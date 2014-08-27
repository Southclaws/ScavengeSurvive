# ScavengeSurvive File-list
This document lists all script modules in the gamemode. It can sometimes fall behind development however and file changes might be missing.
The aim of this file is to explain the purpose of each module and meaning of the folder structure.


## Hooks
A special case that doesn't match the rest of the include structure.

SS\Core\Server\Hooks.pwn - Hooks a couple of functions before any other script can, this is why this is included right at the top.


## Utils/
Modules that contain utility helper functions. Most of these are standalone from the gamemode.

SS/utils/math.pwn
SS/utils/misc.pwn
SS/utils/time.pwn
SS/utils/camera.pwn
SS/utils/message.pwn
SS/utils/vehicle.pwn
SS/utils/vehicledata.pwn
SS/utils/vehicleparts.pwn
SS/utils/zones.pwn
SS/utils/player.pwn
SS/utils/object.pwn
SS/utils/tickcountfix.pwn
SS/utils/string.pwn
SS/utils/debug.pwn

## Core/
Scripts that control everything from gameplay mechanics to server behaviour.

### Server/
Purely server related scripts, unrelated to players, vehicles, items, etc. Generally just miscellaneous or important things.

SS/Core/Server/Init.pwn - Initialises and defines entity types and other script objects.
SS/Core/Server/Settings.pwn - Loads the "settings.json" file or if it's nonexistent, creates one and fills it with defaults.
SS/Core/Server/TextTags.pwn - Handles chat text 'tags' such as @ for player names or & for colours.
SS/Core/Server/Weather.pwn - Manages weather data and the delay between weather changes.
SS/Core/Server/SaveBlock.pwn - Blocks players from saving their character in certain locations, instead the character will be repositioned to a preset position for each blocked 'zone'.
SS/Core/Server/ActivityLog.pwn - Logs strings to a file titled with the date, prefixes each log entry with the time of day.
SS/Core/Server/FileCheck.pwn - Will probably never need to be used, cleans up the player/inventory folders (more info in the script)
SS/Core/Server/IRC.pwn - Connects to an IRC server and channel for chat.
SS/Core/Server/Sockets.pwn - Allows external web services interface with the server through sockets.


### UI/
All these scripts are related to the user interface in some way.

SS/Core/UI/PlayerUI.pwn - Loads all per-player UI elements when someone joins.
SS/Core/UI/GlobalUI.pwn - Loads all global UI elements (looks the same for all players).
SS/Core/UI/HoldAction.pwn - Library that allows actions to be performed by holding the interact key for some period of time and displays a progress bar.
SS/Core/UI/Radio.pwn - Radio interface and controls, players change their frequency with this.
SS/Core/UI/TipText.pwn - Functions that control the displaying and hiding of tooltips.
SS/Core/UI/KeyActions.pwn - Displays a list of context-sensitive key prompts in the upper right corner of the screen.
SS/Core/UI/Watch.pwn - Covers up the mini-map and displays the time, frequency and heading to the player.
SS/Core/UI/Keypad.pwn - Library that adds a 10 digit clickable keypad that is used in the script similarly to dialogs.
SS/Core/UI/DialogPages.pwn - Simple clickable UI elements designed for displaying alongside dialogs for switching pages.
SS/Core/UI/BodyPreview.pwn - Renders a 3D preview of the player with extra information, used in the invenory screen.


### Vehicle/
Vehicle related scripts that control everything related to vehicles.

SS/Core/Vehicle/VehicleTypeIndex.pwn - Provides a way to define abstract vehicle types with various data fields.
SS/Core/Vehicle/Core.pwn - Handles vehicle creation, data generation/management and player interaction. Provides an API for vehicle manipulation.
SS/Core/Vehicle/Spawn.pwn - Spawning code and file-reading code for vehicle placement data.
SS/Core/Vehicle/PlayerVehicle.pwn - Handles player-owned vehicle saving and loading.
SS/Core/Vehicle/Repair.pwn - Uses interaction callback to allow players to repair vehicles using certain items.
SS/Core/Vehicle/LockBreak.pwn - Allows players to break into vehicles that spawned locked using a crowbar item.
SS/Core/Vehicle/Locksmith.pwn - Handles external locking of vehicles using a Locksmith Kit item.
SS/Core/Vehicle/Carmour.pwn - Allows vehicles to have predefined attached objects.
SS/Core/Vehicle/Lock.pwn - Controls vehicle locking and provides API functions.
SS/Core/Vehicle/AntiNinja.pwn - Prevents the SA:MP bug "ninja hijack".
SS/Core/Vehicle/BikeCollision.pwn - Creates an additional collision mesh on pedal bikes to prevent bug abuse.

