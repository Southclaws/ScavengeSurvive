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

#define INVALID_FUEL_OUTLET_ID	(-1)
#define MAX_FUEL_LOCATIONS		(78)
#define FUEL_CAN_CAPACITY		(20)


enum E_FUEL_DATA
{
			fuel_state,
			fuel_buttonId,
Float:		fuel_capacity,
Float:		fuel_amount,
Float:		fuel_posX,
Float:		fuel_posY,
Float:		fuel_posZ
}


new
			fuel_Data[MAX_FUEL_LOCATIONS][E_FUEL_DATA],
			fuel_Total,
Timer:		fuel_RefuelTimer[MAX_PLAYERS],
			fuel_CurrentFuelOutlet[MAX_PLAYERS],
			fuel_CurrentlyRefuelling[MAX_PLAYERS],
			fuel_ButtonFuelOutlet[BTN_MAX] = {INVALID_FUEL_OUTLET_ID, ...};


hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/world/fuel.pwn");

	fuel_CurrentlyRefuelling[playerid] = INVALID_FUEL_OUTLET_ID;
}


stock CreateFuelOutlet(Float:x, Float:y, Float:z, Float:areasize, Float:capacity, Float:startamount)
{
	if(fuel_Total >= MAX_FUEL_LOCATIONS - 1)
	{
		print("ERROR: MAX_FUEL_LOCATIONS limit reached!");
		return -1;
	}

	fuel_Data[fuel_Total][fuel_buttonId]	= CreateButton(x, y, z + 0.5, "Fill petrol can", .label = true, .labeltext = "0.0", .areasize = areasize);

	fuel_Data[fuel_Total][fuel_state]		= 1;
	fuel_Data[fuel_Total][fuel_capacity]	= capacity;
	fuel_Data[fuel_Total][fuel_amount]		= startamount;

	fuel_Data[fuel_Total][fuel_posX]		= x;
	fuel_Data[fuel_Total][fuel_posY]		= y;
	fuel_Data[fuel_Total][fuel_posZ]		= z;

	fuel_ButtonFuelOutlet[fuel_Data[fuel_Total][fuel_buttonId]] = fuel_Total;

	UpdateFuelText(fuel_Total);

	return fuel_Total++;
}

hook OnPlayerUseItemWithBtn(playerid, buttonid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItemWithBtn] in /gamemodes/sss/core/world/fuel.pwn");

	if(GetItemType(itemid) != item_GasCan)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(fuel_ButtonFuelOutlet[buttonid] == INVALID_FUEL_OUTLET_ID)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(fuel_Data[fuel_ButtonFuelOutlet[buttonid]][fuel_buttonId] != buttonid)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(Float:GetItemExtraData(itemid) >= FUEL_CAN_CAPACITY)
	{
		ShowActionText(playerid, ls(playerid, "FUELCANFULL"), 3000);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	StartRefuellingFuelCan(playerid, fuel_ButtonFuelOutlet[buttonid]);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerRelBtnWithItem(playerid, buttonid, itemid)
{
	if(fuel_CurrentFuelOutlet[playerid] != INVALID_FUEL_OUTLET_ID)
	{
		StopRefuellingFuelCan(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

StartRefuellingFuelCan(playerid, outletid)
{
	if(!(0 <= outletid < fuel_Total))
	{
		printf("ERROR: [StartRefuellingFuelCan] invalid outletid: %d", outletid);
		return 0;
	}

	if(GetItemType(GetPlayerItem(playerid)) != item_GasCan)
	{
		ShowActionText(playerid, ls(playerid, "YOUNEEDFCAN"), 3000, 120);
		return 0;
	}

	if(fuel_Data[outletid][fuel_amount] <= 0.0)
	{
		ShowActionText(playerid, ls(playerid, "EMPTY"), 3000, 80);
		return 0;
	}

	CancelPlayerMovement(playerid);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, FUEL_CAN_CAPACITY);
	SetPlayerProgressBarValue(playerid, ActionBar, 0.0);
	ShowPlayerProgressBar(playerid, ActionBar);

	stop fuel_RefuelTimer[playerid];
	fuel_RefuelTimer[playerid] = repeat RefuelCanUpdate(playerid);
	fuel_CurrentFuelOutlet[playerid] = outletid;

	ApplyAnimation(playerid, "HEIST9", "USE_SWIPECARD", 4.0, 0, 0, 0, 0, 500);

	return 1;
}

StopRefuellingFuelCan(playerid)
{
	HidePlayerProgressBar(playerid, ActionBar);
	ClearAnimations(playerid);

	stop fuel_RefuelTimer[playerid];
	fuel_CurrentFuelOutlet[playerid] = INVALID_FUEL_OUTLET_ID;
}

timer RefuelCanUpdate[500](playerid)
{
	if(fuel_CurrentFuelOutlet[playerid] == INVALID_FUEL_OUTLET_ID)
	{
		StopRefuellingFuelCan(playerid);
		return;
	}

	new
		itemid = GetPlayerItem(playerid),
		Float:transfer,
		Float:amount,
		Float:px,
		Float:py,
		Float:pz;

	amount = Float:GetItemExtraData(itemid);

	if(amount >= FUEL_CAN_CAPACITY
	|| fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] <= 0.0
	|| GetItemType(itemid) != item_GasCan)
	{
		StopRefuellingFuelCan(playerid);
		return;
	}

	GetPlayerPos(playerid, px, py, pz);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_posX], fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_posY]));

	SetPlayerProgressBarValue(playerid, ActionBar, amount);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, FUEL_CAN_CAPACITY);
	ShowPlayerProgressBar(playerid, ActionBar);
	ApplyAnimation(playerid, "PED", "DRIVE_BOAT", 4.0, 1, 0, 0, 0, 0);

	transfer = (amount + 1.2 > 20.0) ? 20.0 - amount : 1.2;
	SetItemArrayDataAtCell(itemid, _:(amount + transfer), LIQUID_ITEM_ARRAY_CELL_AMOUNT);
	SetItemArrayDataAtCell(itemid, liquid_Petrol, LIQUID_ITEM_ARRAY_CELL_TYPE);
	fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] -= transfer;

	UpdateFuelText(fuel_CurrentFuelOutlet[playerid]);

	return;
}


