package runner

import (
	"bufio"
	"fmt"
	"io"
	"regexp"
	"strconv"
	"strings"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

const EntryPattern = `[OnGameModeInit] FIRST_INIT`
const ExitPattern = `[OnScriptExit] LAST_EXIT`

var PluginPattern = regexp.MustCompile(`Loading plugin:\s(\w+)`)

func LogParser(restartKiller chan struct{}) io.Writer {
	// Pipe output to a scanner, this allows the program to read logs and
	// re-format them in a nicer format.
	outputReader, outputWriter := io.Pipe()

	// start in background and repeat on failure with panic recover
	go func() {
		for {
			parseWithRecover(outputReader, restartKiller)
		}
	}()

	return outputWriter
}

func parseWithRecover(r io.Reader, restartKiller chan struct{}) {
	defer func() {
		err := recover()
		zap.L().Error("log parser encountered an error", zap.Any("error", err))
	}()

	init := true
	plugins := []string{}
	scanner := bufio.NewScanner(r)
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

			fmt.Println(line)

			// skip unimportant log lines
			continue
		}

		// otherwise, parse log entries for the samp-logger format and write
		// them out.
		message, fields := parseSampLoggerFormat(line)
		zap.L().Info(message, fields...)
	}
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
		if len(value) == 0 {
			return nil
		}
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
