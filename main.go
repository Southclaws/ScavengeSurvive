package main

import (
	"context"
	"os"
	"os/exec"
	"os/signal"
	"runtime"

	"github.com/Southclaws/sampctl/download"
	"github.com/Southclaws/sampctl/pkgcontext"
	"github.com/google/go-github/github"
	"github.com/pkg/errors"
	"go.uber.org/zap"
)

func main() {
	if err := run(); err != nil {
		zap.L().Fatal("unexpected exit", zap.Error(err))
	}
}

func run() error {
	dir, err := os.Getwd()
	if err != nil {
		return err
	}

	cacheDir, err := download.GetCacheDir()
	if err != nil {
		return err
	}

	gh := github.NewClient(nil)

	pcx, err := pkgcontext.NewPackageContext(gh, nil, true, dir, runtime.GOOS, cacheDir, "")
	if err != nil {
		return errors.Wrap(err, "failed to interpret directory as Pawn package")
	}

	// pcx.Runtime = runtimeName
	pcx.CacheDir = cacheDir
	// pcx.BuildName = build
	pcx.ForceBuild = true
	pcx.ForceEnsure = false
	pcx.BuildFile = "BUILD_NUMBER"
	pcx.Relative = true

	if err := pcx.RunPrepare(context.Background()); err != nil {
		return errors.Wrap(err, "failed to prepare runtime")
	}

	return execute()
}

func execute() error {
	cmd := exec.CommandContext(context.Background(), "./samp-server.exe")
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, os.Interrupt)

	select {
	case <-sigs:
		return cmd.Process.Signal(os.Kill)
	}

	return nil
}
