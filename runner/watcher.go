package runner

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/Southclaws/sampctl/pkgcontext"
	"github.com/fsnotify/fsnotify"
	"go.uber.org/zap"
)

func RunWatcher(ctx context.Context, pcx *pkgcontext.PackageContext) {
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

	last := time.Time{}

	for {
		select {
		case e := <-w.Events:
			if time.Since(last) < time.Second*10 {
				zap.L().Debug("ignoring frequent change", zap.Duration("since", time.Since(last)))
				continue
			}

			zap.L().Debug("source code change", zap.String("event", e.String()))

			fmt.Print("\n")

			last = time.Now()
			_, _, err := pcx.Build(ctx, "", false, false, false, "BUILD_NUMBER")
			if err != nil {
				zap.L().Info("build failed", zap.Error(err))
				continue
			}

			fmt.Print("\n")

			zap.L().Info("build finished", zap.Duration("duration", time.Since(last)))

		case e := <-w.Errors:
			zap.L().Info("watcher error", zap.Error(e))

		case <-ctx.Done():
			return
		}
	}
}
