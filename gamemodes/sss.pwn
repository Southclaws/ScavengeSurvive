/*==============================================================================


	Southclaw's Scavenge and Survive

		Big thanks to Onfire559/Adam for the initial concept and developing
		the idea a lot long ago with some very productive discussions!
		Recently influenced by Minecraft and DayZ, credits to the creators of
		those games and their fundamental mechanics and concepts.


==============================================================================*/


#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS	(32)

native IsValidVehicle(vehicleid);

#include <YSI\y_utils>				// By Y_Less:				http://forum.sa-mp.com/showthread.php?p=1696956
#include <YSI\y_va>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <YSI\y_iterate>

#include "../scripts/SSS/MovementDetection.pwn"

#include <formatex>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=313488
#include <strlib>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=362764
#include <md-sort>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=343172
#include <geoip>					// By Totto8492:			http://forum.sa-mp.com/showthread.php?t=32509
#include <sscanf2>					// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=120356
#include <streamer>					// By Incognito:			http://forum.sa-mp.com/showthread.php?t=102865
#include <CTime>					// By RyDeR:				http://forum.sa-mp.com/showthread.php?t=294054 - FIX: http://pastebin.com/zZ9bLs7K OR http://pastebin.com/2sJA38Kg
#include <IniFiles>					// By Southclaw:			http://forum.sa-mp.com/showthread.php?t=262795
#include <bar>						// By Torbido:				http://forum.sa-mp.com/showthread.php?t=113443
#include <playerbar>				// By Torbido/Southclaw:	http://pastebin.com/ZuLPd1K6
#include <rbits>					// By RyDeR:				http://forum.sa-mp.com/showthread.php?t=275142
#include <CameraMover>				// By Southclaw:			http://forum.sa-mp.com/showthread.php?t=329813
#include <FileManager>				// By JaTochNietDan:		http://forum.sa-mp.com/showthread.php?t=92246
#include <SIF/SIF>					// By Southclaw:			https://github.com/Southclaw/SIF
#include <WeaponData>				// By Southclaw:			http://pastebin.com/ZGTr32Fv


native WP_Hash(buffer[], len, const str[]);


//===================================================================Definitions


// Limits
#define MAX_MOTD_LEN				(128)
#define MAX_PLAYER_FILE				(MAX_PLAYER_NAME+16)
#define MAX_ADMIN					(16)
#define MAX_PASSWORD_LEN			(129)
#define MAX_SERVER_UPTIME			(25200)


// Files
#define PLAYER_DATA_FILE			"SSS/Player/%s.inv"
#define SPAWNS_DATA					"SSS/Spawns/%s.dat"
#define ACCOUNT_DATABASE			"SSS/Accounts.db"
#define SETTINGS_FILE				"SSS/Settings.txt"
#define ADMIN_DATA_FILE				"SSS/AdminList.txt"


// Database Rows
#define ROW_NAME					"name"
#define ROW_PASS					"pass"
#define ROW_GEND					"gend"
#define ROW_IPV4					"ipv4"
#define ROW_ALIVE					"alive"
#define ROW_SPAWN					"spawn"
#define ROW_ISVIP					"vip"
#define ROW_DATE					"date"
#define ROW_REAS					"reason"
#define ROW_BNBY					"by"


// Macros
#define t:%1<%2>					((%1)|=(%2))
#define f:%1<%2>					((%1)&=~(%2))

#define SetSpawn(%0,%1,%2,%3,%4)	SetSpawnInfo(%0, NO_TEAM, 0, %1, %2, %3, %4, 0,0,0,0,0,0)
#define GetFile(%0,%1)				format(%1, MAX_PLAYER_FILE, PLAYER_DATA_FILE, %0)

#define CMD:%1(%2)					forward cmd_%1(%2);\
									public cmd_%1(%2)

#define ACMD:%1[%2](%3)				forward cmd_%1_%2(%3);\
									public cmd_%1_%2(%3)

// Colours
#define YELLOW						0xFFFF00AA

#define RED							0xE85454AA
#define GREEN						0x33AA33AA
#define BLUE						0x33CCFFAA

#define ORANGE						0xFFAA00AA
#define GREY						0xAFAFAFAA
#define PINK						0xFFC0CBAA
#define NAVY						0x000080AA
#define GOLD						0xB8860BAA
#define LGREEN						0x00FD4DAA
#define TEAL						0x008080AA
#define BROWN						0xA52A2AAA
#define AQUA						0xF0F8FFAA

#define BLACK						0x000000AA
#define WHITE						0xFFFFFFAA


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


#define ATTACHSLOT_ITEM				(0)
#define ATTACHSLOT_BAG				(1)
#define ATTACHSLOT_USE				(2)
#define ATTACHSLOT_HOLSTER			(3)
#define ATTACHSLOT_HOLD				(4)
#define ATTACHSLOT_CUFFS			(5)
#define ATTACHSLOT_TORCH			(6)
#define ATTACHSLOT_HAT				(7)


#define KEYTEXT_INTERACT			"~k~~VEHICLE_ENTER_EXIT~"
#define KEYTEXT_PUT_AWAY			"~k~~CONVERSATION_YES~"
#define KEYTEXT_DROP_ITEM			"~k~~CONVERSATION_NO~"
#define KEYTEXT_INVENTORY			"~k~~GROUP_CONTROL_BWD~"
#define KEYTEXT_ENGINE				"~k~~CONVERSATION_YES~"
#define KEYTEXT_LIGHTS				"~k~~CONVERSATION_NO~"


enum
{
	DRUG_TYPE_ASPIRIN,		// Remove shaky screen
	DRUG_TYPE_PAINKILL,		// Add 10 HP, remove dark screen for 1 minute
	DRUG_TYPE_LSD,			// Weather effects
	DRUG_TYPE_AIR,			// Health loss and death
	DRUG_TYPE_MORPHINE,		// Shaky screen and health gain
	DRUG_TYPE_ADRENALINE,	// Slow health gain
	DRUG_TYPE_HEROINE		// Low visibility
}


//==============================================================SERVER VARIABLES


enum
{
	d_NULL,

// Internal Dialogs
	d_Login,
	d_Register,
	d_WelcomeMessage,

// External Dialogs
	d_NotebookPage,
	d_NotebookEdit,
	d_NotebookError,
	d_SignEdit,
	d_Tires,
	d_Lights,
	d_Radio,
	d_GraveStone
}


new HORIZONTAL_RULE[] = {"-------------------------------------------------------------------------------------------------------------------------"};

//=====================Player Tag Names
new const AdminName[4][14]=
{
	"Player",			// 0
	"Moderator",		// 1
	"Administrator",	// 2
	"Developer"			// 3
},
AdminColours[4]=
{
	0xFFFFFFFF,			// 0
	0x5DFC0AFF,			// 1
	0x33CCFFAA,			// 2
	0x6600FFFF			// 3
};


//=====================Server Global Settings
enum (<<=1)
{
	ChatLocked = 1,
	ServerLocked,
	Restarting
}
enum e_admin_data
{
	admin_Name[MAX_PLAYER_NAME],
	admin_Level
}


new
	bServerGlobalSettings,
	gServerUptime,
	gMessageOfTheDay[MAX_MOTD_LEN],
	gAdminData[MAX_ADMIN][e_admin_data],
	gTotalAdmins;

new
	skin_MainM,
	skin_MainF,

	skin_Civ1M,
	skin_Civ2M,
	skin_Civ3M,
	skin_Civ4M,
	skin_MechM,
	skin_BikeM,
	skin_ArmyM,
	skin_ClawM,
	skin_FreeM,

	skin_Civ1F,
	skin_Civ2F,
	skin_Civ3F,
	skin_Civ4F,
	skin_ArmyF,
	skin_IndiF;

new
	anim_Blunt,
	anim_Stab;


enum E_WEATHER_DATA
{
	weather_id,
	weather_name[24]
}
enum E_TIME_DATA
{
	time_hour,
	time_name[11]
}
new
	WeatherData[20][E_WEATHER_DATA]=
	{
		{0, "EXTRASUNNY_LS"},
		{1, "SUNNY_LS"},
		{2, "EXTRASUNNY_SMOG_LS"},
		{3, "SUNNY_SMOG_LS"},
		{4, "CLOUDY_LS"},

		{5, "SUNNY_SF"},
		{6, "EXTRASUNNY_SF"},
		{7, "CLOUDY_SF"},
		{8, "RAINY_SF"},
		{9, "FOGGY_SF"},

		{10, "SUNNY_LV"},
		{11, "EXTRASUNNY_LV"},
		{12, "CLOUDY_LV"},

		{13, "EXTRASUNNY_COUNTRYSIDE"},
		{14, "SUNNY_COUNTRYSIDE"},
		{15, "CLOUDY_COUNTRYSIDE"},
		{16, "RAINY_COUNTRYSIDE"},

		{17, "EXTRASUNNY_DESERT"},
		{18, "SUNNY_DESERT"},
		{19, "SANDSTORM_DESERT"}
	};

//=====================Loot Types
enum
{
	loot_Civilian,
	loot_Industrial,
	loot_Police,
	loot_Military,
	loot_Medical,
	loot_CarCivilian,
	loot_CarIndustrial,
	loot_CarPolice,
	loot_CarMilitary,
	loot_Survivor
}

//=====================Clock and Timers
new
				gWeatherID,
				gLastWeatherChange;

//=====================Menus and Textdraws
new
Text:			DeathText			= Text:INVALID_TEXT_DRAW,
Text:			DeathButton			= Text:INVALID_TEXT_DRAW,
Text:			ClockText			= Text:INVALID_TEXT_DRAW,
Text:			RestartCount		= Text:INVALID_TEXT_DRAW,
Text:			MapCover1			= Text:INVALID_TEXT_DRAW,
Text:			MapCover2			= Text:INVALID_TEXT_DRAW,
Text:			HitMark_centre		= Text:INVALID_TEXT_DRAW,
Text:			HitMark_offset		= Text:INVALID_TEXT_DRAW,

PlayerText:		ClassBackGround		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		ClassButtonMale		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		ClassButtonFemale	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		HungerBarBackground	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		HungerBarForeground	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		ToolTip				= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		HelpTipText			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleFuelText		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleDamageText	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleEngineText	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleNameText		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleSpeedText	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		AddHPText			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		AddScoreText		= PlayerText:INVALID_TEXT_DRAW,

PlayerBar:		TankHeatBar			= INVALID_PLAYER_BAR_ID,
PlayerBar:		ActionBar			= INVALID_PLAYER_BAR_ID,
PlayerBar:		KnockoutBar			= INVALID_PLAYER_BAR_ID,
				MiniMapOverlay;

//==============================================================PLAYER VARIABLES


enum (<<= 1) // 14
{
		HasAccount = 1,
		IsVip,
		LoggedIn,
		CanExitWelcome,
		AdminDuty,
		Gender,
		Alive,
		Dying,
		Spawned,
		FirstSpawn,
		HelpTips,
		ShowHUD,
		KnockedOut,
		Bleeding,

		HangingOutWindow,

		Frozen,
		Muted,

		DebugMode,
}
enum E_PLAYER_DATA
{
		ply_Password[MAX_PASSWORD_LEN],
		ply_Admin,
		ply_Skin,
		ply_IP,
Float:	ply_posX,
Float:	ply_posY,
Float:	ply_posZ,
Float:	ply_rotZ
}


new
DB:		gAccounts,
		IncorrectPass			[MAX_PLAYERS],
		Warnings				[MAX_PLAYERS],

		gPlayerData				[MAX_PLAYERS][E_PLAYER_DATA],
		bPlayerGameSettings		[MAX_PLAYERS],

		gPlayerName				[MAX_PLAYERS][MAX_PLAYER_NAME],
Float:	gPlayerHP				[MAX_PLAYERS],
Float:	gPlayerAP				[MAX_PLAYERS],
Float:	gPlayerFP				[MAX_PLAYERS],
		gPlayerArmedWeapon		[MAX_PLAYERS],
Float:	gPlayerFrequency		[MAX_PLAYERS],
		gPlayerVehicleID		[MAX_PLAYERS],
Float:	gPlayerVelocity			[MAX_PLAYERS],
Float:	gCurrentVelocity		[MAX_PLAYERS],

		gScreenBoxFadeLevel		[MAX_PLAYERS],
Timer:	gScreenFadeTimer		[MAX_PLAYERS],
Float:	gPlayerDeathPos			[MAX_PLAYERS][4],

		tick_WeaponHit			[MAX_PLAYERS],
		tick_ExitVehicle		[MAX_PLAYERS],
		tick_LastChatMessage	[MAX_PLAYERS],
		ChatMessageStreak		[MAX_PLAYERS],
		ChatMuteTick			[MAX_PLAYERS],

Float:	TankHeat				[MAX_PLAYERS],
Timer:	TankHeatUpdateTimer		[MAX_PLAYERS];


forward OnLoad();
forward SetRestart(seconds);


//======================Library Predefinitions

#define NOTEBOOK_FILE			"SSS/Notebook/%s.dat"
#define MAX_NOTEBOOK_FILE_NAME	(MAX_PLAYER_NAME + 18)

//======================Libraries of Functions

#include "../scripts/utils/math.pwn"
#include "../scripts/utils/misc.pwn"
#include "../scripts/utils/camera.pwn"
#include "../scripts/utils/message.pwn"
#include "../scripts/utils/vehicle.pwn"
#include "../scripts/utils/vehicledata.pwn"
#include "../scripts/utils/zones.pwn"

//======================Hooks

#include "../scripts/SSS/DisallowActions.pwn"
#include "../scripts/SSS/DataCollection.pwn"

//======================API Scripts

#include <SIF/Modules/Craft.pwn>
#include <SIF/Modules/Notebook.pwn>


#include "../scripts/API/Balloon/Balloon.pwn"
#include "../scripts/API/Checkpoint/Checkpoint.pwn"
#include "../scripts/API/Line/Line.pwn"
#include "../scripts/API/Zipline/Zipline.pwn"
#include "../scripts/API/Ladder/Ladder.pwn"
//#include "../scripts/API/Turret/Turret.pwn"
#include "../scripts/API/SprayTag/SprayTag.pwn"

#include "../scripts/Items/misc.pwn"
#include "../scripts/Items/firework.pwn"
#include "../scripts/Items/beer.pwn"
#include "../scripts/Items/timebomb.pwn"
#include "../scripts/Items/Sign.pwn"
#include "../scripts/Items/backpack.pwn"
#include "../scripts/Items/repair.pwn"
#include "../scripts/Items/shield.pwn"
#include "../scripts/Items/handcuffs.pwn"
#include "../scripts/Items/wheel.pwn"
#include "../scripts/Items/gascan.pwn"
#include "../scripts/Items/flashlight.pwn"
#include "../scripts/Items/armyhelm.pwn"
#include "../scripts/Items/crowbar.pwn"
#include "../scripts/Items/zorromask.pwn"
#include "../scripts/Items/headlight.pwn"
#include "../scripts/Items/pills.pwn"
#include "../scripts/Items/dice.pwn"
#include "../scripts/Items/armour.pwn"
#include "../scripts/Items/defenses.pwn"
#include "../scripts/Items/injector.pwn"
#include "../scripts/Items/medical.pwn"
#include "../scripts/Items/phonebomb.pwn"
#include "../scripts/Items/motionmine.pwn"
#include "../scripts/Items/parachute.pwn"

//======================Data Load and Setup

#include "../scripts/SSS/Spawns.pwn"
#include "../scripts/SSS/LootData.pwn"
#include "../scripts/SSS/LootSpawn.pwn"
#include "../scripts/SSS/HouseLoot.pwn"
#include "../scripts/SSS/VehicleData.pwn"
#include "../scripts/SSS/VehicleSpawn.pwn"

//======================Gameplay Mechanics

#include "../scripts/SSS/Weapons.pwn"
#include "../scripts/SSS/Vehicle.pwn"
#include "../scripts/SSS/Fuel.pwn"
#include "../scripts/SSS/Food.pwn"
#include "../scripts/SSS/Cooking.pwn"
#include "../scripts/SSS/Clothes.pwn"
#include "../scripts/SSS/Hats.pwn"
#include "../scripts/SSS/Inventory.pwn"
#include "../scripts/SSS/SafeBox.pwn"
#include "../scripts/SSS/SitDown.pwn"
#include "../scripts/SSS/Radio.pwn"
#include "../scripts/SSS/Defenses.pwn"
#include "../scripts/SSS/Drugs.pwn"
#include "../scripts/SSS/MeleeItems.pwn"
#include "../scripts/SSS/KnockOut.pwn"
#include "../scripts/SSS/GraveStone.pwn"

#include "../scripts/SSS/Tutorial.pwn"
#include "../scripts/SSS/WelcomeMessage.pwn"
#include "../scripts/SSS/TipText.pwn"
#include "../scripts/SSS/ToolTipEvents.pwn"
#include "../scripts/SSS/TextTags.pwn"

#include "../scripts/SSS/Cmds/Core.pwn"
#include "../scripts/SSS/Cmds/Commands.pwn"
#include "../scripts/SSS/Cmds/Moderator.pwn"
#include "../scripts/SSS/Cmds/Administrator.pwn"
#include "../scripts/SSS/Cmds/Dev.pwn"
#include "../scripts/SSS/Cmds/Duty.pwn"

//======================Map Scripts