### Loot/
Scripts that manage automated item spawning (Does not require its own folder really)
SS/Core/Loot/Spawn.pwn - Contains functions for generating random items and creating them.


### Player/
Player related code. Not gameplay mechanics however, these scripts are all internal and aren't really 'experienced' by end-users.

SS/Core/Player/Core.pwn - Manages connects and disconnects, runs init and exit code for players.
SS/Core/Player/Accounts.pwn - Everything to do with the account side of players (not character data)
SS/Core/Player/Aliases.pwn - Contains functions that find accounts from the same owner.
SS/Core/Player/ipv4-log.pwn - Logs IP addresses for players if they change.
SS/Core/Player/gpci-log.pwn - Logs gpci hashes for players if they change.
SS/Core/Player/SaveLoad.pwn - Manages the character and inventory saving/loading.
SS/Core/Player/Spawn.pwn - Handles spawning the player in as an existing or new character.
SS/Core/Player/Damage.pwn - Handles weapon damage code, uses the AdvancedWeaponData library.
SS/Core/Player/Death.pwn - Death code and item dropping.
SS/Core/Player/Tutorial.pwn - The simple inventory tutorial script displayed for new players.
SS/Core/Player/WelcomeMessage.pwn - A dialog with a welcome message for new players, keeps the message up for 5 seconds.
SS/Core/Player/Chat.pwn - OnPlayerText code, global/local/radio code and muting.
SS/Core/Player/CmdProcess.pwn - OnPlayerCommandText command processing (ZCMD style)
SS/Core/Player/Commands.pwn - Contains all the standard player commands.
SS/Core/Player/AfkCheck.pwn - Empty.
SS/Core/Player/AltTabCheck.pwn - Checks if the player's game is unfocused and kicks them after some time.
SS/Core/Player/DisallowActions.pwn - Blocks the player from doing certain things when they shouldn't (picking up items while handcuffed for example)
SS/Core/Player/Profile.pwn - Simple "/profile" command that retrieves some basic stats on a player name.
SS/Core/Player/ToolTips.pwn - Script that uses 'TipText' to display information on each item.
SS/Core/Player/Whitelist.pwn - Contains all whitelist related functions and queries.


### Char/
These are all gameplay mechanic scripts. The effects of these scripts are directly 'experienced' by the player.

SS/Core/Char/Food.pwn - Controls food item definition and eating/drinking code.
SS/Core/Char/Drugs.pwn - Drug effects and timing code.
SS/Core/Char/Clothes.pwn - Clothes items, changing clothes and skin data management and interface.
SS/Core/Char/Hats.pwn - Hat item definition, hat data management and interface.
SS/Core/Char/Inventory.pwn - Inventory UI code, inventory 'tiles' and click-events.
SS/Core/Char/Animations.pwn - Sitting, surrendering and handcuff stumbling code.
SS/Core/Char/MeleeItems.pwn - Handles melee item definition and weapon code.
SS/Core/Char/KnockOut.pwn - Unconsciousness code, also updates low-health knockouts.
SS/Core/Char/Disarm.pwn - Code for disarming a knocked out or surrendering player.
SS/Core/Char/Overheat.pwn - Vehicle weapon overheating code for the Rhino tank and Hunter helicopter.
SS/Core/Char/Towtruck.pwn - Tow truck towing code.
SS/Core/Char/Holster.pwn - Manages holstering items and declaring items that can be holstered.
SS/Core/Char/Infection.pwn - Handles timed infection effects from eating raw meat food items.
SS/Core/Char/Backpack.pwn - Backpack definition, interaction and interfacing with other containers.
SS/Core/Char/HandCuffs.pwn - Handcuff offsets and toggle function (not item code).
SS/Core/Char/Medical.pwn - All medical item behaviour code in here.
SS/Core/Char/AimShout.pwn - Allows players to send predefined customised local chat messages while aiming their weapon.
SS/Core/Char/Masks.pwn - All facial wear item definition and interface.
SS/Core/Char/Bleed.pwn - Controls player health loss through bleeding.


