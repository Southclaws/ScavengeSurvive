# Scavenge and Survive

[![GPL-V3](https://img.shields.io/badge/license-GPL3-red.svg)](http://www.gnu.org/copyleft/gpl.html)
[![Slack](https://img.shields.io/badge/discuss-slack-orange.svg)](https://join.slack.com/southclaws/shared_invite/MjA5NzM2ODkxMDExLTE0OTk1MDI4MjItYjdjM2NmMTJjNA)
[![Discord](https://img.shields.io/badge/discuss-discord-blue.svg)](http://dc.southcla.ws)
[![GitHub issues](https://img.shields.io/github/issues/Southclaws/ScavengeSurvive.svg)](https://www.github.com/Southclaws/ScavengeSurvive/issues)
[![Donate](https://img.shields.io/badge/donate-paypal-3b7bbf.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=P7H2FNNWLMFW4)

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

## Development

Development of this project requires
[`sampctl`](https://github.com/Southclaws/sampctl), a package management and
project build tool for SA:MP. It's easy to install and easy to use. To compile
the gamemode, run:

```bash
sampctl project build
```

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
