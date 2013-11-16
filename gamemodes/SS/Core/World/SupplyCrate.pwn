#include <YSI\y_hooks>


#define MAX_SUPPLY_DROP_LOCATIONS		(38)
#define MAX_SUPPLY_DROP_LOCATION_NAME	(32)
#define SUPPLY_CRATE_DROP_HEIGHT		(800.0)
#define SUPPLY_CRATE_INTERVAL			(3600000 + random(1800000)) // somewhere between 1 hour and 1 hour 30 minutes


enum E_SUPPLY_DROP_LOCATION_DATA
{
		sup_name[MAX_SUPPLY_DROP_LOCATION_NAME],
Float:	sup_posX,
Float:	sup_posY,
Float:	sup_posZ,
bool:	sup_used
}

static
Float:	sup_DropLocationData[MAX_SUPPLY_DROP_LOCATIONS][E_SUPPLY_DROP_LOCATION_DATA],
		sup_TotalLocations,

		sup_ObjCrate1 = INVALID_OBJECT_ID,
		sup_ObjCrate2 = INVALID_OBJECT_ID,
		sup_ObjPara = INVALID_OBJECT_ID,
Float:	sup_DropX,
Float:	sup_DropY,
Float:	sup_DropZ;


hook OnGameModeInit()
{
	defer SupplyDropTimer();
	return 1;
}

DefineSupplyDropPos(name[MAX_SUPPLY_DROP_LOCATION_NAME], Float:x, Float:y, Float:z)
{
	sup_DropLocationData[sup_TotalLocations][sup_name] = name;
	sup_DropLocationData[sup_TotalLocations][sup_posX] = x;
	sup_DropLocationData[sup_TotalLocations][sup_posY] = y;
	sup_DropLocationData[sup_TotalLocations][sup_posZ] = z;

	sup_TotalLocations++;
}

timer SupplyDropTimer[SUPPLY_CRATE_INTERVAL]()
{
	if(Iter_Count(Player) < 2)
		return;

	new location = random(sup_TotalLocations);

	while(sup_DropLocationData[location][sup_used])
		location = random(sup_TotalLocations);

	SupplyCrateDrop(sup_DropLocationData[location][sup_posX], sup_DropLocationData[location][sup_posY], sup_DropLocationData[location][sup_posZ]);
	MsgAllF(YELLOW, " >  [EBS]: SUPPLY DROP INCOMING AT LOCATION: "C_BLUE"'%s'", sup_DropLocationData[location][sup_name]);

	sup_DropLocationData[location][sup_used] = true;

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
		8 + random(9), loot_Military);

	DestroyDynamicObject(sup_ObjPara);
	sup_ObjCrate1 = INVALID_OBJECT_ID;
	sup_ObjCrate2 = INVALID_OBJECT_ID;
	sup_ObjPara = INVALID_OBJECT_ID;
}

public OnDynamicObjectMoved(objectid)
{
	if(objectid == sup_ObjPara)
		SupplyCrateLand();

	return CallLocalFunction("sup_OnDynamicObjectMoved", "d", objectid);
}
#if defined _ALS_OnDynamicObjectMoved
	#undef OnDynamicObjectMoved
#else
	#define _ALS_OnDynamicObjectMoved
#endif
#define OnDynamicObjectMoved sup_OnDynamicObjectMoved
forward sup_OnDynamicObjectMoved(objectid);

CMD:sc(playerid, params[])
{
	new
		Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	SupplyCrateDrop(x, y, z);

	return 1;
}
