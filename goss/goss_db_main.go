package main

import (
	"github.com/jinzhu/gorm"
	// gorm sqlite dialect
	_ "github.com/jinzhu/gorm/dialects/sqlite"
)

// ConnectDatabase sets up database connections
func ConnectDatabase(location string, logmode bool) (*gorm.DB, error) {
	db, err := gorm.Open("sqlite3", location)
	if err != nil {
		return nil, err
	}

	db.LogMode(logmode)
	db.AutoMigrate(&PlayerAccount{})

	return db, nil
}
