# ScavengeSurvive to open.mp: research findings

Date: 2026-09-09
Repository: https://github.com/Southclaws/ScavengeSurvive (branch `master`, HEAD `399ba8e8`)
Local checkout: `/root/scavengesurvive`, work branch `openmp`
Goal: run the gamemode on open.mp natively on this machine, no Docker.

## 1. Upstream repository

Scavenge and Survive is a PvP SA:MP survival gamemode written in Pawn, licensed
MPL 2.0, copyright Barnaby "Southclaws" Keene. Around 242 `.pwn` files live under
`gamemodes/`, all pulled into one translation unit by the entry script.

### Package definition (`pawn.json`)

| Field | Value |
| --- | --- |
| entry | `gamemodes/ScavengeSurvive.pwn` |
| output | `gamemodes/ScavengeSurvive.amx` |
| dependencies | 35 |
| build args | `-;+ -(+ -\+ -d3 -Z+` |
| build includes | `legacy` |
| runtime bind | `0.0.0.0:7777` |
| runtime rcon_password | `scavenge` |
| runtime extra | `long_call_time=0` |

`long_call_time` is a crashdetect plugin setting written into `server.cfg`, not a
SA:MP core setting.

### Dependencies that ship native binaries

These are the only dependencies that are not pure Pawn:

| Dependency | Pinned upstream | Binary |
| --- | --- | --- |
| Southclaws/samp-nolog | 0.2.1 | nolog.so |
| maddinat0r/sscanf | v2.8.3 | sscanf.so |
| samp-incognito/samp-streamer-plugin | v2.9.5 | streamer.so |
| Southclaws/pawn-chrono | 1.1.1 | chrono.so |
| Southclaws/samp-whirlpool | v1.0.0 | Whirlpool.so |
| Zeex/samp-plugin-crashdetect | v4.20 | crashdetect.so |
| Southclaws/pawn-fsutil | 1.3.0 | fsutil.so |

Standard library dependencies are `sampctl/samp-stdlib` and `sampctl/samp-stdutil`.
Everything else (YSI, item, inventory, container, craft, door, button, modio,
strlib, sqlitei, md-sort, progress2, formatex, samp-ini, weapon-data, linegen,
zipline, ladders, personal-space, pawn-errors, samp-logger) is Pawn source only.

### Entry script observations

`gamemodes/ScavengeSurvive.pwn`:

- includes `<a_samp>` first, then `<crashdetect>`, `<sscanf2>`, `<streamer>`,
  `<chrono>`, `<fsutil>`, `<sqlitei>` and a long list of YSI includes
- redefines `MAX_PLAYERS` to 50 before including anything
- calls `SetCrashDetectLongCallTime(5000)` and `EnableCrashDetectLongCall()` at
  the end of `main()`
- polls `localhost:7788/update` with the `HTTP` native once per second from the
  `RestartUpdate` task, which is the Go runner's update endpoint
- restarts the gamemode with `SendRconCommand("gmx")`
- prints two marker strings the runner greps for and which must not change:
  `[OnGameModeInit] FIRST_INIT` and `[OnScriptExit] LAST_EXIT`
- opens two SQLite databases through sqlitei under `scriptfiles/data/`
- reads settings from `scriptfiles/data/settings.ini` via `LoadSettings`

Other SA:MP specific usage found by search: `gpci` (player identifier hashing) in
six files, `SetSVarInt` in `gamemodes/sss/utils/logging.pwn`. Both exist on open.mp.

`gamemodes/testing.pwn` and roughly 30 filterscripts also include `<a_samp>`, but
sampctl only compiles the single entry script, so filterscripts do not affect the
build.

`legacy/` holds five local includes that are not published as packages:
`debug-labels.inc`, `item-list.inc`, `item-serializer.inc`, `keys-inventory.inc`,
`multi-button.inc`.

### Docker and tooling being replaced

- `Dockerfile`: two stages, a Go build of the runner and a runtime stage based on
  the `southclaws/sampctl` image with `uuid-dev:i386` installed.
- `docker-compose.yml`: mounts the whole repository into `/server`, exposes
  7777/udp, and passes a large `SETTINGS_OVERRIDE` block. That block is the only
  place the server's default settings values are recorded, so it must be
  preserved somewhere when Docker goes away.
- `Taskfile.yml`: default task builds and runs the Go runner.
- CI `.github/workflows/build.yml`: `AGraber/sampctl-action@v1` with sampctl
  1.9.1, then `sampctl p build --forceEnsure`.
- CI `.github/workflows/runner.yml`: cross builds the runner for Windows and Linux.

