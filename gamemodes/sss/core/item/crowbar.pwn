/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


new
	cbr_TargetVehicle[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...},
	cbr_OpenType[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	cbr_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}

StartBreakingVehicleLock(playerid, vehicleid, type)
{
	new
		engine,
		lights,
		alarm,
		doors,
		bonnet,
		boot,
		objective;

	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

	if(type == 0)
	{
		if(doors == 0)
			return 0;

		cbr_OpenType[playerid] = 0;
	}
	if(type == 1)
	{
		if(IsVehicleTrunkLocked(vehicleid) == 0)
			return 0;

		cbr_OpenType[playerid] = 1;
	}

	cbr_TargetVehicle[playerid] = vehicleid;
	ApplyAnimation(playerid, "POLICE", "DOOR_KICK", 3.0, 1, 1, 1, 0, 0);

	StartHoldAction(playerid, 3000);

	return 1;
}

StopBreakingVehicleLock(playerid)
{
	if(cbr_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	ClearAnimations(playerid);
	StopHoldAction(playerid);

	cbr_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

public OnHoldActionUpdate(playerid, progress)
{
	if(cbr_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(!IsValidVehicle(cbr_TargetVehicle[playerid]) || GetItemType(GetPlayerItem(playerid)) != item_Crowbar || !IsPlayerInVehicleArea(playerid, cbr_TargetVehicle[playerid]))
		{
			StopBreakingVehicleLock(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		SetPlayerToFaceVehicle(playerid, cbr_TargetVehicle[playerid]);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(cbr_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(cbr_OpenType[playerid] == 0)
		{
			VehicleDoorsState(cbr_TargetVehicle[playerid], 0);
		}
		if(cbr_OpenType[playerid] == 1)
		{
			SetVehicleTrunkLock(cbr_TargetVehicle[playerid], 0);
		}

		StopBreakingVehicleLock(playerid);			

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
