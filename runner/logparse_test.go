package runner

import (
	"fmt"
	"testing"

	"github.com/kr/pretty"
	"github.com/stretchr/testify/assert"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var p = ReactiveParser{}

func Test_parseSampLoggerFormat(t *testing.T) {
	tests := []struct {
		input string
		msg   string
		want  []zapcore.Field
	}{
		{
			`lvl=info msg="Setting loaded" path="spawn/new-items/1" output="Ammo9mm"`,
			"Setting loaded",
			[]zapcore.Field{
				zap.String("path", "spawn/new-items/1"),
				zap.String("output", "Ammo9mm"),
			},
		},
		{
			`lvl=info msg="Setting loaded" path="this \"thing\" contains quotes"`,
			"Setting loaded",
			[]zapcore.Field{
				zap.String("path", `this "thing" contains quotes`),
			},
		},
		{
			`Registered SIF debug handler 1: 'SIF/Button' initial state: 0`,
			`Registered SIF debug handler 1: 'SIF/Button' initial state: 0`,
			nil,
		},
	}
	for ii, tt := range tests {
		t.Run(fmt.Sprint(ii), func(t *testing.T) {
			_, msg, got := p.parseSampLoggerFormat(tt.input)
			// Fields come out of a map, so their order is not stable.
			assert.ElementsMatch(t, tt.want, got)
			pretty.Println(msg, got) //nolint:errcheck
		})
	}
}

func Test_parseSampLoggerToMap(t *testing.T) {
	tests := []struct {
		input string
		want  map[string]string
	}{
		{
			`lvl=info msg="Setting loaded" path="spawn/new-items/1" output="Ammo9mm"`,
			map[string]string{
				"lvl":    "info",
				"msg":    "Setting loaded",
				"path":   "spawn/new-items/1",
				"output": "Ammo9mm",
			},
		},
		{
			`lvl=info msg="Setting loaded" path="this \"thing\" contains quotes"`,
			map[string]string{
				"lvl":  "info",
				"msg":  "Setting loaded",
				"path": `this "thing" contains quotes`,
			},
		},
		{
			`Registered SIF debug handler 1: 'SIF/Button' initial state: 0`,
			nil,
		},
	}
	for ii, tt := range tests {
		t.Run(fmt.Sprint(ii), func(t *testing.T) {
			got := parseSampLoggerToMap(tt.input)
			assert.Equal(t, tt.want, got)
			pretty.Println(got) //nolint:errcheck
		})
	}
}

func Test_splitLine(t *testing.T) {
	tests := []struct {
		line string
		want []string
	}{
		{
			`lvl=info msg="Setting loaded" path="spawn/new-items/1" output="Ammo9mm"`,
			[]string{
				`lvl=info`,
				`msg="Setting loaded"`,
				`path="spawn/new-items/1"`,
				`output="Ammo9mm"`,
			},
		},
	}
	for ii, tt := range tests {
		t.Run(fmt.Sprint(ii), func(t *testing.T) {
			got := splitLine(tt.line)
			pretty.Println(got) //nolint:errcheck
		})
	}
}

func Test_stripOpenMPPrefix(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{
			`[2026-09-09T06:31:30+0100] [Info] [OnGameModeInit] FIRST_INIT`,
			`[OnGameModeInit] FIRST_INIT`,
		},
		{
			`[2026-09-09T06:31:30+0100] [Error] File or function is not found`,
			`File or function is not found`,
		},
		{
			`[2026-09-09T06:31:30+0100] [Info] [debug] AMX backtrace:`,
			`[debug] AMX backtrace:`,
		},
		{
			`[2026-09-09T06:31:44+0100] [Info] lvl="info" msg="spawned items" type="Bread"`,
			`lvl="info" msg="spawned items" type="Bread"`,
		},
		{
			// Lines the server writes before logging is configured have no
			// prefix and must be left alone.
			`Starting open.mp server (1.5.8.3079)`,
			`Starting open.mp server (1.5.8.3079)`,
		},
		{
			// A gamemode print that merely starts with a bracket is not a
			// prefix and must survive intact.
			`[main] Finished initialising Southclaws' Scavenge and Survive`,
			`[main] Finished initialising Southclaws' Scavenge and Survive`,
		},
	}

	for _, tt := range tests {
		assert.Equal(t, tt.want, stripOpenMPPrefix(tt.input))
	}
}

func Test_ComponentPattern(t *testing.T) {
	match := ComponentPattern.FindStringSubmatch(
		"\tSuccessfully loaded component Objects (1.5.8.3079) with UID 59f8415f72da6160")
	assert.Equal(t, []string{"Successfully loaded component Objects", "Objects"}, match)
}
