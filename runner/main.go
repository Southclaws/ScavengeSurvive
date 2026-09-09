package runner

import (
	"context"
	"os"
	"os/signal"
	"path/filepath"
	"sync"
	"time"

	"github.com/cskr/pubsub"
	"github.com/pkg/errors"
	"go.uber.org/zap"
)

func Run(cfg Config) error {
	zap.L().Info("scavenge and survive runner initialising")

	dir, err := os.Getwd()
	if err != nil {
		return errors.Wrap(err, "failed to get current working directory")
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	if shouldEnsure(dir) {
		if err := EnsureDependencies(ctx); err != nil {
			return err
		}
		if err := BuildGamemode(ctx); err != nil {
			return err
		}
	}

	zap.L().Info("prepared runtime environment")

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, os.Interrupt)

	if cfg.Settings != "" {
		WriteSettings(cfg.Settings)
	}

	ps := pubsub.New(0)

	if cfg.AutoBuild {
		go RunWatcher(ctx)
	}

	go RunAPI(ctx, ps, cfg.Restart)
	if cfg.DiscordToken != "" {
		go RunDiscord(ctx, ps, cfg)
	}

	time.Sleep(time.Second)

	parser := ReactiveParser{ps}

	// The server is waited on during shutdown, so that the runner does not exit
	// and leave the server it started running without a supervisor.
	var server sync.WaitGroup
	server.Add(1)
	go func() {
		defer server.Done()
		RunServer(ctx, ps, os.Stdin, parser.GetWriter(), false)
	}()

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
			zap.L().Info("shutting down, stopping server")
			cancel()
			server.Wait()
			return err
		}

		time.Sleep(time.Millisecond * 100)
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
