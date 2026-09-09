# Porting log

What changed, in order, and what went wrong on the way. Repository
`/root/scavengesurvive`, branch `openmp` off `master` at `399ba8e8`.

## Commit 1: switch the package definition to open.mp

`pawn.json` gained `"preset": "openmp"` and `"runtime_type": "openmp"`, which is
what makes sampctl generate `config.json` and fetch `omp-server` rather than
`server.cfg` and `samp03svr`.

The three stdlib dependencies go first in the list, in this order:
`openmultiplayer/omp-stdlib`, `pawn-lang/samp-stdlib@open.mp`,
`pawn-lang/pawn-stdlib@open.mp`. The two `@open.mp` branches are deliberately
empty. They exist so that any dependency asking for the SA-MP standard library
transitively resolves to nothing and the open.mp includes win. Confirmed
locally: both directories contain only a readme and a pawndoc stylesheet.

`.gitignore` gained `config.json`, `components/`, `omp-server`, `log.txt` and
`bans.json`.

## Commit 2: build against the open.mp standard library

This is where the real work was. Errors, in the order they surfaced.

### sqlitei could not find PrintAmxBacktrace (41 errors)

Dropping crashdetect broke sqlitei, which calls `PrintAmxBacktrace` whenever any
of its `DB_DEBUG_BACKTRACE_*` options are on, and the gamemode turns all three
on. The initial decision to drop the plugin was wrong: crashdetect is a hard
dependency here, not an optional debugging aid.

Resolution: depend on `AmyrAhmady/samp-plugin-crashdetect:v4.22`, the open.mp
compatible fork, and restore both the include and the two long call API calls in
`main()`. That fork provides the whole legacy API including `PrintAmxBacktrace`.

### Seven gamemode functions collided with new open.mp natives

open.mp's includes declare natives that did not exist in SA-MP. Rather than
check them one at a time, the full list was extracted by comparing every
`native` in omp-stdlib against every `stock` and `forward` in `gamemodes/`:

| Gamemode function | open.mp native | Renamed to |
| --- | --- | --- |
| IsPlayerSpawned | `bool:IsPlayerSpawned(playerid)` | GetPlayerSpawnedState |
| IsPlayerCuffed | `bool:IsPlayerCuffed(playerid)` | IsPlayerHandcuffed |
| GetPlayerSpectateType | `GetPlayerSpectateType(playerid)` | GetPlayerSpectateMode |
| GetVehicleColours | `bool:GetVehicleColours(vehicleid, &c1, &c2)` | GetVehicleColourData |
| IsVehicleDead | `bool:IsVehicleDead(vehicleid)` | IsVehicleStateDead |
| IsVehicleOccupied | `bool:IsVehicleOccupied(vehicleid)` | IsVehicleOccupiedState |
| RemovePlayerWeapon | `bool:RemovePlayerWeapon(playerid, WEAPON:weaponid)` | RemovePlayerWeapons |

Every one of these is backed by the gamemode's own state, not the server's.
`IsVehicleDead` means `veh_state == VEHICLE_STATE_DEAD`, `IsPlayerSpawned` means
the gamemode's own spawn flow finished, `RemovePlayerWeapon` resets every weapon
and hides a textdraw. So they were renamed rather than deleted in favour of the
natives. All call sites are inside `gamemodes/`, none in dependencies or
filterscripts, so the rename was contained.

### weapon-data declares its own GetWeaponSlot

`Southclaws/samp-weapon-data` has no tags and one branch, so it cannot be
upgraded past the collision with open.mp's `GetWeaponSlot` native. Nothing calls
it, in the gamemode or in the library itself, so the library's copy is renamed
with a macro around its include and undefined immediately after.

### Three callbacks gained parameter tags

`OnPlayerKeyStateChange`, `OnPlayerTakeDamage` and `OnPlayerDeath` now take
`KEY:` and `WEAPON:` tagged parameters. The open.mp migration guide calls this
the only breaking change from the new tags and gives the fix, a fallback define
plus the tagged signature, which is what was used. YSI `hook` declarations of
the same callbacks were unaffected.

### The 'T' format specifier was mangled by YSI

`gamemodes/sss/utils/string.pwn` defines two custom formatex specifiers. The 'M'
one compiled, the 'T' one produced a syntax error that made no sense.

Diagnosis: build with `-l` to get the preprocessed listing. The correct line
reads `forward F@M(...); public F@M(...)`, while the broken one reads
`forward F@Tpublic F@T(...)`. formatex names the generated public after the
specifier letter, so 'T' produces `F@T`, and YSI's foreach implementation
defines `#define F@T%0\32; F@T`, a macro that eats everything up to the first
space on any line containing `F@T`.

This is a YSI version regression rather than an open.mp problem, introduced by
pinning YSI to 5.10 rather than the 5.05 line the project used. The specifier is
unused in the codebase, but it was kept working rather than deleted: the
expansion is written out by hand with no spaces after `F@T`, which the macro
cannot match. A comment on the lines says why.

### A dependency with a malformed package definition

`ScavengeSurvive/craft` on its default branch lists a dependency as
`Southclaws-samp-logger`, with a hyphen where the slash should be. sampctl 1.14
rejects it and aborts the whole ensure. There is one commit to that file, so no
older revision is clean.

