/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


enum // Tires
{
	CAR_TIRE_FRONT_LEFT,
	CAR_TIRE_REAR_LEFT,
	CAR_TIRE_FRONT_RIGHT,
	CAR_TIRE_REAR_RIGHT,
	BIKE_TIRE_FRONT,
	BIKE_TIRE_REAR
}
enum // Plane parts
{
	PLANE_PART_WINGS,
	PLANE_PART_TAIL
}


/*==============================================================================

	Tires

==============================================================================*/


stock SetCarTireState(vehicleid, tire, toggle)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	new
		panels,
		doors,
		lights,
		tires,

		backright,
		frontright,
		backleft,
		frontleft;

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	decode_tires(tires, backright, frontright, backleft, frontleft);

	switch(tire)
	{
		case CAR_TIRE_FRONT_LEFT:
			tires = encode_tires(backright, frontright, backleft, toggle);

		case CAR_TIRE_REAR_LEFT:
			tires = encode_tires(backright, frontright, toggle, frontleft);

		case CAR_TIRE_FRONT_RIGHT:
			tires = encode_tires(backright, toggle, backleft, frontleft);

		case CAR_TIRE_REAR_RIGHT:
			tires = encode_tires(toggle, frontright, backleft, frontleft);

		case BIKE_TIRE_FRONT:
			tires = encode_tires(backright, toggle, backleft, toggle);

		case BIKE_TIRE_REAR:
			tires = encode_tires(toggle, frontright, toggle, frontleft);
	}

	UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	return 1;
}

stock GetCarTireState(vehicleid, tire)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	new
		panels,
		doors,
		lights,
		tires;

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	return tires & tire;
}


/*==============================================================================

	Plane Flaps

==============================================================================*/


stock SetPlanePartDamage(vehicleid, part, damage)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

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

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	decode_panels(input, flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper);

	if(part == PLANE_PART_WINGS)
		encode_panels(flp, frp, damage, rrp, windshield, front_bumper, rear_bumper);

	else if(part == PLANE_PART_TAIL)
		encode_panels(flp, frp, rlp, rrp, damage, front_bumper, rear_bumper);

	UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	return 1;
}

stock GetPlanePartDamage(vehicleid, part)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

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

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	decode_panels(panels, flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper);

	if(part == PLANE_PART_WINGS)
		return rlp;

	else if(part == PLANE_PART_TAIL)
		return windshield;

	return 0;
}


/*==============================================================================

	Standard "encode_" functions with "decode_" counterparts

==============================================================================*/


stock decode_panels(input, &flp, &frp, &rlp, &rrp, &windshield, &front_bumper, &rear_bumper)
{
	flp = input & 0xF;
	frp = (input >> 4) & 0xF;
	rlp = (input >> 8) & 0xF;
	rrp = (input >> 12) & 0xF;
	windshield = (input >> 16) & 0xF;
	front_bumper = (input >> 20) & 0xF;
	rear_bumper = (input >> 24) & 0xF;
}
stock encode_panels(flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper)
{
	return flp | (frp << 4) | (rlp << 8) | (rrp << 12) | (windshield << 16) | (front_bumper << 20) | (rear_bumper << 24);
}

stock decode_doors(input, &bonnet, &boot, &driver_door, &passenger_door)
{
	bonnet = input & 0xFF;
	boot = (input >> 8) & 0xFF;
	driver_door = (input >> 16) & 0xFF;
	passenger_door = (input >> 24) & 0xFF;
}
stock encode_doors(bonnet, boot, driver_door, passenger_door)
{
	return bonnet | (boot << 8) | (driver_door << 16) | (passenger_door << 24);
}

stock decode_lights(input, &light1, &light2, &light3, &light4)
{
	light1 = input & 0x1;
	light2 = (input >> 1) & 0x1;
	light3 = (input >> 2) & 0x1;
	light4 = (input >> 3) & 0x1;
}
stock encode_lights(light1, light2, light3, light4)
{
	return light1 | (light2 << 1) | (light3 << 2) | (light4 << 3);
}

stock decode_tires(input, &backright, &frontright, &backleft, &frontleft)
{
	backright = input & 0x1;
	frontright = (input >> 1) & 0x1;
	backleft = (input >> 2) & 0x1;
	frontleft = (input >> 3) & 0x1;
}
stock encode_tires(backright, frontright, backleft, frontleft)
{
	return backright | (frontright << 1) | (backleft << 2) | (frontleft << 3);
}
