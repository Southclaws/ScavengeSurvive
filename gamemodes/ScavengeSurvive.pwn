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
#define STRLIB_RETURN_SIZE				(256) // strlib
#define MODIO_DEBUG						(0) // modio
#define MODIO_FILE_STRUCTURE_VERSION	(20) // modio
#define MODIO_SCRIPT_EXIT_FIX			(1) // modio
#define MAX_MODIO_SESSION				(1024) // modio
#define ITM_ARR_ARRAY_SIZE_PROTECT		(false) // SIF/extensions/ItemArrayData
#define ITM_MAX_TEXT					(48) // SIF/Item
#define ITM_DROP_ON_DEATH				(false) // SIF/Item
//	#define SIF_USE_DEBUG_LABELS			(true) // SIF/extensions/DebugLabels
//	#define DEBUG_LABELS_BUTTON				(true) // SIF/Button
//	#define DEBUG_LABELS_ITEM				(true) // SIF/Item
#define BTN_MAX							(16384) // SIF/Button
#define ITM_MAX							(16384) // SIF/Item
#define CNT_MAX_SLOTS					(64)

/*==============================================================================

	Guaranteed first call

==============================================================================*/

forward OnGameModeInit_Pre();
public OnGameModeInit()
{
	OnGameModeInit_Setup();
	OnGameModeInit_Pre();
	#if defined gm_OnGameModeInit
		return gm_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit gm_OnGameModeInit
#if defined gm_OnGameModeInit
	forward gm_OnGameModeInit();
#endif

/*==============================================================================

	Libraries and respective links to their release pages

==============================================================================*/

#include <sscanf2>					// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=120356
#include <YSI\y_utils>				// By Y_Less:				http://forum.sa-mp.com/showthread.php?p=1696956
#include <YSI\y_va>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <YSI\y_iterate>
#include <YSI\y_ini>
#include <YSI\y_dialog>

#include "SS\Core\Server\Hooks.pwn"	// Internal library for hooking functions before they are used in external libraries.

#include <streamer>					// By Incognito, 2.7:		http://forum.sa-mp.com/showthread.php?t=102865
//#include <irc>						// By Incognito, 1.4.5:		http://forum.sa-mp.com/showthread.php?t=98803
#include <dns>						// By Incognito, 2.4:		http://forum.sa-mp.com/showthread.php?t=75605

#include <sqlitei>					// By Slice, v0.9.6:		http://forum.sa-mp.com/showthread.php?t=303682
#include <formatex>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=313488
#include <strlib>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=362764
#include <md-sort>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=343172
#include <geolocation>				// By Whitetiger:			https://github.com/Whitetigerswt/SAMP-geoip

#define time ctime_time
#include <CTime>					// By RyDeR:				http://forum.sa-mp.com/showthread.php?t=294054
#undef time

#include <playerprogress>			// By Torbido/Southclaw:	https://github.com/Southclaw/PlayerProgressBar
#include <FileManager>				// By JaTochNietDan, 1.5:	http://forum.sa-mp.com/showthread.php?t=92246
#include <djson>					// By DracoBlue, 1.6.2 :	http://forum.sa-mp.com/showthread.php?t=48439

#include <modio>					// By Southclaw:			https://github.com/Southclaw/modio
#include <SIF>						// By Southclaw:			https://github.com/Southclaw/SIF
#include <SIF\extensions\ItemArrayData>
#include <SIF\extensions\ItemList>
#include <SIF\extensions\InventoryDialog>
#include <SIF\extensions\InventoryKeys>
#include <SIF\extensions\ContainerDialog>
#include <SIF\extensions\Craft>
#include <WeaponData>				// By Southclaw:			https://github.com/Southclaw/AdvancedWeaponData
#include <Balloon>					// By Southclaw:			https://github.com/Southclaw/Balloon
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
#define MAX_INFO_MESSAGE			(8)
#define MAX_INFO_MESSAGE_LEN		(128)
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
#define GEID_FILE					DIRECTORY_MAIN"geids.dat"


// Macros
#define t:%1<%2>					((%1)|=(%2))
#define f:%1<%2>					((%1)&=~(%2))

#define SetSpawn(%0,%1,%2,%3,%4)	SetSpawnInfo(%0, NO_TEAM, 0, %1, %2, %3, %4, 0,0,0,0,0,0)

#define CMD:%1(%2)					forward cmd_%1(%2);\
									public cmd_%1(%2)

#define ACMD:%1[%2](%3)				forward acmd_%1_%2(%3);\
									public acmd_%1_%2(%3)

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
#define REPORT_TYPE_END


// Genders
#define GENDER_MALE					(0)
#define GENDER_FEMALE				(1)


// Key text
#define KEYTEXT_INTERACT			"~k~~VEHICLE_ENTER_EXIT~"
#define KEYTEXT_PUT_AWAY			"~k~~CONVERSATION_YES~"
#define KEYTEXT_DROP_ITEM			"~k~~CONVERSATION_NO~"
#define KEYTEXT_INVENTORY			"~k~~GROUP_CONTROL_BWD~"
#define KEYTEXT_ENGINE				"~k~~CONVERSATION_YES~"
#define KEYTEXT_LIGHTS				"~k~~CONVERSATION_NO~"
#define KEYTEXT_DOORS				"~k~~TOGGLE_SUBMISSIONS~"
#define KEYTEXT_RADIO				"R"


// Staff levels
enum
{
	STAFF_LEVEL_NONE,						// 0
	STAFF_LEVEL_GAME_MASTER,				// 1
	STAFF_LEVEL_MODERATOR,					// 2
	STAFF_LEVEL_ADMINISTRATOR,				// 3
	STAFF_LEVEL_DEVELOPER,					// 4
	STAFF_LEVEL_SECRET						// 5
}

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

// Chat modes
enum
{
	CHAT_MODE_LOCAL,		// 0 - Speak to players within chatbubble distance
	CHAT_MODE_GLOBAL,		// 1 - Speak to all players
	CHAT_MODE_RADIO,		// 2 - Speak to players on the same radio frequency
	CHAT_MODE_ADMIN			// 3 - Speak to admins
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
	k_Generator,
	k_PassageTop,
	k_PassageBottom,
	k_Catwalk,
	k_Headquarters1,
	k_Headquarters2,
	k_Shaft,
	k_Lockup
}


/*==============================================================================

	Global Variables

==============================================================================*/


// DATABASES AND STATEMENTS
new
DB:				gAccounts,
DB:				gWorld;

// SERVER SETTINGS (JSON LOADED)
new
		// player
		gMessageOfTheDay[MAX_MOTD_LEN],
		gWebsiteURL[MAX_WEBSITE_NAME],
		gInfoMessage[MAX_INFO_MESSAGE][MAX_INFO_MESSAGE_LEN],
		gRuleList[MAX_RULE][MAX_RULE_LEN],
		gStaffList[MAX_STAFF][MAX_STAFF_LEN],
		gInfoMessageInterval,
		gPerformFileCheck,

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
		gServerMaxUptime;

// INTERNAL
new
		gServerUptime,
bool:	gServerRestarting,
		gBigString[MAX_PLAYERS][4096],
		gTotalInfoMessage,
		gTotalRules,
		gTotalStaff,
		gCurrentInfoMessage;

// SKINS/CLOTHES
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

// ITEM ATTACK ANIMATION HANDLES
new
	anim_Blunt,
	anim_Stab,
	anim_Heavy;

// DRUG TYPES
new
	drug_Antibiotic,
	drug_Painkill,
	drug_Lsd,
	drug_Air,
	drug_Morphine,
	drug_Adrenaline,
	drug_Heroin;

// LOOT INDEXES
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
	loot_Survivor,
	loot_SupplyCrate
}

// AMMO CALIBRES
new
				calibre_9mm,
				calibre_50c,
				calibre_12g,
				calibre_556,
				calibre_357,
				calibre_762,
				calibre_rpg,
				calibre_fuel,
				calibre_film;

