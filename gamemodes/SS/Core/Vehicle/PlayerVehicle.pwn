#include <YSI\y_hooks>


#define PLAYER_VEHICLE_DIRECTORY	"./scriptfiles/SSS/Vehicles/"
#define PLAYER_VEHICLE_FILE			"SSS/Vehicles/%s.dat"

enum
{
	VEH_CELL_MODEL,		// 00
	VEH_CELL_HEALTH,	// 01
	VEH_CELL_FUEL,		// 02
	VEH_CELL_POSX,		// 03
	VEH_CELL_POSY,		// 04
	VEH_CELL_POSZ,		// 05
	VEH_CELL_ROTZ,		// 06
	VEH_CELL_COL1,		// 07
	VEH_CELL_COL2,		// 08
	VEH_CELL_PANELS,	// 09
	VEH_CELL_DOORS,		// 10
	VEH_CELL_LIGHTS,	// 11
	VEH_CELL_TIRES,		// 12
	VEH_CELL_ARMOUR,	// 13
	VEH_CELL_INV		// 14
}


SavePlayerVehicles()
{
	new owner[MAX_PLAYER_NAME];

	for(new i; i < MAX_SPAWNED_VEHICLES; i++)
	{
		GetVehicleOwner(i, owner);

		if(IsValidVehicleID(i))
		{
			if(strlen(owner) >= 3)
				SavePlayerVehicle(i, owner);
		}
		else
		{
			if(strlen(owner) >= 3)
				RemovePlayerVehicleFile(i);
		}
	}
}

LoadPlayerVehicles()
{
	new
		dir:direc = dir_open(PLAYER_VEHICLE_DIRECTORY),
		item[28],
		type;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			LoadPlayerVehicle(item);
		}
	}

	dir_close(direc);

	printf("Loaded %d Player vehicles\n", Iter_Count(veh_Index));

	return;
}

