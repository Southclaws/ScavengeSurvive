package runner

import (
	"context"
	"os"
	"os/exec"

	"github.com/pkg/errors"
	"go.uber.org/zap"
)

// SampctlBinary is the sampctl executable the runner shells out to. sampctl
// owns dependency resolution, the compiler, the open.mp server binary and the
// generation of config.json, so the runner drives it rather than duplicating
// any of that work.
const SampctlBinary = "sampctl"

// EnsureDependencies downloads Pawn dependencies, plugins and the server
// package described by pawn.json.
func EnsureDependencies(ctx context.Context) error {
	zap.L().Info("ensuring dependencies, this may take a while")
	return errors.Wrap(runSampctl(ctx, "ensure"), "failed to ensure dependencies")
}

// BuildGamemode compiles the package entry script into its .amx output.
func BuildGamemode(ctx context.Context) error {
	zap.L().Info("building gamemode")
	return errors.Wrap(runSampctl(ctx, "build"), "failed to build gamemode")
}

func runSampctl(ctx context.Context, args ...string) error {
	cmd := exec.CommandContext(ctx, SampctlBinary, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
