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

#define DEFAULT_POS_X				(-907.5452)
#define DEFAULT_POS_Y				(272.7235)
#define DEFAULT_POS_Z				(1014.1449)

#include "../scripts/SSS/Server/HackDetect.pwn"

#include <formatex>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=313488
#include <strlib>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=362764
#include <md-sort>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=343172

#define result GeoIP_result
#include <GeoIP>					// By Whitetiger:			http://forum.sa-mp.com/showthread.php?t=296171
#undef result

#include <sscanf2>					// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=120356
#include <streamer>					// By Incognito:			http://forum.sa-mp.com/showthread.php?t=102865

#define time ctime_time
#include <CTime>					// By RyDeR:				http://forum.sa-mp.com/showthread.php?t=294054
#undef time

#include <IniFiles>					// By Southclaw:			http://forum.sa-mp.com/showthread.php?t=262795
#include <bar>						// By Torbido:				http://forum.sa-mp.com/showthread.php?t=113443
#include <playerbar>				// By Torbido/Southclaw:	http://pastebin.com/ZuLPd1K6
#include <CameraMover>				// By Southclaw:			http://forum.sa-mp.com/showthread.php?t=329813
#include <FileManager>				// By JaTochNietDan:		http://forum.sa-mp.com/showthread.php?t=92246
#include <SIF/SIF>					// By Southclaw:			https://github.com/Southclaw/SIF
#include <WeaponData>				// By Southclaw:			http://pastebin.com/ZGTr32Fv


native WP_Hash(buffer[], len, const str[]);


//===================================================================Definitions


// Limits
#define MAX_MOTD_LEN				(128)
#define MAX_PLAYER_FILE				(MAX_PLAYER_NAME+16)
#define MAX_ADMIN					(32)
#define MAX_PASSWORD_LEN			(129)
#define MAX_SERVER_UPTIME			(3600 * 5)


// Files
#define PLAYER_DATA_FILE			"SSS/Player/%s.dat"
#define PLAYER_ITEM_FILE			"SSS/Inventory/%s.inv"
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
#define ROW_READ					"read"


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


enum
{
	ATTACHSLOT_ITEM,		// 0
	ATTACHSLOT_BAG,			// 1
	ATTACHSLOT_USE,			// 2
	ATTACHSLOT_HOLSTER,		// 3
	ATTACHSLOT_HOLD,		// 4
	ATTACHSLOT_CUFFS,		// 5
	ATTACHSLOT_TORCH,		// 6
	ATTACHSLOT_HAT,			// 7
	ATTACHSLOT_BLOOD		// 8
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
	d_BanInfo
}

// Keypad IDs
enum
{
	k_ControlTower,
	k_MainGate,
	k_AirstripGate,
	k_BlastDoor,
	k_Storage,
	k_StorageWatch
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
	gTotalAdmins,
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
ItemType:		item_Timebomb		= INVALID_ITEM_TYPE,
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
ItemType:		item_CapCase		= INVALID_ITEM_TYPE,
ItemType:		item_MotionMine		= INVALID_ITEM_TYPE,
ItemType:		item_CapMine		= INVALID_ITEM_TYPE,
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
ItemType:		item_PhoneBomb		= INVALID_ITEM_TYPE,
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
ItemType:		item_PlantPot		= INVALID_ITEM_TYPE;


//=====================Menus and Textdraws
new
Text:			DeathText			= Text:INVALID_TEXT_DRAW,
Text:			DeathButton			= Text:INVALID_TEXT_DRAW,
Text:			RestartCount		= Text:INVALID_TEXT_DRAW,
Text:			HitMark_centre		= Text:INVALID_TEXT_DRAW,
Text:			HitMark_offset		= Text:INVALID_TEXT_DRAW,

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
PlayerText:		AddHPText			= PlayerText:INVALID_TEXT_DRAW,
PlayerText:		AddScoreText		= PlayerText:INVALID_TEXT_DRAW,

PlayerBar:		OverheatBar			= INVALID_PLAYER_BAR_ID,
PlayerBar:		ActionBar			= INVALID_PLAYER_BAR_ID,
PlayerBar:		KnockoutBar			= INVALID_PLAYER_BAR_ID,
				MiniMapOverlay;

//==============================================================PLAYER VARIABLES


enum (<<= 1) // 14
{
		HasAccount = 1,
		IsVip,
		LoggedIn,
		LoadedData,
		IsNewPlayer,
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
		Infected,
		GlobalQuiet,

		Frozen,
		Muted,

