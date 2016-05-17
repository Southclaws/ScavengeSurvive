/*==============================================================================


	Southclaw's Scavenge and Survive

		Big thanks to Onfire559/Adam for the initial concept and developing
		the idea a lot long ago with some very productive discussions!
		Recently influenced by Minecraft and DayZ, credits to the creators of
		those games and their fundamental mechanics and concepts.

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


==============================================================================*/


#include <a_samp>

/*==============================================================================

	Library Predefinitions

==============================================================================*/

#undef MAX_PLAYERS
#define MAX_PLAYERS	(32)

native IsValidVehicle(vehicleid);
native gpci(playerid, serial[], len);

#define _DEBUG							0 // YSI
#define DB_DEBUG						false // SQLitei
#define DB_MAX_STATEMENTS				(128) // SQLitei
#define DB_DEBUG_BACKTRACE_NOTICE		(true) // SQLitei
#define DB_DEBUG_BACKTRACE_WARNING		(true) // SQLitei
#define DB_DEBUG_BACKTRACE_ERROR		(true) // SQLitei
#define STRLIB_RETURN_SIZE				(256) // strlib
#define MODIO_DEBUG						(0) // modio
#define MODIO_FILE_STRUCTURE_VERSION	(20) // modio
#define MODIO_SCRIPT_EXIT_FIX			(1) // modio
#define MAX_MODIO_SESSION				(2048) // modio
#define BTN_TELEPORT_FREEZE_TIME		(3000) // SIF/Button
#define INV_MAX_SLOTS					(6) // SIF/Inventory
#define ITM_ARR_ARRAY_SIZE_PROTECT		(false) // SIF/extensions/ItemArrayData
#define ITM_MAX_TYPES					(ItemType:300) // SIF/Item
#define ITM_MAX_NAME					(20) // SIF/Item
#define ITM_MAX_TEXT					(64) // SIF/Item
#define ITM_DROP_ON_DEATH				(false) // SIF/Item
#define SIF_USE_DEBUG_LABELS			(true) // SIF/extensions/DebugLabels
//	#define DEBUG_LABELS_BUTTON				(true) // SIF/Button
//	#define DEBUG_LABELS_ITEM				(true) // SIF/Item
#define BTN_MAX							(32768) // SIF/Button
#define ITM_MAX							(32768) // SIF/Item
#define CNT_MAX_SLOTS					(100)

/*==============================================================================

	Guaranteed first call

	OnGameModeInit_Setup is called before ANYTHING else, the purpose of this is
	to prepare various internal and external systems that may need to be ready
	for other modules to use their functionality. This function isn't hooked.

	OnScriptInit (from YSI) is then called through modules which is used to
	prepare dependencies such as databases, folders and register debuggers.

	OnGameModeInit is then finally called throughout modules and starts inside
	the "Server/Init.pwn" module (very important) so itemtypes and other object
	types can be defined. This callback is used throughout other scripts as a
	means for declaring entities with relevant data.

==============================================================================*/

public OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Main'...");

	OnGameModeInit_Setup();

	#if defined main_OnGameModeInit
		return main_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit main_OnGameModeInit
#if defined main_OnGameModeInit
	forward main_OnGameModeInit();
#endif

/*==============================================================================

	Libraries and respective links to their release pages

==============================================================================*/

#include <crashdetect>				// By Zeex					http://forum.sa-mp.com/showthread.php?t=262796
#include <sscanf2>					// By Y_Less:				https://github.com/Southclaw/sscanf2
#include <YSI\y_utils>				// By Y_Less, 4:			https://github.com/Misiur/YSI-Includes
#include <YSI\y_va>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <YSI\y_iterate>
#include <YSI\y_ini>
#include <YSI\y_dialog>

#include "sss\core\server\hooks.pwn"// Internal library for hooking functions before they are used in external libraries.

#include <streamer>					// By Incognito, v2.7.5.2:	http://forum.sa-mp.com/showthread.php?t=102865
#include <irc>						// By Incognito, 1.4.5:		http://forum.sa-mp.com/showthread.php?t=98803
#include <dns>						// By Incognito, 2.4:		http://forum.sa-mp.com/showthread.php?t=75605
#include <sqlitei>					// By Slice, v0.9.7:		http://forum.sa-mp.com/showthread.php?t=303682
#include <formatex>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=313488
#include <strlib>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=362764
#include <md-sort>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=343172
#include <geolocation>				// By Whitetiger:			https://github.com/Whitetigerswt/SAMP-geoip

