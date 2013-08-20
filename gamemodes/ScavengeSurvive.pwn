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

//#define DB_DEBUG true
#define DB_MAX_STATEMENTS (48)

/*==============================================================================

	Libraries and respective links to their release pages

==============================================================================*/

#include <YSI\y_utils>				// By Y_Less:				http://forum.sa-mp.com/showthread.php?p=1696956
#include <YSI\y_va>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <YSI\y_iterate>
#include <YSI\y_ini>

#define DEFAULT_POS_X				(-907.5452)
#define DEFAULT_POS_Y				(272.7235)
#define DEFAULT_POS_Z				(1014.1449)

#include "SS/Core/Server/Hooks.pwn"

#include <sscanf2>					// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=120356
#include <streamer>					// By Incognito:			http://forum.sa-mp.com/showthread.php?t=102865

#include <sqlitei>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=303682
#include <formatex>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=313488
#include <strlib>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=362764
#include <md-sort>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=343172

#define result GeoIP_result
#include <GeoIP>					// By Whitetiger:			http://forum.sa-mp.com/showthread.php?t=296171
#undef result

#define time ctime_time
#include <CTime>					// By RyDeR:				http://forum.sa-mp.com/showthread.php?t=294054
#undef time

#include <playerprogress>			// By Torbido/Southclaw:	https://gist.github.com/Southclaw/5979661
#include <FileManager>				// By JaTochNietDan:		http://forum.sa-mp.com/showthread.php?t=92246
#include <SIF/SIF>					// By Southclaw:			https://github.com/Southclaw/SIF
#include <WeaponData>				// By Southclaw:			https://gist.github.com/Southclaw/5934397
#include <Balloon>					// By Southclaw:			https://gist.github.com/Southclaw/6254507
#include <Line>						// By Southclaw:			https://gist.github.com/Southclaw/6254512
#include <Zipline>					// By Southclaw:			https://gist.github.com/Southclaw/6254523
#include <Ladder>					// By Southclaw:			https://gist.github.com/Southclaw/6254527

native WP_Hash(buffer[], len, const str[]);
									// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=65290


//===================================================================Definitions


// Limits
#define MAX_MOTD_LEN				(128)
#define MAX_WEBSITE_NAME			(64)
#define MAX_PLAYER_FILE				(MAX_PLAYER_NAME+16)
#define MAX_ADMIN					(48)
#define MAX_PASSWORD_LEN			(129)
#define MAX_SERVER_UPTIME			(3600 * 5)
#define MAX_SPAWNED_VEHICLES		(250)


// Files
#define PLAYER_DATA_FILE			"SSS/Player/%s.dat"
#define PLAYER_ITEM_FILE			"SSS/Inventory/%s.inv"
#define ACCOUNT_DATABASE			"SSS/Accounts.db"
#define WORLD_DATABASE				"SSS/World.db"
#define SETTINGS_FILE				"SSS/settings.cfg"


// Database
#define ACCOUNTS_TABLE_PLAYER		"Player"
#define ACCOUNTS_TABLE_BANS			"Bans"
#define ACCOUNTS_TABLE_REPORTS		"Reports"
#define ACCOUNTS_TABLE_BUGS			"Bugs"
#define ACCOUNTS_TABLE_WHITELIST	"Whitelist"
#define ACCOUNTS_TABLE_ADMINS		"Admins"
#define WORLD_TABLE_SPRAYTAG		"SprayTag"

// Player
#define FIELD_PLAYER_NAME			"name"		// 00
#define FIELD_PLAYER_PASS			"pass"		// 01
#define FIELD_PLAYER_IPV4			"ipv4"		// 02
#define FIELD_PLAYER_ALIVE			"alive"		// 03
#define FIELD_PLAYER_SPAWN			"spawn"		// 04
#define FIELD_PLAYER_KARMA			"karma"		// 05
#define FIELD_PLAYER_REGDATE		"regdate"	// 06
#define FIELD_PLAYER_LASTLOG		"lastlog"	// 07
#define FIELD_PLAYER_SPAWNTIME		"spawntime"	// 08
#define FIELD_PLAYER_TOTALSPAWNS	"spawns"	// 19
#define FIELD_PLAYER_WARNINGS		"warnings"	// 10
#define FIELD_PLAYER_AIMSHOUT		"aimshout"	// 11

enum
{
	FIELD_ID_PLAYER_NAME,
	FIELD_ID_PLAYER_PASS,
	FIELD_ID_PLAYER_IPV4,
	FIELD_ID_PLAYER_ALIVE,
	FIELD_ID_PLAYER_SPAWN,
	FIELD_ID_PLAYER_KARMA,
	FIELD_ID_PLAYER_REGDATE,
	FIELD_ID_PLAYER_LASTLOG,
	FIELD_ID_PLAYER_SPAWNTIME,
	FIELD_ID_PLAYER_TOTALSPAWNS,
	FIELD_ID_PLAYER_WARNINGS,
	FIELD_ID_PLAYER_AIMSHOUT
}

// Bans
#define FIELD_BANS_NAME				"name"		// 00
#define FIELD_BANS_IPV4				"ipv4"		// 01
#define FIELD_BANS_DATE				"date"		// 02
#define FIELD_BANS_REASON			"reason"	// 03
#define FIELD_BANS_BY				"by"		// 04

enum
{
	FIELD_ID_BANS_NAME,
	FIELD_ID_BANS_IPV4,
	FIELD_ID_BANS_DATE,
	FIELD_ID_BANS_REASON,
	FIELD_ID_BANS_BY
}

// Reports
#define FIELD_REPORTS_NAME			"name"		// 00
#define FIELD_REPORTS_REASON		"reason"	// 01
#define FIELD_REPORTS_DATE			"date"		// 02
#define FIELD_REPORTS_READ			"read"		// 03
#define FIELD_REPORTS_TYPE			"type"		// 04
#define FIELD_REPORTS_POSX			"posx"		// 05
#define FIELD_REPORTS_POSY			"posy"		// 06
#define FIELD_REPORTS_POSZ			"posz"		// 07
#define FIELD_REPORTS_INFO			"info"		// 08
#define FIELD_REPORTS_BY			"by"		// 09

enum
{
	FIELD_ID_REPORTS_NAME,
	FIELD_ID_REPORTS_REASON,
	FIELD_ID_REPORTS_DATE,
	FIELD_ID_REPORTS_READ,
	FIELD_ID_REPORTS_TYPE,
	FIELD_ID_REPORTS_POSX,
	FIELD_ID_REPORTS_POSY,
	FIELD_ID_REPORTS_POSZ,
	FIELD_ID_REPORTS_INFO,
	FIELD_ID_REPORTS_BY
}

// Bugs
#define FIELD_BUGS_NAME				"name"		// 00
#define FIELD_BUGS_REASON			"reason"	// 01
#define FIELD_BUGS_DATE				"date"		// 02

enum
{
	FIELD_ID_BUGS_NAME,
	FIELD_ID_BUGS_REASON,
	FIELD_ID_BUGS_DATE
}

// Whitelist
#define FIELD_WHITELIST_NAME		"name"		// 00

// Admins
#define FIELD_ADMINS_NAME			"name"		// 00
#define FIELD_ADMINS_LEVEL			"level"		// 01

// SprayTag
#define FIELD_SPRAYTAG_NAME			"name"		// 00
#define FIELD_SPRAYTAG_POSX			"posx"		// 01
#define FIELD_SPRAYTAG_POSY			"posy"		// 02
#define FIELD_SPRAYTAG_POSZ			"posz"		// 03
#define FIELD_SPRAYTAG_ROTX			"rotx"		// 04
#define FIELD_SPRAYTAG_ROTY			"roty"		// 05
#define FIELD_SPRAYTAG_ROTZ			"rotz"		// 06

enum
{
	FIELD_ID_SPRAYTAG_NAME,
	FIELD_ID_SPRAYTAG_POSX,
	FIELD_ID_SPRAYTAG_POSY,
	FIELD_ID_SPRAYTAG_POSZ,
	FIELD_ID_SPRAYTAG_ROTX,
	FIELD_ID_SPRAYTAG_ROTY,
	FIELD_ID_SPRAYTAG_ROTZ
}


// Macros
#define t:%1<%2>					((%1)|=(%2))
#define f:%1<%2>					((%1)&=~(%2))

#define SetSpawn(%0,%1,%2,%3,%4)	SetSpawnInfo(%0, NO_TEAM, 0, %1, %2, %3, %4, 0,0,0,0,0,0)
#define GetFile(%0,%1)				format(%1, MAX_PLAYER_FILE, PLAYER_DATA_FILE, %0)
#define GetInvFile(%0,%1)			format(%1, MAX_PLAYER_FILE, PLAYER_ITEM_FILE, %0)

#define CMD:%1(%2)					forward cmd_%1(%2);\
									public cmd_%1(%2)

#define ACMD:%1[%2](%3)				forward cmd_%1_%2(%3);\
									public cmd_%1_%2(%3)

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


#define GENDER_MALE					(0)
#define GENDER_FEMALE				(1)

enum
{
	ATTACHSLOT_ITEM,		// 0 - Same as SIF/Item
	ATTACHSLOT_BAG,			// 1 - Bag on back
	ATTACHSLOT_USE,			// 2 - Item use temp slot
	ATTACHSLOT_HOLSTER,		// 3 - Item holstering
	ATTACHSLOT_HOLD,		// 4 - Unused
	ATTACHSLOT_CUFFS,		// 5 - Handcuff slot
	ATTACHSLOT_TORCH,		// 6 - Torch light slot
	ATTACHSLOT_HAT,			// 7 - Head-wear slot
	ATTACHSLOT_BLOOD,		// 8 - Bleeding particle effect
	ATTACHSLOT_ARMOUR		// 9 - Armour model slot
}

