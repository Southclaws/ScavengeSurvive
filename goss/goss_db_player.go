package ssdb

// gorm sqlite dialect
import _ "github.com/jinzhu/gorm/dialects/sqlite"

// PlayerAccount represents a player's account details (not character) such as
// password, register date and other information that won't change much.
type PlayerAccount struct {
	Name             string `gorm:"column:name;primary_key;index;not null;unique"`
	Password         string `gorm:"column:pass"`
	IPAddress        int32  `gorm:"column:ipv4"`
	IsAlive          int32  `gorm:"column:alive"` // to be removed
	RegistrationDate int32  `gorm:"column:regdate"`
	LastLogin        int32  `gorm:"column:lastlog"`   // to be removed
	LastSpawn        int32  `gorm:"column:spawntime"` // to be removed
	TotalSpawns      int32  `gorm:"column:spawns"`    // to be removed
	TotalWarnings    int32  `gorm:"column:warnings"`  // to be removed
	GPCI             string `gorm:"column:gpci"`
	IsActive         int32  `gorm:"column:active"`
}

// TableName updates the PlayerAccount SQL table name
func (PlayerAccount) TableName() string {
	return "Player"
}