#define time ctime_time
#include <CTime>					// By RyDeR:				http://forum.sa-mp.com/showthread.php?t=294054
#undef time

#include <progress2>				// By Toribio/Southclaw:	https://github.com/Southclaw/PlayerProgressBar
#include <FileManager>				// By JaTochNietDan, 1.5:	http://forum.sa-mp.com/showthread.php?t=92246
#include <mapandreas>

#include <SimpleINI>				// By Southclaw:			https://github.com/Southclaw/SimpleINI
#include <modio>					// By Southclaw:			https://github.com/Southclaw/modio
#include <SIF>						// By Southclaw, HEAD:		https://github.com/Southclaw/SIF
#include <SIF\extensions\ItemArrayData>
#include <SIF\extensions\ItemList>
#include <SIF\extensions\InventoryDialog>
#include <SIF\extensions\InventoryKeys>
#include <SIF\extensions\ContainerDialog>
#include <SIF\extensions\Craft>
#include <SIF\extensions\DebugLabels>
#include <WeaponData>				// By Southclaw:			https://github.com/Southclaw/AdvancedWeaponData
#include <Line>						// By Southclaw:			https://github.com/Southclaw/Line
#include <Zipline>					// By Southclaw:			https://github.com/Southclaw/Zipline
#include <Ladder>					// By Southclaw:			https://github.com/Southclaw/Ladder

native WP_Hash(buffer[], len, const str[]);
									// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=65290


/*==============================================================================

	Definitions

==============================================================================*/


// Limits
#define MAX_MOTD_LEN				(128)
#define MAX_WEBSITE_NAME			(64)
#define MAX_RULE					(24)
#define MAX_RULE_LEN				(128)
#define MAX_STAFF					(24)
#define MAX_STAFF_LEN				(24)
#define MAX_PLAYER_FILE				(MAX_PLAYER_NAME+16)
#define MAX_ADMIN					(48)
#define MAX_PASSWORD_LEN			(129)
#define MAX_GPCI_LEN				(41)
#define MAX_HOST_LEN				(256)


// Directories
#define DIRECTORY_SCRIPTFILES		"./scriptfiles/"
#define DIRECTORY_MAIN				"SSS/"


// Files
#define ACCOUNT_DATABASE			DIRECTORY_MAIN"accounts.db"
#define WORLD_DATABASE				DIRECTORY_MAIN"world.db"
#define SETTINGS_FILE				DIRECTORY_MAIN"settings.ini"


// Macros
#define t:%1<%2>					((%1)|=(%2))
#define f:%1<%2>					((%1)&=~(%2))

#define SetSpawn(%0,%1,%2,%3,%4)	SetSpawnInfo(%0, NO_TEAM, 0, %1, %2, %3, %4, 0,0,0,0,0,0)

#define CMD:%1(%2)					forward cmd_%1(%2);\
									public cmd_%1(%2)

#define ACMD:%1[%2](%3)				forward acmd_%1_%2(%3);\
									public acmd_%1_%2(%3)

#define SCMD:%1(%2)					forward scmd_%1(%2);\
									public scmd_%1(%2)

#define HOLDING(%0)					((newkeys & (%0)) == (%0))
#define RELEASED(%0)				(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#define PRESSED(%0)					(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define IsValidPlayerID(%0)			(0<=%0<MAX_PLAYERS)


// Colours
#define YELLOW						0xFFFF00FF

#define RED							0xE85454FF
#define GREEN						0x33AA33FF
#define BLUE						0x33CCFFFF

#define ORANGE						0xFFAA00FF
#define GREY						0xAFAFAFFF
#define PINK						0xFFC0CBFF
#define NAVY						0x000080FF
#define GOLD						0xB8860BFF
#define LGREEN						0x00FD4DFF
#define TEAL						0x008080FF
#define BROWN						0xA52A2AFF
#define AQUA						0xF0F8FFFF

#define BLACK						0x000000FF
#define WHITE						0xFFFFFFFF
#define CHAT_LOCAL					0xADABD1FF
#define CHAT_RADIO					0xCFD1ABFF


// Embedding Colours
#define C_YELLOW					"{FFFF00}"