Resolution: pin craft to its `samp-compat` branch, whose package definition is
valid. Its `craft.inc` differs from the default branch by exactly one line,
which tightens `DefineItemCraftSet`'s tag from `{ItemType, _}` to
`{ItemType, bool}`. Every call site passes item types and boolean literals, so
the stricter version is a better fit.

Result: build succeeds, `gamemodes/ScavengeSurvive.amx` is produced. 1751
warnings remain, of which 1449 are weak tag mismatches and 294 are deprecated
SA-MP spellings such as `PlayerTextDrawBoxColor`. Neither blocks the build.
`NO_TAGS` and `SAMP_COMPAT` would silence them wholesale, but both throw away
checking the includes are trying to provide, so they were left visible.

## Commit 3: preserve the settings defaults

The gameplay settings the project ran on existed only inside the compose file's
`SETTINGS_OVERRIDE` block. Copied to `misc/settings.ini.example` before Docker
was removed.

First successful run happened here. Two more things were needed on this host,
both 32 bit libraries: `libatomic1:i386` for `omp-server` itself, and
`libuuid1:i386` for the uuid plugin. Without the latter the plugin fails to load
and the gamemode dies on "Function not registered: UUID".

## Commit 4: rewrite the runner

The runner used the sampctl Go module from 2021, which predates open.mp support,
to ensure and build, and then started `./samp03svr` itself.

The decisive fact: `sampctl ensure` does not write `config.json`, only
`sampctl run` does, and sampctl has no generate only mode. Verified by deleting
the file and running ensure. So the runner cannot start `omp-server` directly
without reimplementing sampctl's config generation. It now starts `sampctl run`
as a child in its own process group, and stops the group on restart. Windows
gets a separate implementation that stops the child directly.

Log parsing needed the open.mp prefix stripping. Every line is now
`[timestamp] [Level] message`, which broke the `HasPrefix` checks for
`[debug] AMX backtrace:` and the samp-logger structured format, though the
`Contains` checks for FIRST_INIT and LAST_EXIT still worked. A prefix regex
strips it before the existing logic runs. Components are now collected alongside
plugins, and the plugin name pattern was widened to accept hyphens so
`pawn-memory` is not reported as `pawn`.

Also fixed a pre-existing flaky test. `Test_parseSampLoggerFormat` compared a
field slice built from a map with `assert.Equal`, so it failed roughly one run
in six on the original code too. It now uses `assert.ElementsMatch`.

## Commit 5: sscanf as a component, and a correction

Two research passes over every plugin found exactly one with a real open.mp
component: sscanf. Its 2.13.8 release ships the same binary under both
`components/` and `plugins/`, exporting both entry points, and the open.mp
installation guide asks for it in `components/`.

sampctl's `component://` scheme installs the binary but does not add the
package's include directory to the compiler path, so the build failed with
"cannot read from file: sscanf2". Declaring sscanf twice, once with
`component://` and once with `includes://`, gives both. Confirmed by a clean
build from an empty tree.

Nothing else has a component. A community streamer component exists but its
package definition was never updated, so sampctl cannot resolve its asset, and
it is a single author fork with no adoption. open.mp provides no replacement for
Whirlpool hashing, for heap allocation, or for UUID generation, and only a
partial replacement for the fsutil and chrono APIs.

Correction to commit 1: the `long_call_time` runtime setting was removed as a
crashdetect leftover. That was wrong. crashdetect reads it from `config.json` on
open.mp, and without it the slow database and language loading during startup
are reported as hangs. Restoring it takes the count of those warnings from two
to zero. Upstream had the same arrangement: zero in the config so startup is
quiet, then five seconds set from `main()` once the gamemode is up.

pawn-memory was arriving transitively at whatever HEAD happened to be. It is
pinned to 2.0.1 now. Pinning it with a `plugin://` prefix makes sampctl fail to
extract the release asset, so it is pinned as a bare dependency.

## Commit 6: remove Docker

Dockerfile and compose file deleted, README rewritten for the native setup, CI
moved to sampctl 1.14.1 with a token to avoid the unauthenticated GitHub rate
limit, Taskfile given ensure, build and run tasks.

## Commit 7: stop the server when the runner stops

Found during final verification. Interrupting the runner left `omp-server`
running with nothing supervising it. The runner returned from its signal loop
and exited before the goroutine watching the cancelled context could stop the
child.

There was a second problem in the same place. The server loop treated any exit
as a reason to restart, so during shutdown it would have waited five seconds and
started a fresh server on the way out. It now checks whether the context has
been cancelled first, and the wait itself is interruptible.

The runner now cancels and waits for the server goroutine before returning, and
kills the process group if it has not stopped fifteen seconds after being asked.

Verified both directions: interrupting the runner leaves no server process
behind, and killing the server process makes the runner start a new one that
loads the gamemode again.

## Open items

- 1449 weak tag mismatch warnings and 294 deprecated spelling warnings. Fixing
  them is mechanical but touches most of the codebase, and open.mp ships a
  `callback-upgrade` tool for the callback subset.
- Whirlpool is unsalted and its own author's readme says to use bcrypt instead.
  Migrating password hashes is a separate project.
- fsutil and chrono could be partly replaced by open.mp natives. fsutil's path
  helpers and unsandboxed access have no equivalent, so it cannot go entirely.
- Nothing here was tested with a game client. Verification stops at a clean
  server boot, full world and loot loading, and the runner integration.
