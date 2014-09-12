#include <YSI\y_hooks>


/*==============================================================================

	Everything global is declared, defined and initialised here. This ensures
	that all entity definitions are not null before other scripts initialise.
	Called AFTER OnGameModeInit_Setup and BEFORE other OnScriptInit hooks.

==============================================================================*/


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


// DATABASES
new
DB:				gAccounts,
DB:				gWorld;

// GLOBAL SERVER SETTINGS (Todo: modularise)
new
		// player
		gMessageOfTheDay[MAX_MOTD_LEN],
		gWebsiteURL[MAX_WEBSITE_NAME],
		gInfoMessage[MAX_INFO_MESSAGE][MAX_INFO_MESSAGE_LEN],
		gRuleList[MAX_RULE][MAX_RULE_LEN],
		gStaffList[MAX_STAFF][MAX_STAFF_LEN],
		gInfoMessageInterval,

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
				calibre_50cae,
				calibre_12g,
				calibre_556,
				calibre_357,
				calibre_762,
				calibre_rpg,
				calibre_fuel,
				calibre_film,
				calibre_50bmg,
				calibre_308;

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
ItemType:		item_WASR3Rifle		= INVALID_ITEM_TYPE,
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
ItemType:		item_Ammo762		= INVALID_ITEM_TYPE,
ItemType:		item_AK47Rifle		= INVALID_ITEM_TYPE,
ItemType:		item_M77RMRifle		= INVALID_ITEM_TYPE,
ItemType:		item_DogsBreath		= INVALID_ITEM_TYPE,
// 190
ItemType:		item_Ammo50BMG		= INVALID_ITEM_TYPE,
ItemType:		item_Ammo308		= INVALID_ITEM_TYPE,
ItemType:		item_Model70Rifle	= INVALID_ITEM_TYPE,
ItemType:		item_LenKnocksRifle	= INVALID_ITEM_TYPE;

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


forward SetRestart(seconds); // Todo: move to restart module


public OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Init'...");


// 00
	item_NULL			= DefineItemType("NULL",				"NULL",				0,		1);
	item_Knuckles		= DefineItemType("Knuckle Duster", 		"Knuckles",			331,	1,	90.0);
	item_GolfClub		= DefineItemType("Golf Club", 			"GolfClub",			333,	3,	90.0);
	item_Baton			= DefineItemType("Baton", 				"Baton",			334,	2,	90.0);
	item_Knife			= DefineItemType("Knife", 				"Knife",			335,	1,	90.0);
	item_Bat			= DefineItemType("Baseball Bat", 		"Bat",				336,	3,	90.0);
	item_Spade			= DefineItemType("Spade", 				"Spade",			337,	3,	90.0);
	item_PoolCue		= DefineItemType("Pool Cue", 			"PoolCue",			338,	5,	90.0);
	item_Sword			= DefineItemType("Sword", 				"Sword",			339,	4,	90.0);
	item_Chainsaw		= DefineItemType("Chainsaw", 			"Chainsaw",			341,	8,	90.0);
// 10
	item_Dildo1			= DefineItemType("Dildo",				"Dildo1",			321,	1,	90.0);
	item_Dildo2			= DefineItemType("Dildo",				"Dildo2",			322,	1,	90.0);
	item_Dildo3			= DefineItemType("Dildo",				"Dildo3",			323,	1,	90.0);
	item_Dildo4			= DefineItemType("Dildo",				"Dildo4",			324,	1,	90.0);
	item_Flowers		= DefineItemType("Flowers",				"Flowers",			325,	2,	90.0);
	item_WalkingCane	= DefineItemType("Cane",				"WalkingCane",		326,	3,	90.0);
	item_Grenade		= DefineItemType("Grenade",				"Grenade",			342,	2,	90.0);
	item_Teargas		= DefineItemType("Teargas",				"Teargas",			343,	2,	90.0);
	item_Molotov		= DefineItemType("Molotov",				"Molotov",			344,	2,	90.0);
	item_NULL2			= DefineItemType("<null>",				"NULL2",			000,	1,	90.0);
// 20
	item_NULL3			= DefineItemType("<null>",				"NULL3",			000,	1,	90.0);
	item_NULL4			= DefineItemType("<null>",				"NULL4",			000,	1,	90.0);
	item_M9Pistol		= DefineItemType("M9",					"M9Pistol",			346,	2,	90.0);
	item_M9PistolSD		= DefineItemType("M9 SD",				"M9PistolSD",		347,	3,	90.0);
	item_DesertEagle	= DefineItemType("Desert Eagle",		"DesertEagle",		348,	2,	90.0);
	item_PumpShotgun	= DefineItemType("Shotgun",				"PumpShotgun",		349,	5,	90.0);
	item_Sawnoff		= DefineItemType("Sawnoff",				"Sawnoff",			350,	3,	90.0);
	item_Spas12			= DefineItemType("Spas 12",				"Spas12",			351,	6,	90.0);
	item_Mac10			= DefineItemType("Mac 10",				"Mac10",			352,	3,	90.0);
	item_MP5			= DefineItemType("MP5",					"MP5",				353,	5,	90.0);
// 30
	item_WASR3Rifle		= DefineItemType("WASR-3",				"WASR3Rifle",		355,	8,	90.0);
	item_M16Rifle		= DefineItemType("M16",					"M16Rifle",			356,	8,	90.0);
	item_Tec9			= DefineItemType("Tec 9",				"Tec9",				372,	4,	90.0);
	item_SemiAutoRifle	= DefineItemType("Rifle",				"SemiAutoRifle",	357,	9,	90.0);
	item_SniperRifle	= DefineItemType("Sniper",				"SniperRifle",		358,	9,	90.0);
	item_RocketLauncher	= DefineItemType("RPG",					"RocketLauncher",	359,	12,	90.0);
	item_Heatseeker		= DefineItemType("Heatseeker",			"Heatseeker",		360,	12,	90.0);
	item_Flamer			= DefineItemType("Flamer",				"Flamer",			361,	14,	90.0);
	item_Minigun		= DefineItemType("Minigun",				"Minigun",			362,	14,	90.0);
	item_RemoteBomb		= DefineItemType("Remote Bomb",			"RemoteBomb",		363,	2,	90.0);
