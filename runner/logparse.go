package runner

import (
	"bufio"
	"io"
	"regexp"
	"strconv"
	"strings"

	"github.com/cskr/pubsub"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

const (
	sampLoggerMessageKey = `msg`
	sampLoggerLevelKey   = `lvl`
	EntryPattern         = `[OnGameModeInit] FIRST_INIT`
	ExitPattern          = `[OnScriptExit] LAST_EXIT`
	ErrorPattern         = `Run time error`

	ChunkDebugStart = `[debug] AMX backtrace:`
	ChunkErrorStart = `[error] UNHANDLED ERRORS:`
)

var PluginPattern = regexp.MustCompile(`Loading plugin:\s(\w+)`)

type LogParser interface {
	GetWriter() io.Writer
}

type ReactiveParser struct {
	ps *pubsub.PubSub
}

func (p *ReactiveParser) GetWriter() io.Writer {
	// Pipe output to a scanner, this allows the program to read logs and
	// re-format them in a nicer format.
	outputReader, outputWriter := io.Pipe()

	// start in background and repeat on failure with panic recover
	go func() {
		for {
			p.parseWithRecover(outputReader)
		}
	}()

	return outputWriter
}

func (p *ReactiveParser) parseWithRecover(r io.Reader) {
	defer func() {
		err := recover()
		zap.L().Error("log parser encountered an error", zap.Any("error", err))
	}()

	init := true
	plugins := []string{}
	scanner := bufio.NewScanner(r)
	preamble := []string{}

	debug := false
	debugTrace := []string{}

	for scanner.Scan() {
		line := scanner.Text()

		if init {
			if strings.Contains(line, ErrorPattern) {
				zap.L().Warn("an error occurred during initialisation, below is the output from initialisation that is usually hidden during normal startups")
				p.ps.Pub(strings.Join(preamble, "\n"), "errors.init")
				for _, l := range preamble {
					zap.L().Info(l)
				}
				preamble = preamble[:0]
				p.ps.Pub(true, "restart")
				init = true
				continue
			}

			// Entry pattern tells the scanner that the process has handed
			// control to the gamemode and preamble is finished. Log out the
			// relevant info such as plugins loaded.
			if strings.Contains(line, EntryPattern) {
				init = false
				zap.L().Info("finished initialising", zap.Strings("plugins", plugins))
				continue
			}

			// look for plugin initialisation logs and store them for printing
			match := PluginPattern.FindStringSubmatch(line)
			if len(match) == 2 {
				plugins = append(plugins, match[1])
			}

			// save the preamble for later, if the server crashes during
			// startup then this needs to be printed for debugging.
			preamble = append(preamble, line)

			// skip logging these lines immediately because they're mostly
			// useless for non-broken startup.
			continue
		}

		// Exit pattern triggers a full process restart.
		if strings.Contains(line, ExitPattern) {
			p.ps.Pub(true, "restart")
			init = true
			continue
		}

		if !debug {
			if strings.HasPrefix(line, ChunkDebugStart) || strings.HasPrefix(line, ChunkErrorStart) {
				debug = true
			}
		} else {
			// if the log entry is not a debug entry OR the start of a new debug
			// chunk, send the error to the errors topic.
			if !strings.HasPrefix(line, "[debug]") && !strings.HasPrefix(line, "[error]") {
				p.ps.Pub(strings.Join(debugTrace, "\n"), "errors.backtrace")
				debugTrace = debugTrace[:0]
				debug = false
			} else if strings.HasPrefix(line, ChunkDebugStart) || strings.HasPrefix(line, ChunkErrorStart) {
				p.ps.Pub(strings.Join(debugTrace, "\n"), "errors.backtrace")
				debugTrace = []string{line}
				debug = true
			}
			debugTrace = append(debugTrace, line)
		}

		// otherwise, parse log entries for the samp-logger format and write
		// them out.
		f, message, fields := p.parseSampLoggerFormat(line)
		f(message, fields...)
	}
}

func (r *ReactiveParser) parseSampLoggerFormat(line string) (func(msg string, fields ...zapcore.Field), string, []zapcore.Field) {
	rawFields := parseSampLoggerToMap(line)
	if len(rawFields) > 0 {
		fields := []zapcore.Field{}
		for key, value := range rawFields {
			if len(value) == 0 {
				return zap.L().Info, line, nil
			}
			if key == sampLoggerMessageKey || key == sampLoggerLevelKey {
				continue
			}
			fields = append(fields, transformType(key, value))
		}
		if lvl, ok := rawFields[sampLoggerLevelKey]; ok {
			if lvl == "error" {
				r.ps.Pub(rawFields, "errors.single")
				return zap.L().Error, rawFields[sampLoggerMessageKey], fields
			} else if lvl == "debug" {
				return zap.L().Debug, rawFields[sampLoggerMessageKey], fields
			}
		}
		return zap.L().Info, rawFields[sampLoggerMessageKey], fields
	}
	return zap.L().Info, line, nil
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
