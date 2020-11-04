package runner

import (
	"time"

	"go.uber.org/zap/zapcore"
)

type Config struct {
	Production           bool          `envconfig:"PRODUCTION"         default:"false"`
	LogLevel             zapcore.Level `envconfig:"LOG_LEVEL"          default:"info"`
	Settings             string        `envconfig:"SETTINGS_OVERRIDE"`
	Restart              time.Duration `envconfig:"AUTO_RESTART_TIME"  default:"1h"`
	AutoBuild            bool          `envconfig:"AUTO_BUILD"         default:"false"`
	DiscordToken         string        `envconfig:"DISCORD_TOKEN"      default:""`
	DiscordChannelInfo   string        `envconfig:"DISCORD_CHANNEL_INFO"    default:""`
	DiscordChannelErrors string        `envconfig:"DISCORD_CHANNEL_ERRORS"    default:""`
	RconPassword         string        `envconfig:"RCON_PASSWORD"      default:"scavenge"`
}
