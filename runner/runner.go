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

func RunServer(ctx context.Context, ps *pubsub.PubSub, r io.Reader, w io.Writer, once bool) {
	zap.L().Info("starting blocking process")

	for {
		err := runBlocking(ctx, ps, r, w)
		if err != nil {
			if err == context.Canceled {
				break
			}
			zap.L().Info("process exited with error, restarting", zap.Error(err))
		} else {
			zap.L().Info("process exited cleanly, restarting")
		}

		cleanup()

		if once {
			break
		}

		time.Sleep(time.Second * 5)
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

	go func() {
		select {
		case <-ps.SubOnce("restart"):
			zap.L().Info("internally triggered process restart")
		case <-ctx.Done():
		}

		if err := terminateProcess(cmd); err != nil {
			zap.L().Info("failed to stop server process", zap.Error(err))
		}
	}()

	return cmd.Wait()
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