#include "../scripts/SSS/Maps/santos.pwn"
#include "../scripts/SSS/Maps/fierro.pwn"
#include "../scripts/SSS/Maps/venturas.pwn"
#include "../scripts/SSS/Maps/redcounty.pwn"
#include "../scripts/SSS/Maps/flintcounty.pwn"
#include "../scripts/SSS/Maps/bonecounty.pwn"
#include "../scripts/SSS/Maps/robada.pwn"

#include "../scripts/SSS/Maps/LockboxLV.pwn"

#include "../scripts/SSS/Maps/Area69.pwn"
#include "../scripts/SSS/Maps/Ranch.pwn"
#include "../scripts/SSS/Maps/MtChill.pwn"


main()
{
	new
		DBResult:tmpResult,
		rowCount,
		tmpCurPass[MAX_PASSWORD_LEN],
		tmpName[MAX_PLAYER_NAME],
		tmpHashPass[MAX_PASSWORD_LEN],
		tmpQuery[512];

	gAccounts = db_open(ACCOUNT_DATABASE);

	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Player` (`"#ROW_NAME"`, `"#ROW_PASS"`, `"#ROW_IPV4"`, `"#ROW_ALIVE"`, `"#ROW_GEND"`, `"#ROW_SPAWN"`, `"#ROW_ISVIP"`)"));
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Bans` (`"#ROW_NAME"`, `"#ROW_IPV4"`, `"#ROW_DATE"`, `"#ROW_REAS"`, `"#ROW_BNBY"`)"));

	tmpResult = db_query(gAccounts, "SELECT * FROM `Player`");
	rowCount = db_num_rows(tmpResult);

	if(rowCount > 0)
	{
		for(new i;i<rowCount;i++)
		{
			db_get_field_assoc(tmpResult, #ROW_PASS, tmpCurPass, MAX_PASSWORD_LEN);
			db_get_field_assoc(tmpResult, #ROW_NAME, tmpName, MAX_PASSWORD_LEN);
			if(strlen(tmpCurPass) < 128)
			{
				WP_Hash(tmpHashPass, MAX_PASSWORD_LEN, tmpCurPass);

				format(tmpQuery, 512,
					"UPDATE `Player` SET `"#ROW_PASS"` = '%s' WHERE `"#ROW_NAME"` = '%s'",
					tmpHashPass, tmpName);

				db_free_result(db_query(gAccounts, tmpQuery));
			}
			db_next_row(tmpResult);
		}
	}
	db_free_result(tmpResult);


	file_Open(SETTINGS_FILE);

	print("\n-------------------------------------");
	print(" Southclaw's Scavenge And Survive");
	print("  ----  Server Data  ----");
	printf("   %d\t- Visitors",			file_GetVal("Connections"));
	printf("   %d\t- Accounts",			rowCount);
	printf("   %d\t- Administrators",	gTotalAdmins);
	print("-------------------------------------\n");

	file_Close();
}




























public OnGameModeInit()
{
	print("Starting Main Game Script 'SSS' ...");

	file_OS();
	SetGameModeText("Scavenge And Survive [BETA]");
	SetMapName("San Androcalypse");

	EnableStuntBonusForAll(false);
	ManualVehicleEngineAndLights();
	SetNameTagDrawDistance(1.0);
	UsePlayerPedAnims();
	AllowInteriorWeapons(true);
	DisableInteriorEnterExits();
	ShowNameTags(true);

	gWeatherID			= WeatherData[random(sizeof(WeatherData))][weather_id];
	gLastWeatherChange	= tickcount();

	MiniMapOverlay = GangZoneCreate(-6000, -6000, 6000, 6000);

	if(!fexist(SETTINGS_FILE))
		file_Create(SETTINGS_FILE);

	else
	{
		file_Open(SETTINGS_FILE);
		file_GetStr("motd", gMessageOfTheDay);
		file_Close();
	}

	if(!fexist(ADMIN_DATA_FILE))
		file_Create(ADMIN_DATA_FILE);

	else
	{
		new
			File:tmpFile = fopen(ADMIN_DATA_FILE, io_read),
			line[MAX_PLAYER_NAME + 4];

		while(fread(tmpFile, line))
		{
			sscanf(line, "p<=>s[24]d", gAdminData[gTotalAdmins][admin_Name], gAdminData[gTotalAdmins][admin_Level]);
			gTotalAdmins++;
		}
		fclose(tmpFile);
		SortDeepArray(gAdminData, admin_Level, .order = SORT_DESC);
	}

	item_Parachute		= DefineItemType("Parachute",		371,	ITEM_SIZE_MEDIUM,	90.0, 0.0, 0.0,			0.0,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000);
	item_Medkit			= DefineItemType("Medkit",			1580,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_HardDrive		= DefineItemType("Hard Drive",		328,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0);
	item_Key			= DefineItemType("Key",				327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);

	item_FireworkBox	= DefineItemType("Fireworks",		2039,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.096996, 0.044811, 0.035688, 4.759557, 255.625167, 0.000000);
	item_FireLighter	= DefineItemType("Lighter",			327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_timer			= DefineItemType("Timer Device",	19273,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0);
	item_explosive		= DefineItemType("Explosive",		1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_timebomb		= DefineItemType("Time Bomb",		1252,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0);
	item_battery		= DefineItemType("Battery",			2040,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082);
	item_fusebox		= DefineItemType("Fuse Box",		2038,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0);
	item_Beer			= DefineItemType("Beer",			1543,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.60376, 0.032063, -0.204802, 0.000000, 0.000000, 0.000000);
	item_Sign			= DefineItemType("Sign",			19471,	ITEM_SIZE_LARGE,	0.0, 0.0, 270.0,		0.0);
	item_Armour			= DefineItemType("Armour",			19515,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.300333, -0.090105, 0.000000, 0.000000, 0.000000, 180.000000);

	item_Bandage		= DefineItemType("Bandage",			1575,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_FishRod		= DefineItemType("Fishing Rod",		18632,	ITEM_SIZE_LARGE,	90.0, 0.0, 0.0,			0.0,	0.091496, 0.019614, 0.000000, 185.619995, 354.958374, 0.000000);
	item_Wrench			= DefineItemType("Wrench",			18633,	ITEM_SIZE_SMALL,	0.0, 90.0, 0.0,			0.0,	0.084695, -0.009181, 0.152275, 98.865089, 270.085449, 0.000000);
	item_Crowbar		= DefineItemType("Crowbar",			18634,	ITEM_SIZE_SMALL,	0.0, 90.0, 0.0,			0.0,	0.066177, 0.011153, 0.038410, 97.289527, 270.962554, 1.114514);
	item_Hammer			= DefineItemType("Hammer",			18635,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0,	0.000000, -0.008230, 0.000000, 6.428617, 0.000000, 0.000000);
	item_Shield			= DefineItemType("Shield",			18637,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	-0.262389, 0.016478, -0.151046, 103.597534, 6.474381, 38.321765);
	item_Flashlight		= DefineItemType("Flashlight",		18641,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.061910, 0.022700, 0.039052, 190.938354, 0.000000, 0.000000);
	item_Taser			= DefineItemType("Taser",			18642,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.079878, 0.014009, 0.029525, 180.000000, 0.000000, 0.000000);
	item_LaserPoint		= DefineItemType("Laser Pointer",	18643,	ITEM_SIZE_SMALL,	0.0, 0.0, 90.0,			0.0,	0.066244, 0.010838, -0.000024, 6.443027, 287.441467, 0.000000);
	item_Screwdriver	= DefineItemType("Screwdriver",		18644,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.099341, 0.021018, 0.009145, 193.644195, 0.000000, 0.000000);

	item_MobilePhone	= DefineItemType("Mobile Phone",	18865,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.103904, -0.003697, -0.015173, 94.655189, 184.031860, 0.000000);
	item_Pager			= DefineItemType("Pager",			18875,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.097277, 0.027625, 0.013023, 90.819244, 191.427993, 0.000000);
	item_Rake			= DefineItemType("Rake",			18890,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	-0.002599, 0.003984, 0.026356, 190.231231, 0.222518, 271.565185);
	item_HotDog			= DefineItemType("Hotdog",			19346,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.088718, 0.035828, 0.008570, 272.851745, 354.704772, 9.342185);
	item_EasterEgg		= DefineItemType("Easter Egg",		19345,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.000000, 0.000000, 0.000000, 0.000000, 90.000000, 0.000000);
	item_Cane			= DefineItemType("Cane",			19348,	ITEM_SIZE_MEDIUM,	270.0, 0.0, 0.0,		0.0,	0.041865, 0.022883, -0.079726, 4.967216, 10.411237, 0.000000);
	item_HandCuffs		= DefineItemType("Handcuffs",		19418,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0,	0.077635, 0.011612, 0.000000, 0.000000, 90.000000, 0.000000);
	item_Bucket			= DefineItemType("Bucket",			19468,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.293691, -0.074108, 0.020810, 148.961685, 280.067260, 151.782791);
	item_GasMask		= DefineItemType("Gas Mask",		19472,	ITEM_SIZE_SMALL,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000);
	item_Flag			= DefineItemType("Flag",			2993,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.045789, 0.026306, -0.078802, 8.777217, 0.272155, 0.000000);

	item_DoctorBag		= DefineItemType("Doctor's Bag",	1210,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 90.0,			0.0,	0.285915, 0.078406, -0.009429, 0.000000, 270.000000, 0.000000);
	item_Backpack		= DefineItemType("Backpack",		3026,	ITEM_SIZE_MEDIUM,	270.0, 0.0, 90.0,		0.0,	0.470918, 0.150153, 0.055384, 181.319580, 7.513789, 163.436065);
	item_Satchel		= DefineItemType("Small Bag",		363,	ITEM_SIZE_MEDIUM,	270.0, 0.0, 0.0,		0.0,	0.052853, 0.034967, -0.177413, 0.000000, 261.397491, 349.759826);
	item_Wheel			= DefineItemType("Wheel",			1079,	ITEM_SIZE_CARRY,	0.0, 0.0, 90.0,			0.436,	-0.098016, 0.356168, -0.309851, 258.455596, 346.618103, 354.313049);
	item_MotionSense	= DefineItemType("Motion Sensor",	327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.008151, 0.012682, -0.050635, 0.000000, 0.000000, 0.000000);
	item_CapCase		= DefineItemType("Cap Case",		1213,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.191558, 0.000000, 0.040402, 90.000000, 0.000000, 0.000000);
	item_MotionMine		= DefineItemType("Motion Mine",		1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_CapMine		= DefineItemType("Cap Mine",		1213,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.262021, 0.014938, 0.000000, 279.040191, 352.944946, 358.980987);
	item_Pizza			= DefineItemType("Pizza",			1582,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.320344, 0.064041, 0.168296, 92.941909, 358.492523, 14.915378);
	item_Burger			= DefineItemType("Burger",			2703,	ITEM_SIZE_SMALL,	-76.0, 257.0, -11.0,	0.0,	0.066739, 0.041782, 0.026828, 3.703052, 3.163064, 6.946474);

	item_BurgerBox		= DefineItemType("Burger",			2768,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.107883, 0.093265, 0.029676, 91.010627, 7.522015, 0.000000);
	item_Taco			= DefineItemType("Taco",			2769,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.069803, 0.057707, 0.039241, 0.000000, 78.877342, 0.000000);
	item_GasCan			= DefineItemType("Petrol Can",		1650,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.27,	0.143402, 0.027548, 0.063652, 0.000000, 253.648208, 0.000000);
	item_Clothes		= DefineItemType("Clothes",			2891,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_HelmArmy		= DefineItemType("Army Helmet",		19106,	ITEM_SIZE_MEDIUM,	345.0, 270.0, 0.0,		0.045);
	item_MediumBox		= DefineItemType("Box",				3014,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.1844,	-0.027872, 0.145617, -0.246524, 243.789840, 347.397491, 349.931610);
	item_SmallBox		= DefineItemType("Small Box",		3016,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.081998, 0.081005, -0.195033, 247.160079, 336.014343, 347.379638);
	item_AmmoBox		= DefineItemType("Ammo Box",		2358,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.114177, 0.089762, -0.173014, 247.160079, 354.746368, 79.219100);
	item_AmmoTin		= DefineItemType("Ammo Tin",		2040,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.114177, 0.094383, -0.174175, 252.006393, 354.746368, 167.069869);
	item_Meat			= DefineItemType("Meat",			2804,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	-0.051398, 0.017334, 0.189188, 270.495391, 353.340423, 167.069869);

	item_DeadLeg		= DefineItemType("Leg",				2905,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.147815, 0.052444, -0.164205, 253.163970, 358.857666, 167.069869);
	item_Torso			= DefineItemType("Torso",			2907,	ITEM_SIZE_CARRY,	0.0, 0.0, 270.0,		0.0,	0.087207, 0.093263, -0.280867, 253.355865, 355.971557, 175.203552);
	item_LongPlank		= DefineItemType("Plank",			2937,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.141491, 0.002142, -0.190920, 248.561920, 350.667724, 175.203552);
	item_GreenGloop		= DefineItemType("Unknown",			2976,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.063387, 0.013771, -0.595982, 341.793945, 352.972686, 226.892105);
	item_Capsule		= DefineItemType("Capsule",			3082,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.096439, 0.034642, -0.313377, 341.793945, 348.492706, 240.265777);
	item_RadioPole		= DefineItemType("Receiver",		3221,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777);
	item_SignShot		= DefineItemType("Sign",			3265,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777);
	item_Mailbox		= DefineItemType("Mailbox",			3407,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777);
	item_Pumpkin		= DefineItemType("Pumpkin",			19320,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.3,	0.105948, 0.279332, -0.253927, 246.858016, 0.000000, 0.000000);
	item_Nailbat		= DefineItemType("Nailbat",			2045,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0);

	item_ZorroMask		= DefineItemType("Zorro Mask",		18974,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.193932, 0.050861, 0.017257, 90.000000, 0.000000, 0.000000);
	item_Barbecue		= DefineItemType("BBQ",				1481,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0, 			0.6745,	0.106261, 0.004634, -0.144552, 246.614654, 345.892211, 258.267395);
	item_Headlight		= DefineItemType("Headlight",		19280,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.107282, 0.051477, 0.023807, 0.000000, 259.073913, 351.287475);
	item_Pills			= DefineItemType("Pills",			2709,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.09,	0.044038, 0.082106, 0.000000, 0.000000, 0.000000, 0.000000);
	item_AutoInjec		= DefineItemType("Injector",		2711,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.028,	0.145485, 0.020127, 0.034870, 0.000000, 260.512817, 349.967254);
	item_BurgerBag		= DefineItemType("Burger",			2663,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.205,	0.320356, 0.042146, 0.049817, 0.000000, 260.512817, 349.967254);
	item_CanDrink		= DefineItemType("Can",				2601,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.054,	0.064848, 0.059404, 0.017578, 0.000000, 359.136199, 30.178396);
	item_Detergent		= DefineItemType("Detergent",		1644,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.1,	0.081913, 0.047686, -0.026389, 95.526962, 0.546049, 358.890563);
	item_Dice			= DefineItemType("Dice",			1851,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.136,	0.031958, 0.131180, -0.214385, 69.012298, 16.103448, 10.308629);
	item_Dynamite		= DefineItemType("Dynamite",		1654,	ITEM_SIZE_MEDIUM);

	item_Door			= DefineItemType("Door",			1497,	ITEM_SIZE_CARRY,	90.0, 90.0, 0.0,		0.0,	0.313428, -0.507642, -1.340901, 336.984893, 348.837493, 113.141563);
	item_MetPanel		= DefineItemType("Metal Panel",		1965,	ITEM_SIZE_CARRY,	0.0, 90.0, 0.0,			0.0,	0.070050, 0.008440, -0.180277, 338.515014, 349.801025, 33.250347);
	item_SurfBoard		= DefineItemType("Surfboard",		2410,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	-0.033293, 0.167523, -0.333268, 79.455276, 123.749847, 77.635063);
	item_CrateDoor		= DefineItemType("Crate Door",		2678,	ITEM_SIZE_CARRY,	90.0, 90.0, 0.0,		0.0,	0.077393, 0.015846, -0.013984, 337.887634, 172.861953, 68.495330);
	item_CorPanel		= DefineItemType("Metal Sheet",		2904,	ITEM_SIZE_CARRY,	90.0, 90.0, 0.0,		0.0,	-0.365094, 1.004213, -0.665850, 337.887634, 172.861953, 68.495330);
	item_ShipDoor		= DefineItemType("Ship Door",		2944,	ITEM_SIZE_CARRY,	180.0, 90.0, 0.0,		0.0,	0.134831, -0.039784, -0.298796, 337.887634, 172.861953, 162.198867);
	item_MetalPlate		= DefineItemType("Metal Sheet",		2952,	ITEM_SIZE_CARRY,	180.0, 90.0, 0.0,		0.0,	-0.087715, 0.483874, 1.109397, 337.887634, 172.861953, 162.198867);
	item_MetalStand		= DefineItemType("Metal Plate",		2978,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	-0.106182, 0.534724, -0.363847, 278.598419, 68.350570, 57.954662);
	item_WoodDoor		= DefineItemType("Wood Panel",		3093,	ITEM_SIZE_CARRY,	0.0, 90.0, 0.0,			0.0,	0.117928, -0.025927, -0.203919, 339.650421, 168.808807, 337.216766);
	item_WoodPanel		= DefineItemType("Wood Panel",		5153,	ITEM_SIZE_CARRY,	360.209, 23.537, 0.0,	0.0,	-0.342762, 0.908910, -0.453703, 296.326019, 46.126548, 226.118209);

	item_Flare			= DefineItemType("Flare",			345,	ITEM_SIZE_SMALL);
	item_PhoneBomb		= DefineItemType("Phone Bomb",		1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_ParaBag		= DefineItemType("Parachute Bag",	371,	ITEM_SIZE_MEDIUM,	90.0, 0.0, 0.0,			0.0,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000);


	anim_Blunt = DefineAnimSet();
	AddAnimToSet(anim_Blunt, 17, 22, 7.0);
	AddAnimToSet(anim_Blunt, 18, 23, 9.0);
	AddAnimToSet(anim_Blunt, 19, 24, 11.0);

	anim_Stab = DefineAnimSet();
	AddAnimToSet(anim_Stab, 751, 756, 37.8);

	SetItemAnimSet(item_Wrench,			anim_Blunt);
	SetItemAnimSet(item_Crowbar,		anim_Blunt);
	SetItemAnimSet(item_Hammer,			anim_Blunt);
	SetItemAnimSet(item_Rake,			anim_Blunt);
	SetItemAnimSet(item_Cane,			anim_Blunt);
	SetItemAnimSet(item_Taser,			anim_Stab);
	SetItemAnimSet(item_Screwdriver,	anim_Stab);


	DefineFoodItem(item_HotDog,			30.0);
	DefineFoodItem(item_Pizza,			60.0);
	DefineFoodItem(item_Burger,			35.0);
	DefineFoodItem(item_BurgerBox,		35.0);
	DefineFoodItem(item_Taco,			30.0);
	DefineFoodItem(item_BurgerBag,		45.0);


	DefineItemCombo(item_timer,				item_explosive,		item_timebomb);
	DefineItemCombo(item_explosive,			item_MotionSense,	item_MotionMine);
	DefineItemCombo(item_Medkit,			item_Bandage,		item_DoctorBag);
	DefineItemCombo(item_MobilePhone,		item_explosive,		item_PhoneBomb);
	DefineItemCombo(ItemType:4,				item_Parachute,		item_ParaBag,		.returnitem1 = 0, .returnitem2 = 1);


	DefineLootIndex(loot_Civilian);
	DefineLootIndex(loot_Industrial);
	DefineLootIndex(loot_Police);
	DefineLootIndex(loot_Military);
	DefineLootIndex(loot_Medical);
	DefineLootIndex(loot_CarCivilian);
	DefineLootIndex(loot_CarIndustrial);
	DefineLootIndex(loot_CarPolice);
	DefineLootIndex(loot_CarMilitary);
	DefineLootIndex(loot_Survivor);


	skin_MainM	= DefineSkinItem(60,	"Civilian",			1, 0.0);
	skin_MainF	= DefineSkinItem(192,	"Civilian",			0, 0.0);

	skin_Civ1M	= DefineSkinItem(170,	"Civilian",			1, 1.0);
	skin_Civ2M	= DefineSkinItem(188,	"Civilian",			1, 1.0);
	skin_Civ3M	= DefineSkinItem(44,	"Civilian",			1, 1.0);
	skin_Civ4M	= DefineSkinItem(206,	"Civilian",			1, 1.0);
	skin_MechM	= DefineSkinItem(50,	"Mechanic",			1, 0.6);
	skin_BikeM	= DefineSkinItem(254,	"Biker",			1, 0.3);
	skin_ArmyM	= DefineSkinItem(287,	"Military",			1, 0.2);
	skin_ClawM	= DefineSkinItem(101,	"Southclaw",		1, 0.1);
	skin_FreeM	= DefineSkinItem(156,	"Morgan Freeman",	1, 0.01);

	skin_Civ1F	= DefineSkinItem(65,	"Civilian",			0, 0.8);
	skin_Civ2F	= DefineSkinItem(93,	"Civilian",			0, 0.8);
	skin_Civ3F	= DefineSkinItem(233,	"Civilian",			0, 0.8);
	skin_Civ4F	= DefineSkinItem(193,	"Civilian",			0, 0.8);
	skin_ArmyF	= DefineSkinItem(191,	"Military",			0, 0.2);
	skin_IndiF	= DefineSkinItem(131,	"Indian",			0, 0.1);

	DefineSafeboxType("Box", 			item_MediumBox,		6, 6, 3, 2);
	DefineSafeboxType("Small Box", 		item_SmallBox,		4, 2, 1, 0);
	DefineSafeboxType("Ammo Box", 		item_AmmoBox,		6, 6, 4, 0);
	DefineSafeboxType("Ammo Tin", 		item_AmmoTin,		2, 2, 0, 0);
	DefineSafeboxType("Capsule", 		item_Capsule,		2, 2, 0, 0);

	CallLocalFunction("OnLoad", "");

	LoadVehicles();
	LoadTextDraws();
	LoadSafeboxes();
	LoadDefenses();


	for(new i; i < MAX_PLAYERS; i++)
	{
		ResetVariables(i);
	}

	return 1;
}
public OnGameModeExit()
{
	SaveAllSafeboxes(true);
	UnloadVehicles();
	SaveAllDefenses();

	db_close(gAccounts);

	return 1;
}
public SetRestart(seconds)
{
	printf("Restarting server in: %ds", seconds);
	gServerUptime = MAX_SERVER_UPTIME - seconds;
}

RestartGamemode()
{
	foreach(new i : Player)
	{
		SavePlayerData(i, true);
		ResetVariables(i);
	}

	t:bServerGlobalSettings<Restarting>;
	SendRconCommand("gmx");

	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, HORIZONTAL_RULE);
	MsgAll(YELLOW, " >  The Server Is Restarting, Please Wait...");
	MsgAll(BLUE, HORIZONTAL_RULE);
}

task AutoSave[60000]()
{
	if(Iter_Count(Player) == 0)
		return;

	foreach(new i : Player)
	{
		SavePlayerData(i, false);
	}

	defer AutoSave_Safeboxes();
}

timer AutoSave_Safeboxes[250]()
{
	SaveAllSafeboxes(false);

	defer AutoSave_Vehicles();
}

timer AutoSave_Vehicles[250]()
{
	for(new i; i < MAX_VEHICLES; i++)
	{
		if(IsValidVehicle(i))
		{
			if(!isnull(gVehicleOwner[i]))
				SavePlayerVehicle(i, gVehicleOwner[i], false);
		}
	}
	defer AutoSave_Defenses();
}

timer AutoSave_Defenses[250]()
{
	SaveAllDefenses();
}


task GameUpdate[1000]()
{
	if(gServerUptime > MAX_SERVER_UPTIME)
	{
		RestartGamemode();
	}

	if(gServerUptime > MAX_SERVER_UPTIME - 3600)
	{
		new str[36];
		format(str, 36, "Server Restarting In:~n~%02d:%02d", (MAX_SERVER_UPTIME - gServerUptime) / 60, (MAX_SERVER_UPTIME - gServerUptime) % 60);
		TextDrawSetString(RestartCount, str);
		TextDrawShowForAll(RestartCount);
	}

	gServerUptime++;

	new
		str[6],
		hour,
		minute,
		weather;

	gettime(hour, minute);

	format(str, 6, "%02d:%02d", hour, minute);
	TextDrawSetString(ClockText, str);

	if(tickcount() - gLastWeatherChange > 600000 && random(100) < 5)
	{
		gLastWeatherChange = tickcount();
		gWeatherID = WeatherData[random(sizeof(WeatherData))][weather_id];
	}

	foreach(new i : Player)
	{
		if(IsPlayerUnderDrugEffect(i, DRUG_TYPE_LSD))
		{
			hour = 22;
			minute = 3;
			weather = 33;

			if(tickcount() - GetPlayerDrugUseTick(i, DRUG_TYPE_LSD) > 120000)
				RemoveDrug(i, DRUG_TYPE_LSD);
		}
		else if(IsPlayerUnderDrugEffect(i, DRUG_TYPE_HEROINE))
		{
			hour = 22;
			minute = 30;
			weather = 33;

			if(tickcount() - GetPlayerDrugUseTick(i, DRUG_TYPE_HEROINE) > 120000)
				RemoveDrug(i, DRUG_TYPE_HEROINE);
		}
		else
		{
			weather = WeatherData[gWeatherID][weather_id];
		}

		SetPlayerTime(i, hour, minute);
		SetPlayerWeather(i, weather);
	}
}

task GlobalAnnouncement[600000]()
{
	MsgAll(YELLOW, " >  Confused? Check out the Wiki: "#C_ORANGE"scavenge-survive.wikia.com "#C_YELLOW"or: "#C_ORANGE"empire-bay.com");
}

ptask PlayerUpdate[100](playerid)
{
	if(GetPlayerPing(playerid) > 350)
	{
		MsgF(playerid, YELLOW, " >  You have been kicked for having a ping of %d which is over the limit of 350.", GetPlayerPing(playerid));
		Kick(playerid);
		return;
	}

	ResetPlayerMoney(playerid);

	if(IsPlayerInAnyVehicle(playerid))
	{
		new
			vehicleid = GetPlayerVehicleID(playerid),
			model = GetVehicleModel(vehicleid),
			Float:health;

		if(GetVehicleType(model) != VTYPE_BMX && model != 0)
		{
			GetVehicleHealth(vehicleid, health);

			if(300.0 < health < 500.0)
			{
				if(VehicleEngineState(vehicleid) && gPlayerVelocity[playerid] > 30.0)
				{
					if(random(100) < (50 - ((health - 400.0) / 4)))
					{
						if(health < 400.0)
							VehicleEngineState(vehicleid, 0);
		
						SetVehicleHealth(vehicleid, health - (((200 - (health - 300.0)) / 100.0) / 2.0));
					}
				}
				else
				{
					if(random(100) < 100 - (50 - ((health - 400.0) / 4)))
					{
						if(health < 400.0)
							VehicleEngineState(vehicleid, 1);
					}
				}
			}
			if(VehicleEngineState(vehicleid) && VehicleFuelData[model - 400][veh_maxFuel] > 0.0)
			{
				if(health < 300.0 || gVehicleFuel[vehicleid] <= 0.0)
				{
					VehicleEngineState(vehicleid, 0);
					PlayerTextDrawColor(playerid, VehicleEngineText, RED);
				}
				else
				{
					if(gVehicleFuel[vehicleid] > 0.0)
					{
						gVehicleFuel[vehicleid] -= ((VehicleFuelData[model - 400][veh_fuelCons] / 100) * (((gPlayerVelocity[playerid]/60)/60)/10) + 0.0001);
					}

					if(tickcount() - tick_ExitVehicle[playerid] > 3000 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
						SetPlayerArmedWeapon(playerid, 0);

					PlayerTextDrawColor(playerid, VehicleEngineText, YELLOW);
				}
			}
			else
			{
				PlayerTextDrawColor(playerid, VehicleEngineText, RED);
			}

			new str[18];
			format(str, 18, "%.2fL/%.2f", gVehicleFuel[vehicleid], VehicleFuelData[model - 400][veh_maxFuel]);
			PlayerTextDrawSetString(playerid, VehicleFuelText, str);

			PlayerTextDrawColor(playerid, VehicleDamageText, (255 << 24 | floatround(health * 0.256) << 16 | floatround(health * 0.256) << 8 | 255));

			PlayerTextDrawShow(playerid, VehicleFuelText);
			PlayerTextDrawShow(playerid, VehicleDamageText);
			PlayerTextDrawShow(playerid, VehicleEngineText);

			if(floatabs(gCurrentVelocity[playerid] - gPlayerVelocity[playerid]) > ((GetVehicleType(model) == VTYPE_BMX) ? 35.0 : 30.0))
			{
				GivePlayerHP(playerid, -(floatabs(gCurrentVelocity[playerid] - gPlayerVelocity[playerid]) * 0.2));
			}

			gCurrentVelocity[playerid] = gPlayerVelocity[playerid];
		}
	}

	if(gScreenBoxFadeLevel[playerid] <= 0)
	{
		if(gPlayerHP[playerid] < 40.0 || IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_LSD) || IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_HEROINE))
		{
			if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_PAINKILL))
			{
				PlayerTextDrawHide(playerid, ClassBackGround);

				if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_PAINKILL) > 60000)
					RemoveDrug(playerid, DRUG_TYPE_PAINKILL);
			}
			else if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
			{
				PlayerTextDrawHide(playerid, ClassBackGround);
			}
			else
			{
				PlayerTextDrawBoxColor(playerid, ClassBackGround, floatround((40.0 - gPlayerHP[playerid]) * 4.4));
				PlayerTextDrawShow(playerid, ClassBackGround);
			}
		}
		else
		{
			PlayerTextDrawHide(playerid, ClassBackGround);
		}
	}

	KnockOutUpdate(playerid);

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
	{
		SetPlayerDrunkLevel(playerid, 100000);

		if(random(100) < 50)
			GivePlayerHP(playerid, -0.5);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE))
	{
		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_MORPHINE) > 120000 || gPlayerHP[playerid] >= 100.0)
			RemoveDrug(playerid, DRUG_TYPE_MORPHINE);

		SetPlayerDrunkLevel(playerid, 2200);

		if(random(100) < 80)
			GivePlayerHP(playerid, 0.05, .msg = false);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
	{
		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_ADRENALINE) > 120000 || gPlayerHP[playerid] >= 100.0)
			RemoveDrug(playerid, DRUG_TYPE_ADRENALINE);

		GivePlayerHP(playerid, 0.01, .msg = false);
	}

	if(bPlayerGameSettings[playerid] & Bleeding)
	{
		if(random(100) < 60)
			GivePlayerHP(playerid, -0.01, .msg = false);
	}

	if(gPlayerArmedWeapon[playerid] == 0 && GetPlayerWeapon(playerid))
	{
		ResetPlayerWeapons(playerid);
	}

	return;
}