### Weapon/
Weapon related scripts, currently only one but a folder exists in case of expansion.

SS/Core/Weapon/ammunition.pwn - Handles calibre and ammunition type definition and interface.
SS/Core/Weapon/core.pwn - Completely wraps the default weapon system of the game and adds extra functionality such as magazine and reserve pools of ammunition.
SS/Core/Weapon/interact.pwn - Handles weapon item interaction (picking up weapons and ammo etc).
SS/Core/Weapon/damage.core.pwn - Contains the main damage code and bleeding/knockout formula.
SS/Core/Weapon/damage.firearm.pwn - Contains firearm specific damage code.
SS/Core/Weapon/damage.melee.pwn - Contains default and custom melee weapon damage code.
SS/Core/Weapon/damage.vehicle.pwn - Handles vehicle collisions and converts to injury/bleed effects.
SS/Core/Weapon/damage.explosive.pwn - Handles explosions and converts to injury/bleed effects.
SS/Core/Weapon/animset.pwn - Allows definition of animation sets, for use with melee and reload animations.
SS/Core/Weapon/misc.pwn - Miscellaneous helper functions relating to weapons.
SS/Core/Weapon/AntiCombatLog.pwn - Prevents combat logging to a certain extent.
SS/Core/Weapon/tracer.pwn - Module that handles tracer rounds.


### World/
Entities that are created in the game world and can interacted with in some way.

SS/Core/World/Fuel.pwn - Create fuel outlets that can be used to fill Petrol Cans.
SS/Core/World/Barbecue.pwn - Item extension code that allows food to be cooked on BBQ items.
SS/Core/World/Defences.pwn - Manages defence item definition, manipulation and destruction.
SS/Core/World/GraveStone.pwn - Item extension code for torsos that stores player name and death reason with torso items.
SS/Core/World/SafeBox.pwn - Handles safebox containers, saving and loading of item contents.
SS/Core/World/Tent.pwn - Handles construction of tents and saving/loading of item contents.
SS/Core/World/Campfire.pwn - Handles objects for campfires and some clever trickery used to swap the item models.
SS/Core/World/Workbench.pwn - Unfinished, so far it can create tables in the world that you place items on.
SS/Core/World/Emp.pwn - Creates taser-like explosions that knock players out.
SS/Core/World/Explosive.pwn - Manages setting items to explode and figuring out where those items are in the world.
SS/Core/World/SprayTag.pwn - Creates flat planes in the world that players can spray their username onto.
SS/Core/World/Sign.pwn - Item extension script that allows sign items to be placed and written on.
SS/Core/World/SupplyCrate.pwn - Creates supply crates that contain items on a timer that drop to predefined locations.
SS/Core/World/WeaponsCache.pwn - A minigame/puzzle that drops weapons caches and gives players limited navigational information for finding them.


### Admin/
These scripts are all staff tools or administrative control scripts.

