package runner

import (
	"io/ioutil"
	"os"
	"os/exec"
	"strings"

	"github.com/pkg/errors"
	"go.uber.org/zap"
)

func Ensure() error {
	if err := cmd("git", "init"); err != nil {
		return errors.Wrap(err, "failed to git init")
	}

	if err := cmd("git", "remote", "add", "origin", "https://github.com/Southclaws/ScavengeSurvive.git"); err != nil {
		return errors.Wrap(err, "failed to add origin")
	}

	zap.L().Info("this may take a while...")
	if err := cmd("git", "pull", "origin", "master"); err != nil {
		return errors.Wrap(err, "failed to git init")
	}

	zap.L().Info("done cloning repository")

	return nil
}

func cmd(name string, arg ...string) error {
	c := exec.Command(name, arg...)
	c.Stdout = os.Stdout
	return c.Run()
}

func isDirEmpty(dir string) bool {
	d, err := ioutil.ReadDir(dir)
	if err != nil {
		panic(err)
	}

	if len(d) == 1 {
		if strings.HasPrefix(d[0].Name(), "ScavengeSurvive") {
			return true
		}
	}
	return len(d) == 0
}
