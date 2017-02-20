package main

// gorm sqlite dialect
import _ "github.com/jinzhu/gorm/dialects/sqlite"

// Report represents a player report, either by another player or the system.
type Report struct {
	Name     string  `gorm:"column:name;primary_key;index;not null;unique"`
	Reason   string  `gorm:"column:reason"`
	Date     int32   `gorm:"column:date"`
	Read     int32   `gorm:"column:read"`
	Type     string  `gorm:"column:type"`
	Posx     float32 `gorm:"column:posx"`
	Posy     float32 `gorm:"column:posy"`
	Posz     float32 `gorm:"column:posz"`
	World    int32   `gorm:"column:world"`
	Interior int32   `gorm:"column:interior"`
	Info     string  `gorm:"column:info"`
	By       string  `gorm:"column:by"`
	Active   int32   `gorm:"column:active"`
}

// TableName wraps the internal table name
func (Report) TableName() string {
	return "Reports"
}
