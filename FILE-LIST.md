## Core/
Scripts that control everything from gameplay mechanics to server behaviour.
### Server/
Purely server related scripts, unrelated to players, vehicles, items, etc. Generally just miscellaneous or important things.
- Hooks - Hooks a couple of functions before any other script can, this is why this is included right at the top.
- Settings - Loads the "settings.json" file or if it's nonexistent, creates one and fills it with defaults.
- TextTags - Handles chat text 'tags' such as @ for player names or & for colours.
- Weather - Manages weather data and the delay between weather changes.
- Whitelist - Contains all whitelist related functions and queries.
- SaveBlock - Blocks players from saving their character in certain locations, instead the character will be repositioned to a preset position for each blocked 'zone'.
- ActivityLog - Logs strings to a file titled with the date, prefixes each log entry with the time of day.
- FileCheck - Will probably never need to be used, cleans up the player/inventory folders (more info in the script)
- Autosave - Efficiently autosaves vehicles and player data on a timer.
- IRC - Connects to an IRC server and channel for chat.

### UI/
All these scripts are related to the user interface in some way.
- PlayerUI - Loads all per-player UI elements when someone joins.
- GlobalUI - Loads all global UI elements (looks the same for all players).
- HoldAction - Library that allows actions to be performed by holding the interact key for some period of time and displays a progress bar.
- Radio - Radio interface and controls, players change their frequency with this.
- TipText - Functions that control the displaying and hiding of tooltips.
- KeyActions - Displays a list of context-sensitive key prompts in the upper right corner of the screen.
- Watch - Covers up the mini-map and displays the time, frequency and heading to the player.
- Keypad - Library that adds a 10 digit clickable keypad that is used in the script similarly to dialogs.

### Vehicle/
Vehicle related scripts that control everything related to vehicles.
- Core - Handles vehicle creation, data generation/management and player interaction. Provides an API for vehicle manipulation.
- Spawn - Spawning code and file-reading code for vehicle placement data.
- PlayerVehicle - Handles player-owned vehicle saving and loading.
- Repair - Uses interaction callback to allow players to repair vehicles using certain items.
- LockBreak - Allows players to break into vehicles that spawned locked using a crowbar item.
- Locksmith - Handles external locking of vehicles using a Locksmith Kit item.
- Carmour - Allows vehicles to have attached objects.

### Weapon/
Weapon related scripts, currently only one but a folder exists in case of expansion.
- Core - Completely wraps the default weapon system of the game and adds extra functionality such as magazine and reserve pools of ammunition.

### Loot/
Scripts that manage automated item spawning.
- Spawn - Contains functions for generating random items and creating them.
- HouseLoot - Uses the above script and the Streamer plugin API to create loot items inside house interior meshes.

### Player/
Player related code. Not gameplay mechanics however, these scripts are all internal and aren't really 'experienced' by end-users.
- Core - Manages connects and disconnects, runs init and exit code for players.
- Accounts - Everything to do with the account side of players (not character data)
- Aliases - Contains functions that find accounts from the same owner.
- SaveLoad - Manages the character and inventory saving/loading.
- Spawn - Handles spawning the player in as an existing or new character.
- Damage - Handles weapon damage code, uses the AdvancedWeaponData library.
- Death - Death code and item dropping.
- Tutorial - The simple inventory tutorial script displayed for new players.
- WelcomeMessage - A dialog with a welcome message for new players, keeps the message up for 5 seconds.
- AntiCombatLog - Ensures players can't log off shortly after being shot at.
- Chat - OnPlayerText code, global/local/radio code and muting.
- CmdProcess - OnPlayerCommandText command processing (ZCMD style)
- Commands - Contains all the standard player commands.
- AfkCheck - Empty... (???)
- AltTabCheck - Checks if the player's game is unfocused and kicks them after some time.
- DisallowActions - Blocks the player from doing certain things when they shouldn't (picking up items while handcuffed for example)
- Profile - Simple "/profile" command that retrieves some basic stats on a player name.
- ToolTips - Script that uses 'TipText' to display information on each item.