enum
{
	DRUG_TYPE_ANTIBIOTIC,	// 0 - Remove infection
	DRUG_TYPE_PAINKILL,		// 1 - +10 HP, 5 minutes no darkness or knockouts from low HP
	DRUG_TYPE_LSD,			// 2 - Weather effects
	DRUG_TYPE_AIR,			// 3 - Health loss and death
	DRUG_TYPE_MORPHINE,		// 4 - Shaky screen and health regen
	DRUG_TYPE_ADRENALINE,	// 5 - No knockouts, camera shaking and slow health regen
	DRUG_TYPE_HEROINE		// 6 - Weather effects
}

enum
{
	CHAT_MODE_LOCAL,		// 0 - Speak to players within chatbubble distance
	CHAT_MODE_GLOBAL,		// 1 - Speak to all players
	CHAT_MODE_RADIO,		// 2 - Speak to players on the same radio frequency
	CHAT_MODE_ADMIN			// 3 - Speak to admins
}


#define KEYTEXT_INTERACT			"~k~~VEHICLE_ENTER_EXIT~"
#define KEYTEXT_PUT_AWAY			"~k~~CONVERSATION_YES~"
#define KEYTEXT_DROP_ITEM			"~k~~CONVERSATION_NO~"
#define KEYTEXT_INVENTORY			"~k~~GROUP_CONTROL_BWD~"
#define KEYTEXT_ENGINE				"~k~~CONVERSATION_YES~"
#define KEYTEXT_LIGHTS				"~k~~CONVERSATION_NO~"
#define KEYTEXT_DOORS				"~k~~TOGGLE_SUBMISSIONS~"
#define KEYTEXT_RADIO				"R"


//==============================================================SERVER VARIABLES


// Dialog IDs
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
	d_GraveStone,

	d_ReportMenu,
	d_ReportPlayerList,
	d_ReportNameInput,
	d_ReportReason,

	d_ReportList,
	d_Report,
	d_ReportOptions,

	d_IssueSubmit,
	d_IssueList,
	d_Issue,

	d_DefenseSetPass,
	d_DefenseEnterPass,

	d_TransferAmmoToGun,
	d_TransferAmmoToBox,
	d_TransferAmmoGun2Gun,

	d_BanList,
	d_BanInfo,

	d_DetFieldList
}

// Keypad IDs
enum
{
	k_ControlTower,
	k_MainGate,
	k_AirstripGate,
	k_BlastDoor,
	k_Storage,
	k_StorageWatch,
	k_Lockup
}


new HORIZONTAL_RULE[] = {"-------------------------------------------------------------------------------------------------------------------------"};

//=====================Player Tag Names
new const AdminName[5][14]=
{
	"Player",			// 0
	"Game Master",		// 1
	"Moderator",		// 2
	"Administrator",	// 3
	"Developer"			// 4
},
AdminColours[5]=
{
	0xFFFFFFFF,			// 0
	0x5DFC0AFF,			// 1
	0x33CCFFAA,			// 2
	0x6600FFFF,			// 3
	0xFF0000FF			// 4
};


//=====================Server Global Settings
enum e_admin_data
{
	admin_Name[MAX_PLAYER_NAME],
	admin_Level
}


new
DB:				gAccounts,
DB:				gWorld,

// ACCOUNTS_TABLE_PLAYER
DBStatement:	gStmt_AccountExists,
DBStatement:	gStmt_AccountCreate,
DBStatement:	gStmt_AccountLoad,
DBStatement:	gStmt_AccountUpdate,
DBStatement:	gStmt_AccountDelete,
DBStatement:	gStmt_AccountSetPassword,
DBStatement:	gStmt_AccountSetIpv4,
DBStatement:	gStmt_AccountSetLastLog,
DBStatement:	gStmt_AccountSetSpawnTime,
DBStatement:	gStmt_AccountSetTotalSpawns,
DBStatement:	gStmt_AccountGetAliases,
DBStatement:	gStmt_AccountSetAimShout,

// ACCOUNTS_TABLE_BANS
DBStatement:	gStmt_BanInsert,
DBStatement:	gStmt_BanDelete,
DBStatement:	gStmt_BanGetFromNameIp,
DBStatement:	gStmt_BanGetList,
DBStatement:	gStmt_BanGetTotal,
DBStatement:	gStmt_BanGetInfo,
DBStatement:	gStmt_BanNameCheck,
DBStatement:	gStmt_BanUpdateIpv4,

// ACCOUNTS_TABLE_REPORTS
DBStatement:	gStmt_ReportInsert,
DBStatement:	gStmt_ReportDelete,
DBStatement:	gStmt_ReportDeleteName,
DBStatement:	gStmt_ReportNameExists,
DBStatement:	gStmt_ReportList,
DBStatement:	gStmt_ReportInfo,
DBStatement:	gStmt_ReportSetRead,
DBStatement:	gStmt_ReportGetUnread,

// ACCOUNTS_TABLE_BUGS
DBStatement:	gStmt_BugInsert,
DBStatement:	gStmt_BugDelete,
DBStatement:	gStmt_BugList,
DBStatement:	gStmt_BugTotal,
DBStatement:	gStmt_BugInfo,

// ACCOUNTS_TABLE_WHITELIST
DBStatement:	gStmt_WhitelistExists,
DBStatement:	gStmt_WhitelistInsert,
DBStatement:	gStmt_WhitelistDelete,

// ACCOUNTS_TABLE_ADMINS
DBStatement:	gStmt_AdminLoadAll,
DBStatement:	gStmt_AdminExists,
DBStatement:	gStmt_AdminInsert,
DBStatement:	gStmt_AdminUpdate,
DBStatement:	gStmt_AdminDelete,
DBStatement:	gStmt_AdminGetLevel,

// WORLD_TABLE_SPRAYTAG
DBStatement:	gStmt_SprayTagExists,
DBStatement:	gStmt_SprayTagInsert,
DBStatement:	gStmt_SprayTagLoad,
DBStatement:	gStmt_SprayTagSave;


new
		gMessageOfTheDay[MAX_MOTD_LEN],
		gWebsiteURL[MAX_WEBSITE_NAME],
		gGameModeName[32],
bool:	gWhitelist,
bool:	gPauseMap,
bool:	gInteriorEntry,
bool:	gPlayerAnimations,
Float:	gNameTagDistance,
		gCombatLogWindow,
		gLoginFreezeTime,
		gMaxTaboutTime,

		gAdminData[MAX_ADMIN][e_admin_data],
		gTotalAdmins,
		gServerUptime,
bool:	gServerRestarting,
		gPingLimit = 400;

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

