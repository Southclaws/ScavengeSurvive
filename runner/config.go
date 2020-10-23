package runner

import (
	"time"

	"go.uber.org/zap/zapcore"
)

type Config struct {
	Production bool          `envconfig:"PRODUCTION" default:"false"`
	LogLevel   zapcore.Level `envconfig:"LOG_LEVEL"  default:"info"`
	Settings   string        `envconfig:"SETTINGS_OVERRIDE"`
	Restart    time.Duration `envconfig:"AUTO_RESTART_TIME" default:"1h"`
}
