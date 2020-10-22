package runner

import (
	"context"
	"io"
	"os"
	"os/exec"
	"runtime"
	"time"

	"go.uber.org/zap"
)

func RunServer(ctx context.Context, r io.Reader, w io.Writer, once bool) {
	zap.L().Info("starting blocking process")

	// a signaller that uses logs to understand when the gamemode is restarting
	// with gmx that means this program can kill the process and restart it.
	restartKiller := make(chan struct{})
	outputWriter := LogParser(restartKiller)

	for {
		err := runBlocking(ctx, restartKiller, r, outputWriter)
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
	}
}

func runBlocking(parentctx context.Context, restartKiller chan struct{}, in io.Reader, out io.Writer) (err error) {
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
		<-restartKiller
		time.Sleep(time.Second * 5)
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
