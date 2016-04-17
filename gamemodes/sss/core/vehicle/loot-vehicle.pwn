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


CreateLootVehicle(type, Float:x, Float:y, Float:z, Float:r)
{
	new
		vehicleid,
		model,
		colour1,
		colour2;

	model = GetVehicleTypeModel(type);

	switch(model)
	{
		case 416, 433, 523, 427, 490, 528, 407, 544, 596, 597, 598, 599, 432, 601:
		{
			colour1 = -1;
			colour2 = -1;
		}
		default:
		{
			colour1 = 128 + random(128);
			colour2 = 128 + random(128);
		}
	}

	vehicleid = CreateWorldVehicle(type, x, y, z, r, colour1, colour2);
	SetVehicleEngine(vehicleid, 0);

	if(vehicleid >= MAX_VEHICLES)
	{
		print("ERROR: Vehicle limit reached.");
		DestroyVehicle(vehicleid);
		return 0;
	}

	Iter_Add(veh_Index, vehicleid);

	SetVehicleColours(vehicleid, colour1, colour2);

	GenerateVehicleData(vehicleid);
	SetVehicleSpawnPoint(vehicleid, x, y, z, r);

	return vehicleid;
}

GenerateVehicleData(vehicleid)
{
	new
		type,
		category,
		Float:maxfuel,
		lootindex,
		trunksize,
		chance;

	type = GetVehicleType(vehicleid);
	category = GetVehicleTypeCategory(type);
	maxfuel = GetVehicleTypeMaxFuel(type);
	lootindex = GetVehicleTypeLootIndex(type);
	trunksize = GetVehicleTypeTrunkSize(type);

// Health

	chance = random(100);

	if(chance < 1)
		SetVehicleHP(vehicleid, 500 + random(200));

	else if(chance < 5)
		SetVehicleHP(vehicleid, 400 + random(200));

	else
		SetVehicleHP(vehicleid, 300 + random(200));

// Fuel

	chance = random(100);

	if(chance < 1)
		SetVehicleFuel(vehicleid, maxfuel / 2 + frandom(maxfuel / 2));

	else if(chance < 5)
		SetVehicleFuel(vehicleid, maxfuel / 4 + frandom(maxfuel / 3));

	else if(chance < 10)
		SetVehicleFuel(vehicleid, maxfuel / 8 + frandom(maxfuel / 4));

	else
		SetVehicleFuel(vehicleid, frandom(1.0));

// Visual Damage

	if(category < VEHICLE_CATEGORY_MOTORBIKE)
	{
		SetVehicleDamageData(vehicleid,
			encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
			encode_doors(random(5), random(5), random(5), random(5)),
			encode_lights(random(2), random(2), random(2), random(2)),
			encode_tires(random(2), random(2), random(2), random(2)) );
	}

// Locks

/*	if(maxfuel == 0.0)
	{
		SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);
	}
	else
	{
		new locked;

		if(doors == 0)
			locked = random(2);

		if(panels)
			veh_TrunkLock[vehicleid] = random(2);

		SetVehicleParamsEx(vehicleid, 0, random(2), !random(100), locked, random(2), random(2), 0);
	}*/

// Putting loot in trunks

	if(lootindex != -1 && 0 < trunksize <= CNT_MAX_SLOTS)
	{
		FillContainerWithLoot(GetVehicleContainer(vehicleid), random(trunksize / 3), lootindex);
	}

// Number plate

	SetVehicleNumberPlate(vehicleid, RandomNumberPlateString());
}
