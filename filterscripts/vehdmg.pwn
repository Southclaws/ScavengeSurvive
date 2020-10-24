/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
native IsValidVehicle(vehicleid);

#include <zcmd>
#include <sscanf2>
#include "../scripts/utils/vehicleparts.pwn"

CMD:panels(playerid, params[])
{
	new
		panels,
		doors,
		lights,
		tires,

		flp,
		frp,
		rlp,
		rrp,
		windshield,
		front_bumper,
		rear_bumper;

	GetVehicleDamageStatus(GetPlayerVehicleID(playerid), panels, doors, lights, tires);

	decode_panels(panels, flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper);

	printf("%d - flp", flp);
	printf("%d - frp", frp);
	printf("%d - rlp", rlp);
	printf("%d - rrp", rrp);
	printf("%d - windshield", windshield);
	printf("%d - front_bumper", front_bumper);
	printf("%d - rear_bumper", rear_bumper);

	return 1;
}

CMD:doors(playerid, params[])
{
	new
		panels,
		doors,
		lights,
		tires,

		bonnet,
		boot,
		driver_door,
		passenger_door;

	GetVehicleDamageStatus(GetPlayerVehicleID(playerid), panels, doors, lights, tires);

	decode_doors(doors, bonnet, boot, driver_door, passenger_door);

	printf("%d - bonnet", bonnet);
	printf("%d - boot", boot);
	printf("%d - driver_door", driver_door);
	printf("%d - passenger_door", passenger_door);

	return 1;
}

CMD:lights(playerid, params[])
{
	new
		panels,
		doors,
		lights,
		tires,

		light1,
		light2,
		light3,
		light4;

	GetVehicleDamageStatus(GetPlayerVehicleID(playerid), panels, doors, lights, tires);

	decode_lights(lights, light1, light2, light3, light4);

	printf("%d - light1", light1);
	printf("%d - light2", light2);
	printf("%d - light3", light3);
	printf("%d - light4", light4);

	return 1;
}

CMD:tires(playerid, params[])
{
	new
		panels,
		doors,
		lights,
		tires,

		tire1,
		tire2,
		tire3,
		tire4;

	GetVehicleDamageStatus(GetPlayerVehicleID(playerid), panels, doors, lights, tires);

	decode_tires(tires, tire1, tire2, tire3, tire4);

	printf("%d - tire1", tire1);
	printf("%d - tire2", tire2);
	printf("%d - tire3", tire3);
	printf("%d - tire4", tire4);

	return 1;
}


CMD:setpanels(playerid, params[])
{
	new
		type[24],
		data,

		panels,
		doors,
		lights,
		tires,

		flp,
		frp,
		rlp,
		rrp,
		windshield,
		front_bumper,
		rear_bumper;

	sscanf(params, "s[24]d", type, data);

	GetVehicleDamageStatus(GetPlayerVehicleID(playerid), panels, doors, lights, tires);

	decode_panels(panels, flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper);


	if(!strcmp(type, "flp"))
		panels = encode_panels(data, frp, rlp, rrp, windshield, front_bumper, rear_bumper);

	if(!strcmp(type, "frp"))
		panels = encode_panels(flp, data, rlp, rrp, windshield, front_bumper, rear_bumper);

	if(!strcmp(type, "rlp"))
		panels = encode_panels(flp, frp, data, rrp, windshield, front_bumper, rear_bumper);

	if(!strcmp(type, "rrp"))
		panels = encode_panels(flp, frp, rlp, data, windshield, front_bumper, rear_bumper);

	if(!strcmp(type, "w"))
		panels = encode_panels(flp, frp, rlp, rrp, data, front_bumper, rear_bumper);

	if(!strcmp(type, "fb"))
		panels = encode_panels(flp, frp, rlp, rrp, windshield, data, rear_bumper);

	if(!strcmp(type, "rb"))
		panels = encode_panels(flp, frp, rlp, rrp, windshield, front_bumper, data);


	UpdateVehicleDamageStatus(GetPlayerVehicleID(playerid), panels, doors, lights, tires);

	return 1;
}

CMD:settires(playerid, params[])
{
	new
		type[24],
		data,

		panels,
		doors,
		lights,
		tires,

		frontright,
		backright,
		backleft,
		frontleft;

	sscanf(params, "s[24]d", type, data);

	GetVehicleDamageStatus(GetPlayerVehicleID(playerid), panels, doors, lights, tires);

	decode_tires(tires, backright, frontright, backleft, frontleft);


	if(!strcmp(type, "fl"))
		tires = encode_tires(data, frontright, backleft, frontleft);

	if(!strcmp(type, "rl"))
		tires = encode_tires(backright, data, frontright, frontleft);

	if(!strcmp(type, "fr"))
		tires = encode_tires(backright, frontright, data, frontleft);

	if(!strcmp(type, "rr"))
		tires = encode_tires(backright, frontright, backleft, data);


	UpdateVehicleDamageStatus(GetPlayerVehicleID(playerid), panels, doors, lights, tires);

	return 1;
}

CMD:repair(playerid, params[])
{
	RepairVehicle(GetPlayerVehicleID(playerid));
	return 1;
}

/*
	TESTED WITH DODO:

	FLP = GENERAL SMOKE
	{
		value seems to do nothing
	}

	RLP = TAIL
	{
		1, 2, 3 = flap damage
	}

	WINDSHIELD = RIGHT WING
	{
		1, 2, 3 = flap damage
	}
*/
