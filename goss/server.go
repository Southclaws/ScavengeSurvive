package main

import (
	"encoding/json"
	"log"
	"os"

	redis "gopkg.in/redis.v5"

	"github.com/Southclaws/goss"
)

// Config stores app global configuration
type Config struct {
	RedisHost    string
	DiscordToken string
	DiscordBinds []Bind
}

func main() {

	// Config

	cfg, err := loadConfig("config.json")
	if err != nil {
		log.Print("config load error")
		log.Fatal(err)
	}

	// Database

	db, err := ssdb.ConnectDatabase("ss.db")
	if err != nil {
		panic(err)
	}

	var count int
	db.Model(&ssdb.PlayerAccount{}).Count(&count)

	log.Printf("Connected to database, player count: %d", count)

	// Redis

	redisClient := redis.NewClient(&redis.Options{
		Addr: cfg.RedisHost,
	})
	_, err = redisClient.Ping().Result()
	if err != nil {
		log.Print("redis ping error")
		log.Fatal(err)
	}
	log.Print("Connected to Redis")

	// Discord

	go ConnectDiscord(cfg, redisClient)
}

func loadConfig(filename string) (Config, error) {
	var config Config
	file, err := os.Open(filename)
	if err != nil {
		return config, err
	}

	json.NewDecoder(file).Decode(&config)

	err = file.Close()
	if err != nil {
		return config, err
	}

	log.Printf("Loaded config:")
	log.Printf("RedisHost: '%s'", config.RedisHost)
	log.Printf("DiscordToken: (%d chars)", len(config.DiscordToken))
	log.Printf("channel binds:")
	for i := range config.DiscordBinds {
		log.Printf("- %s <> %s:%s", config.DiscordBinds[i].DiscordChannel, config.DiscordBinds[i].InputQueue, config.DiscordBinds[i].OutputQueue)
	}
	log.Printf("~")

	return config, nil
}