//=====================Item Types
new stock
ItemType:		item_Parachute		= INVALID_ITEM_TYPE,
ItemType:		item_Medkit			= INVALID_ITEM_TYPE,
ItemType:		item_HardDrive		= INVALID_ITEM_TYPE,
ItemType:		item_Key			= INVALID_ITEM_TYPE,
// 50
ItemType:		item_FireworkBox	= INVALID_ITEM_TYPE,
ItemType:		item_FireLighter	= INVALID_ITEM_TYPE,
ItemType:		item_Timer			= INVALID_ITEM_TYPE,
ItemType:		item_Explosive		= INVALID_ITEM_TYPE,
ItemType:		item_TntTimebomb	= INVALID_ITEM_TYPE,
ItemType:		item_Battery		= INVALID_ITEM_TYPE,
ItemType:		item_Fusebox		= INVALID_ITEM_TYPE,
ItemType:		item_Bottle			= INVALID_ITEM_TYPE,
ItemType:		item_Sign			= INVALID_ITEM_TYPE,
ItemType:		item_Armour			= INVALID_ITEM_TYPE,
// 60
ItemType:		item_Bandage		= INVALID_ITEM_TYPE,
ItemType:		item_FishRod		= INVALID_ITEM_TYPE,
ItemType:		item_Wrench			= INVALID_ITEM_TYPE,
ItemType:		item_Crowbar		= INVALID_ITEM_TYPE,
ItemType:		item_Hammer			= INVALID_ITEM_TYPE,
ItemType:		item_Shield			= INVALID_ITEM_TYPE,
ItemType:		item_Flashlight		= INVALID_ITEM_TYPE,
ItemType:		item_Taser			= INVALID_ITEM_TYPE,
ItemType:		item_LaserPoint		= INVALID_ITEM_TYPE,
ItemType:		item_Screwdriver	= INVALID_ITEM_TYPE,
// 70
ItemType:		item_MobilePhone	= INVALID_ITEM_TYPE,
ItemType:		item_Pager			= INVALID_ITEM_TYPE,
ItemType:		item_Rake			= INVALID_ITEM_TYPE,
ItemType:		item_HotDog			= INVALID_ITEM_TYPE,
ItemType:		item_EasterEgg		= INVALID_ITEM_TYPE,
ItemType:		item_Cane			= INVALID_ITEM_TYPE,
ItemType:		item_HandCuffs		= INVALID_ITEM_TYPE,
ItemType:		item_Bucket			= INVALID_ITEM_TYPE,
ItemType:		item_GasMask		= INVALID_ITEM_TYPE,
ItemType:		item_Flag			= INVALID_ITEM_TYPE,
// 80
ItemType:		item_DoctorBag		= INVALID_ITEM_TYPE,
ItemType:		item_Backpack		= INVALID_ITEM_TYPE,
ItemType:		item_Satchel		= INVALID_ITEM_TYPE,
ItemType:		item_Wheel			= INVALID_ITEM_TYPE,
ItemType:		item_MotionSense	= INVALID_ITEM_TYPE,
ItemType:		item_Accelerometer	= INVALID_ITEM_TYPE,
ItemType:		item_TntProxMine	= INVALID_ITEM_TYPE,
ItemType:		item_IedBomb		= INVALID_ITEM_TYPE,
ItemType:		item_Pizza			= INVALID_ITEM_TYPE,
ItemType:		item_Burger			= INVALID_ITEM_TYPE,
// 90
ItemType:		item_BurgerBox		= INVALID_ITEM_TYPE,
ItemType:		item_Taco			= INVALID_ITEM_TYPE,
ItemType:		item_GasCan			= INVALID_ITEM_TYPE,
ItemType:		item_Clothes		= INVALID_ITEM_TYPE,
ItemType:		item_HelmArmy		= INVALID_ITEM_TYPE,
ItemType:		item_MediumBox		= INVALID_ITEM_TYPE,
ItemType:		item_SmallBox		= INVALID_ITEM_TYPE,
ItemType:		item_LargeBox		= INVALID_ITEM_TYPE,
ItemType:		item_AmmoTin		= INVALID_ITEM_TYPE,
ItemType:		item_Meat			= INVALID_ITEM_TYPE,
// 100
ItemType:		item_DeadLeg		= INVALID_ITEM_TYPE,
ItemType:		item_Torso			= INVALID_ITEM_TYPE,
ItemType:		item_LongPlank		= INVALID_ITEM_TYPE,
ItemType:		item_GreenGloop		= INVALID_ITEM_TYPE,
ItemType:		item_Capsule		= INVALID_ITEM_TYPE,
ItemType:		item_RadioPole		= INVALID_ITEM_TYPE,
ItemType:		item_SignShot		= INVALID_ITEM_TYPE,
ItemType:		item_Mailbox		= INVALID_ITEM_TYPE,
ItemType:		item_Pumpkin		= INVALID_ITEM_TYPE,
ItemType:		item_Nailbat		= INVALID_ITEM_TYPE,
// 110
ItemType:		item_ZorroMask		= INVALID_ITEM_TYPE,
ItemType:		item_Barbecue		= INVALID_ITEM_TYPE,
ItemType:		item_Headlight		= INVALID_ITEM_TYPE,
ItemType:		item_Pills			= INVALID_ITEM_TYPE,
ItemType:		item_AutoInjec		= INVALID_ITEM_TYPE,
ItemType:		item_BurgerBag		= INVALID_ITEM_TYPE,
ItemType:		item_CanDrink		= INVALID_ITEM_TYPE,
ItemType:		item_Detergent		= INVALID_ITEM_TYPE,
ItemType:		item_Dice			= INVALID_ITEM_TYPE,
ItemType:		item_Dynamite		= INVALID_ITEM_TYPE,
// 120
ItemType:		item_Door			= INVALID_ITEM_TYPE,
ItemType:		item_MetPanel		= INVALID_ITEM_TYPE,
ItemType:		item_SurfBoard		= INVALID_ITEM_TYPE,
ItemType:		item_CrateDoor		= INVALID_ITEM_TYPE,
ItemType:		item_CorPanel		= INVALID_ITEM_TYPE,
ItemType:		item_ShipDoor		= INVALID_ITEM_TYPE,
ItemType:		item_MetalPlate		= INVALID_ITEM_TYPE,
ItemType:		item_MetalStand		= INVALID_ITEM_TYPE,
ItemType:		item_WoodDoor		= INVALID_ITEM_TYPE,
ItemType:		item_WoodPanel		= INVALID_ITEM_TYPE,
// 130
ItemType:		item_Flare			= INVALID_ITEM_TYPE,
ItemType:		item_TntPhoneBomb	= INVALID_ITEM_TYPE,
ItemType:		item_ParaBag		= INVALID_ITEM_TYPE,
ItemType:		item_Keypad			= INVALID_ITEM_TYPE,
ItemType:		item_TentPack		= INVALID_ITEM_TYPE,
ItemType:		item_Campfire		= INVALID_ITEM_TYPE,
ItemType:		item_CowboyHat		= INVALID_ITEM_TYPE,
ItemType:		item_TruckCap		= INVALID_ITEM_TYPE,
ItemType:		item_BoaterHat		= INVALID_ITEM_TYPE,
ItemType:		item_BowlerHat		= INVALID_ITEM_TYPE,
// 140
ItemType:		item_PoliceCap		= INVALID_ITEM_TYPE,
ItemType:		item_TopHat			= INVALID_ITEM_TYPE,
ItemType:		item_Ammo9mm		= INVALID_ITEM_TYPE,
ItemType:		item_Ammo50			= INVALID_ITEM_TYPE,
ItemType:		item_AmmoBuck		= INVALID_ITEM_TYPE,
ItemType:		item_Ammo556		= INVALID_ITEM_TYPE,
ItemType:		item_Ammo357		= INVALID_ITEM_TYPE,
ItemType:		item_AmmoRocket		= INVALID_ITEM_TYPE,
ItemType:		item_MolotovEmpty	= INVALID_ITEM_TYPE,
ItemType:		item_Money			= INVALID_ITEM_TYPE,
// 150
ItemType:		item_PowerSupply	= INVALID_ITEM_TYPE,
ItemType:		item_StorageUnit	= INVALID_ITEM_TYPE,
ItemType:		item_Fluctuator		= INVALID_ITEM_TYPE,
ItemType:		item_IoUnit			= INVALID_ITEM_TYPE,
ItemType:		item_FluxCap		= INVALID_ITEM_TYPE,
ItemType:		item_DataInterface	= INVALID_ITEM_TYPE,
ItemType:		item_HackDevice		= INVALID_ITEM_TYPE,
ItemType:		item_PlantPot		= INVALID_ITEM_TYPE,
ItemType:		item_HerpDerp		= INVALID_ITEM_TYPE,
ItemType:		item_Parrot			= INVALID_ITEM_TYPE,
// 160
ItemType:		item_TntTripMine	= INVALID_ITEM_TYPE,
ItemType:		item_IedTimebomb	= INVALID_ITEM_TYPE,
ItemType:		item_IedProxMine	= INVALID_ITEM_TYPE,
ItemType:		item_IedTripMine	= INVALID_ITEM_TYPE,
ItemType:		item_IedPhoneBomb	= INVALID_ITEM_TYPE,
ItemType:		item_EmpTimebomb	= INVALID_ITEM_TYPE,
ItemType:		item_EmpProxMine	= INVALID_ITEM_TYPE,
ItemType:		item_EmpTripMine	= INVALID_ITEM_TYPE,
ItemType:		item_EmpPhoneBomb	= INVALID_ITEM_TYPE,
ItemType:		item_Gyroscope		= INVALID_ITEM_TYPE,
// 170
ItemType:		item_Motor			= INVALID_ITEM_TYPE,
ItemType:		item_StarterMotor	= INVALID_ITEM_TYPE,
ItemType:		item_FlareGun		= INVALID_ITEM_TYPE,
ItemType:		item_PetrolBomb		= INVALID_ITEM_TYPE,
ItemType:		item_CodePart		= INVALID_ITEM_TYPE,
ItemType:		item_LargeBackpack	= INVALID_ITEM_TYPE;


//=====================Menus and Textdraws
new
Text:			DeathText			= Text:INVALID_TEXT_DRAW,
Text:			DeathButton			= Text:INVALID_TEXT_DRAW,
Text:			RestartCount		= Text:INVALID_TEXT_DRAW,
Text:			HitMark_centre		= Text:INVALID_TEXT_DRAW,
Text:			HitMark_offset		= Text:INVALID_TEXT_DRAW,
Text:			Branding			= Text:INVALID_TEXT_DRAW,

PlayerText:		ClassBackGround		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		ClassButtonMale		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		ClassButtonFemale	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		WeaponAmmo			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		HungerBarBackground	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		HungerBarForeground	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		WatchBackground		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		WatchTime			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		WatchBear			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		WatchFreq			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		ToolTip				= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		HelpTipText			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleFuelText		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleDamageText	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleEngineText	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleDoorsText	= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleNameText		= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		VehicleSpeedText	= PlayerText:INVALID_TEXT_DRAW,

PlayerBar:		OverheatBar			= INVALID_PLAYER_BAR_ID,
PlayerBar:		ActionBar			= INVALID_PLAYER_BAR_ID,
PlayerBar:		KnockoutBar			= INVALID_PLAYER_BAR_ID,
				MiniMapOverlay;

//==============================================================PLAYER VARIABLES


forward OnLoad();
forward SetRestart(seconds);


//======================Library Predefinitions

#define NOTEBOOK_FILE			"SSS/Notebook/%s.dat"
#define MAX_NOTEBOOK_FILE_NAME	(MAX_PLAYER_NAME + 18)

//======================Utilities

#include "SS/utils/math.pwn"
#include "SS/utils/misc.pwn"
#include "SS/utils/camera.pwn"
#include "SS/utils/message.pwn"
#include "SS/utils/vehicle.pwn"
#include "SS/utils/vehicledata.pwn"
#include "SS/utils/vehicleparts.pwn"
#include "SS/utils/zones.pwn"
#include "SS/utils/player.pwn"
#include "SS/utils/object.pwn"

//======================SIF Module Scripts

#include <SIF/Modules/Craft.pwn>
#include <SIF/Modules/Notebook.pwn>

//======================Server Core

#include "SS/Core/Server/Settings.pwn"
#include "SS/Core/Server/TextTags.pwn"
#include "SS/Core/Server/Weather.pwn"
#include "SS/Core/Server/Whitelist.pwn"
#include "SS/Core/Server/SaveBlock.pwn"
#include "SS/Core/Server/ActivityLog.pwn"

//======================UI

#include "SS/Core/UI/PlayerUI.pwn"
#include "SS/Core/UI/GlobalUI.pwn"
#include "SS/Core/UI/HoldAction.pwn"
#include "SS/Core/UI/Radio.pwn"
#include "SS/Core/UI/TipText.pwn"
#include "SS/Core/UI/KeyActions.pwn"
#include "SS/Core/UI/ToolTips.pwn"
#include "SS/Core/UI/Watch.pwn"
#include "SS/Core/UI/Keypad.pwn"

