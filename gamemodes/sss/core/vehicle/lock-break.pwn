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


static
	cro_TargetVehicle[MAX_PLAYERS],
	cro_OpenType[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/vehicle/lock-break.pwn");

	cro_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	d:3:GLOBAL_DEBUG("[OnPlayerInteractVehicle] in /gamemodes/sss/core/vehicle/lock-break.pwn");

	if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
	{
		if(IsVehicleLocked(vehicleid))
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(225.0 < angle < 315.0)
		{
			if(StartBreakingVehicleLock(playerid, vehicleid, 0))
				return Y_HOOKS_BREAK_RETURN_1;
		}

		if(155.0 < angle < 205.0)
		{
			if(StartBreakingVehicleLock(playerid, vehicleid, 1))
				return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/vehicle/lock-break.pwn");

	if(oldkeys & 16)
	{
		StopBreakingVehicleLock(playerid);
	}
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

		cro_OpenType[playerid] = 0;
	}
	if(type == 1)
	{
		if(!IsVehicleTrunkLocked(vehicleid))
			return 0;

		cro_OpenType[playerid] = 1;
	}

	cro_TargetVehicle[playerid] = vehicleid;
	ApplyAnimation(playerid, "POLICE", "DOOR_KICK", 3.0, 1, 1, 1, 0, 0);

	StartHoldAction(playerid, 3000);

	return 1;
}

StopBreakingVehicleLock(playerid)
{
	if(cro_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	ClearAnimations(playerid);
	StopHoldAction(playerid);

	cro_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

public OnHoldActionUpdate(playerid, progress)
{
	if(cro_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(!IsValidVehicle(cro_TargetVehicle[playerid]) || GetItemType(GetPlayerItem(playerid)) != item_Crowbar || !IsPlayerInVehicleArea(playerid, cro_TargetVehicle[playerid]))
		{
			StopBreakingVehicleLock(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		SetPlayerToFaceVehicle(playerid, cro_TargetVehicle[playerid]);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionFinish] in /gamemodes/sss/core/vehicle/lock-break.pwn");

	if(cro_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(cro_OpenType[playerid] == 0)
		{
			VehicleDoorsState(cro_TargetVehicle[playerid], 0);
		}
		if(cro_OpenType[playerid] == 1)
		{
			SetVehicleTrunkLock(cro_TargetVehicle[playerid], 0);
		}

		StopBreakingVehicleLock(playerid);			

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}
