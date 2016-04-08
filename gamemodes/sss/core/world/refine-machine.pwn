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


#define MAX_REFINE_MACHINE			(32)
#define MAX_REFINE_MACHINE_ITEMS	(12)
#define MAX_REFINE_MACHINE_FUEL		(80.0)
#define REFINE_MACHINE_FUEL_USAGE	(3.5)


enum E_REFINE_MACHINE_DATA
{
			rm_machineId,
Float:		rm_fuel,
bool:		rm_cooking,
			rm_smoke,
			rm_cookTime,
			rm_startTime
}


static
			rm_Data[MAX_REFINE_MACHINE][E_REFINE_MACHINE_DATA],
			rm_Total,

			rm_MachineRefineMachine[MAX_MACHINE] = {-1, ...},

			rm_CurrentRefineMachine[MAX_PLAYERS];


static HANDLER = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	HANDLER = debug_register_handler("refine-machine");
}

hook OnPlayerConnect(playerid)
{
	rm_CurrentRefineMachine[playerid] = -1;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateRefineMachine(Float:x, Float:y, Float:z, Float:rz)
{
	if(rm_Total == MAX_REFINE_MACHINE - 1)
	{
		print("ERROR: MAX_REFINE_MACHINE Limit reached.");
		return 0;
	}

	rm_Data[rm_Total][rm_machineId] = CreateMachine(943, x, y, z, rz, "Refining Machine", "Press "KEYTEXT_INTERACT" to access machine~n~Hold "KEYTEXT_INTERACT" to open menu~n~Use Petrol Can to add fuel", MAX_REFINE_MACHINE_ITEMS);

	rm_MachineRefineMachine[rm_Data[rm_Total][rm_machineId]] = rm_Total;

	return rm_Total++;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerUseMachine(playerid, machineid, interactiontype)
{
	if(rm_MachineRefineMachine[machineid] != -1)
	{
		d:1:HANDLER("[OnPlayerUseMachine] machineid %d refine machine %d interactiontype %d", machineid, rm_MachineRefineMachine[machineid], interactiontype);
		if(rm_Data[rm_MachineRefineMachine[machineid]][rm_machineId] == machineid)
		{
			_rm_PlayerUseRefineMachine(playerid, rm_MachineRefineMachine[machineid], interactiontype);
		}
		else
		{
			printf("ERROR: RefineMachine bi-directional link error. rm_MachineRefineMachine rm_machineId = %d machineid = %d");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_rm_PlayerUseRefineMachine(playerid, refinemachineid, interactiontype)
{
	d:1:HANDLER("[_rm_PlayerUseRefineMachine] playerid %d refinemachineid %d interactiontype %d", playerid, refinemachineid, interactiontype);

	if(rm_Data[refinemachineid][rm_cooking])
	{
		ShowActionText(playerid, sprintf(ls(playerid, "MACHPROCESS"), MsToString(rm_Data[refinemachineid][rm_cookTime] - GetTickCountDifference(GetTickCount(), rm_Data[refinemachineid][rm_startTime]), "%m minutes %s seconds")), 8000);
		return 0;
	}

	if(interactiontype == 0)
	{
		DisplayContainerInventory(playerid, GetMachineContainerID(rm_Data[refinemachineid][rm_machineId]));
		return 0;
	}

	rm_CurrentRefineMachine[playerid] = refinemachineid;

	if(GetItemType(GetPlayerItem(playerid)) == item_GasCan)
	{
		d:1:HANDLER("[_rm_PlayerUseRefineMachine] starting HoldAction for %ds starting at %ds", floatround(MAX_REFINE_MACHINE_FUEL), floatround(rm_Data[refinemachineid][rm_fuel]));
		StartHoldAction(playerid, floatround(MAX_REFINE_MACHINE_FUEL * 1000), floatround(rm_Data[refinemachineid][rm_fuel] * 1000));
		return 0;
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			new ret = _rm_StartCooking(refinemachineid);

			if(ret == 0)
				ShowActionText(playerid, ls(playerid, "MACHNOITEMS"), 5000);

			else if(ret == -1)
				ShowActionText(playerid, ls(playerid, "MACHRESTART"), 6000);

			else if(ret == -2)
				ShowActionText(playerid, sprintf(ls(playerid, "MACHNOTFUEL"), REFINE_MACHINE_FUEL_USAGE), 6000);

			else
				ShowActionText(playerid, sprintf(ls(playerid, "MACHCOOKTIM"), MsToString(ret, "%m minutes %s seconds")), 6000);

			rm_CurrentRefineMachine[playerid] = -1;
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Refining Machine", sprintf("Press 'Start' to activate the refining machine and convert scrap into refined metal.\n\n"C_GREEN"Fuel amount: "C_WHITE"%.1f", rm_Data[refinemachineid][rm_fuel]), "Start", "Cancel");

	return 0;
}

hook OnItemAddToContainer(containerid, itemid, playerid)
{
	if(playerid != INVALID_PLAYER_ID)
	{
		new machineid = GetContainerMachineID(containerid);

		if(machineid != INVALID_MACHINE_ID)
		{
			if(rm_MachineRefineMachine[machineid] != -1)
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
	if(rm_CurrentRefineMachine[playerid] != -1)
	{
		d:3:HANDLER("[OnHoldActionUpdate] refinemachineid %d progress %d", rm_CurrentRefineMachine[playerid], progress);

		new itemid = GetPlayerItem(playerid);

		if(GetItemType(itemid) != item_GasCan)
		{
			d:3:HANDLER("[OnHoldActionUpdate] Stopping HoldAction: player not holding petrol can");
			StopHoldAction(playerid);
			rm_CurrentRefineMachine[playerid] = -1;
		}

		new fuel = GetItemArrayDataAtCell(itemid, 0);

		if(fuel <= 0)
		{
			d:3:HANDLER("[OnHoldActionUpdate] Stopping HoldAction: petrol can has %d < 0 fuel", fuel);
			StopHoldAction(playerid);
			rm_CurrentRefineMachine[playerid] = -1;
			HideActionText(playerid);
		}
		else
		{
			d:3:HANDLER("[OnHoldActionUpdate] setting petrol can to %d, machine to %.1f", fuel - 1, rm_Data[rm_CurrentRefineMachine[playerid]][rm_fuel] + 1.0);
			SetItemArrayDataAtCell(itemid, fuel - 1, 0);
			rm_Data[rm_CurrentRefineMachine[playerid]][rm_fuel] += 1.0;
			ShowActionText(playerid, ls(playerid, "REFUELLING"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_rm_StartCooking(refinemachineid)
{
	d:1:HANDLER("[_rm_PlayerUseRefineMachine] refinemachineid %d", refinemachineid);
	new itemcount;

	for(new j = GetContainerSize(GetMachineContainerID(rm_Data[refinemachineid][rm_machineId])); itemcount < j; itemcount++)
	{
		if(!IsContainerSlotUsed(GetMachineContainerID(rm_Data[refinemachineid][rm_machineId]), itemcount))
			break;
	}

	if(itemcount == 0)
		return 0;

	// cook time = 90 seconds per item plus random 30 seconds
	new cooktime = (itemcount * 90) + random(30);
	d:2:HANDLER("[_rm_PlayerUseRefineMachine] itemcount %d cooktime %ds", itemcount, cooktime);

	// if there's not enough time left, don't allow a new cook to start.
	if(gServerUptime >= gServerMaxUptime - (cooktime * 1.5))
		return -1;

	if(rm_Data[refinemachineid][rm_fuel] < REFINE_MACHINE_FUEL_USAGE * itemcount)
		return -2;

	new
		Float:x,
		Float:y,
		Float:z;

	GetMachinePos(rm_Data[refinemachineid][rm_machineId], x, y, z);

	cooktime *= 1000; // convert to ms

	d:2:HANDLER("[_rm_PlayerUseRefineMachine] started cooking...");
	rm_Data[refinemachineid][rm_cooking] = true;
	DestroyDynamicObject(rm_Data[refinemachineid][rm_smoke]);
	rm_Data[refinemachineid][rm_smoke] = CreateDynamicObject(18726, x, y, z - 1.0, 0.0, 0.0, 0.0);
	rm_Data[refinemachineid][rm_cookTime] = cooktime;
	rm_Data[refinemachineid][rm_startTime] = GetTickCount();

	defer _rm_FinishCooking(refinemachineid, cooktime);

	return cooktime;
}

timer _rm_FinishCooking[cooktime](refinemachineid, cooktime)
{
#pragma unused cooktime
	d:1:HANDLER("[_rm_PlayerUseRefineMachine] finished cooking...");
	new
		itemid,
		containerid = GetMachineContainerID(rm_Data[refinemachineid][rm_machineId]),
		itemcount;

	for(new i = GetContainerItemCount(containerid) - 1; i > -1; i--)
	{
		itemid = GetContainerSlotItem(containerid, i);

		d:3:HANDLER("[_rm_PlayerUseRefineMachine] slot %d: destroying %d", i, itemid);

		rm_Data[refinemachineid][rm_fuel] -= REFINE_MACHINE_FUEL_USAGE;

		DestroyItem(itemid);
		itemcount++;
	}

	for(new i; i < itemcount; i++)
	{
		itemid = CreateItem(item_RefinedMetal);
		AddItemToContainer(containerid, itemid);
	}

	DestroyDynamicObject(rm_Data[refinemachineid][rm_smoke]);
	rm_Data[refinemachineid][rm_cooking] = false;
	rm_Data[refinemachineid][rm_smoke] = INVALID_OBJECT_ID;
}
