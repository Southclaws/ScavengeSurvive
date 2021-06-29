/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_SUPPLY_DROP_TYPE			(5)
#define MAX_SUPPLY_DROP_TYPE_NAME		(24)
#define MAX_SUPPLY_DROP_LOCATIONS		(38)
#define MAX_SUPPLY_DROP_LOCATION_NAME	(32)
#define SUPPLY_DROP_SPEED				(3.5)
#define SUPPLY_DROP_TICK_INTERVAL		(60000)
#define SUPPLY_DROP_COOLDOWN			(600000)


enum E_SUPPLY_DROP_TYPE_DATA
{
			supt_name[MAX_SUPPLY_DROP_TYPE_NAME],
			supt_loot[32],
			supt_interval,
			supt_random,
			supt_required,

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
   Iterator:sup_Index<MAX_SUPPLY_DROP_LOCATIONS>,
			sup_TotalLocations,
Timer:		sup_UpdateTimer,
			sup_CurrentType = -1,
			sup_LastSupplyDrop,
			sup_ObjCrate1 = INVALID_OBJECT_ID,
			sup_ObjCrate2 = INVALID_OBJECT_ID,
			sup_ObjPara = INVALID_OBJECT_ID,
Float:		sup_DropX,
Float:		sup_DropY,
Float:		sup_DropZ,
Container:	sup_Containerid = INVALID_CONTAINER_ID,
Button:		sup_Button = INVALID_BUTTON_ID;


hook OnGameModeInit()
{
	sup_UpdateTimer = repeat SupplyDropTimer();

	return 1;
}


DefineSupplyDropType(const name[], const lootindex[], interval, rand, required)
{
	if(sup_TypeTotal == MAX_SUPPLY_DROP_TYPE)
	{
		err("Supply drop type limit reached.");
		return -1;
	}

	strcat(sup_TypeData[sup_TypeTotal][supt_name], name, MAX_SUPPLY_DROP_TYPE_NAME);
	strcat(sup_TypeData[sup_TypeTotal][supt_loot], lootindex, 32);
	sup_TypeData[sup_TypeTotal][supt_interval] = interval * 1000;
	sup_TypeData[sup_TypeTotal][supt_random] = rand * 1000;
	sup_TypeData[sup_TypeTotal][supt_required] = required;

	sup_TypeData[sup_TypeTotal][supt_lastDrop] = GetTickCount() - sup_TypeData[sup_TypeTotal][supt_interval];
	sup_TypeData[sup_TypeTotal][supt_offset] = random(sup_TypeData[sup_TypeTotal][supt_random]);

	return sup_TypeTotal++;
}

DefineSupplyDropPos(const name[MAX_SUPPLY_DROP_LOCATION_NAME], Float:x, Float:y, Float:z)
{
	new id = Iter_Free(sup_Index);

	if(id == ITER_NONE)
	{
		err("Supply drop pos definition limit reached.");
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
	// sup_CurrentType represents which type of crate is currently in the
	// falling animation. This value is always -1 except for the time between
	// a drop starting and landing.
	if(sup_CurrentType != -1)
	{
		dbg("supply-crate", 1, "[SupplyDropTimer] Current type != -1: %d", sup_CurrentType);
		return;
	}

	// sup_Index is the linked-list of supply drop locations. When it's empty,
	// there are no more locations so stop the timer.
	if(Iter_Count(sup_Index) == 0)
	{
		err("Supply drops run out, stopping supply drop timer.");
		stop sup_UpdateTimer;
		return;
	}

	// This checks the time between the last drop time (sup_LastSupplyDrop) and
	// the current time GetTickCount(). If that interval is below the maximum
	// cooldown time, the script just waits for the next timer call.
	if(GetTickCountDifference(GetTickCount(), sup_LastSupplyDrop) < SUPPLY_DROP_COOLDOWN)
	{
		dbg("supply-crate", 1, "[SupplyDropTimer] Cooling down: %d/%d.", GetTickCountDifference(GetTickCount(), sup_LastSupplyDrop), SUPPLY_DROP_COOLDOWN);
		return;
	}

	new
		type,
		id,
		ret;

	// This loop picks a type. Types have a required amount of players
	// (supt_required) designed so more valuable drops only fall if there are
	// more players available to fight over them. This also encourages players
	// to invite their friends onto the server to increase their chances!
	while(type < sup_TypeTotal)
	{
		// The code used to pick the drop type is actually a bit weird and I
		// should probably rewrite it. The current system isn't actually a
		// randomised choice, it cycles through drop types (hence 'type++')

		// The first check looks at the player count vs player requirement for
		// a type. If it does not meet this requirement, the type is cycled to
		// the next.
		if(Iter_Count(Player) < sup_TypeData[type][supt_required])
		{
			dbg("supply-crate", 1, "[SupplyDropTimer] Checking %d: Not enough players (%d < %d).", type, Iter_Count(Player), sup_TypeData[type][supt_required]);
			type++;
			continue;
		}

		// Here, the check is for the last drop time of the individual type.
		// This works just the same as the earlier check for global drop
		// cooldown except it's for each individual drop type.

		// supt_offset is actually the only randomised property that affects
		// when a drop falls. Everything else is completely systematic and
		// predictable if the value of supt_offset value is known.

		// As before, if the check finds that the time between the last time
		// this drop fell is below the drop type cooldown PLUS the randomised
		// offset value, the code skips this drop type.
		if(GetTickCountDifference(GetTickCount(), sup_TypeData[type][supt_lastDrop]) < sup_TypeData[type][supt_interval] + sup_TypeData[type][supt_offset])
		{
			dbg("supply-crate", 1, "[SupplyDropTimer] Checking %d: Last drop too soon (%d < %d).", type, GetTickCountDifference(GetTickCount(), sup_TypeData[type][supt_lastDrop]), sup_TypeData[type][supt_interval] + sup_TypeData[type][supt_offset]);
			type++;
			continue;
		}

		break;
	}

	// If the loop ran through every drop type and reached an out of bounds
	// value, the entire process is cancelled since no drops are available as
	// they either don't meet the player requirement or are still cooling down.
	if(type == sup_TypeTotal)
	{
		dbg("supply-crate", 1, "[SupplyDropTimer] No supply drop type available.");
		return;
	}

	// Now, the code has determined what drop to create it needs to pick a
	// location. This is why the location index is a linked-list. As locations
	// are removed from the index over time, Iter_Random can efficiently pick
	// a random index as oppose to a regular array which would require a loop
	// that misses more and more as indexes are removed or it would require a
	// secondary array to keep track of available entries.
	id = Iter_Random(sup_Index);
	ret = SupplyCrateDrop(type, sup_DropLocationData[id][supl_posX], sup_DropLocationData[id][supl_posY], sup_DropLocationData[id][supl_posZ]);

	// This block should never actually execute but it's here as a warning. If
	// SupplyCrateDrop returns 0 somehow, it means the value of sup_CurrentType
	// was changed at some point between SupplyDropTimer and SupplyCrateDrop.
	// This would be a red flag for memory corruption!
	if(!ret)
	{
		err("Supply crate already active (type: %d)", sup_CurrentType);
		return;
	}

	// Finally, just aesthetics. The supply drop message is generated and the
	// name of the drop is randomised. This was designed to give some
	// uncertainty to the whole process so players don't always know what kind
	// of loot a drop contains. This uncertainty also brings in a skill of
	// keeping track of drops. If a rare drop hasn't appeared for hours then an
	// unknown drop is more likely to be of that type so more worth the risk.
	new name[MAX_SUPPLY_DROP_TYPE_NAME];

	if(random(100) < 50)
		strcat(name, sup_TypeData[type][supt_name], MAX_SUPPLY_DROP_TYPE_NAME);

	else
		name = "Unknown";

	ChatMsgAll(YELLOW, " >  [EBS]: SUPPLY DROP: "C_BLUE"\"%s\""C_YELLOW" INCOMING AT: "C_ORANGE"\"%s\"", name, sup_DropLocationData[id][supl_name]);

	// Remove the location from the index so it isn't chosen again.
	Iter_Remove(sup_Index, id);

	// Record the current time and store it for next time this function is
	// called and the cooldown check can be made. Also, assign a randomised time
	// offset to remove predictability from the system. As mentioned before,
	// this is actually the only randomised element of the drop process.
	sup_TypeData[type][supt_lastDrop] = GetTickCount();
	sup_TypeData[type][supt_offset] = random(sup_TypeData[type][supt_random]);

	return;
}

SupplyCrateDrop(type, Float:x, Float:y, Float:z)
{
	dbg("supply-crate", 1, "[SupplyCrateDrop] Dropping supply crate of type %d at %f %f %f", type, x, y, z);

	if(sup_CurrentType != -1)
	{
		dbg("supply-crate", 1, "[SupplyCrateDrop] ERROR: sup_CurrentType is not -1 (%d)", sup_CurrentType);
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
	dbg("supply-crate", 1, "[SupplyCrateLand] Supply crate landed, type: %d", sup_CurrentType);

	if(sup_CurrentType == -1)
	{
		err("sup_CurrentType == -1");
		return;
	}

	new
		Float:a,
		Float:x,
		Float:y,
		Float:z,
		lootindex,
		freeslots;

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, 3.0, sup_DropX, sup_DropY, sup_DropZ))
		{
			GetPlayerPos(i, x, y, z);
			a = GetAngleToPoint(sup_DropX, sup_DropY, x, y);

			SetPlayerPos(i, sup_DropX + (3.0 * floatsin(a, degrees)), sup_DropY + (3.0 * floatcos(a, degrees)), sup_DropZ + 1.0);
		}		
	}

