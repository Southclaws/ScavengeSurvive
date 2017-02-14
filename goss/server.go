package main

import (
	"fmt"
	"log"

	"encoding/json"
	"os"

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

// API holds program state and shares access to resources
type API struct {
	// settings
	RedisHost    string
	DiscordToken string
	DiscordBinds []Bind
	// objects
	redisClient       *redis.Client
	discordClient     *discordgo.Session
	messagesToDiscord chan Message
	messagesToGame    chan Message
	messageHistory    []string
	done              chan bool
}

func (api API) getOutQueueFromChannel(channel string) string {
	for i := range api.DiscordBinds {
		if channel == api.DiscordBinds[i].DiscordChannel {
			return api.DiscordBinds[i].OutputQueue
		}
	}
	return ""
}

func (api API) getChannelFromInQueue(queue string) string {
	for i := range api.DiscordBinds {
		if queue == api.DiscordBinds[i].InputQueue {
			return api.DiscordBinds[i].DiscordChannel
		}
	}
	return ""
}

func main() {
	var api API
	var err error

	err = api.loadConfig("config.json")
	if err != nil {
		log.Print("config load error")
		log.Fatal(err)
	}

	api.redisClient = redis.NewClient(&redis.Options{
		Addr: api.RedisHost,
	})
	_, err = api.redisClient.Ping().Result()
	if err != nil {
		log.Print("redis ping error")
		log.Fatal(err)
	}
	log.Print("Connected to Redis")

	api.discordClient, err = discordgo.New("Bot " + api.DiscordToken)
	if err != nil {
		log.Print("discord client creation error")
		log.Fatal(err)
	}
	log.Print("Connected to Discord")

	api.messagesToDiscord = make(chan Message)
	api.messagesToGame = make(chan Message)

	api.discordClient.AddHandler(api.ready)

	err = api.discordClient.Open()
	if err != nil {
		fmt.Println("discord client connection error")
		log.Fatal(err)
	}

	log.Print("Awaiting Discord ready state...")
	api.done = make(chan bool)
	<-api.done
}

func (api API) ready(s *discordgo.Session, event *discordgo.Ready) {
	log.Print("Discord ready")
	go api.awaitFromDiscord()
	go api.awaitFromGame()
	go api.awaitToDiscord()
	go api.awaitToGame()
	api.messagesToGame <- Message{"System", "Hi, I'm connected!", "samp.chat.discord.incoming"}
	log.Print("discord connector now serving")
}

func (api API) awaitFromDiscord() {
	log.Print("[READY] awaiting messages from discord")
	api.discordClient.AddHandler(func(s *discordgo.Session, m *discordgo.MessageCreate) {
		destination := api.getOutQueueFromChannel(m.Message.ChannelID)

		if destination != "" {
			message := Message{m.Message.Author.Username, m.Message.Content, destination}
			log.Printf("[RECIEVE DISCORD] %s: '%s' [%s]", m.Message.Author.Username, m.Message.Content, destination)

			api.messagesToGame <- message
		} else {
			log.Printf("[RECIEVE DISCORD] message arrived with unknown destination bind: '%s'", m.Message.ChannelID)
		}
	})
}

func (api API) awaitFromGame() {
	log.Print("[READY] awaiting messages from game")
	for i := range api.DiscordBinds {
		go func(input string, destination string) {
			for {
				reply, err := api.redisClient.BLPop(0, input).Result()
				if err != nil {
					log.Print(err)
				} else if len(reply) < 2 {
					log.Print("error: redis reply length lower than 2")
				} else {
					raw := reply[1]
					split := strings.SplitN(raw, ":", 2)
					log.Printf("[RECIEVE GAME] %s: '%s' [%s]", split[0], split[1], destination)
					api.messagesToDiscord <- Message{split[0], split[1], destination}
				}
			}
		}(api.DiscordBinds[i].InputQueue, api.DiscordBinds[i].DiscordChannel)
	}
}

func (api API) awaitToDiscord() {
	log.Print("[READY] awaiting messages to discord")
	for {
		message := <-api.messagesToDiscord
		log.Printf("[SEND DISCORD] %s: '%s' [%s]", message.user, message.text, message.destination)

		messageHistory = append(messageHistory, text)
		text := fmt.Sprintf("%s: %s", message.user, message.text)
		sr, err := api.discordClient.ChannelMessageSend(message.destination, text)
		if err != nil {
			log.Print(err)
			log.Print(sr)
		}
	}
}

func (api API) awaitToGame() {
	log.Print("[READY] awaiting messages to game")
	for {
		message := <-api.messagesToGame
		log.Printf("[SEND GAME] %s: '%s' [%s]", message.user, message.text, message.destination)

		messageHistory = append(messageHistory, message.text)
		raw := fmt.Sprintf("%s:%s", message.user, message.text)
		response := api.redisClient.LPush(message.destination, raw)
		if response.Val() < 1 {
			log.Println("redis LPUSH result is less than expected:", response.Val())
		}
	}
}

func (api *API) loadConfig(filename string) error {
	file, err := os.Open(filename)
	if err != nil {
		return err
	}

	json.NewDecoder(file).Decode(&api)

	err = file.Close()
	if err != nil {
		return err
	}

	log.Printf("Loaded config:")
	log.Printf("RedisHost: '%s'", api.RedisHost)
	log.Printf("DiscordToken: (%d chars)", len(api.DiscordToken))
	log.Printf("channel binds:")
	for i := range api.DiscordBinds {
		log.Printf("- %s <> %s:%s", api.DiscordBinds[i].DiscordChannel, api.DiscordBinds[i].InputQueue, api.DiscordBinds[i].OutputQueue)
	}
	log.Printf("~")

	return nil
}
