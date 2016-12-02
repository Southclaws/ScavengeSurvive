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


/*
	Parent class for vehicle types. A created vehicle is an instance of this.

	A vehicle group is a category of vehicles, such as sedan, estate, 4x4 etc,
	which is merely an identifier for grouping similar vehicles together.

	A vehicle type is a specific type of vehicle with a specific model and a set
	of properties such as a model name, fuel consumption speed and trunk size.
*/


#define MAX_VEHICLE_GROUP		(12)
#define MAX_VEHICLE_GROUP_NAME	(32)
#define MAX_VEHICLE_TYPE		(70)
#define MAX_VEHICLE_TYPE_NAME	(32)
#define INVALID_VEHICLE_TYPE	(-1)


enum (<<= 1)
{
	VEHICLE_FLAG_NOT_LOCKABLE = 1,
	VEHICLE_FLAG_NO_ENGINE,
	VEHICLE_FLAG_TRAILER,
	VEHICLE_FLAG_CAN_SURF
}

enum
{
	VEHICLE_CATEGORY_CAR,
	VEHICLE_CATEGORY_TRUCK,
	VEHICLE_CATEGORY_MOTORBIKE,
	VEHICLE_CATEGORY_PUSHBIKE,
	VEHICLE_CATEGORY_HELICOPTER,
	VEHICLE_CATEGORY_PLANE,
	VEHICLE_CATEGORY_BOAT,
	VEHICLE_CATEGORY_TRAIN,
	MAX_VEHICLE_CATEGORIES
}

enum
{
	VEHICLE_SIZE_SMALL,
	VEHICLE_SIZE_MEDIUM,
	VEHICLE_SIZE_LARGE
}

enum E_VEHICLE_TYPE_DATA
{
		veh_modelId,
		veh_name[MAX_VEHICLE_TYPE_NAME],
		veh_spawnGroup,
		veh_category,
		veh_size,
Float:	veh_maxFuel,
Float:	veh_fuelCons,
		veh_lootIndex[32],
		veh_trunkSize,
Float:	veh_spawnChance,
		veh_flags
}


static
		veh_GroupName[MAX_VEHICLE_GROUP][MAX_VEHICLE_GROUP_NAME],
		veh_TypeData[MAX_VEHICLE_TYPE][E_VEHICLE_TYPE_DATA];

new
		veh_GroupTotal,
		veh_TypeTotal;


/*==============================================================================

	Core

==============================================================================*/


stock DefineVehicleSpawnGroup(name[])
{
	if(veh_GroupTotal == MAX_VEHICLE_GROUP - 1)
		return -1;

	log("Defining new vehicle spawn group %d: '%s'.", veh_GroupTotal, name);

	strcat(veh_GroupName[veh_GroupTotal], name, MAX_VEHICLE_GROUP_NAME);

	return veh_GroupTotal++;
}

stock DefineVehicleType(modelid, name[], group, category, size, Float:maxfuel, Float:fuelcons, lootindex[], trunksize, Float:spawnchance, flags = 0)
{
	if(veh_TypeTotal == MAX_VEHICLE_TYPE - 1)
		return -1;

	log("Defining new vehicle type %d: model %d, name '%s', group %d, category %d, size %d, maxfuel %f, fuelcons %f, lootindex %s, trunksize %d, spawnchance %f, flags %d",
		veh_TypeTotal, modelid, name, group, category, size, maxfuel, fuelcons, lootindex, trunksize, spawnchance, flags);

	veh_TypeData[veh_TypeTotal][veh_modelId] = modelid;
	strcat(veh_TypeData[veh_TypeTotal][veh_modelId], name, MAX_VEHICLE_TYPE_NAME);
	veh_TypeData[veh_TypeTotal][veh_spawnGroup] = group;
	veh_TypeData[veh_TypeTotal][veh_category] = category;
	veh_TypeData[veh_TypeTotal][veh_size] = size;
	veh_TypeData[veh_TypeTotal][veh_maxFuel] = maxfuel;
	veh_TypeData[veh_TypeTotal][veh_fuelCons] = fuelcons;
	strcat(veh_TypeData[veh_TypeTotal][veh_lootIndex], lootindex, 32);
	veh_TypeData[veh_TypeTotal][veh_trunkSize] = trunksize;
	veh_TypeData[veh_TypeTotal][veh_spawnChance] = spawnchance;
	veh_TypeData[veh_TypeTotal][veh_flags] = flags;

	return veh_TypeTotal++;
}

