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
	lock_Status				[MAX_VEHICLES],
	lock_LastChange			[MAX_VEHICLES],
	lock_DisableForPlayer	[MAX_PLAYERS];


public OnVehicleCreated(vehicleid)
{
	lock_Status[vehicleid] = 0;
	lock_LastChange[vehicleid] = 0;

	#if defined lock_OnVehicleCreated
		return lock_OnVehicleCreated(vehicleid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnVehicleCreated
	#undef OnVehicleCreated
#else
	#define _ALS_OnVehicleCreated
#endif
 
#define OnVehicleCreated lock_OnVehicleCreated
#if defined lock_OnVehicleCreated
	forward lock_OnVehicleCreated(vehicleid);
#endif

hook OnPlayerConnect(playerid)
{
	lock_DisableForPlayer[playerid] = false;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_SUBMISSION)
	{
		if(IsPlayerInAnyVehicle(playerid))
			_HandleLockKey(playerid);
	}

	return 1;
}

_HandleLockKey(playerid)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(VehicleDoorsState(vehicleid))
		SetVehicleExternalLock(vehicleid, false);

	else
		SetVehicleExternalLock(vehicleid, true);

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(lock_Status[vehicleid])
	{
		CancelPlayerMovement(playerid);
		ShowActionText(playerid, "Door Locked", 3000);
	}

	return 1;
}

public OnPlayerEnterVehicleArea(playerid, vehicleid)
{
	if(!lock_Status[vehicleid] && !lock_DisableForPlayer[playerid])
	{
		SetVehicleParamsForPlayer(vehicleid, playerid, 0, 0);
	}
	else
	{
		SetVehicleParamsForPlayer(vehicleid, playerid, 0, 1);
	}

	#if defined lock_OnPlayerEnterVehicleArea
		return lock_OnPlayerEnterVehicleArea(playerid, vehicleid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterVehicleArea
	#undef OnPlayerEnterVehicleArea
#else
	#define _ALS_OnPlayerEnterVehicleArea
#endif
#define OnPlayerEnterVehicleArea lock_OnPlayerEnterVehicleArea
#if defined lock_OnPlayerEnterVehicleArea
	forward lock_OnPlayerEnterVehicleArea(playerid, vehicleid);
#endif

public OnPlayerLeaveVehicleArea(playerid, vehicleid)
{
	SetVehicleParamsForPlayer(vehicleid, playerid, 0, 1);

	#if defined lock_OnPlayerLeaveVehicleArea
		return lock_OnPlayerLeaveVehicleArea(playerid, vehicleid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLeaveVehicleArea
	#undef OnPlayerLeaveVehicleArea
#else
	#define _ALS_OnPlayerLeaveVehicleArea
#endif
#define OnPlayerLeaveVehicleArea lock_OnPlayerLeaveVehicleArea
#if defined lock_OnPlayerLeaveVehicleArea
	forward lock_OnPlayerLeaveVehicleArea(playerid, vehicleid);
#endif


/*==============================================================================

	Interface

==============================================================================*/


stock IsVehicleLocked(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return -1;

	return lock_Status[vehicleid];
}

stock SetVehicleExternalLock(vehicleid, status)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	if(IsVehicleDead(vehicleid))
	{
		lock_Status[vehicleid] = true;
		VehicleDoorsState(vehicleid, true);
		return 1;
	}

	lock_LastChange[vehicleid] = GetTickCount();

	lock_Status[vehicleid] = status;
	VehicleDoorsState(vehicleid, status);

	return 1;
}

stock GetVehicleLockTick(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return lock_LastChange[vehicleid];
}

stock TogglePlayerVehicleEntry(playerid, bool:toggle)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	lock_DisableForPlayer[playerid] = toggle;

	return 1;
}
