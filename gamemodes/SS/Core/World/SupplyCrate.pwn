#include <YSI\y_hooks>


#define MAX_SUPPLY_DROP_TYPE			(5)
#define MAX_SUPPLY_DROP_TYPE_NAME		(24)
#define MAX_SUPPLY_DROP_LOCATIONS		(38)
#define MAX_SUPPLY_DROP_LOCATION_NAME	(32)
#define SUPPLY_DROP_SPEED				(3.5)
#define SUPPLY_DROP_TICK_INTERVAL		(60000)
#define SUPPLY_DROP_COOLDOWN			(300000)


enum E_SUPPLY_DROP_TYPE_DATA
{
			supt_name[MAX_SUPPLY_DROP_TYPE_NAME],
			supt_loot,
			supt_interval,
			supt_random,

			supt_lastDrop,
			supt_offset
}

enum E_SUPPLY_DROP_LOCATION_DATA
{
			supl_name[MAX_SUPPLY_DROP_LOCATION_NAME],
Float:		supl_posX,
Float:		supl_posY,
Float:		supl_posZ,
bool:		supl_used
}

static
			sup_TypeData[MAX_SUPPLY_DROP_TYPE][E_SUPPLY_DROP_TYPE_DATA],
			sup_TypeTotal;

static
Float:		sup_DropLocationData[MAX_SUPPLY_DROP_LOCATIONS][E_SUPPLY_DROP_LOCATION_DATA],
Iterator:	sup_Index<MAX_SUPPLY_DROP_LOCATIONS>,
			sup_TotalLocations,

			sup_CurrentType = -1,
			sup_LastSupplyDrop,
			sup_ObjCrate1 = INVALID_OBJECT_ID,
			sup_ObjCrate2 = INVALID_OBJECT_ID,
			sup_ObjPara = INVALID_OBJECT_ID,
Float:		sup_DropX,
Float:		sup_DropY,
Float:		sup_DropZ;

static
			sup_RequiredPlayers = 3;


static
			HANDLER = -1;


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'SupplyCrate'...");

	repeat SupplyDropTimer();

	HANDLER = debug_register_handler("SupplyCrate", 2);

	return 1;
}


DefineSupplyDropType(name[], lootindex, interval, rand)
{
	if(sup_TypeTotal == MAX_SUPPLY_DROP_TYPE)
	{
		print("ERROR: Supply drop type limit reached.");
		return -1;
	}

	strcat(sup_TypeData[sup_TypeTotal][supt_name], name, MAX_SUPPLY_DROP_TYPE_NAME);
	sup_TypeData[sup_TypeTotal][supt_loot] = lootindex;
	sup_TypeData[sup_TypeTotal][supt_interval] = interval * 1000;
	sup_TypeData[sup_TypeTotal][supt_random] = rand * 1000;

	sup_TypeData[sup_TypeTotal][supt_lastDrop] = GetTickCount() - sup_TypeData[sup_TypeTotal][supt_interval];
	sup_TypeData[sup_TypeTotal][supt_offset] = random(sup_TypeData[sup_TypeTotal][supt_random]);

	return sup_TypeTotal++;
}

DefineSupplyDropPos(name[MAX_SUPPLY_DROP_LOCATION_NAME], Float:x, Float:y, Float:z)
{
	new id = Iter_Free(sup_Index);

	if(id == -1)
	{
		printf("ERROR: Supply drop pos definition limit reached.");
		return -1;
	}

	sup_DropLocationData[id][supl_name] = name;
	sup_DropLocationData[id][supl_posX] = x;
	sup_DropLocationData[id][supl_posY] = y;
	sup_DropLocationData[id][supl_posZ] = z;

	Iter_Add(sup_Index, id);
	sup_TotalLocations++;

	return id;
}

