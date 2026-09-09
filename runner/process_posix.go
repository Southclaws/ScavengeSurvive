//go:build !windows
// +build !windows

package runner

import (
	"os/exec"
	"syscall"
)

// isolateProcess puts the child in its own process group so that stopping it
// also stops the server process it starts, and so that a terminal interrupt
// reaches the runner rather than the server directly.
func isolateProcess(cmd *exec.Cmd) {
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
}

// terminateProcess asks the whole process group started by isolateProcess to
// stop.
func terminateProcess(cmd *exec.Cmd) error {
	return signalProcessGroup(cmd, syscall.SIGTERM)
}

// killProcess stops the process group without giving it a chance to clean up.
func killProcess(cmd *exec.Cmd) error {
	return signalProcessGroup(cmd, syscall.SIGKILL)
}

func signalProcessGroup(cmd *exec.Cmd, signal syscall.Signal) error {
	if cmd.Process == nil {
		return nil
	}
	return syscall.Kill(-cmd.Process.Pid, signal)
}
