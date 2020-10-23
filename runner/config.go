package runner

import "go.uber.org/zap/zapcore"

type Config struct {
	Production bool          `envconfig:"PRODUCTION" default:"false"`
	LogLevel   zapcore.Level `envconfig:"LOG_LEVEL"  default:"info"`
	Settings   string        `envconfig:"SETTINGS_OVERRIDE"`
}
