package main

// gorm sqlite dialect
import _ "github.com/jinzhu/gorm/dialects/sqlite"

// Whitelist represents a whitelisted player name.
type Whitelist struct {
	Name string `gorm:"column:name;primary_key;index;not null;unique"`
}

// TableName wraps the internal table name
func (Whitelist) TableName() string {
	return "Whitelist"
}
