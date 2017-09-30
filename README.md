# Scavenge and Survive

[![GPL-V3](https://img.shields.io/badge/license-GPL3-red.svg)](http://www.gnu.org/copyleft/gpl.html)
[![Slack](https://img.shields.io/badge/discuss-slack-orange.svg)](https://join.slack.com/southclaws/shared_invite/MjA5NzM2ODkxMDExLTE0OTk1MDI4MjItYjdjM2NmMTJjNA)
[![Discord](https://img.shields.io/badge/discuss-discord-blue.svg)](http://dc.southcla.ws)
[![GitHub issues](https://img.shields.io/github/issues/Southclaws/ScavengeSurvive.svg)]()
[![Waffle.io](https://img.shields.io/waffle/label/Southclaws/ScavengeSurvive/in%20progress.svg)](https://waffle.io/Southclaws/ScavengeSurvive)
[![Donate](https://img.shields.io/badge/donate-paypal-3b7bbf.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=P7H2FNNWLMFW4)


## A PvP SA:MP server script

The aim of the game is to find supplies such as tools or weapons to help you survive, either alone or in a group.

The overall objective is to build a stable community and defend it from players with more hostile intentions.

Items spawn around the map in various places categorised by type, rarity and location. Vehicles are rare and spawn with damaged engines or tires and will usually spawn with loot inside the trunk.

No gameplay mechanics require the use of commands. All gameplay has been built with an intuitive _interaction model_ in mind with only 5 major keys required to access the gamemode-specific features.


## Development

Development of this project is only advised to experienced users of the Pawn language or other languages. The development environment is rather specific and requires quite a bit of existing software knowledge such as makefiles, dependency management and Docker (if on Windows).

That being said, I encourage people to play around with this code, create a new map and put loot spawns in it or completely mod it into a new gamemode, I would love to see what creations are made! Please publish all bug fixes in order to benefit everyone.

### Pre-Requisites

- GNU Make - You can install Git For Windows to get this on Windows, it's pretty standard on Linux
- Git - You should have acquired the project via `git clone` anyway, if not I highly advise it so you can easily stay up to date
- sampctl - You can download this from my GitHub - it's a tool for aiding the development and management process of SA:MP servers
- Patience - This is not a simple project, you have been warned. I do not have time to provide tech-support so please do not contact me asking me for help compiling the project (sorry!)

### Dependencies

To get the dependencies, run `make dependencies` - this will also run on every build, just to keep things up to date. I try to keep the code compatible with the HEADs of dependencies. You can download them manually but that would be a pain.

### `pawncc` on System `PATH` Environment Variable

Make sure `pawncc` is available as a command - if you do not know how to do this then Google is your friend! I recommend Zeex' compiler on Linux but the default compiler will do just fine on Windows.

### Compile!

If you're just developing, run `make dev-windows`/`make dev-linux` to run a fast build. YMMV but it takes around 30 seconds on my machine.

When you deploy, run `make prod-windows`/`make prod-linux` and this will push all the limits for various entities up pretty high.

### Don't Be Selfish

When you fix something, don't keep it to yourself. This is an open source project. An important part of open source is sharing, that's why this code is free of charge and available to all.

Please respect this. Feel free to keep your unique features private, just submit *all* fixes to the base code as pull requests or just email them to me.

### Builds

Each time I compile a version of the gamemode, the build number (stored in `BUILD_NUMBER`) is incremented. This is also shown in-game at the top-right of the screen and will allow players and developers to know which version is in use which can help track issues and fix bugs.

### Missing Features

Scavenge and Survive is now provided as a baseline to build from and many older features have been stripped out and are being developed privately. This is partly to deter inexperienced users from attempting to run a SS server/community. I hate to do this and it goes against everything I believe in when it comes to open source but it's something I had to do to prevent problems between communities and people using my work without giving proper credit.

Missing features:

#### Entity Storage (items, safeboxes, tents, defences, signs)

You will need to devise your own system for storing safeboxes, tents, defences and signs.

This does not affect players and vehicles, these systems are still public so you can still run a basic server.

#### Tree generator bitmap

This is simply a 6000 x 6000 bitmap that determines tree placement.
See generate_trees.py for information.


## LICENSE

Short Summary: https://www.tldrlegal.com/l/gpl-3.0

I don't expect you to read the entire license (Read the summary linked above).

Just ensure you understand this:

**You may copy, distribute and modify the software as long as you track changes/dates in source files.**

**Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.**

And leave all credits intact.

### Source file extract

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
