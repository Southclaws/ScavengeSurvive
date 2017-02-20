package main

import (
	"container/ring"
	"fmt"
	"log"
	"strings"

	"github.com/bwmarrin/discordgo"
	"gopkg.in/redis.v5"
)

// Bind represents a link between a Discord channel and a Redis queue
type Bind struct {
	DiscordChannel string
	InputQueue     string
	OutputQueue    string
}

// Message represents a message moving through this app
type Message struct {
	user string
	text string
	// when in the `messagesToDiscord` queue, this represents a Discord channel
	// and when in the `messagesToGame` queue, it represents a queue name.
	destination string
}

// DiscordContext holds program state and shares access to resources
type DiscordContext struct {
	config Config
	// objects
	redisClient       *redis.Client
	discordClient     *discordgo.Session
	messagesToDiscord chan Message
	messagesToGame    chan Message
	messageHistory    *ring.Ring
	done              chan bool
}

func (dc DiscordContext) getOutQueueFromChannel(channel string) string {
	for i := range dc.config.DiscordBinds {
		if channel == dc.config.DiscordBinds[i].DiscordChannel {
			return dc.config.DiscordBinds[i].OutputQueue
		}
	}
	return ""
}

func (dc DiscordContext) getChannelFromInQueue(queue string) string {
	for i := range dc.config.DiscordBinds {
		if queue == dc.config.DiscordBinds[i].InputQueue {
			return dc.config.DiscordBinds[i].DiscordChannel
		}
	}
	return ""
}

// ConnectDiscord will connect to the discord server and redis server and block
func ConnectDiscord(config Config, redisClient *redis.Client) {
	var dc DiscordContext
	var err error

	dc.config = config
	dc.redisClient = redisClient

	dc.discordClient, err = discordgo.New("Bot " + dc.config.DiscordToken)
	if err != nil {
		log.Print("discord client creation error")
		log.Fatal(err)
	}
	log.Print("Connected to Discord")

	dc.messagesToDiscord = make(chan Message)
	dc.messagesToGame = make(chan Message)
	dc.messageHistory = ring.New(32)

	dc.discordClient.AddHandler(dc.ready)

	err = dc.discordClient.Open()
	if err != nil {
		fmt.Println("discord client connection error")
		log.Fatal(err)
	}

	log.Print("Awaiting Discord ready state...")
	dc.done = make(chan bool)
	<-dc.done
}

func (dc DiscordContext) ready(s *discordgo.Session, event *discordgo.Ready) {
	log.Print("Discord ready")
	go dc.awaitFromDiscord()
	go dc.awaitFromGame()
	go dc.awaitToDiscord()
	go dc.awaitToGame()
	dc.messagesToGame <- Message{"System", "Hi, I'm connected!", "samp.chat.discord.incoming"}
	log.Print("discord connector now serving")
}

func (dc DiscordContext) awaitFromDiscord() {
	log.Print("[READY] awaiting messages from discord")
	dc.discordClient.AddHandler(func(s *discordgo.Session, m *discordgo.MessageCreate) {
		destination := dc.getOutQueueFromChannel(m.Message.ChannelID)

		if destination != "" {
			split := strings.SplitN(m.Message.Content, ": ", 2)
			duplicate := false
			if len(split) >= 2 {
				dc.messageHistory.Do(func(i interface{}) {
					if i == split[1] {
						duplicate = true
					}
				})
			}

			if !duplicate {
				message := Message{m.Message.Author.Username, m.Message.Content, destination}
				log.Printf("[RECIEVE DISCORD] %s: '%s' [%s]", m.Message.Author.Username, m.Message.Content, destination)
				dc.messagesToGame <- message
			}
		} else {
			log.Printf("[RECIEVE DISCORD] message arrived with unknown destination bind: '%s'", m.Message.ChannelID)
		}
	})
}

func (dc DiscordContext) awaitFromGame() {
	log.Print("[READY] awaiting messages from game")
	for i := range dc.config.DiscordBinds {
		go func(input string, destination string) {
			for {
				reply, err := dc.redisClient.BLPop(0, input).Result()
				if err != nil {
					log.Print(err)
				} else if len(reply) < 2 {
					log.Print("error: redis reply length lower than 2")
				} else {
					raw := reply[1]
					split := strings.SplitN(raw, ":", 2)

					if len(split) != 2 {
						log.Printf("[RECIEVE GAME] message malformed, no colon delimiter: '%s'", raw)
						continue
					}

					duplicate := false
					dc.messageHistory.Do(func(i interface{}) {
						if i == split[1] {
							duplicate = true
						}
					})

					if !duplicate {
						log.Printf("[RECIEVE GAME] %s: '%s' [%s]", split[0], split[1], destination)
						dc.messagesToDiscord <- Message{split[0], split[1], destination}
					}
				}
			}
		}(dc.config.DiscordBinds[i].InputQueue, dc.config.DiscordBinds[i].DiscordChannel)
	}
}

func (dc DiscordContext) awaitToDiscord() {
	log.Print("[READY] awaiting messages to discord")
	for {
		message := <-dc.messagesToDiscord
		log.Printf("[SEND DISCORD] %s: '%s' [%s]", message.user, message.text, message.destination)

		dc.messageHistory.Value = message.text
		dc.messageHistory.Next()
		text := fmt.Sprintf("%s: %s", message.user, message.text)
		sr, err := dc.discordClient.ChannelMessageSend(message.destination, text)
		if err != nil {
			log.Print(err)
			log.Print(sr)
		}
	}
}

func (dc DiscordContext) awaitToGame() {
	log.Print("[READY] awaiting messages to game")
	for {
		message := <-dc.messagesToGame
		log.Printf("[SEND GAME] %s: '%s' [%s]", message.user, message.text, message.destination)

		dc.messageHistory.Value = message.text
		dc.messageHistory.Next()
		raw := fmt.Sprintf("%s:%s", message.user, message.text)
		response := dc.redisClient.LPush(message.destination, raw)
		if response.Val() < 1 {
			log.Println("redis LPUSH result is less than expected:", response.Val())
		}
	}
}