// ITEM TYPES
new stock
// 00
ItemType:		item_NULL			= INVALID_ITEM_TYPE,
ItemType:		item_Knuckles		= INVALID_ITEM_TYPE,
ItemType:		item_GolfClub		= INVALID_ITEM_TYPE,
ItemType:		item_Baton			= INVALID_ITEM_TYPE,
ItemType:		item_Knife			= INVALID_ITEM_TYPE,
ItemType:		item_Bat			= INVALID_ITEM_TYPE,
ItemType:		item_Spade			= INVALID_ITEM_TYPE,
ItemType:		item_PoolCue		= INVALID_ITEM_TYPE,
ItemType:		item_Sword			= INVALID_ITEM_TYPE,
ItemType:		item_Chainsaw		= INVALID_ITEM_TYPE,
// 10
ItemType:		item_Dildo1			= INVALID_ITEM_TYPE,
ItemType:		item_Dildo2			= INVALID_ITEM_TYPE,
ItemType:		item_Dildo3			= INVALID_ITEM_TYPE,
ItemType:		item_Dildo4			= INVALID_ITEM_TYPE,
ItemType:		item_Flowers		= INVALID_ITEM_TYPE,
ItemType:		item_WalkingCane	= INVALID_ITEM_TYPE,
ItemType:		item_Grenade		= INVALID_ITEM_TYPE,
ItemType:		item_Teargas		= INVALID_ITEM_TYPE,
ItemType:		item_Molotov		= INVALID_ITEM_TYPE,
ItemType:		item_NULL2			= INVALID_ITEM_TYPE,
// 20
ItemType:		item_NULL3			= INVALID_ITEM_TYPE,
ItemType:		item_NULL4			= INVALID_ITEM_TYPE,
ItemType:		item_M9Pistol		= INVALID_ITEM_TYPE,
ItemType:		item_M9PistolSD		= INVALID_ITEM_TYPE,
ItemType:		item_DesertEagle	= INVALID_ITEM_TYPE,
ItemType:		item_PumpShotgun	= INVALID_ITEM_TYPE,
ItemType:		item_Sawnoff		= INVALID_ITEM_TYPE,
ItemType:		item_Spas12			= INVALID_ITEM_TYPE,
ItemType:		item_Mac10			= INVALID_ITEM_TYPE,
ItemType:		item_MP5			= INVALID_ITEM_TYPE,
// 30
ItemType:		item_AK47Rifle		= INVALID_ITEM_TYPE,
ItemType:		item_M16Rifle		= INVALID_ITEM_TYPE,
ItemType:		item_Tec9			= INVALID_ITEM_TYPE,
ItemType:		item_SemiAutoRifle	= INVALID_ITEM_TYPE,
ItemType:		item_SniperRifle	= INVALID_ITEM_TYPE,
ItemType:		item_RocketLauncher	= INVALID_ITEM_TYPE,
ItemType:		item_Heatseeker		= INVALID_ITEM_TYPE,
ItemType:		item_Flamer			= INVALID_ITEM_TYPE,
ItemType:		item_Minigun		= INVALID_ITEM_TYPE,
ItemType:		item_RemoteBomb		= INVALID_ITEM_TYPE,
// 40
ItemType:		item_Detonator		= INVALID_ITEM_TYPE,
ItemType:		item_SprayPaint		= INVALID_ITEM_TYPE,
ItemType:		item_Extinguisher	= INVALID_ITEM_TYPE,
ItemType:		item_Camera			= INVALID_ITEM_TYPE,
ItemType:		item_NightVision	= INVALID_ITEM_TYPE,
ItemType:		item_ThermalVision	= INVALID_ITEM_TYPE,
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
ItemType:		item_StunGun		= INVALID_ITEM_TYPE,
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
ItemType:		item_HockeyMask		= INVALID_ITEM_TYPE,
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
ItemType:		item_MetalGate		= INVALID_ITEM_TYPE,
ItemType:		item_CrateDoor		= INVALID_ITEM_TYPE,
ItemType:		item_CorPanel		= INVALID_ITEM_TYPE,
ItemType:		item_ShipDoor		= INVALID_ITEM_TYPE,
ItemType:		item_RustyDoor		= INVALID_ITEM_TYPE,
ItemType:		item_MetalStand		= INVALID_ITEM_TYPE,
ItemType:		item_RustyMetal		= INVALID_ITEM_TYPE,
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
ItemType:		item_LargeBackpack	= INVALID_ITEM_TYPE,
ItemType:		item_LocksmithKit	= INVALID_ITEM_TYPE,
ItemType:		item_XmasHat		= INVALID_ITEM_TYPE,
ItemType:		item_VehicleWeapon	= INVALID_ITEM_TYPE,
ItemType:		item_AdvancedKeypad	= INVALID_ITEM_TYPE,
// 180
ItemType:		item_Ammo9mmFMJ		= INVALID_ITEM_TYPE,
ItemType:		item_AmmoFlechette	= INVALID_ITEM_TYPE,
ItemType:		item_AmmoHomeBuck	= INVALID_ITEM_TYPE,
ItemType:		item_Ammo556Tracer	= INVALID_ITEM_TYPE,
ItemType:		item_Ammo556HP		= INVALID_ITEM_TYPE,
ItemType:		item_Ammo357Tracer	= INVALID_ITEM_TYPE,
ItemType:		item_Ammo762		= INVALID_ITEM_TYPE;

// UI HANDLES
new
Text:			DeathText			= Text:INVALID_TEXT_DRAW,
Text:			DeathButton			= Text:INVALID_TEXT_DRAW,
Text:			RestartCount		= Text:INVALID_TEXT_DRAW,
Text:			HitMark_centre		= Text:INVALID_TEXT_DRAW,
Text:			HitMark_offset		= Text:INVALID_TEXT_DRAW,
Text:			Branding			= Text:INVALID_TEXT_DRAW,

