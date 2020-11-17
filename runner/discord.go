package runner

import (
	"context"
	"fmt"
	"strings"
	"time"

	sampquery "github.com/Southclaws/go-samp-query"
	"github.com/bwmarrin/discordgo"
	"github.com/cenkalti/backoff/v4"
	"github.com/cskr/pubsub"
	"github.com/pkg/errors"
	"go.uber.org/zap"
)

func RunDiscord(ctx context.Context, ps *pubsub.PubSub, cfg Config) {
	panic(backoff.Retry(func() (err error) {
		defer func() {
			if r := recover(); r != nil {
				switch x := r.(type) {
				case string:
					err = errors.New(x)
				case error:
					err = x
				default:
					err = errors.Errorf("Unknown panic: %v", r)
				}
			}
		}()

		runDiscord(ctx, ps, cfg)

		return nil
	}, &backoff.ExponentialBackOff{
		InitialInterval:     backoff.DefaultInitialInterval,
		RandomizationFactor: backoff.DefaultRandomizationFactor,
		Multiplier:          backoff.DefaultMultiplier,
		MaxInterval:         0,
		MaxElapsedTime:      backoff.DefaultMaxElapsedTime,
		Stop:                backoff.Stop,
		Clock:               backoff.SystemClock,
	}))
}

func runDiscord(ctx context.Context, ps *pubsub.PubSub, cfg Config) {
	discord, err := discordgo.New("Bot " + cfg.DiscordToken)
	if err != nil {
		panic(err)
	}

	discord.ChannelMessageSend(cfg.DiscordChannelInfo, "Scavenge and Survive server starting!") //nolint:errcheck

	discord.AddHandler(func(s *discordgo.Session, m *discordgo.MessageCreate) {
		switch m.Message.Content {
		case "/status":
			server, err := sampquery.GetServerInfo(ctx, "play.scavengesurvive.com:7777", false)
			if err != nil {
				discord.ChannelMessageSend(cfg.DiscordChannelInfo, "Failed to query :("+err.Error()) //nolint:errcheck
			} else {
				discord.ChannelMessageSendEmbed(cfg.DiscordChannelInfo, &discordgo.MessageEmbed{ //nolint:errcheck
					Title: "Server Status",
					Type:  discordgo.EmbedTypeRich,
					Description: fmt.Sprintf(
						"Players: %d/%d\nPing: %d",
						server.Players,
						server.MaxPlayers,
						server.Ping,
					),
					Color: 0xff4700,
				})
			}
		}
	})

	go func() {
		if err := discord.Open(); err != nil {
			panic(err)
		}
	}()

	// these must be pre-created in order to prevent messages being missed
	// during initialisation.
	errorsBacktrace := ps.Sub("errors.backtrace")
	infoRestart := ps.Sub("info.restart")
	infoUpdate := ps.Sub("info.update")
	errorsSingle := ps.Sub("errors.single")

	for {
		select {
		case <-infoRestart:
			// if _, err := discord.ChannelMessageSend(cfg.DiscordChannelInfo, "Server restart!"); err != nil {
			// 	zap.L().Error("failed to send discord message", zap.Error(err))
			// }

		case d := <-infoUpdate:
			if _, err := discord.ChannelMessageSend(cfg.DiscordChannelInfo, fmt.Sprintf("A server update is on the way in %s", d.(time.Duration))); err != nil {
				zap.L().Error("failed to send discord message", zap.Error(err))
			}

		case obj := <-errorsSingle:
			data, ok := obj.(map[string]string)
			if !ok {
				zap.L().Error("failed to get error fields", zap.Any("obj", obj))
			}

			title, ok := data[sampLoggerMessageKey]
			if !ok {
				title = "Error"
			}

			fields := []*discordgo.MessageEmbedField{}
			for k, v := range data {
				if k == sampLoggerMessageKey {
					continue
				}
				fields = append(fields, &discordgo.MessageEmbedField{
					Name:  k,
					Value: v,
				})
			}

			if _, err := discord.ChannelMessageSendEmbed(cfg.DiscordChannelErrors, &discordgo.MessageEmbed{
				Type:   discordgo.EmbedTypeRich,
				Title:  title,
				Fields: fields,
				Color:  0xFF0000,
			}); err != nil {
				zap.L().Error("failed to send discord message", zap.Error(err))
			}
		case obj := <-errorsBacktrace:
			message, ok := obj.(string)
			if !ok {
				zap.L().Error("failed to get error fields", zap.Any("obj", obj))
			}

			// filter out dialogue responses as they contain raw passwords
			lines := strings.Split(message, "\n")
			n := 0
			for _, line := range lines {
				if !strings.Contains(line, "OnDialogResponse") {
					lines[n] = line
					n++
				}
			}
			lines = lines[:n]

			if _, err := discord.ChannelMessageSend(cfg.DiscordChannelErrors, fmt.Sprintf("Error backtrace:\n```\n%s\n```", strings.Join(lines, "\n"))); err != nil {
				zap.L().Error("failed to send discord message", zap.Error(err))
			}
		}
	}
}
