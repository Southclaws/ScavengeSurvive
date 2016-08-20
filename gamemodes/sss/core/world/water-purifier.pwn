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


#define MAX_WATER_MACHINE_FUEL		(15.0)
#define WATER_MACHINE_FUEL_USAGE	(3.0)
#define WATER_PURIFY_TIME			(30)


enum e_WATER_MACHINE_DATA
{
			wm_containerid,
Float:		wm_fuel,
bool:		wm_cooking,
			wm_smoke,
			wm_cookTime,
			wm_startTime,
			wm_selectedItem
}


static		wm_CurrentWaterMachine[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
			wm_ItemWaterPurifier[ITM_MAX] 		= {-1, ...};


static HANDLER = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	HANDLER = debug_register_handler("water-purifier", 6);
}

hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/world/water-purifier.pwn");

	wm_CurrentWaterMachine[playerid] = -1;
}

hook OnItemCreateInWorld(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemCreateInWorld] in /gamemodes/sss/core/world/water-purifier.pwn");

	if(GetItemType(itemid) == item_WaterMachine)
	{
		new data[e_WATER_MACHINE_DATA];

		GetItemArrayData(itemid, data);

		data[wm_smoke] 			= INVALID_OBJECT_ID;
		data[wm_selectedItem]	= INVALID_ITEM_ID;

		SetItemArrayData(itemid, data, _:e_WATER_MACHINE_DATA);
	}
}