SS/Core/Admin/Report.pwn - System tool for reporting possible hackers to a database.
SS/Core/Admin/Report_cmds.pwn - Player tool for reporting other players.
SS/Core/Admin/HackDetect.pwn - Detects most hack devices and automatically reports or bans players.
SS/Core/Admin/HackTrap.pwn - Allows creation of dummy items in impossible-to-reach places that autoban on pickup.
SS/Core/Admin/Ban.pwn - Ban system, database functions and interface.
SS/Core/Admin/BanCommand.pwn - Code that handles the "/ban" admin command.
SS/Core/Admin/BanList.pwn - Code that displays a list of banned players.
SS/Core/Admin/Spectate.pwn - Allows staff to watch over players and displays some basic info about the player.
SS/Core/Admin/Core.pwn - Core of the staff level system, database functions and interface.
SS/Core/Admin/Level1.pwn - Staff level 1 commands.
SS/Core/Admin/Level2.pwn - Staff level 2 commands.
SS/Core/Admin/Level3.pwn - Staff level 3 commands.
SS/Core/Admin/Level4.pwn - Staff level 4 commands.
SS/Core/Admin/Level5.pwn - Developer commands.
SS/Core/Admin/BugReport.pwn - Bug reporting script for players to use.
SS/Core/Admin/detfield.pwn - Manages detection field core code (database stuff, creation and deletion)
SS/Core/Admin/detfield_cmds.pwn - Extension that allows staff to create detection fields which log player activity in the field area.
SS/Core/Admin/detfield_draw.pwn - Currently unused extension that draws a detection field polygon with objects in the game world.
SS/Core/Admin/Mute.pwn - Timed muting system blocks players from using global chat.
SS/Core/Admin/Rcon.pwn - Basic RCON commands for whitelist and restart control.
SS/Core/Admin/Freeze.pwn - Timed player freezing functions.
SS/Core/Admin/NameTags.pwn - Functions for toggling nametags for admin purposes.
SS/Core/Admin/FreeCam.pwn - Freely movable flying camera tool for admins.


### Item/
All these scripts are item related code, it's currently in a bit of a mess and needs sorting.

SS/Core/Item/Food.pwn
SS/Core/Item/firework.pwn
SS/Core/Item/bottle.pwn
SS/Core/Item/TntTimeBomb.pwn
SS/Core/Item/Sign.pwn
SS/Core/Item/shield.pwn
SS/Core/Item/HandCuffs.pwn
SS/Core/Item/wheel.pwn
SS/Core/Item/gascan.pwn
SS/Core/Item/armyhelm.pwn
SS/Core/Item/zorromask.pwn
SS/Core/Item/headlight.pwn
SS/Core/Item/pills.pwn
SS/Core/Item/dice.pwn
SS/Core/Item/armour.pwn
SS/Core/Item/injector.pwn
SS/Core/Item/TntPhoneBomb.pwn
SS/Core/Item/TntTripMine.pwn
SS/Core/Item/parachute.pwn
SS/Core/Item/molotov.pwn
SS/Core/Item/screwdriver.pwn
SS/Core/Item/torso.pwn
SS/Core/Item/ammotin.pwn
SS/Core/Item/tentpack.pwn
SS/Core/Item/campfire.pwn
SS/Core/Item/cowboyhat.pwn
SS/Core/Item/truckcap.pwn
SS/Core/Item/boaterhat.pwn
SS/Core/Item/bowlerhat.pwn
SS/Core/Item/policecap.pwn
SS/Core/Item/tophat.pwn
SS/Core/Item/herpderp.pwn
SS/Core/Item/candrink.pwn
SS/Core/Item/TntProxMine.pwn
SS/Core/Item/IedTimebomb.pwn
SS/Core/Item/IedTripMine.pwn
SS/Core/Item/IedProxMine.pwn
SS/Core/Item/IedPhoneBomb.pwn
SS/Core/Item/EmpTimebomb.pwn
SS/Core/Item/EmpTripMine.pwn
SS/Core/Item/EmpProxMine.pwn
SS/Core/Item/EmpPhoneBomb.pwn
SS/Core/Item/GasMask.pwn
SS/Core/Item/HockeyMask.pwn
SS/Core/Item/XmasHat.pwn
SS/Core/Item/StunGun.pwn


### Data/
The data that goes into the systems to make them work.

SS/Data/Loot.pwn - Loot indexes.
SS/Data/Vehicle.pwn - Vehicle fuel, trunk sizes, loot indexes, etc...
SS/Data/Weapon.pwn - Weapon ammunition types and sizes.

SS/Core/Server/Autosave.pwn - Efficiently autosaves vehicles and player data on a timer.


## World/
More modules are all included from within "/World/World.pwn" which means you can swap out to a new world script simply by changing this include.
Worlds packaged with the server:

SS/World/World.pwn - The entirety of San Andreas covered with loot spawns and interactive environment features.
SS/World/World_BS.pwn - A small testing/combat area in Bayside, Tierra Robada with high weapon loot spawns.
SS/World/World_Wasteland.pwn - Experimental procedurally generated flat desert land.
