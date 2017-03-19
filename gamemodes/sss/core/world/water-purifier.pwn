/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


/*==============================================================================

	Setup

==============================================================================*/


#define MAX_WATER_MACHINE			(32)
#define MAX_WATER_MACHINE_ITEMS		(12)
#define MAX_WATER_MACHINE_FUEL		(80.0)
#define WATER_MACHINE_FUEL_USAGE	(3.5)


enum E_WATER_MACHINE_DATA
{
			wm_machineId,
Float:		wm_fuel,
bool:		wm_cooking,
			wm_smoke,
			wm_cookTime,
			wm_startTime
}


static
			wm_Data[MAX_WATER_MACHINE][E_WATER_MACHINE_DATA],
			wm_Total,

			wm_MachineWaterMachine[MAX_MACHINE] = {-1, ...},

			wm_CurrentWaterMachine[MAX_PLAYERS];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/world/water-purifier.pwn");

	wm_CurrentWaterMachine[playerid] = -1;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateWaterMachine(Float:x, Float:y, Float:z, Float:rz)
{
	if(wm_Total == MAX_WATER_MACHINE - 1)
	{
		err("MAX_WATER_MACHINE Limit reached.");
		return 0;
	}

	wm_Data[wm_Total][wm_machineId] = CreateMachine(943, x, y, z, rz, "Refining Machine", "Press "KEYTEXT_INTERACT" to access machine~n~Hold "KEYTEXT_INTERACT" to open menu~n~Use Petrol Can to add fuel", MAX_WATER_MACHINE_ITEMS);

	wm_MachineWaterMachine[wm_Data[wm_Total][wm_machineId]] = wm_Total;

	return wm_Total++;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerUseMachine(playerid, machineid, interactiontype)
{
	dbg("global", CORE, "[OnPlayerUseMachine] in /gamemodes/sss/core/world/water-purifier.pwn");

	if(wm_MachineWaterMachine[machineid] != -1)
	{
		dbg("gamemodes/sss/core/world/water-purifier.pwn", 1, "[OnPlayerUseMachine] machineid %d water machine %d interactiontype %d", machineid, wm_MachineWaterMachine[machineid], interactiontype);
		if(wm_Data[wm_MachineWaterMachine[machineid]][wm_machineId] == machineid)
		{
			_wm_PlayerUseWaterMachine(playerid, wm_MachineWaterMachine[machineid], interactiontype);
		}
		else
		{
			err("WaterMachine bi-directional link error. wm_MachineWaterMachine wm_machineId = %d machineid = %d");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_wm_PlayerUseWaterMachine(playerid, watermachineid, interactiontype)
{
	dbg("gamemodes/sss/core/world/water-purifier.pwn", 1, "[_wm_PlayerUseWaterMachine] playerid %d watermachineid %d interactiontype %d", playerid, watermachineid, interactiontype);

	if(wm_Data[watermachineid][wm_cooking])
	{
		ShowActionText(playerid, sprintf(ls(playerid, "MACHPROCESS", true), MsToString(wm_Data[watermachineid][wm_cookTime] - GetTickCountDifference(GetTickCount(), wm_Data[watermachineid][wm_startTime]), "%m minutes %s seconds")), 8000);
		return 0;
	}

	if(interactiontype == 0)
	{
		DisplayContainerInventory(playerid, GetMachineContainerID(wm_Data[watermachineid][wm_machineId]));
		return 0;
	}

	wm_CurrentWaterMachine[playerid] = watermachineid;

	new 
		ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

	if(GetItemTypeLiquidContainerType(itemtype) != -1)
	{
		if(GetLiquidItemLiquidType(GetPlayerItem(playerid)) == liquid_Petrol)
		{
			dbg("gamemodes/sss/core/world/water-purifier.pwn", 1, "[_wm_PlayerUseWaterMachine] starting HoldAction for %ds starting at %ds", floatround(MAX_WATER_MACHINE_FUEL), floatround(wm_Data[watermachineid][wm_fuel]));
			StartHoldAction(playerid, floatround(MAX_WATER_MACHINE_FUEL * 1000), floatround(wm_Data[watermachineid][wm_fuel] * 1000));
			return 0;
		}
	}

	Dialog_Show(playerid, WaterMachine, DIALOG_STYLE_MSGBOX, "Refining Machine", sprintf("Press 'Start' to activate the water purifier.\n\n"C_GREEN"Fuel amount: "C_WHITE"%.1f", wm_Data[watermachineid][wm_fuel]), "Start", "Cancel");

	return 0;
}

Dialog:WaterMachine(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new ret = _wm_StartCooking(watermachineid);

		if(ret == 0)
			ShowActionText(playerid, ls(playerid, "MACHNOITEMS", true), 5000);

		else if(ret == -1)
			ShowActionText(playerid, ls(playerid, "MACHRESTART", true), 6000);

		else if(ret == -2)
			ShowActionText(playerid, sprintf(ls(playerid, "MACHNOTFUEL", true), WATER_MACHINE_FUEL_USAGE), 6000);

		else
			ShowActionText(playerid, sprintf(ls(playerid, "MACHCOOKTIM", true), MsToString(ret, "%m minutes %s seconds")), 6000);

		wm_CurrentWaterMachine[playerid] = -1;
	}
}

hook OnItemAddToContainer(containerid, itemid, playerid)
{
	dbg("global", CORE, "[OnItemAddToContainer] in /gamemodes/sss/core/world/water-machine.pwn");

	if(playerid != INVALID_PLAYER_ID)
	{
		new machineid = GetContainerMachineID(containerid);

		if(machineid != INVALID_MACHINE_ID)
		{
			if(wm_MachineWaterMachine[machineid] != -1)
			{
				if(GetItemType(itemid) != item_ScrapMetal)
					return 1;
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionUpdate(playerid, progress)
{
	dbg("global", CORE, "[OnHoldActionUpdate] in /gamemodes/sss/core/world/water-machine.pwn");

	if(wm_CurrentWaterMachine[playerid] != -1)
	{
		dbg("gamemodes/sss/core/world/water-purifier.pwn", 3, "[OnHoldActionUpdate] watermachineid %d progress %d", wm_CurrentWaterMachine[playerid], progress);

		new itemid = GetPlayerItem(playerid);

		if(GetItemTypeLiquidContainerType(GetItemType(itemid)) != -1)
		{
			if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
			{
				dbg("gamemodes/sss/core/world/water-purifier.pwn", 3, "[OnHoldActionUpdate] Stopping HoldAction: player not holding petrol can");
				StopHoldAction(playerid);
				wm_CurrentWaterMachine[playerid] = -1;
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}

		new 
			Float:fuel = GetLiquidItemLiquidAmount(itemid),
			Float:transfer;

		if(fuel <= 0.0)
		{
			dbg("gamemodes/sss/core/world/water-purifier.pwn", 3, "[OnHoldActionUpdate] Stopping HoldAction: petrol can has %d < 0 fuel", fuel);
			StopHoldAction(playerid);
			wm_CurrentWaterMachine[playerid] = -1;
			HideActionText(playerid);
		}
		else
		{
			dbg("gamemodes/sss/core/world/water-purifier.pwn", 3, "[OnHoldActionUpdate] setting petrol can to %d, machine to %.1f", fuel - 1, wm_Data[wm_CurrentWaterMachine[playerid]][wm_fuel] + 1.0);
			transfer = (fuel - 1.1 < 0.0) ? fuel : 1.1;
			SetLiquidItemLiquidAmount(itemid, fuel - transfer);
			wm_Data[wm_CurrentWaterMachine[playerid]][wm_fuel] += 1.1;
			ShowActionText(playerid, ls(playerid, "REFUELLING", true));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_wm_StartCooking(watermachineid)
{
	dbg("gamemodes/sss/core/world/water-purifier.pwn", 1, "[_wm_PlayerUseWaterMachine] watermachineid %d", watermachineid);
	new itemcount;

	for(new j = GetContainerSize(GetMachineContainerID(wm_Data[watermachineid][wm_machineId])); itemcount < j; itemcount++)
	{
		if(!IsContainerSlotUsed(GetMachineContainerID(wm_Data[watermachineid][wm_machineId]), itemcount))
			break;
	}

	if(itemcount == 0)
		return 0;

	// cook time = 60 seconds per item plus random 20 seconds
	new cooktime = (itemcount * 60) + random(20);
	dbg("gamemodes/sss/core/world/water-purifier.pwn", 2, "[_wm_PlayerUseWaterMachine] itemcount %d cooktime %ds", itemcount, cooktime);

	// if there's not enough time left, don't allow a new cook to start.
	if(gServerUptime >= gServerMaxUptime - (cooktime * 1.5))
		return -1;

	if(wm_Data[watermachineid][wm_fuel] < WATER_MACHINE_FUEL_USAGE * itemcount)
		return -2;

	new
		Float:x,
		Float:y,
		Float:z;

	GetMachinePos(wm_Data[watermachineid][wm_machineId], x, y, z);

	cooktime *= 1000; // convert to ms

	dbg("gamemodes/sss/core/world/water-purifier.pwn", 2, "[_wm_PlayerUseWaterMachine] started cooking...");
	wm_Data[watermachineid][wm_cooking] = true;
	DestroyDynamicObject(wm_Data[watermachineid][wm_smoke]);
	wm_Data[watermachineid][wm_smoke] = CreateDynamicObject(18726, x, y, z - 1.0, 0.0, 0.0, 0.0);
	wm_Data[watermachineid][wm_cookTime] = cooktime;
	wm_Data[watermachineid][wm_startTime] = GetTickCount();

	defer _wm_FinishCooking(watermachineid, cooktime);

	return cooktime;
}

timer _wm_FinishCooking[cooktime](watermachineid, cooktime)
{
#pragma unused cooktime
	dbg("gamemodes/sss/core/world/water-purifier.pwn", 1, "[_wm_PlayerUseWaterMachine] finished cooking...");
	new
		itemid,
		containerid = GetMachineContainerID(wm_Data[watermachineid][wm_machineId]),
		itemcount;

	for(new i = GetContainerItemCount(containerid) - 1; i > -1; i--)
	{
		itemid = GetContainerSlotItem(containerid, i);

		dbg("gamemodes/sss/core/world/water-purifier.pwn", 3, "[_wm_PlayerUseWaterMachine] slot %d: destroying %d", i, itemid);

		wm_Data[watermachineid][wm_fuel] -= WATER_MACHINE_FUEL_USAGE;

		DestroyItem(itemid);
		itemcount++;
	}

	for(new i; i < itemcount; i++)
	{
		itemid = CreateItem(item_Bottle);
		AddItemToContainer(containerid, itemid);
	}

	DestroyDynamicObject(wm_Data[watermachineid][wm_smoke]);
	wm_Data[watermachineid][wm_cooking] = false;
	wm_Data[watermachineid][wm_smoke] = INVALID_OBJECT_ID;
}