ptask FoodUpdate[1000](playerid)
{
	new animidx = GetPlayerAnimationIndex(playerid);

	if(animidx == 43) // Sitting
	{
		gPlayerFP[playerid] -= 0.00001;
	}
	else if(animidx == 1159) // Crouching
	{
		gPlayerFP[playerid] -= 0.0003;
	}
	else if(animidx == 1195) // Jumping
	{
		gPlayerFP[playerid] -= 0.0022;	
	}
	else if(animidx == 1231) // Running
	{
		gPlayerFP[playerid] -= 0.0008;
	}
	else // Idle
	{
		new k, ud, lr;
		GetPlayerKeys(playerid, k, ud, lr);

		if(k & KEY_WALK) // Walking
		{
			gPlayerFP[playerid] -= 0.0001;
		}
		else if(k & KEY_SPRINT) // Sprinting
		{
			gPlayerFP[playerid] -= 0.0012;
		}
		else if(k & KEY_JUMP) // Jump
		{
			gPlayerFP[playerid] -= 0.0022;
		}
		else // Anything else
		{
			gPlayerFP[playerid] -= 0.0005;
		}
	}

	if(gPlayerFP[playerid] > 100.0)
		gPlayerFP[playerid] = 100.0;

	if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE) && !IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
	{
		if(gPlayerFP[playerid] < 30.0)
		{
			if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ASPIRIN))
			{
				SetPlayerDrunkLevel(playerid, 0);

				if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_ASPIRIN) > 120000)
					RemoveDrug(playerid, DRUG_TYPE_ASPIRIN);
			}
			else
			{
				SetPlayerDrunkLevel(playerid, 2000 + floatround((31.0 - gPlayerFP[playerid]) * 300.0));
			}
		}
		else
		{
			SetPlayerDrunkLevel(playerid, 0);
		}
	}

	if(gPlayerFP[playerid] < 20.0)
		gPlayerHP[playerid] -= (20.0 - gPlayerFP[playerid]) / 10.0;

	if(gPlayerFP[playerid] < 0.0)
		gPlayerFP[playerid] = 0.0;

	if(bPlayerGameSettings[playerid] & ShowHUD)
	{
		PlayerTextDrawLetterSize(playerid, HungerBarForeground, 0.500000, -(gPlayerFP[playerid] / 10.0));
		PlayerTextDrawShow(playerid, HungerBarBackground);
		PlayerTextDrawShow(playerid, HungerBarForeground);
	}
}

timer TankHeatUpdate[100](playerid)
{
	if(GetVehicleModel(GetPlayerVehicleID(playerid)) != 432)stop TankHeatUpdateTimer[playerid];

	if(TankHeat[playerid]>0.0)TankHeat[playerid]-=1.0;
	SetPlayerProgressBarMaxValue(playerid, TankHeatBar, 30.0);
	SetPlayerProgressBarValue(playerid, TankHeatBar, TankHeat[playerid]);
	UpdatePlayerProgressBar(playerid, TankHeatBar);
}

