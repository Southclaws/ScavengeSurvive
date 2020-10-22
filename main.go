package main

import (
	"os"
	"time"

	"github.com/Southclaws/ScavengeSurvive/runner"
	_ "github.com/joho/godotenv/autoload"
	"github.com/kelseyhightower/envconfig"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"gopkg.in/natefinch/lumberjack.v2"
)

type config struct {
	Production bool          `envconfig:"PRODUCTION" default:"false"`
	LogLevel   zapcore.Level `envconfig:"LOG_LEVEL"  default:"info"`
}

var logFileNameFormat = `logs/server-2006-01-02.log`

func main() {
	// Logger config is quite important for this app so it goes first in main().

	var cfg config
	envconfig.MustProcess("", &cfg)

	var encoder zapcore.Encoder
	if cfg.Production {
		encoder = zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig())
	} else {
		ec := zap.NewDevelopmentEncoderConfig()
		ec.EncodeLevel = zapcore.CapitalColorLevelEncoder
		encoder = zapcore.NewConsoleEncoder(ec)
	}

	zap.ReplaceGlobals(zap.New(zapcore.NewTee(
		zapcore.NewCore(
			encoder,
			zapcore.Lock(os.Stdout),
			cfg.LogLevel,
		),
		zapcore.NewCore(
			encoder,
			zapcore.AddSync(&lumberjack.Logger{
				Filename: time.Now().Format(logFileNameFormat),
				MaxSize:  100, // MB
			}),
			cfg.LogLevel,
		),
	)))
	zap.L().Info("logger configured", zap.Any("config", cfg))

	// Now run the app itself.
	if err := runner.Run(); err != nil {
		zap.L().Info("unexpected exit", zap.String("error", err.Error()))
	} else {
		zap.L().Info("exited gracefully")
	}
}
