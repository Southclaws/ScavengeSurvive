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

## Commits 8 to 12: clear the warnings

The port compiled and ran at this point, with 1751 warnings. The open.mp
include documentation, in `documentation/readme-intermediate.md` and
`documentation/readme-expert.md` inside the omp-stdlib dependency, explains
what each kind means and how to resolve it. It also offers `NO_TAGS`,
`MIXED_SPELLINGS`, `LEGACY_SCRIPTING_API` and `SAMP_COMPAT` as ways to silence
them wholesale. None of those were used. Every warning that belongs to this
codebase was resolved by changing the code the warning points at.

### What they were

| Kind | Count |
| --- | --- |
| Weak tag mismatch | 1449 |
| Deprecated function or spelling | 294 |
| Unused or shadowed variables | 8 |

### Deprecated names

The includes settled on British spellings as canonical, so the six textdraw
colour functions were renamed, which accounted for 225 warnings. Four other
deprecated calls were replaced with the ones their messages named:
PrintAmxBacktrace, db_num_rows and pawn-errors' NoError, plus Iter_SafeRemove.

Iter_SafeRemove was the only one that needed thought. It removed an entry and
handed back the following one so a caller could advance a loop by hand. YSI
supports removal during iteration now, so the three functions built on it just
remove the entry, and the loops that called them advance on their own. Two of
those functions returned the next id rather than the one they were given, which
their callers then assigned back to the loop variable.

### Tags

Parameters restricted to a set of values are enumerations now, and on or off
parameters are booleans, so bare integers warn.

The bulk was mechanical, applied with a script that split each call's arguments
at the top level rather than pattern matching, so nested calls, arrays and
strings were left alone and any argument that was not a plain integer literal
was reported rather than rewritten. That covered animation, textdraw, timer and
label calls, and took the count from 1507 to 298. One macro was responsible for
524 of those on its own: PreloadAnimLib expanded to an ApplyAnimation call with
four booleans written as zero, once for each of 131 animation libraries.

The rest was not mechanical. Tagging a hooked callback's parameters pushes the
tag into its body, which is where the value is. Warnings went up before they
went down, and each rise named a magic number worth replacing: a key test that
read 16 became KEY_SECONDARY_ATTACK, a shot handler switching on 30 became
WEAPON_AK47, and a tyre repair testing `tires & 0b0010` became a named popped
tyre with its clearing mask written as the complement of the same constant.

Where a value crossed a module boundary the tag was carried with it rather than
cast at each use. The weapon item record's base weapon field, the vehicle damage
record's four fields, the functions that pack and unpack those bitfields, and
the locals that receive them are all tagged now, which is what turned seventeen
melee weapon definitions passing zero into WEAPON_FIST.

Two places were deliberately left as explicit untags. A death handler switches
over the result of GetLastHitByWeapon, which returns an Item, against weapon and
reason ids. The two disagree, the same function already untagged that value on
the lines above, and reconciling it is a gameplay decision rather than a porting
one. Vehicle light masks kept their literal values with the tag applied, because
the gamemode treats lights as four adjacent bits and the includes document a
different layout.

### What is left

95 warnings, of which 88 are inside dependencies and 7 are pre-existing code
quality warnings in the gamemode.

The dependency warnings cannot be fixed from here, because sampctl re-downloads
those directories. 38 of them are sqlitei calling PrintAmxBacktrace, one line
upstream. The rest are sqlitei's legacy database API, and untagged booleans in
samp-ladders and samp-zipline.

The seven in the gamemode are unused assignments and two shadowed variables,
none of them related to open.mp. They were left alone on purpose. One is worth a
look by someone who knows the gameplay: a vehicle collision handler reads a
knock multiplier back from a callback and then never uses it, which the compiler
now points at. Silencing it would hide that.

## Open items

- 88 warnings inside dependencies, listed above. sqlitei's PrintAmxBacktrace
  calls are a one line upstream fix worth sending.
- A vehicle collision handler fetches a knock multiplier and never applies it.
  The compiler flags it as an unused assignment. It looks like a real bug, but
  fixing it changes gameplay.
- Whirlpool is unsalted and its own author's readme says to use bcrypt instead.
  Migrating password hashes is a separate project.
- fsutil and chrono could be partly replaced by open.mp natives. fsutil's path
  helpers and unsandboxed access have no equivalent, so it cannot go entirely.
- Nothing here was tested with a game client. Verification stops at a clean
  server boot, full world and loot loading, and the runner integration.
