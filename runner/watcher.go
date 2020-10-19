package runner

import (
	"context"
	"fmt"
	"time"

	"github.com/Southclaws/sampctl/pkgcontext"
	"github.com/fsnotify/fsnotify"
	"go.uber.org/zap"
)

func RunWatcher(ctx context.Context, pcx *pkgcontext.PackageContext) {
	w, err := fsnotify.NewWatcher()
	if err != nil {
		panic(err)
	}
	defer w.Close()

	err = w.Add("gamemodes/sss")
	if err != nil {
		panic(err)
	}

	err = w.Add("gamemodes/ScavengeSurvive.pwn")
	if err != nil {
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
