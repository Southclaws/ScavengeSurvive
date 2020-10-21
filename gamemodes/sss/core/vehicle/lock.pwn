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


#include <YSI_Coding\y_hooks>


enum E_LOCK_STATE
{
	E_LOCK_STATE_OPEN,		// 0 Vehicle is enterable
	E_LOCK_STATE_EXTERNAL,	// 1 Installed lock, cannot be broken with crowbar
	E_LOCK_STATE_DEFAULT	// 2 Default manufacturer's lock, broken with crowbar
}

static
E_LOCK_STATE:	lock_Status				[MAX_VEHICLES],
				lock_LastChange			[MAX_VEHICLES],
				lock_DisableForPlayer	[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Key"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Key"), 2);
}

hook OnVehicleCreated(vehicleid)
{
	lock_Status[vehicleid] = E_LOCK_STATE_OPEN;
	lock_LastChange[vehicleid] = 0;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnVehicleReset(oldid, newid)
{
	lock_Status[newid] = lock_Status[oldid];
}

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

	if(newkeys & 16)
	{
		new vehicleid = GetPlayerVehicleArea(playerid);

		if(IsValidVehicle(vehicleid))
		{
			if(!IsPlayerInVehicle(playerid, vehicleid))
			{
				if(lock_Status[vehicleid] == E_LOCK_STATE_DEFAULT)
					ShowActionText(playerid, ls(playerid, "LOCKUSECROW"), 6000);

				else if(lock_Status[vehicleid] == E_LOCK_STATE_EXTERNAL)
					ShowActionText(playerid, ls(playerid, "LOCKCUSTOML"), 6000);
			}
		}
	}

	return 1;
}

_HandleLockKey(playerid)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(lock_Status[vehicleid] == E_LOCK_STATE_OPEN)
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_DEFAULT);

	else
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(lock_Status[vehicleid] != E_LOCK_STATE_OPEN)
	{
		CancelPlayerMovement(playerid);
		ShowActionText(playerid, ls(playerid, "DOORLOCKED", true), 3000);
	}

	return 1;
}

hook OnPlayerEnterVehArea(playerid, vehicleid)
{
	if(lock_Status[vehicleid] == E_LOCK_STATE_OPEN && !lock_DisableForPlayer[playerid] && !IsVehicleDead(vehicleid))
	{
		SetVehicleParamsForPlayer(vehicleid, playerid, 0, 0);
	}
	else
	{
		SetVehicleParamsForPlayer(vehicleid, playerid, 0, 1);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLeaveVehArea(playerid, vehicleid)
{
	SetVehicleParamsForPlayer(vehicleid, playerid, 0, 1);

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Interface

==============================================================================*/


stock E_LOCK_STATE:GetVehicleLockState(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return E_LOCK_STATE_OPEN;

	return lock_Status[vehicleid];
}

stock SetVehicleExternalLock(vehicleid, E_LOCK_STATE:status)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	if(IsVehicleDead(vehicleid))
	{
		lock_Status[vehicleid] = E_LOCK_STATE_EXTERNAL;
		VehicleDoorsState(vehicleid, true);
		return 1;
	}

	lock_LastChange[vehicleid] = GetTickCount();

	lock_Status[vehicleid] = status;

	if(status == E_LOCK_STATE_OPEN)
		VehicleDoorsState(vehicleid, false);

	else
		VehicleDoorsState(vehicleid, true);

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

	lock_DisableForPlayer[playerid] = !toggle;

	return 1;
}