public OnPlayerConnect(playerid)
{
	SetPlayerColor(playerid, 0xB8B8B800);
	SetPlayerWeather(playerid, WeatherData[gWeatherID][weather_id]);
	GetPlayerName(playerid, gPlayerName[playerid], MAX_PLAYER_NAME);

	if(IsPlayerNPC(playerid))return 1;

	new
		tmpadminlvl,
		tmpIP[16],
		tmpByte[4],
		tmpCountry[32],
		tmpQuery[128],
		DBResult:tmpResult;

	GetPlayerIp(playerid, tmpIP, 16);

	sscanf(tmpIP, "p<.>a<d>[4]", tmpByte);
	gPlayerData[playerid][ply_IP] = ((tmpByte[0] << 24) | (tmpByte[1] << 16) | (tmpByte[2] << 8) | tmpByte[3]) ;

	format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Bans` WHERE `"#ROW_NAME"` = '%s' OR `"#ROW_IPV4"` = %d",
		gPlayerName[playerid], gPlayerData[playerid][ply_IP]);

	tmpResult = db_query(gAccounts, tmpQuery);
	
	if(db_num_rows(tmpResult) > 0)
	{
		new
			str[256],
			tmptime[12],
			tm<timestamp>,
			timestampstr[64],
			reason[64],
			bannedby[24];

		db_get_field(tmpResult, 2, tmptime, 12);
		db_get_field(tmpResult, 3, reason, 64);
		db_get_field(tmpResult, 4, bannedby, 24);
		
		localtime(Time:strval(tmptime), timestamp);
		strftime(timestampstr, 64, "%A %b %d %Y at %X", timestamp);

		format(str, 256, "\
			"#C_YELLOW"Date:\n\t\t"#C_BLUE"%s\n\n\n\
			"#C_YELLOW"By:\n\t\t"#C_BLUE"%s\n\n\n\
			"#C_YELLOW"Reason:\n\t\t"#C_BLUE"%s", timestampstr, reason, bannedby);

		ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Banned", str, "Close", "");

		Kick(playerid);
		return 1;
	}

	for(new idx; idx<gTotalAdmins; idx++)
	{
		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]))
		{
			tmpadminlvl = gAdminData[idx][admin_Level];
			if(tmpadminlvl > 3) tmpadminlvl = 3;
			break;
		}
	}

	format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Player` WHERE `"#ROW_NAME"` = '%s'", gPlayerName[playerid]);
	tmpResult = db_query(gAccounts, tmpQuery);

	ResetVariables(playerid);

	if(gPlayerData[playerid][ply_IP] == 2130706433)
		tmpCountry = "Localhost";

	else
		GetCountryName(tmpIP, tmpCountry);
	
	if(isnull(tmpCountry))tmpCountry = "Unknown";

	TextDrawShowForPlayer(playerid, ClockText);

	if(db_num_rows(tmpResult) >= 1)
	{
		new
			tmpField[50],
			dbIP;

		db_get_field_assoc(tmpResult, #ROW_PASS, gPlayerData[playerid][ply_Password], MAX_PASSWORD_LEN);

		db_get_field_assoc(tmpResult, #ROW_GEND, tmpField, 2);

		if(strval(tmpField) == 0)
		{
			f:bPlayerGameSettings[playerid]<Gender>;
		}
		else
		{
			t:bPlayerGameSettings[playerid]<Gender>;
		}

		db_get_field_assoc(tmpResult, #ROW_IPV4, tmpField, 12);
		dbIP = strval(tmpField);

		db_get_field_assoc(tmpResult, #ROW_ALIVE, tmpField, 2);

		if(tmpField[0] == '1')
			t:bPlayerGameSettings[playerid]<Alive>;

		else
			f:bPlayerGameSettings[playerid]<Alive>;

		db_get_field_assoc(tmpResult, #ROW_SPAWN, tmpField, 50);
		sscanf(tmpField, "ffff",
			gPlayerData[playerid][ply_posX],
			gPlayerData[playerid][ply_posY],
			gPlayerData[playerid][ply_posZ],
			gPlayerData[playerid][ply_rotZ]);

		db_get_field_assoc(tmpResult, #ROW_ISVIP, tmpField, 2);

		if(tmpField[0] == '1')
			t:bPlayerGameSettings[playerid]<IsVip>;

		else
			f:bPlayerGameSettings[playerid]<IsVip>;

		t:bPlayerGameSettings[playerid]<HasAccount>;

		if(gPlayerData[playerid][ply_IP] == dbIP)
			Login(playerid);

		else
		{
			new str[128];
			format(str, 128, ""C_WHITE"Welcome Back %P"#C_WHITE", Please log into to your account below!\n\n"#C_YELLOW"Enjoy your stay :)", playerid);
			ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Leave");
		}
	}
	else
	{
		new str[150];
		format(str, 150, ""#C_WHITE"Hello %P"#C_WHITE", You must be new here!\nPlease create an account by entering a "#C_BLUE"password"#C_WHITE" below:", playerid);
		ShowPlayerDialog(playerid, d_Register, DIALOG_STYLE_PASSWORD, "Register For A New Account", str, "Accept", "Leave");
	}
	if(bServerGlobalSettings & ServerLocked)
	{
		Msg(playerid, RED, " >  Server Locked by an admin "#C_WHITE"- Please try again soon.");
		MsgAdminsF(1, RED, " >  %s attempted to join the server while it was locked.", gPlayerName[playerid]);
		Kick(playerid);
		return false;
	}

	MsgAllF(WHITE, " >  %P (%d)"#C_WHITE" has joined [Country: %s]", playerid, playerid, tmpCountry);

	CheckForExtraAccounts(playerid, gPlayerName[playerid]);

	SetAllWeaponSkills(playerid, 500);
	LoadPlayerTextDraws(playerid);
	SetPlayerScore(playerid, 0);
	Streamer_ToggleIdleUpdate(playerid, true);


	db_free_result(tmpResult);

	file_Open(SETTINGS_FILE);
	file_IncVal("Connections", 1);
	file_Save(SETTINGS_FILE);
	file_Close();

	t:bPlayerGameSettings[playerid]<HelpTips>;
	t:bPlayerGameSettings[playerid]<ShowHUD>;

	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);
	SpawnPlayer(playerid);

	MsgF(playerid, YELLOW, " >  MoTD: "#C_BLUE"%s", gMessageOfTheDay);

	return 1;
}

CheckForExtraAccounts(playerid, name[])
{
	new
		rowCount,
		tmpIpQuery[128],
		tmpIpField[32],
		DBResult:tmpIpResult,
		tmpNameList[128];

	format(tmpIpQuery, 128,
		"SELECT * FROM `Player` WHERE `"#ROW_IPV4"` = '%d' AND `"#ROW_NAME"` != '%s'",
		gPlayerData[playerid][ply_IP], name);

	tmpIpResult = db_query(gAccounts, tmpIpQuery);

	rowCount = db_num_rows(tmpIpResult);

	if(rowCount > 0)
	{
		for(new i;i<rowCount && i < 5;i++)
		{
			db_get_field(tmpIpResult, 0, tmpIpField, 128);
			if(i>0)strcat(tmpNameList, ", ");
			strcat(tmpNameList, tmpIpField);
			db_next_row(tmpIpResult);
		}
		MsgAdminsF(1, YELLOW, " >  Aliases: "#C_BLUE"(%d)"#C_ORANGE" %s", rowCount, tmpNameList);
	}
	db_free_result(tmpIpResult);
}
public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid))return 1;

	t:bPlayerGameSettings[playerid]<FirstSpawn>;

	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);

	return 0;
}
public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid))return 1;

	t:bPlayerGameSettings[playerid]<FirstSpawn>;

	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);

	return 1;
}


CreateNewUserfile(playerid, password[])
{
	new
		file[MAX_PLAYER_FILE],
		tmpQuery[300];

	GetFile(gPlayerName[playerid], file);

	fclose(fopen(file, io_write));

	format(tmpQuery, 300,
		"INSERT INTO `Player` (`"#ROW_NAME"`, `"#ROW_PASS"`, `"#ROW_IPV4"`, `"#ROW_ALIVE"`, `"#ROW_SPAWN"`, `"#ROW_ISVIP"`) \
		VALUES('%s', '%s', '%d', '0', '0.0, 0.0, 0.0, 0.0', '%d')",
		gPlayerName[playerid], password, gPlayerData[playerid][ply_IP],
		(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0);

	db_free_result(db_query(gAccounts, tmpQuery));

	for(new idx; idx<gTotalAdmins; idx++)
	{
		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]) && !isnull(gPlayerName[playerid]))
		{
			gPlayerData[playerid][ply_Admin] = gAdminData[idx][admin_Level];
			break;
		}
	}

	if(gPlayerData[playerid][ply_Admin] > 0)
		MsgF(playerid, BLUE, " >  Your admin level: %d", gPlayerData[playerid][ply_Admin]);

	t:bPlayerGameSettings[playerid]<LoggedIn>;
	t:bPlayerGameSettings[playerid]<HasAccount>;
}

Login(playerid)
{
	new
		tmpQuery[256];

	format(tmpQuery, sizeof(tmpQuery), "UPDATE `Player` SET `"#ROW_IPV4"` = '%d' WHERE `"#ROW_NAME"` = '%s'", gPlayerData[playerid][ply_IP], gPlayerName[playerid]);
	db_free_result(db_query(gAccounts, tmpQuery));

	for(new idx; idx<gTotalAdmins; idx++)
	{

		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]))
		{
			gPlayerData[playerid][ply_Admin] = gAdminData[idx][admin_Level];
			break;
		}
	}

	if(gPlayerData[playerid][ply_Admin] > 0)
		MsgF(playerid, BLUE, " >  Your admin level: %d", gPlayerData[playerid][ply_Admin]);

	t:bPlayerGameSettings[playerid]<LoggedIn>;
	IncorrectPass[playerid]=0;

	stop gScreenFadeTimer[playerid];
	gScreenFadeTimer[playerid] = repeat FadeScreen(playerid);

	SetPlayerPos(playerid,
		gPlayerData[playerid][ply_posX],
		gPlayerData[playerid][ply_posY],
		gPlayerData[playerid][ply_posZ]);

	FreezePlayer(playerid, 3000);
}

SavePlayerData(playerid, prints = false)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 0;

	new
		tmpQuery[256];

	if(bPlayerGameSettings[playerid] & Alive)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		if(Distance(x, y, z, -907.5452, 272.7235, 1014.1449) < 50.0)
			return 0;

		if(x == 0.0 && y == 0.0 && z == 0.0)
			return 0;

		format(tmpQuery, sizeof(tmpQuery),
			"UPDATE `Player` SET \
			`"#ROW_ALIVE"` = '1', \
			`"#ROW_GEND"` = '%d', \
			`"#ROW_SPAWN"` = '%f %f %f %f', \
			`"#ROW_ISVIP"` = '%d' \
			WHERE `"#ROW_NAME"` = '%s'",
			(bPlayerGameSettings[playerid] & Gender) ? 1 : 0,
			x, y, z, a,
			(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0,
			gPlayerName[playerid]);

		SavePlayerInventory(playerid, prints);

		if(IsPlayerInAnyVehicle(playerid))
		{
			SavePlayerVehicle(gPlayerVehicleID[playerid], gPlayerName[playerid]);
		}
	}
	else
	{
		format(tmpQuery, sizeof(tmpQuery),
			"UPDATE `Player` SET \
			`"#ROW_ALIVE"` = '0', \
			`"#ROW_GEND"` = '0', \
			`"#ROW_SPAWN"` = '0.0 0.0 0.0 0.0', \
			`"#ROW_ISVIP"` = '%d' \
			WHERE `"#ROW_NAME"` = '%s'",
			(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0,
			gPlayerName[playerid]);

		ClearPlayerInventoryFile(playerid);
	}

	db_free_result(db_query(gAccounts, tmpQuery));

	return 1;
}

SavePlayerInventory(playerid, prints = false)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		characterdata[5],
		helditems[2],
		inventoryitems[8];

	GetFile(gPlayerName[playerid], filename);

	file = fopen(filename, io_write);

	characterdata[0] = _:gPlayerHP[playerid];
	characterdata[1] = _:gPlayerAP[playerid];
	characterdata[2] = _:gPlayerFP[playerid];
	characterdata[3] = GetPlayerClothes(playerid);
	characterdata[4] = GetPlayerHat(playerid);

	if(prints)
		printf("[SAVE] %s HP: %f", characterdata[0], characterdata[1]);

	fblockwrite(file, characterdata, 5);

	if(GetPlayerHolsteredWeapon(playerid) != 0)
	{
		helditems[0] = GetPlayerHolsteredWeapon(playerid);
		helditems[1] = GetPlayerHolsteredWeaponAmmo(playerid);
		fblockwrite(file, helditems, 2);
	}
	else
	{
		helditems[0] = 0;
		helditems[1] = 0;
		fblockwrite(file, helditems, 2);
	}

	if(GetPlayerWeapon(playerid) > 0)
	{
		helditems[0] = GetPlayerWeapon(playerid);
		helditems[1] = GetPlayerAmmo(playerid);
		fblockwrite(file, helditems, 2);
	}
	else
	{
		if(IsValidItem(GetPlayerItem(playerid)))
		{
			helditems[0] = _:GetItemType(GetPlayerItem(playerid));
			helditems[1] = GetItemExtraData(GetPlayerItem(playerid));
			fblockwrite(file, helditems, 2);
		}
		else
		{
			helditems[0] = -1;
			helditems[1] = -1;
			fblockwrite(file, helditems, 2);
		}
	}

	for(new i, j; j < 4; i += 2, j++)
	{
		inventoryitems[i] = _:GetItemType(GetInventorySlotItem(playerid, j));
		inventoryitems[i + 1] = GetItemExtraData(GetInventorySlotItem(playerid, j));
	}

	fblockwrite(file, inventoryitems, 8);

	if(IsValidItem(GetPlayerBackpackItem(playerid)))
	{
		new
			containerid = GetItemExtraData(GetPlayerBackpackItem(playerid)),
			bagdata[17];

		bagdata[0] = _:GetItemType(GetPlayerBackpackItem(playerid));

		for(new i = 1, j; j < GetContainerSize(containerid); i += 2, j++)
		{
			bagdata[i] = _:GetItemType(GetContainerSlotItem(containerid, j));
			bagdata[i+1] = GetItemExtraData(GetContainerSlotItem(containerid, j));
		}
		fblockwrite(file, bagdata, 17);
	}

	fclose(file);
}
LoadPlayerInventory(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		filepos,
		characterdata[5],
		helditems[2],
		inventoryitems[8],
		bagdata[17],
		itemid;

	GetFile(gPlayerName[playerid], filename);

	if(!fexist(filename))
	{
		ClearPlayerInventoryFile(playerid);
		return 0;
	}

	file = fopen(filename, io_read);

	fblockread(file, characterdata, 5);

	printf("[LOAD]: H: %f A: %f F: %f S: %d H: %d", characterdata[0], characterdata[1], characterdata[2], characterdata[3], characterdata[4]);

	if(Float:characterdata[0] <= 0.0)
		characterdata[0] = _:1.0;

	gPlayerHP[playerid] = Float:characterdata[0];
	gPlayerAP[playerid] = Float:characterdata[1];
	gPlayerFP[playerid] = Float:characterdata[2];
	gPlayerData[playerid][ply_Skin] = characterdata[3];
	SetPlayerHat(playerid, characterdata[4]);

	fblockread(file, helditems, 2);

	printf("[LOAD]: holster: %d %d", helditems[0], helditems[1]);
	if(0 < helditems[0] <= WEAPON_PARACHUTE)
	{
		if(helditems[1] > 0)
		{
			HolsterWeapon(playerid, helditems[0], helditems[1], 800);
		}
	}

	fblockread(file, helditems, 2);
	printf("[LOAD]: holding: %d %d", helditems[0], helditems[1]);
	if(helditems[0] != -1)
	{
		if(0 < helditems[0] <= WEAPON_PARACHUTE)
		{
			GivePlayerWeapon(playerid, helditems[0], helditems[1]);
			gPlayerArmedWeapon[playerid] = helditems[0];
		}
		else
		{
			itemid = CreateItem(ItemType:helditems[0], 0.0, 0.0, 0.0);

			if(!IsItemTypeSafebox(ItemType:helditems[0]) && !IsItemTypeBag(ItemType:helditems[0]))
				SetItemExtraData(itemid, helditems[1]);

			GiveWorldItemToPlayer(playerid, itemid, false);
		}
	}

	filepos = fblockread(file, inventoryitems, 8);

	for(new i; i < 8; i += 2)
	{
		if(!IsValidItemType(ItemType:inventoryitems[i]) || inventoryitems[i] == 0)
			continue;

		itemid = CreateItem(ItemType:inventoryitems[i], 0.0, 0.0, 0.0);
	
		if(!IsItemTypeSafebox(ItemType:inventoryitems[i]) && !IsItemTypeBag(ItemType:inventoryitems[i]))
			SetItemExtraData(itemid, inventoryitems[i + 1]);
	
		AddItemToInventory(playerid, itemid);
	}

	if(filepos != 0)
	{
		new
			containerid;

		fblockread(file, bagdata, 17);

		if(bagdata[0] == _:item_Satchel)
		{
			itemid = CreateItem(item_Satchel, 0.0, 0.0, 0.0);
			containerid = GetItemExtraData(itemid);
			GivePlayerBackpack(playerid, itemid);

			for(new i = 1; i < 8; i += 2)
			{
				if(bagdata[i] == _:INVALID_ITEM_TYPE)
					continue;

				itemid = CreateItem(ItemType:bagdata[i], 0.0, 0.0, 0.0);

				if(!IsItemTypeSafebox(ItemType:bagdata[i]) && !IsItemTypeBag(ItemType:bagdata[i]))
					SetItemExtraData(itemid, bagdata[i+1]);

				AddItemToContainer(containerid, itemid);
			}
		}

		if(bagdata[0] == _:item_Backpack)
		{
			itemid = CreateItem(item_Backpack, 0.0, 0.0, 0.0);
			containerid = GetItemExtraData(itemid);

			GivePlayerBackpack(playerid, itemid);

			for(new i = 1; i < 16; i += 2)
			{
				if(bagdata[i] == _:INVALID_ITEM_TYPE)
					continue;

				itemid = CreateItem(ItemType:bagdata[i], 0.0, 0.0, 0.0);

				if(!IsItemTypeSafebox(ItemType:bagdata[i]) && !IsItemTypeBag(ItemType:bagdata[i]))
					SetItemExtraData(itemid, bagdata[i+1]);

				AddItemToContainer(containerid, itemid);
			}
		}
	}

	fclose(file);

	return 1;
}
ClearPlayerInventoryFile(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file;

	GetFile(gPlayerName[playerid], filename);

	file = fopen(filename, io_write);
	fblockwrite(file, {0}, 1);
	fclose(file);
}


