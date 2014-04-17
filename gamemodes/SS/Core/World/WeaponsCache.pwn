#include <YSI\y_hooks>


#define MAX_WEPCACHE_LOCATIONS			(256)
#define WEPCACHE_INTERVAL				(1500000 + random(600000)) // 25 minutes + random 10 minutes
#define WEPCACHE_SIGNAL_INTERVAL		(200000)


enum E_WEPCACHE_LOCATION_DATA
{
Float:	wepc_posX,
Float:	wepc_posY,
Float:	wepc_posZ
}

static
Float:		wepc_DropLocationData[MAX_WEPCACHE_LOCATIONS][E_WEPCACHE_LOCATION_DATA],
Iterator:	wepc_Index<MAX_WEPCACHE_LOCATIONS>,
			webc_ActiveDrop = -1;


hook OnGameModeInit()
{
	defer WeaponsCacheTimer();
	return 1;
}

DefineWeaponsCachePos(Float:x, Float:y, Float:z)
{
	new id = Iter_Free(wepc_Index);

	if(id == -1)
	{
		printf("ERROR: Weapons cache pos definition limit reached.");
		return -1;
	}

	wepc_DropLocationData[id][wepc_posX] = x;
	wepc_DropLocationData[id][wepc_posY] = y;
	wepc_DropLocationData[id][wepc_posZ] = z;

	Iter_Add(wepc_Index, id);

	return id;
}

timer WeaponsCacheTimer[WEPCACHE_INTERVAL]()
{
	if(Iter_Count(Player) < 4)
		return;

	// There are no more locations available, kill the timer.
	if(Iter_Count(wepc_Index) == 0)
	{
		printf("ERROR: Weapons caches run out, stopping weapons cache timer.");
		return;
	}

	// Pick a location without any players nearby
	new
		id = Iter_Random(wepc_Index),
		checked;

	while(GetPlayersNearDropLocation(id) > 0)
	{
		if(checked == Iter_Count(wepc_Index))
		{
			checked = -1;
			break;
		}

		id = Iter_Random(wepc_Index);
		checked++;
	}

	if(checked > -1)
	{
		WeaponsCacheDrop(wepc_DropLocationData[id][wepc_posX], wepc_DropLocationData[id][wepc_posY], wepc_DropLocationData[id][wepc_posZ]);

		Iter_Remove(wepc_Index, id);

		webc_ActiveDrop = id;
	}

	defer WeaponsCacheTimer();

	return;
}

GetPlayersNearDropLocation(id)
{
	new count;

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, 500.0, wepc_DropLocationData[id][wepc_posX], wepc_DropLocationData[id][wepc_posY], wepc_DropLocationData[id][wepc_posZ]))
			count++;
	}

	return count;
}

WeaponsCacheDrop(Float:x, Float:y, Float:z)
{
	if(webc_ActiveDrop != -1)
		return 0;

	CreateDynamicObject(964, x, y, z - 0.0440, 0.0, 0.0, 0.0, .streamdistance = 1000.0, .drawdistance = 1000.0);

	FillContainerWithLoot(
		CreateContainer("Supply Crate", 8, x, y - 0.5, z + 1.0),
		4 + random(5), loot_Military);

	defer WeaponsCacheSignal(1, x, y, z);

	return 1;
}

timer WeaponsCacheSignal[WEPCACHE_SIGNAL_INTERVAL](count, Float:x, Float:y, Float:z)
{
	// Gets a random supply drop location and uses it as a reference point.
	// Announces the angle and distance from that location to the weapons cache.
	new
		location = random(GetTotalSupplyDropLocations()),
		name[MAX_SUPPLY_DROP_LOCATION_NAME],
		Float:ref_x,
		Float:ref_y,
		Float:ref_z,
		Float:angleto,
		Float:distanceto;

	GetSupplyDropLocationName(location, name);
	GetSupplyDropLocationPos(location, ref_x, ref_y, ref_z);

	angleto = absoluteangle(360 - GetAngleToPoint(ref_x, ref_y, x, y));
	distanceto = Distance2D(ref_x, ref_y, x, y);

	MsgAllF(YELLOW, " >  [EBS]: WEAPONS CACHE SIGNAL: BEARING: %.1fDEG DISTANCE: %.1fM FROM: '%s'", angleto, distanceto, name);

	if(count < 3)
	{
		defer WeaponsCacheSignal(count + 1, x, y, z);
		webc_ActiveDrop = -1;
	}
}

ACMD:wc[4](playerid, params[])
{
	new
		Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	WeaponsCacheDrop(x, y, z);

	return 1;
}
