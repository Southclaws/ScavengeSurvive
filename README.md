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

## Getting Started

### Requirements

To get started with Scavenge and Survive, you need the following tools installed
on your computer:

- [Git](https://git-scm.com) To clone the repository and provide functionality
  to the [Runner](#runner)
- [sampctl](https://github.com/Southclaws/sampctl) To install the necessary Pawn
  dependencies and SA-MP plugins automatically.
- [The Go Language](https://golang.org/) To build tooling such as the Runner
  application which will make the development process easier.
- [Taskfile](https://taskfile.dev) To run common development tasks such as
  building, running and generating additional assets and data.

Tip: The easiest way to install all of these is with [Scoop](https://scoop.sh)!

### First Time Build & Run

Clone the repository to your computer using Git (Or the GitHub desktop app, if
you prefer that)

```
git clone https://github.com/Southclaws/ScavengeSurvive.git
```

Now, open the directory in your favourite IDE. I recommend vscode. As long as
you have a terminal in there, you'll be fine.

Run the following commands to pull the Pawn dependencies, SA-MP plugins,
compiler and other necessary components:

```
sampctl package ensure
sampctl package build
```

When on `master` branch, this should finish with no errors. You can check the
state of the `master` branch here:
https://github.com/Southclaws/ScavengeSurvive/actions?query=workflow%3Abuild if
the topmost item has a ✅ then the latest commit on `master` will compile with
no errors.

Now, build and run the runner with:

```
task
```

This will run the default task which will compile and run the Runner. This
application runs in the background while you develop and will keep the server
running.

### Development Workflow

Now you can edit code and leave the Runner in the background. The runner will
not automatically recompile the gamemode unless you set `AUTO_BUILD`. Generally,
it's best to separate this process so use sampctl for builds instead.

Once you have made a change and are ready to test, go in-game and use the
`/restart` command with 0 to restart the server immediately.

#### `.env`

You can place environment variables in a file named `.env` in the root directory
of the repository. For a list of configuration options, see `runner/config.go`.
The environment variable names are the ones after `envconfig` in
"UPPER_SNAKE_CASE".

## Deployment

The recommended deployment strategy is to use Docker. This project comes with a
`Dockerfile` and a `docker-compose.yml` so it's ready to go.

Assuming you have a server (baremetal or virtual), clone the source to the
machine either manually or using an automation tool such as
[Pico](https://pico.sh)

```
git clone https://github.com/Southclaws/ScavengeSurvive.git
```

Now you just need to run Docker Compose, which will build the image if necessary
and run it - detach in order to daemonise the server. It's exposed on port 7777
udp by default.

```
docker-compose up -d
```

### Architecture

The image uses the Runner as the entrypoint. This keeps the server running and
performs restarts internal to the container - this means the container will not
close unless a catastrophic error occurs. Because of this, you should leave
auto-restart for the container disabled and manually intervene if anything goes
wrong.

The container expects the entire repository to be mounted into it. This may seem
counterintuitive but this is to facilitate safe restarts without complicating
the application architecture.

### Updating the Server

When a new version is released, `git pull` inside the repository (Or, if you're
using Pico, this will be done automatically) and let the Runner automatically
rebuild the server while it's running. See below to learn more about automatic
update scheduling.

## Runner

The Runner is a simple wrapper around the server binary. It simply keeps the
server running and is suitable for use in development and production.

### Automatic Update Scheduling

When the launcher detects a new `ScavengeSurvive.amx` file has been compiled, it
will signal to the game server that an update is ready. This will trigger the
game server to schedule a restart in 1 hour.

### Logging

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

### Auto Restart

If the server crashes - or, more accurately, closes without the runner telling
it to, it will automatically restart.

### Restart Process Kill

To avoid `server closed connection` while also doing a full restart without
`gmx`, the process will be killed completely and re-executed when the gamemode
finishes its graceful shutdown during a restart.

### Auto Build

Set the environment variable `AUTO_BUILD` to 1 in order to enable automatic
builds. This is similar to sampctl's --watch feature.

---

## Open Source

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

### The License

Short Summary: https://tldrlegal.com/license/mozilla-public-license-2.0-(mpl-2)

Ensure that you understand these key points from the license:

You must make the source code for any of your changes available under MPL, but
you can combine the MPL software with proprietary code, as long as you keep the
MPL code in separate files. Version 2.0 is, by default, compatible with LGPL and
GPL version 2 or greater. You can distribute binaries under a proprietary
license, as long as you make the source available under MPL.

**And leave all credits intact. This includes any in-game messages.**

This block is shown at the top of every source file to indicate it's under MPL:

```
Copyright (C) 2020 Barnaby "Southclaws" Keene

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
```
