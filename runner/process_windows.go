//go:build windows
// +build windows

package runner

import "os/exec"

// isolateProcess is a no-op on Windows, where the child is stopped directly.
func isolateProcess(cmd *exec.Cmd) {}

// terminateProcess stops the child process.
func terminateProcess(cmd *exec.Cmd) error {
	if cmd.Process == nil {
		return nil
	}
	return cmd.Process.Kill()
}

// killProcess stops the child process.
func killProcess(cmd *exec.Cmd) error {
	return terminateProcess(cmd)
}