timer SupplyDropTimer[SUPPLY_DROP_TICK_INTERVAL]()
{
	if(sup_CurrentType != -1)
	{
		d:1:HANDLER("[SupplyDropTimer] Current type != -1: %d", sup_CurrentType);
		return;
	}

	if(Iter_Count(Player) < sup_RequiredPlayers)
	{
		d:1:HANDLER("[SupplyDropTimer] Player count (%d) is below required player count (%d).", Iter_Count(Player), sup_RequiredPlayers);
		return;
	}

	if(Iter_Count(sup_Index) == 0)
	{
		printf("[SupplyDropTimer] ERROR: Supply drops run out, stopping supply drop timer.");
		return;
	}

	if(GetTickCountDifference(GetTickCount(), sup_LastSupplyDrop) < SUPPLY_DROP_COOLDOWN)
	{
		d:1:HANDLER("[SupplyDropTimer] Cooling down: %d/%d.", GetTickCountDifference(GetTickCount(), sup_LastSupplyDrop), SUPPLY_DROP_COOLDOWN);
		return;
	}

	new
		id,
		ret;

	for(new i; i < sup_TypeTotal; i++)
	{
		d:2:HANDLER("[SupplyDropTimer] Supply type: %d time since last drop: %d interval + offset: %d", i, GetTickCountDifference(GetTickCount(), sup_TypeData[i][supt_lastDrop]), sup_TypeData[i][supt_interval] + sup_TypeData[i][supt_offset]);
		if(GetTickCountDifference(GetTickCount(), sup_TypeData[i][supt_lastDrop]) < sup_TypeData[i][supt_interval] + sup_TypeData[i][supt_offset])
			continue;

		id = Iter_Random(sup_Index);
		ret = SupplyCrateDrop(i, sup_DropLocationData[id][supl_posX], sup_DropLocationData[id][supl_posY], sup_DropLocationData[id][supl_posZ]);

		if(ret)
		{
			MsgAllF(YELLOW, " >  [EBS]: SUPPLY DROP: "C_BLUE"\"%s\""C_YELLOW" INCOMING AT: "C_ORANGE"\"%s\"", sup_TypeData[i][supt_name], sup_DropLocationData[id][supl_name]);

			Iter_Remove(sup_Index, id);

			sup_TypeData[i][supt_lastDrop] = GetTickCount();
			sup_TypeData[i][supt_offset] = random(sup_TypeData[i][supt_random]);

			return;
		}

		printf("[SupplyDropTimer] ERROR: Supply crate already active (type: %d)", sup_CurrentType);

		break;
	}

	return;
}

SupplyCrateDrop(type, Float:x, Float:y, Float:z)
{
	d:1:HANDLER("[SupplyCrateDrop] Dropping supply crate of type %d at %f %f %f", type, x, y, z);

	if(sup_CurrentType != -1)
	{
		d:1:HANDLER("[SupplyCrateDrop] ERROR: sup_CurrentType is not -1 (%d)", sup_CurrentType);
		return 0;
	}

	sup_ObjCrate1 = CreateDynamicObject(3799, x, y, 1000.0, 0.0, 0.0, 0.0, .streamdistance = 10000),
	sup_ObjCrate2 = CreateDynamicObject(3799, x + 0.01, y + 0.01, 1000.0 + 2.4650, 0.0, 180.0, 0.0, .streamdistance = 10000),
	sup_ObjPara = CreateDynamicObject(18849, x, y, 1000.0 + 8.0, 0.0, 0.0, 0.0, .streamdistance = 10000),
	CreateDynamicObject(18728, x, y, z - 1.0, 0.0, 0.0, 0.0);

	MoveDynamicObject(sup_ObjCrate1, x, y, z, SUPPLY_DROP_SPEED, 0.0, 0.0, 720.0);
	MoveDynamicObject(sup_ObjCrate2, x + 0.01, y + 0.01, z + 2.4650, SUPPLY_DROP_SPEED, 0.0, 180.0, 720.0);
	MoveDynamicObject(sup_ObjPara, x, y, z - 10.0, SUPPLY_DROP_SPEED, 0.0, 0.0, 720.0);

	sup_CurrentType = type;
	sup_DropX = x;
	sup_DropY = y;
	sup_DropZ = z;

	return 1;
}

