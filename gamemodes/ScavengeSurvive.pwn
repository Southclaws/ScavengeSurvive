/*==============================================================================


	Southclaws' Scavenge and Survive

		Big thanks to Onfire559/Adam for the initial concept and developing
		the idea a lot long ago with some very productive discussions!
		Recently influenced by Minecraft and DayZ, credits to the creators of
		those games and their fundamental mechanics and concepts.

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>

/*==============================================================================

	Library Predefinitions

==============================================================================*/

#undef MAX_PLAYERS
#define MAX_PLAYERS						(50)

// YSI
#define _DEBUG							0

#define CGEN_MEMORY						(90000)

#define YSI_NO_VERSION_CHECK
#define YSI_NO_OPTIMISATION_MESSAGE
#define YSI_NO_MODE_CACHE
#define YSI_NO_HEAP_MALLOC

// SQLitei
#define DB_DEBUG						false
#define DB_MAX_STATEMENTS				(128)
#define DB_DEBUG_BACKTRACE_NOTICE		(true)
#define DB_DEBUG_BACKTRACE_WARNING		(true)
#define DB_DEBUG_BACKTRACE_ERROR		(true)

// strlib
#define STRLIB_RETURN_SIZE				(256)

// modio
#define MODIO_DEBUG						(0)
#define MODIO_FILE_STRUCTURE_VERSION	(20)
#define MODIO_SCRIPT_EXIT_FIX			(1)
#define MAX_MODIO_SESSION				(2048)

// SS/button
#define BTN_TELEPORT_FREEZE_TIME		(3000)

// SS/inventory
#define MAX_INVENTORY_SLOTS				(6)

// SS/button
#define BTN_MAX							Button:32768

// SS/item
#define MAX_ITEM						Item:32768
#define MAX_ITEM_TYPE					(ItemType:302)
#define MAX_ITEM_NAME					(20)
#define MAX_ITEM_TEXT					(64)
#define MAX_CONTAINER_SLOTS				(100)

// pawn-errors
// #define PRINT_BACKTRACES

#pragma warning disable 208 // TODO: Fix reparse issues and remove!
#pragma dynamic 64000

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
	// Note: DO NOT CHANGE THIS STRING!
	print("[OnGameModeInit] FIRST_INIT");

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

#include <crashdetect>				// By Zeex					https://github.com/Zeex/samp-plugin-crashdetect
#include <sscanf2>					// By Y_Less:				https://github.com/maddinat0r/sscanf
#include <streamer>					// By Incognito:			https://github.com/samp-incognito/samp-streamer-plugin/releases/tag/v2.82
#include <chrono>					// By Southclaws:			https://github.com/Southclaws/pawn-chrono
#include <fsutil>					// By Southclaws:			https://github.com/Southclaws/pawn-fsutil
#include <sqlitei>					// By Slice:				https://github.com/oscar-broman/sqlitei
#include <YSI_Coding\y_hooks>       // By Y_Less:				https://github.com/pawn-lang/YSI-Includes
#include <YSI_Coding\y_timers>      // By Y_Less:				https://github.com/pawn-lang/YSI-Includes
#include <YSI_Coding\y_va>          // By Y_Less:				https://github.com/pawn-lang/YSI-Includes
#include <YSI_Core\y_utils>			// By Y_Less:				https://github.com/pawn-lang/YSI-Includes
#include <YSI_Data\y_iterate>       // By Y_Less:				https://github.com/pawn-lang/YSI-Includes
#include <YSI_Storage\y_ini>        // By Y_Less:				https://github.com/pawn-lang/YSI-Includes
#include <YSI_Visual\y_dialog>      // By Y_Less:				https://github.com/pawn-lang/YSI-Includes

#include "sss\core\server\hooks.pwn"// Internal library for hooking functions before they are used in external libraries.

// Temporary fix
#if defined IsNaN
	#undef IsNaN
#endif

