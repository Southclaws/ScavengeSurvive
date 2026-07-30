package runner

import (
	"bytes"
	"context"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/cskr/pubsub"
)

func TestServerBinary(t *testing.T) {
	tests := map[string]string{
		"linux":   "./samp03svr",
		"windows": "./samp-server.exe",
	}
	for goos, want := range tests {
		got, err := serverBinary(goos)
		if err != nil {
			t.Fatalf("serverBinary(%q): %v", goos, err)
		}
		if got != want {
			t.Fatalf("serverBinary(%q) = %q, want %q", goos, got, want)
		}
	}

	if _, err := serverBinary("plan9"); err == nil {
		t.Fatal("serverBinary accepted an unsupported platform")
	}
}

func TestRunBlockingCommandStartsServer(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("shell fixture is Unix-only")
	}

	binary := filepath.Join(t.TempDir(), "server")
	if err := os.WriteFile(binary, []byte("#!/bin/sh\nprintf 'server ready\\n'\n"), 0o755); err != nil {
		t.Fatal(err)
	}

	var output bytes.Buffer
	if err := runBlockingCommand(context.Background(), pubsub.New(1), nil, &output, binary); err != nil {
		t.Fatal(err)
	}
	if got := output.String(); got != "server ready\n" {
		t.Fatalf("output = %q", got)
	}
}
