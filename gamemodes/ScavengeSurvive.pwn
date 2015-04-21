/*==============================================================================


	Southclaw's Scavenge and Survive

		Big thanks to Onfire559/Adam for the initial concept and developing
		the idea a lot long ago with some very productive discussions!
		Recently influenced by Minecraft and DayZ, credits to the creators of
		those games and their fundamental mechanics and concepts.


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

#include <sscanf2>					// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=120356
#include <YSI\y_utils>				// By Y_Less, 3.1:			http://forum.sa-mp.com/showthread.php?p=1696956
#include <YSI\y_va>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <YSI\y_iterate>
#include <YSI\y_ini>
#include <YSI\y_dialog>

#include "SS\Core\Server\Hooks.pwn"	// Internal library for hooking functions before they are used in external libraries.

#include <crashdetect>				// By Zeex					http://forum.sa-mp.com/showthread.php?t=262796
#include <streamer>					// By Incognito, 2.7:		http://forum.sa-mp.com/showthread.php?t=102865
#include <irc>						// By Incognito, 1.4.5:		http://forum.sa-mp.com/showthread.php?t=98803
#include <dns>						// By Incognito, 2.4:		http://forum.sa-mp.com/showthread.php?t=75605
#include <socket>					// By BlueG, v0.2b:			http://forum.sa-mp.com/showthread.php?t=333934
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
#include <a_json>					// By KingHual, 0.1.1:		http://forum.sa-mp.com/showthread.php?t=543919

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
#define SETTINGS_FILE				DIRECTORY_MAIN"settings.json"


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

new stock
		GLOBAL_DEBUG = -1;


/*==============================================================================

	Gamemode Scripts

==============================================================================*/


// API Pre
#tryinclude "ss/extensions/ext_pre.pwn"

// UTILITIES
#include "SS/utils/math.pwn"
#include "SS/utils/misc.pwn"
#include "SS/utils/time.pwn"
#include "SS/utils/camera.pwn"
#include "SS/utils/message.pwn"
#include "SS/utils/vehicle.pwn"
#include "SS/utils/vehicledata.pwn"
#include "SS/utils/vehicleparts.pwn"
#include "SS/utils/zones.pwn"
#include "SS/utils/player.pwn"
#include "SS/utils/object.pwn"
#include "SS/utils/tickcountfix.pwn"
#include "SS/utils/string.pwn"
#include "SS/utils/debug.pwn"

// SERVER CORE
#include "SS/Core/Server/Init.pwn"
#include "SS/Core/Server/Settings.pwn"
#include "SS/Core/Server/TextTags.pwn"
#include "SS/Core/Server/Weather.pwn"
#include "SS/Core/Server/SaveBlock.pwn"
#include "SS/Core/Server/ActivityLog.pwn"
#include "SS/Core/Server/FileCheck.pwn"
#include "SS/Core/Server/Sockets.pwn"
#include "SS/Core/Server/InfoMessage.pwn"

// UI
#include "SS/Core/UI/PlayerUI.pwn"
#include "SS/Core/UI/GlobalUI.pwn"
#include "SS/Core/UI/HoldAction.pwn"
#include "SS/Core/UI/Radio.pwn"
#include "SS/Core/UI/TipText.pwn"
#include "SS/Core/UI/KeyActions.pwn"
#include "SS/Core/UI/Watch.pwn"
#include "SS/Core/UI/Keypad.pwn"
#include "SS/Core/UI/DialogPages.pwn"
#include "SS/Core/UI/BodyPreview.pwn"

// VEHICLE
#include "SS/Core/Vehicle/VehicleType.pwn"
#include "SS/Core/Vehicle/Core.pwn"
#include "SS/Core/Vehicle/PlayerVehicle.pwn"
#include "SS/Core/Vehicle/LootVehicle.pwn"
#include "SS/Core/Vehicle/Spawn.pwn"
#include "SS/Core/Vehicle/Interact.pwn"
#include "SS/Core/Vehicle/Trunk.pwn"
#include "SS/Core/Vehicle/Repair.pwn"
#include "SS/Core/Vehicle/LockBreak.pwn"
#include "SS/Core/Vehicle/Locksmith.pwn"
#include "SS/Core/Vehicle/Carmour.pwn"
#include "SS/Core/Vehicle/Lock.pwn"
#include "SS/Core/Vehicle/AntiNinja.pwn"
#include "SS/Core/Vehicle/BikeCollision.pwn"
#include "SS/Core/Vehicle/Trailer.pwn"