#include <progress2>				// By Toribio/Southclaws:	https://github.com/Southclaws/progress2
#include <formatex>					// By Slice:				https://github.com/southclaws/formatex
#include <strlib>					// By Slice:				https://github.com/oscar-broman/strlib
#include <md-sort>					// By Slice:				https://github.com/oscar-broman/md-sort
#include <ini>						// By Southclaws:			https://github.com/Southclaws/SimpleINI
#include <modio>					// By Southclaws:			https://github.com/Southclaws/modio
#include <personal-space>           // By Southclaws:			https://github.com/ScavengeSurvive/personal-space
#include <button>           		// By Southclaws:			https://github.com/ScavengeSurvive/button
#include <door>                     // By Southclaws:			https://github.com/ScavengeSurvive/door
#include <item>                     // By Southclaws:			https://github.com/ScavengeSurvive/item
#include <inventory>                // By Southclaws:			https://github.com/ScavengeSurvive/inventory
#include <container>                // By Southclaws:			https://github.com/ScavengeSurvive/container
#include <item-array-data>          // By Southclaws:			https://github.com/Southclaws/ScavengeSurvive/item-array-data
#include <item-serializer>          // By Southclaws:			https://github.com/Southclaws/ScavengeSurvive/tree/master/legacy
#include <inventory-dialog>         // By Southclaws:			https://github.com/ScavengeSurvive/
#include <container-dialog>         // By Southclaws:			https://github.com/ScavengeSurvive/
#include <craft>                    // By Southclaws:			https://github.com/ScavengeSurvive/
#include <debug-labels>             // By Southclaws:			https://github.com/Southclaws/ScavengeSurvive/tree/master/legacy
#include <weapon-data>				// By Southclaws:			https://github.com/Southclaws/AdvancedWeaponData
#include <linegen>					// By Southclaws:			https://github.com/Southclaws/Line
#include <zipline>					// By Southclaws:			https://github.com/Southclaws/Zipline
#include <ladders>					// By Southclaws:			https://github.com/Southclaws/Ladder

native WP_Hash(buffer[], len, const str[]);
									// By Y_Less:				https://github.com/Southclaws/samp-whirlpool
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
#define DIRECTORY_MAIN				"data/"


// Files
#define ACCOUNT_DATABASE			DIRECTORY_MAIN"accounts.db"
#define WORLD_DATABASE				DIRECTORY_MAIN"world.db"
#define SETTINGS_FILE				DIRECTORY_MAIN"settings.ini"


// Macros
#define CMD:%1(%2)					forward cmd_%1(%2);\
									public cmd_%1(%2)

#define ACMD:%1[%2](%3)				forward acmd_%1_%2(%3);\
									public acmd_%1_%2(%3)

#define SCMD:%1(%2)					forward scmd_%1(%2);\
									public scmd_%1(%2)

#define HOLDING(%0)					((newkeys & (%0)) == (%0))
#define RELEASED(%0)				(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#define PRESSED(%0)					(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

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

// Redefine Item Extra Data API with the Array Data API
#define SetItemExtraData(%0,%1) SetItemArrayDataAtCell(%0,%1,0,true)
#define GetItemExtraData(%0) GetItemArrayDataAtCell(%0,0)


/*==============================================================================
	Global values
==============================================================================*/


new
		gBuildNumber,
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
bool:	gAutoLoginWithIP,
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

// UTILITIES
#include "sss/utils/logging.pwn"
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
#include "sss/utils/string.pwn"
#include "sss/utils/dialog-pages.pwn"
#include "sss/utils/item.pwn"
#include "sss/utils/headoffsets.pwn"


// SERVER CORE
#include "sss/core/server/settings.pwn"
#include "sss/core/server/text-tags.pwn"
#include "sss/core/server/weather.pwn"
#include "sss/core/server/save-block.pwn"
#include "sss/core/server/info-message.pwn"
#include "sss/core/server/language.pwn"
#include "sss/core/player/language.pwn"

/*
	PARENT SYSTEMS
	Modules that declare setup functions and constants used throughout.
*/
#include "sss/core/vehicle/vehicle-type.pwn"
#include "sss/core/vehicle/lock.pwn"
#include "sss/core/player/player.pwn"
#include "sss/core/vehicle/vehicle.pwn"
#include "sss/core/admin/admin.pwn"
#include "sss/core/weapon/ammunition.pwn"
#include "sss/core/weapon/weapon.pwn"
#include "sss/core/weapon/damage.pwn"
#include "sss/core/ui/hold-action.pwn"
#include "sss/core/item/liquid.pwn"
#include "sss/core/world/tree.pwn"
#include "sss/core/world/explosive.pwn"
#include "sss/core/world/craft-construct.pwn"
#include "sss/core/io/loot.pwn"
#include "sss/core/io/item.pwn"
#include "sss/core/io/defence.pwn"
#include "sss/core/io/safebox.pwn"
#include "sss/core/io/tree.pwn"

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
#include "sss/core/player/whitelist.pwn"
#include "sss/core/player/country.pwn"
#include "sss/core/player/recipes.pwn"
#include "sss/core/player/widescreen.pwn"

