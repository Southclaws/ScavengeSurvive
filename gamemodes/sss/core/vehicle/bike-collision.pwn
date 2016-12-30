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
	CollisionVehicle[MAX_PLAYERS],
	CollisionObject[MAX_PLAYERS];


hook OnPlayerDisconnect(playerid)
{
	dbg("global", CORE, "[OnPlayerDisconnect] in /gamemodes/sss/core/vehicle/bike-collision.pwn");

	CollisionVehicle[playerid] = INVALID_VEHICLE_ID;
	DestroyObject(CollisionObject[playerid]);
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	dbg("global", CORE, "[OnPlayerStateChange] in /gamemodes/sss/core/vehicle/bike-collision.pwn");

	if(newstate == PLAYER_STATE_DRIVER)
	{
		new
			vehicleid,
			vehicletypecategory;

		vehicleid = GetPlayerVehicleID(playerid);
		vehicletypecategory = GetVehicleTypeCategory(GetVehicleType(vehicleid));

		if(vehicletypecategory == VEHICLE_CATEGORY_PUSHBIKE || vehicletypecategory == VEHICLE_CATEGORY_MOTORBIKE)
		{
			CollisionVehicle[playerid] = vehicleid;
			CollisionObject[playerid] = CreateObject(0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0);
			AttachObjectToVehicle(CollisionObject[playerid], CollisionVehicle[playerid], 0.0, 0.6, 1.2, 0.0, 0.0, 0.0);
		}

		return 1;
	}

	if(oldstate == PLAYER_STATE_DRIVER)
	{
		if(CollisionVehicle[playerid] != INVALID_VEHICLE_ID)
		{
			new vehicletypecategory = GetVehicleTypeCategory(GetVehicleType(CollisionVehicle[playerid]));

			if(vehicletypecategory == VEHICLE_CATEGORY_PUSHBIKE || vehicletypecategory == VEHICLE_CATEGORY_MOTORBIKE)
			{
				DestroyObject(CollisionObject[playerid]);
				CollisionVehicle[playerid] = INVALID_VEHICLE_ID;
				CollisionObject[playerid] = INVALID_OBJECT_ID;
			}
		}

		return 1;
	}

	return 1;
}