### Go runner (`main.go` and `runner/`)

The runner supervises the server process and stays alive across restarts.

| File | Role | open.mp impact |
| --- | --- | --- |
| runner/runner.go | Spawns the server binary, restarts on exit | Hardcodes `./samp03svr` and `./samp-server.exe`; deletes `server_log.txt` |
| runner/main.go | Ensure, build, config generation via the old sampctl Go module (`rook.NewPackageContext`, `RunPrepare`) | That module predates open.mp support |
| runner/watcher.go | fsnotify on `gamemodes/*.pwn`, rebuilds through `pcx.Build` | Same module problem |
| runner/logparse.go | Parses server output, detects init errors and plugin loads | Patterns match SA:MP log formatting |
| runner/api.go | HTTP endpoint on :7788 telling the gamemode an update is ready | Unchanged |
| runner/discord.go | Optional Discord bridge | Unchanged |
| runner/config.go | envconfig settings | Unchanged |

Log patterns currently matched: `Run time error`, `[debug] AMX backtrace:`,
`[error] UNHANDLED ERRORS:`, and the regex `Loading plugin:\s(\w+)`.

### .gitignore

Already ignores `plugins/`, `dependencies/`, `*.so`, `server.cfg`, `samp03svr`,
`logs/`, `server_log.txt`, `scriptfiles/data/`. It does not yet cover the open.mp
artefacts: `config.json`, `components/`, `omp-server`, `log.txt`, `bans.json`.

## 2. Host environment

| Item | Value |
| --- | --- |
| OS | Debian GNU/Linux forky/sid |
| Architecture | x86_64 |
| Go | 1.27.1 |
| Present | git, gh (authenticated), node, npm, curl, wget, unzip, tar |
| Absent before this work | sampctl, pawncc, task, i386 multiarch |

open.mp publishes no 64-bit Linux server, so the server process and every legacy
plugin are 32-bit ELF binaries. Running them on this host required enabling i386
multiarch and installing `libc6:i386`, `libstdc++6:i386` and `libgcc-s1:i386`.
That is what the Docker image was doing behind the scenes with `uuid-dev:i386`.

## 3. open.mp and toolchain versions

| Component | Version | Linux asset |
| --- | --- | --- |
| open.mp server | v1.5.8.3079 | open.mp-linux-x86.tar.gz, open.mp-linux-x86-dynssl.tar.gz |
| Pawn compiler | v3.10.10 | pawnc-3.10.10-linux.tar.gz |
| sampctl | 1.14.1 | sampctl_1.14.1_linux_amd64.tar.gz |
| sscanf | v2.13.8 | sscanf-2.13.8-linux.tar.gz |
| streamer | v2.9.6 | samp-streamer-plugin-2.9.6.zip |
| pawn-chrono | 1.1.2 | chrono.so |
| pawn-fsutil | 1.3.0 | fsutil.so |
| samp-whirlpool | v1.0.0 | Whirlpool.so |
| YSI-Includes | v5.10.0006 | source only |

sampctl 1.14.1 is the first line of sampctl with first class open.mp support. The
relevant behaviour, read from its source and docs:

- `preset: "openmp"` in `pawn.json` switches compiler and runtime defaults.
- Runtime type comes from `runtime.runtime_type`, or is auto detected when
  `runtime.version` contains `openmp` or `open.mp`
  (`src/pkg/runtime/config/runtime.go`, `DetectRuntimeType`).
- open.mp runtimes generate `config.json` rather than `server.cfg`
  (`src/pkg/runtime/config_openmp.go`), with `hostname` mapped to `name`,
  `maxplayers` to `max_players`, and `runtime.extra` merged in at top level.
- `runtime.plugins` becomes `pawn.legacy_plugins` and `runtime.components`
  becomes `pawn.components` in `config.json`.
- The server binary is renamed on extraction: `omp-server` replaces `samp03svr`
  (`src/pkg/runtime/download.go`, `normalizeRuntimePaths`).
- Dependency URL schemes: `plugin://user/repo` lands in `plugins/`,
  `component://user/repo` lands in `components/`.
- The migration guide tells projects to depend on `openmultiplayer/omp-stdlib`,
  `pawn-lang/samp-stdlib@open.mp` and `pawn-lang/pawn-stdlib@open.mp`, and to drop
  plain `samp-stdlib`, because community packages often pull the SA:MP stdlib
  transitively and would otherwise win.

`openmultiplayer/omp-stdlib` provides `open.mp.inc` as the real entry point plus
compatibility wrappers. Its `a_samp.inc` emits a warning and forwards to
`<open.mp>`, so unported scripts still compile.