// CHARACTER SCRIPTS
#include "sss/core/char/movement.pwn"
#include "sss/core/char/food.pwn"
#include "sss/core/char/drugs.pwn"
#include "sss/core/char/clothes.pwn"
#include "sss/core/char/inventory.pwn"
#include "sss/core/char/animations.pwn"
#include "sss/core/char/knockout.pwn"
#include "sss/core/char/disarm.pwn"
#include "sss/core/char/overheat.pwn"
#include "sss/core/char/infection.pwn"
#include "sss/core/char/handcuffs.pwn"
#include "sss/core/char/aim-shout.pwn"
#include "sss/core/char/bleed.pwn"
#include "sss/core/char/skills.pwn"
#include "sss/core/char/travel-stats.pwn"

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
#include "sss/core/ui/tool-tip.pwn"
#include "sss/core/ui/key-actions.pwn"
#include "sss/core/ui/watch.pwn"
#include "sss/core/ui/keypad.pwn"
#include "sss/core/ui/body-preview.pwn"
#include "sss/core/ui/status.pwn"

// WORLD ENTITIES
#include "sss/core/world/fuel.pwn"
#include "sss/core/world/supply-crate.pwn"
#include "sss/core/world/weapons-cache.pwn"
#include "sss/core/world/loot.pwn"
#include "sss/core/world/item-tweak.pwn"

// ITEM TYPE CATEGORIES
#include "sss/core/itemtype/defences.pwn"
#include "sss/core/itemtype/furniture.pwn"
#include "sss/core/itemtype/liquid-container.pwn"
#include "sss/core/itemtype/machine.pwn"
#include "sss/core/itemtype/safebox.pwn"
#include "sss/core/itemtype/hats.pwn"
#include "sss/core/itemtype/backpack.pwn"
#include "sss/core/itemtype/medical.pwn"
#include "sss/core/itemtype/masks.pwn"
#include "sss/core/itemtype/holster.pwn"

// ITEMS
#include "sss/core/item/food.pwn"
#include "sss/core/item/firework.pwn"
#include "sss/core/item/shield.pwn"
#include "sss/core/item/handcuffs.pwn"
#include "sss/core/item/wheel.pwn"
#include "sss/core/item/headlight.pwn"
#include "sss/core/item/pills.pwn"
#include "sss/core/item/dice.pwn"
#include "sss/core/item/armour.pwn"
#include "sss/core/item/injector.pwn"
#include "sss/core/item/parachute.pwn"
#include "sss/core/item/molotov.pwn"
#include "sss/core/item/screwdriver.pwn"
#include "sss/core/item/torso.pwn"
#include "sss/core/item/campfire.pwn"
#include "sss/core/item/herpderp.pwn"
#include "sss/core/item/stungun.pwn"
#include "sss/core/item/note.pwn"
#include "sss/core/item/seedbag.pwn"
#include "sss/core/item/plantpot.pwn"
#include "sss/core/item/heartshapedbox.pwn"
#include "sss/core/item/fishingrod.pwn"
#include "sss/core/item/locator.pwn"
#include "sss/core/item/locker.pwn"
#include "sss/core/item/largeframe.pwn"
#include "sss/core/item/barbecue.pwn"
#include "sss/core/item/tent.pwn"
#include "sss/core/item/sign.pwn"
#include "sss/core/item/workbench.pwn"
#include "sss/core/item/scrap-machine.pwn"
#include "sss/core/item/refine-machine.pwn"
#include "sss/core/item/water-purifier.pwn"
#include "sss/core/item/plot-pole.pwn"

// ITEMS (HATS/MASKS/BAGS)
#include "sss/core/apparel/armyhelm.pwn"
#include "sss/core/apparel/cowboyhat.pwn"
#include "sss/core/apparel/truckcap.pwn"
#include "sss/core/apparel/boaterhat.pwn"
#include "sss/core/apparel/bowlerhat.pwn"
#include "sss/core/apparel/policecap.pwn"
#include "sss/core/apparel/tophat.pwn"
#include "sss/core/apparel/xmashat.pwn"
#include "sss/core/apparel/witcheshat.pwn"
#include "sss/core/apparel/policehelm.pwn"
#include "sss/core/apparel/zorromask.pwn"
#include "sss/core/apparel/gasmask.pwn"
#include "sss/core/apparel/hockeymask.pwn"
#include "sss/core/apparel/bandana.pwn"
#include "sss/core/apparel/Backpack.pwn"
#include "sss/core/apparel/Daypack.pwn"
#include "sss/core/apparel/HeartShapedBox.pwn"
#include "sss/core/apparel/LargeBackpack.pwn"
#include "sss/core/apparel/MediumBag.pwn"
#include "sss/core/apparel/ParaBag.pwn"
#include "sss/core/apparel/Rucksack.pwn"
#include "sss/core/apparel/Satchel.pwn"

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

// POST-CODE

#include "sss/core/player/save-load.pwn"
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
	print("[main] Finished initialising Southclaws' Scavenge and Survive");

	gServerInitialising = false;
	gServerInitialiseTick = GetTickCount();
	SetCrashDetectLongCallTime(5000);
	EnableCrashDetectLongCall();
}