LoadPlayerVehicle(filename[])
{
	new
		File:file,
		filedir[64],
		vehicleid,
		vehicletype,
		owner[MAX_PLAYER_NAME],
		containerid,
		array[VEH_CELL_INV + (CNT_MAX_SLOTS * 3)],
		itemid;

	filedir = "SSS/Vehicles/";
	strcat(filedir, filename);

	file = fopen(filedir, io_read);

	if(!file)
		return 0;

	if(strlen(filename) <= 4)
	{
		fclose(file);
		fremove(filedir);
		return 0;
	}

	fblockread(file, array, sizeof(array));
	fclose(file);

	vehicletype = GetVehicleType(array[VEH_CELL_MODEL]);

	if(!(400 <= array[VEH_CELL_MODEL] <= 612))
	{
		printf("ERROR: Removing Vehicle file: %s. Invalid model ID.", filename);
		fremove(filedir);
		return 0;
	}

	if(Float:array[VEH_CELL_HEALTH] < 255.5)
	{
		printf("ERROR: Removing Vehicle %s file: %s due to low health.", VehicleNames[array[VEH_CELL_MODEL]-400], filename);
		fremove(filedir);
		return 0;
	}

	if(vehicletype == VTYPE_TRAIN)
	{
		printf("ERROR: Removing Vehicle %s file: %s because train.", VehicleNames[array[VEH_CELL_MODEL]-400], filename);
		fremove(filedir);
		return 0;
	}

	if(vehicletype != VTYPE_SEA)
	{
		if(!IsPointInMapBounds(Float:array[VEH_CELL_POSX], Float:array[VEH_CELL_POSY], Float:array[VEH_CELL_POSZ]))
		{
			if(vehicletype == VTYPE_HELI || vehicletype == VTYPE_PLANE)
			{
				array[VEH_CELL_POSZ] = _:(Float:array[VEH_CELL_POSZ] + 2.0);
			}
			else
			{
				printf("ERROR: Removing Vehicle %s file: %s because it's out of the map bounds.", VehicleNames[array[VEH_CELL_MODEL]-400], filename);
				fremove(filedir);

				return 0;
			}
		}
	}

	strmid(owner, filename, 0, strlen(filename) - 4);

	if(strlen(owner) < 3)
	{
		printf("ERROR: Vehicle owner name is invalid: '%s' Length: %d", owner, strlen(owner));
		DestroyVehicle(vehicleid, 1);
		fremove(filedir);
		return 0;
	}

	vehicleid = CreateVehicle(
		array[VEH_CELL_MODEL],
		Float:array[VEH_CELL_POSX],
		Float:array[VEH_CELL_POSY],
		Float:array[VEH_CELL_POSZ],
		Float:array[VEH_CELL_ROTZ],
		array[VEH_CELL_COL1],
		array[VEH_CELL_COL2],
		86400);

	if(!IsValidVehicleID(vehicleid))
		return 0;

	SetVehicleSpawnPoint(vehicleid,
		Float:array[VEH_CELL_POSX],
		Float:array[VEH_CELL_POSY],
		Float:array[VEH_CELL_POSZ],
		Float:array[VEH_CELL_ROTZ]);

	SetVehicleOwner(vehicleid, owner);

	printf("\t[LOAD] vehicle %d: %s for %s at %f, %f, %f", vehicleid, VehicleNames[array[VEH_CELL_MODEL]-400], owner, array[VEH_CELL_POSX], array[VEH_CELL_POSY], array[VEH_CELL_POSZ], array[VEH_CELL_ROTZ]);

	Iter_Add(veh_Index, vehicleid);

	if(Float:array[VEH_CELL_HEALTH] > 990.0)
		array[VEH_CELL_HEALTH] = _:990.0;

	veh_Data[vehicleid][veh_health]				= Float:array[VEH_CELL_HEALTH];
	veh_Data[vehicleid][veh_Fuel]				= Float:array[VEH_CELL_FUEL];
	veh_Data[vehicleid][veh_panels]				= array[VEH_CELL_PANELS];
	veh_Data[vehicleid][veh_doors]				= array[VEH_CELL_DOORS];
	veh_Data[vehicleid][veh_lights]				= array[VEH_CELL_LIGHTS];
	veh_Data[vehicleid][veh_tires]				= array[VEH_CELL_TIRES];
	veh_Data[vehicleid][veh_armour]				= array[VEH_CELL_ARMOUR];
	veh_Data[vehicleid][veh_colour1]			= array[VEH_CELL_COL1];
	veh_Data[vehicleid][veh_colour2]			= array[VEH_CELL_COL2];

	if(VehicleFuelData[array[VEH_CELL_MODEL]-400][veh_trunkSize] > 0)
	{
		containerid = CreateContainer("Trunk", VehicleFuelData[array[VEH_CELL_MODEL]-400][veh_trunkSize], .virtual = 1);
		SetVehicleContainer(vehicleid, containerid);

		for(new i, j; j < CNT_MAX_SLOTS; i += 3, j++)
		{
			if(!IsValidItemType(ItemType:array[VEH_CELL_INV + i]) || array[i + VEH_CELL_INV] == 0)
				continue;

			itemid = CreateItem(ItemType:array[VEH_CELL_INV + i], 0.0, 0.0, 0.0);

			if(array[VEH_CELL_INV + i + 1] == 1)
			{
				if(!IsItemTypeSafebox(ItemType:array[VEH_CELL_INV + i]) && !IsItemTypeBag(ItemType:array[VEH_CELL_INV + i]))
				{
					SetItemExtraData(itemid, array[VEH_CELL_INV + i + 2]);
				}

				AddItemToContainer(containerid, itemid);
			}
		}
	}
	else
	{
		SetVehicleContainer(vehicleid, INVALID_CONTAINER_ID);
	}

	t:veh_BitData[vehicleid]<veh_Player>;

	UpdateVehicleData(vehicleid);
	CreateVehicleArea(vehicleid);

	return 1;
}

