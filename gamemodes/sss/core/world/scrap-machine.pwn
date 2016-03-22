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


#define MAX_SCRAP_MACHINE			(32)
#define MAX_SCRAP_MACHINE_ITEMS		(12)


enum E_SCRAP_MACHINE_DATA
{
			sm_machineId,
bool:		sm_cooking,
			sm_smoke,
			sm_cookTime,
			sm_startTime
}


static
			sm_Data[MAX_SCRAP_MACHINE][E_SCRAP_MACHINE_DATA],
			sm_Total,

			sm_ItemTypeScrapValue[ITM_MAX_TYPES],
			sm_MachineScrapMachine[BTN_MAX] = {INVALID_MACHINE_ID, ...},

			sm_CurrentScrapMachine[MAX_PLAYERS];


static HANDLER = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	HANDLER = debug_register_handler("scrap-machine");
}

hook OnPlayerConnect(playerid)
{
	sm_CurrentScrapMachine[playerid] = -1;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateScrapMachine(Float:x, Float:y, Float:z, Float:rz)
{
	if(sm_Total == MAX_SCRAP_MACHINE - 1)
	{
		print("ERROR: MAX_SCRAP_MACHINE Limit reached.");
		return 0;
	}

	sm_Data[sm_Total][sm_machineId] = CreateMachine(920, x, y, z, rz, "Scrap Machine", MAX_SCRAP_MACHINE_ITEMS);

	sm_MachineScrapMachine[sm_Data[sm_Total][sm_machineId]] = sm_Total;

	return sm_Total++;
}

stock SetItemTypeScrapValue(ItemType:itemtype, value)
{
	if(!IsValidItemType(itemtype))
	{
		printf("ERROR: Tried to assign scrap value to invalid item type.");
		return;
	}

	sm_ItemTypeScrapValue[itemtype] = value;

	return;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


public OnPlayerUseMachine(playerid, machineid, interactiontype)
{
	if(sm_MachineScrapMachine[machineid] != -1)
	{
		d:1:HANDLER("[OnPlayerUseMachine] machineid %d scrap machine %d interactiontype %d", machineid, sm_MachineScrapMachine[machineid], interactiontype);
		if(sm_Data[sm_MachineScrapMachine[machineid]][sm_machineId] == machineid)
		{
			_sm_PlayerUseScrapMachine(playerid, sm_MachineScrapMachine[machineid], interactiontype);
		}
		else
		{
			printf("ERROR: ScrapMachine bi-directional link error. sm_MachineScrapMachine sm_machineId = %d machineid = %d");
		}
	}

	#if defined sm_OnPlayerUseMachine
		return sm_OnPlayerUseMachine(playerid, machineid, interactiontype);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseMachine
	#undef OnPlayerUseMachine
#else
	#define _ALS_OnPlayerUseMachine
#endif
#define OnPlayerUseMachine sm_OnPlayerUseMachine
#if defined sm_OnPlayerUseMachine
	forward sm_OnPlayerUseMachine(playerid, machineid, interactiontype);
#endif

_sm_PlayerUseScrapMachine(playerid, scrapmachineid, interactiontype)
{
	d:1:HANDLER("[_sm_PlayerUseScrapMachine] playerid %d scrapmachineid %d interactiontype %d", playerid, scrapmachineid, interactiontype);

	if(sm_Data[scrapmachineid][sm_cooking])
	{
		ShowActionText(playerid, sprintf("The machine is currently cooking~n~%s left", MsToString(sm_Data[scrapmachineid][sm_cookTime] - GetTickCountDifference(GetTickCount(), sm_Data[scrapmachineid][sm_startTime]), "%m minutes %s seconds")), 8000);
		return 0;
	}

	if(interactiontype == 0)
	{
		DisplayContainerInventory(playerid, GetMachineContainerID(sm_Data[scrapmachineid][sm_machineId]));
		return 0;
	}
	else
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, listitem, inputtext

			if(response)
			{
				new ret = _sm_StartCooking(scrapmachineid);

				if(ret == 0)
					ShowActionText(playerid, "There are no items inside.", 5000);

				else if(ret == -1)
					ShowActionText(playerid, "The server is restarting soon, not enough time to cook.~n~Try putting less items inside to reduce cook time.", 6000);

				else
					ShowActionText(playerid, sprintf("Cook time: %s", MsToString(ret, "%m minutes %s seconds")), 6000);
			}
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Scrap Machine",
			"Press 'Start' to activate the scrap machine and convert certain types of items into scrap.\n\
			Items that cannot be turned into scrap metal will be destroyed.",
			"Start", "Cancel");
	}

	return 0;
}

_sm_StartCooking(scrapmachineid)
{
	d:1:HANDLER("[_sm_PlayerUseScrapMachine] scrapmachineid %d", scrapmachineid);
	new itemcount;

	for(new j = GetContainerSize(GetMachineContainerID(sm_Data[scrapmachineid][sm_machineId])); itemcount < j; itemcount++)
	{
		if(!IsContainerSlotUsed(GetMachineContainerID(sm_Data[scrapmachineid][sm_machineId]), itemcount))
			break;
	}

	if(itemcount == 0)
		return 0;

	// cook time = 90 seconds per item plus random 30 seconds
	new cooktime = (itemcount * 90) + random(30);
	d:2:HANDLER("[_sm_PlayerUseScrapMachine] itemcount %d cooktime %ds", itemcount, cooktime);

	// if there's not enough time left, don't allow a new cook to start.
	if(gServerUptime >= gServerMaxUptime - (cooktime * 1.5))
		return -1;

	new
		Float:x,
		Float:y,
		Float:z;

	GetMachinePos(sm_Data[scrapmachineid][sm_machineId], x, y, z);

	cooktime *= 1000; // convert to ms

	d:2:HANDLER("[_sm_PlayerUseScrapMachine] started cooking...");
	sm_Data[scrapmachineid][sm_cooking] = true;
	DestroyDynamicObject(sm_Data[scrapmachineid][sm_smoke]);
	sm_Data[scrapmachineid][sm_smoke] = CreateDynamicObject(18726, x, y, z - 1.0, 0.0, 0.0, 0.0);
	sm_Data[scrapmachineid][sm_cookTime] = cooktime;
	sm_Data[scrapmachineid][sm_startTime] = GetTickCount();

	defer _sm_FinishCooking(scrapmachineid, cooktime);

	return cooktime;
}

timer _sm_FinishCooking[cooktime](scrapmachineid, cooktime)
{
#pragma unused cooktime
	d:1:HANDLER("[_sm_PlayerUseScrapMachine] finished cooking...");
	new
		itemid,
		scrapcount;

	for(new i, j = GetContainerSize(GetMachineContainerID(sm_Data[scrapmachineid][sm_machineId])); i < j; i++)
	{
		itemid = GetContainerSlotItem(GetMachineContainerID(sm_Data[scrapmachineid][sm_machineId]), i);

		d:3:HANDLER("[_sm_PlayerUseScrapMachine] slot %d: destroying %d", i, itemid);

		if(!IsValidItem(itemid))
			break;

		scrapcount += sm_ItemTypeScrapValue[GetItemType(itemid)];

		DestroyItem(itemid);
	}

	scrapcount = scrapcount > MAX_SCRAP_MACHINE_ITEMS ? MAX_SCRAP_MACHINE_ITEMS : scrapcount;

	for(new i; i < scrapcount; i++)
	{
		itemid = CreateItem(item_ScrapMetal);
		AddItemToContainer(GetMachineContainerID(sm_Data[scrapmachineid][sm_machineId]), itemid);
		d:3:HANDLER("[_sm_PlayerUseScrapMachine] Created item %d and added to container %d", itemid, GetMachineContainerID(sm_Data[scrapmachineid][sm_machineId]));
	}

	DestroyDynamicObject(sm_Data[scrapmachineid][sm_smoke]);
	sm_Data[scrapmachineid][sm_cooking] = false;
	sm_Data[scrapmachineid][sm_smoke] = INVALID_OBJECT_ID;
}