StartRefuellingVehicle(playerid, vehicleid)
{
	new itemid = GetPlayerItem(playerid);

	if(GetItemType(itemid) != item_GasCan)
		return 0;

	if(GetItemArrayDataAtCell(itemid, LIQUID_ITEM_ARRAY_CELL_TYPE) != liquid_Petrol)
	{
		ShowActionText(playerid, ls(playerid, "FUELNOTPETR"), 3000);
		return 0;
	}

	CancelPlayerMovement(playerid);
	ApplyAnimation(playerid, "PED", "DRIVE_BOAT", 4.0, 1, 0, 0, 0, 0);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, GetVehicleTypeMaxFuel(GetVehicleType(vehicleid)));
	SetPlayerProgressBarValue(playerid, ActionBar, 0.0);
	ShowPlayerProgressBar(playerid, ActionBar);

	stop fuel_RefuelTimer[playerid];
	fuel_RefuelTimer[playerid] = repeat RefuelVehicleUpdate(playerid, vehicleid);
	fuel_CurrentlyRefuelling[playerid] = vehicleid;

	return 1;
}

StopRefuellingVehicle(playerid)
{
	stop fuel_RefuelTimer[playerid];

	if(!IsValidVehicle(fuel_CurrentlyRefuelling[playerid]))
		return 0;

	HidePlayerProgressBar(playerid, ActionBar);
	ClearAnimations(playerid);
	fuel_CurrentlyRefuelling[playerid] = INVALID_FUEL_OUTLET_ID;

	return 1;
}

timer RefuelVehicleUpdate[500](playerid, vehicleid)
{
	if(!IsValidVehicle(vehicleid))
	{
		StopRefuellingVehicle(playerid);
		return;
	}

	new
		itemid = GetPlayerItem(playerid),
		Float:canfuel,
		Float:transfer,
		Float:vehiclefuel,
		Float:px,
		Float:py,
		Float:pz,
		Float:vx,
		Float:vy,
		Float:vz;

	canfuel = Float:GetItemExtraData(itemid);
	vehiclefuel = GetVehicleFuel(vehicleid);

	if(vehiclefuel >= GetVehicleTypeMaxFuel(GetVehicleType(vehicleid))
	|| canfuel <= 0.0
	|| GetItemType(itemid) != item_GasCan
	|| !IsPlayerInVehicleArea(playerid, vehicleid))
	{
		StopRefuellingVehicle(playerid);
		return;
	}

	SetPlayerProgressBarValue(playerid, ActionBar, vehiclefuel);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, GetVehicleTypeMaxFuel(GetVehicleType(vehicleid)));
	ShowPlayerProgressBar(playerid, ActionBar);

	GetPlayerPos(playerid, px, py, pz);
	GetVehiclePos(vehicleid, vx, vy, vz);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, vx, vy));

	transfer = (canfuel - 0.8 < 0.0) ? canfuel : 0.8;
	SetItemArrayDataAtCell(itemid, _:(canfuel - transfer), LIQUID_ITEM_ARRAY_CELL_AMOUNT);
	SetVehicleFuel(vehicleid, vehiclefuel + transfer);

	return;
}

UpdateFuelText(outletid)
	return SetButtonLabel(fuel_Data[outletid][fuel_buttonId], sprintf("%.1f/%.1f", fuel_Data[outletid][fuel_amount], fuel_Data[outletid][fuel_capacity]));
