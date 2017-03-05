package main

import (
	"github.com/jinzhu/gorm"
)

// GetAccountHistory returns a list of accounts associated with a given name
// based on IP, password hash and GPCI history.
func GetAccountHistory(db *gorm.DB, name string, max int) ([]string, error) {
	var result []string
	var hash string
	var record GPCI

	db.Select("hash").Where(&GPCI{Name: name}).First(hash)
	rows, err := db.Where(&GPCI{Hash: hash}).Rows()

	if err != nil {
		return result, err
	}

	for rows.Next() {
		rows.Scan(record)
		result = append(result, record.Name)
	}

	return result, nil
}
