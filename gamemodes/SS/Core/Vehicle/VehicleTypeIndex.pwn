/*
	Parent class for vehicle types. A created vehicle is an instance of this.

	A vehicle group is a category of vehicles, such as sedan, estate, 4x4 etc,
	which is merely an identifier for grouping similar vehicles together.

	A vehicle type is a specific type of vehicle with a specific model and a set
	of properties such as a model name, fuel consumption speed and trunk size.
*/


#define MAX_VEHICLE_GROUP		(12)
#define MAX_VEHICLE_GROUP_NAME	(32)
#define MAX_VEHICLE_TYPE		(64)
#define MAX_VEHICLE_TYPE_NAME	(32)
#define INVALID_VEHICLE_TYPE	(-1)


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
	VEHICLE_CATEGORY_TRAILER,
	MAX_VEHICLE_CATEGORIES
}
enum
{
	VEHICLE_SIZE_SMALL,
	VEHICLE_SIZE_MEDIUM,
	VEHICLE_SIZE_LARGE
}

enum (<<= 1)
{
	VEHICLE_FLAG_LOCKABLE,
	VEHICLE_FLAG_ELECTRIC
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
		veh_lootIndex,
		veh_trunkSize,
		veh_spawnChance,
		veh_flags
}


static
		veh_GroupName[MAX_VEHICLE_GROUP][MAX_VEHICLE_GROUP_NAME],
		veh_GroupTotal,
		veh_TypeData[MAX_VEHICLE_TYPE][E_VEHICLE_TYPE_DATA],
		veh_TypeTotal,
		veh_Type[MAX_VEHICLES];


/*==============================================================================

	Core

==============================================================================*/


stock DefineVehicleSpawnGroup(name[])
{
	if(veh_GroupTotal == MAX_VEHICLE_GROUP - 1)
		return -1;

	printf("Defining new vehicle spawn group %d: '%s'.", veh_GroupTotal, name);

	strcat(veh_GroupName[veh_GroupTotal], name, MAX_VEHICLE_GROUP_NAME);

	return veh_GroupTotal++;
}

stock DefineVehicleType(modelid, name[], group, category, size, Float:maxfuel, Float:fuelcons, lootindex, trunksize, spawnchance, flags = 0)
{
	if(veh_TypeTotal == MAX_VEHICLE_TYPE - 1)
		return -1;

	printf("Defining new vehicle type %d: model %d, name '%s', group %d, category %d, size %d.", veh_TypeTotal, modelid, name, group, category, size);

	veh_TypeData[veh_TypeTotal][veh_modelId] = modelid;
	strcat(veh_TypeData[veh_TypeTotal][veh_modelId], name, MAX_VEHICLE_TYPE_NAME);
	veh_TypeData[veh_TypeTotal][veh_spawnGroup] = group;
	veh_TypeData[veh_TypeTotal][veh_category] = category;
	veh_TypeData[veh_TypeTotal][veh_size] = size;
	veh_TypeData[veh_TypeTotal][veh_maxFuel] = maxfuel;
	veh_TypeData[veh_TypeTotal][veh_fuelCons] = fuelcons;
	veh_TypeData[veh_TypeTotal][veh_lootIndex] = lootindex;
	veh_TypeData[veh_TypeTotal][veh_trunkSize] = trunksize;
	veh_TypeData[veh_TypeTotal][veh_spawnChance] = spawnchance;
	veh_TypeData[veh_TypeTotal][veh_flags] = flags;

	return veh_TypeTotal++;
}


stock CreateVehicleOfType(type, Float:x, Float:y, Float:z, Float:r, colour1, colour2)
{
	if(!(0 <= type < veh_TypeTotal))
	{
		printf("ERROR: Tried to create invalid vehicle type (%d).", type);
		return 0;
	}

	/*
		some code from the spawn module, not sure if it's necessary still...
			switch(model)
			{
				case 403, 443, 514, 515, 539:
				{
					posZ += 2.0;
				}
			}

	*/

	//printf("[CreateVehicleOfType] Creating vehicle of type %d model %d at %f, %f, %f", type, veh_TypeData[type][veh_modelId], x, y, z);

	new vehicleid = CreateVehicle(veh_TypeData[type][veh_modelId], x, y, z, r, colour1, colour2, 864000);

	if(!IsValidVehicle(vehicleid))
		return 0;

	veh_Type[vehicleid] = type;

	return vehicleid;
}

stock PickRandomVehicleTypeFromGroup(group, categories[], maxcategories, sizes[], maxsizes)
{
	//printf("[PickRandomVehicleTypeFromGroup] group: %d categories: %d sizes: %d", group, maxcategories, maxsizes);
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

		if(random(100) < veh_TypeData[i][veh_spawnChance])
		{
			//printf("[PickRandomVehicleTypeFromGroup] Adding '%s' to list", veh_TypeData[i][veh_name]);
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


stock GetVehicleType(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return INVALID_VEHICLE_TYPE;

	return veh_Type[vehicleid];
}

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
stock GetVehicleTypeLootIndex(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_lootIndex];
}

// veh_trunkSize
stock GetVehicleTypeTrunkSize(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_trunkSize];
}

// veh_spawnChance
stock GetVehicleTypeSpawnChance(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_spawnChance];
}

// veh_flags
stock GetVehicleTypeFlags(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal))
		return 0;

	return veh_TypeData[vehicletype][veh_flags];
}


/*
	Hook for CreateVehicle, if the first parameter isn't a valid model ID but is
	a valid vehicle-type from this index, use the index create function instead.
*/
stock vti_CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay)
{
	#pragma unused vehicletype, x, y, z, rotation, color1, color2, respawn_delay
	printf("ERROR: Cannot create vehicle by model ID.");

	return 0;
}
#if defined _ALS_CreateVehicle
	#undef CreateVehicle
#else
	#define _ALS_CreateVehicle
#endif
#define CreateVehicle vti_CreateVehicle
