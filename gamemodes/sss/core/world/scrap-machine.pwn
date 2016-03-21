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
#define MAX_SCRAP_MACHINE_ITEMS	(4)


enum E_SCRAP_MACHINE_DATA
{
			sm_objId,
			sm_buttonId,
			sm_containerId,
Text3D:		sm_labelId,
Float:		sm_posX,
Float:		sm_posY,
Float:		sm_posZ,
Float:		sm_rotZ,
bool:		sm_cooking,
			sm_smoke,
			sm_cookTime,
			sm_startTime
}


static
			sm_Data[MAX_SCRAP_MACHINE][E_SCRAP_MACHINE_DATA],
			sm_Total,

			sm_ItemTypeScrapValue[ITM_MAX_TYPES],
			sm_ButtonScrapMachine[BTN_MAX] = {-1, ...},

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

	sm_Data[sm_Total][sm_objId] = CreateDynamicObject(920, x, y, z, 0.0, 0.0, rz);
	sm_Data[sm_Total][sm_buttonId] = CreateButton(x, y, z, "Press "KEYTEXT_INTERACT" to use scrap machine", .areasize = 2.0);
	sm_Data[sm_Total][sm_containerId] = CreateContainer("Scrap Machine", 12);
	sm_Data[sm_Total][sm_labelId] = CreateDynamic3DTextLabel("Scrap Machine", GREEN, x, y, z + 1.0, 10.0);
	sm_Data[sm_Total][sm_posX] = x;
	sm_Data[sm_Total][sm_posY] = y;
	sm_Data[sm_Total][sm_posZ] = z;
	sm_Data[sm_Total][sm_rotZ] = rz;

	sm_ButtonScrapMachine[sm_Data[sm_Total][sm_buttonId]] = sm_Total;

	return sm_Total++;
}

stock SetItemScrapValue(ItemType:itemtype, value)
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


public OnButtonPress(playerid, buttonid)
{
	if(sm_ButtonScrapMachine[buttonid] != -1)
	{
		d:1:HANDLER("[OnButtonPress] button %d scrap machine %d", buttonid, sm_ButtonScrapMachine[buttonid]);
		if(sm_Data[sm_ButtonScrapMachine[buttonid]][sm_buttonId] == buttonid)
		{
			_sm_PlayerUseScrapMachine(playerid, sm_ButtonScrapMachine[buttonid]);
		}
		else
		{
			printf("ERROR: ScrapMachine bi-directional link error. sm_ButtonScrapMachine sm_buttonId = %d buttonid = %d");
		}
	}

	#if defined sm_OnButtonPress
		return sm_OnButtonPress(playerid, buttonid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress sm_OnButtonPress
#if defined sm_OnButtonPress
	forward sm_OnButtonPress(playerid, buttonid);
#endif

_sm_PlayerUseScrapMachine(playerid, scrapmachineid)
{
	d:1:HANDLER("[_sm_PlayerUseScrapMachine] playerid %d scrapmachineid %d", playerid, scrapmachineid);

	if(sm_Data[scrapmachineid][sm_cooking])
	{
		ShowActionText(playerid, sprintf("The machine is currently cooking~n~%s left", MsToString(sm_Data[scrapmachineid][sm_cookTime] - GetTickCountDifference(GetTickCount(), sm_Data[scrapmachineid][sm_startTime]), "%m minutes %s seconds")), 8000);
		return 0;
	}

	if(IsValidItem(GetPlayerItem(playerid)))
	{
		DisplayContainerInventory(playerid, sm_Data[scrapmachineid][sm_containerId]);
		return 0;
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			new ret = _sm_StartCooking(scrapmachineid);

			if(ret == 0)
				ShowActionText(playerid, "There are no items inside.~n~Interact while holding an item to put it inside.", 8000);

			else if(ret == -1)
				ShowActionText(playerid, "The machine can't finish before the next server restart.", 6000);

			else
				ShowActionText(playerid, sprintf("Cook time: %s", MsToString(ret, "%m minutes %s seconds")), 6000);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Scrap Machine", "Press 'Start' to activate the scrap machine and convert certain types of items into scrap. Items that cannot be turned into scrap metal will be destroyed.", "Start", "Cancel");

	return 0;
}

_sm_StartCooking(scrapmachineid)
{
	d:1:HANDLER("[_sm_PlayerUseScrapMachine] scrapmachineid %d", scrapmachineid);
	new
		itemcount,
		cooktime;

	for(new j = GetContainerSize(sm_Data[scrapmachineid][sm_containerId]); itemcount < j; itemcount++)
	{
		if(!IsContainerSlotUsed(sm_Data[scrapmachineid][sm_containerId], itemcount))
			break;
	}

	if(itemcount == 0)
		return 0;

	// cook time = 90 seconds per item plus random 30 seconds
	cooktime = (itemcount * 90) + random(30);
	d:2:HANDLER("[_sm_PlayerUseScrapMachine] itemcount %d cooktime %ds", itemcount, cooktime);

	// if there's not enough time left, don't allow a new cook to start.
	if(gServerUptime >= gServerMaxUptime - (cooktime * 1.5))
		return -1;

	cooktime *= 1000; // convert to ms

	d:2:HANDLER("[_sm_PlayerUseScrapMachine] started cooking...");
	sm_Data[scrapmachineid][sm_cooking] = true;
	DestroyDynamicObject(sm_Data[scrapmachineid][sm_smoke]);
	sm_Data[scrapmachineid][sm_smoke] = CreateDynamicObject(18726, sm_Data[scrapmachineid][sm_posX], sm_Data[scrapmachineid][sm_posY], sm_Data[scrapmachineid][sm_posZ], 0.0, 0.0, sm_Data[scrapmachineid][sm_rotZ] - 1.0);
	sm_Data[scrapmachineid][sm_cookTime] = cooktime;
	sm_Data[scrapmachineid][sm_startTime] = GetTickCount();

	defer _sm_FinishCooking(scrapmachineid, cooktime);

	return cooktime;
}

timer _sm_FinishCooking[cooktime](scrapmachineid, cooktime)
{
#pragma unused cooktime
	d:1:HANDLER("[_sm_PlayerUseScrapMachine] finished cooking...");
	new itemid;

	for(new i, j = GetContainerSize(sm_Data[scrapmachineid][sm_containerId]); i < j; i++)
	{
		itemid = GetContainerSlotItem(sm_Data[scrapmachineid][sm_containerId], i);

		d:3:HANDLER("[_sm_PlayerUseScrapMachine] slot %d: destroying %d", i, itemid);

		if(!IsValidItem(itemid))
			break;

		DestroyItem(itemid);
		itemid = CreateItem(item_ScrapMetal);
		AddItemToContainer(sm_Data[scrapmachineid][sm_containerId], itemid);
		d:3:HANDLER("[_sm_PlayerUseScrapMachine] Created item %d and added to container %d", itemid, sm_Data[scrapmachineid][sm_containerId]);
	}

	DestroyDynamicObject(sm_Data[scrapmachineid][sm_smoke]);
	sm_Data[scrapmachineid][sm_cooking] = false;
	sm_Data[scrapmachineid][sm_smoke] = INVALID_OBJECT_ID;
}
