package main

// gorm sqlite dialect
import _ "github.com/jinzhu/gorm/dialects/sqlite"

// Admin represents a binding between a player and an admin level
type Admin struct {
	Name  string `gorm:"column:name;primary_key;index;not null;unique"`
	Level int32  `gorm:"column:level"`
}

// TableName wraps the internal table name
func (Admin) TableName() string {
	return "Admins"
}
