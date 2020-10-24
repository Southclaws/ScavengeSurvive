/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <zcmd>


enum
{
	WHEELSFRONT_LEFT,	// 0
	WHEELSFRONT_RIGHT,	// 1
	WHEELSMID_LEFT,		// 2
	WHEELSMID_RIGHT,	// 3
	WHEELSREAR_LEFT,	// 4
	WHEELSREAR_RIGHT	// 5
}

CMD:wheelpos(playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(vehicleid == 0)
		return 1;

	new
		wheel,
		Float:x,
		Float:y,
		Float:z,
		str[12];

	for(wheel = WHEELSFRONT_LEFT; wheel <= WHEELSREAR_RIGHT; wheel++)
	{
		GetVehicleWheelPos(vehicleid, wheel, x, y, z);
		CreateObject(18647, x, y, z, 0.0, 0.0, 0.0);
		format(str, 12, "%d", wheel);
		Create3DTextLabel(str, 0xFFFF00FF, x, y, z + (float(wheel) / 10.0), 100.0, 0, 0);
	}

	return 1;
}


stock GetVehicleWheelPos(vehicleid, wheel, &Float:x, &Float:y, &Float:z)
{
	new
		Float:rot,
		Float:x2,
		Float:y2,
		Float:z2,
		Float:div;

	GetVehicleZAngle(vehicleid, rot);
	GetVehiclePos(vehicleid, x2, y2, z2);

	rot = 360 - rot;

	switch(wheel)
	{
		case WHEELSFRONT_LEFT .. WHEELSFRONT_RIGHT: // Front Tyres
			GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_WHEELSFRONT, x, y, z);

		case WHEELSMID_LEFT .. WHEELSMID_RIGHT: // Middle Tyres
			GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_WHEELSMID, x, y, z);

		case WHEELSREAR_LEFT .. WHEELSREAR_RIGHT: // Rear Tyres
			GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_WHEELSREAR, x, y, z);

		default: return 0;
	}
	div = (wheel % 2) ? (x) : (-x);
	x = floatsin(rot, degrees) * y + floatcos(rot, degrees) * div + x2;
	y = floatcos(rot, degrees) * y - floatsin(rot, degrees) * div + y2;
	z += z2;
	return 1;
}