// PLAYER INTERNAL SCRIPTS
#include "SS/Core/Player/Core.pwn"
#include "SS/Core/Player/Accounts.pwn"
#include "SS/Core/Player/Aliases.pwn"
#include "SS/Core/Player/ipv4-log.pwn"
#include "SS/Core/Player/gpci-log.pwn"
#include "SS/Core/Player/SaveLoad.pwn"
#include "SS/Core/Player/Spawn.pwn"
#include "SS/Core/Player/Damage.pwn"
#include "SS/Core/Player/Death.pwn"
#include "SS/Core/Player/Tutorial.pwn"
#include "SS/Core/Player/WelcomeMessage.pwn"
#include "SS/Core/Player/Chat.pwn"
#include "SS/Core/Player/CmdProcess.pwn"
#include "SS/Core/Player/Commands.pwn"
#include "SS/Core/Player/AfkCheck.pwn"
#include "SS/Core/Player/AltTabCheck.pwn"
#include "SS/Core/Player/DisallowActions.pwn"
#include "SS/Core/Player/ToolTips.pwn"
#include "SS/Core/Player/Whitelist.pwn"
#include "SS/Core/Player/IRC.pwn"
#include "SS/Core/Player/Country.pwn"

// CHARACTER SCRIPTS
#include "SS/Core/Char/Food.pwn"
#include "SS/Core/Char/Drugs.pwn"
#include "SS/Core/Char/Clothes.pwn"
#include "SS/Core/Char/Hats.pwn"
#include "SS/Core/Char/Inventory.pwn"
#include "SS/Core/Char/Animations.pwn"
#include "SS/Core/Char/MeleeItems.pwn"
#include "SS/Core/Char/KnockOut.pwn"
#include "SS/Core/Char/Disarm.pwn"
#include "SS/Core/Char/Overheat.pwn"
#include "SS/Core/Char/Holster.pwn"
#include "SS/Core/Char/Infection.pwn"
#include "SS/Core/Char/Backpack.pwn"
#include "SS/Core/Char/HandCuffs.pwn"
#include "SS/Core/Char/Medical.pwn"
#include "SS/Core/Char/AimShout.pwn"
#include "SS/Core/Char/Masks.pwn"
#include "SS/Core/Char/Bleed.pwn"

// WEAPON
#include "SS/Core/Weapon/ammunition.pwn"
#include "SS/Core/Weapon/core.pwn"
#include "SS/Core/Weapon/interact.pwn"
#include "SS/Core/Weapon/damage.core.pwn"
#include "SS/Core/Weapon/damage.firearm.pwn"
#include "SS/Core/Weapon/damage.melee.pwn"
#include "SS/Core/Weapon/damage.vehicle.pwn"
#include "SS/Core/Weapon/damage.explosive.pwn"
#include "SS/Core/Weapon/damage.world.pwn"
#include "SS/Core/Weapon/animset.pwn"
#include "SS/Core/Weapon/misc.pwn"
#include "SS/Core/Weapon/AntiCombatLog.pwn"
#include "SS/Core/Weapon/tracer.pwn"

// WORLD ENTITIES
#include "SS/Core/World/Fuel.pwn"
#include "SS/Core/World/Barbecue.pwn"
#include "SS/Core/World/Defences.pwn"
#include "SS/Core/World/GraveStone.pwn"
#include "SS/Core/World/SafeBox.pwn"
#include "SS/Core/World/Tent.pwn"
#include "SS/Core/World/Campfire.pwn"
#include "SS/Core/World/Workbench.pwn"
#include "SS/Core/World/Emp.pwn"
#include "SS/Core/World/Explosive.pwn"
#include "SS/Core/World/Sign.pwn"
#include "SS/Core/World/SupplyCrate.pwn"
#include "SS/Core/World/WeaponsCache.pwn"
#include "SS/Core/World/Loot.pwn"

// ADMINISTRATION TOOLS
#include "SS/Core/Admin/Report.pwn"
#include "SS/Core/Admin/Report_cmds.pwn"
#include "SS/Core/Admin/HackDetect.pwn"
#include "SS/Core/Admin/HackTrap.pwn"
#include "SS/Core/Admin/Ban.pwn"
#include "SS/Core/Admin/BanCommand.pwn"
#include "SS/Core/Admin/BanList.pwn"
#include "SS/Core/Admin/Spectate.pwn"
#include "SS/Core/Admin/Core.pwn"
#include "SS/Core/Admin/Level1.pwn"
#include "SS/Core/Admin/Level2.pwn"
#include "SS/Core/Admin/Level3.pwn"
#include "SS/Core/Admin/Level4.pwn"
#include "SS/Core/Admin/Level5.pwn"
#include "SS/Core/Admin/BugReport.pwn"
#include "SS/Core/Admin/detfield.pwn"
#include "SS/Core/Admin/detfield_cmds.pwn"
#include "SS/Core/Admin/detfield_draw.pwn"
#include "SS/Core/Admin/Mute.pwn"
#include "SS/Core/Admin/Rcon.pwn"
#include "SS/Core/Admin/Freeze.pwn"
#include "SS/Core/Admin/NameTags.pwn"
#include "SS/Core/Admin/FreeCam.pwn"
#include "SS/Core/Admin/PlayerList.pwn"