//======================Game Data

#include "SS/Data/Vehicle.pwn"
#include "SS/Data/Weapon.pwn"
#include "SS/Data/Loot.pwn"

//======================Vehicle

#include "SS/Core/Vehicle/Core.pwn"
#include "SS/Core/Vehicle/Spawn.pwn"
#include "SS/Core/Vehicle/PlayerVehicle.pwn"
#include "SS/Core/Vehicle/Repair.pwn"

//======================Weapon

#include "SS/Core/Weapon/Core.pwn"

//======================Loot

#include "SS/Core/Loot/Spawn.pwn"
#include "SS/Core/Loot/HouseLoot.pwn"

//======================Player Core

#include "SS/Core/Player/Core.pwn"
#include "SS/Core/Player/Accounts.pwn"
#include "SS/Core/Player/SaveLoad.pwn"
#include "SS/Core/Player/Spawn.pwn"
#include "SS/Core/Player/Drugs.pwn"
#include "SS/Core/Player/Damage.pwn"
#include "SS/Core/Player/Death.pwn"
#include "SS/Core/Player/Tutorial.pwn"
#include "SS/Core/Player/WelcomeMessage.pwn"
#include "SS/Core/Player/AntiCombatLog.pwn"
#include "SS/Core/Player/Chat.pwn"
#include "SS/Core/Player/Command.pwn"
#include "SS/Core/Player/AfkCheck.pwn"
#include "SS/Core/Player/AltTabCheck.pwn"
#include "SS/Core/Player/DisallowActions.pwn"
#include "SS/Core/Player/Report.pwn"
#include "SS/Core/Player/HackDetect.pwn"
#include "SS/Core/Player/Profile.pwn"

//======================Character

#include "SS/Core/Char/Food.pwn"
#include "SS/Core/Char/Clothes.pwn"
#include "SS/Core/Char/Hats.pwn"
#include "SS/Core/Char/Inventory.pwn"
#include "SS/Core/Char/Animations.pwn"
#include "SS/Core/Char/MeleeItems.pwn"
#include "SS/Core/Char/KnockOut.pwn"
#include "SS/Core/Char/Disarm.pwn"
#include "SS/Core/Char/Overheat.pwn"
#include "SS/Core/Char/Towtruck.pwn"
#include "SS/Core/Char/Holster.pwn"
#include "SS/Core/Char/Infection.pwn"
#include "SS/Core/Char/Backpack.pwn"
#include "SS/Core/Char/HandCuffs.pwn"
#include "SS/Core/Char/Medical.pwn"
#include "SS/Core/Char/AimShout.pwn"

//======================World

#include "SS/Core/World/Fuel.pwn"
#include "SS/Core/World/Barbecue.pwn"
#include "SS/Core/World/Defenses.pwn"
#include "SS/Core/World/GraveStone.pwn"
#include "SS/Core/World/SafeBox.pwn"
#include "SS/Core/World/Carmour.pwn"
#include "SS/Core/World/Tent.pwn"
#include "SS/Core/World/Campfire.pwn"
#include "SS/Core/World/HackTrap.pwn"
#include "SS/Core/World/Workbench.pwn"
#include "SS/Core/World/Food.pwn"
#include "SS/Core/World/Emp.pwn"
#include "SS/Core/World/Explosive.pwn"
#include "SS/Core/World/SprayTag.pwn"
#include "SS/Core/World/Sign.pwn"

//======================Command Features

#include "SS/Core/Admin/Commands.pwn"
#include "SS/Core/Admin/GameMaster.pwn"
#include "SS/Core/Admin/Moderator.pwn"
#include "SS/Core/Admin/Administrator.pwn"
#include "SS/Core/Admin/Dev.pwn"
#include "SS/Core/Admin/Duty.pwn"
#include "SS/Core/Admin/Ban.pwn"
#include "SS/Core/Admin/Spectate.pwn"
#include "SS/Core/Admin/Core.pwn"
#include "SS/Core/Admin/BugReport.pwn"
#include "SS/Core/Admin/DetectionField.pwn"

//======================Items

#include "SS/Core/Item/firework.pwn"
#include "SS/Core/Item/bottle.pwn"
#include "SS/Core/Item/TntTimeBomb.pwn"
#include "SS/Core/Item/Sign.pwn"
#include "SS/Core/Item/shield.pwn"
#include "SS/Core/Item/HandCuffs.pwn"
#include "SS/Core/Item/wheel.pwn"
#include "SS/Core/Item/gascan.pwn"
#include "SS/Core/Item/flashlight.pwn"
#include "SS/Core/Item/armyhelm.pwn"
#include "SS/Core/Item/crowbar.pwn"
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
#include "SS/Core/Item/candrink.pwn"
#include "SS/Core/Item/TntProxMine.pwn"
#include "SS/Core/Item/IedTimebomb.pwn"
#include "SS/Core/Item/IedTripMine.pwn"
#include "SS/Core/Item/IedProxMine.pwn"
#include "SS/Core/Item/IedPhoneBomb.pwn"
#include "SS/Core/Item/EmpTimebomb.pwn"
#include "SS/Core/Item/EmpTripMine.pwn"
#include "SS/Core/Item/EmpProxMine.pwn"
#include "SS/Core/Item/EmpPhoneBomb.pwn"


//======================Post-code

#include "SS/Core/Server/Autosave.pwn"

//======================World

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
}




























