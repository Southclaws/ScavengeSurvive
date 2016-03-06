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


/*
	Anti "ninja-jack" (or anj)
*/


static
	anj_CurrentlyEntering[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};


hook OnPlayerConnect(playerid)
{
	anj_CurrentlyEntering[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(!ispassenger)
	{
		anj_CurrentlyEntering[playerid] = vehicleid;
		defer CurrentlyEnteringCheck(playerid);
	}

	return 1;
}

timer CurrentlyEnteringCheck[3000](playerid)
{
	if(!IsPlayerInAnyVehicle(playerid))
		anj_CurrentlyEntering[playerid] = INVALID_VEHICLE_ID;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
	{
		anj_CurrentlyEntering[playerid] = INVALID_VEHICLE_ID;
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 8 || newkeys & 32)
	{
		if(anj_CurrentlyEntering[playerid] != INVALID_VEHICLE_ID)
		{
			new
				targetid = INVALID_PLAYER_ID,
				Float:x,
				Float:y,
				Float:z,
				Float:a;

			GetVehiclePos(anj_CurrentlyEntering[playerid], x, y, z);
			GetVehicleZAngle(anj_CurrentlyEntering[playerid], a);

			foreach(new i : Player)
			{
				if(IsPlayerInVehicle(i, anj_CurrentlyEntering[playerid]) && GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
				{
					targetid = i;
					break;
				}
			}

			if(targetid != INVALID_PLAYER_ID)
			{
				RemovePlayerFromVehicle(targetid);
				SetPlayerPos(targetid, x + floatsin(-a + 90.0, degrees), y + floatcos(-a + 90.0, degrees), z);
			}

			anj_CurrentlyEntering[playerid] = INVALID_VEHICLE_ID;
		}
	}
	return 1;
}

stock IsPlayerBeingHijacked(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	foreach(new i : Player)
	{
		if(anj_CurrentlyEntering[i] == GetPlayerVehicleID(playerid))
			return 1;
	}

	return 0;
}
