package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"runtime"
	"strconv"

	"github.com/Southclaws/ScavengeSurvive/runner"
	"github.com/Southclaws/sampctl/download"
	"github.com/Southclaws/sampctl/pkgcontext"
	"github.com/google/go-github/github"
	"github.com/joho/godotenv"
	"github.com/pkg/errors"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

func main() {

	if err := run(); err != nil {
		zap.L().Info("unexpected exit", zap.String("error", err.Error()))
	}
	zap.L().Info("exited gracefully")
}

func run() error {
	zap.L().Info("scavenge and survive runner initialising")

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
	pcx.ForceBuild = false
	pcx.ForceEnsure = false
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

	go runner.Run(ctx, os.Stdin, os.Stdout)

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

func init() {
	//nolint:errcheck
	godotenv.Load()

	prod, err := strconv.ParseBool(os.Getenv("PRODUCTION"))
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	var config zap.Config
	if prod {
		config = zap.NewProductionConfig()
	} else {
		config = zap.NewDevelopmentConfig()
	}

	var level zapcore.Level
	if err := level.UnmarshalText([]byte(os.Getenv("LOG_LEVEL"))); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	config.DisableCaller = true
	config.Level.SetLevel(level)
	config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	// config.OutputPaths = []string{fmt.Sprintf("logs/%v.log", time.Now().Format("2006-01-02"))}

	logger, err := config.Build()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	zap.ReplaceGlobals(logger)

	if !prod {
		zap.L().Info("logger configured in development mode", zap.String("level", level.String()))
	}
}