/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerUseMachine(playerid, itemid, interactiontype)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseMachine] in /gamemodes/sss/core/world/water-purifier.pwn");

	if(GetItemType(itemid) == item_WaterMachine)
	{
		d:1:HANDLER("[OnPlayerUseMachine] itemid %d interactiontype %d", itemid, interactiontype);
		_wm_PlayerUseWaterMachine(playerid, itemid, interactiontype);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerPickUpItem] in /gamemodes/sss/core/world/water-purifier.pwn");

	if(wm_ItemWaterPurifier[itemid] != -1)
	{
		if(_wm_RemoveSelectedItem(itemid) == 0)
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_wm_PlayerUseWaterMachine(playerid, itemid, interactiontype)
{
	d:1:HANDLER("[_wm_PlayerUseWaterMachine] playerid %d itemid %d interactiontype %d", playerid, itemid, interactiontype);

	wm_CurrentWaterMachine[playerid] = itemid;

	new data[e_WATER_MACHINE_DATA];

	GetItemArrayData(itemid, data);

	if(data[wm_cooking])
	{
		ShowActionText(playerid, sprintf(ls(playerid, "MACHPROCESS", true), MsToString(data[wm_cookTime] - GetTickCountDifference(GetTickCount(), data[wm_startTime]), "%m minutes %s seconds")), 8000);
		return 0;
	}

	if(interactiontype == 0)
	{
		if(GetItemType(itemid) != item_Crowbar)
				if(data[wm_selectedItem] == INVALID_ITEM_ID)
					_wm_AddSelectedItem(playerid, data);

		return 0;
	}

	new 
		ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

	if(GetItemTypeLiquidContainerType(itemtype) != -1)
	{
		if(GetLiquidItemLiquidType(GetPlayerItem(playerid)) == liquid_Petrol)
		{
			d:1:HANDLER("[_wm_PlayerUseWaterMachine] starting HoldAction for %ds starting at %ds", floatround(MAX_WATER_MACHINE_FUEL), floatround(data[wm_fuel]));
			StartHoldAction(playerid, floatround(MAX_WATER_MACHINE_FUEL * 1000), floatround(data[wm_fuel] * 1000));
			return 0;
		}
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			new ret = _wm_StartCooking(itemid);

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
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Water Purifier", sprintf("Press 'Start' to activate the water purifier and purify and contaminated water.\n\n"C_GREEN"Fuel amount: "C_WHITE"%.1f", data[wm_fuel]), "Start", "Cancel");

	return 0;
}

_wm_AddSelectedItem(playerid, data[e_WATER_MACHINE_DATA])
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz,
		itemid = GetPlayerItem(playerid),
		ItemType:itemtype = GetItemType(itemid);

	if(GetItemTypeLiquidContainerType(itemtype) != -1)
	{
		if(GetLiquidItemLiquidType(itemid) == liquid_SaltWater)
		{
			data[wm_selectedItem] = itemid;
			SetItemArrayData(wm_CurrentWaterMachine[playerid], data, _:e_WATER_MACHINE_DATA);

			GetItemPos(wm_CurrentWaterMachine[playerid], x, y, z);
			GetItemRot(wm_CurrentWaterMachine[playerid], rx, ry, rz);
			CreateItemInWorld(itemid,
				x + (0.92358 * floatsin(- rz - 70.727416, degrees)),
				y + (0.92358 * floatcos(- rz - 70.727416, degrees)),
				z + 0.91,
				rx, ry, rz);

			wm_ItemWaterPurifier[itemid] = wm_CurrentWaterMachine[playerid];
		}
		else
			ShowActionText(playerid, ls(playerid, "PURWATERONLY", true), 5000);
	}

	return 1;
}

_wm_RemoveSelectedItem(itemid)
{
	new data[e_WATER_MACHINE_DATA];

	GetItemArrayData(wm_ItemWaterPurifier[itemid], data);

	if(data[wm_cooking])
		return 0;

	data[wm_selectedItem] = INVALID_ITEM_ID;

	SetItemArrayData(wm_ItemWaterPurifier[itemid], data, _:e_WATER_MACHINE_DATA);

	wm_ItemWaterPurifier[itemid] = -1;
	return 1;
}

hook OnHoldActionUpdate(playerid, progress)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionUpdate] in /gamemodes/sss/core/world/water-purifier.pwn");

	if(wm_CurrentWaterMachine[playerid] != -1)
	{
		d:3:HANDLER("[OnHoldActionUpdate] Water purifier itemid %d progress %d", wm_CurrentWaterMachine[playerid], progress);

		new itemid = GetPlayerItem(playerid);

		if(GetItemTypeLiquidContainerType(GetItemType(itemid)) != -1)
		{
			if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
			{
				d:3:HANDLER("[OnHoldActionUpdate] Stopping HoldAction: player not holding petrol can");
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
			d:3:HANDLER("[OnHoldActionUpdate] Stopping HoldAction: petrol can has %d < 0 fuel", fuel);
			StopHoldAction(playerid);
			wm_CurrentWaterMachine[playerid] = -1;
			HideActionText(playerid);
		}
		else
		{
			new Float:machinefuel = Float:GetItemArrayDataAtCell(wm_CurrentWaterMachine[playerid], wm_fuel);

			d:3:HANDLER("[OnHoldActionUpdate] setting petrol can to %f, machine to %f", fuel - 1.1, machinefuel + 1.1);
			transfer = (fuel - 1.1 < 0.0) ? fuel : 1.1;
			SetLiquidItemLiquidAmount(itemid, fuel - transfer);
			SetItemArrayDataAtCell(wm_CurrentWaterMachine[playerid], _:(machinefuel + 1.1), wm_fuel);
			ShowActionText(playerid, ls(playerid, "REFUELLING", true));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_wm_StartCooking(itemid)
{
	new data[e_WATER_MACHINE_DATA];

	GetItemArrayData(itemid, data);

	if(data[wm_selectedItem] == INVALID_ITEM_ID)
		return 0;

	// if there's not enough time left, don't allow a new cook to start.
	if(gServerUptime >= gServerMaxUptime - (WATER_PURIFY_TIME * 1.5))
		return -1;

	if(data[wm_fuel] < WATER_MACHINE_FUEL_USAGE)
		return -2;

	new
		Float:x,
		Float:y,
		Float:z,
		cooktime = WATER_PURIFY_TIME * 1000;

	GetItemPos(itemid, x, y, z);

	d:2:HANDLER("[_wm_PlayerUseWaterMachine] started cooking...");
	data[wm_cooking] = true;
	DestroyDynamicObject(data[wm_smoke]);
	data[wm_smoke] = CreateDynamicObject(18726, x, y, z + 0.25, 0.0, 0.0, 0.0);
	data[wm_cookTime] = cooktime;
	data[wm_startTime] = GetTickCount();

	SetItemArrayData(itemid, data, _:e_WATER_MACHINE_DATA);

	defer _wm_FinishCooking(itemid, cooktime);

	return cooktime;
}

timer _wm_FinishCooking[cooktime](itemid, cooktime)
{
	#pragma unused cooktime
	d:1:HANDLER("[_wm_PlayerUseWaterMachine] finished cooking...");
	new data[e_WATER_MACHINE_DATA];

	GetItemArrayData(itemid, data);

	SetLiquidItemLiquidType(data[wm_selectedItem], liquid_PurifiedWater);

	DestroyDynamicObject(data[wm_smoke]);
	data[wm_fuel]		-= WATER_MACHINE_FUEL_USAGE;
	data[wm_cooking] 	= false;
	data[wm_smoke] 		= INVALID_OBJECT_ID;

	SetItemArrayData(itemid, data, _:e_WATER_MACHINE_DATA);
}

/*CMD:liq(playerid, params[]) // Cmd to test the purifier
{
	new
		itemid,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	itemid = CreateItem(item_GasCan,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)),
		z - FLOOR_OFFSET, .rz = r);

	SetItemArrayDataAtCell(itemid, _:5.0, LIQUID_ITEM_ARRAY_CELL_AMOUNT);
	SetItemArrayDataAtCell(itemid, liquid_SaltWater, LIQUID_ITEM_ARRAY_CELL_TYPE);
	return 1;
}*/