#define C_RED						"{E85454}"
#define C_GREEN						"{33AA33}"
#define C_BLUE						"{33CCFF}"

#define C_ORANGE					"{FFAA00}"
#define C_GREY						"{AFAFAF}"
#define C_PINK						"{FFC0CB}"
#define C_NAVY						"{000080}"
#define C_GOLD						"{B8860B}"
#define C_LGREEN					"{00FD4D}"
#define C_TEAL						"{008080}"
#define C_BROWN						"{A52A2A}"
#define C_AQUA						"{F0F8FF}"

#define C_BLACK						"{000000}"
#define C_WHITE						"{FFFFFF}"

#define C_SPECIAL					"{0025AA}"


// Body parts
#define BODY_PART_TORSO				(3)
#define BODY_PART_GROIN				(4)
#define BODY_PART_LEFT_ARM			(5)
#define BODY_PART_RIGHT_ARM			(6)
#define BODY_PART_LEFT_LEG			(7)
#define BODY_PART_RIGHT_LEG			(8)
#define BODY_PART_HEAD				(9)


// Report types
#define REPORT_TYPE_PLAYER_ID		"PLY ID"
#define REPORT_TYPE_PLAYER_NAME		"PLY NAME"
#define REPORT_TYPE_PLAYER_CLOSE	"PLY CLOSE"
#define REPORT_TYPE_PLAYER_KILLER	"PLY KILL"
#define REPORT_TYPE_TELEPORT		"TELE"
#define REPORT_TYPE_SWIMFLY			"FLY"
#define REPORT_TYPE_VHEALTH			"VHP"
#define REPORT_TYPE_CAMDIST			"CAM"
#define REPORT_TYPE_CARNITRO		"NOS"
#define REPORT_TYPE_CARHYDRO		"HYDRO"
#define REPORT_TYPE_CARTELE			"VTP"
#define REPORT_TYPE_HACKTRAP		"TRAP"
#define REPORT_TYPE_LOCKEDCAR		"LCAR"
#define REPORT_TYPE_AMMO			"AMMO"
#define REPORT_TYPE_SHOTANIM		"ANIM"
#define REPORT_TYPE_BADHITOFFSET	"BHIT"
#define REPORT_TYPE_BAD_SHOT_WEAP	"BSHT"


// Genders
#define GENDER_MALE					(0)
#define GENDER_FEMALE				(1)


// Key text
#define KEYTEXT_INTERACT			"~k~~VEHICLE_ENTER_EXIT~"
#define KEYTEXT_RELOAD				"~k~~PED_ANSWER_PHONE~"
#define KEYTEXT_PUT_AWAY			"~k~~CONVERSATION_YES~"
#define KEYTEXT_DROP_ITEM			"~k~~CONVERSATION_NO~"
#define KEYTEXT_INVENTORY			"~k~~GROUP_CONTROL_BWD~"
#define KEYTEXT_ENGINE				"~k~~CONVERSATION_YES~"
#define KEYTEXT_LIGHTS				"~k~~CONVERSATION_NO~"
#define KEYTEXT_DOORS				"~k~~TOGGLE_SUBMISSIONS~"
#define KEYTEXT_RADIO				"R"

// Attachment slots
enum
{
	ATTACHSLOT_ITEM,		// 0 - Same as SIF/Item
	ATTACHSLOT_BAG,			// 1 - Bag on back
	ATTACHSLOT_HOLSTER,		// 2 - Item holstering
	ATTACHSLOT_HAT,			// 3 - Head-wear slot
	ATTACHSLOT_FACE,		// 4 - Face-wear slot
	ATTACHSLOT_BLOOD,		// 5 - Bleeding particle effect
	ATTACHSLOT_ARMOUR		// 6 - Armour model slot
}


/*==============================================================================

	Global values

==============================================================================*/


new
bool:	gServerInitialising = true,
		gServerInitialiseTick,
bool:	gServerRestarting = false,
		gServerMaxUptime,
		gServerUptime,
		gGlobalDebugLevel;

// DATABASES
new
DB:		gAccounts;

// GLOBAL SERVER SETTINGS (Todo: modularise)
new
		// player
		gMessageOfTheDay[MAX_MOTD_LEN],
		gWebsiteURL[MAX_WEBSITE_NAME],
		gRuleList[MAX_RULE][MAX_RULE_LEN],
		gStaffList[MAX_STAFF][MAX_STAFF_LEN],

		// server
