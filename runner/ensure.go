package runner

import (
	"fmt"
	"io/ioutil"
	"os/exec"
)

func Ensure() error {
	if err := exec.Command("git", "clone", "https://github.com/Southclaws/ScavengeSurvive", ".").Run(); err != nil {
		return err
	}

	return nil
}

func isDirEmpty(dir string) bool {
	d, err := ioutil.ReadDir(dir)
	if err != nil {
		panic(err)
	}
	fmt.Println(d)
	return len(d) == 0
}
