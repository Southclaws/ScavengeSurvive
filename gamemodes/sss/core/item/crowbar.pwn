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


new
	cbr_TargetVehicle[MAX_PLAYERS],
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
			return 1;
		}

		SetPlayerToFaceVehicle(playerid, cbr_TargetVehicle[playerid]);

		return 1;
	}

	#if defined crow_OnHoldActionUpdate
		return crow_OnHoldActionUpdate(playerid, progress);
	#else
		return 0;
	#endif
}

public OnHoldActionFinish(playerid)
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

		return 1;
	}

	#if defined crow_OnHoldActionFinish
		return crow_OnHoldActionFinish(playerid);
	#else
		return 0;
	#endif
}


// Hooks


#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate crow_OnHoldActionUpdate
#if defined crow_OnHoldActionUpdate
	forward crow_OnHoldActionUpdate(playerid, progress);
#endif


#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish crow_OnHoldActionFinish
#if defined crow_OnHoldActionFinish
	forward crow_OnHoldActionFinish(playerid);
#endif