// ITEMS
#include "SS/Core/Item/Food.pwn"
#include "SS/Core/Item/firework.pwn"
#include "SS/Core/Item/bottle.pwn"
#include "SS/Core/Item/TntTimeBomb.pwn"
#include "SS/Core/Item/Sign.pwn"
#include "SS/Core/Item/shield.pwn"
#include "SS/Core/Item/HandCuffs.pwn"
#include "SS/Core/Item/wheel.pwn"
#include "SS/Core/Item/gascan.pwn"
#include "SS/Core/Item/armyhelm.pwn"
#include "SS/Core/Item/zorromask.pwn"
#include "SS/Core/Item/headlight.pwn"
#include "SS/Core/Item/pills.pwn"
#include "SS/Core/Item/dice.pwn"
#include "SS/Core/Item/armour.pwn"
#include "SS/Core/Item/injector.pwn"
#include "SS/Core/Item/TntPhoneBomb.pwn"
#include "SS/Core/Item/TntTripMine.pwn"
#include "SS/Core/Item/parachute.pwn"
#include "SS/Core/Item/molotov.pwn"
#include "SS/Core/Item/screwdriver.pwn"
#include "SS/Core/Item/torso.pwn"
#include "SS/Core/Item/ammotin.pwn"
#include "SS/Core/Item/tentpack.pwn"
#include "SS/Core/Item/campfire.pwn"
#include "SS/Core/Item/cowboyhat.pwn"
#include "SS/Core/Item/truckcap.pwn"
#include "SS/Core/Item/boaterhat.pwn"
#include "SS/Core/Item/bowlerhat.pwn"
#include "SS/Core/Item/policecap.pwn"
#include "SS/Core/Item/tophat.pwn"
#include "SS/Core/Item/herpderp.pwn"
#include "SS/Core/Item/TntProxMine.pwn"
#include "SS/Core/Item/IedTimebomb.pwn"
#include "SS/Core/Item/IedTripMine.pwn"
#include "SS/Core/Item/IedProxMine.pwn"
#include "SS/Core/Item/IedPhoneBomb.pwn"
#include "SS/Core/Item/EmpTimebomb.pwn"
#include "SS/Core/Item/EmpTripMine.pwn"
#include "SS/Core/Item/EmpProxMine.pwn"
#include "SS/Core/Item/EmpPhoneBomb.pwn"
#include "SS/Core/Item/GasMask.pwn"
#include "SS/Core/Item/HockeyMask.pwn"
#include "SS/Core/Item/XmasHat.pwn"
#include "SS/Core/Item/StunGun.pwn"
#include "SS/Core/Item/note.pwn"
#include "SS/Core/Item/SeedBag.pwn"
#include "SS/Core/Item/PlantPot.pwn"
#include "SS/Core/Item/HeartShapedBox.pwn"

// GAME DATA LOADING
#include "SS/Data/Loot.pwn"
#include "SS/Data/Vehicle.pwn"
//#include "SS/Data/Weapon.pwn"


// POST-CODE

#include "SS/Core/Server/Autosave.pwn"
#tryinclude "ss/extensions/ext_post.pwn"

// WORLD

#include "SS/World/World.pwn"

#if !defined gMapName
	#error World script MUST have a "gMapName" variable!
#endif

#if !defined GenerateSpawnPoint
	#error World script MUST have a "GenerateSpawnPoint" function!
#endif


main()
{
	print("\n\n/*==============================================================================\n\n");
	print("    Southclaw's Scavenge and Survive");
	print("\n\n==============================================================================*/\n\n");

	new itemtypename[ITM_MAX_NAME];

	for(new ItemType:i; i < ITM_MAX_TYPES; i++)
	{
		if(!IsValidItemType(i))
			break;

		if(GetItemTypeCount(i) == 0)
			continue;

		GetItemTypeUniqueName(i, itemtypename);

		printf("[%03d] Spawned %04d '%s'", _:i, GetItemTypeCount(i), itemtypename);
	}

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

	SendRconCommand(sprintf("mapname %s", gMapName));

	GetSettingInt("server/global-debug-level", 0, gGlobalDebugLevel);
	GLOBAL_DEBUG = debug_register_handler("GLOBAL", gGlobalDebugLevel);
}

public OnGameModeExit()
{
	print("\n[OnGameModeExit] Shutting down...");

	new File:f = fopen("nonexistentfile", io_read), _s[1];
	fread(f, _s);
	fclose(f);

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

	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, "-------------------------------------------------------------------------------------------------------------------------");
	MsgAll(YELLOW, " >  The Server Is Restarting, Please Wait...");
	MsgAll(BLUE, "-------------------------------------------------------------------------------------------------------------------------");
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
