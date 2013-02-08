#define MAX_WEAPONS (50)

enum
{
	WEAPON_UNARMED,
	WEAPON_KNUCKLES,
	WEAPON_GOLFCLUB,
	WEAPON_NITESTICK,
	WEAPON_KNIFE,
	WEAPON_BASEBALLBAT,
	WEAPON_SHOVEL,
	WEAPON_POOLCUE,
	WEAPON_KANTANA,
	WEAPON_CHAINSAW,
	WEAPON_DILDO1,
	WEAPON_DILDO2,
	WEAPON_DILDO3,
	WEAPON_DILDO4,
	WEAPON_FLOWERS,
	WEAPON_CANE,
	WEAPON_GRENADES,
	WEAPON_TEARGAS,
	WEAPON_MOLOTOV,
	WEAPON_NULL1,
	WEAPON_NULL2,
	WEAPON_NULL3,
	WEAPON_COLT45,
	WEAPON_COLT45SD,
	WEAPON_DESERTEAGLE,
	WEAPON_SHOTGUN,
	WEAPON_SAWNOFF,
	WEAPON_SPAS12,
	WEAPON_MAC10,
	WEAPON_MP5,
	WEAPON_AK47,
	WEAPON_M4,
	WEAPON_TEC9,
	WEAPON_RIFLE,
	WEAPON_SNIPER,
	WEAPON_ROCKETLAUNCHER,
	WEAPON_HEATSEEKER,
	WEAPON_FLAMER,
	WEAPON_MINIGUN,
	WEAPON_SACHEL,
	WEAPON_DETONATOR,
	WEAPON_SPRAYCAN,
	WEAPON_EXTINGUISHER,
	WEAPON_CAMERA,
	WEAPON_NIGHTVISION,
	WEAPON_THERMALVISION,
	WEAPON_PARACHUTE,

