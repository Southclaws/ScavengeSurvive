package main

import (
	"flag"
	"fmt"
	"log"

	"github.com/bwmarrin/discordgo"
	"gopkg.in/redis.v5"
)

// API holds program state and shares access to resources
type API struct {
	redisClient       *redis.Client
	discordClient     *discordgo.Session
	discordChannel    string
	messagesToDiscord chan string
	messagesToGame    chan string
	done              chan bool
}

func main() {
	var api API
	var token string
	var redisHost string
	var err error

	flag.StringVar(&token, "a", "", "Auth token")
	flag.StringVar(&redisHost, "h", "localhost:6379", "Redis host:port")
	flag.StringVar(&api.discordChannel, "c", "", "Discord channel")
	flag.Parse()

	log.Print("Discord connector initialising")
	log.Printf("redisHost: '%s'", redisHost)
	log.Printf("discordChannel: '%s'", api.discordChannel)

	if token == "" {
		log.Print("Provide an auth token via -a")
		return
	}

	api.redisClient = redis.NewClient(&redis.Options{
		Addr: redisHost,
	})
	_, err = api.redisClient.Ping().Result()
	if err != nil {
		log.Print(err)
		return
	}
	log.Print("Connected to Redis")

	api.discordClient, err = discordgo.New("Bot " + token)
	if err != nil {
		fmt.Println(err)
		return
	}
	log.Print("Connected to Discord")

	api.messagesToDiscord = make(chan string)
	api.messagesToGame = make(chan string)

	api.discordClient.AddHandler(api.ready)

	err = api.discordClient.Open()
	if err != nil {
		fmt.Println("error opening connection,", err)
		return
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
	api.messagesToGame <- "Hi, I'm connected!"
	log.Print("discord connector now serving")
}

func (api API) awaitFromDiscord() {
	log.Print("[READY] awaiting messages from discord")
	api.discordClient.AddHandler(func(s *discordgo.Session, m *discordgo.MessageCreate) {
		message := m.Message.Content
		log.Print("[RECIEVE DISCORD]:", message)

		api.messagesToGame <- message
	})
}

func (api API) awaitFromGame() {
	log.Print("[READY] awaiting messages from game")
	for {
		reply, err := api.redisClient.BLPop(0, "samp.chat.discord.outgoing").Result()
		if err != nil {
			log.Print(err)
		} else if len(reply) < 2 {
			log.Print("error: redis reply length lower than 2")
		} else {
			message := reply[1]
			log.Print("[RECIEVE GAME]:", message)
			api.messagesToDiscord <- message
		}
	}
}

func (api API) awaitToDiscord() {
	log.Print("[READY] awaiting messages to discord")
	for {
		message := <-api.messagesToDiscord
		log.Print("[SEND DISCORD]:", message)

		sr, err := api.discordClient.ChannelMessageSend(api.discordChannel, message)
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
		log.Print("[SEND GAME]:", message)

		response := api.redisClient.LPush("samp.chat.discord.incoming", message)
		if response.Val() < 1 {
			log.Println("redis LPUSH result is less than expected:", response.Val())
		}
	}
}
