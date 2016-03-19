# Scavenge and Survive gamemode script for SA:MP
[![GPL-V3](http://www.gnu.org/graphics/gplv3-88x31.png)](http://www.gnu.org/copyleft/gpl.html)[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/Southclaw/ScavengeSurvive?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)[![Donate](https://www.paypalobjects.com/en_GB/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=M7WJU7YN8PKGQ)

Support the development of this mod by donating. I can put more time into adding new features!


## A PvP SA:MP server script built upon the SIF framework.

The aim of the game is to find supplies such as tools or weapons to help you
survive, either alone or in a group.

The overall objective is to build a stable community and defend it from players
with more hostile intentions.

Items spawn around the map in various places categorised by type, rarity and
location. Vehicles are rare and spawn with damaged engines or tires and will
usually spawn with loot inside the trunk.

No gameplay mechanics require the use of commands. All gameplay has been built
with an intuitive _interaction model_ in mind with only 5 major keys required
to access the gamemode-specific features.


## Development

The gamemode is written in a modular fashion, borrowing a lot of concepts from
object-oriented programming. The "World" scripts are separated and can be
completely replaced for a new map.

I encourage people to play around with this code, create a new map and put loot
spawns in it or completely mod it into a new gamemode, I would love to see what
creations are made! Please publish all bug fixes in order to benefit everyone.


## Setup

1. **Dependencies**

 Ensure you have ALL the dependencies listed in the master script (the one you
 compile from!) each #include line has a link to the release page.

2. **"/scriptfiles/" directory**

 Rename "scriptfiles-folder-structure-and-readmes" to just "scriptfiles".
 The reason this folder has this name is because I don't want my actual
 scriptfiles folder on the repo as it contains various things I don't wish to
 share (such as user accounts and data for the test server) this may change.

 (However, the server will cleverly automatically create any missing
 files/folders when started so this repository folder isn't even required any
 more!)

3. **Compile!**

 If you set up all the dependencies correctly, there should be *no*
 errors at all. If you have a problem compiling DON'T SUBMIT AN ISSUE HERE!
 that place is reserved for actual bugs.

4. **Set up plugins and filterscripts in your _"./server.cfg"_ file.**

 Note: The repo contains *many* filterscripts, most of these are just testing
 tools and utilities, there are only *2* filterscripts you need to run on a
 public server:

        filterscripts object-loader rcon
        plugins streamer sscanf CTime Whirlpool FileManager irc

5. **Set up gamemode settings in your _"./scriptfiles/SSS/settings.ini"_ file**

 This is an INI file with game settings that will self-create if absent.
 Not all settings must be present, here is an example:
 ```
 player/max-tab-out-time=600000
 player/combat-log-window=30
 player/interior-entry=0
 autosave/autosave-toggle=1
 autosave/autosave-interval=60000
 vehicle-spawn/spawn-chance=5.0
 ```

6. **Enjoy!**

 Do whatever you want with it, but keep my name on it :)
