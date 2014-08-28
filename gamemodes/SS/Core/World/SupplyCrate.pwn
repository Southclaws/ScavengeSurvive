#include <YSI\y_hooks>


#define MAX_SUPPLY_DROP_LOCATIONS		(38)
#define MAX_SUPPLY_DROP_LOCATION_NAME	(32)
#define SUPPLY_CRATE_DROP_HEIGHT		(800.0)
#define SUPPLY_CRATE_INTERVAL			(3600000 + random(1800000)) // somewhere between 1 hour and 1 hour 30 minutes


enum E_SUPPLY_DROP_LOCATION_DATA
{
			sup_name[MAX_SUPPLY_DROP_LOCATION_NAME],
Float:		sup_posX,
Float:		sup_posY,
Float:		sup_posZ,
bool:		sup_used
}

static
Float:		sup_DropLocationData[MAX_SUPPLY_DROP_LOCATIONS][E_SUPPLY_DROP_LOCATION_DATA],
Iterator:	sup_Index<MAX_SUPPLY_DROP_LOCATIONS>,
			sup_TotalLocations,

			sup_ObjCrate1 = INVALID_OBJECT_ID,
			sup_ObjCrate2 = INVALID_OBJECT_ID,
			sup_ObjPara = INVALID_OBJECT_ID,
Float:		sup_DropX,
Float:		sup_DropY,
Float:		sup_DropZ;


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'SupplyCrate'...");

	defer SupplyDropTimer();
	return 1;
}

DefineSupplyDropPos(name[MAX_SUPPLY_DROP_LOCATION_NAME], Float:x, Float:y, Float:z)
{
	new id = Iter_Free(sup_Index);

	if(id == -1)
	{
		printf("ERROR: Supply drop pos definition limit reached.");
		return -1;
	}

	sup_DropLocationData[id][sup_name] = name;
	sup_DropLocationData[id][sup_posX] = x;
	sup_DropLocationData[id][sup_posY] = y;
	sup_DropLocationData[id][sup_posZ] = z;

	Iter_Add(sup_Index, id);
	sup_TotalLocations++;

	return id;
}

timer SupplyDropTimer[SUPPLY_CRATE_INTERVAL]()
{
	if(Iter_Count(Player) < 3)
		return;

	if(Iter_Count(sup_Index) == 0)
	{
		printf("ERROR: Supply drops run out, stopping supply drop timer.");
		return;
	}

	new id = Iter_Random(sup_Index);

	SupplyCrateDrop(sup_DropLocationData[id][sup_posX], sup_DropLocationData[id][sup_posY], sup_DropLocationData[id][sup_posZ]);
	MsgAllF(YELLOW, " >  [EBS]: SUPPLY DROP INCOMING AT id: "C_BLUE"'%s'", sup_DropLocationData[id][sup_name]);

	Iter_Remove(sup_Index, id);

	defer SupplyDropTimer();

	return;
}

SupplyCrateDrop(Float:x, Float:y, Float:z)
{
	sup_ObjCrate1 = CreateDynamicObject(3799, x, y, SUPPLY_CRATE_DROP_HEIGHT, 0.0, 0.0, 0.0, .streamdistance = 10000),
	sup_ObjCrate2 = CreateDynamicObject(3799, x + 0.01, y + 0.01, SUPPLY_CRATE_DROP_HEIGHT + 2.4650, 0.0, 180.0, 0.0, .streamdistance = 10000),
	sup_ObjPara = CreateDynamicObject(18849, x, y, SUPPLY_CRATE_DROP_HEIGHT + 8.0, 0.0, 0.0, 0.0, .streamdistance = 10000),

	MoveDynamicObject(sup_ObjCrate1, x, y, z, 10.0, 0.0, 0.0, 720.0);
	MoveDynamicObject(sup_ObjCrate2, x + 0.01, y + 0.01, z + 2.4650, 10.0, 0.0, 180.0, 720.0);
	MoveDynamicObject(sup_ObjPara, x, y, z - 10.0, 10.0, 0.0, 0.0, 720.0);

	sup_DropX = x;
	sup_DropY = y;
	sup_DropZ = z;
}

SupplyCrateLand()
{
	FillContainerWithLoot(
		CreateContainer("Supply Crate", 16, sup_DropX + 1.5, sup_DropY, sup_DropZ + 1.0),
		8 + random(9), loot_SupplyCrate);

	DestroyDynamicObject(sup_ObjPara);
	sup_ObjCrate1 = INVALID_OBJECT_ID;
	sup_ObjCrate2 = INVALID_OBJECT_ID;
	sup_ObjPara = INVALID_OBJECT_ID;
}

public OnDynamicObjectMoved(objectid)
{
	if(objectid == sup_ObjPara)
		SupplyCrateLand();

	#if defined sup_OnDynamicObjectMoved
		return sup_OnDynamicObjectMoved(objectid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnDynamicObjectMoved
	#undef OnDynamicObjectMoved
#else
	#define _ALS_OnDynamicObjectMoved
#endif
#define OnDynamicObjectMoved sup_OnDynamicObjectMoved
#if defined sup_OnDynamicObjectMoved
	forward sup_OnDynamicObjectMoved(objectid);
#endif

ACMD:sc[4](playerid, params[])
{
	new
		Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	SupplyCrateDrop(x, y, z);

	return 1;
}


// Interface


stock GetSupplyDropLocationName(location, name[MAX_SUPPLY_DROP_LOCATION_NAME])
{
	if(location >= sup_TotalLocations)
		return 0;

	name[0] = EOS;
	strcat(name, sup_DropLocationData[location][sup_name]);

	return 1;
}

stock GetSupplyDropLocationPos(location, &Float:x, &Float:y, &Float:z)
{
	if(location >= sup_TotalLocations)
		return 0;

	x = sup_DropLocationData[location][sup_posX];
	y = sup_DropLocationData[location][sup_posY];
	z = sup_DropLocationData[location][sup_posZ];

	return 1;
}

stock IsSupplyDropLocationUsed(location)
{
	if(location >= sup_TotalLocations)
		return 0;

	return sup_DropLocationData[location][sup_used];
}

stock GetTotalSupplyDropLocations()
{
	return sup_TotalLocations;
}