### Char/
These are all gameplay mechanic scripts. The effects of these scripts are directly 'experienced' by the player.
- Food - Controls food item definition and eating/drinking code.
- Clothes - Clothes items, changing clothes and skin data management and interface.
- Hats - Hat item definition, hat data management and interface.
- Inventory - Inventory UI code, inventory 'tiles' and click-events.
- Animations - Sitting, surrendering and handcuff stumbling code.
- MeleeItems - Handles melee item definition and weapon code.
- KnockOut - Unconsciousness code, also updates low-health knockouts.
- Disarm - Code for disarming a knocked out or surrendering player.
- Overheat - Vehicle weapon overheating code for the Rhino tank and Hunter helicopter.
- Towtruck - Tow truck towing code.
- Holster - Manages holstering items and declaring items that can be holstered.
- Infection - Handles timed infection effects from eating raw meat food items.
- Backpack - Backpack definition, interaction and interfacing with other containers.
- HandCuffs - Handcuff offsets and toggle function (not item code).
- Medical - All medical item behaviour code in here.
- AimShout - Allows players to send predefined customised local chat messages while aiming their weapon.
- Masks - All facial wear item definition and interface.
- Drugs - Drug effects and timing code.

### World/
Entities that are created in the game world and can interacted with in some way.
- Fuel - Create fuel outlets that can be used to fill Petrol Cans.
- Barbecue - Item extension code that allows food to be cooked on BBQ items.
- Defences - Manages defence item definition, manipulation and destruction.
- GraveStone - Item extension code for torsos that stores player name and death reason with torso items.
- SafeBox - Handles safebox containers, saving and loading of item contents.
- Tent - Handles construction of tents and saving/loading of item contents.
- Campfire - Handles objects for campfires and some clever trickery used to swap the item models.
- Workbench - Unfinished, so far it can create tables in the world that you place items on.
- Emp - Creates taser-like explosions that knock players out.
- Explosive - Manages setting items to explode and figuring out where those items are in the world.
- SprayTag - Creates flat planes in the world that players can spray their username onto.
- Sign - Item extension script that allows sign items to be placed and written on.
- SupplyCrate - Creates supply crates that contain items on a timer that drop to predefined locations.

### Admin/
These scripts are all staff tools or administrative control scripts.
- Report - Player tool for reporting other players.
- HackDetect - Detects most hack devices and automatically reports or bans players.
- HackTrap - Allows creation of dummy items in impossible-to-reach places that autoban on pickup.
- Level1 - Admin level 1 commands.
- Level2 - Admin level 2 commands.
- Level3 - Admin level 3 commands.
- Level4 - Developer commands.
- Duty - Duty command that handles loading and unloading of character data.
- Ban - Ban system, database functions and interface.
- BanCommand - Code that handles the "/ban" admin command.
- BanList - Code that displays a list of banned players.
- Spectate - Allows staff to watch over players and displays some basic info about the player.
- Core - Core of the staff level system, database functions and interface.
- BugReport - Bug reporting script for players to use.
- detfield - Manages detection field core code (database stuff, creation and deletion)
- detfield_cmds - Extension that allows staff to create detection fields which log player activity in the field area.
- detfield_draw - Currently unused extension that draws a detection field polygon with objects in the game world.
- Mute - Timed muting system blocks players from using global chat.

### Item/
All these scripts are item related code, it's currently in a bit of a mess and needs sorting.
- Food
- firework
- bottle
- TntTimeBomb
- Sign
- shield
- HandCuffs
- wheel
- gascan
- armyhelm
- zorromask
- headlight
- pills
- dice
- armour
- injector
- TntPhoneBomb
- TntTripMine
- parachute
- molotov
- screwdriver
- torso
- ammotin
- tentpack
- campfire
- cowboyhat
- truckcap
- boaterhat
- bowlerhat
- policecap
- tophat
- herpderp
- candrink
- TntProxMine
- IedTimebomb
- IedTripMine
- IedProxMine
- IedPhoneBomb
- EmpTimebomb
- EmpTripMine
- EmpProxMine
- EmpPhoneBomb
- GasMask
- HockeyMask
- XmasHat

### Data/
The data that goes into the systems to make them work.
- Vehicle - Vehicle fuel, trunk sizes, loot indexes, etc...
- Weapon - Weapon ammunition types and sizes.
- Loot - Loot indexes.

## Utils/
- math
- misc
- time
- camera
- message
- vehicle
- vehicledata
- vehicleparts
- zones
- player
- object
- tickcountfix

## World/
These scripts are all included from within "/World/World.pwn" which means you can swap out to a new worldscript by simply copying in a folder.
Worlds packaged with the server:
- World - The entirety of San Andreas covered with loot spawns and interactive environment features.
- World_LS - Just Los Santos and Red County loot spawns, fuel outlets and some interactive features.
- World_LV - Just Las Venturas, Bone County and Tierra Robada loot spawns, fuel outlets and some interactive features.
- World_SF - Just San Fierro and Flint County loot spawns, fuel outlets and some interactive features.
- World_Wasteland - Experimental procedurally generated flat desert land.
