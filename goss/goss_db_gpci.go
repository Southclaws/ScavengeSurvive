package main

// gorm sqlite dialect
import _ "github.com/jinzhu/gorm/dialects/sqlite"

// GPCI represents a log entry for a player's GPCI hash
type GPCI struct {
	Name string `gorm:"column:name;primary_key;index;not null;unique"`
	Hash string `gorm:"column:hash"`
	Date int32  `gorm:"column:date"`
}

// TableName wraps the internal table name
func (GPCI) TableName() string {
	return "gpci_log"
}
