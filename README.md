Scavenge and Survive gamemode script for SA:MP
================================


A PvP SA:MP server script built upon the SIF framework.
-------------------------

The aim of the game is to find supplies such as tools or weapons to help you
survive, either alone or in a group.

The overall objective is to build a stable community and defend it from hostile
players known as bandits.

Items spawn around the map in various places categorised by type, rarity and
location. Vehicles are rare and spawn with damaged engines, tires or locked,
they will usually spawn with loot inside the trunk.


Development
-------------------------

The gamemode is written in such a way that moving to a completely custom area
would be simple as just changing a few coordinate lines in some files.

I encourage people to play around with this gamemode, create a new map and put
loot spawns in it, I would love to see what is created!


Setup
-------------------------

1. Ensure you have ALL the dependencies listed in the master script (the one you
compile from!) each #include line has a link to the release page.

2. rename "scriptfiles-folder-structure-and-readmes" to just "scriptfiles".
The reason this folder has this name is because I don't want my actual
scriptfiles folder on the repo as it contains various things I don't wish to
share (such as user accounts and data for the test server) this may change.

3. Compile! If you set up all the dependencies correctly, there should be *no*
errors at all. If you have a problem compiling DON'T SUBMIT AN ISSUE HERE!
that place is reserved for actual bugs, if you need help, send me an email :)

4. Set up plugins and filterscripts in your _server.cfg_ file.
Note: The repo contains *many* filterscripts, most of these are just testing
tools and utilities, there are only *2* filterscripts you need to run on a
public server:

        filterscripts maps rcon
        plugins streamer sscanf CTime Whirlpool FileManager

5. Set up your "/scriptfiles/SSS/settings.cfg" file, this is included with the
repo, here is an explanation of each key:

    * motd _(string)_ - message of the day, displayed to players upon connecting
    * gamemodename _(string)_ - server browser gamemode name
    * whitelist _(bool)_ - enable whitelist
    * allow-pause-map _(bool)_ - enable the map option in the pause menu
    * interior-entry _(bool)_ - enable interior entrances
    * player-animations _(bool)_ - enable the standard CJ animations
    * nametag-distance _(float)_ - set the nametag render distance (0.0 for off)

Enjoy, do whatever you want with it, but keep my name on it :)
