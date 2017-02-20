package main

import (
	"encoding/json"
	"log"
	"os"
	"path/filepath"

	redis "gopkg.in/redis.v5"
)

// Config stores app global configuration
type Config struct {
	WorkingDir   string `json:"omitempty"`
	Database     string
	RedisHost    string
	DiscordToken string
	DiscordBinds []Bind
}

func main() {

	// Config

	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		log.Fatal(err)
	}

	cfg := Config{
		WorkingDir: dir,
		Database:   "ss.db",
	}

	err = loadConfig("config.json", &cfg)
	if err != nil {
		log.Print("config load error")
		log.Fatal(err)
	}

	log.Printf("Loaded config:")
	log.Printf("- WorkingDir: '%s'", cfg.WorkingDir)
	log.Printf("- Database: '%s'", cfg.Database)
	log.Printf("- RedisHost: '%s'", cfg.RedisHost)
	log.Printf("- DiscordToken: (%d chars)", len(cfg.DiscordToken))
	log.Printf("- channel binds:")
	for i := range cfg.DiscordBinds {
		log.Printf("  - %s <> %s:%s", cfg.DiscordBinds[i].DiscordChannel, cfg.DiscordBinds[i].InputQueue, cfg.DiscordBinds[i].OutputQueue)
	}
	log.Printf("~")

	// Database

	db, err := ssdb.ConnectDatabase(filepath.Join(cfg.WorkingDir, cfg.Database), true)
	if err != nil {
		panic(err)
	}

	if err := db.DB().Ping(); err != nil {
		panic(err)
	}

	var count int
	db.Model(&ssdb.PlayerAccount{}).Where(&ssdb.PlayerAccount{IsActive: 1}).Count(&count)

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

	done := make(chan bool)
	<-done
}

func loadConfig(filename string, cfg *Config) error {
	file, err := os.Open(filename)
	if err != nil {
		return err
	}

	json.NewDecoder(file).Decode(&cfg)

	err = file.Close()
	if err != nil {
		return err
	}

	return nil
}