// 40
	item_Detonator		= DefineItemType("Detonator",			"Detonator",		364,	2,	90.0);
	item_SprayPaint		= DefineItemType("Spray Paint",			"SprayPaint",		365,	1,	90.0);
	item_Extinguisher	= DefineItemType("Extinguisher",		"Extinguisher",		366,	4,	90.0);
	item_Camera			= DefineItemType("Camera",				"Camera",			367,	2,	90.0);
	item_NightVision	= DefineItemType("Night Vision",		"NightVision",		000,	2,	90.0);
	item_ThermalVision	= DefineItemType("Thermal Vision",		"ThermalVision",	000,	2,	90.0);
	item_Parachute		= DefineItemType("Parachute",			"Parachute",		371,	6,	90.0, 0.0, 0.0,			0.0,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000);
	item_Medkit			= DefineItemType("Medkit",				"Medkit",			1580,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_HardDrive		= DefineItemType("Hard Drive",			"HardDrive",		328,	1,	90.0, 0.0, 0.0,			0.0);
	item_Key			= DefineItemType("Key",					"Key",				327,	1,	0.0, 0.0, 0.0,			0.01);//, .colour = 0xFFDEDEDE);
// 50
	item_FireworkBox	= DefineItemType("Fireworks",			"FireworkBox",		2039,	2,	0.0, 0.0, 0.0,			0.0,	0.096996, 0.044811, 0.035688, 4.759557, 255.625167, 0.000000);
	item_FireLighter	= DefineItemType("Lighter",				"FireLighter",		327,	1,	0.0, 0.0, 0.0,			0.0);
	item_Timer			= DefineItemType("Timer Device",		"Timer",			2922,	2,	90.0, 0.0, 0.0,			0.0,	0.231612, 0.050027, 0.017069, 0.000000, 343.020019, 180.000000);
	item_Explosive		= DefineItemType("TNT",					"Explosive",		1576,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_TntTimebomb	= DefineItemType("Timed TNT",			"TntTimebomb",		1252,	2,	270.0, 0.0, 0.0,		0.0);
	item_Battery		= DefineItemType("Battery",				"Battery",			1579,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_Fusebox		= DefineItemType("Fuse Box",			"Fusebox",			328,	2,	90.0, 0.0, 0.0,			0.0);
	item_Bottle			= DefineItemType("Bottle",				"Bottle",			1543,	1,	0.0, 0.0, 0.0,			0.0,	0.060376, 0.032063, -0.204802, 0.000000, 0.000000, 0.000000);
	item_Sign			= DefineItemType("Sign",				"Sign",				19471,	6,	0.0, 0.0, 270.0,		0.0);
	item_Armour			= DefineItemType("Armour",				"Armour",			19515,	4,	90.0, 0.0, 0.0,			0.0,	0.300333, -0.090105, 0.000000, 0.000000, 0.000000, 180.000000);
// 60
	item_Bandage		= DefineItemType("Bandage",				"Bandage",			1575,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_FishRod		= DefineItemType("Fishing Rod",			"FishRod",			18632,	6,	90.0, 0.0, 0.0,			0.0,	0.091496, 0.019614, 0.000000, 185.619995, 354.958374, 0.000000);
	item_Wrench			= DefineItemType("Wrench",				"Wrench",			18633,	2,	0.0, 90.0, 0.0,			0.0,	0.084695, -0.009181, 0.152275, 98.865089, 270.085449, 0.000000);
	item_Crowbar		= DefineItemType("Crowbar",				"Crowbar",			18634,	2,	0.0, 90.0, 0.0,			0.0,	0.066177, 0.011153, 0.038410, 97.289527, 270.962554, 1.114514);
	item_Hammer			= DefineItemType("Hammer",				"Hammer",			18635,	2,	270.0, 0.0, 0.0,		0.01,	0.000000, -0.008230, 0.000000, 6.428617, 0.000000, 0.000000);
	item_Shield			= DefineItemType("Shield",				"Shield",			18637,	8,	0.0, 0.0, 0.0,			0.0,	-0.262389, 0.016478, -0.151046, 103.597534, 6.474381, 38.321765);
	item_Flashlight		= DefineItemType("Flashlight",			"Flashlight",		18641,	2,	90.0, 0.0, 0.0,			0.0,	0.061910, 0.022700, 0.039052, 190.938354, 0.000000, 0.000000);
	item_StunGun		= DefineItemType("Stun Gun",			"StunGun",			18642,	1,	90.0, 0.0, 0.0,			0.0,	0.079878, 0.014009, 0.029525, 180.000000, 0.000000, 0.000000);
	item_LaserPoint		= DefineItemType("Laser Pointer",		"LaserPoint",		18643,	1,	0.0, 0.0, 90.0,			0.0,	0.066244, 0.010838, -0.000024, 6.443027, 287.441467, 0.000000);
	item_Screwdriver	= DefineItemType("Screwdriver",			"Screwdriver",		18644,	1,	90.0, 0.0, 0.0,			0.0,	0.099341, 0.021018, 0.009145, 193.644195, 0.000000, 0.000000);
// 70
	item_MobilePhone	= DefineItemType("Mobile Phone",		"MobilePhone",		18865,	1,	0.0, 0.0, 0.0,			0.0,	0.103904, -0.003697, -0.015173, 94.655189, 184.031860, 0.000000);
	item_Pager			= DefineItemType("Pager",				"Pager",			18875,	1,	0.0, 0.0, 0.0,			0.0,	0.097277, 0.027625, 0.013023, 90.819244, 191.427993, 0.000000);
	item_Rake			= DefineItemType("Rake",				"Rake",				18890,	6,	90.0, 0.0, 0.0,			0.0,	-0.002599, 0.003984, 0.026356, 190.231231, 0.222518, 271.565185);
	item_HotDog			= DefineItemType("Hotdog",				"HotDog",			19346,	1,	0.0, 0.0, 0.0,			0.0,	0.088718, 0.035828, 0.008570, 272.851745, 354.704772, 9.342185);
	item_EasterEgg		= DefineItemType("Easter Egg",			"EasterEgg",		19345,	3,	0.0, 0.0, 0.0,			0.0,	0.000000, 0.000000, 0.000000, 0.000000, 90.000000, 0.000000);
	item_Cane			= DefineItemType("Cane",				"Cane",				19348,	3,	270.0, 0.0, 0.0,		0.0,	0.041865, 0.022883, -0.079726, 4.967216, 10.411237, 0.000000);
	item_HandCuffs		= DefineItemType("Handcuffs",			"HandCuffs",		19418,	1,	270.0, 0.0, 0.0,		0.0,	0.077635, 0.011612, 0.000000, 0.000000, 90.000000, 0.000000);
	item_Bucket			= DefineItemType("Bucket",				"Bucket",			19468,	2,	0.0, 0.0, 0.0,			0.0,	0.293691, -0.074108, 0.020810, 148.961685, 280.067260, 151.782791);
	item_GasMask		= DefineItemType("Gas Mask",			"GasMask",			19472,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000);
	item_Flag			= DefineItemType("Flag",				"Flag",				2993,	3,	0.0, 0.0, 0.0,			0.0,	0.045789, 0.026306, -0.078802, 8.777217, 0.272155, 0.000000);
// 80
	item_DoctorBag		= DefineItemType("Doctor's Bag",		"DoctorBag",		1210,	3,	0.0, 0.0, 90.0,			0.0,	0.285915, 0.078406, -0.009429, 0.000000, 270.000000, 0.000000);
	item_Backpack		= DefineItemType("Backpack",			"Backpack",			3026,	8,	270.0, 0.0, 90.0,		0.0,	0.470918, 0.150153, 0.055384, 181.319580, 7.513789, 163.436065);
	item_Satchel		= DefineItemType("Small Bag",			"Satchel",			363,	4,	270.0, 0.0, 0.0,		0.0,	0.052853, 0.034967, -0.177413, 0.000000, 261.397491, 349.759826);
	item_Wheel			= DefineItemType("Wheel",				"Wheel",			1079,	9,	0.0, 0.0, 90.0,			0.436,	-0.098016, 0.356168, -0.309851, 258.455596, 346.618103, 354.313049, true);
	item_MotionSense	= DefineItemType("Motion Sensor",		"MotionSense",		327,	1,	0.0, 0.0, 0.0,			0.0,	0.008151, 0.012682, -0.050635, 0.000000, 0.000000, 0.000000);
	item_Accelerometer	= DefineItemType("Accelerometer",		"Accelerometer",	327,	1,	0.0, 0.0, 0.0,			0.0,	0.008151, 0.012682, -0.050635, 0.000000, 0.000000, 0.000000);
	item_TntProxMine	= DefineItemType("Proximity TNT",		"TntProxMine",		1576,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_IedBomb		= DefineItemType("IED",					"IedBomb",			2033,	2,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891);
	item_Pizza			= DefineItemType("Pizza",				"Pizza",			1582,	2,	0.0, 0.0, 0.0,			0.0,	0.320344, 0.064041, 0.168296, 92.941909, 358.492523, 14.915378);
	item_Burger			= DefineItemType("Burger",				"Burger",			2703,	1,	-76.0, 257.0, -11.0,	0.0,	0.066739, 0.041782, 0.026828, 3.703052, 3.163064, 6.946474);
// 90
	item_BurgerBox		= DefineItemType("Burger",				"BurgerBox",		2768,	1,	0.0, 0.0, 0.0,			0.0,	0.107883, 0.093265, 0.029676, 91.010627, 7.522015, 0.000000);
	item_Taco			= DefineItemType("Taco",				"Taco",				2769,	1,	0.0, 0.0, 0.0,			0.0,	0.069803, 0.057707, 0.039241, 0.000000, 78.877342, 0.000000);
	item_GasCan			= DefineItemType("Petrol Can",			"GasCan",			1650,	4,	0.0, 0.0, 0.0,			0.27,	0.143402, 0.027548, 0.063652, 0.000000, 253.648208, 0.000000);
	item_Clothes		= DefineItemType("Clothes",				"Clothes",			2891,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_HelmArmy		= DefineItemType("Army Helmet",			"HelmArmy",			19106,	2,	345.0, 270.0, 0.0,		0.045,	0.184999, -0.007999, 0.046999, 94.199989, 22.700027, 4.799994);
	item_MediumBox		= DefineItemType("Medium Box",			"MediumBox",		3014,	6,	0.0, 0.0, 0.0,			0.1844,	-0.027872, 0.145617, -0.246524, 243.789840, 347.397491, 349.931610, true);
	item_SmallBox		= DefineItemType("Small Box",			"SmallBox",			2969,	4,	0.0, 0.0, 0.0,			0.0,	0.114177, 0.089762, -0.173014, 247.160079, 354.746368, 79.219100, true);
	item_LargeBox		= DefineItemType("Large Box",			"LargeBox",			1271,	10,	0.0, 0.0, 0.0,			0.3112,	0.050000, 0.334999, -0.327000,  -23.900018, -10.200002, 11.799987, true);
	item_HockeyMask		= DefineItemType("Hockey Mask",			"HockeyMask",		19036,	1,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Meat			= DefineItemType("Meat",				"Meat",				2804,	3,	0.0, 0.0, 0.0,			0.0,	-0.051398, 0.017334, 0.189188, 270.495391, 353.340423, 167.069869);
// 100
	item_DeadLeg		= DefineItemType("Leg",					"DeadLeg",			2905,	4,	0.0, 0.0, 0.0,			0.0,	0.147815, 0.052444, -0.164205, 253.163970, 358.857666, 167.069869, true);
	item_Torso			= DefineItemType("Torso",				"Torso",			2907,	8,	0.0, 0.0, 270.0,		0.0,	0.087207, 0.093263, -0.280867, 253.355865, 355.971557, 175.203552, true);
	item_LongPlank		= DefineItemType("Plank",				"LongPlank",		2937,	11,	0.0, 0.0, 0.0,			0.0,	0.141491, 0.002142, -0.190920, 248.561920, 350.667724, 175.203552, true);
	item_GreenGloop		= DefineItemType("Unknown",				"GreenGloop",		2976,	4,	0.0, 0.0, 0.0,			0.0,	0.063387, 0.013771, -0.595982, 341.793945, 352.972686, 226.892105, true);
	item_Capsule		= DefineItemType("Capsule",				"Capsule",			3082,	4,	0.0, 0.0, 0.0,			0.0,	0.096439, 0.034642, -0.313377, 341.793945, 348.492706, 240.265777, true);
	item_RadioPole		= DefineItemType("Receiver",			"RadioPole",		3221,	3,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777);
	item_SignShot		= DefineItemType("Sign",				"SignShot",			3265,	3,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777);
	item_Mailbox		= DefineItemType("Mailbox",				"Mailbox",			3407,	4,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777);
	item_Pumpkin		= DefineItemType("Pumpkin",				"Pumpkin",			19320,	6,	0.0, 0.0, 0.0,			0.3,	0.105948, 0.279332, -0.253927, 246.858016, 0.000000, 0.000000, true);
	item_Nailbat		= DefineItemType("Nailbat",				"Nailbat",			2045,	3,	0.0, 0.0, 0.0);
// 110
	item_ZorroMask		= DefineItemType("Zorro Mask",			"ZorroMask",		18974,	1,	0.0, 0.0, 0.0,			0.0,	0.193932, 0.050861, 0.017257, 90.000000, 0.000000, 0.000000);
	item_Barbecue		= DefineItemType("BBQ",					"Barbecue",			1481,	10,	0.0, 0.0, 0.0,			0.6745,	0.106261, 0.004634, -0.144552, 246.614654, 345.892211, 258.267395, true);
	item_Headlight		= DefineItemType("Headlight",			"Headlight",		19280,	1,	90.0, 0.0, 0.0,			0.0,	0.107282, 0.051477, 0.023807, 0.000000, 259.073913, 351.287475);
	item_Pills			= DefineItemType("Pills",				"Pills",			2709,	1,	0.0, 0.0, 0.0,			0.09,	0.044038, 0.082106, 0.000000, 0.000000, 0.000000, 0.000000);
	item_AutoInjec		= DefineItemType("Injector",			"AutoInjec",		2711,	1,	90.0, 0.0, 0.0,			0.028,	0.145485, 0.020127, 0.034870, 0.000000, 260.512817, 349.967254);
	item_BurgerBag		= DefineItemType("Burger",				"BurgerBag",		2663,	2,	0.0, 0.0, 0.0,			0.205,	0.320356, 0.042146, 0.049817, 0.000000, 260.512817, 349.967254);
	item_CanDrink		= DefineItemType("Can",					"CanDrink",			2601,	1,	0.0, 0.0, 0.0,			0.054,	0.064848, 0.059404, 0.017578, 0.000000, 359.136199, 30.178396);
	item_Detergent		= DefineItemType("Detergent",			"Detergent",		1644,	1,	0.0, 0.0, 0.0,			0.1,	0.081913, 0.047686, -0.026389, 95.526962, 0.546049, 358.890563);
	item_Dice			= DefineItemType("Dice",				"Dice",				1851,	6,	0.0, 0.0, 0.0,			0.136,	0.031958, 0.131180, -0.214385, 69.012298, 16.103448, 10.308629, true);
	item_Dynamite		= DefineItemType("Dynamite",			"Dynamite",			1654,	2);
// 120
	item_Door			= DefineItemType("Door",				"Door",				1497,	14,	90.0, 90.0, 0.0,		0.0,	0.313428, -0.507642, -1.340901, 336.984893, 348.837493, 113.141563, true);
	item_MetPanel		= DefineItemType("Metal Panel",			"MetPanel",			1965,	14,	0.0, 90.0, 0.0,			0.0,	0.070050, 0.008440, -0.180277, 338.515014, 349.801025, 33.250347, true);
	item_MetalGate		= DefineItemType("Metal Gate",			"MetalGate",		19303,	14,	270.0, 0.0, 0.0,		0.0,	0.057177, 0.073761, -0.299014,  -19.439863, -10.153647, 105.119079, true);
	item_CrateDoor		= DefineItemType("Crate Door",			"CrateDoor",		3062,	14,	90.0, 90.0, 0.0,		0.0,	0.150177, -0.097238, -0.299014,  -19.439863, -10.153647, 105.119079, true);
	item_CorPanel		= DefineItemType("Corrugated Metal",	"CorPanel",			2904,	15,	90.0, 90.0, 0.0,		0.0,	-0.365094, 1.004213, -0.665850, 337.887634, 172.861953, 68.495330, true);
	item_ShipDoor		= DefineItemType("Ship Door",			"ShipDoor",			2944,	14,	180.0, 90.0, 0.0,		0.0,	0.134831, -0.039784, -0.298796, 337.887634, 172.861953, 162.198867, true);
	item_RustyDoor		= DefineItemType("Metal Panel",			"RustyDoor",		2952,	15,	180.0, 90.0, 0.0,		0.0,	-0.087715, 0.483874, 1.109397, 337.887634, 172.861953, 162.198867, true);
	item_MetalStand		= DefineItemType("Metal Stand",			"MetalStand",		2978,	13,	0.0, 0.0, 0.0,			0.0,	-0.106182, 0.534724, -0.363847, 278.598419, 68.350570, 57.954662, true);
	item_RustyMetal		= DefineItemType("Rusty Metal Sheet",	"RustyMetal",		16637,	16,	0.0, 270.0, 90.0,		0.0,	-0.068822, 0.989761, -0.620014,  -114.639907, -10.153647, 170.419097, true);
	item_WoodPanel		= DefineItemType("Wood Ramp",			"WoodPanel",		5153,	16,	360.0, 23.537, 0.0,		0.0,	-0.342762, 0.908910, -0.453703, 296.326019, 46.126548, 226.118209, true);
// 130
	item_Flare			= DefineItemType("Flare",				"Flare",			345,	2);
	item_TntPhoneBomb	= DefineItemType("Phone Remote TNT",	"TntPhoneBomb",		1576,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_ParaBag		= DefineItemType("Parachute Bag",		"ParaBag",			371,	6,	90.0, 0.0, 0.0,			0.0,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000);
	item_Keypad			= DefineItemType("Keypad",				"Keypad",			19273,	2,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000);
	item_TentPack		= DefineItemType("Tent Pack",			"TentPack",			1279,	8,	0.0, 0.0, 0.0,			0.0,	0.106261, 0.004634, -0.144552, 246.614654, 345.892211, 258.267395, true);
	item_Campfire		= DefineItemType("Campfire",			"Campfire",			19475,	5,	0.0, 0.0, 0.0,			0.0,	0.106261, 0.004634, -0.144552, 246.614654, 345.892211, 258.267395, true);
	item_CowboyHat		= DefineItemType("Cowboy Hat",			"CowboyHat",		18962,	1,	0.0, 270.0, 0.0,		0.0427,	0.232999, 0.032000, 0.016000, 0.000000, 2.700027, -67.300010);
	item_TruckCap		= DefineItemType("Trucker Cap",			"TruckCap",			18961,	1,	0.0, 0.0, 0.0,			0.01,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954);
	item_BoaterHat		= DefineItemType("Boater Hat",			"BoaterHat",		18946,	1,	-12.18, 268.14, 0.0,	0.318,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954);
	item_BowlerHat		= DefineItemType("Bowler Hat",			"BowlerHat",		18947,	1,	-12.18, 268.14, 0.0,	0.01,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954);
//140
	item_PoliceCap		= DefineItemType("Police Cap",			"PoliceCap",		18636,	1,	0.0, 0.0, 0.0,			0.318,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954);
	item_TopHat			= DefineItemType("Top Hat",				"TopHat",			19352,	2,	0.0, 0.0, 0.0,			-0.023,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954);
	item_Ammo9mm		= DefineItemType("9mm Rounds",			"Ammo9mm",			2037,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo50			= DefineItemType(".50 Rounds",			"Ammo50",			2037,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_AmmoBuck		= DefineItemType("Shotgun Shells",		"AmmoBuck",			2038,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo556		= DefineItemType("5.56 Rounds",			"Ammo556",			2040,	3,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo357		= DefineItemType(".357 Rounds",			"Ammo357",			2039,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_AmmoRocket		= DefineItemType("Rockets",				"AmmoRocket",		3016,	4,	0.0, 0.0, 0.0,			0.0,	0.081998, 0.081005, -0.195033, 247.160079, 336.014343, 347.379638, true);
	item_MolotovEmpty	= DefineItemType("Empty Molotov",		"MolotovEmpty",		344,	1,	-4.0, 0.0, 0.0,			0.1728,	0.000000, -0.004999, 0.000000,  0.000000, 0.000000, 0.000000);
	item_Money			= DefineItemType("Pre-War Money",		"Money",			1212,	1,	0.0, 0.0, 0.0,			0.0,	0.133999, 0.022000, 0.018000,  -90.700004, -11.199998, -101.600013);
// 150
	item_PowerSupply	= DefineItemType("Power Supply",		"PowerSupply",		3016,	1,	0.0, 0.0, 0.0,			0.0,	0.255000, -0.054000, 0.032000, -87.499984, -7.599999, -7.999998);
	item_StorageUnit	= DefineItemType("Storage Unit",		"StorageUnit",		328,	1,	0.0, 0.0, 0.0,			0.0);
	item_Fluctuator		= DefineItemType("Fluctuator Unit",		"Fluctuator",		343,	1,	0.0, 0.0, 0.0,			0.0);
	item_IoUnit			= DefineItemType("I/O Unit",			"IoUnit",			19273,	1,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000);
	item_FluxCap		= DefineItemType("Flux Capacitor",		"FluxCap",			343,	1,	0.0, 0.0, 0.0,			0.0);
	item_DataInterface	= DefineItemType("Data Interface",		"DataInterface",	19273,	1,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000);
	item_HackDevice		= DefineItemType("Hack Interface",		"HackDevice",		364,	1,	0.0, 0.0, 0.0,			0.0,	0.134000, 0.080000, -0.037000,  84.299949, 3.399998, 9.400002);
	item_PlantPot		= DefineItemType("Plant Pot",			"PlantPot",			2203,	4,	0.0, 0.0, 0.0,			0.138,	-0.027872, 0.145617, -0.246524, 243.789840, 347.397491, 349.931610, true);
	item_HerpDerp		= DefineItemType("Derpification Unit",	"HerpDerp",			19513,	1,	0.0, 0.0, 0.0,			0.0,	0.103904, -0.003697, -0.015173, 94.655189, 184.031860, 0.000000);
	item_Parrot			= DefineItemType("Sebastian",			"Parrot",			19078,	2,	0.0, 0.0, 0.0,			0.0,	0.131000, 0.021000, 0.005999,  -86.000091, 6.700000, -106.300018);
// 160
	item_TntTripMine	= DefineItemType("Trip Mine TNT",		"TntTripMine",		1576,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000);
	item_IedTimebomb	= DefineItemType("Timed IED",			"IedTimebomb",		2033,	2,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891);
	item_IedProxMine	= DefineItemType("Proximity IED",		"IedProxMine",		2033,	2,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891);
	item_IedTripMine	= DefineItemType("Trip Mine IED",		"IedTripMine",		2033,	2,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891);
	item_IedPhoneBomb	= DefineItemType("Phone Remote IED",	"IedPhoneBomb",		2033,	2,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891);
	item_EmpTimebomb	= DefineItemType("Timed EMP",			"EmpTimebomb",		343,	2,	0.0, 0.0, 0.0,			0.0);
	item_EmpProxMine	= DefineItemType("Proximity EMP",		"EmpProxMine",		343,	2,	0.0, 0.0, 0.0,			0.0);
	item_EmpTripMine	= DefineItemType("Trip Mine EMP",		"EmpTripMine",		343,	2,	0.0, 0.0, 0.0,			0.0);
	item_EmpPhoneBomb	= DefineItemType("Phone Remote EMP",	"EmpPhoneBomb",		343,	2,	0.0, 0.0, 0.0,			0.0);
	item_Gyroscope		= DefineItemType("Gyroscope Unit",		"Gyroscope",		1945,	1,	0.0, 0.0, 0.0,			0.0,	0.180000, 0.085000, 0.009000,  -86.099967, -112.099975, 92.699890);
// 170
	item_Motor			= DefineItemType("Motor",				"Motor",			2006,	2,	0.0, 0.0, 0.0,			0.0,	0.129999, 0.087999, 0.009000,  -86.099967, -112.099975, 92.699890);
	item_StarterMotor	= DefineItemType("Starter Motor",		"StarterMotor",		2006,	2,	0.0, 0.0, 0.0,			0.0,	0.129999, 0.087999, 0.009000,  -86.099967, -112.099975, 92.699890);
	item_FlareGun		= DefineItemType("Flare Gun",			"FlareGun",			2034,	2,	0.0, 0.0, 0.0,			0.0,	0.176000, 0.020000, 0.039999,  89.199989, -0.900000, 1.099991);
	item_PetrolBomb		= DefineItemType("Petrol Bomb",			"PetrolBomb",		1650,	4,	0.0, 0.0, 0.0,			0.27,	0.143402, 0.027548, 0.063652, 0.000000, 253.648208, 0.000000);
	item_CodePart		= DefineItemType("Code",				"CodePart",			1898,	1,	90.0, 0.0, 0.0,			0.02,	0.086999, 0.017999, 0.075999,  0.000000, 0.000000, 100.700019);
	item_LargeBackpack	= DefineItemType("Large Backpack",		"LargeBackpack",	3026,	9,	270.0, 0.0, 90.0,		0.0,	0.470918, 0.150153, 0.055384, 181.319580, 7.513789, 163.436065, false, 0xFFF4A460);
	item_LocksmithKit	= DefineItemType("Locksmith Kit",		"LocksmithKit",		1210,	3,	0.0, 0.0, 90.0,			0.0,	0.285915, 0.078406, -0.009429, 0.000000, 270.000000, 0.000000, false, 0xFFF4A460);
	item_XmasHat		= DefineItemType("Christmas Hat",		"XmasHat",			19066,	1,	0.0, 0.0, 0.0,			0.0,	0.135000, -0.018001, -0.002000,  90.000000, 174.500061, 9.600001);
	item_VehicleWeapon	= DefineItemType("VEHICLE_WEAPON",		"VehicleWeapon",	356,	99,	90.0);
	item_AdvancedKeypad	= DefineItemType("Advanced Keypad",		"AdvancedKeypad",	19273,	2,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000);
// 180
	item_Ammo9mmFMJ		= DefineItemType("9mm Rounds",			"Ammo9mmFMJ",		2037,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_AmmoFlechette	= DefineItemType("Shotgun Shells",		"AmmoFlechette",	2038,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_AmmoHomeBuck	= DefineItemType("Shotgun Shells",		"AmmoHomeBuck",		2038,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo556Tracer	= DefineItemType("5.56 Rounds",			"Ammo556Tracer",	2040,	3,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo556HP		= DefineItemType("5.56 Rounds",			"Ammo556HP",		2040,	3,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo357Tracer	= DefineItemType(".357 Rounds",			"Ammo357Tracer",	2039,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo762		= DefineItemType("7.62 Rounds",			"Ammo762",			2040,	3,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_AK47Rifle		= DefineItemType("AK-47",				"AK47Rifle",		355,	8,	90.0);
	item_M77RMRifle		= DefineItemType("M77-RM",				"M77RMRifle",		357,	9,	90.0);
	item_DogsBreath		= DefineItemType("Dog's Breath",		"DogsBreath",		2034,	3,	0.0, 0.0, 0.0,			0.0,	0.176000, 0.020000, 0.039999,  89.199989, -0.900000, 1.099991);
// 190
	item_Ammo50BMG		= DefineItemType(".50 Rounds",			"Ammo50BMG",		2037,	1,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Ammo308		= DefineItemType(".308 Rounds",			"Ammo308",			2039,	1,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741);
	item_Model70Rifle	= DefineItemType("Model 70",			"Model70Rifle",		358,	9,	90.0);
	item_LenKnocksRifle	= DefineItemType("The Len-Knocks",		"LenKnocksRifle",	358,	10,	90.0);

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
	SetItemTypeMaxArrayData(item_WASR3Rifle,	4);
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
	SetItemTypeMaxArrayData(item_StunGun,		4);
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
	SetItemTypeMaxArrayData(item_LocksmithKit,	1);
	SetItemTypeMaxArrayData(item_XmasHat,		1);
	SetItemTypeMaxArrayData(item_VehicleWeapon,	4);
	SetItemTypeMaxArrayData(item_AdvancedKeypad,1);
	SetItemTypeMaxArrayData(item_Ammo9mmFMJ,	1);
	SetItemTypeMaxArrayData(item_AmmoFlechette,	1);
	SetItemTypeMaxArrayData(item_AmmoHomeBuck,	1);
	SetItemTypeMaxArrayData(item_Ammo556Tracer,	1);
	SetItemTypeMaxArrayData(item_Ammo556HP,		1);
	SetItemTypeMaxArrayData(item_Ammo357Tracer,	1);
	SetItemTypeMaxArrayData(item_Ammo762,		1);
	SetItemTypeMaxArrayData(item_AK47Rifle,		4);
	SetItemTypeMaxArrayData(item_M77RMRifle,	4);
	SetItemTypeMaxArrayData(item_DogsBreath,	4);
	SetItemTypeMaxArrayData(item_Ammo50BMG,		1);
	SetItemTypeMaxArrayData(item_Ammo308,		1);
	SetItemTypeMaxArrayData(item_Model70Rifle,	4);
	SetItemTypeMaxArrayData(item_LenKnocksRifle,4);

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
	calibre_9mm		= DefineAmmoCalibre("9mm",		0.015);
	calibre_50cae	= DefineAmmoCalibre(".50",		0.073);
	calibre_12g		= DefineAmmoCalibre("12 Gauge",	0.031);
	calibre_556		= DefineAmmoCalibre("5.56mm",	0.019);
	calibre_357		= DefineAmmoCalibre(".357",		0.036);
	calibre_762		= DefineAmmoCalibre("7.62",		0.032);
	calibre_rpg		= DefineAmmoCalibre("RPG",		0.0);
	calibre_fuel	= DefineAmmoCalibre("Fuel",		0.0);
	calibre_film	= DefineAmmoCalibre("Film",		0.0);
	calibre_50bmg	= DefineAmmoCalibre(".50",		0.073);
	calibre_308		= DefineAmmoCalibre(".308",		0.043);

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

		magsize - maximum amount of rounds in a magazine. This value must be
		below the max for that base weapon since client side weapon mag sizes
		can't be altered. Melee weapons use this field to store the knockout
		probability in floating point form.

		maxmags - total amount of reserve magazines held by the user.

		animset - currently only used by melee weapons, dictates the set of
		animations used for attacking with the weapon.
	*/

	//					itemtype				baseweapon					calibre			bleedrate		koprob	n/a		animset
	DefineItemTypeWeapon(item_Wrench,			0,							-1,				0.001,			_:1.20,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Crowbar,			0,							-1,				0.003,			_:1.25,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Hammer,			0,							-1,				0.002,			_:1.30,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Rake,				0,							-1,				0.018,			_:1.30,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Cane,				0,							-1,				0.008,			_:1.25,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_StunGun,			0,							-1,				0.0,			0,		0,		anim_Stab);
	DefineItemTypeWeapon(item_Screwdriver,		0,							-1,				0.024,			0,		0,		anim_Stab);
	DefineItemTypeWeapon(item_Mailbox,			0,							-1,				0.0,			_:1.40,	0,		anim_Heavy);
	//					itemtype				baseweapon					calibre			bleedrate		koprob	n/a		animset
	DefineItemTypeWeapon(item_Knuckles,			WEAPON_BRASSKNUCKLE,		-1,				0.005,			20,		0);
	DefineItemTypeWeapon(item_GolfClub,			WEAPON_GOLFCLUB,			-1,				0.007,			35,		0);
	DefineItemTypeWeapon(item_Baton,			WEAPON_NITESTICK,			-1,				0.003,			24,		0);
	DefineItemTypeWeapon(item_Knife,			WEAPON_KNIFE,				-1,				0.035,			14,		0);
	DefineItemTypeWeapon(item_Bat,				WEAPON_BAT,					-1,				0.009,			35,		0);
	DefineItemTypeWeapon(item_Spade,			WEAPON_SHOVEL,				-1,				0.021,			40,		0);
	DefineItemTypeWeapon(item_PoolCue,			WEAPON_POOLSTICK,			-1,				0.008,			37,		0);
	DefineItemTypeWeapon(item_Sword,			WEAPON_KATANA,				-1,				0.044,			15,		0);
	DefineItemTypeWeapon(item_Chainsaw,			WEAPON_CHAINSAW,			-1,				0.093,			19,		0);
	DefineItemTypeWeapon(item_Dildo1,			WEAPON_DILDO,				-1,				0.001,			0,		0);
	DefineItemTypeWeapon(item_Dildo2,			WEAPON_DILDO2,				-1,				0.001,			0,		0);
	DefineItemTypeWeapon(item_Dildo3,			WEAPON_VIBRATOR,			-1,				0.001,			0,		0);
	DefineItemTypeWeapon(item_Dildo4,			WEAPON_VIBRATOR2,			-1,				0.001,			0,		0);
	DefineItemTypeWeapon(item_Flowers,			WEAPON_FLOWER,				-1,				0.001,			0,		0);
	DefineItemTypeWeapon(item_WalkingCane,		WEAPON_CANE,				-1,				0.006,			24,		0);
	DefineItemTypeWeapon(item_Grenade,			WEAPON_GRENADE,				-1,				0.0,			0,		0);
	DefineItemTypeWeapon(item_Teargas,			WEAPON_TEARGAS,				-1,				0.0,			0,		0);
	DefineItemTypeWeapon(item_Molotov,			WEAPON_MOLTOV,				-1,				0.0,			0,		0);
	//					itemtype				baseweapon					calibre			muzzvelocity	magsize	maxmags		animset
	DefineItemTypeWeapon(item_M9Pistol,			WEAPON_COLT45,				calibre_9mm,	300.0,			10,		1);
	DefineItemTypeWeapon(item_M9PistolSD,		WEAPON_SILENCED,			calibre_9mm,	250.0,			10,		1);
	DefineItemTypeWeapon(item_DesertEagle,		WEAPON_DEAGLE,				calibre_357,	420.0,			7,		2);
	DefineItemTypeWeapon(item_PumpShotgun,		WEAPON_SHOTGUN,				calibre_12g,	475.0,			6,		1);
	DefineItemTypeWeapon(item_Sawnoff,			WEAPON_SAWEDOFF,			calibre_12g,	265.0,			2,		6);
	DefineItemTypeWeapon(item_Spas12,			WEAPON_SHOTGSPA,			calibre_12g,	480.0,			6,		1);
	DefineItemTypeWeapon(item_Mac10,			WEAPON_UZI,					calibre_9mm,	376.0,			32,		1);
	DefineItemTypeWeapon(item_MP5,				WEAPON_MP5,					calibre_9mm,	400.0,			30,		1);
	DefineItemTypeWeapon(item_WASR3Rifle,		WEAPON_AK47,				calibre_556,	943.0,			30,		1);
	DefineItemTypeWeapon(item_M16Rifle,			WEAPON_M4,					calibre_556,	948.0,			30,		1);
	DefineItemTypeWeapon(item_Tec9,				WEAPON_TEC9,				calibre_9mm,	360.0,			36,		1);
	DefineItemTypeWeapon(item_SemiAutoRifle,	WEAPON_RIFLE,				calibre_357,	829.0,			5,		1);
	DefineItemTypeWeapon(item_SniperRifle,		WEAPON_SNIPER,				calibre_357,	864.0,			5,		1);
	DefineItemTypeWeapon(item_RocketLauncher,	WEAPON_ROCKETLAUNCHER,		calibre_rpg,	0.0,			1,		0);
	DefineItemTypeWeapon(item_Heatseeker,		WEAPON_HEATSEEKER,			calibre_rpg,	0.0,			1,		0);
	DefineItemTypeWeapon(item_Flamer,			WEAPON_FLAMETHROWER,		calibre_fuel,	0.0,			100,	1);
	DefineItemTypeWeapon(item_Minigun,			WEAPON_MINIGUN,				calibre_556,	853.0,			100,	1);
	DefineItemTypeWeapon(item_RemoteBomb,		WEAPON_SATCHEL,				-1,				0.0,			1,		1);
	DefineItemTypeWeapon(item_Detonator,		WEAPON_BOMB,				-1,				0.0,			1,		1);
	DefineItemTypeWeapon(item_SprayPaint,		WEAPON_SPRAYCAN,			-1,				0.0,			100,	0);
	DefineItemTypeWeapon(item_Extinguisher,		WEAPON_FIREEXTINGUISHER,	-1,				0.0,			100,	0);
	DefineItemTypeWeapon(item_Camera,			WEAPON_CAMERA,				calibre_film,	1337.0,			24,		4);
	DefineItemTypeWeapon(item_VehicleWeapon,	WEAPON_M4,					calibre_556,	750.0,			0,		1);
	DefineItemTypeWeapon(item_AK47Rifle,		WEAPON_AK47,				calibre_762,	715.0,			30,		1);
	DefineItemTypeWeapon(item_M77RMRifle,		WEAPON_RIFLE,				calibre_357,	823.0,			1,		9);
	DefineItemTypeWeapon(item_DogsBreath,		WEAPON_DEAGLE,				calibre_50bmg,	1398.6,			1,		9);
	DefineItemTypeWeapon(item_Model70Rifle,		WEAPON_SNIPER,				calibre_308,	860.6,			1,		9);
	DefineItemTypeWeapon(item_LenKnocksRifle,	WEAPON_SNIPER,				calibre_50bmg,	938.5,			1,		4);

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
	DefineItemTypeAmmo(item_Ammo50,				"Action Express",	calibre_50cae,	1.0,	1.5,	0.9,	28);
	DefineItemTypeAmmo(item_AmmoBuck,			"No. 1",			calibre_12g,	1.1,	1.8,	0.5,	24);
	DefineItemTypeAmmo(item_Ammo556,			"FMJ",				calibre_556,	1.1,	1.2,	0.8,	30);
	DefineItemTypeAmmo(item_Ammo357,			"FMJ",				calibre_357,	1.2,	1.1,	0.9,	10);
	DefineItemTypeAmmo(item_AmmoRocket,			"RPG",				calibre_rpg,	1.0,	1.0,	2.0,	1);
	DefineItemTypeAmmo(item_GasCan,				"Petrol",			calibre_fuel,	0.0,	0.0,	0.0,	20);
	DefineItemTypeAmmo(item_Ammo9mmFMJ,			"FMJ",				calibre_9mm,	1.2,	0.5,	0.8,	20);
	DefineItemTypeAmmo(item_AmmoFlechette,		"Flechette",		calibre_12g,	1.6,	0.6,	0.2,	8);
	DefineItemTypeAmmo(item_AmmoHomeBuck,		"Improvised",		calibre_12g,	1.6,	0.4,	0.3,	14);
	DefineItemTypeAmmo(item_Ammo556Tracer,		"Tracer",			calibre_556,	0.9,	1.1,	0.5,	30);
	DefineItemTypeAmmo(item_Ammo556HP,			"Hollow Point",		calibre_556,	1.3,	1.6,	0.4,	30);
	DefineItemTypeAmmo(item_Ammo357Tracer,		"Tracer",			calibre_357,	0.9,	1.1,	0.6,	10);
	DefineItemTypeAmmo(item_Ammo762,			"FMJ",				calibre_762,	1.3,	1.1,	0.9,	30);
	DefineItemTypeAmmo(item_Ammo50BMG,			"BMG",				calibre_50bmg,	2.0,	2.0,	1.0,	16);
	DefineItemTypeAmmo(item_Ammo308,			"FMJ",				calibre_308,	1.2,	1.1,	0.8,	10);


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
	SetItemTypeHolsterable(item_WASR3Rifle,		1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_M16Rifle,		1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Tec9,			8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_SemiAutoRifle,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_SniperRifle,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_RocketLauncher,	1, 0.181966, -0.238397, -0.094830, 252.7912, 353.8938, 357.5294, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Heatseeker,		1, 0.181966, -0.238397, -0.094830, 252.7912, 353.8938, 357.5294, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_AK47Rifle,		1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_M77RMRifle,		1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_DogsBreath,		8, 0.176000, -0.005000, 0.062999, -14.499991, -0.900000, 1.099991, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_StunGun,		8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_Shield,			1, 0.027000, -0.039999, 0.170000, 270.0000, -171.0000, 90.0000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Mailbox,		1, 0.457000, -0.094999, -0.465000,  2.099999, -42.600, -94.500, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_DogsBreath,		8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 500,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_Model70Rifle,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_LenKnocksRifle,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");


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


	DefineItemCombo(item_Knife,			item_Parachute,		item_ParaBag,		.returnitem1 = 0, .returnitem2 = 1);
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
	DefineItemCombo(item_Knife,			item_Clothes,		item_Bandage,		.returnitem1 = 0, .returnitem2 = 1);
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

	DefineSafeboxType("Medium Box",		item_MediumBox,		8, 6, 3, 2);
	DefineSafeboxType("Small Box",		item_SmallBox,		6, 2, 1, 0);
	DefineSafeboxType("Large Box",		item_LargeBox,		12, 8, 6, 6);
	DefineSafeboxType("Capsule",		item_Capsule,		2, 2, 0, 0);

	DefineBagType("Backpack",			item_Backpack,		10, 4, 1, 0, -0.110900, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Small Bag",			item_Satchel,		5, 2, 1, 0, 0.241894, -0.160918, 0.181463, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Parachute Bag",		item_ParaBag,		8, 4, 2, 0, 0.039470, -0.088898, -0.009887, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Large Backpack",		item_LargeBackpack,	12, 5, 2, 0, -0.2209, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.2000000, 1.300000, 1.100000);


	for(new i; i < MAX_PLAYERS; i++)
	{
		ResetVariables(i); // Todo: move to player module or just remove
	}

	defer AutoSave(); // Todo: move to autosave module
	defer InfoMessage(); // Todo: move to info message module

	return 1;
}
