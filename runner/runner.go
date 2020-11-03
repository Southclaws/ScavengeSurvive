package runner

import (
	"context"
	"io"
	"os"
	"os/exec"
	"runtime"
	"time"

	"github.com/cskr/pubsub"
	"go.uber.org/zap"
)

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

func runBlocking(parentctx context.Context, ps *pubsub.PubSub, in io.Reader, out io.Writer) (err error) {
	ctx, cancel := context.WithCancel(parentctx)
	defer cancel()

	var binary string
	switch runtime.GOOS {
	case "windows":
		binary = "./samp-server.exe"
	case "linux":
		binary = "./samp03svr"
	default:
		panic("unknown OS")
	}

	cmd := exec.CommandContext(ctx, binary)
	cmd.Stdin = in
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
		<-ps.SubOnce("restart")
		zap.L().Info("internally triggered process restart")
		cancel()
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
	os.Remove("server_log.txt") //nolint:errcheck
}
