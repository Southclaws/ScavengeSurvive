# Scavenge and Survive
[![GPL-V3](http://www.gnu.org/graphics/gplv3-88x31.png)](http://www.gnu.org/copyleft/gpl.html)[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/Southclaw/ScavengeSurvive?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Support the development of this mod by donating. I can put more time into adding new features!

[![Donate](https://www.paypalobjects.com/webstatic/mktg/Logo/pp-logo-200px.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=P7H2FNNWLMFW4)


## A PvP SA:MP server script

The aim of the game is to find supplies such as tools or weapons to help you survive, either alone or in a group.

The overall objective is to build a stable community and defend it from players with more hostile intentions.

Items spawn around the map in various places categorised by type, rarity and location. Vehicles are rare and spawn with damaged engines or tires and will usually spawn with loot inside the trunk.

No gameplay mechanics require the use of commands. All gameplay has been built with an intuitive _interaction model_ in mind with only 5 major keys required to access the gamemode-specific features.


## Development

The gamemode is written in a modular fashion, borrowing a lot of concepts from object-oriented programming. The "World" scripts are separated and can be completely replaced for a new map.

I encourage people to play around with this code, create a new map and put loot spawns in it or completely mod it into a new gamemode, I would love to see what creations are made! Please publish all bug fixes in order to benefit everyone.

### Don't Be Selfish

When you fix something, don't keep it to yourself. This is an open source project. An important part of open source is sharing, that's why this code is free of charge and available to all.

Please respect this. Feel free to keep your unique features private, just submit *all* fixes to the base code as pull requests or just email them to me.

### Builds

Each time I compile a version of the gamemode, the build number (stored in BUILD_NUMBER) is incremented. This is also shown in-game at the top-right of the screen and will allow players and developers to know which version is in use which can help track issues and fix bugs.

IMPORTANT: DO NOT USE THE BUILD SCRIPT YOURSELF! The reason for this is that you'll change the build number which is meant to reflect which BASE version of the gamemode you are using, NOT your own builds. This will greatly improve my ability to fix issues on your server.


## Setup

**What version do I use?**

If you're running a *public server* use the latest [release](https://github.com/Southclaw/ScavengeSurvive/releases). It *should* be stable but remember, this is a constantly evolving project and bugs always slip through!

If you want to hack on the code and contribute, pull the latest commit.

### 1. Dependencies

Ensure you have ALL the dependencies listed in the master script (the one you compile from!) each #include line has a link to the release page.

### 2. `scriptfiles/` directory

The server will automatically create any required directories such as `scriptfiles/data/`.

If you want to use the maps provided in the repository, extract `scriptfiles/Maps.zip` to `scriptfiles/`

### 3. Compile!

If you have a problem compiling **DON'T SUBMIT AN ISSUE HERE!** this is reserved for actual bugs.

If you set up all the dependencies correctly, there should be *no* errors or warnings at all unless mentioned in the commit message.

### 4. Set up plugins and filterscripts in your `server.cfg` file.

Note: The repo contains *many* filterscripts, most of these are just testing tools and utilities, there are only *2* filterscripts you need to run on a public server:
```
filterscripts object-loader rcon
plugins streamer sscanf CTime Whirlpool FileManager irc
```

### 5. Set up gamemode settings in your `scriptfiles/SSS/settings.ini` file

This is an INI file with game settings that will self-create if absent.

Most of the settings should be self-explanitory. If the purpose isn't clear, look up the setting in the source code for more information.


## LICENSE

I don't expect you to read the entire license.

Just ensure you understand this:

You may copy, distribute and modify the software as long as you track changes/dates in source files.

Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.

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
with this program.  If not, see http://www.gnu.org/licenses/.
```