stock PickRandomVehicleTypeFromGroup(group, categories[], maxcategories, sizes[], maxsizes)
{
	// log("[PickRandomVehicleTypeFromGroup] group: %d categories: %d sizes: %d", group, maxcategories, maxsizes);
	new
		idx,
		cell,
		list[MAX_VEHICLE_TYPE];

	for(new i; i < veh_TypeTotal; i++)
	{
		if(veh_TypeData[i][veh_spawnGroup] != group)
			continue;

		if(!_IsMatchingCategory(i, categories, maxcategories))
			continue;

		if(!_IsMatchingSize(i, sizes, maxsizes))
			continue;

		if(frandom(100.0) < veh_TypeData[i][veh_spawnChance])
		{
			// log("[PickRandomVehicleTypeFromGroup] Adding '%s' to list", veh_TypeData[i][veh_name]);
			list[idx++] = i;
		}
	}

	cell = random(idx);

	if(cell > sizeof(list))
		return -1;

	return list[cell];
}

_IsMatchingCategory(vehicletype, categories[], maxcategories)
{
	for(new i; i <= maxcategories; i++)
	{
		if(i == maxcategories)
			return 0;

		if(veh_TypeData[vehicletype][veh_category] == categories[i])
			return 1;
	}

	return 0;
}

_IsMatchingSize(vehicletype, sizes[], maxsizes)
{
	for(new i; i <= maxsizes; i++)
	{
		if(i == maxsizes)
			return 0;

		if(veh_TypeData[vehicletype][veh_size] == sizes[i])
			return 1;
	}

	return 0;
}

stock GetVehicleGroupFromName(name[], bool:ignorecase = true, bool:partial = false)
{
	if(isnull(name))
		return -1;

	if(partial)
	{
		for(new i; i < veh_GroupTotal; i++)
		{
			if(strfind(veh_GroupName[i], name, ignorecase) != -1)
				return i;
		}
	}
	else
	{
		for(new i; i < veh_GroupTotal; i++)
		{
			if(!strcmp(name, veh_GroupName[i], ignorecase))
				return i;
		}
	}

	return -1;
}

stock GetVehicleTypeFromName(name[], bool:ignorecase = true, bool:partial = false)
{
	if(isnull(name))
		return -1;

	if(partial)
	{
		for(new i; i < veh_TypeTotal; i++)
		{
			if(strfind(veh_TypeData[i][veh_name], name, ignorecase) != -1)
				return i;
		}
	}
	else
	{
		for(new i; i < veh_TypeTotal; i++)
		{
			if(!strcmp(name, veh_TypeData[i][veh_name], ignorecase))
				return i;
		}
	}

	return -1;
}

stock GetVehicleTypeFromModel(modelid)
{
	for(new i; i < veh_TypeTotal; i++)
	{
		if(veh_TypeData[i][veh_modelId] == modelid)
			return i;
	}

	return INVALID_VEHICLE_TYPE;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsValidVehicleType(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return 1;
}

// veh_modelId
stock GetVehicleTypeModel(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_modelId];
}

// veh_name
stock GetVehicleTypeName(vehicletype, name[])
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	name[0] = EOS;
	strcat(name, veh_TypeData[vehicletype][veh_name], MAX_VEHICLE_TYPE_NAME);

	return 1;
}

// veh_spawnGroup
stock GetVehicleTypeGroup(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_spawnGroup];
}

// veh_category
stock GetVehicleTypeCategory(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_category];
}

// veh_size
stock GetVehicleTypeSize(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_size];
}

// veh_maxFuel
stock Float:GetVehicleTypeMaxFuel(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0.0;

	return veh_TypeData[vehicletype][veh_maxFuel];
}

// veh_fuelCons
stock Float:GetVehicleTypeFuelConsumption(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0.0;

	return veh_TypeData[vehicletype][veh_fuelCons];
}

// veh_lootIndex
stock GetVehicleTypeLootIndex(vehicletype, lootindex[])
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	lootindex[0] = EOS;
	strcat(lootindex, veh_TypeData[vehicletype][veh_lootIndex], 32);

	return 1;
}

// veh_trunkSize
stock GetVehicleTypeTrunkSize(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_trunkSize];
}

// veh_spawnChance
stock Float:GetVehicleTypeSpawnChance(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0.0;

	return veh_TypeData[vehicletype][veh_spawnChance];
}

// veh_flags
stock GetVehicleTypeFlags(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_flags];
}

// veh_flags / VEHICLE_FLAG_NOT_LOCKABLE
stock IsVehicleTypeLockable(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return !(veh_TypeData[vehicletype][veh_flags] & VEHICLE_FLAG_NOT_LOCKABLE);
}

// veh_flags / VEHICLE_FLAG_NO_ENGINE
stock IsVehicleTypeNoEngine(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_flags] & VEHICLE_FLAG_NO_ENGINE;
}

// veh_flags / VEHICLE_FLAG_TRAILER
stock IsVehicleTypeTrailer(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_flags] & VEHICLE_FLAG_TRAILER;
}

// veh_flags / VEHICLE_FLAG_CAN_SURF
stock IsVehicleTypeSurfable(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_flags] & VEHICLE_FLAG_CAN_SURF;
}
