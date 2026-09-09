//go:build !windows
// +build !windows

package runner

import (
	"os/exec"
	"syscall"
)

// isolateProcess puts the child in its own process group so that stopping it
// also stops the server process it starts.
func isolateProcess(cmd *exec.Cmd) {
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
}

// terminateProcess signals the whole process group started by isolateProcess.
func terminateProcess(cmd *exec.Cmd) error {
	if cmd.Process == nil {
		return nil
	}
	return syscall.Kill(-cmd.Process.Pid, syscall.SIGTERM)
}
