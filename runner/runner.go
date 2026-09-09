package runner

import (
	"context"
	"io"
	"os"
	"os/exec"
	"time"

	"github.com/cskr/pubsub"
	"go.uber.org/zap"
)

// serverLog is the log file open.mp writes alongside its console output. It is
// removed between runs so a crash report always belongs to the current process.
const serverLog = "log.txt"

// restartDelay is how long to wait before starting the server again after it
// has exited.
const restartDelay = time.Second * 5

// stopGracePeriod is how long the server is given to shut down on its own after
// being asked to stop, before it is killed.
const stopGracePeriod = time.Second * 15

func RunServer(ctx context.Context, ps *pubsub.PubSub, r io.Reader, w io.Writer, once bool) {
	zap.L().Info("starting blocking process")

	for {
		err := runBlocking(ctx, ps, r, w)

		// A cancelled context means the runner itself is shutting down, so the
		// server has already been stopped and must not be started again.
		if ctx.Err() != nil {
			zap.L().Info("server stopped")
			return
		}

		if err != nil {
			zap.L().Info("process exited with error, restarting", zap.Error(err))
		} else {
			zap.L().Info("process exited cleanly, restarting")
		}

		cleanup()

		if once {
			return
		}

		select {
		case <-ctx.Done():
			return
		case <-time.After(restartDelay):
		}

		ps.Pub(struct{}{}, "info.restart")
	}
}

// runBlocking starts the server through sampctl and blocks until it exits.
// sampctl generates config.json from the runtime section of pawn.json and then
// launches omp-server, so the runner does not need to know where either the
// server binary or its configuration comes from.
func runBlocking(parentctx context.Context, ps *pubsub.PubSub, in io.Reader, out io.Writer) (err error) {
	ctx, cancel := context.WithCancel(parentctx)
	defer cancel()

	cmd := exec.Command(SampctlBinary, "run")
	cmd.Stdin = in
	isolateProcess(cmd)

	r := cmdReader(cmd)
	if err := cmd.Start(); err != nil {
		return err
	}

	go func() {
		// TODO: Handle IO copy errors.
		// nolint:errcheck
		io.Copy(out, r)
	}()

	finished := make(chan struct{})
	go stopOnSignal(ctx, ps, cmd, finished)

	err = cmd.Wait()
	close(finished)

	return err
}

// stopOnSignal stops the server when a restart is requested or the runner is
// shutting down, and kills it if it does not stop on its own in time. It
// returns as soon as the server exits, whatever the reason.
func stopOnSignal(ctx context.Context, ps *pubsub.PubSub, cmd *exec.Cmd, finished <-chan struct{}) {
	restart := ps.SubOnce("restart")
	defer ps.Unsub(restart, "restart")

	select {
	case <-restart:
		zap.L().Info("internally triggered process restart")
	case <-ctx.Done():
	case <-finished:
		return
	}

	if err := terminateProcess(cmd); err != nil {
		zap.L().Info("failed to stop server process", zap.Error(err))
	}

	select {
	case <-finished:
	case <-time.After(stopGracePeriod):
		zap.L().Info("server did not stop in time, killing it")
		if err := killProcess(cmd); err != nil {
			zap.L().Info("failed to kill server process", zap.Error(err))
		}
	}
}

func cmdReader(cmd *exec.Cmd) io.Reader {
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return nil
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		return nil
	}
	return io.MultiReader(stdout, stderr)
}

func cleanup() {
	os.Remove(serverLog) //nolint:errcheck
}
