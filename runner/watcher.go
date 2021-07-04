package runner

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/Southclaws/sampctl/rook"
	"github.com/fsnotify/fsnotify"
	"go.uber.org/zap"
)

func RunWatcher(parent context.Context, pcx *rook.PackageContext) {
	zap.L().Info("starting file watcher for auto rebuild")

	w, err := fsnotify.NewWatcher()
	if err != nil {
		panic(err)
	}
	defer w.Close()

	if err := filepath.Walk("gamemodes", func(path string, f os.FileInfo, _ error) error {
		if filepath.Ext(path) == ".pwn" {
			zap.L().Debug("watching", zap.String("match", path))
			err = w.Add(path)
			if err != nil {
				panic(err)
			}
		}
		return nil
	}); err != nil {
		panic(err)
	}

	var ctx context.Context
	var cancel context.CancelFunc
	defer func() {
		if cancel != nil {
			cancel()
		}
	}()
	builds := make(chan error)
	running := false
	last := time.Time{}
	for {
		select {
		case e := <-w.Events:
			if time.Since(last) < time.Second {
				continue
			}

			if running {
				zap.L().Debug("cancelling existing build job")
				cancel()
			}

			zap.L().Debug("source code change", zap.String("event", e.String()))

			ctx, cancel = context.WithCancel(parent)
			running = true
			last = time.Now()

			go doBuild(ctx, pcx, builds)

		case err := <-builds:
			if err != nil {
				zap.L().Info("build failed", zap.Error(err))
			} else {
				zap.L().Info("build finished", zap.Duration("duration", time.Since(last)))
			}
			running = false

		case e := <-w.Errors:
			zap.L().Info("watcher error", zap.Error(e))

		case <-parent.Done():
			if cancel != nil {
				cancel()
			}
			return
		}
	}
}

func doBuild(ctx context.Context, pcx *rook.PackageContext, results chan error) {
	fmt.Print("\n") // output padding, for readability of build errors etc.
	_, _, err := pcx.Build(ctx, "", false, false, false, "")
	if err != nil {
		zap.L().Info("build failed", zap.Error(err))
		results <- err
	}
	fmt.Print("\n")

	results <- nil
}
