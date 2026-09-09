/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	new Item:itemid = GetPlayerItem(playerid);

	if(GetItemType(itemid) == item_Wheel)
	{
		if(_WheelRepair(playerid, vehicleid, itemid))
			return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_WheelRepair(playerid, vehicleid, Item:itemid)
{
	new
		wheel = GetPlayerVehicleTire(playerid, vehicleid),
		vehicletype = GetVehicleType(vehicleid),
		VEHICLE_PANEL_STATUS:panels,
		VEHICLE_DOOR_STATUS:doors,
		VEHICLE_LIGHT_STATUS:lights,
		VEHICLE_TYRE_STATUS:tires;

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	if(GetVehicleTypeCategory(vehicletype) == VEHICLE_CATEGORY_MOTORBIKE && GetVehicleTypeModel(vehicletype) != 471)
	{
		switch(wheel)
		{
			case WHEELSFRONT_LEFT, WHEELSFRONT_RIGHT: // Front
			{
				if(tires & VEHICLE_TYRE_STATUS_FRONT_RIGHT_POPPED)
				{
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & ~VEHICLE_TYRE_STATUS_FRONT_RIGHT_POPPED);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPFT", true), 5000);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			case WHEELSMID_LEFT, WHEELSMID_RIGHT, WHEELSREAR_LEFT, WHEELSREAR_RIGHT: // back
			{
				if(tires & VEHICLE_TYRE_STATUS_REAR_RIGHT_POPPED)
				{
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & ~VEHICLE_TYRE_STATUS_REAR_RIGHT_POPPED);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPRT", true), 5000);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			default:
				return 0;
		}
	}
	else
	{
		switch(wheel)
		{
			case WHEELSFRONT_LEFT:
			{
				if(tires & VEHICLE_TYRE_STATUS_FRONT_LEFT_POPPED)
				{
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & ~VEHICLE_TYRE_STATUS_FRONT_LEFT_POPPED);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPFL", true), 5000);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			case WHEELSFRONT_RIGHT:
			{
				if(tires & VEHICLE_TYRE_STATUS_FRONT_RIGHT_POPPED)
				{
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & ~VEHICLE_TYRE_STATUS_FRONT_RIGHT_POPPED);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPFR", true), 5000);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			case WHEELSREAR_LEFT:
			{
				if(tires & VEHICLE_TYRE_STATUS_REAR_LEFT_POPPED)
				{
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & ~VEHICLE_TYRE_STATUS_REAR_LEFT_POPPED);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPBL", true), 5000);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			case WHEELSREAR_RIGHT:
			{
				if(tires & VEHICLE_TYRE_STATUS_REAR_RIGHT_POPPED)
				{
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & ~VEHICLE_TYRE_STATUS_REAR_RIGHT_POPPED);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPBR", true), 5000);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			default:
				return 0;
		}
	}

	return 1;
}


/*
ShowTireList(playerid, vehicleid)
{
	new
		vehicletype = GetVehicleType(vehicleid),
		VEHICLE_PANEL_STATUS:panels,
		VEHICLE_DOOR_STATUS:doors,
		VEHICLE_LIGHT_STATUS:lights,
		VEHICLE_TYRE_STATUS:tires,
		str[22 * 4];

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	if(GetVehicleTypeCategory(vehicletype) == VEHICLE_CATEGORY_MOTORBIKE && GetVehicleTypeModel(vehicletype) != 471)
	{
		tiredata[playerid][0] = tires & VEHICLE_TYRE_STATUS_REAR_RIGHT_POPPED;
		tiredata[playerid][1] = tires & VEHICLE_TYRE_STATUS_FRONT_RIGHT_POPPED;

		if(tiredata[playerid][0]) // back
			strcat(str, "{FF0000}Back\n");

		else
			strcat(str, "{FFFFFF}Back\n");


		if(tiredata[playerid][1]) // front
			strcat(str, "{FF0000}Front\n");

		else
			strcat(str, "{FFFFFF}Front\n");
	}
	else
	{
		tiredata[playerid][0] = 
		tiredata[playerid][1] = 
		tiredata[playerid][2] = 
		tiredata[playerid][3] = 

		if(tiredata[playerid][0])
			strcat(str, "{FF0000}Back Right\n");

		else
			strcat(str, "{FFFFFF}Back Right\n");


		if(tiredata[playerid][1])
			strcat(str, "{FF0000}Front Right\n");

		else
			strcat(str, "{FFFFFF}Front Right\n");


		if(tiredata[playerid][2])
			strcat(str, "{FF0000}Back Left\n");

		else
			strcat(str, "{FFFFFF}Back Left\n");


		if(tiredata[playerid][3])
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
		new Item:itemid = GetPlayerItem(playerid);

		if(listitem == 0)
		{
			if(tiredata[playerid][0] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & ~VEHICLE_TYRE_STATUS_REAR_RIGHT_POPPED);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
		if(listitem == 1)
		{
			if(tiredata[playerid][1] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & ~VEHICLE_TYRE_STATUS_FRONT_RIGHT_POPPED);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
		if(listitem == 2)
		{
			if(tiredata[playerid][2] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & ~VEHICLE_TYRE_STATUS_REAR_LEFT_POPPED);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
		if(listitem == 3)
		{
			if(tiredata[playerid][3] && GetItemType(itemid) == item_Wheel)
			{
				UpdateVehicleDamageStatus(gCurrentWheelFixVehicle[playerid], panels, doors, lights, tires & ~VEHICLE_TYRE_STATUS_FRONT_LEFT_POPPED);
				DestroyItem(itemid);
			}
			else ShowTireList(playerid, gCurrentWheelFixVehicle[playerid]);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Tires", str, "Fix", "Cancel");

	return 1;
}
*/