## 4. Porting decisions

**Drop crashdetect.** open.mp reports Pawn runtime errors and backtraces itself.
The plugin's two API calls in `main()` (`SetCrashDetectLongCallTime`,
`EnableCrashDetectLongCall`) and the `long_call_time` runtime extra go with it.

**Drop samp-nolog.** It exists solely to hook `logprintf` and stop SA:MP writing
to `server_log.txt`, closing an RCON log bleed vulnerability. open.mp does not
have that logging path, so the plugin has no purpose.

**Move sscanf to the maintained fork.** `maddinat0r/sscanf` v2.8.3 predates the
open.mp SDK. `Y-Less/sscanf` v2.13.8 carries the open.mp SDK update (changelog
entry 2.13.4, "Update open.mp SDK") and keeps the same `sscanf2.inc` include name.

**Bump streamer to v2.9.6.** That release merges open.mp compatibility work by
AmyrAhmady.

**Keep the remaining legacy plugins.** fsutil, chrono and Whirlpool are loaded
through `pawn.legacy_plugins`, which open.mp supports for 32-bit SA:MP plugins.

**Pin YSI.** The upstream dependency is unpinned, so `sampctl ensure` would drift.
Pin to a tag once the build is green.

## 5. Risks identified up front

- Compile errors against omp-stdlib and a newer YSI are the main unknown. The
  build uses `-Z+` compatibility mode, which softens some of this.
- Installing i386 packages changes host state. It is unavoidable without a
  container, which the user ruled out.
- No SA:MP or open.mp game client is available here, so nothing beyond a clean
  server boot and runner integration can be verified.

## 6. Plugins versus components

open.mp has two kinds of native extension. Components are the open.mp native
format, live in `components/` and are listed under `pawn.components` in
`config.json`. Legacy plugins are SA-MP plugins, live in `plugins/` and are
listed under `pawn.legacy_plugins`. open.mp loads every component before any
legacy plugin.

Each of this project's binary dependencies was researched against the open.mp
documentation, the open.mp GitHub organisation and each plugin's own repository.

| Plugin | Component available | Decision |
| --- | --- | --- |
| sscanf | Yes, in the v2.13.8 release | Moved to `components/` |
| streamer | No official one | Stays a legacy plugin at v2.9.6 |
| crashdetect | No | Stays a legacy plugin, AmyrAhmady fork v4.22 |
| Whirlpool | No | Stays a legacy plugin |
| fsutil | No | Stays a legacy plugin |
| chrono | No | Stays a legacy plugin |
| pawn-memory | No | Stays a legacy plugin, pinned to 2.0.1 |
| pawn-uuid | No | Stays a legacy plugin |

Details worth keeping:

- **sscanf** ships one binary that exports both a component entry point and the
  legacy plugin entry points, and the release archive carries it under both
  directory names. The open.mp installation guide asks for it in `components/`.
  Loading a script compiled against the component include from `plugins/`
  produces sscanf error 42.
- **streamer** v2.9.6 is the open.mp compatibility release, merged by an open.mp
  maintainer. A community component fork exists but its package definition was
  never updated, so sampctl cannot resolve its release asset, and it has no
  meaningful adoption. Not used.
- **crashdetect** from AmyrAhmady is the fork open.mp's own documentation links
  to. Version 4.20, which this project pinned, is the one with a known open.mp
  crash. It also needs `-d3` in the build args, which this project already sets.
- **Whirlpool** has no open.mp equivalent. open.mp's standard library declares
  only `SHA256_PassHash` and an alias, both deprecated for password use, and no
  Whirlpool, MD5 or SHA-512 native. The plugin's own readme tells readers to
  move to bcrypt. Migrating hashes is out of scope for this port.
- **fsutil** is only partly replaceable. open.mp's Pawn component registers the
  AMX file module, so `fexist`, `fremove`, `frename`, `fcopy`, `fcreatedir` and
  directory globbing are all native now, but the path string helpers have no
  equivalent and native file access is confined to `scriptfiles`.
- **chrono** is likewise partly replaceable. `gettime`, `getdate` and
  `cvttimestamp` are native, but chrono's tagged duration types and its date
  formatting and parsing are not.
- **pawn-memory** and **pawn-uuid** have no open.mp equivalent at all.

sampctl expresses the distinction with dependency URL schemes: `component://`
installs to `components/`, `plugin://` installs to `plugins/`, `includes://`
contributes only an include path, and a bare `user/repo` is a source dependency
that also gets auto classified as a legacy plugin when it declares plugin
resources.
