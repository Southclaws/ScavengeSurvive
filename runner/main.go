package runner

import (
	"context"
	"os"
	"os/signal"
	"runtime"

	"github.com/Southclaws/sampctl/download"
	"github.com/Southclaws/sampctl/pkgcontext"
	"github.com/google/go-github/github"
	"github.com/pkg/errors"
	"go.uber.org/zap"
)

func Run() error {
	zap.L().Info("scavenge and survive runner initialising")

	dir, err := os.Getwd()
	if err != nil {
		return errors.Wrap(err, "failed to get current working directory")
	}

	forceBuild := false
	forceEnsure := false
	if isDirEmpty(dir) {
		zap.L().Info("Current directory is empty, cloning new copy of Scavenge and Survive")
		if err := Ensure(); err != nil {
			return errors.Wrap(err, "failed to ensure")
		}
		forceBuild = true
		forceEnsure = true
		zap.L().Info("doing first-time ensure and build")
	}

	cacheDir, err := download.GetCacheDir()
	if err != nil {
		return errors.Wrap(err, "failed to get cache directory")
	}

	gh := github.NewClient(nil)

	pcx, err := pkgcontext.NewPackageContext(gh, nil, true, dir, runtime.GOOS, cacheDir, "")
	if err != nil {
		return errors.Wrap(err, "failed to interpret directory as Pawn package")
	}

	// pcx.Runtime = runtimeName
	pcx.CacheDir = cacheDir
	// pcx.BuildName = build
	pcx.ForceBuild = forceBuild
	pcx.ForceEnsure = forceEnsure
	pcx.BuildFile = "BUILD_NUMBER"
	pcx.Relative = true

	if err := pcx.RunPrepare(context.Background()); err != nil {
		return errors.Wrap(err, "failed to prepare runtime")
	}

	zap.L().Info("prepared runtime environment")

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, os.Interrupt)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	if os.Getenv("AUTO_BUILD") != "" {
		go RunWatcher(ctx, pcx)
	}

	go RunServer(ctx, os.Stdin, os.Stdout)

	zap.L().Info("awaiting signals, cancellations or fatal errors")

	f := func() error {
		select {
		case s := <-sigs:
			return errors.Errorf("signal received: %s", s.String())

		case <-ctx.Done():
			return context.Canceled

		default:
			return nil
		}
	}

	for {
		if err := f(); err != nil {
			return err
		}
	}
}
