package runner

import (
	"bufio"
	"context"
	"io"
	"os"
	"os/exec"
	"regexp"
	"runtime"
	"strconv"
	"strings"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

const EntryPattern = `[OnGameModeInit] FIRST_INIT`
const ExitPattern = `[OnScriptExit] LAST_EXIT`

var PluginPattern = regexp.MustCompile(`Loading plugin:\s(\w+)`)

func RunServer(ctx context.Context, r io.Reader, w io.Writer) {
	zap.L().Info("starting blocking process")

	// a signaller that uses logs to understand when the gamemode is restarting
	// with gmx that means this program can kill the process and restart it.
	restartKiller := make(chan struct{})

	// Pipe output to a scanner, this allows the program to read logs and
	// re-format them in a nicer format.
	outputReader, outputWriter := io.Pipe()
	go func() {
		init := true
		plugins := []string{}
		scanner := bufio.NewScanner(outputReader)
		for scanner.Scan() {
			line := scanner.Text()

			// Exit pattern triggers a full process restart.
			if strings.Contains(line, ExitPattern) {
				restartKiller <- struct{}{}
				init = true
				continue
			}

			// Entry pattern tells the scanner that the process has handed
			// control to the gamemode and preamble is finished. Log out the
			// relevant info such as plugins loaded.
			if strings.Contains(line, EntryPattern) {
				init = false
				zap.L().Info("finished initialising", zap.Strings("plugins", plugins))
			} else if init {
				match := PluginPattern.FindStringSubmatch(line)
				if len(match) == 2 {
					plugins = append(plugins, match[1])
				}

				// skip unimportant log lines
				continue
			}

			// otherwise, parse log entries for the samp-logger format and write
			// them out.
			message, fields := parseSampLoggerFormat(line)
			zap.L().Info(message, fields...)
		}
	}()

	for {
		err := runBlocking(ctx, restartKiller, r, outputWriter)
		if err != nil {
			if err == context.Canceled {
				break
			}
			zap.L().Info("process exited with error, restarting", zap.Error(err))
		} else {
			zap.L().Info("process exited cleanly, restarting")
		}

		cleanup()
	}
}

func runBlocking(parentctx context.Context, restartKiller chan struct{}, in io.Reader, out io.Writer) (err error) {
	ctx, cancel := context.WithCancel(parentctx)
	defer cancel()

	var binary string
	switch runtime.GOOS {
	case "windows":
		binary = "./samp-server.exe"
	case "linux":
		binary = "./samp03svr"
	default:
		panic("unknown OS")
	}

	cmd := exec.CommandContext(ctx, binary)
	cmd.Stdin = in
	r := cmdReader(cmd)
	if err := cmd.Start(); err != nil {
		return err
	}

	go func() {
		// TODO: Handle IO copy errors.
		// nolint:errcheck
		io.Copy(out, r)
	}()

	go func() {
		<-restartKiller
		time.Sleep(time.Millisecond)
		zap.L().Info("internally triggered process restart")
		cancel()
	}()

	return cmd.Wait()
}

func cmdReader(cmd *exec.Cmd) io.Reader {
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return nil
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		return nil
	}
	return io.MultiReader(stdout, stderr)
}

func cleanup() {
	os.Remove("server_log.txt") //nolint:errcheck
}

func parseSampLoggerFormat(line string) (string, []zapcore.Field) {
	rawFields := parseSampLoggerToMap(line)
	if len(rawFields) > 0 {
		fields := []zapcore.Field{}
		for key, value := range rawFields {
			if len(value) == 0 {
				return line, nil
			}
			if key == "text" {
				continue
			}
			fields = append(fields, transformType(key, value))
		}
		return rawFields["text"], fields
	}
	return line, nil
}

func parseSampLoggerToMap(line string) map[string]string {
	fields := make(map[string]string)

	for _, field := range splitLine(line) {
		split := strings.SplitN(field, "=", 2)
		if len(split) != 2 {
			return nil
		}
		value := strings.ReplaceAll(split[1], `\`, "")
		if value[0] == '"' {
			fields[split[0]] = strings.Trim(value, `"`)
		} else {
			fields[split[0]] = value
		}
	}

	return fields
}

func splitLine(line string) []string {
	result := []string{}
	instring := false
	escape := false
	begin := 0
	for idx, char := range line {
		if !instring {
			if char == '"' {
				instring = true
				continue
			}

			if char == ' ' {
				if begin < idx {
					result = append(result, line[begin:idx])
					begin = idx + 1
				}
				continue
			}
		}
		if instring {
			if char == '\\' {
				escape = true
				continue
			}
			if escape {
				escape = false
				continue
			}
			if char == '"' {
				instring = false
			}
		}
	}
	result = append(result, line[begin:])
	return result
}

func transformType(key, value string) zapcore.Field {
	if value[0] >= '0' && value[0] <= '9' {
		for _, c := range value {
			if c == '.' {
				if v, err := strconv.ParseFloat(value, 32); err == nil {
					return zap.Float64(key, v)
				} else {
					break
				}
			}
		}
		if v, err := strconv.ParseInt(value, 10, 32); err == nil {
			return zap.Int64(key, v)
		}
	}

	return zap.String(key, value)
}
