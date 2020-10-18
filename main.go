package main

import (
	"fmt"
	"os"
	"strconv"

	"github.com/Southclaws/ScavengeSurvive/runner"
	"github.com/joho/godotenv"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

func main() {
	if err := runner.Run(); err != nil {
		zap.L().Info("unexpected exit", zap.String("error", err.Error()))
	}
	zap.L().Info("exited gracefully")
}

func init() {
	//nolint:errcheck
	godotenv.Load()

	prod, err := strconv.ParseBool(os.Getenv("PRODUCTION"))
	if _, ok := err.(*strconv.NumError); !ok {
		fmt.Println("Failed to parse environment variable `PRODUCTION`", os.Getenv("PRODUCTION"), "error:", err)
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