/*
	This is called absolutely first before any other call.
*/
OnGameModeInit_Setup()
{
	print("[OnGameModeInit_Setup] Setting up...");

	// removed the file thing, so left this at the last version number for now.
	// probably needs a better method, like a build-time variable or something.
	new buildstring[12] = "1769";

	// file_read("BUILD_NUMBER", buildstring);
	gBuildNumber = strval(buildstring);

	if(gBuildNumber < 1000)
	{
		printf("UNKNOWN ERROR: gBuildNumber is below 1000: %d this should never happen! Ensure you've cloned the repository correctly.", gBuildNumber);
		for(;;){}
	}

	Logger_Log("Initialising Scavenge and Survive", Logger_I("build", gBuildNumber));

	Streamer_ToggleErrorCallback(true);

	if(Exists(DIRECTORY_SCRIPTFILES"SSS/"))
	{
		print("ERROR: ./scriptfiles directory detected using old directory structure, please see release notes for stable release #04");
		for(;;){}
	}

	if(!Exists(DIRECTORY_SCRIPTFILES))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES"' not found. Creating directory.");
		CreateDir(DIRECTORY_SCRIPTFILES);
	}

	if(!Exists(DIRECTORY_SCRIPTFILES DIRECTORY_MAIN))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_MAIN"' not found. Creating directory.");
		CreateDir(DIRECTORY_SCRIPTFILES DIRECTORY_MAIN);
	}

	gAccounts = db_open_persistent(ACCOUNT_DATABASE);

	LoadSettings();

	SendRconCommand(sprintf("mapname %s", GetMapName()));

	GetSettingInt("server/global-debug-level", 0, gGlobalDebugLevel);
	debug_set_level("global", gGlobalDebugLevel);

	RestartCount				=TextDrawCreate(410.000000, 10.000000, "Server Restart In:~n~00:00");
	TextDrawAlignment			(RestartCount, 2);
	TextDrawBackgroundColor		(RestartCount, 255);
	TextDrawFont				(RestartCount, 1);
	TextDrawLetterSize			(RestartCount, 0.400000, 1.600000);
	TextDrawColor				(RestartCount, -1);
	TextDrawSetOutline			(RestartCount, 1);
	TextDrawSetProportional		(RestartCount, 1);
}

public OnGameModeExit()
{
	print("[OnGameModeExit] Shutting down...");

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
	// Note: DO NOT CHANGE THIS STRING!
	print("[OnScriptExit] LAST_EXIT");
	return 1;
}

forward SetRestart(seconds);
public SetRestart(seconds)
{
	printf("Restarting server in: %ds", seconds);
	gServerUptime = gServerMaxUptime - seconds;
}

RestartGamemode()
{
	print("[RestartGamemode] Initialising gamemode restart...");
	gServerRestarting = true;

	foreach(new i : Player)
	{
		SavePlayerData(i);
		ResetVariables(i);
	}

	CloseSaveSessions();

	SendRconCommand("gmx");

	ChatMsgAll(BLUE, " ");
	ChatMsgAll(ORANGE, "Scavenge and Survive");
	ChatMsgAll(BLUE, "    Copyright (C) 2020 Barnaby \"Southclaws\" Keene");
	ChatMsgAll(BLUE, "    This Source Code Form is subject to the terms of the Mozilla Public");
	ChatMsgAll(BLUE, "    License, v. 2.0. If a copy of the MPL was not distributed with this");
	ChatMsgAll(BLUE, "    file, You can obtain one at http://mozilla.org/MPL/2.0/.");
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
				if(IsPlayerHudOn(i))
					TextDrawShowForPlayer(i, RestartCount);

				else
					TextDrawHideForPlayer(i, RestartCount);
			}
		}

		gServerUptime++;
	}

	HTTP(0, HTTP_GET, "localhost:7788/update", "", "OnUpdateCheck");
}

forward OnUpdateCheck(index, response_code, data[]);
public OnUpdateCheck(index, response_code, data[])
{
	if(response_code != 200)
		return;

	if(strlen(data) == 0)
		return;

	new status[8], time;
	if(sscanf(data, "s[8]d", status, time))
		return;

	if(strcmp(status, "update"))
		return;

	Logger_Log("updated amx ready to go", Logger_I("restart_seconds", time));
	SetRestart(time);
}

DirectoryCheck(const directory[])
{
	if(!Exists(directory))
	{
		Logger_Log("creating directory", Logger_S("directory", directory));
		CreateDir(directory);
	}
}

DatabaseTableCheck(DB:database, const tablename[], expectedcolumns)
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
		err("Table '%s' has %d columns, expected %d:", tablename, dbcolumns, expectedcolumns);

		// Put the server into a loop to stop it so the user can read the message.
		// It won't function correctly with bad databases anyway.
		for(;;){}
	}
}

public Streamer_OnPluginError(const error[])
{
	err(error);
}
