# Scavenge and Survive

## Overview

Scavenge and Survive is a PvP SA:MP survival gamemode. The aim of the game is to
find supplies such as tools or weapons to help you survive, either alone or in a
group.

The overall objective is to build a stable community and defend it from players
with more hostile intentions.

Items spawn around the map in various places categorised by type, rarity and
location. Vehicles are rare and spawn with damaged engines or tires and will
usually spawn with loot inside the trunk.

No gameplay mechanics require the use of commands. All gameplay has been built
with an intuitive _interaction model_ in mind with only 5 major keys required to
access the gamemode-specific features.

## Usage

To run Scavenge and Survive, download the Scavenge and Survive server launcher.
Either add this to your path, or, if you don't know how to do that, just drop it
into an _empty_ directory and run it.

You can download the latest version of the launcher by going to
[this link](https://github.com/Southclaws/ScavengeSurvive/actions?query=workflow%3Arunner)
and selecting the first item in the list with a ✅ and clicking `runner` under
"Artifacts". This will give you a zip file with a Windows and a Linux binary.

Executing the runner in an empty directory will download, ensure and build the
gamemode ready for running.

Executing the runner in the repository will:

1. Generate a `server.cfg`
2. Run the server with enhancements

### Runner Enhancements

#### Automatic Update Scheduling

When the launcher detects a new `ScavengeSurvive.amx` file has been compiled, it
will signal to the game server that an update is ready. This will trigger the
game server to schedule a restart in 1 hour.

#### Logging

The runner will automatically parse all log output and re-write it to stdout
after parsing it. It will parse
[samp-logger](https://github.com/Southclaws/samp-logger) format output and
output it using the built-in logger. This means logs can be in JSON or other
formats.

All preamble is removed. This means all the nonsense that the SA-MP server and
plugins print out during initialisation is removed completely. So all you'll see
is a list of plugins:

```
2020-10-19T02:04:21.566+0100    INFO    finished initialising   {"plugins": ["nolog", "crashdetect", "sscanf", "streamer", "chrono", "pawn", "Whirlpool", "fsutil"]}
2020-10-19T02:04:21.567+0100    INFO    [OnGameModeInit] FIRST_INIT
```

#### Auto Restart

If the server crashes - or, more accurately, closes without the runner telling
it to, it will automatically restart.

#### Restart Process Kill

To avoid `server closed connection` while also doing a full restart without
`gmx`, the process will be killed completely and re-executed when the gamemode
finishes its graceful shutdown during a restart.

## Development

Development of this project requires
[`sampctl`](https://github.com/Southclaws/sampctl), a package management and
project build tool for SA:MP. It's easy to install and easy to use. To download
all dependencies and compile the gamemode, run:

```bash
sampctl project ensure
sampctl project build
```

There is also a [Taskfile](https://taskfile.dev/#/) in the repo for common
tasks. This is usually used to start the runner and run other tasks such as
generating trees etc.

I encourage people to play around with this code, create a new map and put loot
spawns in it or completely mod it into a new gamemode, I would love to see what
creations are made! Please publish all bug fixes in order to benefit everyone.

That being said, This is not a simple project, you have been warned. I do not
have time to provide tech-support so please do not contact me asking me for help
compiling the project (sorry!)

### Don't Be Selfish

When you fix something, don't keep it to yourself. This is an open source
project. An important part of open source is sharing, that's why this code is
free of charge and available to all.

Please respect this. Feel free to keep your unique features private, just submit
_all_ fixes to the base code as pull requests or just email them to me/post them
as issues here.

## LICENSE

Short Summary: https://www.tldrlegal.com/l/gpl-3.0

Ensure that you understand these key points from the license:

**You may copy, distribute and modify the software as long as you track
changes/dates in source files.**

**Any modifications to or software including (via compiler) GPL-licensed code
must also be made available under the GPL along with build & install
instructions.**

And leave all credits intact. This includes any in-game messages.

This block is shown at the top of every source file to indicate it's under GPL:

```
Copyright (C) 2016 Barnaby "Southclaw" Keene

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.
```