SupplyCrateLand()
{
	d:1:HANDLER("[SupplyCrateLand] Supply crate landed, type: %d", sup_CurrentType);

	if(sup_CurrentType == -1)
	{
		print("ERROR: sup_CurrentType == -1");
		return;
	}

	new
		containerid,
		Float:a,
		Float:x,
		Float:y,
		Float:z;

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, 3.0, sup_DropX, sup_DropY, sup_DropZ))
		{
			GetPlayerPos(i, x, y, z);
			a = GetAngleToPoint(sup_DropX, sup_DropY, x, y);

			SetPlayerPos(i, sup_DropX + (3.0 * floatsin(a, degrees)), sup_DropY + (3.0 * floatcos(a, degrees)), sup_DropZ + 1.0);
		}		
	}

	containerid = CreateContainer("Supply Crate", 48, sup_DropX + 1.5, sup_DropY, sup_DropZ + 1.0);

	FillContainerWithLoot(containerid, 38 + random(11), sup_TypeData[sup_CurrentType][supt_loot]);
	d:2:HANDLER("[SupplyCrateLand] Spawned %d items in supply crate container %d", 48 - GetContainerFreeSlots(containerid), containerid);

	DestroyDynamicObject(sup_ObjPara);
	sup_CurrentType = -1;
	sup_ObjCrate1 = INVALID_OBJECT_ID;
	sup_ObjCrate2 = INVALID_OBJECT_ID;
	sup_ObjPara = INVALID_OBJECT_ID;

	sup_LastSupplyDrop = GetTickCount();

	return;
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
	new type = strval(params);

	if(isnull(params) || !(0 <= type < sup_TypeTotal))
	{
		MsgF(playerid, YELLOW, " >  Usage: /sc [type] - types:");

		for(new i; i < sup_TypeTotal; i++)
			MsgF(playerid, YELLOW, " >  %d: %s", i, sup_TypeData[i][supt_name]);

		return 1;
	}

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	SupplyCrateDrop(type, x, y, z - 0.8);

	return 1;
}

ACMD:screq[4](playerid, params[])
{
	sup_RequiredPlayers = strval(params);

	MsgF(playerid, YELLOW, " >  Required players for supply drops set to %d.", sup_RequiredPlayers);

	return 1;
}

ACMD:scinfo[4](playerid, params[])
{
	MsgF(playerid, YELLOW, " >  Current type: %d", sup_CurrentType);

	for(new i; i < sup_TypeTotal; i++)
		MsgF(playerid, YELLOW, " >  %d: Tick diff: %d Curr tick: %d Last drop: %d Interval+Offset: %d", i, GetTickCountDifference(GetTickCount(), sup_TypeData[i][supt_lastDrop]), GetTickCount(), sup_TypeData[i][supt_lastDrop], sup_TypeData[i][supt_interval] + sup_TypeData[i][supt_offset]);

	return 1;
}

// Interface


stock GetSupplyDropLocationName(location, name[MAX_SUPPLY_DROP_LOCATION_NAME])
{
	if(location >= sup_TotalLocations)
		return 0;

	name[0] = EOS;
	strcat(name, sup_DropLocationData[location][supl_name]);

	return 1;
}

stock GetSupplyDropLocationPos(location, &Float:x, &Float:y, &Float:z)
{
	if(location >= sup_TotalLocations)
		return 0;

	x = sup_DropLocationData[location][supl_posX];
	y = sup_DropLocationData[location][supl_posY];
	z = sup_DropLocationData[location][supl_posZ];

	return 1;
}

stock IsSupplyDropLocationUsed(location)
{
	if(location >= sup_TotalLocations)
		return 0;

	return sup_DropLocationData[location][supl_used];
}

stock GetTotalSupplyDropLocations()
{
	return sup_TotalLocations;
}