SavePlayerVehicle(vehicleid, name[MAX_PLAYER_NAME], print = true)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(isnull(name))
		return 0;

	if(veh_BitData[vehicleid] & veh_Dead)
		return 0;

	new
		File:file,
		filename[MAX_PLAYER_NAME + 18],
		array[VEH_CELL_INV + (CNT_MAX_SLOTS * 3)],
		itemid;

	array[VEH_CELL_MODEL] = GetVehicleModel(vehicleid);

	if(GetVehicleType(array[VEH_CELL_MODEL]) == VTYPE_TRAIN)
		return 0;

	GetVehicleHealth(vehicleid, Float:array[1]);

	array[VEH_CELL_FUEL] = _:GetVehicleFuel(vehicleid);
	GetVehiclePos(vehicleid, Float:array[VEH_CELL_POSX], Float:array[VEH_CELL_POSY], Float:array[VEH_CELL_POSZ]);
	GetVehicleZAngle(vehicleid, Float:array[VEH_CELL_ROTZ]);
	array[VEH_CELL_COL1] = veh_Data[vehicleid][veh_colour1];
	array[VEH_CELL_COL2] = veh_Data[vehicleid][veh_colour2];
	GetVehicleDamageStatus(vehicleid, array[VEH_CELL_PANELS], array[VEH_CELL_DOORS], array[VEH_CELL_LIGHTS], array[VEH_CELL_TIRES]);
	array[VEH_CELL_ARMOUR] = 0;

	if(print)
		printf("\t[SAVE] Vehicle %d: %s for %s", vehicleid, VehicleNames[array[VEH_CELL_MODEL]-400], name);

	if(IsValidContainer(GetVehicleContainer(vehicleid)))
	{
		for(new i, j; j < CNT_MAX_SLOTS; i += 3, j++)
		{
			if(IsContainerSlotUsed(GetVehicleContainer(vehicleid), j))
			{
				itemid = GetContainerSlotItem(GetVehicleContainer(vehicleid), j);
				array[VEH_CELL_INV + i] = _:GetItemType(itemid);
				array[VEH_CELL_INV + i + 1] = 1;
				array[VEH_CELL_INV + i + 2] = GetItemExtraData(itemid);

				if(array[VEH_CELL_INV + i] == 0)
					return 0;
			}
			else
			{
				array[VEH_CELL_INV + i] = -1;
				array[VEH_CELL_INV + i + 1] = 1;
				array[VEH_CELL_INV + i + 2] = 0;
			}
		}
	}

	SetVehicleOwner(vehicleid, name);

	format(filename, sizeof(filename), "SSS/Vehicles/%s.dat", name);
	file = fopen(filename, io_write);
	fblockwrite(file, array, sizeof(array));
	fclose(file);

	return 1;
}

SetVehicleOwner(vehicleid, name[MAX_PLAYER_NAME], print = false)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(!isnull(veh_Owner[vehicleid]))
	{
		if(strcmp(veh_Owner[vehicleid], name))
			RemovePlayerVehicleFile(vehicleid, print);
	}

	veh_Owner[vehicleid] = name;

	for(new i; i < MAX_SPAWNED_VEHICLES; i++)
	{
		if(i == vehicleid)
			continue;

		if(!strcmp(veh_Owner[i], veh_Owner[vehicleid]))
			veh_Owner[i][0] = EOS;
	}

	return 1;
}

RemovePlayerVehicleFile(vehicleid, print = true)
{
	new owner[MAX_PLAYER_NAME];

	GetVehicleOwner(vehicleid, owner);

	if(isnull(owner))
		return 0;

	if(print)
		printf("[DELT] Removing vehicle: %d for player: %s", vehicleid, owner);

	new filename[MAX_PLAYER_NAME + 18];

	format(filename, sizeof(filename), "SSS/Vehicles/%s.dat", owner);
	fremove(filename);

	return 1;
}