public OnPlayerDisconnect(playerid, reason)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	if(bPlayerGameSettings[playerid] & LoggedIn && !(bPlayerGameSettings[playerid] & AdminDuty))
		SavePlayerData(playerid);

	ResetVariables(playerid);
	UnloadPlayerTextDraws(playerid);

	if(bServerGlobalSettings & Restarting)
		return 0;

	switch(reason)
	{
		case 0:MsgAllF(GREY, " >  %s lost connection.", gPlayerName[playerid]);
		case 1:MsgAllF(GREY, " >  %s left the server.", gPlayerName[playerid]);
	}

	return 1;
}


ResetVariables(playerid)
{
	bPlayerGameSettings[playerid]		= 0;

	gPlayerData[playerid][ply_Admin]	= 0,
	gPlayerData[playerid][ply_Skin]		= 0,
	gPlayerHP[playerid]					= 100.0;
	gPlayerAP[playerid]					= 0.0;
	gPlayerFP[playerid]					= 80.0;
	gPlayerVehicleID[playerid]			= INVALID_VEHICLE_ID,
	Warnings[playerid]					= 0;
	IncorrectPass[playerid]				= 0;

	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);

	for(new i; i < 10; i++)
		RemovePlayerAttachedObject(playerid, i);
}


CMD:help(playerid, params[])
{
	ShowWelcomeMessage(playerid, 0);
	return 1;
}