		DebugMode
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
Float:	ply_rotZ,
		ply_stance
}
enum
{
	CHAT_MODE_LOCAL,
	CHAT_MODE_GLOBAL,
	CHAT_MODE_RADIO
}


new
DB:		gAccounts,
		gPlayerPassAttempts		[MAX_PLAYERS],
		gPlayerWarnings			[MAX_PLAYERS],

		gPlayerData				[MAX_PLAYERS][E_PLAYER_DATA],
		bPlayerGameSettings		[MAX_PLAYERS],

		gPlayerName				[MAX_PLAYERS][MAX_PLAYER_NAME],
Float:	gPlayerHP				[MAX_PLAYERS],
Float:	gPlayerAP				[MAX_PLAYERS],
Float:	gPlayerFP				[MAX_PLAYERS],
Float:	gPlayerFrequency		[MAX_PLAYERS],
		gPlayerChatMode			[MAX_PLAYERS],
		gPlayerVehicleID		[MAX_PLAYERS],
Float:	gPlayerVelocity			[MAX_PLAYERS],
Float:	gCurrentVelocity		[MAX_PLAYERS],
		gPingLimitStrikes		[MAX_PLAYERS],
		gPlayerSpecTarget		[MAX_PLAYERS],

		gScreenBoxFadeLevel		[MAX_PLAYERS],
Float:	gPlayerDeathPos			[MAX_PLAYERS][4],

