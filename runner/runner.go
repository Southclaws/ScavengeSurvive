package runner

import (
	"context"
	"fmt"
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
	binary, err := serverBinary(runtime.GOOS)
	if err != nil {
		return err
	}
	return runBlockingCommand(parentctx, ps, in, out, binary)
}

func serverBinary(goos string) (string, error) {
	switch goos {
	case "windows":
		return "./samp-server.exe", nil
	case "linux":
		return "./samp03svr", nil
	default:
		return "", fmt.Errorf("unsupported server platform %q", goos)
	}
}

func runBlockingCommand(parentctx context.Context, ps *pubsub.PubSub, in io.Reader, out io.Writer, binary string) (err error) {
	ctx, cancel := context.WithCancel(parentctx)
	defer cancel()

	cmd := exec.CommandContext(ctx, binary)
	cmd.Stdin = in
	cmd.Stdout = out
	cmd.Stderr = out
	if err := cmd.Start(); err != nil {
		return err
	}

	go func() {
		<-ps.SubOnce("restart")
		zap.L().Info("internally triggered process restart")
		cancel()
	}()

	return cmd.Wait()
}

func cleanup() {
	os.Remove("server_log.txt") //nolint:errcheck
}