	WEAPON_VEHICLE_BULLET,
	WEAPON_VEHICLE_EXPLOSIVE,
	WEAPON_VEHICLE_COLLISION
}
enum WepEnum
{
	WepName[30],        // A
	WepModel,           // B
	MagSize,            // C
	GtaSlot,            // D
	Float:MinDam,       // E
	Float:MaxDam,       // F
	Float:MinDis,       // G
	Float:MaxDis,       // H
	Float:FireRate,     // I
	Float:MaxRange      // J
}
stock const WepData[MAX_WEAPONS][WepEnum]=
{
//  A                   B    C      D   E       F       G    H      I       J
	{"Fist",			000, 1, 	0,	1.5,	5.0,	0.0, 2.0,	0.0,	1.6}, 		// 0
	{"Knuckle Duster",	331, 1, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 1
	{"Golf Club",		333, 1, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 2
	{"Baton", 			334, 1, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 3
	{"Knife",			335, 1, 	1,	20.0,	26.0,	0.0, 1.6,	0.0,	1.6}, 		// 4
	{"Baseball Bat",	336, 1, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 5
	{"Spade",			337, 1, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 6
	{"Pool Cue",		338, 1,		1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 7
	{"Sword",			339, 1, 	1,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 8
	{"Chainsaw",		341, 1,		1,	24.5,	30.0,	0.0, 2.0,	0.0,	1.6}, 		// 9

//  A                   B    C      D   E       F       G    H      I       J
	{"Dildo",			321, 1, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 10
	{"Dildo",			322, 1, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 11
	{"Dildo",			323, 1, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 12
	{"Dildo",			324, 1, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 13
	{"Flowers",			325, 1, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 14
	{"Cane",			326, 1, 	10,	0.5,	1.0,	0.0, 2.0,	0.0,	1.6}, 		// 15

//  A                   B    C      D   E       F       G    H      I       J
	{"Grenade",			342, 1, 	8,	50.0,	100.0,	0.0, 2.0,	0.0,	40.0}, 		// 16
	{"Teargas",			343, 1, 	8,	0.0,	0.0,	0.0, 2.0,	0.0,	40.0}, 		// 17
	{"Molotov",			344, 1, 	8,	1.0,	5.0,	0.0, 2.0,	0.0,	40.0}, 		// 18

	{"<null>",			000, 0, 	0,	0.0,	0.0,	0.0, 2.0,	0.0,	0.0}, 		// 19
	{"<null>",			000, 0, 	0,	0.0,	0.0,	0.0, 2.0,	0.0,	0.0}, 		// 20
	{"<null>",			000, 0, 	0,	0.0,	0.0,	0.0, 2.0,	0.0,	0.0}, 		// 21

//  A                   B    C      D   E       F       G    H      I       J
	{"M9",				346, 17,	2,	15.0,	24.0,	10.0, 30.0,	164.83,	35.0},		// 22
	{"M9 SD",			347, 17,	2,	15.0,	24.0,	10.0, 30.0,	166.61,	35.0},		// 23
	{"Desert Eagle",	348, 7,		2,	20.0,	28.0,	12.0, 35.0,	82.54,	35.0},		// 24

//  A                   B    C      D   E       F       G    H      I       J
	{"Shotgun",			349, 6,		3,	15.0,	36.0,	11.0, 35.0,	56.40,	40.0},		// 25
	{"Sawnoff",			350, 2,		3,	5.0,	60.0,	5.0, 24.0,	196.07,	35.0},		// 26
	{"Spas 12",			351, 7,		3,	16.0,	35.0,	14.0, 40.0,	179.10,	40.0},		// 27

//  A                   B    C      D   E       F       G    H      I       J
	{"Mac 10",			352, 100,	4,	12.0,	20.0,	10.0, 35.0,	461.26,	35.0},		// 28
	{"MP5",				353, 30,	4,	12.0,	24.0,	9.0, 38.0,	554.98,	45.0},		// 29
	{"AK-47",			355, 30,	5,	20.0,	26.0,	11.0, 39.0,	474.47,	70.0},		// 30
	{"M4-A1",			356, 50,	5,	24.0,	30.0,	13.0, 46.0,	490.59,	90.0},		// 31
	{"Tec 9",			372, 100,	4,	10.0,	24.0,	10.0, 25.0,	447.48,	35.0},		// 32

//  A                   B    C      D   E       F       G    H      I       J
	{"Rifle",			357, 5,		6,	60.0,	70.0,	30.0, 100.0,55.83,	100.0},		// 33
	{"Sniper",			358, 5,		6,	60.0,	80.0,	30.0, 100.0,55.67,	100.0},		// 34

//  A                   B    C      D   E       F       G    H      I       J
	{"RPG-7",			359, 1,		7,	50.0,	100.0,	1.0, 30.0,	0.0,	55.0},		// 35
	{"Heatseek",		360, 1,		7,	50.0,	100.0,	1.0, 30.0,	0.0,	55.0},		// 36
	{"Flamer",			361, 100,	7,	1.1,	10.0,	1.0, 5.0,	2974.95,5.1},		// 37
	{"Chaingun",		362, 500,	7,	1.1,	10.0,	1.0, 60.0,	2571.42,75.0},		// 38

//  A                   B    C      D   E       F       G    H      I       J
	{"C4",				363, 1,		8,	5.0,	20.0,	10.0, 50.0,	0.0,	40.0},		// 39
	{"Detonator",		364, 1,		12,	0.0,	0.0,	0.0, 0.0,	0.0,	25.0},		// 40
	{"Spray Paint",		365, 500,	9,	0.0,	0.1,	0.0, 2.0,	0.0,	6.1},		// 41
	{"Extinguisher",	366, 500,	9,	0.0,	0.0,	0.0, 2.0,	0.0,	10.1},		// 42
	{"Camera",			367, 36,	9,	0.0,	0.0,	0.0, 0.0,	0.0,	100.0},		// 43
	{"Night Vision",	000, 1,		11,	0.0,	0.0,	0.0, 0.0,	0.0,	100.0},		// 44
	{"Thermal Vision",	000, 1,		11,	0.0,	0.0,	0.0, 0.0,	0.0,	100.0},		// 45
	{"Parachute",		371, 1,		11,	0.0,	0.0,	0.0, 0.0,	0.0,	50.0},		// 46
	{"Vehicle Gun",		000, 0,		0,	3.0,	7.0,	0.0, 50.0,	0.0,	50.0},		// 47
	{"Vehicle Bomb",	000, 0,		0,	50.0,	50.0,	0.0, 50.0,	0.0,	50.0},		// 48
	{"Vehicle",			000, 0,		0,	20.0,	30.0,	0.0, 10.0,	0.0,	25.0}		// 49
};





































































































new stock wOffset[40]=
{
	0,	// Unarmed,
	-1,	// Knuckles,
	-1,	// Golfclub,
	-1,	// Nitestick,
	1,	// Knife,
	-1,	// Baseballbat,
	-1,	// Shovel,
	-1,	// Poolcue,
	-1,	// Kantana,
	-1,	// Chainsaw,
	-1,	// dildo1,
	-1,	// dildo2,
	-1,	// dildo3,
	-1,	// dildo4,
	-1,	// Flowers,
	-1,	// Cane,
	-1,	// Grenades,
	-1,	// Teargas,
	-1,	// Molotov,
	-1,
	-1,
	-1,
	2,	// colt45,
	3,	// colt45sd,
	4,	// Deserteagle,
	5,	// Shotgun,
	6,	// Sawnoff,
	7,	// Spas12,
	8,	// Mac10,
	9,	// Mp5,
	10,	// Ak47,
	11,	// M4,
	12,	// Tec9,
	13,	// Countryrifle,
	14,	// Sniperrifle,
	15,	// Rpg,
	-1, // Heatseeker
	16,	// Flamer,
	17,	// Minigun,
	18 // Mine
};
