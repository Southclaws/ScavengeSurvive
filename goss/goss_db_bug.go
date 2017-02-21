package main

// gorm sqlite dialect
import _ "github.com/jinzhu/gorm/dialects/sqlite"

// Bug represents a bug report.
type Bug struct {
	Name   string `gorm:"column:name;primary_key;index;not null;unique"`
	Reason string `gorm:"column:reason"`
	Date   int32  `gorm:"column:date"`
}

// TableName wraps the internal table name
func (Bug) TableName() string {
	return "Bugs"
}
