#define MAX_AMMO_TYPE		(7)
#define MAX_AMMO_TYPE_NAME	(9)


enum
{
	AMMO_TYPE_NONE,
	AMMO_TYPE_9MM,
	AMMO_TYPE_50,
	AMMO_TYPE_BUCK,
	AMMO_TYPE_556,
	AMMO_TYPE_308,
	AMMO_TYPE_ROCKET
}

new AmmoTypeName[MAX_AMMO_TYPE][MAX_AMMO_TYPE_NAME]=
{
	"None",
	"9mm",		// 2037
	".50",		// 2037
	"Buckshot",	// 2038
	"5.56",		// 2040
	".338",		// 2039
	"Rocket"	// 2061
};

stock GetAmmoTypeName(ammotype, name[])
{
	if(!(0 <= ammotype < MAX_AMMO_TYPE))
		return 0;

	name[0] = EOS;
	strcat(name, AmmoTypeName[ammotype], MAX_AMMO_TYPE_NAME);

	return 1;
}


enum E_WEAPON_DATA_EXTRA
{
	weapon_ammoType,
	weapon_ammoMax
}

new WeaponAmmoData[MAX_WEAPONS][E_WEAPON_DATA_EXTRA]=
{
	{AMMO_TYPE_NONE,	1},		// Fist				// 0
	{AMMO_TYPE_NONE,	1},		// Knuckle Duster	// 1
	{AMMO_TYPE_NONE,	1},		// Golf Club		// 2
	{AMMO_TYPE_NONE,	1},		// Baton 			// 3
	{AMMO_TYPE_NONE,	1},		// Knife			// 4
	{AMMO_TYPE_NONE,	1},		// Baseball Bat		// 5
	{AMMO_TYPE_NONE,	1},		// Spade			// 6
	{AMMO_TYPE_NONE,	1},		// Pool Cue			// 7
	{AMMO_TYPE_NONE,	1},		// Sword			// 8
	{AMMO_TYPE_NONE,	1},		// Chainsaw			// 9

	{AMMO_TYPE_NONE,	1},		// Dildo			// 10
	{AMMO_TYPE_NONE,	1},		// Dildo			// 11
	{AMMO_TYPE_NONE,	1},		// Dildo			// 12
	{AMMO_TYPE_NONE,	1},		// Dildo			// 13
	{AMMO_TYPE_NONE,	1},		// Flowers			// 14
	{AMMO_TYPE_NONE,	1},		// Cane				// 15

	{AMMO_TYPE_NONE,	1},		// Grenade			// 16
	{AMMO_TYPE_NONE,	1},		// Teargas			// 17
	{AMMO_TYPE_NONE,	1},		// Molotov			// 18

	{AMMO_TYPE_NONE,	0},		// <null>			// 19
	{AMMO_TYPE_NONE,	0},		// <null>			// 20
	{AMMO_TYPE_NONE,	0},		// <null>			// 21

	{AMMO_TYPE_9MM,		10},	// M9				// 22
	{AMMO_TYPE_9MM,		10},	// M9 SD			// 23
	{AMMO_TYPE_50,		10},	// Desert Eagle		// 24

	{AMMO_TYPE_BUCK,	12},	// Shotgun			// 25
	{AMMO_TYPE_BUCK,	12},	// Sawnoff			// 26
	{AMMO_TYPE_BUCK,	12},	// Spas 12			// 27

	{AMMO_TYPE_9MM,		6},		// Mac 10			// 28
	{AMMO_TYPE_9MM,		8},		// MP5				// 29
	{AMMO_TYPE_556,		8},		// AK-47			// 30
	{AMMO_TYPE_556,		6},		// M4-A1			// 31
	{AMMO_TYPE_9MM,		8},		// Tec 9			// 32

	{AMMO_TYPE_308,		14},	// Rifle			// 33
	{AMMO_TYPE_308,		14},	// Sniper			// 34

	{AMMO_TYPE_ROCKET,	0},		// RPG-7			// 35
	{AMMO_TYPE_ROCKET,	0},		// Heatseek			// 36
	{AMMO_TYPE_NONE,	4},		// Flamer			// 37
	{AMMO_TYPE_556,		2},		// Chaingun			// 38

	{AMMO_TYPE_NONE,	1},		// {"C4				// 39
	{AMMO_TYPE_NONE,	1},		// {"Detonator		// 40
	{AMMO_TYPE_NONE,	0},		// {"Spray Paint	// 41
	{AMMO_TYPE_NONE,	0},		// {"Extinguisher	// 42
	{AMMO_TYPE_NONE,	4},		// {"Camera			// 43
	{AMMO_TYPE_NONE,	1},		// {"Night Vision	// 44
	{AMMO_TYPE_NONE,	1},		// {"Thermal Vision	// 45
	{AMMO_TYPE_NONE,	1},		// {"Parachute		// 46

	{AMMO_TYPE_NONE,	1},		// {"Vehicle Gun	// 47
	{AMMO_TYPE_NONE,	1},		// {"Vehicle Bomb	// 48
	{AMMO_TYPE_NONE,	1}		// {"Vehicle		// 49
};

stock GetWeaponAmmoType(weaponid)
{
	if(!(0 < weaponid < MAX_WEAPONS))
		return AMMO_TYPE_NONE;

	return WeaponAmmoData[weaponid][weapon_ammoType];
}

stock ItemType:GetWeaponAmmoTypeItem(weaponid)
{
	if(!(0 < weaponid < MAX_WEAPONS))
		return INVALID_ITEM_TYPE;

	switch(WeaponAmmoData[weaponid][weapon_ammoType])
	{
		case AMMO_TYPE_9MM:
			return item_Ammo9mm;

		case AMMO_TYPE_50:
			return item_Ammo50;

		case AMMO_TYPE_BUCK:
			return item_AmmoBuck;

		case AMMO_TYPE_556:
			return item_Ammo556;

		case AMMO_TYPE_308:
			return item_Ammo338;

		case AMMO_TYPE_ROCKET:
			return item_AmmoRocket;
	}
	return INVALID_ITEM_TYPE;
}

stock GetWeaponAmmoMax(weaponid)
{
	if(!(0 < weaponid < MAX_WEAPONS))
		return 0;

	return WeaponAmmoData[weaponid][weapon_ammoMax];
}