bool:	gPauseMap,
bool:	gInteriorEntry,
bool:	gPlayerAnimations,
bool:	gVehicleSurfing,
Float:	gNameTagDistance,
		gCombatLogWindow,
		gLoginFreezeTime,
		gMaxTaboutTime,
		gPingLimit,
		gCrashOnExit;

// INTERNAL
new
		gBigString[MAX_PLAYERS][4096],
		gTotalRules,
		gTotalStaff;

new stock
		GLOBAL_DEBUG = -1;


/*==============================================================================

	Gamemode Scripts

==============================================================================*/


// API Pre
#tryinclude "sss/extensions/ext_pre.pwn"

// UTILITIES
#include "sss/utils/math.pwn"
#include "sss/utils/misc.pwn"
#include "sss/utils/time.pwn"
#include "sss/utils/camera.pwn"
#include "sss/utils/message.pwn"
#include "sss/utils/vehicle.pwn"
#include "sss/utils/vehicle-data.pwn"
#include "sss/utils/vehicle-parts.pwn"
#include "sss/utils/zones.pwn"
#include "sss/utils/player.pwn"
#include "sss/utils/object.pwn"
#include "sss/utils/tickcountfix.pwn"
#include "sss/utils/string.pwn"
#include "sss/utils/debug.pwn"
#include "sss/utils/dialog-pages.pwn"

// SERVER CORE
#include "sss/core/server/settings.pwn"
#include "sss/core/server/text-tags.pwn"
#include "sss/core/server/weather.pwn"
#include "sss/core/server/save-block.pwn"
#include "sss/core/server/activity-log.pwn"
#include "sss/core/server/info-message.pwn"
#include "sss/core/server/language.pwn"
#include "sss/core/player/language.pwn"

/*
	PARENT SYSTEMS
	Modules that declare setup functions and constants used throughout.
*/
#include "sss/core/vehicle/vehicle-type.pwn"
#include "sss/core/vehicle/core.pwn"
#include "sss/core/player/core.pwn"
#include "sss/core/player/save-load.pwn"
#include "sss/core/admin/core.pwn"
#include "sss/core/char/holster.pwn"
#include "sss/core/weapon/ammunition.pwn"
#include "sss/core/weapon/core.pwn"
#include "sss/core/weapon/damage-core.pwn"
#include "sss/core/ui/hold-action.pwn"
#include "sss/core/item/liquid.pwn"

/*
	MODULE INITIALISATION CALLS
	Calls module constructors to set up entity types.
*/
#include "sss/core/server/init.pwn"

/*
	CHILD SYSTEMS
	Modules that do not declare anything globally accessible besides interfaces.
*/
// VEHICLE
#include "sss/core/vehicle/player-vehicle.pwn"
#include "sss/core/vehicle/loot-vehicle.pwn"
#include "sss/core/vehicle/spawn.pwn"
#include "sss/core/vehicle/interact.pwn"
#include "sss/core/vehicle/trunk.pwn"
#include "sss/core/vehicle/repair.pwn"
#include "sss/core/vehicle/lock-break.pwn"
#include "sss/core/vehicle/locksmith.pwn"
#include "sss/core/vehicle/carmour.pwn"
#include "sss/core/vehicle/lock.pwn"
#include "sss/core/vehicle/anti-ninja.pwn"
#include "sss/core/vehicle/bike-collision.pwn"
#include "sss/core/vehicle/trailer.pwn"

// PLAYER INTERNAL SCRIPTS
#include "sss/core/player/accounts.pwn"
#include "sss/core/player/aliases.pwn"
#include "sss/core/player/ipv4-log.pwn"
#include "sss/core/player/gpci-log.pwn"
#include "sss/core/player/gpci-whitelist.pwn"
#include "sss/core/player/brightness.pwn"
#include "sss/core/player/spawn.pwn"
#include "sss/core/player/damage.pwn"
#include "sss/core/player/death.pwn"
#include "sss/core/player/tutorial.pwn"
#include "sss/core/player/welcome-message.pwn"
#include "sss/core/player/chat.pwn"
#include "sss/core/player/cmd-process.pwn"
#include "sss/core/player/commands.pwn"
#include "sss/core/player/afk-check.pwn"
#include "sss/core/player/alt-tab-check.pwn"
#include "sss/core/player/disallow-actions.pwn"
#include "sss/core/player/tool-tips.pwn"
#include "sss/core/player/whitelist.pwn"
#include "sss/core/player/irc.pwn"
#include "sss/core/player/country.pwn"

