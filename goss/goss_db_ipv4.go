package main

// gorm sqlite dialect
import _ "github.com/jinzhu/gorm/dialects/sqlite"

// Ipv4 represents a log entry for a player's Ipv4
type Ipv4 struct {
	Name string `gorm:"column:name;primary_key;index;not null;unique"`
	Ipv4 string `gorm:"column:ipv4"`
	Date int32  `gorm:"column:date"`
}

// TableName wraps the internal table name
func (Ipv4) TableName() string {
	return "Ipv4_log"
}