PlayerText:		ClassBackGround		[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		ClassButtonMale		[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		ClassButtonFemale	[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		WeaponAmmo			[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		HungerBarBackground	[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		HungerBarForeground	[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		WatchBackground		[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		WatchTime			[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		WatchBear			[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		WatchFreq			[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		ToolTip				[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		HelpTipText			[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		VehicleFuelText		[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		VehicleDamageText	[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		VehicleEngineText	[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		VehicleDoorsText	[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		VehicleNameText		[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:		VehicleSpeedText	[MAX_PLAYERS]	= {PlayerText:INVALID_TEXT_DRAW, ...},

PlayerBar:		OverheatBar			= INVALID_PLAYER_BAR_ID,
PlayerBar:		ActionBar			= INVALID_PLAYER_BAR_ID,
PlayerBar:		KnockoutBar			= INVALID_PLAYER_BAR_ID,
				MiniMapOverlay;


forward OnLoad();
forward SetRestart(seconds);


/*==============================================================================

	Gamemode Scripts

==============================================================================*/


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
#include "SS/Core/Server/Settings.pwn"
#include "SS/Core/Server/TextTags.pwn"
#include "SS/Core/Server/Weather.pwn"
#include "SS/Core/Server/SaveBlock.pwn"
#include "SS/Core/Server/ActivityLog.pwn"
#include "SS/Core/Server/FileCheck.pwn"
#include "SS/Core/Server/IRC.pwn"

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
#include "SS/Core/Vehicle/VehicleTypeIndex.pwn"
#include "SS/Core/Vehicle/Core.pwn"
#include "SS/Core/Vehicle/Spawn.pwn"
#include "SS/Core/Vehicle/PlayerVehicle.pwn"
#include "SS/Core/Vehicle/Repair.pwn"
#include "SS/Core/Vehicle/LockBreak.pwn"
#include "SS/Core/Vehicle/Locksmith.pwn"
#include "SS/Core/Vehicle/Carmour.pwn"
#include "SS/Core/Vehicle/Lock.pwn"
#include "SS/Core/Vehicle/AntiNinja.pwn"
#include "SS/Core/Vehicle/BikeCollision.pwn"

// LOOT
#include "SS/Core/Loot/Spawn.pwn"

// PLAYER INTERNAL SCRIPTS
#include "SS/Core/Player/Core.pwn"
#include "SS/Core/Player/Accounts.pwn"
#include "SS/Core/Player/Aliases.pwn"
#include "SS/Core/Player/ipv4-log.pwn"
#include "SS/Core/Player/host-log.pwn"
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
#include "SS/Core/Player/Profile.pwn"
#include "SS/Core/Player/ToolTips.pwn"
#include "SS/Core/Player/Whitelist.pwn"

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
#include "SS/Core/Char/Towtruck.pwn"
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
#include "SS/Core/World/SprayTag.pwn"
#include "SS/Core/World/Sign.pwn"
#include "SS/Core/World/SupplyCrate.pwn"
#include "SS/Core/World/WeaponsCache.pwn"

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
#include "SS/Core/Item/GasMask.pwn"
#include "SS/Core/Item/HockeyMask.pwn"
#include "SS/Core/Item/XmasHat.pwn"
#include "SS/Core/Item/StunGun.pwn"

// GAME DATA LOADING
#include "SS/Data/Loot.pwn"
#include "SS/Data/Vehicle.pwn"
//#include "SS/Data/Weapon.pwn"


// POST-CODE

#include "SS/Core/Server/Autosave.pwn"

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
}


























OnGameModeInit_Setup()
{
	print("Starting Main Game Script 'SSS' ...");

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
	gWorld = db_open_persistent(WORLD_DATABASE);

	djson_GameModeInit();

	LoadSettings();
}

public OnGameModeInit()
{
	SendRconCommand(sprintf("mapname %s", gMapName));

// 00
	item_NULL			= DefineItemType("NULL",				0,		ITEM_SIZE_SMALL);
	item_Knuckles		= DefineItemType("Knuckle Duster", 		331,	ITEM_SIZE_SMALL,	90.0);
	item_GolfClub		= DefineItemType("Golf Club", 			333,	ITEM_SIZE_LARGE,	90.0);
	item_Baton			= DefineItemType("Baton", 				334,	ITEM_SIZE_MEDIUM,	90.0);
	item_Knife			= DefineItemType("Knife", 				335,	ITEM_SIZE_SMALL,	90.0);
	item_Bat			= DefineItemType("Baseball Bat", 		336,	ITEM_SIZE_LARGE,	90.0);
	item_Spade			= DefineItemType("Spade", 				337,	ITEM_SIZE_LARGE,	90.0);
	item_PoolCue		= DefineItemType("Pool Cue", 			338,	ITEM_SIZE_LARGE,	90.0);
	item_Sword			= DefineItemType("Sword", 				339,	ITEM_SIZE_LARGE,	90.0);
	item_Chainsaw		= DefineItemType("Chainsaw", 			341,	ITEM_SIZE_LARGE,	90.0);
// 10
	item_Dildo1			= DefineItemType("Dildo",				321,	ITEM_SIZE_SMALL,	90.0);
	item_Dildo2			= DefineItemType("Dildo",				322,	ITEM_SIZE_SMALL,	90.0);
	item_Dildo3			= DefineItemType("Dildo",				323,	ITEM_SIZE_SMALL,	90.0);
	item_Dildo4			= DefineItemType("Dildo",				324,	ITEM_SIZE_SMALL,	90.0);
	item_Flowers		= DefineItemType("Flowers",				325,	ITEM_SIZE_MEDIUM,	90.0);
	item_WalkingCane	= DefineItemType("Cane",				326,	ITEM_SIZE_LARGE,	90.0);
	item_Grenade		= DefineItemType("Grenade",				342,	ITEM_SIZE_SMALL,	90.0);
	item_Teargas		= DefineItemType("Teargas",				343,	ITEM_SIZE_SMALL,	90.0);
	item_Molotov		= DefineItemType("Molotov",				344,	ITEM_SIZE_SMALL,	90.0);
	item_NULL2			= DefineItemType("<null>",				000,	ITEM_SIZE_SMALL,	90.0);
// 20
	item_NULL3			= DefineItemType("<null>",				000,	ITEM_SIZE_SMALL,	90.0);
	item_NULL4			= DefineItemType("<null>",				000,	ITEM_SIZE_SMALL,	90.0);
	item_M9Pistol		= DefineItemType("M9",					346,	ITEM_SIZE_SMALL,	90.0);
	item_M9PistolSD		= DefineItemType("M9 SD",				347,	ITEM_SIZE_SMALL,	90.0);
	item_DesertEagle	= DefineItemType("Desert Eagle",		348,	ITEM_SIZE_SMALL,	90.0);
	item_PumpShotgun	= DefineItemType("Shotgun",				349,	ITEM_SIZE_LARGE,	90.0);
	item_Sawnoff		= DefineItemType("Sawnoff",				350,	ITEM_SIZE_MEDIUM,	90.0);
	item_Spas12			= DefineItemType("Spas 12",				351,	ITEM_SIZE_LARGE,	90.0);
	item_Mac10			= DefineItemType("Mac 10",				352,	ITEM_SIZE_MEDIUM,	90.0);
	item_MP5			= DefineItemType("MP5",					353,	ITEM_SIZE_MEDIUM,	90.0);
// 30
	item_AK47Rifle		= DefineItemType("AK-47",				355,	ITEM_SIZE_LARGE,	90.0);
	item_M16Rifle		= DefineItemType("M16",					356,	ITEM_SIZE_LARGE,	90.0);
	item_Tec9			= DefineItemType("Tec 9",				372,	ITEM_SIZE_MEDIUM,	90.0);
	item_SemiAutoRifle	= DefineItemType("Rifle",				357,	ITEM_SIZE_LARGE,	90.0);
	item_SniperRifle	= DefineItemType("Sniper",				358,	ITEM_SIZE_LARGE,	90.0);
	item_RocketLauncher	= DefineItemType("RPG",					359,	ITEM_SIZE_LARGE,	90.0);
	item_Heatseeker		= DefineItemType("Heatseeker",			360,	ITEM_SIZE_LARGE,	90.0);
	item_Flamer			= DefineItemType("Flamer",				361,	ITEM_SIZE_LARGE,	90.0);
	item_Minigun		= DefineItemType("Minigun",				362,	ITEM_SIZE_LARGE,	90.0);
	item_RemoteBomb		= DefineItemType("Remote Bomb",			363,	ITEM_SIZE_MEDIUM,	90.0);
// 40
	item_Detonator		= DefineItemType("Detonator",			364,	ITEM_SIZE_MEDIUM,	90.0);
	item_SprayPaint		= DefineItemType("Spray Paint",			365,	ITEM_SIZE_SMALL,	90.0);
	item_Extinguisher	= DefineItemType("Extinguisher",		366,	ITEM_SIZE_LARGE,	90.0);
	item_Camera			= DefineItemType("Camera",				367,	ITEM_SIZE_SMALL,	90.0);
	item_NightVision	= DefineItemType("Night Vision",		000,	ITEM_SIZE_MEDIUM,	90.0);
	item_ThermalVision	= DefineItemType("Thermal Vision",		000,	ITEM_SIZE_MEDIUM,	90.0);
	item_Parachute		= DefineItemType("Parachute",			371,	ITEM_SIZE_MEDIUM,	90.0, 0.0, 0.0,			0.0,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000);
	item_Medkit			= DefineItemType("Medkit",				1580,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_HardDrive		= DefineItemType("Hard Drive",			328,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0);
	item_Key			= DefineItemType("Key",					327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.01);//, .colour = 0xFFDEDEDE);
// 50
	item_FireworkBox	= DefineItemType("Fireworks",			2039,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.096996, 0.044811, 0.035688, 4.759557, 255.625167, 0.000000);
	item_FireLighter	= DefineItemType("Lighter",				327,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0);
	item_Timer			= DefineItemType("Timer Device",		2922,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.231612, 0.050027, 0.017069, 0.000000, 343.020019, 180.000000);
	item_Explosive		= DefineItemType("TNT",					1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_TntTimebomb	= DefineItemType("Timed TNT",			1252,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0);
	item_Battery		= DefineItemType("Battery",				1579,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_Fusebox		= DefineItemType("Fuse Box",			328,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0);
	item_Bottle			= DefineItemType("Bottle",				1543,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.060376, 0.032063, -0.204802, 0.000000, 0.000000, 0.000000);
	item_Sign			= DefineItemType("Sign",				19471,	ITEM_SIZE_LARGE,	0.0, 0.0, 270.0,		0.0);
	item_Armour			= DefineItemType("Armour",				19515,	ITEM_SIZE_MEDIUM,	90.0, 0.0, 0.0,			0.0,	0.300333, -0.090105, 0.000000, 0.000000, 0.000000, 180.000000);
// 60
	item_Bandage		= DefineItemType("Bandage",				1575,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_FishRod		= DefineItemType("Fishing Rod",			18632,	ITEM_SIZE_LARGE,	90.0, 0.0, 0.0,			0.0,	0.091496, 0.019614, 0.000000, 185.619995, 354.958374, 0.000000);
	item_Wrench			= DefineItemType("Wrench",				18633,	ITEM_SIZE_SMALL,	0.0, 90.0, 0.0,			0.0,	0.084695, -0.009181, 0.152275, 98.865089, 270.085449, 0.000000);
	item_Crowbar		= DefineItemType("Crowbar",				18634,	ITEM_SIZE_SMALL,	0.0, 90.0, 0.0,			0.0,	0.066177, 0.011153, 0.038410, 97.289527, 270.962554, 1.114514);
	item_Hammer			= DefineItemType("Hammer",				18635,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.01,	0.000000, -0.008230, 0.000000, 6.428617, 0.000000, 0.000000);
	item_Shield			= DefineItemType("Shield",				18637,	ITEM_SIZE_LARGE,	0.0, 0.0, 0.0,			0.0,	-0.262389, 0.016478, -0.151046, 103.597534, 6.474381, 38.321765);
	item_Flashlight		= DefineItemType("Flashlight",			18641,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.061910, 0.022700, 0.039052, 190.938354, 0.000000, 0.000000);
	item_StunGun		= DefineItemType("Stun Gun",			18642,	ITEM_SIZE_SMALL,	90.0, 0.0, 0.0,			0.0,	0.079878, 0.014009, 0.029525, 180.000000, 0.000000, 0.000000);
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
	item_TntProxMine	= DefineItemType("Proximity TNT",		1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
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
	item_HockeyMask		= DefineItemType("Hockey Mask",			19036,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
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
	item_Barbecue		= DefineItemType("BBQ",					1481,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.6745,	0.106261, 0.004634, -0.144552, 246.614654, 345.892211, 258.267395);
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
	item_MetalGate		= DefineItemType("Metal Gate",			19303,	ITEM_SIZE_CARRY,	270.0, 0.0, 0.0,		0.0,	0.057177, 0.073761, -0.299014,  -19.439863, -10.153647, 105.119079);
	item_CrateDoor		= DefineItemType("Crate Door",			3062,	ITEM_SIZE_CARRY,	90.0, 90.0, 0.0,		0.0,	0.150177, -0.097238, -0.299014,  -19.439863, -10.153647, 105.119079);
	item_CorPanel		= DefineItemType("Corrugated Metal",	2904,	ITEM_SIZE_CARRY,	90.0, 90.0, 0.0,		0.0,	-0.365094, 1.004213, -0.665850, 337.887634, 172.861953, 68.495330);
	item_ShipDoor		= DefineItemType("Ship Door",			2944,	ITEM_SIZE_CARRY,	180.0, 90.0, 0.0,		0.0,	0.134831, -0.039784, -0.298796, 337.887634, 172.861953, 162.198867);
	item_RustyDoor		= DefineItemType("Metal Panel",			2952,	ITEM_SIZE_CARRY,	180.0, 90.0, 0.0,		0.0,	-0.087715, 0.483874, 1.109397, 337.887634, 172.861953, 162.198867);
	item_MetalStand		= DefineItemType("Metal Stand",			2978,	ITEM_SIZE_CARRY,	0.0, 0.0, 0.0,			0.0,	-0.106182, 0.534724, -0.363847, 278.598419, 68.350570, 57.954662);
	item_RustyMetal		= DefineItemType("Rusty Metal Sheet",	16637,	ITEM_SIZE_CARRY,	0.0, 270.0, 90.0,		0.0,	-0.068822, 0.989761, -0.620014,  -114.639907, -10.153647, 170.419097);
	item_WoodPanel		= DefineItemType("Wood Ramp",			5153,	ITEM_SIZE_CARRY,	360.0, 23.537, 0.0,		0.0,	-0.342762, 0.908910, -0.453703, 296.326019, 46.126548, 226.118209);
// 130
	item_Flare			= DefineItemType("Flare",				345,	ITEM_SIZE_SMALL);
	item_TntPhoneBomb	= DefineItemType("Phone Remote TNT",	1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
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
	item_AmmoBuck		= DefineItemType("Shotgun Shells",		2038,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
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
	item_TntTripMine	= DefineItemType("Trip Mine TNT",		1576,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
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
	item_LocksmithKit	= DefineItemType("Locksmith Kit",		1210,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 90.0,			0.0,	0.285915, 0.078406, -0.009429, 0.000000, 270.000000, 0.000000, 0xFFF4A460);
	item_XmasHat		= DefineItemType("Christmas Hat",		19066,	ITEM_SIZE_SMALL,	0.0, 0.0, 0.0,			0.0,	0.135000, -0.018001, -0.002000,  90.000000, 174.500061, 9.600001);
	item_VehicleWeapon	= DefineItemType("VEHICLE_WEAPON",		356,	ITEM_SIZE_LARGE,	90.0);
	item_AdvancedKeypad	= DefineItemType("Advanced Keypad",		19273,	ITEM_SIZE_SMALL,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000);
// 180
	item_Ammo9mmFMJ		= DefineItemType("9mm Rounds",			2037,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_AmmoFlechette	= DefineItemType("Shotgun Shells",		2038,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_AmmoHomeBuck	= DefineItemType("Shotgun Shells",		2038,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo556Tracer	= DefineItemType("5.56 Rounds",			2040,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo556HP		= DefineItemType("5.56 Rounds",			2040,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo357Tracer	= DefineItemType(".357 Rounds",			2039,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo762		= DefineItemType("7.62 Rounds",			2040,	ITEM_SIZE_MEDIUM,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);

	SetItemTypeMaxArrayData(item_NULL,			0);
	SetItemTypeMaxArrayData(item_Knuckles,		4);
	SetItemTypeMaxArrayData(item_GolfClub,		4);
	SetItemTypeMaxArrayData(item_Baton,			4);
	SetItemTypeMaxArrayData(item_Knife,			4);
	SetItemTypeMaxArrayData(item_Bat,			4);
	SetItemTypeMaxArrayData(item_Spade,			4);
	SetItemTypeMaxArrayData(item_PoolCue,		4);
	SetItemTypeMaxArrayData(item_Sword,			4);
	SetItemTypeMaxArrayData(item_Chainsaw,		4);
	SetItemTypeMaxArrayData(item_Dildo1,		4);
	SetItemTypeMaxArrayData(item_Dildo2,		4);
	SetItemTypeMaxArrayData(item_Dildo3,		4);
	SetItemTypeMaxArrayData(item_Dildo4,		4);
	SetItemTypeMaxArrayData(item_Flowers,		4);
	SetItemTypeMaxArrayData(item_WalkingCane,	4);
	SetItemTypeMaxArrayData(item_Grenade,		4);
	SetItemTypeMaxArrayData(item_Teargas,		4);
	SetItemTypeMaxArrayData(item_Molotov,		4);
	SetItemTypeMaxArrayData(item_NULL2,			4);
	SetItemTypeMaxArrayData(item_NULL3,			4);
	SetItemTypeMaxArrayData(item_NULL4,			4);
	SetItemTypeMaxArrayData(item_M9Pistol,		4);
	SetItemTypeMaxArrayData(item_M9PistolSD,	4);
	SetItemTypeMaxArrayData(item_DesertEagle,	4);
	SetItemTypeMaxArrayData(item_PumpShotgun,	4);
	SetItemTypeMaxArrayData(item_Sawnoff,		4);
	SetItemTypeMaxArrayData(item_Spas12,		4);
	SetItemTypeMaxArrayData(item_Mac10,			4);
	SetItemTypeMaxArrayData(item_MP5,			4);
	SetItemTypeMaxArrayData(item_AK47Rifle,		4);
	SetItemTypeMaxArrayData(item_M16Rifle,		4);
	SetItemTypeMaxArrayData(item_Tec9,			4);
	SetItemTypeMaxArrayData(item_SemiAutoRifle,	4);
	SetItemTypeMaxArrayData(item_SniperRifle,	4);
	SetItemTypeMaxArrayData(item_RocketLauncher,4);
	SetItemTypeMaxArrayData(item_Heatseeker,	4);
	SetItemTypeMaxArrayData(item_Flamer,		4);
	SetItemTypeMaxArrayData(item_Minigun,		4);
	SetItemTypeMaxArrayData(item_RemoteBomb,	4);
	SetItemTypeMaxArrayData(item_Detonator,		4);
	SetItemTypeMaxArrayData(item_SprayPaint,	4);
	SetItemTypeMaxArrayData(item_Extinguisher,	4);
	SetItemTypeMaxArrayData(item_Camera,		4);
	SetItemTypeMaxArrayData(item_NightVision,	4);
	SetItemTypeMaxArrayData(item_ThermalVision,	4);
	SetItemTypeMaxArrayData(item_Parachute,		1);
	SetItemTypeMaxArrayData(item_Medkit,		1);
	SetItemTypeMaxArrayData(item_HardDrive,		1);
	SetItemTypeMaxArrayData(item_Key,			1);
	SetItemTypeMaxArrayData(item_FireworkBox,	1);
	SetItemTypeMaxArrayData(item_FireLighter,	1);
	SetItemTypeMaxArrayData(item_Timer,			1);
	SetItemTypeMaxArrayData(item_Explosive,		1);
	SetItemTypeMaxArrayData(item_TntTimebomb,	1);
	SetItemTypeMaxArrayData(item_Battery,		1);
	SetItemTypeMaxArrayData(item_Fusebox,		1);
	SetItemTypeMaxArrayData(item_Bottle,		1);
	SetItemTypeMaxArrayData(item_Sign,			1);
	SetItemTypeMaxArrayData(item_Armour,		1);
	SetItemTypeMaxArrayData(item_Bandage,		1);
	SetItemTypeMaxArrayData(item_FishRod,		1);
	SetItemTypeMaxArrayData(item_Wrench,		1);
	SetItemTypeMaxArrayData(item_Crowbar,		1);
	SetItemTypeMaxArrayData(item_Hammer,		1);
	SetItemTypeMaxArrayData(item_Shield,		1);
	SetItemTypeMaxArrayData(item_Flashlight,	1);
	SetItemTypeMaxArrayData(item_StunGun,		1);
	SetItemTypeMaxArrayData(item_LaserPoint,	1);
	SetItemTypeMaxArrayData(item_Screwdriver,	1);
	SetItemTypeMaxArrayData(item_MobilePhone,	1);
	SetItemTypeMaxArrayData(item_Pager,			1);
	SetItemTypeMaxArrayData(item_Rake,			1);
	SetItemTypeMaxArrayData(item_HotDog,		1);
	SetItemTypeMaxArrayData(item_EasterEgg,		1);
	SetItemTypeMaxArrayData(item_Cane,			1);
	SetItemTypeMaxArrayData(item_HandCuffs,		1);
	SetItemTypeMaxArrayData(item_Bucket,		1);
	SetItemTypeMaxArrayData(item_GasMask,		1);
	SetItemTypeMaxArrayData(item_Flag,			1);
	SetItemTypeMaxArrayData(item_DoctorBag,		1);
	SetItemTypeMaxArrayData(item_Backpack,		2);
	SetItemTypeMaxArrayData(item_Satchel,		2);
	SetItemTypeMaxArrayData(item_Wheel,			1);
	SetItemTypeMaxArrayData(item_MotionSense,	1);
	SetItemTypeMaxArrayData(item_Accelerometer,	1);
	SetItemTypeMaxArrayData(item_TntProxMine,	1);
	SetItemTypeMaxArrayData(item_IedBomb,		1);
	SetItemTypeMaxArrayData(item_Pizza,			1);
	SetItemTypeMaxArrayData(item_Burger,		1);
	SetItemTypeMaxArrayData(item_BurgerBox,		1);
	SetItemTypeMaxArrayData(item_Taco,			1);
	SetItemTypeMaxArrayData(item_GasCan,		1);
	SetItemTypeMaxArrayData(item_Clothes,		1);
	SetItemTypeMaxArrayData(item_HelmArmy,		1);
	SetItemTypeMaxArrayData(item_MediumBox,		2);
	SetItemTypeMaxArrayData(item_SmallBox,		2);
	SetItemTypeMaxArrayData(item_LargeBox,		2);
	SetItemTypeMaxArrayData(item_HockeyMask,	1);
	SetItemTypeMaxArrayData(item_Meat,			1);
	SetItemTypeMaxArrayData(item_DeadLeg,		1);
	SetItemTypeMaxArrayData(item_Torso,			MAX_PLAYER_NAME + 128 + 2);
	SetItemTypeMaxArrayData(item_LongPlank,		1);
	SetItemTypeMaxArrayData(item_GreenGloop,	1);
	SetItemTypeMaxArrayData(item_Capsule,		1);
	SetItemTypeMaxArrayData(item_RadioPole,		1);
	SetItemTypeMaxArrayData(item_SignShot,		1);
	SetItemTypeMaxArrayData(item_Mailbox,		1);
	SetItemTypeMaxArrayData(item_Pumpkin,		1);
	SetItemTypeMaxArrayData(item_Nailbat,		1);
	SetItemTypeMaxArrayData(item_ZorroMask,		1);
	SetItemTypeMaxArrayData(item_Barbecue,		7);
	SetItemTypeMaxArrayData(item_Headlight,		1);
	SetItemTypeMaxArrayData(item_Pills,			1);
	SetItemTypeMaxArrayData(item_AutoInjec,		1);
	SetItemTypeMaxArrayData(item_BurgerBag,		1);
	SetItemTypeMaxArrayData(item_CanDrink,		1);
	SetItemTypeMaxArrayData(item_Detergent,		1);
	SetItemTypeMaxArrayData(item_Dice,			1);
	SetItemTypeMaxArrayData(item_Dynamite,		1);
	SetItemTypeMaxArrayData(item_Door,			1);
	SetItemTypeMaxArrayData(item_MetPanel,		1);
	SetItemTypeMaxArrayData(item_MetalGate,		1);
	SetItemTypeMaxArrayData(item_CrateDoor,		1);
	SetItemTypeMaxArrayData(item_CorPanel,		1);
	SetItemTypeMaxArrayData(item_ShipDoor,		1);
	SetItemTypeMaxArrayData(item_RustyDoor,		1);
	SetItemTypeMaxArrayData(item_MetalStand,	1);
	SetItemTypeMaxArrayData(item_RustyMetal,	1);
	SetItemTypeMaxArrayData(item_WoodPanel,		1);
	SetItemTypeMaxArrayData(item_Flare,			1);
	SetItemTypeMaxArrayData(item_TntPhoneBomb,	1);
	SetItemTypeMaxArrayData(item_ParaBag,		2);
	SetItemTypeMaxArrayData(item_Keypad,		1);
	SetItemTypeMaxArrayData(item_TentPack,		1);
	SetItemTypeMaxArrayData(item_Campfire,		1);
	SetItemTypeMaxArrayData(item_CowboyHat,		1);
	SetItemTypeMaxArrayData(item_TruckCap,		1);
	SetItemTypeMaxArrayData(item_BoaterHat,		1);
	SetItemTypeMaxArrayData(item_BowlerHat,		1);
	SetItemTypeMaxArrayData(item_PoliceCap,		1);
	SetItemTypeMaxArrayData(item_TopHat,		1);
	SetItemTypeMaxArrayData(item_Ammo9mm,		1);
	SetItemTypeMaxArrayData(item_Ammo50,		1);
	SetItemTypeMaxArrayData(item_AmmoBuck,		1);
	SetItemTypeMaxArrayData(item_Ammo556,		1);
	SetItemTypeMaxArrayData(item_Ammo357,		1);
	SetItemTypeMaxArrayData(item_AmmoRocket,	1);
	SetItemTypeMaxArrayData(item_MolotovEmpty,	1);
	SetItemTypeMaxArrayData(item_Money,			1);
	SetItemTypeMaxArrayData(item_PowerSupply,	1);
	SetItemTypeMaxArrayData(item_StorageUnit,	1);
	SetItemTypeMaxArrayData(item_Fluctuator,	1);
	SetItemTypeMaxArrayData(item_IoUnit,		1);
	SetItemTypeMaxArrayData(item_FluxCap,		1);
	SetItemTypeMaxArrayData(item_DataInterface,	1);
	SetItemTypeMaxArrayData(item_HackDevice,	1);
	SetItemTypeMaxArrayData(item_PlantPot,		1);
	SetItemTypeMaxArrayData(item_HerpDerp,		1);
	SetItemTypeMaxArrayData(item_Parrot,		1);
	SetItemTypeMaxArrayData(item_TntTripMine,	1);
	SetItemTypeMaxArrayData(item_IedTimebomb,	1);
	SetItemTypeMaxArrayData(item_IedProxMine,	1);
	SetItemTypeMaxArrayData(item_IedTripMine,	1);
	SetItemTypeMaxArrayData(item_IedPhoneBomb,	1);
	SetItemTypeMaxArrayData(item_EmpTimebomb,	1);
	SetItemTypeMaxArrayData(item_EmpProxMine,	1);
	SetItemTypeMaxArrayData(item_EmpTripMine,	1);
	SetItemTypeMaxArrayData(item_EmpPhoneBomb,	1);
	SetItemTypeMaxArrayData(item_Gyroscope,		1);
	SetItemTypeMaxArrayData(item_Motor,			1);
	SetItemTypeMaxArrayData(item_StarterMotor,	1);
	SetItemTypeMaxArrayData(item_FlareGun,		1);
	SetItemTypeMaxArrayData(item_PetrolBomb,	1);
	SetItemTypeMaxArrayData(item_CodePart,		1);
	SetItemTypeMaxArrayData(item_LargeBackpack,	2);
	SetItemTypeMaxArrayData(item_LocksmithKit,	0);
	SetItemTypeMaxArrayData(item_XmasHat,		0);
	SetItemTypeMaxArrayData(item_VehicleWeapon,	0);
	SetItemTypeMaxArrayData(item_AdvancedKeypad,0);
	SetItemTypeMaxArrayData(item_Ammo9mmFMJ,	1);
	SetItemTypeMaxArrayData(item_AmmoFlechette,	1);
	SetItemTypeMaxArrayData(item_AmmoHomeBuck,	1);
	SetItemTypeMaxArrayData(item_Ammo556Tracer,	1);
	SetItemTypeMaxArrayData(item_Ammo556HP,		1);
	SetItemTypeMaxArrayData(item_Ammo357Tracer,	1);
	SetItemTypeMaxArrayData(item_Ammo762,		1);

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

	//									name		bleedrate
	calibre_9mm		= DefineAmmoCalibre("9mm",		0.15);
	calibre_50c		= DefineAmmoCalibre(".50",		0.23);
	calibre_12g		= DefineAmmoCalibre("12 Gauge",	0.31);
	calibre_556		= DefineAmmoCalibre("5.56mm",	0.19);
	calibre_357		= DefineAmmoCalibre(".357",		0.36);
	calibre_762		= DefineAmmoCalibre("7.62",		0.30);
	calibre_rpg		= DefineAmmoCalibre("RPG",		0.0);
	calibre_fuel	= DefineAmmoCalibre("Fuel",		0.0);
	calibre_film	= DefineAmmoCalibre("Film",		0.0);

	anim_Blunt		= DefineAnimSet();
	anim_Stab		= DefineAnimSet();
	anim_Heavy		= DefineAnimSet();

	//							animidx
	AddAnimToSet(anim_Blunt,	26);
	AddAnimToSet(anim_Blunt,	17);
	AddAnimToSet(anim_Blunt,	18);
	AddAnimToSet(anim_Blunt,	19);
	AddAnimToSet(anim_Stab,		751);
	AddAnimToSet(anim_Heavy,	19);
	AddAnimToSet(anim_Heavy,	20);

	/*
		baseweapon - GTA weapon ID used for this weapon class. This is the
		GTA weapon that the player will be given when using the item. When this
		value is 0, it indicates the weapon is a custom type that doesn't use a
		GTA weapon as a template.

		calibre - a calibre from the defined calibres above. The calibre
		determines the base bleedrate of the rounds fired from the weapon. Melee
		weapons use the muzzle velocity parameter in the function with bleedrate
		and magsize with knockout chance multiplier.

		muzzvelocity - the simulated initial velocity of the round after being
		fired. This value simulates the muzzle velocity of the weapon which
		affects how much the bullet's velocity is affected by distance. A higher
		muzzle velocity results in rounds that can travel quite far without
		losing velocity and thus energy (which affects the resulting bleedrate
		and knockout chance).

		magsize
	*/

	//					itemtype				baseweapon					calibre			bleedrate		koprob	n/a		animset
	DefineItemTypeWeapon(item_Wrench,			0,							NO_CALIBRE,		0.01,			_:1.20,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Crowbar,			0,							NO_CALIBRE,		0.03,			_:1.25,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Hammer,			0,							NO_CALIBRE,		0.02,			_:1.30,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Rake,				0,							NO_CALIBRE,		0.18,			_:1.30,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Cane,				0,							NO_CALIBRE,		0.08,			_:1.25,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_StunGun,			0,							NO_CALIBRE,		0.0,			0,		0,		anim_Stab);
	DefineItemTypeWeapon(item_Screwdriver,		0,							NO_CALIBRE,		0.24,			0,		0,		anim_Stab);
	DefineItemTypeWeapon(item_Mailbox,			0,							NO_CALIBRE,		0.0,			_:1.40,	0,		anim_Heavy);
	//					itemtype				baseweapon					calibre			bleedrate		koprob	n/a		animset
	DefineItemTypeWeapon(item_Knuckles,			WEAPON_BRASSKNUCKLE,		NO_CALIBRE,		0.05,			20,		0);
	DefineItemTypeWeapon(item_GolfClub,			WEAPON_GOLFCLUB,			NO_CALIBRE,		0.07,			35,		0);
	DefineItemTypeWeapon(item_Baton,			WEAPON_NITESTICK,			NO_CALIBRE,		0.03,			24,		0);
	DefineItemTypeWeapon(item_Knife,			WEAPON_KNIFE,				NO_CALIBRE,		0.35,			14,		0);
	DefineItemTypeWeapon(item_Bat,				WEAPON_BAT,					NO_CALIBRE,		0.09,			35,		0);
	DefineItemTypeWeapon(item_Spade,			WEAPON_SHOVEL,				NO_CALIBRE,		0.21,			40,		0);
	DefineItemTypeWeapon(item_PoolCue,			WEAPON_POOLSTICK,			NO_CALIBRE,		0.08,			37,		0);
	DefineItemTypeWeapon(item_Sword,			WEAPON_KATANA,				NO_CALIBRE,		0.44,			15,		0);
	DefineItemTypeWeapon(item_Chainsaw,			WEAPON_CHAINSAW,			NO_CALIBRE,		0.93,			19,		0);
	DefineItemTypeWeapon(item_Dildo1,			WEAPON_DILDO,				NO_CALIBRE,		0.001,			0,		0);
	DefineItemTypeWeapon(item_Dildo2,			WEAPON_DILDO2,				NO_CALIBRE,		0.001,			0,		0);
	DefineItemTypeWeapon(item_Dildo3,			WEAPON_VIBRATOR,			NO_CALIBRE,		0.001,			0,		0);
	DefineItemTypeWeapon(item_Dildo4,			WEAPON_VIBRATOR2,			NO_CALIBRE,		0.001,			0,		0);
	DefineItemTypeWeapon(item_Flowers,			WEAPON_FLOWER,				NO_CALIBRE,		0.001,			0,		0);
	DefineItemTypeWeapon(item_WalkingCane,		WEAPON_CANE,				NO_CALIBRE,		0.06,			24,		0);
	DefineItemTypeWeapon(item_Grenade,			WEAPON_GRENADE,				NO_CALIBRE,		0.0,			0,		0);
	DefineItemTypeWeapon(item_Teargas,			WEAPON_TEARGAS,				NO_CALIBRE,		0.0,			0,		0);
	DefineItemTypeWeapon(item_Molotov,			WEAPON_MOLTOV,				NO_CALIBRE,		0.0,			0,		0);
	//					itemtype				baseweapon					calibre			muzzvelocity	magsize	maxmags		animset
	DefineItemTypeWeapon(item_M9Pistol,			WEAPON_COLT45,				calibre_9mm,	300.0,			10,		1);
	DefineItemTypeWeapon(item_M9PistolSD,		WEAPON_SILENCED,			calibre_9mm,	250.0,			10,		1);
	DefineItemTypeWeapon(item_DesertEagle,		WEAPON_DEAGLE,				calibre_357,	420.0,			7,		1);
	DefineItemTypeWeapon(item_PumpShotgun,		WEAPON_SHOTGUN,				calibre_12g,	475.0,			6,		1);
	DefineItemTypeWeapon(item_Sawnoff,			WEAPON_SAWEDOFF,			calibre_12g,	265.0,			2,		1);
	DefineItemTypeWeapon(item_Spas12,			WEAPON_SHOTGSPA,			calibre_12g,	480.0,			6,		1);
	DefineItemTypeWeapon(item_Mac10,			WEAPON_UZI,					calibre_9mm,	366.0,			35,		1);
	DefineItemTypeWeapon(item_MP5,				WEAPON_MP5,					calibre_9mm,	400.0,			30,		1);
	DefineItemTypeWeapon(item_AK47Rifle,		WEAPON_AK47,				calibre_556,	715.0,			30,		1);
	DefineItemTypeWeapon(item_M16Rifle,			WEAPON_M4,					calibre_556,	948.0,			30,		1);
	DefineItemTypeWeapon(item_Tec9,				WEAPON_TEC9,				calibre_9mm,	360.0,			30,		1);
	DefineItemTypeWeapon(item_SemiAutoRifle,	WEAPON_RIFLE,				calibre_357,	829.0,			5,		1);
	DefineItemTypeWeapon(item_SniperRifle,		WEAPON_SNIPER,				calibre_357,	864.0,			5,		1);
	DefineItemTypeWeapon(item_RocketLauncher,	WEAPON_ROCKETLAUNCHER,		calibre_rpg,	0.0,			1,		0);
	DefineItemTypeWeapon(item_Heatseeker,		WEAPON_HEATSEEKER,			calibre_rpg,	0.0,			1,		0);
	DefineItemTypeWeapon(item_Flamer,			WEAPON_FLAMETHROWER,		calibre_fuel,	0.0,			100,	1);
	DefineItemTypeWeapon(item_Minigun,			WEAPON_MINIGUN,				calibre_556,	853.0,			100,	1);
	DefineItemTypeWeapon(item_RemoteBomb,		WEAPON_SATCHEL,				NO_CALIBRE,		0.0,			1,		1);
	DefineItemTypeWeapon(item_Detonator,		WEAPON_BOMB,				NO_CALIBRE,		0.0,			1,		1);
	DefineItemTypeWeapon(item_SprayPaint,		WEAPON_SPRAYCAN,			NO_CALIBRE,		0.0,			100,	0);
	DefineItemTypeWeapon(item_Extinguisher,		WEAPON_FIREEXTINGUISHER,	NO_CALIBRE,		0.0,			100,	0);
	DefineItemTypeWeapon(item_Camera,			WEAPON_CAMERA,				calibre_film,	1337.0,			24,		4);
	DefineItemTypeWeapon(item_VehicleWeapon,	WEAPON_M4,					calibre_556,	750.0,			0,		1);

	/*
		name - the additional name given to the ammunition item. This is used to
		format the full item name or weapon name which includes the amount of
		ammo loaded into the weapon or ammo container, the calibre and this name
		which corresponds to the type or behaviour of the ammo. This can refer
		to the jacket type, contained substance or any other firearm term.

		bld - bleedrate multiplier for ammo type. After the base bleedrate for
		a bullet has been calculated using the distance, calibre bleedrate and
		bullet velocity, this value is multiplied against that bleedrate. This
		allows different ammunition types of the same calibre to inflict
		different bleed rates.

		ko - knockout chance multiplier for ammo type. When PlayerInflictWound
		is called, a knockout chance multiplier is sent, the default is 1.0
		resulting no chance in the chance to get knocked out. This value allows
		different ammunition types of the same calibre to affect the chance of a
		target being knocked out by a shot.

		pen - armour and material penetration for ammo type. Unique only to ammo
		types and not calibres, this value changes how the ammunition treats
		targets wearing armour. The base value is 0.0 which is no bleedrate and
		a value of 1.0 results in the round completely ignoring armour. Any
		values above this will just multiply the resulting bleedrate more.

		size - maximum size for the ammo tin item. When ammunition spawns in the
		world, this value is used as a capacity limit for how much ammunition
		may spawn inside the ammo item. It also acts as a limit for transferring
		ammo to the item.
	*/
	//					itemtype				name				calibre			bld		ko		pen		size
	DefineItemTypeAmmo(item_Ammo9mm,			"Hollow Point",		calibre_9mm,	1.0,	1.0,	0.2,	20);
	DefineItemTypeAmmo(item_Ammo50,				"Action Express",	calibre_50c,	1.0,	1.0,	0.9,	28);
	DefineItemTypeAmmo(item_AmmoBuck,			"No. 1",			calibre_12g,	1.0,	1.0,	0.5,	24);
	DefineItemTypeAmmo(item_Ammo556,			"FMJ",				calibre_556,	1.0,	1.0,	0.8,	30);
	DefineItemTypeAmmo(item_Ammo357,			"FMJ",				calibre_357,	1.0,	1.0,	0.9,	10);
	DefineItemTypeAmmo(item_AmmoRocket,			"RPG",				calibre_rpg,	1.0,	1.0,	2.0,	1);
	DefineItemTypeAmmo(item_GasCan,				"Petrol",			calibre_fuel,	0.0,	0.0,	0.0,	20);
	DefineItemTypeAmmo(item_Ammo9mmFMJ,			"FMJ",				calibre_9mm,	1.2,	0.5,	0.8,	20);
	DefineItemTypeAmmo(item_AmmoFlechette,		"Flechette",		calibre_12g,	1.6,	0.6,	0.2,	8);
	DefineItemTypeAmmo(item_AmmoHomeBuck,		"Improvised",		calibre_12g,	1.6,	0.4,	0.3,	14);
	DefineItemTypeAmmo(item_Ammo556Tracer,		"Tracer",			calibre_556,	0.9,	1.1,	0.5,	30);
	DefineItemTypeAmmo(item_Ammo556HP,			"Hollow Point",		calibre_556,	1.3,	1.5,	0.4,	30);
	DefineItemTypeAmmo(item_Ammo357Tracer,		"Tracer",			calibre_357,	0.9,	1.1,	0.6,	10);
	DefineItemTypeAmmo(item_Ammo762,			"Ammo",				calibre_762,	1.0,	1.0,	0.9,	30);


	SetItemTypeHolsterable(item_Baton,			8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_Sword,			1, 0.123097, -0.129424, -0.139251, 0.000000, 301.455871, 0.000000, 600, "GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_M9Pistol,		8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_M9PistolSD,		8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_DesertEagle,	8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_PumpShotgun,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Sawnoff,		8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_Spas12,			1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Mac10,			8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_MP5,			1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_AK47Rifle,		1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_M16Rifle,		1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Tec9,			8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_SemiAutoRifle,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_SniperRifle,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_RocketLauncher,	1, 0.181966, -0.238397, -0.094830, 252.7912, 353.8938, 357.5294, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Heatseeker,		1, 0.181966, -0.238397, -0.094830, 252.7912, 353.8938, 357.5294, 800,	"GOGGLES",	"GOGGLES_PUT_ON");

	SetItemTypeHolsterable(item_StunGun,		8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_Shield,			1, 0.027000, -0.039999, 0.170000, 270.0000, -171.0000, 90.0000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Mailbox,		1, 0.457000, -0.094999, -0.465000,  2.099999, -42.600, -94.500, 800,	"GOGGLES",	"GOGGLES_PUT_ON");


	DefineFoodItem(item_HotDog,			20.0, 1, 0);
	DefineFoodItem(item_Pizza,			50.0, 0, 0);
	DefineFoodItem(item_Burger,			25.0, 1, 0);
	DefineFoodItem(item_BurgerBox,		25.0, 0, 0);
	DefineFoodItem(item_Taco,			15.0, 0, 0);
	DefineFoodItem(item_BurgerBag,		30.0, 0, 0);
	DefineFoodItem(item_Meat,			65.0, 1, 0);
	DefineFoodItem(item_Bottle,			1.0, 0, 1);
	DefineFoodItem(item_CanDrink,		1.0, 0, 1);


	DefineDefenceItem(item_Door,		180.0, 90.0, 0.0,	90.0, 90.0, 0.0,	-0.0331,	2);
	DefineDefenceItem(item_MetPanel,	90.0, 90.0, 0.0,	0.0, 90.0, 0.0,		-0.0092,	5);
	DefineDefenceItem(item_MetalGate,	0.0, 0.0, 0.0,		270.0, 0.0, 0.0,	1.2007,		4);
	DefineDefenceItem(item_CrateDoor,	0.0, 90.0, 0.0,		90.0, 90.0, 0.0,	1.4738,		5);
	DefineDefenceItem(item_CorPanel,	0.0, 90.0, 0.0,		90.0, 90.0, 0.0,	1.1859,		6);
	DefineDefenceItem(item_ShipDoor,	90.0, 90.0, 0.0,	180.0, 90.0, 0.0,	1.3966,		9);
	DefineDefenceItem(item_RustyDoor,	90.0, 90.0, 0.0,	180.0, 90.0, 0.0,	2.1143,		7);
	DefineDefenceItem(item_MetalStand,	90.0, 0.0, 0.0,		0.0, 0.0, 0.0,		0.5998,		7);
	DefineDefenceItem(item_RustyMetal,	0.0, 180.0, 90.0,	0.0, 270.0, 90.0,	1.4401,		5);
	DefineDefenceItem(item_WoodPanel,	90.0, 0.0, 23.5,	0.0, 0.0, 0.0,		1.0161,		7);


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
	DefineItemCombo(item_StunGun,		item_RadioPole,		item_Fluctuator);
	DefineItemCombo(item_MobilePhone,	item_Keypad,		item_IoUnit);
	DefineItemCombo(item_PowerSupply,	item_Fluctuator,	item_FluxCap);
	DefineItemCombo(item_StorageUnit,	item_IoUnit,		item_DataInterface);
	DefineItemCombo(item_FluxCap,		item_DataInterface,	item_HackDevice);
	DefineItemCombo(item_PowerSupply,	item_Timer,			item_Motor);
	DefineItemCombo(item_Key,			item_Motor,			item_LocksmithKit);
	DefineItemCombo(item_Motor,			item_Fluctuator,	item_StarterMotor);
	DefineItemCombo(item_IoUnit,		item_PowerSupply,	item_AdvancedKeypad);
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
	DefineLootIndex(loot_SupplyCrate);


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

	drug_Antibiotic	= DefineDrugType("Antibiotic",	300000);
	drug_Painkill	= DefineDrugType("Painkill",	300000);
	drug_Lsd		= DefineDrugType("Lsd",			300000);
	drug_Air		= DefineDrugType("Air",			300000);
	drug_Morphine	= DefineDrugType("Morphine",	300000);
	drug_Adrenaline	= DefineDrugType("Adrenaline",	300000);
	drug_Heroin		= DefineDrugType("Heroin",		300000);

	DefineSafeboxType("Medium Box",		item_MediumBox,		6, 6, 3, 2);
	DefineSafeboxType("Small Box",		item_SmallBox,		4, 2, 1, 0);
	DefineSafeboxType("Large Box",		item_LargeBox,		10, 8, 6, 6);
	DefineSafeboxType("Capsule",		item_Capsule,		2, 2, 0, 0);

	DefineBagType("Backpack",			item_Backpack,		8, 4, 1, 0, -0.110900, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Small Bag",			item_Satchel,		4, 2, 1, 0, 0.241894, -0.160918, 0.181463, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Parachute Bag",		item_ParaBag,		6, 4, 2, 0, 0.039470, -0.088898, -0.009887, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Large Backpack",		item_LargeBackpack,	9, 5, 2, 0, -0.2209, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.2000000, 1.300000, 1.100000);

	CreateNewSprayTag(-399.76999, 1514.92004, 75.26000,   0.00000, 0.00000, 0.00000);
	CreateNewSprayTag(-229.34000, 1082.34998, 20.29000,   0.00000, 0.00000, 0.00000);
	CreateNewSprayTag(-2442.16992, 2299.22998, 5.71000,   0.00000, 0.00000, 270.00000);
	CreateNewSprayTag(-2662.94995, 2121.43994, 2.14000,   0.00000, 0.00000, 180.00000);
	CreateNewSprayTag(146.92000, 1831.78003, 18.02000,   0.00000, 0.00000, 90.00000);
	CreateNewSprayTag(1172.88086, -1313.05103, 14.24630,   10.00000, 0.00000, 180.00000);
	CreateNewSprayTag(1237.39001, -1631.59998, 28.02000,   0.00000, 0.00000, 91.00000);
	CreateNewSprayTag(1118.51100, -1540.14001, 23.66000,   0.00000, 0.00000, 178.46001);
	CreateNewSprayTag(1202.10999, -1201.55005, 20.47000,   0.00000, 0.00000, 90.00000);
	CreateNewSprayTag(1264.15002, -1270.28003, 14.26000,   0.00000, 0.00000, 270.00000);
	CreateNewSprayTag(-1908.90003, 299.56000, 41.52000,   0.00000, 0.00000, 180.00000);
	CreateNewSprayTag(-2636.69995, 635.52002, 15.13000,   0.00000, 0.00000, 0.00000);
	CreateNewSprayTag(-2224.75000, 881.27002, 84.13000,   0.00000, 0.00000, 90.00000);
	CreateNewSprayTag(-1788.31995, 748.41998, 25.36000,   0.00000, 0.00000, 270.00000);


	// Initiation Code

	CallLocalFunction("OnLoad", "");

	// Data From Files

	LoadAdminData();

	LoadVehicles	(true, true);
	LoadSafeboxes	(true, true);
	LoadTents		(true, true);
	LoadDefences	(true, true);
	LoadSigns		(true, true);

	LoadSprayTags();

	if(gPerformFileCheck)
		PerformGlobalPlayerFileCheck();

	for(new i; i < MAX_PLAYERS; i++)
	{
		ResetVariables(i);
	}

	defer AutoSave();
	defer InfoMessage();

	return 1;
}

public OnGameModeExit()
{
	log("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\nGamemode exiting...*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*");

	djson_GameModeExit();

	// First param: print each individual entity when it's saved
	// Second param: print the total amount of entities saved

	SavePlayerVehicles	(true, true);
	SaveSafeboxes		(true, true);
	SaveTents			(true, true);
	SaveDefences		(true, true);
	SaveSigns			(true, true);

	SaveSprayTags();

	print("\nSave Complete! Safe to shut down.");

	return 1;
}

public SetRestart(seconds)
{
	printf("Restarting server in: %ds", seconds);
	gServerUptime = gServerMaxUptime - seconds;
}

RestartGamemode()
{
	log("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\nGamemode restarting...*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*");
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

task GameUpdate[1000]()
{
	WeatherUpdate();

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
			TextDrawShowForAll(RestartCount);
		}

		gServerUptime++;
	}
}

timer InfoMessage[gInfoMessageInterval * 60 * 1000]()
{
	if(gCurrentInfoMessage >= gTotalInfoMessage)
		gCurrentInfoMessage = 0;

	MsgAll(YELLOW, sprintf(" >  "C_BLUE"%s", gInfoMessage[gCurrentInfoMessage]));

	gCurrentInfoMessage++;

	defer InfoMessage();
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
		sql_string[256],
		dbcolumns;

	format(query, sizeof(query), "pragma table_info(%s)", tablename);
	result = db_query(database, query);
	db_get_field(result, 0, sql_string, sizeof(sql_string));

	dbcolumns = db_num_rows(result);

	if(dbcolumns != expectedcolumns)
	{
		printf("ERROR: Table '%s' has %d columns, expected %d:", tablename, dbcolumns, expectedcolumns);
		print("Please verify table structure against column list in script.");
		print(sql_string);

		// Put the server into a loop to stop it so the user can read the message.
		// It won't function correctly with bad databases anyway.
		for(;;){}
	}
}