// CHARACTER SCRIPTS
#include "sss/core/char/food.pwn"
#include "sss/core/char/drugs.pwn"
#include "sss/core/char/clothes.pwn"
#include "sss/core/char/hats.pwn"
#include "sss/core/char/inventory.pwn"
#include "sss/core/char/animations.pwn"
#include "sss/core/char/knockout.pwn"
#include "sss/core/char/disarm.pwn"
#include "sss/core/char/overheat.pwn"
#include "sss/core/char/infection.pwn"
#include "sss/core/char/backpack.pwn"
#include "sss/core/char/handcuffs.pwn"
#include "sss/core/char/medical.pwn"
#include "sss/core/char/aim-shout.pwn"
#include "sss/core/char/masks.pwn"
#include "sss/core/char/bleed.pwn"

// WEAPON
#include "sss/core/weapon/loot.pwn"
#include "sss/core/weapon/interact.pwn"
#include "sss/core/weapon/damage-firearm.pwn"
#include "sss/core/weapon/damage-melee.pwn"
#include "sss/core/weapon/damage-vehicle.pwn"
#include "sss/core/weapon/damage-explosive.pwn"
#include "sss/core/weapon/damage-world.pwn"
#include "sss/core/weapon/animset.pwn"
#include "sss/core/weapon/misc.pwn"
#include "sss/core/weapon/anti-combat-log.pwn"
#include "sss/core/weapon/tracer.pwn"

// UI
#include "sss/core/ui/radio.pwn"
#include "sss/core/ui/tip-text.pwn"
#include "sss/core/ui/key-actions.pwn"
#include "sss/core/ui/watch.pwn"
#include "sss/core/ui/keypad.pwn"
#include "sss/core/ui/body-preview.pwn"

// WORLD ENTITIES
#include "sss/core/world/fuel.pwn"
#include "sss/core/world/barbecue.pwn"
#include "sss/core/world/defences.pwn"
#include "sss/core/world/gravestone.pwn"
#include "sss/core/world/safebox.pwn"
#include "sss/core/world/tent.pwn"
#include "sss/core/world/campfire.pwn"
#include "sss/core/world/emp.pwn"
#include "sss/core/world/explosive.pwn"
#include "sss/core/world/sign.pwn"
#include "sss/core/world/supply-crate.pwn"
#include "sss/core/world/weapons-cache.pwn"
#include "sss/core/world/loot.pwn"
#include "sss/core/world/craft-construct.pwn"
#include "sss/core/world/workbench.pwn"
#include "sss/core/world/machine.pwn"
#include "sss/core/world/scrap-machine.pwn"
#include "sss/core/world/refine-machine.pwn"
#include "sss/core/world/tree.pwn"

// ADMINISTRATION TOOLS
#include "sss/core/admin/report.pwn"
#include "sss/core/admin/report-cmds.pwn"
#include "sss/core/admin/hack-detect.pwn"
#include "sss/core/admin/hack-trap.pwn"
#include "sss/core/admin/ban.pwn"
#include "sss/core/admin/ban-command.pwn"
#include "sss/core/admin/ban-list.pwn"
#include "sss/core/admin/spectate.pwn"
#include "sss/core/admin/level1.pwn"
#include "sss/core/admin/level2.pwn"
#include "sss/core/admin/level3.pwn"
#include "sss/core/admin/level4.pwn"
#include "sss/core/admin/level5.pwn"
#include "sss/core/admin/bug-report.pwn"
#include "sss/core/admin/detfield.pwn"
#include "sss/core/admin/detfield-cmds.pwn"
#include "sss/core/admin/detfield-draw.pwn"
#include "sss/core/admin/mute.pwn"
#include "sss/core/admin/rcon.pwn"
#include "sss/core/admin/freeze.pwn"
#include "sss/core/admin/name-tags.pwn"
#include "sss/core/admin/player-list.pwn"

