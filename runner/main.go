package runner

import (
	"context"
	"os"
	"os/signal"
	"path/filepath"
	"runtime"
	"time"

	"github.com/Southclaws/sampctl/download"
	"github.com/Southclaws/sampctl/rook"
	"github.com/cskr/pubsub"
	"github.com/google/go-github/github"
	"github.com/pkg/errors"
	"go.uber.org/zap"
)

func Run(cfg Config) error {
	zap.L().Info("scavenge and survive runner initialising")

	dir, err := os.Getwd()
	if err != nil {
		return errors.Wrap(err, "failed to get current working directory")
	}

	forceBuild := false
	forceEnsure := false
	if shouldEnsure(dir) {
		forceBuild = true
		forceEnsure = true
	}

	cacheDir, err := download.GetCacheDir()
	if err != nil {
		return errors.Wrap(err, "failed to get cache directory")
	}

	gh := github.NewClient(nil)

	pcx, err := rook.NewPackageContext(gh, nil, true, dir, runtime.GOOS, cacheDir, "")
	if err != nil {
		return errors.Wrap(err, "failed to interpret directory as Pawn package")
	}

	pcx.CacheDir = cacheDir
	pcx.ForceBuild = forceBuild
	pcx.ForceEnsure = forceEnsure
	pcx.Relative = true
	if cfg.RconPassword != "" {
		pcx.Package.Runtime.RCONPassword = &cfg.RconPassword
	}

	if err := pcx.RunPrepare(context.Background()); err != nil {
		return errors.Wrap(err, "failed to prepare runtime")
	}

	zap.L().Info("prepared runtime environment")

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, os.Interrupt)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	if cfg.Settings != "" {
		WriteSettings(cfg.Settings)
	}

	ps := pubsub.New(0)

	if cfg.AutoBuild {
		go RunWatcher(ctx, pcx)
	}

	go RunAPI(ctx, ps, cfg.Restart)
	if cfg.DiscordToken != "" {
		go RunDiscord(ctx, ps, cfg)
	}

	time.Sleep(time.Second)

	parser := ReactiveParser{ps}
	go RunServer(ctx, ps, os.Stdin, parser.GetWriter(), false)

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

func shouldEnsure(dir string) bool {
	if isDirEmpty(dir) {
		zap.L().Info("Current directory is empty, cloning new copy of Scavenge and Survive")
		if err := Ensure(); err != nil {
			panic(errors.Wrap(err, "failed to ensure"))
		}
		zap.L().Info("doing first-time ensure and build: current dir is empty")
		return true
	}

	if _, err := os.Stat(filepath.Join(dir, "dependencies")); os.IsNotExist(err) {
		zap.L().Info("doing first-time ensure and build: dependencies missing")
		return true
	}

	if i, err := os.Stat(filepath.Join(dir, "gamemodes/ScavengeSurvive.amx")); os.IsNotExist(err) || i.Size() == 0 {
		zap.L().Info("doing first-time ensure and build: amx missing or empty")
		return true
	}
	return false
}
