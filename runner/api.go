package runner

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/cskr/pubsub"
	"github.com/fsnotify/fsnotify"
	"github.com/go-chi/chi"
	"go.uber.org/atomic"
	"go.uber.org/zap"
)

const amx = "gamemodes/ScavengeSurvive.amx"

func RunAPI(ctx context.Context, ps *pubsub.PubSub, restartTime time.Duration) {
	rtr := chi.NewRouter()

	update := atomic.NewBool(false)

	rtr.Get("/update", func(w http.ResponseWriter, r *http.Request) {
		if update.Load() {
			zap.L().Info("sending restart signal", zap.Duration("time", restartTime))
			w.Write([]byte(fmt.Sprintf("update %d", int(restartTime.Seconds())))) //nolint:errcheck
			ps.Pub(restartTime, "info.update")
		}

		update.Store(false)
	})

	go http.ListenAndServe(":7788", rtr) //nolint:errcheck

	w, err := fsnotify.NewWatcher()
	if err != nil {
		panic(err)
	}

	err = w.Add(amx)
	if err != nil {
		panic(err)
	}
	last := time.Now()
	for e := range w.Events {
		if func() bool {
			lastInfo, err := os.Stat(amx)
			if err != nil {
				return false
			}
			if time.Since(last) < time.Second*30 {
				return false
			}
			currInfo, err := os.Stat(amx)
			if err != nil {
				return false
			}

			// sleep for a bit, to check if the file is changing in size
			time.Sleep(time.Second)

			// if the file grew in size, it's being compiled
			if currInfo.Size() > lastInfo.Size() {
				zap.L().Debug("compilation in progress",
					zap.Int64("size", currInfo.Size()),
					zap.String("op", e.Op.String()))
				return false
			}

			if currInfo.Size() < 50000000 {
				zap.L().Debug("amx file is too small",
					zap.Int64("size", currInfo.Size()),
					zap.String("op", e.Op.String()))
				return false
			}

			if currInfo.Size() != lastInfo.Size() {
				return false
			}

			if e.Op&fsnotify.Write|fsnotify.Create == 0 {
				return false
			}

			last = time.Now()
			return true
		}() {
			zap.L().Debug("detected non-zero sized amx file change",
				zap.String("op", e.Op.String()))
			update.Store(true)
		} else {
			update.Store(false)
		}
	}
}