// ITEMS
#include "sss/core/item/food.pwn"
#include "sss/core/item/firework.pwn"
#include "sss/core/item/bottle.pwn"
#include "sss/core/item/tnttimebomb.pwn"
#include "sss/core/item/sign.pwn"
#include "sss/core/item/shield.pwn"
#include "sss/core/item/handcuffs.pwn"
#include "sss/core/item/wheel.pwn"
#include "sss/core/item/gascan.pwn"
#include "sss/core/item/armyhelm.pwn"
#include "sss/core/item/zorromask.pwn"
#include "sss/core/item/headlight.pwn"
#include "sss/core/item/pills.pwn"
#include "sss/core/item/dice.pwn"
#include "sss/core/item/armour.pwn"
#include "sss/core/item/injector.pwn"
#include "sss/core/item/tntphonebomb.pwn"
#include "sss/core/item/tnttripmine.pwn"
#include "sss/core/item/parachute.pwn"
#include "sss/core/item/molotov.pwn"
#include "sss/core/item/screwdriver.pwn"
#include "sss/core/item/torso.pwn"
#include "sss/core/item/ammotin.pwn"
#include "sss/core/item/tentpack.pwn"
#include "sss/core/item/campfire.pwn"
#include "sss/core/item/cowboyhat.pwn"
#include "sss/core/item/truckcap.pwn"
#include "sss/core/item/boaterhat.pwn"
#include "sss/core/item/bowlerhat.pwn"
#include "sss/core/item/policecap.pwn"
#include "sss/core/item/tophat.pwn"
#include "sss/core/item/herpderp.pwn"
#include "sss/core/item/tntproxmine.pwn"
#include "sss/core/item/iedtimebomb.pwn"
#include "sss/core/item/iedtripmine.pwn"
#include "sss/core/item/iedproxmine.pwn"
#include "sss/core/item/iedphonebomb.pwn"
#include "sss/core/item/emptimebomb.pwn"
#include "sss/core/item/emptripmine.pwn"
#include "sss/core/item/empproxmine.pwn"
#include "sss/core/item/empphonebomb.pwn"
#include "sss/core/item/gasmask.pwn"
#include "sss/core/item/hockeymask.pwn"
#include "sss/core/item/xmashat.pwn"
#include "sss/core/item/stungun.pwn"
#include "sss/core/item/note.pwn"
#include "sss/core/item/seedbag.pwn"
#include "sss/core/item/plantpot.pwn"
#include "sss/core/item/heartshapedbox.pwn"
#include "sss/core/item/fishingrod.pwn"
#include "sss/core/item/chainsaw.pwn"
#include "sss/core/item/locator.pwn"

// GAME DATA LOADING
#include "sss/data/loot.pwn" // todo: load from file


// POST-CODE

#include "sss/core/server/auto-save.pwn"
#tryinclude "sss/extensions/ext_post.pwn"

// WORLD

#include "sss/world/world.pwn"

#if !defined GetMapName
	#error World script MUST have a "GetMapName" function!
#endif

#if !defined GenerateSpawnPoint
	#error World script MUST have a "GenerateSpawnPoint" function!
#endif


static
Text:RestartCount = Text:INVALID_TEXT_DRAW;

main()
{
	print("\n\n/*==============================================================================\n\n");
	print("    Southclaw's Scavenge and Survive");
	print("        Copyright (C) 2016 Barnaby \"Southclaw\" Keene");
	print("        This program comes with ABSOLUTELY NO WARRANTY; This is free software,");
	print("        and you are welcome to redistribute it under certain conditions.");
	print("        Please see <http://www.gnu.org/copyleft/gpl.html> for details.");
	print("\n\n==============================================================================*/\n\n");

	gServerInitialising = false;
	gServerInitialiseTick = GetTickCount();
}

