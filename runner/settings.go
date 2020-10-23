package runner

import (
	"io/ioutil"
	"os"
)

func WriteSettings(data string) {
	if err := ioutil.WriteFile("scriptfiles/data/settings.ini", []byte(data), os.ModePerm); err != nil {
		panic(err)
	}
}