public OnGameModeInit()
{
	print("Starting Main Game Script 'SSS' ...");

	gAccounts = db_open_persistent(ACCOUNT_DATABASE);
	gWorld = db_open_persistent(WORLD_DATABASE);

	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_PLAYER" ( \
		"FIELD_PLAYER_NAME" TEXT,\
		"FIELD_PLAYER_PASS" TEXT,\
		"FIELD_PLAYER_IPV4" INTEGER,\
		"FIELD_PLAYER_ALIVE" INTEGER,\
		"FIELD_PLAYER_SPAWN" TEXT,\
		"FIELD_PLAYER_KARMA" INTEGER,\
		"FIELD_PLAYER_REGDATE" INTEGER,\
		"FIELD_PLAYER_LASTLOG" INTEGER,\
		"FIELD_PLAYER_SPAWNTIME" INTEGER,\
		"FIELD_PLAYER_TOTALSPAWNS" INTEGER,\
		"FIELD_PLAYER_WARNINGS" INTEGER,\
		"FIELD_PLAYER_AIMSHOUT" TEXT\
		)"));

	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_BANS" ( \
		"FIELD_BANS_NAME" TEXT, \
		"FIELD_BANS_IPV4" INTEGER, \
		"FIELD_BANS_DATE" INTEGER, \
		"FIELD_BANS_REASON" TEXT, \
		"FIELD_BANS_BY" TEXT \
		)"));

	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_REPORTS" ( \
		"FIELD_REPORTS_NAME" TEXT, \
		"FIELD_REPORTS_REASON" TEXT, \
		"FIELD_REPORTS_DATE" INTEGER, \
		"FIELD_REPORTS_READ" INTEGER, \
		"FIELD_REPORTS_TYPE" INTEGER, \
		"FIELD_REPORTS_POSX" REAL, \
		"FIELD_REPORTS_POSY" REAL, \
		"FIELD_REPORTS_POSZ" REAL, \
		"FIELD_REPORTS_INFO" TEXT, \
		"FIELD_REPORTS_BY" TEXT \
		)"));

	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_BUGS" ( \
		"FIELD_BUGS_NAME" TEXT, \
		"FIELD_BUGS_REASON" TEXT, \
		"FIELD_BUGS_DATE" INTEGER \
		)"));

	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_WHITELIST" ( \
		"FIELD_WHITELIST_NAME" TEXT \
		)"));

	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_ADMINS" ( \
		"FIELD_ADMINS_NAME" TEXT, \
		"FIELD_ADMINS_LEVEL" INTEGER \
		)"));


	db_free_result(db_query(gWorld, "CREATE TABLE IF NOT EXISTS "WORLD_TABLE_SPRAYTAG" ( \
		"FIELD_SPRAYTAG_NAME" TEXT, \
		"FIELD_SPRAYTAG_POSX" REAL, \
		"FIELD_SPRAYTAG_POSY" REAL, \
		"FIELD_SPRAYTAG_POSZ" REAL, \
		"FIELD_SPRAYTAG_ROTX" REAL, \
		"FIELD_SPRAYTAG_ROTY" REAL, \
		"FIELD_SPRAYTAG_ROTZ" REAL \
		)"));

	gStmt_AccountExists			= db_prepare(gAccounts, "SELECT COUNT(*) FROM Player WHERE "FIELD_PLAYER_NAME" = ?");
	gStmt_AccountCreate			= db_prepare(gAccounts, "INSERT INTO Player VALUES(?, ?, ?, 0, '0.0, 0.0, 0.0, 0.0', 0, ?, ?, 0, 0, 0, ?)");
	gStmt_AccountLoad			= db_prepare(gAccounts, "SELECT * FROM Player WHERE "FIELD_PLAYER_NAME" = ?");
	gStmt_AccountUpdate			= db_prepare(gAccounts, "UPDATE Player SET "FIELD_PLAYER_ALIVE" = ?, "FIELD_PLAYER_SPAWN" = ?, "FIELD_PLAYER_KARMA" = ?, "FIELD_PLAYER_WARNINGS" = ? WHERE "FIELD_PLAYER_NAME" = ?");
	gStmt_AccountDelete			= db_prepare(gAccounts, "DELETE FROM Player WHERE "FIELD_PLAYER_NAME" = ?");
	gStmt_AccountSetPassword	= db_prepare(gAccounts, "UPDATE Player SET "FIELD_PLAYER_PASS" = ? WHERE "FIELD_PLAYER_NAME" = ?");
	gStmt_AccountSetIpv4		= db_prepare(gAccounts, "UPDATE Player SET "FIELD_PLAYER_IPV4" = ? WHERE "FIELD_PLAYER_NAME" = ?");
	gStmt_AccountSetLastLog		= db_prepare(gAccounts, "UPDATE Player SET "FIELD_PLAYER_LASTLOG" = ? WHERE "FIELD_PLAYER_NAME" = ?");
	gStmt_AccountSetSpawnTime	= db_prepare(gAccounts, "UPDATE Player SET "FIELD_PLAYER_SPAWNTIME" = ? WHERE "FIELD_PLAYER_NAME" = ?");
	gStmt_AccountSetTotalSpawns	= db_prepare(gAccounts, "UPDATE Player SET "FIELD_PLAYER_TOTALSPAWNS" = ? WHERE "FIELD_PLAYER_NAME" = ?");
	gStmt_AccountGetAliases		= db_prepare(gAccounts, "SELECT * FROM Player WHERE "FIELD_PLAYER_IPV4" = ? AND "FIELD_PLAYER_NAME" != ?");
	gStmt_AccountSetAimShout	= db_prepare(gAccounts, "UPDATE Player SET "FIELD_PLAYER_AIMSHOUT" = ? WHERE "FIELD_PLAYER_NAME" = ?");

	gStmt_BanInsert				= db_prepare(gAccounts, "INSERT INTO Bans VALUES(?, ?, ?, ?, ?)");
	gStmt_BanDelete				= db_prepare(gAccounts, "DELETE FROM Bans WHERE "FIELD_BANS_NAME" = ?");
	gStmt_BanGetFromNameIp		= db_prepare(gAccounts, "SELECT COUNT(*), "FIELD_BANS_DATE", "FIELD_BANS_REASON" FROM Bans WHERE LOWER("FIELD_BANS_NAME") = LOWER(?) OR "FIELD_BANS_IPV4" = ? ORDER BY "FIELD_BANS_DATE" DESC");
	gStmt_BanGetList			= db_prepare(gAccounts, "SELECT * FROM Bans ORDER BY "FIELD_BANS_DATE" DESC LIMIT ?, ?");
	gStmt_BanGetTotal			= db_prepare(gAccounts, "SELECT COUNT(*) FROM Bans");
	gStmt_BanGetInfo			= db_prepare(gAccounts, "SELECT * FROM Bans WHERE "FIELD_BANS_NAME" = ?");
	gStmt_BanNameCheck			= db_prepare(gAccounts, "SELECT COUNT(*) FROM Bans WHERE LOWER("FIELD_BANS_NAME") = LOWER(?) ORDER BY "FIELD_BANS_DATE" DESC");
	gStmt_BanUpdateIpv4			= db_prepare(gAccounts, "UPDATE Bans SET "FIELD_BANS_IPV4" = ? WHERE LOWER("FIELD_BANS_NAME") = LOWER(?) ORDER BY "FIELD_BANS_DATE" DESC");

	gStmt_ReportInsert			= db_prepare(gAccounts, "INSERT INTO Reports VALUES(?, ?, ?, '0', ?, ?, ?, ?, ?, ?)");
	gStmt_ReportDelete			= db_prepare(gAccounts, "DELETE FROM Reports WHERE "FIELD_REPORTS_NAME" = ? AND "FIELD_REPORTS_DATE" = ?");
	gStmt_ReportDeleteName		= db_prepare(gAccounts, "DELETE FROM Reports WHERE "FIELD_REPORTS_NAME" = ?");
	gStmt_ReportNameExists		= db_prepare(gAccounts, "SELECT COUNT(*) FROM Reports WHERE "FIELD_REPORTS_NAME" = ?");
	gStmt_ReportList			= db_prepare(gAccounts, "SELECT * FROM Reports");
	gStmt_ReportInfo			= db_prepare(gAccounts, "SELECT * FROM Reports WHERE "FIELD_REPORTS_NAME" = ? AND "FIELD_REPORTS_DATE" = ?");
	gStmt_ReportSetRead			= db_prepare(gAccounts, "UPDATE Reports SET "FIELD_REPORTS_READ" = ? WHERE "FIELD_REPORTS_NAME" = ? AND "FIELD_REPORTS_DATE" = ?");
	gStmt_ReportGetUnread		= db_prepare(gAccounts, "SELECT COUNT(*) FROM Reports WHERE "FIELD_REPORTS_READ" = 0");

	gStmt_BugInsert				= db_prepare(gAccounts, "INSERT INTO Bugs VALUES(?, ?, ?)");
	gStmt_BugDelete				= db_prepare(gAccounts, "DELETE FROM Bugs WHERE "FIELD_BUGS_DATE" = ?");
	gStmt_BugList				= db_prepare(gAccounts, "SELECT * FROM Bugs");
	gStmt_BugTotal				= db_prepare(gAccounts, "SELECT COUNT(*) FROM Bugs");
	gStmt_BugInfo				= db_prepare(gAccounts, "SELECT * FROM Bugs WHERE "FIELD_BUGS_DATE" = ?");

	gStmt_WhitelistExists		= db_prepare(gAccounts, "SELECT COUNT(*) FROM Whitelist WHERE "FIELD_WHITELIST_NAME" = ?");
	gStmt_WhitelistInsert		= db_prepare(gAccounts, "INSERT INTO Whitelist ("FIELD_WHITELIST_NAME") VALUES(?)");
	gStmt_WhitelistDelete		= db_prepare(gAccounts, "DELETE FROM Whitelist WHERE "FIELD_WHITELIST_NAME" = ?");

	gStmt_AdminLoadAll			= db_prepare(gAccounts, "SELECT * FROM Admins");
	gStmt_AdminExists			= db_prepare(gAccounts, "SELECT COUNT(*) FROM Admins WHERE "FIELD_ADMINS_NAME" = ?");
	gStmt_AdminInsert			= db_prepare(gAccounts, "INSERT INTO Admins VALUES(?, ?)");
	gStmt_AdminUpdate			= db_prepare(gAccounts, "UPDATE Admins SET "FIELD_ADMINS_LEVEL" = ? WHERE "FIELD_ADMINS_NAME" = ?");
	gStmt_AdminDelete			= db_prepare(gAccounts, "DELETE FROM Admins WHERE "FIELD_ADMINS_NAME" = ?");
	gStmt_AdminGetLevel			= db_prepare(gAccounts, "SELECT * FROM Admins WHERE "FIELD_ADMINS_NAME" = ?");

	gStmt_SprayTagExists		= db_prepare(gWorld, "SELECT COUNT(*) FROM SprayTag WHERE "FIELD_SPRAYTAG_POSX" = ? AND "FIELD_SPRAYTAG_POSY" = ? AND "FIELD_SPRAYTAG_POSZ" = ?");
	gStmt_SprayTagInsert		= db_prepare(gWorld, "INSERT INTO SprayTag VALUES(?, ?, ?, ?, ?, ?, ?)");
	gStmt_SprayTagLoad			= db_prepare(gWorld, "SELECT * FROM SprayTag");
	gStmt_SprayTagSave			= db_prepare(gWorld, "UPDATE SprayTag SET "FIELD_SPRAYTAG_NAME" = ? WHERE "FIELD_SPRAYTAG_POSX" = ? AND "FIELD_SPRAYTAG_POSY" = ? AND "FIELD_SPRAYTAG_POSZ" = ? ");

	LoadSettings();

	SendRconCommand(sprintf("mapname %s", gMapName));

	item_Parachute		= DefineItemType("Parachute",			371,	ITEM_SIZE_MEDIUM,	90.0, 0.0, 0.0,			0.0,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000);
	item_Medkit			= DefineItemType("Medkit",				1580,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_HardDrive		= DefineItemType("Hard Drive",			328,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0);
	item_Key			= DefineItemType("Key",					327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
// 50
	item_FireworkBox	= DefineItemType("Fireworks",			2039,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.096996, 0.044811, 0.035688, 4.759557, 255.625167, 0.000000);
	item_FireLighter	= DefineItemType("Lighter",				327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_Timer			= DefineItemType("Timer Device",		2922,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.231612, 0.050027, 0.017069, 0.000000, 343.020019, 180.000000);
	item_Explosive		= DefineItemType("TNT",					1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_TntTimebomb	= DefineItemType("Time Bomb",			1252,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0);
	item_Battery		= DefineItemType("Battery",				1579,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_Fusebox		= DefineItemType("Fuse Box",			328,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0);
	item_Bottle			= DefineItemType("Bottle",				1543,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.060376, 0.032063, -0.204802, 0.000000, 0.000000, 0.000000);
	item_Sign			= DefineItemType("Sign",				19471,	ITEM_SIZE_LARGE,	0.0, 0.0, 270.0,		0.0);
	item_Armour			= DefineItemType("Armour",				19515,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.300333, -0.090105, 0.000000, 0.000000, 0.000000, 180.000000);
// 60
	item_Bandage		= DefineItemType("Bandage",				1575,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_FishRod		= DefineItemType("Fishing Rod",			18632,	ITEM_SIZE_LARGE,	90.0, 0.0, 0.0,			0.0,	0.091496, 0.019614, 0.000000, 185.619995, 354.958374, 0.000000);
	item_Wrench			= DefineItemType("Wrench",				18633,	ITEM_SIZE_SMALL,	0.0, 90.0, 0.0,			0.0,	0.084695, -0.009181, 0.152275, 98.865089, 270.085449, 0.000000);
	item_Crowbar		= DefineItemType("Crowbar",				18634,	ITEM_SIZE_SMALL,	0.0, 90.0, 0.0,			0.0,	0.066177, 0.011153, 0.038410, 97.289527, 270.962554, 1.114514);
	item_Hammer			= DefineItemType("Hammer",				18635,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0,	0.000000, -0.008230, 0.000000, 6.428617, 0.000000, 0.000000);
	item_Shield			= DefineItemType("Shield",				18637,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	-0.262389, 0.016478, -0.151046, 103.597534, 6.474381, 38.321765);
	item_Flashlight		= DefineItemType("Flashlight",			18641,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.061910, 0.022700, 0.039052, 190.938354, 0.000000, 0.000000);
	item_Taser			= DefineItemType("Taser",				18642,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.079878, 0.014009, 0.029525, 180.000000, 0.000000, 0.000000);
	item_LaserPoint		= DefineItemType("Laser Pointer",		18643,	ITEM_SIZE_SMALL,	0.0, 0.0, 90.0,			0.0,	0.066244, 0.010838, -0.000024, 6.443027, 287.441467, 0.000000);
	item_Screwdriver	= DefineItemType("Screwdriver",			18644,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.099341, 0.021018, 0.009145, 193.644195, 0.000000, 0.000000);
// 70
	item_MobilePhone	= DefineItemType("Mobile Phone",		18865,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.103904, -0.003697, -0.015173, 94.655189, 184.031860, 0.000000);
	item_Pager			= DefineItemType("Pager",				18875,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.097277, 0.027625, 0.013023, 90.819244, 191.427993, 0.000000);
	item_Rake			= DefineItemType("Rake",				18890,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	-0.002599, 0.003984, 0.026356, 190.231231, 0.222518, 271.565185);
	item_HotDog			= DefineItemType("Hotdog",				19346,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.088718, 0.035828, 0.008570, 272.851745, 354.704772, 9.342185);
	item_EasterEgg		= DefineItemType("Easter Egg",			19345,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.000000, 0.000000, 0.000000, 0.000000, 90.000000, 0.000000);
	item_Cane			= DefineItemType("Cane",				19348,	ITEM_SIZE_MEDIUM,	270.0, 0.0, 0.0,		0.0,	0.041865, 0.022883, -0.079726, 4.967216, 10.411237, 0.000000);
	item_HandCuffs		= DefineItemType("Handcuffs",			19418,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0,	0.077635, 0.011612, 0.000000, 0.000000, 90.000000, 0.000000);
	item_Bucket			= DefineItemType("Bucket",				19468,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.293691, -0.074108, 0.020810, 148.961685, 280.067260, 151.782791);
	item_GasMask		= DefineItemType("Gas Mask",			19472,	ITEM_SIZE_SMALL,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000);
	item_Flag			= DefineItemType("Flag",				2993,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.045789, 0.026306, -0.078802, 8.777217, 0.272155, 0.000000);
// 80
	item_DoctorBag		= DefineItemType("Doctor's Bag",		1210,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 90.0,			0.0,	0.285915, 0.078406, -0.009429, 0.000000, 270.000000, 0.000000);
	item_Backpack		= DefineItemType("Backpack",			3026,	ITEM_SIZE_MEDIUM,	270.0, 0.0, 90.0,		0.0,	0.470918, 0.150153, 0.055384, 181.319580, 7.513789, 163.436065);
	item_Satchel		= DefineItemType("Small Bag",			363,	ITEM_SIZE_MEDIUM,	270.0, 0.0, 0.0,		0.0,	0.052853, 0.034967, -0.177413, 0.000000, 261.397491, 349.759826);
	item_Wheel			= DefineItemType("Wheel",				1079,	ITEM_SIZE_CARRY,	0.0, 0.0, 90.0,			0.436,	-0.098016, 0.356168, -0.309851, 258.455596, 346.618103, 354.313049);
	item_MotionSense	= DefineItemType("Motion Sensor",		327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.008151, 0.012682, -0.050635, 0.000000, 0.000000, 0.000000);
	item_Accelerometer	= DefineItemType("Accelerometer",		327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.008151, 0.012682, -0.050635, 0.000000, 0.000000, 0.000000);
	item_TntProxMine	= DefineItemType("Proximity Mine",		1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_IedBomb		= DefineItemType("IED",					2033,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891);
	item_Pizza			= DefineItemType("Pizza",				1582,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.320344, 0.064041, 0.168296, 92.941909, 358.492523, 14.915378);
	item_Burger			= DefineItemType("Burger",				2703,	ITEM_SIZE_SMALL,	-76.0, 257.0, -11.0,	0.0,	0.066739, 0.041782, 0.026828, 3.703052, 3.163064, 6.946474);
// 90
	item_BurgerBox		= DefineItemType("Burger",				2768,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.107883, 0.093265, 0.029676, 91.010627, 7.522015, 0.000000);
	item_Taco			= DefineItemType("Taco",				2769,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.069803, 0.057707, 0.039241, 0.000000, 78.877342, 0.000000);
	item_GasCan			= DefineItemType("Petrol Can",			1650,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.27,	0.143402, 0.027548, 0.063652, 0.000000, 253.648208, 0.000000);
	item_Clothes		= DefineItemType("Clothes",				2891,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_HelmArmy		= DefineItemType("Army Helmet",			19106,	ITEM_SIZE_MEDIUM,	345.0, 270.0, 0.0,		0.045,	0.184999, -0.007999, 0.046999, 94.199989, 22.700027, 4.799994);
	item_MediumBox		= DefineItemType("Medium Box",			3014,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.1844,	-0.027872, 0.145617, -0.246524, 243.789840, 347.397491, 349.931610);
	item_SmallBox		= DefineItemType("Small Box",			2969,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.114177, 0.089762, -0.173014, 247.160079, 354.746368, 79.219100);
	item_LargeBox		= DefineItemType("Large Box",			1271,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.3112,	0.050000, 0.334999, -0.327000,  -23.900018, -10.200002, 11.799987);
	item_AmmoTin		= DefineItemType("Ammo Tin",			2040,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Meat			= DefineItemType("Meat",				2804,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	-0.051398, 0.017334, 0.189188, 270.495391, 353.340423, 167.069869);
// 100
	item_DeadLeg		= DefineItemType("Leg",					2905,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.147815, 0.052444, -0.164205, 253.163970, 358.857666, 167.069869);
	item_Torso			= DefineItemType("Torso",				2907,	ITEM_SIZE_CARRY,	0.0, 0.0, 270.0,		0.0,	0.087207, 0.093263, -0.280867, 253.355865, 355.971557, 175.203552);
	item_LongPlank		= DefineItemType("Plank",				2937,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.141491, 0.002142, -0.190920, 248.561920, 350.667724, 175.203552);
	item_GreenGloop		= DefineItemType("Unknown",				2976,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.063387, 0.013771, -0.595982, 341.793945, 352.972686, 226.892105);
	item_Capsule		= DefineItemType("Capsule",				3082,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.096439, 0.034642, -0.313377, 341.793945, 348.492706, 240.265777);
	item_RadioPole		= DefineItemType("Receiver",			3221,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777);
	item_SignShot		= DefineItemType("Sign",				3265,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777);
	item_Mailbox		= DefineItemType("Mailbox",				3407,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777);
	item_Pumpkin		= DefineItemType("Pumpkin",				19320,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.3,	0.105948, 0.279332, -0.253927, 246.858016, 0.000000, 0.000000);
	item_Nailbat		= DefineItemType("Nailbat",				2045,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0);
// 110
	item_ZorroMask		= DefineItemType("Zorro Mask",			18974,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.193932, 0.050861, 0.017257, 90.000000, 0.000000, 0.000000);
	item_Barbecue		= DefineItemType("BBQ",					1481,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0, 			0.6745,	0.106261, 0.004634, -0.144552, 246.614654, 345.892211, 258.267395);
	item_Headlight		= DefineItemType("Headlight",			19280,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.107282, 0.051477, 0.023807, 0.000000, 259.073913, 351.287475);
	item_Pills			= DefineItemType("Pills",				2709,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.09,	0.044038, 0.082106, 0.000000, 0.000000, 0.000000, 0.000000);
	item_AutoInjec		= DefineItemType("Injector",			2711,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.028,	0.145485, 0.020127, 0.034870, 0.000000, 260.512817, 349.967254);
	item_BurgerBag		= DefineItemType("Burger",				2663,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.205,	0.320356, 0.042146, 0.049817, 0.000000, 260.512817, 349.967254);
	item_CanDrink		= DefineItemType("Can",					2601,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.054,	0.064848, 0.059404, 0.017578, 0.000000, 359.136199, 30.178396);
	item_Detergent		= DefineItemType("Detergent",			1644,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.1,	0.081913, 0.047686, -0.026389, 95.526962, 0.546049, 358.890563);
	item_Dice			= DefineItemType("Dice",				1851,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.136,	0.031958, 0.131180, -0.214385, 69.012298, 16.103448, 10.308629);
	item_Dynamite		= DefineItemType("Dynamite",			1654,	ITEM_SIZE_MEDIUM);
// 120
	item_Door			= DefineItemType("Door",				1497,	ITEM_SIZE_CARRY,	90.0, 90.0, 0.0,		0.0,	0.313428, -0.507642, -1.340901, 336.984893, 348.837493, 113.141563);
	item_MetPanel		= DefineItemType("Metal Panel",			1965,	ITEM_SIZE_CARRY,	0.0, 90.0, 0.0,			0.0,	0.070050, 0.008440, -0.180277, 338.515014, 349.801025, 33.250347);
	item_SurfBoard		= DefineItemType("Surfboard",			2410,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	-0.033293, 0.167523, -0.333268, 79.455276, 123.749847, 77.635063);
	item_CrateDoor		= DefineItemType("Crate Door",			2678,	ITEM_SIZE_CARRY,	90.0, 90.0, 0.0,		0.0,	0.077393, 0.015846, -0.013984, 337.887634, 172.861953, 68.495330);
	item_CorPanel		= DefineItemType("Metal Sheet",			2904,	ITEM_SIZE_CARRY,	90.0, 90.0, 0.0,		0.0,	-0.365094, 1.004213, -0.665850, 337.887634, 172.861953, 68.495330);
	item_ShipDoor		= DefineItemType("Ship Door",			2944,	ITEM_SIZE_CARRY,	180.0, 90.0, 0.0,		0.0,	0.134831, -0.039784, -0.298796, 337.887634, 172.861953, 162.198867);
	item_MetalPlate		= DefineItemType("Metal Sheet",			2952,	ITEM_SIZE_CARRY,	180.0, 90.0, 0.0,		0.0,	-0.087715, 0.483874, 1.109397, 337.887634, 172.861953, 162.198867);
	item_MetalStand		= DefineItemType("Metal Plate",			2978,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	-0.106182, 0.534724, -0.363847, 278.598419, 68.350570, 57.954662);
	item_WoodDoor		= DefineItemType("Wood Panel",			3093,	ITEM_SIZE_CARRY,	0.0, 90.0, 0.0,			0.0,	0.117928, -0.025927, -0.203919, 339.650421, 168.808807, 337.216766);
	item_WoodPanel		= DefineItemType("Wood Panel",			5153,	ITEM_SIZE_CARRY,	360.0, 23.537, 0.0,		0.0,	-0.342762, 0.908910, -0.453703, 296.326019, 46.126548, 226.118209);
// 130
	item_Flare			= DefineItemType("Flare",				345,	ITEM_SIZE_SMALL);
	item_TntPhoneBomb	= DefineItemType("Phone Remote Bomb",	1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_ParaBag		= DefineItemType("Parachute Bag",		371,	ITEM_SIZE_MEDIUM,	90.0, 0.0, 0.0,			0.0,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000);
	item_Keypad			= DefineItemType("Keypad",				19273,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000);
	item_TentPack		= DefineItemType("Tent Pack",			1279,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.106261, 0.004634, -0.144552, 246.614654, 345.892211, 258.267395);
	item_Campfire		= DefineItemType("Campfire",			19475,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.106261, 0.004634, -0.144552, 246.614654, 345.892211, 258.267395);
	item_CowboyHat		= DefineItemType("Cowboy Hat",			18962,	ITEM_SIZE_MEDIUM,	0.0, 270.0, 0.0,		0.0427,	0.232999, 0.032000, 0.016000, 0.000000, 2.700027, -67.300010);
	item_TruckCap		= DefineItemType("Trucker Cap",			18961,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.01,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954);
	item_BoaterHat		= DefineItemType("Boater Hat",			18946,	ITEM_SIZE_MEDIUM,	-12.18, 268.14, 0.0,	0.318,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954);
	item_BowlerHat		= DefineItemType("Bowler Hat",			18947,	ITEM_SIZE_MEDIUM,	-12.18, 268.14, 0.0,	0.01,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954);
//140
	item_PoliceCap		= DefineItemType("Police Cap",			18636,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.318,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954);
	item_TopHat			= DefineItemType("Top Hat",				19352,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			-0.023,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954);
	item_Ammo9mm		= DefineItemType("9mm Rounds",			2037,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo50			= DefineItemType(".50 Rounds",			2037,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_AmmoBuck		= DefineItemType("Buckshot Shells",		2038,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo556		= DefineItemType("5.56 Rounds",			2040,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo357		= DefineItemType(".357 Rounds",			2039,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_AmmoRocket		= DefineItemType("Rockets",				3016,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	0.081998, 0.081005, -0.195033, 247.160079, 336.014343, 347.379638);
	item_MolotovEmpty	= DefineItemType("Empty Molotov",		344,	ITEM_SIZE_SMALL,	-4.0, 0.0, 0.0,			0.1728,	0.000000, -0.004999, 0.000000,  0.000000, 0.000000, 0.000000);
	item_Money			= DefineItemType("Pre-War Money",		1212,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.133999, 0.022000, 0.018000,  -90.700004, -11.199998, -101.600013);
// 150
	item_PowerSupply	= DefineItemType("Power Supply",		3016,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.255000, -0.054000, 0.032000, -87.499984, -7.599999, -7.999998);
	item_StorageUnit	= DefineItemType("Storage Unit",		328,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_Fluctuator		= DefineItemType("Fluctuator Unit",		343,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_IoUnit			= DefineItemType("I/O Unit",			19273,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000);
	item_FluxCap		= DefineItemType("Flux Capacitor",		343,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_DataInterface	= DefineItemType("Data Interface",		19273,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000);
	item_HackDevice		= DefineItemType("Hack Interface",		364,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.134000, 0.080000, -0.037000,  84.299949, 3.399998, 9.400002);
	item_PlantPot		= DefineItemType("Plant Pot",			2203,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.138,	-0.027872, 0.145617, -0.246524, 243.789840, 347.397491, 349.931610);
	item_HerpDerp		= DefineItemType("Derpification Unit",	19513,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.103904, -0.003697, -0.015173, 94.655189, 184.031860, 0.000000);
	item_Parrot			= DefineItemType("Sebastian",			19078,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.131000, 0.021000, 0.005999,  -86.000091, 6.700000, -106.300018);
// 160
	item_TntTripMine	= DefineItemType("Trip Mine",			1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_IedTimebomb	= DefineItemType("Timed IED",			2033,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891);
	item_IedProxMine	= DefineItemType("Proximity IED",		2033,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891);
	item_IedTripMine	= DefineItemType("Trip Mine IED",		2033,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891);
	item_IedPhoneBomb	= DefineItemType("Phone Remote IED",	2033,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891);
	item_EmpTimebomb	= DefineItemType("Timed EMP",			343,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_EmpProxMine	= DefineItemType("Proximity EMP",		343,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_EmpTripMine	= DefineItemType("Trip Mine EMP",		343,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_EmpPhoneBomb	= DefineItemType("Phone Remote EMP",	343,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_Gyroscope		= DefineItemType("Gyroscope Unit",		1945,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.180000, 0.085000, 0.009000,  -86.099967, -112.099975, 92.699890);
// 170
	item_Motor			= DefineItemType("Motor",				2006,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.129999, 0.087999, 0.009000,  -86.099967, -112.099975, 92.699890);
	item_StarterMotor	= DefineItemType("Starter Motor",		2006,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.129999, 0.087999, 0.009000,  -86.099967, -112.099975, 92.699890);
	item_FlareGun		= DefineItemType("Flare Gun",			2034,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.160999, 0.035000, 0.058999,  84.400062, 0.000000, 0.000000);
	item_PetrolBomb		= DefineItemType("Petrol Bomb",			1650,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.27,	0.143402, 0.027548, 0.063652, 0.000000, 253.648208, 0.000000);
	item_CodePart		= DefineItemType("Code",				1898,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.02,	0.086999, 0.017999, 0.075999,  0.000000, 0.000000, 100.700019);
	item_LargeBackpack	= DefineItemType("Large Backpack",		3026,	ITEM_SIZE_MEDIUM,	270.0, 0.0, 90.0,		0.0,	0.470918, 0.150153, 0.055384, 181.319580, 7.513789, 163.436065, 0xFFF4A460);


// 1656 - CUBOID SHAPE, CARRY ITEM
// 1719 - SMALL COMPUTER TYPE DEVICE
// 1898 - SMALL SPIN CLICKER
// 1899 - VERY SMALL SINGLE CHIP
// 1901 - SMALL BLUE CHIPS STACK
// 1952 - SMALL RECORD NEEDLE
// 1960 - RECORD
// 2060 - SANDBAG
// 2277 - PICTURE OF A CAT
// 2352 - T SHAPED SMALL OBJ
// 2590 - SPIKEY HOOK, SCHYTHE?


	SetItemTypeHolsterable(ItemType:03,	1, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");		// Baton
	SetItemTypeHolsterable(ItemType:08,	1, 0.123097, -0.129424, -0.139251, 0.000000, 301.455871, 0.000000, 300, "PED",		"PHONE_IN");		// Sword
	SetItemTypeHolsterable(ItemType:22,	8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");		// M9
	SetItemTypeHolsterable(ItemType:23,	8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");		// M9 SD
	SetItemTypeHolsterable(ItemType:24,	8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");		// Desert Eagle
	SetItemTypeHolsterable(ItemType:25,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");	// Shotgun
	SetItemTypeHolsterable(ItemType:26,	8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");		// Sawnoff
	SetItemTypeHolsterable(ItemType:27,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");	// Spas 12
	SetItemTypeHolsterable(ItemType:28,	8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");		// Mac 10
	SetItemTypeHolsterable(ItemType:29,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");	// MP5
	SetItemTypeHolsterable(ItemType:30,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");	// AK-47
	SetItemTypeHolsterable(ItemType:31,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");	// M16
	SetItemTypeHolsterable(ItemType:32,	8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");		// Tec 9
	SetItemTypeHolsterable(ItemType:33,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");	// Rifle
	SetItemTypeHolsterable(ItemType:34,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");	// Sniper
	SetItemTypeHolsterable(ItemType:35,	1, 0.181966, -0.238397, -0.094830, 252.7912, 353.8938, 357.5294, 800,	"GOGGLES",	"GOGGLES_PUT_ON");	// RPG
	SetItemTypeHolsterable(ItemType:36,	1, 0.181966, -0.238397, -0.094830, 252.7912, 353.8938, 357.5294, 800,	"GOGGLES",	"GOGGLES_PUT_ON");	// Heatseeker

	SetItemTypeHolsterable(item_Taser,	8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");		// Taser
	SetItemTypeHolsterable(item_Shield,	1, 0.027000, -0.039999, 0.170000, 270.0000, -171.0000, 90.0000, 300,	"GOGGLES",	"GOGGLES_PUT_ON");	// Shield


	anim_Blunt = DefineAnimSet();
	anim_Stab = DefineAnimSet();

	AddAnimToSet(anim_Blunt, 26, 3.0);
	AddAnimToSet(anim_Blunt, 17, 4.0);
	AddAnimToSet(anim_Blunt, 18, 6.0);
	AddAnimToSet(anim_Blunt, 19, 8.0);
	AddAnimToSet(anim_Stab, 751, 18.8);

	SetItemAnimSet(item_Wrench,			anim_Blunt);
	SetItemAnimSet(item_Crowbar,		anim_Blunt);
	SetItemAnimSet(item_Hammer,			anim_Blunt);
	SetItemAnimSet(item_Rake,			anim_Blunt);
	SetItemAnimSet(item_Cane,			anim_Blunt);
	SetItemAnimSet(item_Taser,			anim_Stab);
	SetItemAnimSet(item_Screwdriver,	anim_Stab);


	DefineFoodItem(item_HotDog,			20.0, 1, 0);
	DefineFoodItem(item_Pizza,			50.0, 0, 0);
	DefineFoodItem(item_Burger,			25.0, 1, 0);
	DefineFoodItem(item_BurgerBox,		25.0, 0, 0);
	DefineFoodItem(item_Taco,			15.0, 0, 0);
	DefineFoodItem(item_BurgerBag,		30.0, 0, 0);
	DefineFoodItem(item_Meat,			65.0, 1, 0);
	DefineFoodItem(item_Bottle,			1.0, 0, 1);
	DefineFoodItem(item_CanDrink,		1.0, 0, 1);


	DefineDefenseItem(item_Door,		180.0000, 90.0000, 0.0000, -0.0331,		2, 1, 0);
	DefineDefenseItem(item_MetPanel,	90.0000, 90.0000, 0.0000, -0.0092,		4, 1, 1);
	DefineDefenseItem(item_SurfBoard,	90.0000, 0.0000, 0.0000, 0.2650,		2, 1, 1);
	DefineDefenseItem(item_CrateDoor,	0.0000, 90.0000, 0.0000, 0.7287,		6, 1, 1);
	DefineDefenseItem(item_CorPanel,	0.0000, 90.0000, 0.0000, 1.1859,		4, 1, 1);
	DefineDefenseItem(item_ShipDoor,	90.0000, 90.0000, 0.0000, 1.3966,		8, 1, 1);
	DefineDefenseItem(item_MetalPlate,	90.0000, 90.0000, 0.0000, 2.1143,		8, 1, 1);
	DefineDefenseItem(item_MetalStand,	90.0000, 0.0000, 0.0000, 0.5998,		6, 1, 1);
	DefineDefenseItem(item_WoodDoor,	90.0000, 90.0000, 0.0000, -0.0160,		2, 1, 0);
	DefineDefenseItem(item_WoodPanel,	90.0000, 0.0000, 20.0000, 1.0284,		6, 1, 1);


	DefineItemCombo(item_Medkit,		item_Bandage,		item_DoctorBag);
	DefineItemCombo(ItemType:4,			item_Parachute,		item_ParaBag,		.returnitem1 = 0, .returnitem2 = 1);
	DefineItemCombo(item_Bottle,		item_Bandage,		item_MolotovEmpty);

	DefineItemCombo(item_FireworkBox,	item_PowerSupply,	item_IedBomb);
	DefineItemCombo(item_Explosive,		item_Timer,			item_TntTimebomb);
	DefineItemCombo(item_Explosive,		item_Accelerometer,	item_TntTripMine);
	DefineItemCombo(item_Explosive,		item_MotionSense,	item_TntProxMine);
	DefineItemCombo(item_Explosive,		item_MobilePhone,	item_TntPhoneBomb);
	DefineItemCombo(item_IedBomb,		item_Timer,			item_IedTimebomb);
	DefineItemCombo(item_IedBomb,		item_Accelerometer,	item_IedTripMine);
	DefineItemCombo(item_IedBomb,		item_MotionSense,	item_IedProxMine);
	DefineItemCombo(item_IedBomb,		item_MobilePhone,	item_IedPhoneBomb);
	DefineItemCombo(item_Fluctuator,	item_Timer,			item_EmpTimebomb);
	DefineItemCombo(item_Fluctuator,	item_Accelerometer,	item_EmpTripMine);
	DefineItemCombo(item_Fluctuator,	item_MotionSense,	item_EmpProxMine);
	DefineItemCombo(item_Fluctuator,	item_MobilePhone,	item_EmpPhoneBomb);

	DefineItemCombo(item_MediumBox,		item_MediumBox,		item_Campfire);
	DefineItemCombo(item_SmallBox,		item_MediumBox,		item_Campfire);
	DefineItemCombo(item_SmallBox,		item_SmallBox,		item_Campfire);

	DefineItemCombo(item_Battery,		item_Fusebox,		item_PowerSupply);
	DefineItemCombo(item_Timer,			item_HardDrive,		item_StorageUnit);
	DefineItemCombo(item_Taser,			item_RadioPole,		item_Fluctuator);
	DefineItemCombo(item_MobilePhone,	item_Keypad,		item_IoUnit);
	DefineItemCombo(item_PowerSupply,	item_Fluctuator,	item_FluxCap);
	DefineItemCombo(item_StorageUnit,	item_IoUnit,		item_DataInterface);
	DefineItemCombo(item_FluxCap,		item_DataInterface,	item_HackDevice);
	//WriteAllCombosToFile();


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


	skin_MainM	= DefineClothesType(60,		"Civilian",			0, 0.0);
	skin_MainF	= DefineClothesType(192,	"Civilian",			1, 0.0);

	skin_Civ1M	= DefineClothesType(170,	"Civilian",			0, 1.0);
	skin_Civ2M	= DefineClothesType(188,	"Civilian",			0, 1.0);
	skin_Civ3M	= DefineClothesType(44,		"Civilian",			0, 1.0);
	skin_Civ4M	= DefineClothesType(206,	"Civilian",			0, 1.0);
	skin_MechM	= DefineClothesType(50,		"Mechanic",			0, 0.6);
	skin_BikeM	= DefineClothesType(254,	"Biker",			0, 0.3);
	skin_ArmyM	= DefineClothesType(287,	"Military",			0, 0.2);
	skin_ClawM	= DefineClothesType(101,	"Southclaw",		0, 0.1);
	skin_FreeM	= DefineClothesType(156,	"Morgan Freeman",	0, 0.01);

	skin_Civ1F	= DefineClothesType(65,		"Civilian",			1, 0.8);
	skin_Civ2F	= DefineClothesType(93,		"Civilian",			1, 0.8);
	skin_Civ3F	= DefineClothesType(233,	"Civilian",			1, 0.8);
	skin_Civ4F	= DefineClothesType(193,	"Civilian",			1, 0.8);
	skin_ArmyF	= DefineClothesType(191,	"Military",			1, 0.2);
	skin_IndiF	= DefineClothesType(131,	"Indian",			1, 0.1);

	DefineSafeboxType("Medium Box",		item_MediumBox,		6, 6, 3, 2);
	DefineSafeboxType("Small Box", 		item_SmallBox,		4, 2, 1, 0);
	DefineSafeboxType("Large Box", 		item_LargeBox,		10, 8, 6, 6);
	DefineSafeboxType("Capsule", 		item_Capsule,		2, 2, 0, 0);

	DefineBagType("Backpack", 			item_Backpack,		8, 4, 1, 0, -0.110900, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Small Bag", 			item_Satchel,		4, 2, 1, 0, 0.241894, -0.160918, 0.181463, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Parachute Bag", 		item_ParaBag,		6, 4, 2, 0, 0.039470, -0.088898, -0.009887, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Large Backpack",		item_LargeBackpack,	9, 5, 2, 0, -0.2209, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.2000000, 1.300000, 1.100000);


	// Initiation Code

	CallLocalFunction("OnLoad", "");

	// Data From Files

	LoadAdminData();
	LoadVehicles();
	LoadSafeboxes(true);
	LoadTents(true);
	LoadDefenses();
	LoadSprayTags();


	for(new i; i < MAX_PLAYERS; i++)
	{
		ResetVariables(i);
	}

	defer AutoSave();

	return 1;
}

public OnGameModeExit()
{
	SavePlayerVehicles();
	SaveSafeboxes(true);
	SaveTents(true);
	SaveDefenses();
	SaveSprayTags();

	print("\nSave Complete! Safe to shut down.");

	return 1;
}

public SetRestart(seconds)
{
	printf("Restarting server in: %ds", seconds);
	gServerUptime = MAX_SERVER_UPTIME - seconds;
}

RestartGamemode()
{
	gServerRestarting = true;

	foreach(new i : Player)
	{
		Logout(i);
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
	MsgAll(BLUE, HORIZONTAL_RULE);
	MsgAll(YELLOW, " >  The Server Is Restarting, Please Wait...");
	MsgAll(BLUE, HORIZONTAL_RULE);
}

task GameUpdate[1000]()
{
	if(gServerUptime >= MAX_SERVER_UPTIME)
	{
		RestartGamemode();
	}

	if(gServerUptime >= MAX_SERVER_UPTIME - 3600)
	{
		new str[36];
		format(str, 36, "Server Restarting In:~n~%02d:%02d", (MAX_SERVER_UPTIME - gServerUptime) / 60, (MAX_SERVER_UPTIME - gServerUptime) % 60);
		TextDrawSetString(RestartCount, str);
		TextDrawShowForAll(RestartCount);
	}

	WeatherUpdate();

	gServerUptime++;
}

task GlobalAnnouncement[600000]()
{
	MsgAll(YELLOW, " >  Confused? Check out the Wiki: "#C_ORANGE"scavenge-survive.wikia.com "#C_YELLOW"or: "#C_ORANGE"empire-bay.com");
}
