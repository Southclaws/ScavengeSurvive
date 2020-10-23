/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 "Southclaws" Keene

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


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return 1;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(GetVehicleModel(vehicleid) != 525)
		return 1;

	if(newkeys == KEY_ACTION)
	{
		new
			Float:vx1,
			Float:vy1,
			Float:vz1,
			Float:vx2,
			Float:vy2,
			Float:vz2;

		GetVehiclePos(vehicleid, vx1, vy1, vz1);

		foreach(new i : veh_Index)
		{
			if(i == vehicleid)
				continue;

			GetVehiclePos(i, vx2, vy2, vz2);

			if(Distance(vx1, vy1, vz1, vx2, vy2, vz2) < 7.0)
			{
				if(IsTrailerAttachedToVehicle(vehicleid))
					DetachTrailerFromVehicle(vehicleid);

				AttachTrailerToVehicle(i, vehicleid);

				break;
			}
		}
	}

	return 1;
}
