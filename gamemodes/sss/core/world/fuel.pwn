/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>

#define INVALID_FUEL_OUTLET_ID	(-1)
#define MAX_FUEL_LOCATIONS		(86)


enum E_FUEL_DATA
{
			fuel_state,
Button:		fuel_buttonId,
Float:		fuel_capacity,
Float:		fuel_amount,
Float:		fuel_posX,
Float:		fuel_posY,
Float:		fuel_posZ
}


new
			fuel_Data[MAX_FUEL_LOCATIONS][E_FUEL_DATA],
			fuel_Total,
			fuel_CurrentFuelOutlet[MAX_PLAYERS],
			fuel_CurrentlyRefuelling[MAX_PLAYERS],
			fuel_ButtonFuelOutlet[BTN_MAX] = {INVALID_FUEL_OUTLET_ID, ...};


hook OnPlayerConnect(playerid)
{
	fuel_CurrentlyRefuelling[playerid] = INVALID_VEHICLE_ID;
}


stock CreateFuelOutlet(Float:x, Float:y, Float:z, Float:areasize, Float:capacity, Float:startamount)
{
	if(fuel_Total >= MAX_FUEL_LOCATIONS - 1)
	{
		err("MAX_FUEL_LOCATIONS limit reached!");
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

hook OnPlayerUseItemWithBtn(playerid, Button:buttonid, Item:itemid)
{
	if(fuel_ButtonFuelOutlet[buttonid] == INVALID_FUEL_OUTLET_ID)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(fuel_Data[fuel_ButtonFuelOutlet[buttonid]][fuel_buttonId] != buttonid)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new liqcont = GetItemTypeLiquidContainerType(GetItemType(itemid));

	if(liqcont == -1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetLiquidItemLiquidAmount(itemid) >= GetLiquidContainerTypeCapacity(liqcont))
	{
		ShowActionText(playerid, ls(playerid, "FUELCANFULL", true), 3000);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	StartRefuellingFuelCan(playerid, fuel_ButtonFuelOutlet[buttonid]);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerRelBtnWithItem(playerid, Button:buttonid, Item:itemid)
{
	if(fuel_CurrentFuelOutlet[playerid] != INVALID_FUEL_OUTLET_ID)
	{
		StopRefuellingFuelCan(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
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
		err("[StartRefuellingFuelCan] invalid outletid: %d", outletid);
		return 0;
	}

	new liqcont = GetItemTypeLiquidContainerType(GetItemType(GetPlayerItem(playerid)));

	if(liqcont == -1)
	{
		ShowActionText(playerid, ls(playerid, "YOUNEEDFCAN", true), 3000, 120);
		return 0;
	}

	if(fuel_Data[outletid][fuel_amount] <= 0.0)
	{
		ShowActionText(playerid, ls(playerid, "EMPTY", true), 3000, 80);
		return 0;
	}

	CancelPlayerMovement(playerid);
	StartHoldAction(playerid, floatround(GetLiquidContainerTypeCapacity(liqcont) * 1000), floatround(GetLiquidItemLiquidAmount(GetPlayerItem(playerid)) * 1000));
	fuel_CurrentFuelOutlet[playerid] = outletid;

	ApplyAnimation(playerid, "HEIST9", "USE_SWIPECARD", 4.0, 0, 0, 0, 0, 500);

	return 1;
}

StopRefuellingFuelCan(playerid)
{
	if(!(0 <= fuel_CurrentFuelOutlet[playerid] < fuel_Total))
		return 0;

	HidePlayerProgressBar(playerid, ActionBar);
	ClearAnimations(playerid);

	StopHoldAction(playerid);
	fuel_CurrentFuelOutlet[playerid] = INVALID_FUEL_OUTLET_ID;

	return 1;
}

StartRefuellingVehicle(playerid, vehicleid)
{
	new Item:itemid = GetPlayerItem(playerid);

	if(GetItemTypeLiquidContainerType(GetItemType(itemid)) == -1)
		return 0;

	if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
	{
		ShowActionText(playerid, ls(playerid, "FUELNOTPETR", true), 3000);
		return 0;
	}

	if(GetLiquidItemLiquidAmount(itemid) <= 0.0)
	{
		ShowActionText(playerid, ls(playerid, "EMPTY", true), 3000);
		return 0;
	}

	CancelPlayerMovement(playerid);
	ApplyAnimation(playerid, "PED", "DRIVE_BOAT", 4.0, 1, 0, 0, 0, 0);
	StartHoldAction(playerid, floatround(GetVehicleTypeMaxFuel(GetVehicleType(vehicleid)) * 1000), floatround(GetVehicleFuel(vehicleid) * 1000));
	fuel_CurrentlyRefuelling[playerid] = vehicleid;

	return 1;
}

StopRefuellingVehicle(playerid)
{
	if(!IsValidVehicle(fuel_CurrentlyRefuelling[playerid]))
		return 0;

	StopHoldAction(playerid);
	ClearAnimations(playerid);

	fuel_CurrentlyRefuelling[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

hook OnHoldActionUpdate(playerid, progress)
{
	if(IsValidVehicle(fuel_CurrentlyRefuelling[playerid]))
	{
		new
			Item:itemid = GetPlayerItem(playerid),
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
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		canfuel = GetLiquidItemLiquidAmount(itemid);
		vehiclefuel = GetVehicleFuel(fuel_CurrentlyRefuelling[playerid]);

		if(canfuel <= 0.0)
		{
			ShowActionText(playerid, ls(playerid, "EMPTY", true), 3000, 80);
			StopRefuellingVehicle(playerid);
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		if(vehiclefuel >= GetVehicleTypeMaxFuel(GetVehicleType(fuel_CurrentlyRefuelling[playerid])) || !IsPlayerInVehicleArea(playerid, fuel_CurrentlyRefuelling[playerid]))
		{
			StopRefuellingVehicle(playerid);
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		// Override the HoldAction setters
		SetPlayerProgressBarValue(playerid, ActionBar, vehiclefuel * 1000);
		SetPlayerProgressBarMaxValue(playerid, ActionBar, GetVehicleTypeMaxFuel(GetVehicleType(fuel_CurrentlyRefuelling[playerid])) * 1000);
		ShowPlayerProgressBar(playerid, ActionBar);

		GetPlayerPos(playerid, px, py, pz);
		GetVehiclePos(fuel_CurrentlyRefuelling[playerid], vx, vy, vz);
		SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, vx, vy));

		transfer = (canfuel - 0.8 < 0.0) ? canfuel : 0.8;
		SetLiquidItemLiquidAmount(itemid, canfuel - transfer);
		SetVehicleFuel(fuel_CurrentlyRefuelling[playerid], vehiclefuel + transfer);
	}
	else if(fuel_CurrentFuelOutlet[playerid] != INVALID_FUEL_OUTLET_ID)
	{
		new
			Item:itemid,
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
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		amount = GetLiquidItemLiquidAmount(itemid);
		capacity = GetLiquidContainerTypeCapacity(liqcont);

		if(amount >= capacity || fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] <= 0.0)
		{
			StopRefuellingFuelCan(playerid);
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		GetPlayerPos(playerid, px, py, pz);
		SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_posX], fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_posY]));

		// Override the HoldAction setters
		SetPlayerProgressBarValue(playerid, ActionBar, amount * 1000);
		SetPlayerProgressBarMaxValue(playerid, ActionBar, capacity * 1000);
		ShowPlayerProgressBar(playerid, ActionBar);
		ApplyAnimation(playerid, "PED", "DRIVE_BOAT", 4.0, 1, 0, 0, 0, 0);

		transfer = (amount + 1.2 > capacity) ? capacity - amount : 1.2;
		SetLiquidItemLiquidAmount(itemid, amount + transfer);
		SetLiquidItemLiquidType(itemid, liquid_Petrol);
		fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] -= transfer;

		UpdateFuelText(fuel_CurrentFuelOutlet[playerid]);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDrink(playerid, Item:itemid)
{
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