CMD:changename(playerid, params[])
{
	new newname[24];
	if (sscanf(params, "s[24]", newname)) Msg(playerid, YELLOW, "Usage: /changename [new name]");
	else
	{
		new
			tmpQuery[128],
			DBResult:tmpResult,
			file[MAX_PLAYER_FILE];

		GetFile(newname, file);

		format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Player` WHERE `"#ROW_NAME"` = '%s'", newname);
		tmpResult = db_query(gAccounts, tmpQuery);

		if(db_num_rows(tmpResult) == 1 || fexist(file))
		{
			Msg(playerid, ORANGE, " >  That name already exists");
			return 1;
		}

		db_free_result(tmpResult);

		MsgF(playerid, YELLOW, " >  your new name is %s", newname);
		MsgAllF(YELLOW, " >  %s has changed their name to %s", gPlayerName[playerid], newname);

		format(tmpQuery, sizeof(tmpQuery), "UPDATE `Player` SET `"#ROW_NAME"` = '%s' WHERE `"#ROW_NAME"` = '%s'",
			newname, gPlayerName[playerid]);

		db_free_result(db_query(gAccounts, tmpQuery));

		SetPlayerName(playerid, newname);
		gPlayerName[playerid] = newname;

		CreateNewUserfile(playerid, gPlayerData[playerid][ply_Password]);
	}
	return 1;
}

CMD:changepass(playerid,params[])
{
	new
		oldpass[32],
		newpass[32],
		buffer[MAX_PASSWORD_LEN];

	if(!(bPlayerGameSettings[playerid] & LoggedIn))
		return Msg(playerid, YELLOW, " >  You must be logged in to use that command");

	if(sscanf(params, "s[32]s[32]", oldpass, newpass)) return Msg(playerid, YELLOW, "Usage: /changepass [old pass] [new pass]");
	else
	{
		WP_Hash(buffer, MAX_PASSWORD_LEN, oldpass);
		
		if(!strcmp(buffer, gPlayerData[playerid][ply_Password]))
		{
			new
				tmpQuery[256];

			WP_Hash(buffer, MAX_PASSWORD_LEN, newpass);

			format(tmpQuery, 256, "UPDATE `Player` SET `"#ROW_PASS"` = '%s' WHERE `"#ROW_NAME"` = '%s'",
			buffer, gPlayerName[playerid]);

			db_free_result(db_query(gAccounts, tmpQuery));
			
			gPlayerData[playerid][ply_Password] = buffer;

			MsgF(playerid, YELLOW, " >  Password succesfully changed to "#C_BLUE"%s"#C_YELLOW"!", newpass);
		}
		else
		{
			Msg(playerid, RED, " >  The entered password you typed doesn't match your current password.");
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;

	SetPlayerWeather(playerid, WeatherData[gWeatherID][weather_id]);

	if(bPlayerGameSettings[playerid] & AdminDuty)
	{
		SetPlayerPos(playerid, 0.0, 0.0, 3.0);
		gPlayerHP[playerid] = 100.0;
		return 1;
	}

	if(bPlayerGameSettings[playerid] & Dying)
	{
		TogglePlayerSpectating(playerid, true);

		defer SetDeathCamera(playerid);

		SetPlayerCameraPos(playerid,
			gPlayerDeathPos[playerid][0] - floatsin(-gPlayerDeathPos[playerid][3], degrees),
			gPlayerDeathPos[playerid][1] - floatcos(-gPlayerDeathPos[playerid][3], degrees),
			gPlayerDeathPos[playerid][2]);

		SetPlayerCameraLookAt(playerid, gPlayerDeathPos[playerid][0], gPlayerDeathPos[playerid][1], gPlayerDeathPos[playerid][2]);

		TextDrawShowForPlayer(playerid, DeathText);
		TextDrawShowForPlayer(playerid, DeathButton);
		SelectTextDraw(playerid, 0xFFFFFF88);
		gPlayerHP[playerid] = 1.0;
	}
	else
	{
		gScreenBoxFadeLevel[playerid] = 255;
		PlayerTextDrawBoxColor(playerid, ClassBackGround, gScreenBoxFadeLevel[playerid]);
		PlayerTextDrawShow(playerid, ClassBackGround);

		if(bPlayerGameSettings[playerid] & Alive)
		{
			LoadPlayerInventory(playerid);

			if(!IsValidClothes(gPlayerData[playerid][ply_Skin]))
				goto invalid_clothes_id_jump;

			SetPlayerClothes(playerid, gPlayerData[playerid][ply_Skin]);

			SetPlayerFacingAngle(playerid, gPlayerData[playerid][ply_rotZ]);
			SetCameraBehindPlayer(playerid);
			TogglePlayerControllable(playerid, true);
			t:bPlayerGameSettings[playerid]<Spawned>;

			GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
			TextDrawShowForPlayer(playerid, MapCover1);
			TextDrawShowForPlayer(playerid, MapCover2);

			if(bPlayerGameSettings[playerid] & LoggedIn)
			{
				stop gScreenFadeTimer[playerid];
				gScreenFadeTimer[playerid] = repeat FadeScreen(playerid);

				SetPlayerPos(playerid,
					gPlayerData[playerid][ply_posX],
					gPlayerData[playerid][ply_posY],
					gPlayerData[playerid][ply_posZ]);
			}
		}
		else
		{
			invalid_clothes_id_jump:

			gPlayerHP[playerid] = 100.0;
			gPlayerAP[playerid] = 0.0;
			gPlayerFP[playerid] = 80.0;
			PlayerCreateNewCharacter(playerid);
		}
	}

	gPlayerFrequency[playerid] = 108.0;
	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	PreloadPlayerAnims(playerid);

	SetPlayerWeather(playerid, WeatherData[gWeatherID][weather_id]);

	Streamer_Update(playerid);
	SetAllWeaponSkills(playerid, 500);

	return 1;
}

PlayerCreateNewCharacter(playerid)
{
	SetPlayerPos(playerid, -907.5452, 272.7235, 1014.1449);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerCameraLookAt(playerid, -907.5452, 272.7235, 1014.1449);
	SetPlayerCameraPos(playerid, -907.4642, 277.0962, 1014.1492);
	Streamer_UpdateEx(playerid, -907.5452, 272.7235, 1014.1449);

	PlayerTextDrawShow(playerid, ClassButtonMale);
	PlayerTextDrawShow(playerid, ClassButtonFemale);
	SelectTextDraw(playerid, 0xFFFFFF88);
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == ClassButtonMale)
	{
		t:bPlayerGameSettings[playerid]<Gender>;
		OnPlayerSelectGender(playerid);
	}
	if(playertextid == ClassButtonFemale)
	{
		f:bPlayerGameSettings[playerid]<Gender>;
		OnPlayerSelectGender(playerid);
	}
}

timer SetDeathCamera[50](playerid)
{
	InterpolateCameraPos(playerid,
		gPlayerDeathPos[playerid][0] - floatsin(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][1] - floatcos(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][2] + 1.0,
		gPlayerDeathPos[playerid][0] - floatsin(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][1] - floatcos(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][2] + 20.0,
		30000, CAMERA_MOVE);

	InterpolateCameraLookAt(playerid,
		gPlayerDeathPos[playerid][0],
		gPlayerDeathPos[playerid][1],
		gPlayerDeathPos[playerid][2],
		gPlayerDeathPos[playerid][0],
		gPlayerDeathPos[playerid][1],
		gPlayerDeathPos[playerid][2] + 1.0,
		30000, CAMERA_MOVE);
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(bPlayerGameSettings[playerid] & Dying)
		{
			SelectTextDraw(playerid, 0xFFFFFF88);
		}
		else
		{
			TextDrawShowForPlayer(playerid, MapCover1);
			TextDrawShowForPlayer(playerid, MapCover2);
		}
	}
	if(clickedid == DeathButton)
	{
		f:bPlayerGameSettings[playerid]<Dying>;
		TogglePlayerSpectating(playerid, false);
		CancelSelectTextDraw(playerid);
		TextDrawHideForPlayer(playerid, DeathText);
		TextDrawHideForPlayer(playerid, DeathButton);
	}
}

OnPlayerSelectGender(playerid)
{
	new
		r = random(MAX_SPAWNS),
		backpackitem,
		containerid,
		tmpitem;

	if(bPlayerGameSettings[playerid] & IsVip)
	{
		if(bPlayerGameSettings[playerid] & Gender)
		{
			switch(random(6))
			{
				case 0: gPlayerData[playerid][ply_Skin] = skin_Civ1M;
				case 1: gPlayerData[playerid][ply_Skin] = skin_Civ2M;
				case 2: gPlayerData[playerid][ply_Skin] = skin_Civ3M;
				case 3: gPlayerData[playerid][ply_Skin] = skin_Civ4M;
				case 4: gPlayerData[playerid][ply_Skin] = skin_MechM;
				case 5: gPlayerData[playerid][ply_Skin] = skin_BikeM;

			}
		}

		else
		{
			switch(random(6))
			{
				case 0: gPlayerData[playerid][ply_Skin] = skin_Civ1F;
				case 1: gPlayerData[playerid][ply_Skin] = skin_Civ2F;
				case 2: gPlayerData[playerid][ply_Skin] = skin_Civ3F;
				case 3: gPlayerData[playerid][ply_Skin] = skin_Civ4F;
				case 4: gPlayerData[playerid][ply_Skin] = skin_ArmyF;
				case 5: gPlayerData[playerid][ply_Skin] = skin_IndiF;
			}
		}
	}
	else
	{
		if(bPlayerGameSettings[playerid] & Gender)
			gPlayerData[playerid][ply_Skin] = skin_MainM;

		else
			gPlayerData[playerid][ply_Skin] = skin_MainF;
	}

	SetPlayerClothes(playerid, gPlayerData[playerid][ply_Skin]);

	SetPlayerPos(playerid, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	SetPlayerFacingAngle(playerid, gSpawns[r][3]);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
	SetAllWeaponSkills(playerid, 500);
	GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	TextDrawShowForPlayer(playerid, MapCover1);
	TextDrawShowForPlayer(playerid, MapCover2);

	CancelSelectTextDraw(playerid);
	PlayerTextDrawHide(playerid, ClassButtonMale);
	PlayerTextDrawHide(playerid, ClassButtonFemale);

	t:bPlayerGameSettings[playerid]<Spawned>;
	t:bPlayerGameSettings[playerid]<Alive>;

	gScreenBoxFadeLevel[playerid] = 255;
	stop gScreenFadeTimer[playerid];
	gScreenFadeTimer[playerid] = repeat FadeScreen(playerid);

	backpackitem = CreateItem(item_Satchel, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	containerid = GetItemExtraData(backpackitem);

	GivePlayerBackpack(playerid, backpackitem);

	tmpitem = CreateItem(ItemType:WEAPON_KNIFE, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	SetItemExtraData(tmpitem, 1);
	AddItemToContainer(containerid, tmpitem);

	tmpitem = CreateItem(item_Medkit, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	AddItemToContainer(containerid, tmpitem);

	tmpitem = CreateItem(item_Wrench, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	AddItemToContainer(containerid, tmpitem);

	if(bPlayerGameSettings[playerid] & IsVip)
	{
		tmpitem = CreateItem(item_ZorroMask, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
		AddItemToInventory(playerid, tmpitem);
	}

	Tutorial_Start(playerid);
}

timer FadeScreen[100](playerid)
{
	PlayerTextDrawBoxColor(playerid, ClassBackGround, gScreenBoxFadeLevel[playerid]);
	PlayerTextDrawShow(playerid, ClassBackGround);

	gScreenBoxFadeLevel[playerid] -= 4;

	if(gPlayerHP[playerid] <= 40.0)
	{
		if(gScreenBoxFadeLevel[playerid] <= floatround((40.0 - gPlayerHP[playerid]) * 4.4))
			stop gScreenFadeTimer[playerid];
	}
	else
	{
		if(gScreenBoxFadeLevel[playerid] <= 0)
			stop gScreenFadeTimer[playerid];
	}
}


public OnPlayerDeath(playerid, killerid, reason)
{
	if(!(bPlayerGameSettings[playerid] & Alive) || bPlayerGameSettings[playerid] & AdminDuty)
	{
		SpawnPlayer(playerid);
		return 0;
	}


	new deathreason[256];

	t:bPlayerGameSettings[playerid]<Dying>;
	f:bPlayerGameSettings[playerid]<Spawned>;
	f:bPlayerGameSettings[playerid]<AdminDuty>;
	f:bPlayerGameSettings[playerid]<Alive>;

	GetPlayerPos(playerid, gPlayerDeathPos[playerid][0], gPlayerDeathPos[playerid][1], gPlayerDeathPos[playerid][2]);
	GetPlayerFacingAngle(playerid, gPlayerDeathPos[playerid][3]);

	if(IsPlayerInAnyVehicle(playerid))
		gPlayerDeathPos[playerid][2] += 0.1;

	stop TankHeatUpdateTimer[playerid];

	TextDrawHideForPlayer(playerid, MapCover1);
	TextDrawHideForPlayer(playerid, MapCover2);

	if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 432)
		HidePlayerProgressBar(playerid, TankHeatBar);

	DropItems(playerid);
	SpawnPlayer(playerid);

	if(IsPlayerConnected(killerid))
	{
		MsgAdminsF(1, YELLOW, " >  [KILL]: %p killed %p with %d", killerid, playerid, reason);

		switch(reason)
		{
			case 0..3, 5..7, 10..15:
				deathreason = "They were beaten to death.";

			case 4:
				deathreason = "They suffered small lacerations on the torso, possibly from a knife.";

			case 8:
				deathreason = "Large lacerations cover the torso and head, looks like a finely sharpened sword.";

			case 9:
				deathreason = "There's bits everywhere, probably suffered a chainsaw to the torso.";

			case 16, 39, 35, 36, 255:
				deathreason = "They suffered massive concussion due to an explosion.";

			case 18, 37:
				deathreason = "The entire body is charred and burnt.";

			case 22..34, 38:
				deathreason = "They died of blood loss.";

			case 41, 42:
				deathreason = "They were sprayed and suffocated by a high pressure liquid.";

			case 44, 45:
				deathreason = "Somehow, they were killed by goggles.";

			case 43:
				deathreason = "Somehow, they were killed by a camera.";

			default:
				deathreason = "They died for an unknown reason.";

		}
	}
	else
	{
		MsgAdminsF(1, YELLOW, " >  [DEATH]: %p died by %d", playerid, reason);

		if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
		{
			deathreason = "They died of air embolism (injecting oxygen into their bloodsteam).";
		}
		else
		{
			switch(reason)
			{
				case 53:
					deathreason = "They drowned.";

				case 54:
					deathreason = "Most bones are broken, looks like they fell from a great height.";

				case 255:
					deathreason = "They suffered massive concussion due to an explosion.";

				default:
				deathreason = "They died for an unknown reason.";
			}
		}
	}

	CreateGravestone(playerid, deathreason, gPlayerDeathPos[playerid][0], gPlayerDeathPos[playerid][1], gPlayerDeathPos[playerid][2] - FLOOR_OFFSET, gPlayerDeathPos[playerid][3]);

	RemoveDrug(playerid, DRUG_TYPE_AIR);

	return 1;
}

DropItems(playerid)
{
	new
		backpackitem = GetPlayerBackpackItem(playerid),
		itemid;

	if(IsValidItem(GetPlayerItem(playerid)))
	{
		itemid = CreateItemInWorld(GetPlayerItem(playerid),
			gPlayerDeathPos[playerid][0] + floatsin(345.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(345.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET, .zoffset = ITEM_BTN_OFFSET_Z);

		RemoveCurrentItem(playerid);
	}
	else if(GetPlayerWeapon(playerid) > 0 && GetPlayerAmmo(playerid) > 0)
	{
		itemid = CreateItem(ItemType:GetPlayerWeapon(playerid),
			gPlayerDeathPos[playerid][0] + floatsin(345.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(345.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET, .zoffset = ITEM_BTN_OFFSET_Z);

		SetItemExtraData(itemid, GetPlayerAmmo(playerid));
	}

	if(GetPlayerHolsteredWeapon(playerid) > 0 && GetPlayerHolsteredWeaponAmmo(playerid) > 0)
	{
		itemid = CreateItem(ItemType:GetPlayerHolsteredWeapon(playerid),
			gPlayerDeathPos[playerid][0] + floatsin(15.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(15.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET, .zoffset = ITEM_BTN_OFFSET_Z);

		SetItemExtraData(itemid, GetPlayerHolsteredWeaponAmmo(playerid));

		RemovePlayerHolsterWeapon(playerid);
	}

	for(new i; i < INV_MAX_SLOTS; i++)
	{
		itemid = GetInventorySlotItem(playerid, 0);

		if(!IsValidItem(itemid))
			break;

		RemoveItemFromInventory(playerid, 0);
		CreateItemInWorld(itemid,
			gPlayerDeathPos[playerid][0] + floatsin(45.0 + (90.0 * float(i)), degrees),
			gPlayerDeathPos[playerid][1] + floatcos(45.0 + (90.0 * float(i)), degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET, .zoffset = ITEM_BTN_OFFSET_Z);
	}

	if(IsValidItem(backpackitem))
	{
		RemovePlayerBackpack(playerid);

		SetItemPos(backpackitem,
			gPlayerDeathPos[playerid][0] + floatsin(180.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(180.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET, .zoffset = ITEM_BTN_OFFSET_Z);

		SetItemRot(backpackitem, 0.0, 0.0, 0.0, true);
	}

	itemid = CreateItem(item_Clothes,
		gPlayerDeathPos[playerid][0] + floatsin(90.0, degrees),
		gPlayerDeathPos[playerid][1] + floatcos(90.0, degrees),
		gPlayerDeathPos[playerid][2] - FLOOR_OFFSET, .zoffset = ITEM_BTN_OFFSET_Z);

	SetItemExtraData(itemid, GetPlayerClothes(playerid));

	if(IsValidItem(GetPlayerHat(playerid)))
	{
		CreateItem(GetItemTypeFromHat(GetPlayerHat(playerid)),
			gPlayerDeathPos[playerid][0] + floatsin(270.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(270.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET, .zoffset = ITEM_BTN_OFFSET_Z);

		RemovePlayerHat(playerid);
	}

	gPlayerArmedWeapon[playerid] = 0;
}

public OnPlayerUpdate(playerid)
{
	if(bPlayerGameSettings[playerid] & Frozen)
		return 0;

	if(IsPlayerInAnyVehicle(playerid))
	{
		static
			str[8],
			Float:vx,
			Float:vy,
			Float:vz;

		GetVehicleVelocity(gPlayerVehicleID[playerid], vx, vy, vz);
		gPlayerVelocity[playerid] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
		format(str, 32, "%.0fkm/h", gPlayerVelocity[playerid]);
		PlayerTextDrawSetString(playerid, VehicleSpeedText, str);
	}
	else
	{
		SetPlayerArmedWeapon(playerid, gPlayerArmedWeapon[playerid]);

		new
			id,
			ammo;

		GetPlayerWeaponData(playerid, GetWeaponSlot(gPlayerArmedWeapon[playerid]), id, ammo);

		if(ammo == 0 && gPlayerArmedWeapon[playerid] == id && id != 0)
		{
			SetPlayerArmedWeapon(playerid, 0);
			gPlayerArmedWeapon[playerid] = 0;
		}
	}

	if(bPlayerGameSettings[playerid] & Alive)
	{
		SetPlayerHealth(playerid, gPlayerHP[playerid]);
		SetPlayerArmour(playerid, gPlayerAP[playerid]);
	}
	else
	{
		SetPlayerHealth(playerid, 100.0);		
	}

	return 1;
}
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
/*
	if(gPlayerData[playerid][ply_Admin] >= 4)
	{
		new str[64];
		format(str, 64, "took %.2f~n~from %p~n~weap %d", amount, issuerid, weaponid);
		ShowMsgBox(playerid, str, 1000, 120);
	}
*/
	if(issuerid == INVALID_PLAYER_ID)
	{
		if(weaponid == 53)
		{
			GivePlayerHP(playerid, -(amount * 0.1), weaponid);
		}

		else
		{
			GivePlayerHP(playerid, -(amount * 1.3), weaponid);

			if(amount > 10.0 && random(100) < amount)
				KnockOutPlayer(playerid, 5000);
		}

		return 1;
	}

	switch(weaponid)
	{
		case 31:
		{
			new model = GetVehicleModel(gPlayerVehicleID[issuerid]);

			if(model == 447 || model == 476)
				internal_HitPlayer(issuerid, playerid, WEAPON_VEHICLE_BULLET);
		}
		case 38:
		{
			if(GetVehicleModel(gPlayerVehicleID[issuerid]) == 425)
				internal_HitPlayer(issuerid, playerid, WEAPON_VEHICLE_BULLET);
		}
		case 49:
		{
			internal_HitPlayer(issuerid, playerid, WEAPON_VEHICLE_COLLISION);
		}
		case 51:
		{
			new model = GetVehicleModel(gPlayerVehicleID[issuerid]);

			if(model == 432 || model == 520 || model == 425)
				internal_HitPlayer(issuerid, playerid, WEAPON_VEHICLE_EXPLOSIVE);
		}
	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	internal_HitPlayer(playerid, damagedid, weaponid);
	return 1;
}

internal_HitPlayer(playerid, targetid, weaponid, type = 0)
{
	if(weaponid == WEAPON_DEAGLE)
	{
		if(tickcount() - tick_WeaponHit[playerid] < 400)
			return 0;
	}
	else
	{
		if(tickcount() - tick_WeaponHit[playerid] < 100)
			return 0;
	}

	tick_WeaponHit[playerid] = tickcount();

	new
		head,
		Float:px,
		Float:py,
		Float:pz,
		Float:tx,
		Float:ty,
		Float:tz,
		Float:distance,
		Float:hploss;

	GetPlayerPos(playerid, px, py, pz);
	GetPlayerPos(targetid, tx, ty, tz);

	distance = Distance(px, py, pz, tx, ty, tz);

	if(type == 0)
	{
		hploss = GetWeaponDamageFromDistance(weaponid, distance);

		if(head)
			hploss *= 1.5;
	}
	else if(type == 1)
	{
		if(GetItemType(GetPlayerItem(playerid)) == item_Taser)
		{
			KnockOutPlayer(targetid, 30000);
			defer DestroyDynamicObject_Delay(CreateDynamicObject(18724, tx, ty, tz-1.0, 0.0, 0.0, 0.0));
		}
		else
		{
			hploss = anm_Anims[weaponid][anm_CurrentAnim[targetid]][anm_damage];
		}

		if(weaponid == anim_Blunt)
		{
			if(random(100) < 30)
				t:bPlayerGameSettings[targetid]<KnockedOut>;

			if(random(100) < 50)
				t:bPlayerGameSettings[targetid]<Bleeding>;
		}
		if(weaponid == anim_Stab)
		{
			t:bPlayerGameSettings[targetid]<Bleeding>;
		}
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
	{
		hploss *= 0.9;
	}

	if(GetItemType(GetPlayerItem(targetid)) == item_Shield)
	{
		new
			Float:angleto,
			Float:targetangle;

		GetPlayerFacingAngle(targetid, targetangle);

		angleto = absoluteangle(targetangle - GetAngleToPoint(px, py, tx, ty));

		if(225.0 < angleto < 315.0)
		{
			hploss *= 0.2;
		}
	}
	else
	{
		if(!IsPlayerInAnyVehicle(playerid))
		{
			switch(weaponid)
			{
				case 25, 27, 30, 31, 33, 34:
					head = IsPlayerAimingAtHead(playerid, targetid);
			}
			switch(weaponid)
			{
				case 0..3, 5..7, 10..18, 39:
				{
					if(random(100) < 40)
						t:bPlayerGameSettings[targetid]<Bleeding>;
				}
				case 40..46:
				{
					// Unused
				}
				default:
				{
					t:bPlayerGameSettings[targetid]<Bleeding>;

					if(gPlayerHP[playerid] - hploss <= 40.0)
					{
						if(random(100) < 70)
						{
							KnockOutPlayer(targetid, floatround(2000 * (40.0 - gPlayerHP[targetid])));
						}
					}
				}
			}
		}
	}

	GivePlayerHP(targetid, -hploss, weaponid);
	ShowHitMarker(playerid, weaponid);

	if(gPlayerData[playerid][ply_Admin] >= 3)
	{
		new str[32];
		format(str, 32, "did %.2f", hploss);
		ShowMsgBox(playerid, str, 1000, 120);
	}
	
	return 1;
}
timer DestroyDynamicObject_Delay[1000](objectid)
{
	DestroyDynamicObject(objectid);
}
GivePlayerHP(playerid, Float:hp, weaponid = 54, msg = true)
{
	if(hp < 0.0)
	{
		if(gPlayerAP[playerid] > 0.0)
		{
			switch(weaponid)
			{
				case 0..7, 10..15:
					hp *= 0.6;

				case 22..32, 38:
					hp *= 0.5;

				case 33, 34:
					hp *= 0.8;
			}
			gPlayerAP[playerid] += hp / 2.0;
		}
	}
	else
	{
		if(msg)
		{
			new
				tmpstr[16];

			format(tmpstr, 16, "+%.1fHP", hp);

			PlayerTextDrawSetString(playerid, AddHPText, tmpstr);
			PlayerTextDrawShow(playerid, AddHPText);

			defer HideHPText(playerid);
		}
	}
	SetPlayerHP(playerid, (gPlayerHP[playerid] + hp));
}

timer HideHPText[2000](playerid)
{
	PlayerTextDrawHide(playerid, AddHPText);
}

SetPlayerHP(playerid, Float:hp)
{
	if(hp > 100.0)
		hp = 100.0;

	gPlayerHP[playerid] = hp;
}

ShowHitMarker(playerid, weapon)
{
	if(weapon == 34 || weapon == 35)
	{
		TextDrawShowForPlayer(playerid, HitMark_centre);
		defer HideHitMark(playerid, HitMark_centre);
	}
	else
	{
		TextDrawShowForPlayer(playerid, HitMark_offset);
		defer HideHitMark(playerid, HitMark_offset);
	}
}
timer HideHitMark[500](playerid, Text:hitmark)
{
	TextDrawHideForPlayer(playerid, hitmark);
}


/* Weapon Knockback

	if(weaponid==34)
	{
		new
			Float:pX,
			Float:pY,
			Float:pZ,
			Float:iX,
			Float:iY,
			Float:iZ,

			Float:vX,
			Float:vY,
			Float:vZ,

			Float:pA;

		GetPlayerPos(playerid, pX, pY, pZ);
		GetPlayerPos(playerid, iX, iY, iZ);
		GetPlayerPos(playerid, vX, vY, vZ);

		pA = GetAngleToPoint(iX, iY, pX, pY);
		GetXYFromAngle(vX, vY, pA, 0.35);

		pX-=vX;
		pY-=pY;

		SetPlayerVelocity(playerid, pX, pY, -0.2);
		ApplyAnimation(playerid, "PED", "FALL_back", 4.0, 0, 1, 1, 1, 0, 1);
		defer GetUp(playerid);
	}
}
timer GetUp[1000](playerid)
{
	ApplyAnimation(playerid, "PED", "getup", 4.0, 0, 1, 1, 0, 0, 1);
}
*/

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(bPlayerGameSettings[playerid] & DebugMode)
		MsgF(playerid, YELLOW, "Newkeys: %d, OldKeys: %d", newkeys, oldkeys);

	if(IsPlayerInAnyVehicle(playerid))
	{
		new
			iPlayerVehicleID = GetPlayerVehicleID(playerid),
			iVehicleModel = GetVehicleModel(iPlayerVehicleID);

		if( ((newkeys & 1) || (newkeys & 4)) && (iVehicleModel == 432) )
		{
			TankHeat[playerid] += 20.0;
			SetPlayerProgressBarMaxValue(playerid, TankHeatBar, 30.0);
			SetPlayerProgressBarValue(playerid, TankHeatBar, Float:TankHeat[playerid]);
			UpdatePlayerProgressBar(playerid, TankHeatBar);

			if(TankHeat[playerid] >= 30.0)
			{
				GameTextForPlayer(playerid, "~r~Overheating!!!", 3000, 5);
			}
			if(TankHeat[playerid] >= 40.0)
			{
				new Float:Tp[3];
				GetVehiclePos(iPlayerVehicleID, Tp[0], Tp[1], Tp[2]);
				CreateExplosion(Tp[0], Tp[1], Tp[2], 11, 5.0);
				TankHeat[playerid]=0.0;
			}
		}
		if(newkeys == KEY_ACTION)
		{
			if(iVehicleModel == 525)
			{
				new
					Float:Player_vX,
					Float:Player_vY,
					Float:Player_vZ,
					Float:tmp_vX,
					Float:tmp_vY,
					Float:tmp_vZ;

				GetVehiclePos(iPlayerVehicleID, Player_vX, Player_vY, Player_vZ);

				for(new tmp_vID; tmp_vID<MAX_VEHICLES; tmp_vID++)
				{
					GetVehiclePos(tmp_vID, tmp_vX, tmp_vY, tmp_vZ);
					if( (Distance(tmp_vX, tmp_vY, tmp_vZ, Player_vX, Player_vY, Player_vZ)<7.0) && (tmp_vID != iPlayerVehicleID) )
					{
						if(IsTrailerAttachedToVehicle(iPlayerVehicleID))
							DetachTrailerFromVehicle(iPlayerVehicleID);

						AttachTrailerToVehicle(tmp_vID, iPlayerVehicleID);
						break;
					}
				}
			}
		}
		if(newkeys & KEY_YES)
		{
			if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			{
				new Float:health;
				GetVehicleHealth(gPlayerVehicleID[playerid], health);

				if(health >= 300.0)
				{
					if(VehicleFuelData[GetVehicleModel(gPlayerVehicleID[playerid])-400][veh_maxFuel] > 0.0 && gVehicleFuel[gPlayerVehicleID[playerid]] > 0.0)
						VehicleEngineState(gPlayerVehicleID[playerid], !VehicleEngineState(gPlayerVehicleID[playerid]));

					else
						VehicleEngineState(gPlayerVehicleID[playerid], !VehicleEngineState(gPlayerVehicleID[playerid]));
				}
			}
		}
		if(newkeys & KEY_NO)
		{
			VehicleLightsState(gPlayerVehicleID[playerid], !VehicleLightsState(gPlayerVehicleID[playerid]));
		}
		if(newkeys & KEY_CROUCH)
		{
			if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
			{
				if(bPlayerGameSettings[playerid] & HangingOutWindow)
				{
					PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), GetPlayerVehicleSeat(playerid));
					f:bPlayerGameSettings[playerid]<HangingOutWindow>;
				}
				else
				{
					t:bPlayerGameSettings[playerid]<HangingOutWindow>;
				}
			}
		}
	}
	else
	{
		if(newkeys & KEY_JUMP && !(oldkeys & KEY_JUMP) && GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
			ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff",4.1,0,1,1,0,0);

/*
		if(newkeys & KEY_FIRE)
		{
			new iWepState = GetPlayerWeaponState(playerid);

			if((iWepState != WEAPONSTATE_RELOADING && iWepState != WEAPONSTATE_NO_BULLETS))
				OnPlayerShoot(playerid);
		}
*/
	}

	return 1;
}

CMD:g(playerid, params[])
{
	if(isnull(params))
	{
		gPlayerFrequency[playerid] = 108.0;
		Msg(playerid, WHITE, " >  You turn your radio on to the global frequency.");
	}
	else
	{
		PlayerSendChat(playerid, params, 108.0);
	}
	return 1;
}
CMD:l(playerid, params[])
{
	if(isnull(params))
	{
		gPlayerFrequency[playerid] = 0.0;
		Msg(playerid, WHITE, " >  You turned your radio off, chat is not broadcasted.");
	}
	else
	{
		PlayerSendChat(playerid, params, 0.0);
	}
	return 1;
}
CMD:c(playerid, params[])
{
	if(gPlayerFrequency[playerid] != 0.0)
	{
		gPlayerFrequency[playerid] = 0.0;
		Msg(playerid, WHITE, " >  You turned your radio off, chat is not broadcasted.");
	}
	else
	{
		gPlayerFrequency[playerid] = 108.0;
		Msg(playerid, WHITE, " >  You turn your radio on to the global frequency.");
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new tmpMuteTime = tickcount() - ChatMuteTick[playerid];

	if(bPlayerGameSettings[playerid] & Muted)
	{
		Msg(playerid, RED, " >  You are muted");
		return 0;
	}
	if(tmpMuteTime < 10000)
	{
		MsgF(playerid, RED, " >  You are muted for chat flooding, %s remaining.", MsToString(10000-tmpMuteTime, 2));
		return 0;
	}

	if(tickcount() - tick_LastChatMessage[playerid] < 1000)
	{
		ChatMessageStreak[playerid]++;
		if(ChatMessageStreak[playerid] == 5)
		{
			ChatMuteTick[playerid] = tickcount();
			return 0;
		}
	}
	else ChatMessageStreak[playerid]--;

	tick_LastChatMessage[playerid] = tickcount();

	PlayerSendChat(playerid, text, gPlayerFrequency[playerid]);

	return 0;
}
PlayerSendChat(playerid, textInput[], Float:frequency)
{
	new
		text[256],
		text2[128],
		sendsecondline;

	if(frequency == 108.0)
	{
		format(text, 256, "[Global] (%d) %P"#C_WHITE": %s",
			playerid,
			playerid,
			TagScan(textInput));
	}
	else if(frequency == 0.0)
	{
		format(text, 256, "[Local] (%d) %P"#C_WHITE": %s",
			playerid,
			playerid,
			TagScan(textInput));
	}
	else
	{
		format(text, 256, "[%.2f] (%d) %P"#C_WHITE": %s",
			frequency,
			playerid,
			playerid,
			TagScan(textInput));
	}

	SetPlayerChatBubble(playerid, textInput, WHITE, 40.0, 10000);

	if(strlen(text) > 127)
	{
		sendsecondline = 1;

		new
			splitpos;

		for(new c = 128; c > 0; c--)
		{
			if(text[c] == ' ' || text[c] ==  ',' || text[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(text2, text[splitpos]);
		text[splitpos] = 0;
	}

	if(frequency == 108.0)
	{
		foreach(new i : Player)
		{
			SendClientMessage(i, WHITE, text);

			if(sendsecondline)
				SendClientMessage(i, WHITE, text2);
		}
	}
	else if(frequency == 0.0)
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);

		foreach(new i : Player)
		{
			if(IsPlayerInRangeOfPoint(i, 40.0, x, y, z))
			{
				SendClientMessage(i, WHITE, text);

				if(sendsecondline)
					SendClientMessage(i, WHITE, text2);
			}
		}
	}
	else
	{
		foreach(new i : Player)
		{
			if(-0.1 < frequency - gPlayerFrequency[i] < 0.1)
			{
				SendClientMessage(i, WHITE, text);

				if(sendsecondline)
					SendClientMessage(i, WHITE, text2);
			}
		}
	}

	return 1;
}


public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(bPlayerGameSettings[playerid] & DebugMode)
		MsgF(playerid, YELLOW, "Newstate: %d, Oldstate: %d", newstate, oldstate);

	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new model = GetVehicleModel(vehicleid);

		if(newstate == PLAYER_STATE_DRIVER)
		{
			SetPlayerArmedWeapon(playerid, 0);

			if(model == 432)
			{
				TankHeatUpdateTimer[playerid] = repeat TankHeatUpdate(playerid);
				ShowPlayerProgressBar(playerid, TankHeatBar);
			}
		}

		gPlayerVehicleID[playerid] = vehicleid;

		t:bVehicleSettings[vehicleid]<v_Used>;
		t:bVehicleSettings[vehicleid]<v_Occupied>;

		PlayerTextDrawSetString(playerid, VehicleNameText, VehicleNames[model-400]);
		PlayerTextDrawShow(playerid, VehicleNameText);
		PlayerTextDrawShow(playerid, VehicleSpeedText);
		PlayerTextDrawShow(playerid, VehicleFuelText);
		PlayerTextDrawShow(playerid, VehicleDamageText);
		PlayerTextDrawShow(playerid, VehicleEngineText);
	}
	if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
		gPlayerVehicleID[playerid] = INVALID_VEHICLE_ID;

		f:bVehicleSettings[vehicleid]<v_Occupied>;

		PlayerTextDrawHide(playerid, VehicleNameText);
		PlayerTextDrawHide(playerid, VehicleSpeedText);
		PlayerTextDrawHide(playerid, VehicleFuelText);
		PlayerTextDrawHide(playerid, VehicleDamageText);
		PlayerTextDrawHide(playerid, VehicleEngineText);
		HidePlayerProgressBar(playerid, TankHeatBar);
		stop TankHeatUpdateTimer[playerid];
	}
	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(ispassenger)
	{
		new
			Float:px,
			Float:py,
			Float:pz,
			Float:vx,
			Float:vy,
			Float:vz,
			Float:sx,
			Float:sy,
			Float:sz;

		GetPlayerPos(playerid, px, py, pz);
		GetVehiclePos(vehicleid, vx, vy, vz);
		GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

		if(Distance(px, py, pz, vx, vy, vz) > sy + sx / 2)
		{
			CancelPlayerMovement(playerid);
			return 0;
		}
	}

	if(bPlayerGameSettings[playerid] & KnockedOut)
	{
		return 0;
	}

	gCurrentVelocity[playerid] = 0.0;

	return 1;
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	gCurrentVelocity[playerid] = 0.0;

	if(GetVehicleModel(vehicleid) == 432)
		HidePlayerProgressBar(playerid, TankHeatBar);

	tick_ExitVehicle[playerid] = tickcount();

	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_Login)
	{
		if(response)
		{
			if(strlen(inputtext) < 4)
			{
				ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", "Type your password below", "Accept", "Quit");
				return 1;
			}

			new hash[MAX_PASSWORD_LEN];
			WP_Hash(hash, MAX_PASSWORD_LEN, inputtext);

			if(!strcmp(hash, gPlayerData[playerid][ply_Password]))
				Login(playerid);

			else
			{
				new str[64];
				IncorrectPass[playerid]++;
				format(str, 64, "Incorrect password! %d out of 5 tries", IncorrectPass[playerid]);
				ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Quit");
				if(IncorrectPass[playerid] == 5)
				{
					IncorrectPass[playerid] = 0;
					Kick(playerid);
					MsgAllF(GREY, " >  %s left the server without logging in.", gPlayerName[playerid]);
				}
			}
		}
		else
		{
			MsgAllF(GREY, " >  %s left the server without logging in.", gPlayerName[playerid]);
			Kick(playerid);
		}
	}
	if(dialogid == d_Register)
	{
		if(response)
		{
			if(!(4 <= strlen(inputtext) <= 32))
			{
				ShowPlayerDialog(playerid, d_Register, DIALOG_STYLE_PASSWORD, ""#C_RED"Password too short/long!\n"C_YELLOW"Password must be between 4 and 32 characters.", "Type your password below", "Accept", "Quit");
				return 0;
			}
			new
				buffer[MAX_PASSWORD_LEN];

			WP_Hash(buffer, MAX_PASSWORD_LEN, inputtext);
			GivePlayerMoney(playerid, 500);

			CreateNewUserfile(playerid, buffer);

			ShowWelcomeMessage(playerid, 20);
		}
		else
		{
			MsgAllF(GREY, " >  %s left the server without registering.", gPlayerName[playerid]);
			Kick(playerid);
		}
	}

	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new
		cmd[30],
		params[98],
		cmdfunction[64],
		result = 1;

	printf("[comm] [%p]: %s", playerid, cmdtext);

	sscanf(cmdtext, "s[30]s[98]", cmd, params);

	for (new i, j = strlen(cmd); i < j; i++)
		cmd[i] = tolower(cmd[i]);

	format(cmdfunction, 64, "cmd_%s", cmd[1]); // Format the standard command function name

	if(funcidx(cmdfunction) == -1) // If it doesn't exist, all hope is not lost! It might be defined as an admin command which has the admin level after the command name
	{
		new
			iLvl = gPlayerData[playerid][ply_Admin], // The player's admin level
			iLoop = 4; // The highest admin level

		while(iLoop > 0) // Loop backwards through admin levels, from 4 to 1
		{
			format(cmdfunction, 64, "cmd_%s_%d", cmd[1], iLoop); // format the function to include the admin variable

			if(funcidx(cmdfunction) != -1)
				break; // if this function exists, break the loop, at this point iLoop can never be worth 0

			iLoop--; // otherwise just advance to the next iteration, iLoop can become 0 here and thus break the loop at the next iteration
		}

		// If iLoop was 0 after the loop that means it above completed it's last itteration and never found an existing function

		if(iLoop == 0)
			result = 0;

		// If the players level was below where the loop found the existing function,
		// that means the number in the function is higher than the player id
		// Give a 'not high enough admin level' error

		if(iLvl < iLoop)
			result = 5;
	}
	if(result == 1)
	{
		if(isnull(params))result = CallLocalFunction(cmdfunction, "is", playerid, "\1");
		else result = CallLocalFunction(cmdfunction, "is", playerid, params);
	}

/*
	Return values for commands.

	Instead of writing these messages on the commands themselves, I can just
	write them here and return different values on the commands.
*/

	if		(result == 0) Msg(playerid, ORANGE, " >  That is not a recognized command. Check the "#C_BLUE"/help "#C_ORANGE"dialog.");
	else if	(result == 1) return 1; // valid command, do nothing.
	else if	(result == 2) Msg(playerid, ORANGE, " >  You cannot use that command right now.");
	else if	(result == 3) Msg(playerid, RED, " >  You cannot use that command on that player right now.");
	else if	(result == 4) Msg(playerid, RED, " >  Invalid ID");
	else if	(result == 5) Msg(playerid, RED, " >  You have insufficient authority to use that command.");
	else if	(result == 6) Msg(playerid, RED, " >  You can only use that command while on "#C_BLUE"administrator duty"#C_RED".");

	return 1;
}


LoadTextDraws()
{
	print("- Loading TextDraws...");

//=========================================================================Death
	DeathText					=TextDrawCreate(320.000000, 300.000000, "YOU ARE DEAD!");
	TextDrawAlignment			(DeathText, 2);
	TextDrawBackgroundColor		(DeathText, 255);
	TextDrawFont				(DeathText, 1);
	TextDrawLetterSize			(DeathText, 0.500000, 2.000000);
	TextDrawColor				(DeathText, -1);
	TextDrawSetOutline			(DeathText, 0);
	TextDrawSetProportional		(DeathText, 1);
	TextDrawSetShadow			(DeathText, 1);
	TextDrawUseBox				(DeathText, 1);
	TextDrawBoxColor			(DeathText, 85);
	TextDrawTextSize			(DeathText, 20.000000, 150.000000);

	DeathButton					=TextDrawCreate(320.000000, 323.000000, ">Play Again<");
	TextDrawAlignment			(DeathButton, 2);
	TextDrawBackgroundColor		(DeathButton, 255);
	TextDrawFont				(DeathButton, 1);
	TextDrawLetterSize			(DeathButton, 0.370000, 1.599999);
	TextDrawColor				(DeathButton, -1);
	TextDrawSetOutline			(DeathButton, 0);
	TextDrawSetProportional		(DeathButton, 1);
	TextDrawSetShadow			(DeathButton, 1);
	TextDrawUseBox				(DeathButton, 1);
	TextDrawBoxColor			(DeathButton, 85);
	TextDrawTextSize			(DeathButton, 20.000000, 150.000000);
	TextDrawSetSelectable		(DeathButton, true);

//=========================================================================Clock
	ClockText					=TextDrawCreate(605.0, 25.0, "00:00");
	TextDrawUseBox				(ClockText, 0);
	TextDrawFont				(ClockText, 3);
	TextDrawSetShadow			(ClockText, 0);
	TextDrawSetOutline			(ClockText, 2);
	TextDrawBackgroundColor		(ClockText, 0x000000FF);
	TextDrawColor				(ClockText, 0xFFFFFFFF);
	TextDrawAlignment			(ClockText, 3);
	TextDrawLetterSize			(ClockText, 0.5, 1.6);

	RestartCount				=TextDrawCreate(430.000000, 10.000000, "Server Restart In:~n~00:00");
	TextDrawAlignment			(RestartCount, 2);
	TextDrawBackgroundColor		(RestartCount, 255);
	TextDrawFont				(RestartCount, 1);
	TextDrawLetterSize			(RestartCount, 0.400000, 2.000000);
	TextDrawColor				(RestartCount, -1);
	TextDrawSetOutline			(RestartCount, 1);
	TextDrawSetProportional		(RestartCount, 1);


//=====================================================================Map Cover
	MapCover1					=TextDrawCreate(87.000000, 316.000000, "O");
	TextDrawAlignment			(MapCover1, 2);
	TextDrawBackgroundColor		(MapCover1, 255);
	TextDrawFont				(MapCover1, 1);
	TextDrawLetterSize			(MapCover1, 4.159998, 13.600000);
	TextDrawColor				(MapCover1, 255);
	TextDrawSetOutline			(MapCover1, 0);
	TextDrawSetProportional		(MapCover1, 1);
	TextDrawSetShadow			(MapCover1, 0);

	MapCover2					=TextDrawCreate(87.000000, 345.000000, "O");
	TextDrawAlignment			(MapCover2, 2);
	TextDrawBackgroundColor		(MapCover2, 255);
	TextDrawFont				(MapCover2, 1);
	TextDrawLetterSize			(MapCover2, 2.169998, 7.699997);
	TextDrawColor				(MapCover2, 255);
	TextDrawSetOutline			(MapCover2, 0);
	TextDrawSetProportional		(MapCover2, 1);
	TextDrawSetShadow			(MapCover2, 0);

//=====================================================================HitMarker
	new hm[14];
	hm[0] =92,	hm[1] =' ',hm[2] ='/',hm[3] ='~',hm[4] ='n',hm[5] ='~',	hm[6] =' ',
	hm[7] ='~',	hm[8] ='n',hm[9] ='~',hm[10]='/',hm[11]=' ',hm[12]=92,  hm[13]=EOS;
	//"\ /~n~ ~n~/ \"

	HitMark_centre			=TextDrawCreate(305.500000, 208.500000, hm);
	TextDrawBackgroundColor	(HitMark_centre, -1);
	TextDrawFont			(HitMark_centre, 1);
	TextDrawLetterSize		(HitMark_centre, 0.500000, 1.000000);
	TextDrawColor			(HitMark_centre, -1);
	TextDrawSetProportional	(HitMark_centre, 1);
	TextDrawSetOutline		(HitMark_centre, 0);
	TextDrawSetShadow		(HitMark_centre, 0);

	HitMark_offset			=TextDrawCreate(325.500000, 165.500000, hm);
	TextDrawBackgroundColor	(HitMark_offset, -1);
	TextDrawFont			(HitMark_offset, 1);
	TextDrawLetterSize		(HitMark_offset, 0.520000, 1.000000);
	TextDrawColor			(HitMark_offset, -1);
	TextDrawSetProportional	(HitMark_offset, 1);
	TextDrawSetOutline		(HitMark_offset, 0);
	TextDrawSetShadow		(HitMark_offset, 0);

}
LoadPlayerTextDraws(playerid)
{
//==============================================================Character Create
	ClassBackGround					=CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, ClassBackGround, 255);
	PlayerTextDrawFont				(playerid, ClassBackGround, 1);
	PlayerTextDrawLetterSize		(playerid, ClassBackGround, 0.500000, 50.000000);
	PlayerTextDrawColor				(playerid, ClassBackGround, -1);
	PlayerTextDrawSetOutline		(playerid, ClassBackGround, 0);
	PlayerTextDrawSetProportional	(playerid, ClassBackGround, 1);
	PlayerTextDrawSetShadow			(playerid, ClassBackGround, 1);
	PlayerTextDrawUseBox			(playerid, ClassBackGround, 1);
	PlayerTextDrawBoxColor			(playerid, ClassBackGround, 255);
	PlayerTextDrawTextSize			(playerid, ClassBackGround, 640.000000, 0.000000);

	ClassButtonMale					=CreatePlayerTextDraw(playerid, 250.000000, 200.000000, "~n~Male~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonMale, 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonMale, 255);
	PlayerTextDrawFont				(playerid, ClassButtonMale, 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonMale, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonMale, -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonMale, 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonMale, 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonMale, 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonMale, 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonMale, 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonMale, 300.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonMale, true);

	ClassButtonFemale				=CreatePlayerTextDraw(playerid, 390.000000, 200.000000, "~n~Female~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonFemale, 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonFemale, 255);
	PlayerTextDrawFont				(playerid, ClassButtonFemale, 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonFemale, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonFemale, -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonFemale, 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonFemale, 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonFemale, 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonFemale, 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonFemale, 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonFemale, 300.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonFemale, true);


//======================================================================Tooltips

	ToolTip							=CreatePlayerTextDraw(playerid, 618.000000, 120.000000, "fixed it");
	PlayerTextDrawAlignment			(playerid, ToolTip, 3);
	PlayerTextDrawBackgroundColor	(playerid, ToolTip, 255);
	PlayerTextDrawFont				(playerid, ToolTip, 1);
	PlayerTextDrawLetterSize		(playerid, ToolTip, 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, ToolTip, -1);
	PlayerTextDrawSetOutline		(playerid, ToolTip, 1);
	PlayerTextDrawSetProportional	(playerid, ToolTip, 1);


//======================================================================Food Bar

	HungerBarBackground				=CreatePlayerTextDraw(playerid, 612.000000, 101.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, HungerBarBackground, 255);
	PlayerTextDrawFont				(playerid, HungerBarBackground, 1);
	PlayerTextDrawLetterSize		(playerid, HungerBarBackground, 0.500000, -10.200000);
	PlayerTextDrawColor				(playerid, HungerBarBackground, -1);
	PlayerTextDrawSetOutline		(playerid, HungerBarBackground, 0);
	PlayerTextDrawSetProportional	(playerid, HungerBarBackground, 1);
	PlayerTextDrawSetShadow			(playerid, HungerBarBackground, 1);
	PlayerTextDrawUseBox			(playerid, HungerBarBackground, 1);
	PlayerTextDrawBoxColor			(playerid, HungerBarBackground, 255);
	PlayerTextDrawTextSize			(playerid, HungerBarBackground, 618.000000, 10.000000);

	HungerBarForeground				=CreatePlayerTextDraw(playerid, 613.000000, 100.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, HungerBarForeground, 255);
	PlayerTextDrawFont				(playerid, HungerBarForeground, 1);
	PlayerTextDrawLetterSize		(playerid, HungerBarForeground, 0.500000, -10.000000);
	PlayerTextDrawColor				(playerid, HungerBarForeground, -1);
	PlayerTextDrawSetOutline		(playerid, HungerBarForeground, 0);
	PlayerTextDrawSetProportional	(playerid, HungerBarForeground, 1);
	PlayerTextDrawSetShadow			(playerid, HungerBarForeground, 1);
	PlayerTextDrawUseBox			(playerid, HungerBarForeground, 1);
	PlayerTextDrawBoxColor			(playerid, HungerBarForeground, -2130771840);
	PlayerTextDrawTextSize			(playerid, HungerBarForeground, 617.000000, 10.000000);


//======================================================================HelpTips

	HelpTipText						=CreatePlayerTextDraw(playerid, 150.000000, 350.000000, "Tip: You can access the trunks of cars by pressing F at the back");
	PlayerTextDrawBackgroundColor	(playerid, HelpTipText, 255);
	PlayerTextDrawFont				(playerid, HelpTipText, 1);
	PlayerTextDrawLetterSize		(playerid, HelpTipText, 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, HelpTipText, 16711935);
	PlayerTextDrawSetOutline		(playerid, HelpTipText, 1);
	PlayerTextDrawSetProportional	(playerid, HelpTipText, 1);
	PlayerTextDrawSetShadow			(playerid, HelpTipText, 0);
	PlayerTextDrawUseBox			(playerid, HelpTipText, 1);
	PlayerTextDrawBoxColor			(playerid, HelpTipText, 0);
	PlayerTextDrawTextSize			(playerid, HelpTipText, 520.000000, 0.000000);


//========================================================================Speedo

	VehicleNameText					=CreatePlayerTextDraw(playerid, 621.000000, 415.000000, "Infernus");
	PlayerTextDrawAlignment			(playerid, VehicleNameText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleNameText, 255);
	PlayerTextDrawFont				(playerid, VehicleNameText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleNameText, 0.349999, 1.799998);
	PlayerTextDrawColor				(playerid, VehicleNameText, -1);
	PlayerTextDrawSetOutline		(playerid, VehicleNameText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleNameText, 1);

	VehicleSpeedText				=CreatePlayerTextDraw(playerid, 620.000000, 401.000000, "220km/h");
	PlayerTextDrawAlignment			(playerid, VehicleSpeedText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleSpeedText, 255);
	PlayerTextDrawFont				(playerid, VehicleSpeedText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleSpeedText, 0.250000, 1.599998);
	PlayerTextDrawColor				(playerid, VehicleSpeedText, -1);
	PlayerTextDrawSetOutline		(playerid, VehicleSpeedText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleSpeedText, 1);

	VehicleFuelText					=CreatePlayerTextDraw(playerid, 620.000000, 386.000000, "0.0/0.0L");
	PlayerTextDrawAlignment			(playerid, VehicleFuelText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleFuelText, 255);
	PlayerTextDrawFont				(playerid, VehicleFuelText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleFuelText, 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleFuelText, -1);
	PlayerTextDrawSetOutline		(playerid, VehicleFuelText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleFuelText, 1);

	VehicleDamageText				=CreatePlayerTextDraw(playerid, 620.000000, 371.000000, "DMG");
	PlayerTextDrawAlignment			(playerid, VehicleDamageText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleDamageText, 255);
	PlayerTextDrawFont				(playerid, VehicleDamageText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleDamageText, 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleDamageText, RED);
	PlayerTextDrawSetOutline		(playerid, VehicleDamageText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleDamageText, 1);

	VehicleEngineText				=CreatePlayerTextDraw(playerid, 620.000000, 356.000000, "ENG");
	PlayerTextDrawAlignment			(playerid, VehicleEngineText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleEngineText, 255);
	PlayerTextDrawFont				(playerid, VehicleEngineText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleEngineText, 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleEngineText, RED);
	PlayerTextDrawSetOutline		(playerid, VehicleEngineText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleEngineText, 1);


//======================================================================Stat GUI

	AddHPText						=CreatePlayerTextDraw(playerid, 160.000000, 240.000000, "<+HP>");
	PlayerTextDrawColor				(playerid, AddHPText, RED);
	PlayerTextDrawBackgroundColor	(playerid, AddHPText, 255);
	PlayerTextDrawFont				(playerid, AddHPText, 1);
	PlayerTextDrawLetterSize		(playerid, AddHPText, 0.300000, 1.000000);
	PlayerTextDrawSetProportional	(playerid, AddHPText, 1);
	PlayerTextDrawSetShadow			(playerid, AddHPText, 0);
	PlayerTextDrawSetOutline		(playerid, AddHPText, 1);

	AddScoreText					=CreatePlayerTextDraw(playerid, 160.000000, 260.000000, "<+P>");
	PlayerTextDrawColor				(playerid, AddScoreText, YELLOW);
	PlayerTextDrawBackgroundColor	(playerid, AddScoreText, 255);
	PlayerTextDrawFont				(playerid, AddScoreText, 1);
	PlayerTextDrawLetterSize		(playerid, AddScoreText, 0.300000, 1.000000);
	PlayerTextDrawSetProportional	(playerid, AddScoreText, 1);
	PlayerTextDrawSetShadow			(playerid, AddScoreText, 0);
	PlayerTextDrawSetOutline		(playerid, AddScoreText, 1);

	ActionBar						= CreatePlayerProgressBar(playerid, 291.0, 345.0, 57.50, 5.19, GREY, 100.0);
	TankHeatBar						= CreatePlayerProgressBar(playerid, 220.0, 380.0, 200.0, 20.0, RED, 30.0);
	KnockoutBar						= CreatePlayerProgressBar(playerid, 291.0, 315.0, 57.50, 5.19, RED, 100.0);
}
UnloadPlayerTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid, ClassBackGround);
	PlayerTextDrawDestroy(playerid, ClassButtonMale);
	PlayerTextDrawDestroy(playerid, ClassButtonFemale);
	PlayerTextDrawDestroy(playerid, HelpTipText);
	PlayerTextDrawDestroy(playerid, VehicleNameText);
	PlayerTextDrawDestroy(playerid, VehicleSpeedText);
	PlayerTextDrawDestroy(playerid, AddHPText);
	PlayerTextDrawDestroy(playerid, AddScoreText);

	DestroyPlayerProgressBar(playerid, TankHeatBar);
	DestroyPlayerProgressBar(playerid, ActionBar);
	DestroyPlayerProgressBar(playerid, KnockoutBar);
}

public OnPlayerOpenInventory(playerid)
{
	TextDrawHideForPlayer(playerid, MapCover1);
	TextDrawHideForPlayer(playerid, MapCover2);

	return CallLocalFunction("SSS_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory SSS_OnPlayerOpenInventory
forward OnPlayerOpenInventory(playerid);

public OnPlayerCloseInventory(playerid)
{
	TextDrawShowForPlayer(playerid, MapCover1);
	TextDrawShowForPlayer(playerid, MapCover2);

	return CallLocalFunction("SSS_OnPlayerCloseInventory", "d", playerid);
}
#if defined _ALS_OnPlayerCloseInventory
	#undef OnPlayerCloseInventory
#else
	#define _ALS_OnPlayerCloseInventory
#endif
#define OnPlayerCloseInventory SSS_OnPlayerCloseInventory
forward OnPlayerCloseInventory(playerid);

public OnPlayerOpenContainer(playerid)
{
	TextDrawHideForPlayer(playerid, MapCover1);
	TextDrawHideForPlayer(playerid, MapCover2);

	return CallLocalFunction("SSS_OnPlayerOpenContainer", "d", playerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer SSS_OnPlayerOpenContainer
forward OnPlayerOpenContainer(playerid);

public OnPlayerCloseContainer(playerid)
{
	TextDrawShowForPlayer(playerid, MapCover1);
	TextDrawShowForPlayer(playerid, MapCover2);

	return CallLocalFunction("SSS_OnPlayerCloseContainer", "d", playerid);
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer SSS_OnPlayerCloseContainer
forward OnPlayerCloseContainer(playerid);

public OnButtonPress(playerid, buttonid)
{
	return 0;
}

public OnPlayerPickedUpItem(playerid, itemid)
{
}

public OnPlayerActivateCheckpoint(playerid, checkpointid)
{
	return 1;
}


public OnDynamicObjectMoved(objectid)
{
	return 1;
}

stock GetPlayersOnline()
{
	new p;
	foreach(new i : Player)p++;
	return p;
}
SetMapName(MapName[])
{
	new str[30];
	format(str,30,"mapname %s",MapName);
	SendRconCommand(str);
}


#define PreloadAnimLib(%1,%2) ApplyAnimation(%1,%2,"null",0.0,0,0,0,0,0)
PreloadPlayerAnims(playerid)
{
	PreloadAnimLib(playerid, "AIRPORT");
	PreloadAnimLib(playerid, "ATTRACTORS");
	PreloadAnimLib(playerid, "BAR");
	PreloadAnimLib(playerid, "BASEBALL");
	PreloadAnimLib(playerid, "BD_FIRE");
	PreloadAnimLib(playerid, "BEACH");
	PreloadAnimLib(playerid, "BENCHPRESS");
	PreloadAnimLib(playerid, "BF_INJECTION");
	PreloadAnimLib(playerid, "BIKED");
	PreloadAnimLib(playerid, "BIKEH");
	PreloadAnimLib(playerid, "BIKELEAP");
	PreloadAnimLib(playerid, "BIKES");
	PreloadAnimLib(playerid, "BIKEV");
	PreloadAnimLib(playerid, "BIKE_DBZ");
	PreloadAnimLib(playerid, "BMX");
	PreloadAnimLib(playerid, "BOMBER");
	PreloadAnimLib(playerid, "BOX");
	PreloadAnimLib(playerid, "BSKTBALL");
	PreloadAnimLib(playerid, "BUDDY");
	PreloadAnimLib(playerid, "BUS");
	PreloadAnimLib(playerid, "CAMERA");
	PreloadAnimLib(playerid, "CAR");
	PreloadAnimLib(playerid, "CARRY");
	PreloadAnimLib(playerid, "CAR_CHAT");
	PreloadAnimLib(playerid, "CASINO");
	PreloadAnimLib(playerid, "CHAINSAW");
	PreloadAnimLib(playerid, "CHOPPA");
	PreloadAnimLib(playerid, "CLOTHES");
	PreloadAnimLib(playerid, "COACH");
	PreloadAnimLib(playerid, "COLT45");
	PreloadAnimLib(playerid, "COP_AMBIENT");
	PreloadAnimLib(playerid, "COP_DVBYZ");
	PreloadAnimLib(playerid, "CRACK");
	PreloadAnimLib(playerid, "CRIB");
	PreloadAnimLib(playerid, "DAM_JUMP");
	PreloadAnimLib(playerid, "DANCING");
	PreloadAnimLib(playerid, "DEALER");
	PreloadAnimLib(playerid, "DILDO");
	PreloadAnimLib(playerid, "DODGE");
	PreloadAnimLib(playerid, "DOZER");
	PreloadAnimLib(playerid, "DRIVEBYS");
	PreloadAnimLib(playerid, "FAT");
	PreloadAnimLib(playerid, "FIGHT_B");
	PreloadAnimLib(playerid, "FIGHT_C");
	PreloadAnimLib(playerid, "FIGHT_D");
	PreloadAnimLib(playerid, "FIGHT_E");
	PreloadAnimLib(playerid, "FINALE");
	PreloadAnimLib(playerid, "FINALE2");
	PreloadAnimLib(playerid, "FLAME");
	PreloadAnimLib(playerid, "FLOWERS");
	PreloadAnimLib(playerid, "FOOD");
	PreloadAnimLib(playerid, "FREEWEIGHTS");
	PreloadAnimLib(playerid, "GANGS");
	PreloadAnimLib(playerid, "GHANDS");
	PreloadAnimLib(playerid, "GHETTO_DB");
	PreloadAnimLib(playerid, "GOGGLES");
	PreloadAnimLib(playerid, "GRAFFITI");
	PreloadAnimLib(playerid, "GRAVEYARD");
	PreloadAnimLib(playerid, "GRENADE");
	PreloadAnimLib(playerid, "GYMNASIUM");
	PreloadAnimLib(playerid, "HAIRCUTS");
	PreloadAnimLib(playerid, "HEIST9");
	PreloadAnimLib(playerid, "INT_HOUSE");
	PreloadAnimLib(playerid, "INT_OFFICE");
	PreloadAnimLib(playerid, "INT_SHOP");
	PreloadAnimLib(playerid, "JST_BUISNESS");
	PreloadAnimLib(playerid, "KART");
	PreloadAnimLib(playerid, "KISSING");
	PreloadAnimLib(playerid, "KNIFE");
	PreloadAnimLib(playerid, "LAPDAN1");
	PreloadAnimLib(playerid, "LAPDAN2");
	PreloadAnimLib(playerid, "LAPDAN3");
	PreloadAnimLib(playerid, "LOWRIDER");
	PreloadAnimLib(playerid, "MD_CHASE");
	PreloadAnimLib(playerid, "MD_END");
	PreloadAnimLib(playerid, "MEDIC");
	PreloadAnimLib(playerid, "MISC");
	PreloadAnimLib(playerid, "MTB");
	PreloadAnimLib(playerid, "MUSCULAR");
	PreloadAnimLib(playerid, "NEVADA");
	PreloadAnimLib(playerid, "ON_LOOKERS");
	PreloadAnimLib(playerid, "OTB");
	PreloadAnimLib(playerid, "PARACHUTE");
	PreloadAnimLib(playerid, "PARK");
	PreloadAnimLib(playerid, "PAULNMAC");
	PreloadAnimLib(playerid, "PED");
	PreloadAnimLib(playerid, "PLAYER_DVBYS");
	PreloadAnimLib(playerid, "PLAYIDLES");
	PreloadAnimLib(playerid, "POLICE");
	PreloadAnimLib(playerid, "POOL");
	PreloadAnimLib(playerid, "POOR");
	PreloadAnimLib(playerid, "PYTHON");
	PreloadAnimLib(playerid, "QUAD");
	PreloadAnimLib(playerid, "QUAD_DBZ");
	PreloadAnimLib(playerid, "RAPPING");
	PreloadAnimLib(playerid, "RIFLE");
	PreloadAnimLib(playerid, "RIOT");
	PreloadAnimLib(playerid, "ROB_BANK");
	PreloadAnimLib(playerid, "ROCKET");
	PreloadAnimLib(playerid, "RUSTLER");
	PreloadAnimLib(playerid, "RYDER");
	PreloadAnimLib(playerid, "SCRATCHING");
	PreloadAnimLib(playerid, "SHAMAL");
	PreloadAnimLib(playerid, "SHOP");
	PreloadAnimLib(playerid, "SHOTGUN");
	PreloadAnimLib(playerid, "SILENCED");
	PreloadAnimLib(playerid, "SKATE");
	PreloadAnimLib(playerid, "SMOKING");
	PreloadAnimLib(playerid, "SNIPER");
	PreloadAnimLib(playerid, "SPRAYCAN");
	PreloadAnimLib(playerid, "STRIP");
	PreloadAnimLib(playerid, "SUNBATHE");
	PreloadAnimLib(playerid, "SWAT");
	PreloadAnimLib(playerid, "SWEET");
	PreloadAnimLib(playerid, "SWIM");
	PreloadAnimLib(playerid, "SWORD");
	PreloadAnimLib(playerid, "TANK");
	PreloadAnimLib(playerid, "TATTOOS");
	PreloadAnimLib(playerid, "TEC");
	PreloadAnimLib(playerid, "TRAIN");
	PreloadAnimLib(playerid, "TRUCK");
	PreloadAnimLib(playerid, "UZI");
	PreloadAnimLib(playerid, "VAN");
	PreloadAnimLib(playerid, "VENDING");
	PreloadAnimLib(playerid, "VORTEX");
	PreloadAnimLib(playerid, "WAYFARER");
	PreloadAnimLib(playerid, "WEAPONS");
	PreloadAnimLib(playerid, "WUZI");
	PreloadAnimLib(playerid, "WOP");
	PreloadAnimLib(playerid, "GFUNK");
	PreloadAnimLib(playerid, "RUNNINGMAN");
}

stock CancelPlayerMovement(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(playerid, x, y, z);
	ClearAnimations(playerid);
}
FreezePlayer(playerid, time)
{
	TogglePlayerControllable(playerid, false);
	defer UnfreezePlayer(playerid, time);
}
timer UnfreezePlayer[time](playerid, time)
{
#pragma unused time
	TogglePlayerControllable(playerid, true);
}


forward sffa_msgbox(playerid, message[], time, width);
public sffa_msgbox(playerid, message[], time, width)
{
	ShowMsgBox(playerid, message, time, width);
}

IsPlayerDead(playerid)
{
	return bPlayerGameSettings[playerid] & Dying;
}

GetPlayerVehicleExitTick(playerid)
{
	return tick_ExitVehicle[playerid];
}
