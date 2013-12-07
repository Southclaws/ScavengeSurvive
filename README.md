Scavenge and Survive gamemode script for SA:MP
==


A PvP SA:MP server script built upon the SIF framework.
--

The aim of the game is to find supplies such as tools or weapons to help you
survive, either alone or in a group.

The overall objective is to build a stable community and defend it from players
with more hostile intentions.

Items spawn around the map in various places categorised by type, rarity and
location. Vehicles are rare and spawn with damaged engines, tires or locked,
they will usually spawn with loot inside the trunk.

No gameplay mechanics require the use of commands. All gameplay has been built
with an intuitive _interaction model_ in mind with only 5 major keys required
to access the gamemode-specific features.


Development
--

The gamemode is written in a modular fashion, borrowing a lot of concepts from
object-oriented programming. Removing some features can be as simple as removing
an #include line.

The "World" scripts are separated and can be completely replaced for a new map.

An API is in the works that will allow developers to fully control and
manipulate the gamemode without needing to edit it in any way; allowing for
easy, conflict free updating from the master branch.

I encourage people to play around with this code, create a new map and put loot
spawns in it, I would love to see what is made!


Setup
--

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
 that place is reserved for actual bugs, if you need help, send me an email :)

4. **Set up plugins and filterscripts in your _"./server.cfg"_ file.**

 Note: The repo contains *many* filterscripts, most of these are just testing
 tools and utilities, there are only *2* filterscripts you need to run on a
 public server:

        filterscripts maps rcon
        plugins streamer sscanf CTime Whirlpool FileManager

5. **Set up gamemode settings in your _"./scriptfiles/SSS/settings.json"_ file**

 This is included with the repo and it will also self-create if absent.
 Here is an explanation of each key:

 **player related settings:**

  * allow-pause-map _(bool)_ - enable the map option in the pause menu
  * combat-log-window _(integer)_ - combat log time window in seconds
  * interior-entry _(bool)_ - enable interior entrances
  * login-freeze-time _(integer)_ - amount of seconds to freeze player on spawn
  * max-tab-out-time _(integer)_ - amount of seconds that a player can alt tab
  * nametag-distance _(float)_ - set the nametag render distance (0.0 for off)
  * ping-limit _(integer)_ - maximum ping for players
  * player-animations _(bool)_ - enable the standard CJ animations

 **server related settings:**

  * file-check _(bool)_ - perform a full file check on user files
  * gamemodename _(string)_ - server browser gamemode name
  * infomsg-interval _(integer)_ - time between each info message in minutes
  * infomsgs _(string array)_ - array list of periodic information messages
  * motd _(string)_ - message of the day, displayed to players upon connecting
  * rules _(string array)_ - array list of rules
  * website _(string)_ - the website for whitelist notification message
  * whitelist _(bool)_ - enable whitelist

Enjoy, do whatever you want with it, but keep my name on it :)
