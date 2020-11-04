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
			assert.Equal(t, tt.want, got)
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