		tick_ServerJoin			[MAX_PLAYERS],
		tick_Spawn				[MAX_PLAYERS],
		tick_LastDamaged		[MAX_PLAYERS],
		tick_WeaponHit			[MAX_PLAYERS],
		tick_ExitVehicle		[MAX_PLAYERS],
		tick_LastChatMessage	[MAX_PLAYERS],
		tick_LastInfectionFX	[MAX_PLAYERS],
		ChatMessageStreak		[MAX_PLAYERS],
		ChatMuteTick			[MAX_PLAYERS];



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
#include "../scripts/utils/player.pwn"

//======================Hooks

#include "../scripts/SSS/Server/DisallowActions.pwn"
#include "../scripts/SSS/Server/DataCollection.pwn"
#include "../scripts/SSS/Server/BugReport.pwn"

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

//======================Server Core

#include "../scripts/SSS/Server/TextTags.pwn"
#include "../scripts/SSS/Server/Weather.pwn"
#include "../scripts/SSS/Server/Whitelist.pwn"

//======================Player Core

#include "../scripts/SSS/Player/Core.pwn"
#include "../scripts/SSS/Player/Accounts.pwn"
#include "../scripts/SSS/Player/SaveLoad.pwn"
#include "../scripts/SSS/Player/Spawn.pwn"
#include "../scripts/SSS/Player/Drugs.pwn"
#include "../scripts/SSS/Player/Damage.pwn"
#include "../scripts/SSS/Player/Death.pwn"
#include "../scripts/SSS/Player/Tutorial.pwn"
#include "../scripts/SSS/Player/WelcomeMessage.pwn"
#include "../scripts/SSS/Player/CombatLog.pwn"

//======================Data Load

#include "../scripts/SSS/Weapon/Data.pwn"
#include "../scripts/SSS/Loot/Data.pwn"
#include "../scripts/SSS/Loot/HouseLoot.pwn"
#include "../scripts/SSS/Vehicle/Data.pwn"

//======================Data Setup

#include "../scripts/SSS/Weapon/Core.pwn"
#include "../scripts/SSS/Loot/Spawn.pwn"
#include "../scripts/SSS/Vehicle/Spawn.pwn"
#include "../scripts/SSS/Vehicle/Core.pwn"

//======================UI

#include "../scripts/SSS/UI/HoldAction.pwn"
#include "../scripts/SSS/UI/Radio.pwn"
#include "../scripts/SSS/UI/TipText.pwn"
#include "../scripts/SSS/UI/ToolTipEvents.pwn"
#include "../scripts/SSS/UI/Watch.pwn"
#include "../scripts/SSS/UI/Keypad.pwn"

//======================Character

#include "../scripts/SSS/Char/Food.pwn"
#include "../scripts/SSS/Char/Clothes.pwn"
#include "../scripts/SSS/Char/Hats.pwn"
#include "../scripts/SSS/Char/Inventory.pwn"
#include "../scripts/SSS/Char/Animations.pwn"
#include "../scripts/SSS/Char/MeleeItems.pwn"
#include "../scripts/SSS/Char/KnockOut.pwn"
#include "../scripts/SSS/Char/Disarm.pwn"
#include "../scripts/SSS/Char/Overheat.pwn"
#include "../scripts/SSS/Char/Towtruck.pwn"
#include "../scripts/SSS/Char/Holster.pwn"

//======================World

#include "../scripts/SSS/World/Fuel.pwn"
#include "../scripts/SSS/World/Barbecue.pwn"
#include "../scripts/SSS/World/Defenses.pwn"
#include "../scripts/SSS/World/GraveStone.pwn"
#include "../scripts/SSS/World/SafeBox.pwn"
#include "../scripts/SSS/World/Carmour.pwn"
#include "../scripts/SSS/World/Tent.pwn"
#include "../scripts/SSS/World/Campfire.pwn"
#include "../scripts/SSS/World/HackTrap.pwn"

//======================Per-Area Item Spawning

#include "../scripts/SSS/Areas/LS.pwn"
#include "../scripts/SSS/Areas/SF.pwn"
#include "../scripts/SSS/Areas/LV.pwn"
#include "../scripts/SSS/Areas/RC.pwn"
#include "../scripts/SSS/Areas/FC.pwn"
#include "../scripts/SSS/Areas/BC.pwn"
#include "../scripts/SSS/Areas/TR.pwn"

//======================Admin code

#include "../scripts/SSS/Cmds/Core.pwn"
#include "../scripts/SSS/Cmds/Commands.pwn"
#include "../scripts/SSS/Cmds/Moderator.pwn"
#include "../scripts/SSS/Cmds/Administrator.pwn"
#include "../scripts/SSS/Cmds/Dev.pwn"
#include "../scripts/SSS/Cmds/Duty.pwn"
#include "../scripts/SSS/Cmds/Report.pwn"
#include "../scripts/SSS/Cmds/Ban.pwn"
#include "../scripts/SSS/Cmds/Spectate.pwn"

//======================Items

#include "../scripts/Items/firework.pwn"
#include "../scripts/Items/bottle.pwn"
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
#include "../scripts/Items/injector.pwn"
#include "../scripts/Items/medical.pwn"
#include "../scripts/Items/phonebomb.pwn"
#include "../scripts/Items/motionmine.pwn"
#include "../scripts/Items/parachute.pwn"
#include "../scripts/Items/molotov.pwn"
#include "../scripts/Items/screwdriver.pwn"
#include "../scripts/Items/torso.pwn"
#include "../scripts/Items/ammotin.pwn"
#include "../scripts/Items/tentpack.pwn"
#include "../scripts/Items/campfire.pwn"
#include "../scripts/Items/cowboyhat.pwn"
#include "../scripts/Items/truckcap.pwn"
#include "../scripts/Items/boaterhat.pwn"
#include "../scripts/Items/bowlerhat.pwn"
#include "../scripts/Items/policecap.pwn"
#include "../scripts/Items/tophat.pwn"

//======================Map Scripts

//#include "../scripts/SSS/Maps/LockboxLV.pwn"
#include "../scripts/SSS/Maps/Area69.pwn"
#include "../scripts/SSS/Maps/Ranch.pwn"
#include "../scripts/SSS/Maps/MtChill.pwn"

//======================Post-code

#include "../scripts/SSS/Server/Autosave.pwn"


main()
{
	new
		DBResult:tmpResult,
		rowCount;

	gAccounts = db_open(ACCOUNT_DATABASE);

	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Player` (`"#ROW_NAME"`, `"#ROW_PASS"`, `"#ROW_IPV4"`, `"#ROW_ALIVE"`, `"#ROW_GEND"`, `"#ROW_SPAWN"`, `"#ROW_ISVIP"`)"));
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Bans` (`"#ROW_NAME"`, `"#ROW_IPV4"`, `"#ROW_DATE"`, `"#ROW_REAS"`, `"#ROW_BNBY"`)"));
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Reports` (`"#ROW_NAME"`, `"#ROW_REAS"`, `"#ROW_DATE"`, `"#ROW_READ"`)"));
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Bugs` (`"#ROW_NAME"`, `"#ROW_REAS"`, `"#ROW_DATE"`)"));
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS `Whitelist` (`"#ROW_NAME"`)"));

	tmpResult = db_query(gAccounts, "SELECT * FROM `Player`");
	rowCount = db_num_rows(tmpResult);

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
	SetNameTagDrawDistance(0.0);
	UsePlayerPedAnims();
	AllowInteriorWeapons(true);
	DisableInteriorEnterExits();
	ShowNameTags(false);

	MiniMapOverlay = GangZoneCreate(-6000, -6000, 6000, 6000);

	if(!fexist(SETTINGS_FILE))
	{
		file_Create(SETTINGS_FILE);
	}
	else
	{
		file_Open(SETTINGS_FILE);
		file_GetStr("motd", gMessageOfTheDay);
		file_Close();
	}

	if(!fexist(ADMIN_DATA_FILE))
	{
		file_Create(ADMIN_DATA_FILE);
	}
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

	item_Parachute		= DefineItemType("Parachute",			371,	ITEM_SIZE_MEDIUM,	90.0, 0.0, 0.0,			0.0,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000);
	item_Medkit			= DefineItemType("Medkit",				1580,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_HardDrive		= DefineItemType("Hard Drive",			328,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0);
	item_Key			= DefineItemType("Key",					327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
// 50
	item_FireworkBox	= DefineItemType("Fireworks",			2039,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.096996, 0.044811, 0.035688, 4.759557, 255.625167, 0.000000);
	item_FireLighter	= DefineItemType("Lighter",				327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_Timer			= DefineItemType("Timer Device",		2922,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.231612, 0.050027, 0.017069, 0.000000, 343.020019, 180.000000);
	item_Explosive		= DefineItemType("Explosive",			1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_Timebomb		= DefineItemType("Time Bomb",			1252,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0);
	item_Battery		= DefineItemType("Battery",				2040,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082);
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
	item_CapCase		= DefineItemType("Cap Case",			1213,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.191558, 0.000000, 0.040402, 90.000000, 0.000000, 0.000000);
	item_MotionMine		= DefineItemType("Motion Mine",			1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_CapMine		= DefineItemType("Cap Mine",			1213,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.262021, 0.014938, 0.000000, 279.040191, 352.944946, 358.980987);
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
	item_WoodPanel		= DefineItemType("Wood Panel",			5153,	ITEM_SIZE_CARRY,	360.209, 23.537, 0.0,	0.0,	-0.342762, 0.908910, -0.453703, 296.326019, 46.126548, 226.118209);
// 130
	item_Flare			= DefineItemType("Flare",				345,	ITEM_SIZE_SMALL);
	item_PhoneBomb		= DefineItemType("Phone Bomb",			1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
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
	item_Ammo357		= DefineItemType(".338 Rounds",			2039,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
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


	anim_Blunt = DefineAnimSet();
	anim_Stab = DefineAnimSet();

	AddAnimToSet(anim_Blunt, 17, 22, 7.0);
	AddAnimToSet(anim_Blunt, 18, 23, 9.0);
	AddAnimToSet(anim_Blunt, 19, 24, 11.0);
	AddAnimToSet(anim_Stab, 751, 756, 37.8);

	SetItemAnimSet(item_Wrench,			anim_Blunt);
	SetItemAnimSet(item_Crowbar,		anim_Blunt);
	SetItemAnimSet(item_Hammer,			anim_Blunt);
	SetItemAnimSet(item_Rake,			anim_Blunt);
	SetItemAnimSet(item_Cane,			anim_Blunt);
	SetItemAnimSet(item_Taser,			anim_Stab);
	SetItemAnimSet(item_Screwdriver,	anim_Stab);


	DefineFoodItem(item_HotDog,			30.0, 1);
	DefineFoodItem(item_Pizza,			60.0, 0);
	DefineFoodItem(item_Burger,			35.0, 1);
	DefineFoodItem(item_BurgerBox,		35.0, 0);
	DefineFoodItem(item_Taco,			30.0, 0);
	DefineFoodItem(item_BurgerBag,		45.0, 0);
	DefineFoodItem(item_Meat,			75.0, 1);


	DefineDefenseItem(item_Door,		180.0000, 90.0000, 0.0000, -0.0331,		1, 1, 0);
	DefineDefenseItem(item_MetPanel,	90.0000, 90.0000, 0.0000, -0.0092,		2, 1, 1);
	DefineDefenseItem(item_SurfBoard,	90.0000, 0.0000, 0.0000, 0.2650,		1, 1, 1);
	DefineDefenseItem(item_CrateDoor,	0.0000, 90.0000, 0.0000, 0.7287,		3, 1, 1);
	DefineDefenseItem(item_CorPanel,	0.0000, 90.0000, 0.0000, 1.1859,		2, 1, 1);
	DefineDefenseItem(item_ShipDoor,	90.0000, 90.0000, 0.0000, 1.3966,		4, 1, 1);
	DefineDefenseItem(item_MetalPlate,	90.0000, 90.0000, 0.0000, 2.1143,		4, 1, 1);
	DefineDefenseItem(item_MetalStand,	90.0000, 0.0000, 0.0000, 0.5998,		3, 1, 1);
	DefineDefenseItem(item_WoodDoor,	90.0000, 90.0000, 0.0000, -0.0160,		1, 1, 0);
	DefineDefenseItem(item_WoodPanel,	90.0000, 0.0000, 20.0000, 1.0284,		3, 1, 1);


	DefineItemCombo(item_Explosive,		item_Timer,			item_Timebomb);
	DefineItemCombo(item_Explosive,		item_MotionSense,	item_MotionMine);
	DefineItemCombo(item_Explosive,		item_MobilePhone,	item_PhoneBomb);
	DefineItemCombo(item_Medkit,		item_Bandage,		item_DoctorBag);
	DefineItemCombo(ItemType:4,			item_Parachute,		item_ParaBag,		.returnitem1 = 0, .returnitem2 = 1);
	DefineItemCombo(item_Bottle,		item_Bandage,		item_MolotovEmpty);
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

	DefineSafeboxType("Medium Box",		item_MediumBox,		6, 6, 3, 2);
	DefineSafeboxType("Small Box", 		item_SmallBox,		4, 2, 1, 0);
	DefineSafeboxType("Large Box", 		item_LargeBox,		10, 8, 6, 6);
	DefineSafeboxType("Capsule", 		item_Capsule,		2, 2, 0, 0);

	for(new i; i < _:item_Parachute; i++)
	{
		switch(i)
		{
			case 2, 3, 5, 6, 7, 8, 15:
				SetItemTypeHolsterable(ItemType:i, 1, 0.123097, -0.129424, -0.139251, 0.000000, 301.455871, 0.000000, 300, "PED", "PHONE_IN"); // Small arms

			case 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45:
				SetItemTypeHolsterable(ItemType:i, 8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300, "PED", "PHONE_IN"); // Small arms

			case 25, 27, 29, 30, 31, 33, 34:
				SetItemTypeHolsterable(ItemType:i, 1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800, "GOGGLES", "GOGGLES_PUT_ON"); // Two handed

			case 35, 36:
				SetItemTypeHolsterable(ItemType:i, 1, 0.181966, -0.238397, -0.094830, 252.791229, 353.893859, 357.529418, 800, "GOGGLES", "GOGGLES_PUT_ON"); // Rocket
		}
	}

	CallLocalFunction("OnLoad", "");

	LoadVehicles();
	LoadTextDraws();
	LoadSafeboxes();
	LoadDefenses();


	for(new i; i < MAX_PLAYERS; i++)
	{
		ResetVariables(i);
	}

	defer AutoSave();

	return 1;
}

public OnGameModeExit()
{
	SaveAllSafeboxes(false);
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
	t:bServerGlobalSettings<Restarting>;

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

ResetVariables(playerid)
{
	bPlayerGameSettings[playerid]		= 0;

	gPlayerData[playerid][ply_Admin]	= 0,
	gPlayerData[playerid][ply_Skin]		= 0,
	gPlayerHP[playerid]					= 100.0;
	gPlayerAP[playerid]					= 0.0;
	gPlayerFP[playerid]					= 80.0;
	gPlayerVehicleID[playerid]			= INVALID_VEHICLE_ID,
	gPlayerWarnings[playerid]			= 0;
	gPlayerPassAttempts[playerid]		= 0;

	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);

	for(new i; i < 10; i++)
		RemovePlayerAttachedObject(playerid, i);
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
			ShowWatch(playerid);
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

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	MsgF(playerid, -1, " >  Player %P", clickedplayerid);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(newkeys & KEY_YES)
		{
			if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && !(bPlayerGameSettings[playerid] & KnockedOut))
			{
				new Float:health;
				GetVehicleHealth(gPlayerVehicleID[playerid], health);

				if(VehicleFuelData[GetVehicleModel(gPlayerVehicleID[playerid])-400][veh_maxFuel] > 0.0)
				{
					if(health >= 300.0)
					{
						if(gVehicleFuel[gPlayerVehicleID[playerid]] > 0.0)
							VehicleEngineState(gPlayerVehicleID[playerid], !VehicleEngineState(gPlayerVehicleID[playerid]));
					}
				}
			}
		}
		if(newkeys & KEY_NO)
		{
			VehicleLightsState(gPlayerVehicleID[playerid], !VehicleLightsState(gPlayerVehicleID[playerid]));
		}
		if(newkeys & KEY_CTRL_BACK)//262144)
		{
			ShowRadioUI(playerid);
		}
		if(newkeys & KEY_SUBMISSION)
		{
			VehicleDoorsState(gPlayerVehicleID[playerid], !VehicleDoorsState(gPlayerVehicleID[playerid]));
		}
	}
	else
	{
		new weaponid = GetPlayerCurrentWeapon(playerid);
		if(weaponid == 34 || weaponid == 35 || weaponid == 43)
		{
			if(newkeys & 128)
			{
				TogglePlayerHeadwear(playerid, false);
				/*
				switch(GetPlayerCameraMode(playerid))
				{
					case CAMERA_MODE_AIM_SNIPER, CAMERA_MODE_AIM_ROCKETLAUNCHER, CAMERA_MODE_FIXED_CARBUMPER, CAMERA_MODE_AIM_CAMERA, CAMERA_MODE_AIM_HEATSEEKER:
					{
						TogglePlayerHeadwear(playerid, false);
					}
				}
				*/
			}
			if(oldkeys & 128)
			{
				TogglePlayerHeadwear(playerid, true);
			}
	}
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
	if(bPlayerGameSettings[playerid] & Muted)
	{
		Msg(playerid, RED, " >  You are muted");
		return 1;
	}

	if(isnull(params))
	{
		gPlayerChatMode[playerid] = CHAT_MODE_GLOBAL;
		Msg(playerid, WHITE, " >  You turn your radio on to the global frequency.");
	}
	else
	{
		PlayerSendChat(playerid, params, 1.0);
	}
	return 1;
}
CMD:l(playerid, params[])
{
	if(isnull(params))
	{
		gPlayerChatMode[playerid] = CHAT_MODE_LOCAL;
		Msg(playerid, WHITE, " >  You turned your radio off, chat is not broadcasted.");
	}
	else
	{
		PlayerSendChat(playerid, params, 0.0);
	}
	return 1;
}
CMD:r(playerid, params[])
{
	if(isnull(params))
	{
		gPlayerChatMode[playerid] = CHAT_MODE_RADIO;
		MsgF(playerid, WHITE, " >  You turned your radio on to frequency %.2f.", gPlayerFrequency[playerid]);
	}
	else
	{
		PlayerSendChat(playerid, params, gPlayerFrequency[playerid]);
	}
	return 1;
}
CMD:quiet(playerid, params[])
{
	if(bPlayerGameSettings[playerid] & GlobalQuiet)
	{
		f:bPlayerGameSettings[playerid]<GlobalQuiet>;
		Msg(playerid, WHITE, " >  You turn on your radio's global receiver, you will now see all global chat.");
	}
	else
	{
		t:bPlayerGameSettings[playerid]<GlobalQuiet>;
		Msg(playerid, WHITE, " >  You turn off your radio's global receiver, you will not see any global chat.");
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

	if(tmpMuteTime < 30000)
	{
		Msg(playerid, RED, " >  Muted from global chat for "#C_ORANGE"30 "#C_YELLOW"seconds, Reason: "#C_BLUE"chat flooding");
		return 0;
	}

	if(tickcount() - tick_LastChatMessage[playerid] < 1000)
	{
		ChatMessageStreak[playerid]++;
		if(ChatMessageStreak[playerid] == 3)
		{
			Msg(playerid, RED, " >  Muted from global chat for "#C_ORANGE"30 "#C_YELLOW"seconds, Reason: "#C_BLUE"chat flooding");
			ChatMuteTick[playerid] = tickcount();
			return 0;
		}
	}
	else
	{
		if(ChatMessageStreak[playerid] > 0)
			ChatMessageStreak[playerid]--;
	}

	tick_LastChatMessage[playerid] = tickcount();

	if(gPlayerChatMode[playerid] == CHAT_MODE_LOCAL)
		PlayerSendChat(playerid, text, 0.0);

	if(gPlayerChatMode[playerid] == CHAT_MODE_GLOBAL)
		PlayerSendChat(playerid, text, 1.0);

	if(gPlayerChatMode[playerid] == CHAT_MODE_RADIO)
		PlayerSendChat(playerid, text, gPlayerFrequency[playerid]);

	return 0;
}
PlayerSendChat(playerid, textInput[], Float:frequency)
{
	new
		text[256],
		text2[128],
		sendsecondline;

	if(frequency == 0.0)
	{
		format(text, 256, "[Local] (%d) %P"#C_WHITE": %s",
			playerid,
			playerid,
			TagScan(textInput));
	}
	else if(frequency == 1.0)
	{
		format(text, 256, "[Global] (%d) %P"#C_WHITE": %s",
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

	SetPlayerChatBubble(playerid, TagScan(textInput), WHITE, 40.0, 10000);

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

	if(frequency == 0.0)
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
	else if(frequency == 1.0)
	{
		foreach(new i : Player)
		{
			if(bPlayerGameSettings[i] & GlobalQuiet)
				continue;

			SendClientMessage(i, WHITE, text);

			if(sendsecondline)
				SendClientMessage(i, WHITE, text2);
		}
	}
	else
	{
		foreach(new i : Player)
		{
			if(-0.05 < frequency - gPlayerFrequency[i] < 0.05)
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

	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new model = GetVehicleModel(vehicleid);

		gPlayerVehicleID[playerid] = vehicleid;

		t:bVehicleSettings[vehicleid]<v_Used>;
		t:bVehicleSettings[vehicleid]<v_Occupied>;

		PlayerTextDrawSetString(playerid, VehicleNameText, VehicleNames[model-400]);
		PlayerTextDrawShow(playerid, VehicleNameText);
		PlayerTextDrawShow(playerid, VehicleSpeedText);

		if(GetVehicleType(model) != VTYPE_BMX)
		{
			PlayerTextDrawShow(playerid, VehicleFuelText);
			PlayerTextDrawShow(playerid, VehicleDamageText);
			PlayerTextDrawShow(playerid, VehicleEngineText);
			PlayerTextDrawShow(playerid, VehicleDoorsText);
		}
	}
	if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
		VehicleDoorsState(gPlayerVehicleID[playerid], 0);

		gPlayerVehicleID[playerid] = INVALID_VEHICLE_ID;
		PlayerVehicleCurHP[playerid] = 0.0;
		f:bVehicleSettings[vehicleid]<v_Occupied>;

		PlayerTextDrawHide(playerid, VehicleNameText);
		PlayerTextDrawHide(playerid, VehicleSpeedText);
		PlayerTextDrawHide(playerid, VehicleFuelText);
		PlayerTextDrawHide(playerid, VehicleDamageText);
		PlayerTextDrawHide(playerid, VehicleEngineText);
		PlayerTextDrawHide(playerid, VehicleDoorsText);
	}
	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(bPlayerGameSettings[playerid] & KnockedOut)
	{
		return 0;
	}

	if(ispassenger)
	{
		new driverid = -1;

		foreach(new i : Player)
		{
			if(IsPlayerInVehicle(i, vehicleid))
			{
				if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
				{
					driverid = i;
				}
			}
		}

		if(driverid == -1)
			CancelPlayerMovement(playerid);
	}

	gCurrentVelocity[playerid] = 0.0;

	return 1;
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	gCurrentVelocity[playerid] = 0.0;

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
				gPlayerPassAttempts[playerid]++;
				format(str, 64, "Incorrect password! %d out of 5 tries", gPlayerPassAttempts[playerid]);
				ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Quit");
				if(gPlayerPassAttempts[playerid] == 5)
				{
					MsgAllF(GREY, " >  %s left the server without logging in.", gPlayerName[playerid]);
					Kick(playerid);
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

			CreateNewUserfile(playerid, buffer);

			ShowWelcomeMessage(playerid, 10);
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
		params[127],
		cmdfunction[64],
		result = 1;

	printf("[comm] [%p]: %s", playerid, cmdtext);

	sscanf(cmdtext, "s[30]s[127]", cmd, params);

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
	RestartCount				=TextDrawCreate(430.000000, 10.000000, "Server Restart In:~n~00:00");
	TextDrawAlignment			(RestartCount, 2);
	TextDrawBackgroundColor		(RestartCount, 255);
	TextDrawFont				(RestartCount, 1);
	TextDrawLetterSize			(RestartCount, 0.400000, 2.000000);
	TextDrawColor				(RestartCount, -1);
	TextDrawSetOutline			(RestartCount, 1);
	TextDrawSetProportional		(RestartCount, 1);


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


//===================================================================Weapon Ammo

	WeaponAmmo						=CreatePlayerTextDraw(playerid, 520.000000, 64.000000, "500/500");
	PlayerTextDrawAlignment			(playerid, WeaponAmmo, 2);
	PlayerTextDrawBackgroundColor	(playerid, WeaponAmmo, 255);
	PlayerTextDrawFont				(playerid, WeaponAmmo, 1);
	PlayerTextDrawLetterSize		(playerid, WeaponAmmo, 0.210000, 1.000000);
	PlayerTextDrawColor				(playerid, WeaponAmmo, -1);
	PlayerTextDrawSetOutline		(playerid, WeaponAmmo, 1);
	PlayerTextDrawSetProportional	(playerid, WeaponAmmo, 1);
	PlayerTextDrawUseBox			(playerid, WeaponAmmo, 1);
	PlayerTextDrawBoxColor			(playerid, WeaponAmmo, 255);
	PlayerTextDrawTextSize			(playerid, WeaponAmmo, 548.000000, 40.000000);


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


//=========================================================================Watch

	WatchBackground					=CreatePlayerTextDraw(playerid, 33.000000, 338.000000, "LD_POOL:ball");
	PlayerTextDrawBackgroundColor	(playerid, WatchBackground, 255);
	PlayerTextDrawFont				(playerid, WatchBackground, 4);
	PlayerTextDrawLetterSize		(playerid, WatchBackground, 0.500000, 0.000000);
	PlayerTextDrawColor				(playerid, WatchBackground, 255);
	PlayerTextDrawSetOutline		(playerid, WatchBackground, 0);
	PlayerTextDrawSetProportional	(playerid, WatchBackground, 1);
	PlayerTextDrawSetShadow			(playerid, WatchBackground, 1);
	PlayerTextDrawUseBox			(playerid, WatchBackground, 1);
	PlayerTextDrawBoxColor			(playerid, WatchBackground, 255);
	PlayerTextDrawTextSize			(playerid, WatchBackground, 108.000000, 89.000000);

	WatchTime						=CreatePlayerTextDraw(playerid, 87.000000, 372.000000, "69:69");
	PlayerTextDrawAlignment			(playerid, WatchTime, 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchTime, 255);
	PlayerTextDrawFont				(playerid, WatchTime, 2);
	PlayerTextDrawLetterSize		(playerid, WatchTime, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, WatchTime, -1);
	PlayerTextDrawSetOutline		(playerid, WatchTime, 1);
	PlayerTextDrawSetProportional	(playerid, WatchTime, 1);

	WatchBear						=CreatePlayerTextDraw(playerid, 87.000000, 358.000000, "45 Deg");
	PlayerTextDrawAlignment			(playerid, WatchBear, 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchBear, 255);
	PlayerTextDrawFont				(playerid, WatchBear, 2);
	PlayerTextDrawLetterSize		(playerid, WatchBear, 0.300000, 1.500000);
	PlayerTextDrawColor				(playerid, WatchBear, -1);
	PlayerTextDrawSetOutline		(playerid, WatchBear, 1);
	PlayerTextDrawSetProportional	(playerid, WatchBear, 1);

	WatchFreq						=CreatePlayerTextDraw(playerid, 87.000000, 391.000000, "88.8");
	PlayerTextDrawAlignment			(playerid, WatchFreq, 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchFreq, 255);
	PlayerTextDrawFont				(playerid, WatchFreq, 2);
	PlayerTextDrawLetterSize		(playerid, WatchFreq, 0.300000, 1.500000);
	PlayerTextDrawColor				(playerid, WatchFreq, -1);
	PlayerTextDrawSetOutline		(playerid, WatchFreq, 1);
	PlayerTextDrawSetProportional	(playerid, WatchFreq, 1);


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

	VehicleDoorsText				=CreatePlayerTextDraw(playerid, 620.000000, 341.000000, "DOR");
	PlayerTextDrawAlignment			(playerid, VehicleDoorsText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleDoorsText, 255);
	PlayerTextDrawFont				(playerid, VehicleDoorsText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleDoorsText, 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleDoorsText, RED);
	PlayerTextDrawSetOutline		(playerid, VehicleDoorsText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleDoorsText, 1);


//======================================================================Stat GUI

	AddHPText						=CreatePlayerTextDraw(playerid, 160.000000, 240.000000, "<+HP>");
	PlayerTextDrawColor				(playerid, AddHPText, RED);
	PlayerTextDrawBackgroundColor	(playerid, AddHPText, 255);
	PlayerTextDrawFont				(playerid, AddHPText, 1);
	PlayerTextDrawLetterSize		(playerid, AddHPText, 0.300000, 1.000000);
	PlayerTextDrawSetProportional	(playerid, AddHPText, 1);
	PlayerTextDrawSetShadow			(playerid, AddHPText, 0);
	PlayerTextDrawSetOutline		(playerid, AddHPText, 1);

	ActionBar						= CreatePlayerProgressBar(playerid, 291.0, 345.0, 57.50, 5.19, GREY, 100.0);
	OverheatBar						= CreatePlayerProgressBar(playerid, 220.0, 380.0, 200.0, 20.0, RED, 30.0);
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

	DestroyPlayerProgressBar(playerid, OverheatBar);
	DestroyPlayerProgressBar(playerid, ActionBar);
	DestroyPlayerProgressBar(playerid, KnockoutBar);
}

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
	ShowActionText(playerid, message, time, width);
}

IsPlayerDead(playerid)
{
	return bPlayerGameSettings[playerid] & Dying;
}

GetPlayerVehicleExitTick(playerid)
{
	return tick_ExitVehicle[playerid];
}

IsPlayerOnAdminDuty(playerid)
{
	return bPlayerGameSettings[playerid] & AdminDuty;
}

GetPlayerServerJoinTick(playerid)
{
	return tick_ServerJoin[playerid];
}

GetPlayerSpawnTick(playerid)
{
	return tick_Spawn[playerid];
}
