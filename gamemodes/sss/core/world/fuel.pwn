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
#define MAX_FUEL_LOCATIONS		(86)


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

	fuel_CurrentlyRefuelling[playerid] = INVALID_VEHICLE_ID;
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

	if(fuel_ButtonFuelOutlet[buttonid] == INVALID_FUEL_OUTLET_ID)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(fuel_Data[fuel_ButtonFuelOutlet[buttonid]][fuel_buttonId] != buttonid)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new liqcont = GetItemTypeLiquidContainerType(GetItemType(itemid));

	if(liqcont == -1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetLiquidItemLiquidAmount(itemid) >= GetLiquidContainerTypeCapacity(liqcont))
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

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	d:3:GLOBAL_DEBUG("[OnPlayerInteractVehicle] in /gamemodes/sss/core/vehicle/repair.pwn");

	if(angle < 25.0 || angle > 335.0)
	{
		new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));
		
		if(GetItemTypeLiquidContainerType(itemtype) != -1)
			StartRefuellingVehicle(playerid, vehicleid);
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

	new liqcont = GetItemTypeLiquidContainerType(GetItemType(GetPlayerItem(playerid)));

	if(liqcont == -1)
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
	SetPlayerProgressBarMaxValue(playerid, ActionBar, GetLiquidContainerTypeCapacity(liqcont));
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
		itemid,
		liqcont,
		Float:transfer,
		Float:amount,
		Float:capacity,
		Float:px,
		Float:py,
		Float:pz;

	itemid = GetPlayerItem(playerid);
	liqcont = GetItemTypeLiquidContainerType(GetItemType(itemid));

	if(liqcont == -1)
	{
		StopRefuellingFuelCan(playerid);
		return;
	}

	amount = GetLiquidItemLiquidAmount(itemid);
	capacity = GetLiquidContainerTypeCapacity(liqcont);

	if(amount >= capacity || fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] <= 0.0)
	{
		StopRefuellingFuelCan(playerid);
		return;
	}

	GetPlayerPos(playerid, px, py, pz);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_posX], fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_posY]));

	SetPlayerProgressBarValue(playerid, ActionBar, amount);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, capacity);
	ShowPlayerProgressBar(playerid, ActionBar);
	ApplyAnimation(playerid, "PED", "DRIVE_BOAT", 4.0, 1, 0, 0, 0, 0);

	transfer = (amount + 1.2 > capacity) ? capacity - amount : 1.2;
	SetLiquidItemLiquidAmount(itemid, amount + transfer);
	SetLiquidItemLiquidType(itemid, liquid_Petrol);
	fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] -= transfer;

	UpdateFuelText(fuel_CurrentFuelOutlet[playerid]);

	return;
}


StartRefuellingVehicle(playerid, vehicleid)
{
	new itemid = GetPlayerItem(playerid);

	if(GetItemTypeLiquidContainerType(GetItemType(itemid)) == -1)
		return 0;

	if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
	{
		ShowActionText(playerid, ls(playerid, "FUELNOTPETR"), 3000);
		return 0;
	}

	if(GetLiquidItemLiquidAmount(itemid) <= 0.0)
	{
		ShowActionText(playerid, ls(playerid, "EMPTY"), 3000);
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
	fuel_CurrentlyRefuelling[playerid] = INVALID_VEHICLE_ID;

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

	if(GetItemTypeLiquidContainerType(GetItemType(itemid)) == -1)
	{
		StopRefuellingVehicle(playerid);
		return;
	}

	canfuel = GetLiquidItemLiquidAmount(itemid);
	vehiclefuel = GetVehicleFuel(vehicleid);

	if(canfuel <= 0.0)
	{
		ShowActionText(playerid, ls(playerid, "EMPTY"), 3000, 80);
		StopRefuellingVehicle(playerid);
		return;
	}

	if(vehiclefuel >= GetVehicleTypeMaxFuel(GetVehicleType(vehicleid)) || !IsPlayerInVehicleArea(playerid, vehicleid))
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
	SetLiquidItemLiquidAmount(itemid, canfuel - transfer);
	SetVehicleFuel(vehicleid, vehiclefuel + transfer);

	return;
}

hook OnPlayerDrink(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDrink] in /gamemodes/sss/core/world/fuel.pwn");

	if(IsValidVehicle(fuel_CurrentlyRefuelling[playerid]))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleBonnet(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

UpdateFuelText(outletid)
{
	return SetButtonLabel(fuel_Data[outletid][fuel_buttonId], sprintf("%.1f/%.1f", fuel_Data[outletid][fuel_amount], fuel_Data[outletid][fuel_capacity]));
}
