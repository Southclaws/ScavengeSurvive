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
	gCurrentWheelFixVehicle[MAX_PLAYERS],
	gTireData[MAX_PLAYERS][4];


ShowTireList(playerid, vehicleid)
{
	new
		vehicletype = GetVehicleType(vehicleid),
		panels,
		doors,
		lights,
		tires,
		str[22 * 4];

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	if(GetVehicleTypeCategory(vehicletype) == VEHICLE_CATEGORY_MOTORBIKE && GetVehicleTypeModel(vehicletype) != 471)
	{
		gTireData[playerid][0] = tires & 0b0001;
		gTireData[playerid][1] = tires & 0b0010;

		if(gTireData[playerid][0]) // back
			strcat(str, "{FF0000}Back\n");

		else
			strcat(str, "{FFFFFF}Back\n");


		if(gTireData[playerid][1]) // front
			strcat(str, "{FF0000}Front\n");

		else
			strcat(str, "{FFFFFF}Front\n");
	}
	else
	{
		gTireData[playerid][0] = tires & 0b0001;
		gTireData[playerid][1] = tires & 0b0010;
		gTireData[playerid][2] = tires & 0b0100;
		gTireData[playerid][3] = tires & 0b1000;

		if(gTireData[playerid][0]) // backright
			strcat(str, "{FF0000}Back Right\n");

		else
			strcat(str, "{FFFFFF}Back Right\n");


		if(gTireData[playerid][1]) // frontright
			strcat(str, "{FF0000}Front Right\n");

		else
			strcat(str, "{FFFFFF}Front Right\n");


		if(gTireData[playerid][2]) // backleft
			strcat(str, "{FF0000}Back Left\n");

		else
			strcat(str, "{FFFFFF}Back Left\n");


		if(gTireData[playerid][3]) // frontleft
			strcat(str, "{FF0000}Front Left\n");

		else
			strcat(str, "{FFFFFF}Front Left\n");

	}
	gCurrentWheelFixVehicle[playerid] = vehicleid;

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, response, listitem, inputtext

		if(!response)
			return 0;

		GetVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires);
		new itemid = GetPlayerItem(playerid);

		if(listitem == 0)
		{
			if(gTireData[playerid][0] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & 0b1110);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
		if(listitem == 1)
		{
			if(gTireData[playerid][1] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & 0b1101);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
		if(listitem == 2)
		{
			if(gTireData[playerid][2] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & 0b1011);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
		if(listitem == 3)
		{
			if(gTireData[playerid][3] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & 0b0111);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Tires", str, "Fix", "Cancel");

	return 1;
}