/*
	This is called absolutely first before any other call.
*/
OnGameModeInit_Setup()
{
	print("\n[OnGameModeInit_Setup] Setting up...");

	Streamer_ToggleErrorCallback(true);
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);

	if(!dir_exists(DIRECTORY_SCRIPTFILES))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES"' not found. Creating directory.");
		dir_create(DIRECTORY_SCRIPTFILES);
	}

	if(!dir_exists(DIRECTORY_SCRIPTFILES DIRECTORY_MAIN))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_MAIN"' not found. Creating directory.");
		dir_create(DIRECTORY_SCRIPTFILES DIRECTORY_MAIN);
	}

	gAccounts = db_open_persistent(ACCOUNT_DATABASE);

	LoadSettings();

	SendRconCommand(sprintf("mapname %s", GetMapName()));

	GetSettingInt("server/global-debug-level", 0, gGlobalDebugLevel);
	GLOBAL_DEBUG = debug_register_handler("GLOBAL", gGlobalDebugLevel);

	RestartCount				=TextDrawCreate(430.000000, 10.000000, "Server Restart In:~n~00:00");
	TextDrawAlignment			(RestartCount, 2);
	TextDrawBackgroundColor		(RestartCount, 255);
	TextDrawFont				(RestartCount, 1);
	TextDrawLetterSize			(RestartCount, 0.400000, 2.000000);
	TextDrawColor				(RestartCount, -1);
	TextDrawSetOutline			(RestartCount, 1);
	TextDrawSetProportional		(RestartCount, 1);
}

public OnGameModeExit()
{
	print("\n[OnGameModeExit] Shutting down...");

	if(gCrashOnExit)
	{
		new File:f = fopen("nonexistentfile", io_read), _s[1];
		fread(f, _s);
		fclose(f);
	}

	return 1;
}

public OnScriptExit()
{
	print("\n[OnScriptExit] Shutting down...");
}

forward SetRestart(seconds);
public SetRestart(seconds)
{
	printf("Restarting server in: %ds", seconds);
	gServerUptime = gServerMaxUptime - seconds;
}

RestartGamemode()
{
	log("[RestartGamemode] Initialising gamemode restart...");
	gServerRestarting = true;

	foreach(new i : Player)
	{
		SavePlayerData(i);
		ResetVariables(i);
	}

	SendRconCommand("gmx");

	ChatMsgAll(BLUE, " ");
	ChatMsgAll(ORANGE, "Scavenge and Survive");
	ChatMsgAll(BLUE, "    Copyright (C) 2016 Barnaby \"Southclaw\" Keene");
	ChatMsgAll(BLUE, "    This program comes with ABSOLUTELY NO WARRANTY; This is free software,");
	ChatMsgAll(BLUE, "    and you are welcome to redistribute it under certain conditions.");
	ChatMsgAll(BLUE, "    Please see <http://www.gnu.org/copyleft/gpl.html> for details.");
	ChatMsgAll(BLUE, " ");
	ChatMsgAll(BLUE, " ");
	ChatMsgAll(BLUE, "-------------------------------------------------------------------------------------------------------------------------");
	ChatMsgAll(YELLOW, " >  The Server Is Restarting, Please Wait...");
	ChatMsgAll(BLUE, "-------------------------------------------------------------------------------------------------------------------------");
}

task RestartUpdate[1000]()
{
	if(gServerMaxUptime > 0)
	{
		if(gServerUptime >= gServerMaxUptime)
		{
			RestartGamemode();
		}

		if(gServerUptime >= gServerMaxUptime - 3600)
		{
			new str[36];
			format(str, 36, "Server Restarting In:~n~%02d:%02d", (gServerMaxUptime - gServerUptime) / 60, (gServerMaxUptime - gServerUptime) % 60);
			TextDrawSetString(RestartCount, str);

			foreach(new i : Player)
			{
				if(GetPlayerBitFlag(i, ShowHUD))
					TextDrawShowForPlayer(i, RestartCount);

				else
					TextDrawHideForPlayer(i, RestartCount);
			}
		}

		gServerUptime++;
	}
}

DirectoryCheck(directory[])
{
	if(!dir_exists(directory))
	{
		printf("ERROR: Directory '%s' not found. Creating directory.", directory);
		dir_create(directory);
	}
}

DatabaseTableCheck(DB:database, tablename[], expectedcolumns)
{
	new
		query[96],
		DBResult:result,
		dbcolumns;

	format(query, sizeof(query), "pragma table_info(%s)", tablename);
	result = db_query(database, query);

	dbcolumns = db_num_rows(result);

	if(dbcolumns != expectedcolumns)
	{
		printf("ERROR: Table '%s' has %d columns, expected %d:", tablename, dbcolumns, expectedcolumns);
		print("Please verify table structure against column list in script.");

		// Put the server into a loop to stop it so the user can read the message.
		// It won't function correctly with bad databases anyway.
		for(;;){}
	}
}

public Streamer_OnPluginError()
{
	PrintAmxBacktrace();
}
