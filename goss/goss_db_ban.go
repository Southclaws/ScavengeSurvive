package main

// gorm sqlite dialect
import _ "github.com/jinzhu/gorm/dialects/sqlite"

// Ban represents a ban against a player and their IP. Bans can be inactive and
// be duplicates of the same player.
type Ban struct {
	Name     string `gorm:"column:name;primary_key;index;not null;unique"`
	Ipv4     int32  `gorm:"column:ipv4"`
	Date     int32  `gorm:"column:date"`
	Reason   string `gorm:"column:reason"`
	BannedBy string `gorm:"column:by"`
	Duration int32  `gorm:"column:duration"`
	IsActive int32  `gorm:"column:active"`
}

// TableName wraps the internal table name
func (Ban) TableName() string {
	return "Bans"
}
