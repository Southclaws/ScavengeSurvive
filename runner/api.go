package runner

import (
	"context"
	"net/http"
	"os"

	"github.com/fsnotify/fsnotify"
	"github.com/go-chi/chi"
	"go.uber.org/atomic"
)

const amx = "gamemodes/ScavengeSurvive.amx"

func RunAPI(ctx context.Context) {
	rtr := chi.NewRouter()

	update := atomic.NewBool(false)

	rtr.Get("/update", func(w http.ResponseWriter, r *http.Request) {
		if update.Load() {
			w.Write([]byte("update")) //nolint:errcheck
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
	for range w.Events {
		info, err := os.Stat(amx)
		if err != nil {
			continue
		}
		if info.Size() > 0 {
			update.Store(true)
		}
	}
}
