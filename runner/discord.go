package runner

import (
	"context"
	"fmt"
	"time"

	sampquery "github.com/Southclaws/go-samp-query"
	"github.com/cskr/pubsub"
	"github.com/diamondburned/arikawa/discord"
	"github.com/diamondburned/arikawa/gateway"
	"github.com/diamondburned/arikawa/session"
	"go.uber.org/zap"
)

func RunDiscord(ctx context.Context, ps *pubsub.PubSub, cfg Config) {
	s, err := session.New("Bot " + cfg.DiscordToken)
	if err != nil {
		panic(err)
	}

	channelid := new(discord.ChannelID)
	if err := channelid.UnmarshalJSON([]byte(cfg.DiscordChannel)); err != nil {
		panic(err)
	}

	s.AddHandler(func(c *gateway.MessageCreateEvent) {
		switch c.Content {
		case "/status":
			server, err := sampquery.GetServerInfo(ctx, "play.scavengesurvive.com:7777", false)
			if err != nil {
				s.SendMessage(*channelid, "Failed to query :("+err.Error(), nil)
			} else {
				s.SendMessage(*channelid, "", &discord.Embed{
					Title: "Server Status",
					Type:  discord.NormalEmbed,
					Description: fmt.Sprintf(
						"Players: %d/%d\nPing: %d",
						server.Players,
						server.MaxPlayers,
						server.Ping,
					),
					Color: discord.Color(0xff4700),
				})
			}
		}
	})

	if err := s.Open(); err != nil {
		panic(err)
	}
	defer s.Close()

	if _, err = s.Me(); err != nil {
		panic(err)
	}

	for range ps.Sub("server_restart") {
		if _, err := s.SendMessage(*channelid, "Server restart!", nil); err != nil {
			zap.L().Error("failed to send discord message", zap.Error(err))
		}
	}

	for d := range ps.Sub("server_update") {
		if _, err := s.SendMessage(*channelid, fmt.Sprintf("A server update is on the way in %s", d.(time.Duration)), nil); err != nil {
			zap.L().Error("failed to send discord message", zap.Error(err))
		}
	}
}