	if(sup_Containerid != INVALID_CONTAINER_ID)
		DestroyContainer(sup_Containerid);

	if(sup_Button != INVALID_BUTTON_ID)
		DestroyButton(sup_Button);
		
	sup_Containerid = CreateContainer("Supply Crate", 32);
	sup_Button = CreateButton(sup_DropX + 1.5, sup_DropY, sup_DropZ + 1.0, "Supply Crate", .label = 1, .labeltext = "Supply Crate");

	lootindex = GetLootIndexFromName(sup_TypeData[sup_CurrentType][supt_loot]);
	FillContainerWithLoot(Container:sup_Containerid, 4 + random(16), lootindex);
	GetContainerFreeSlots(Container:sup_Containerid, freeslots);
	dbg("supply-crate", 2, "[SupplyCrateLand] Spawned %d items in supply crate container %d", 32 - freeslots, _:sup_Containerid);

	DestroyDynamicObject(sup_ObjPara);
	sup_CurrentType = -1;
	sup_ObjCrate1 = INVALID_OBJECT_ID;
	sup_ObjCrate2 = INVALID_OBJECT_ID;
	sup_ObjPara = INVALID_OBJECT_ID;

	sup_LastSupplyDrop = GetTickCount();

	return;
}

hook OnButtonPress(playerid, Button:id)
{
	if(id == sup_Button)
		DisplayContainerInventory(playerid, Container:sup_Containerid);
}

hook OnDynamicObjectMoved(objectid)
{
	if(objectid == sup_ObjPara)
		SupplyCrateLand();

	return Y_HOOKS_CONTINUE_RETURN_0;
}

ACMD:sc[4](playerid, params[])
{
	new type = strval(params);

	if(isnull(params) || !(0 <= type < sup_TypeTotal))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /sc [type] - types:");

		for(new i; i < sup_TypeTotal; i++)
			ChatMsg(playerid, YELLOW, " >  %d: %s", i, sup_TypeData[i][supt_name]);

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

ACMD:scinfo[4](playerid, params[])
{
	ChatMsg(playerid, YELLOW, " >  Current type: %d", sup_CurrentType);

	for(new i; i < sup_TypeTotal; i++)
		ChatMsg(playerid, YELLOW, " >  %d: Tick diff: %d Curr tick: %d Last drop: %d Interval+Offset: %d", i, GetTickCountDifference(GetTickCount(), sup_TypeData[i][supt_lastDrop]), GetTickCount(), sup_TypeData[i][supt_lastDrop], sup_TypeData[i][supt_interval] + sup_TypeData[i][supt_offset]);

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
