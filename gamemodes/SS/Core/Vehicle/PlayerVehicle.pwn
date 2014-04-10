#include <YSI\y_hooks>


// Old directories for conversion
#define DIRECTORY_VEHICLE_DAT		DIRECTORY_MAIN"VehicleDat/"
#define DIRECTORY_VEHICLE_INV		DIRECTORY_MAIN"VehicleInv/"


static
	vehicle_ItemList[ITM_LST_OF_ITEMS(64)];


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
	VEH_CELL_KEY,		// 14
	VEH_CELL_LOCKED,	// 15
	VEH_CELL_END
}


/*==============================================================================

	Save and Load (all)

==============================================================================*/


SavePlayerVehicles(printeach = false, printtotal = false)
{
	new
		count,
		owner[MAX_PLAYER_NAME];

	for(new i = 1; i < MAX_SPAWNED_VEHICLES; i++)
	{
		owner[0] = EOS;
		GetVehicleOwner(i, owner);

		if(strlen(owner) >= 3)
		{
			if(!IsValidVehicleID(i))
			{
				if(printeach)
					printf("ERROR: Saving vehicle ID %d for %s. Invalid vehicle ID", i, owner);

				RemoveVehicleFile(owner, printeach);
				continue;
			}

			if(veh_BitData[i] & veh_Dead)
			{
				if(printeach)
					printf("ERROR: Saving vehicle ID %d for %s. Vehicle is dead.", i, owner);

				RemoveVehicleFile(owner, printeach);
				continue;
			}

			UpdateVehicleFile(i, printeach);
			count++;
		}
	}

	if(printtotal)
		printf("Saved %d Player vehicles\n", count);
}

LoadPlayerVehicles(printeach = false, printtotal = false)
{
	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE),
		item[28],
		type;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			LoadPlayerVehicle(item, printeach);
		}
	}

	dir_close(direc);

	// If no vehicles were loaded, load the old format
	// This should only ever happen once (upon transition to this new version)
	if(Iter_Count(veh_Index) == 0 && dir_exists(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE_DAT))
		OLD_LoadPlayerVehicles(printeach, printtotal);

	if(printtotal)
		printf("Loaded %d Player vehicles\n", Iter_Count(veh_Index));

	return 1;
}


/*==============================================================================

	Load vehicle (individual)

==============================================================================*/


LoadPlayerVehicle(username[], prints)
{
	new
		filename[64],
		vehicleid,
		vehicletype,
		owner[MAX_PLAYER_NAME],
		containerid,
		data[VEH_CELL_END],
		length;

	filename = DIRECTORY_VEHICLE;
	strcat(filename, username);

	length = modio_read(filename, !"DATA", data, false, false);

	if(length == 0)
		return 0;

	if(!(400 <= data[VEH_CELL_MODEL] <= 612))
	{
		printf("ERROR: Removing Vehicle file: %s. Invalid model ID %d.", username, data[VEH_CELL_MODEL]);
		fremove(filename);
		return 0;
	}

	if(Float:data[VEH_CELL_HEALTH] < 255.5)
	{
		printf("ERROR: Removing Vehicle %s file: %s due to low health.", VehicleNames[data[VEH_CELL_MODEL]-400], username);
		fremove(filename);
		return 0;
	}

	vehicletype = GetVehicleType(data[VEH_CELL_MODEL]);

	if(vehicletype == VTYPE_TRAIN)
	{
		printf("ERROR: Removing Vehicle %s file: %s because train.", VehicleNames[data[VEH_CELL_MODEL]-400], username);
		fremove(filename);
		return 0;
	}

	if(vehicletype != VTYPE_SEA)
	{
		if(!IsPointInMapBounds(Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]))
		{
			if(vehicletype == VTYPE_HELI || vehicletype == VTYPE_PLANE)
			{
				data[VEH_CELL_POSZ] = _:(Float:data[VEH_CELL_POSZ] + 10.0);
			}
			else
			{
				printf("ERROR: Removing Vehicle %s file: %s because it's out of the map bounds.", VehicleNames[data[VEH_CELL_MODEL]-400], username);
				fremove(filename);

				return 0;
			}
		}
	}

	strmid(owner, username, 0, strlen(username) - 4);

	vehicleid = CreateVehicle(
		data[VEH_CELL_MODEL],
		Float:data[VEH_CELL_POSX],
		Float:data[VEH_CELL_POSY],
		Float:data[VEH_CELL_POSZ],
		Float:data[VEH_CELL_ROTZ],
		data[VEH_CELL_COL1],
		data[VEH_CELL_COL2],
		86400);

	if(!IsValidVehicleID(vehicleid))
		return 0;

	SetVehicleSpawnPoint(vehicleid,
		Float:data[VEH_CELL_POSX],
		Float:data[VEH_CELL_POSY],
		Float:data[VEH_CELL_POSZ],
		Float:data[VEH_CELL_ROTZ]);

	veh_Owner[vehicleid] = owner;

	if(prints)
		printf("\t[LOAD] Vehicle %d (%s): %s for %s at %f, %f, %f", vehicleid, data[VEH_CELL_LOCKED] ? ("L") : ("U"), VehicleNames[data[VEH_CELL_MODEL]-400], owner, data[VEH_CELL_POSX], data[VEH_CELL_POSY], data[VEH_CELL_POSZ], data[VEH_CELL_ROTZ]);

	Iter_Add(veh_Index, vehicleid);

	if(Float:data[VEH_CELL_HEALTH] > 990.0)
		data[VEH_CELL_HEALTH] = _:990.0;

	veh_Data[vehicleid][veh_health]				= Float:data[VEH_CELL_HEALTH];
	veh_Data[vehicleid][veh_Fuel]				= Float:data[VEH_CELL_FUEL];
	veh_Data[vehicleid][veh_panels]				= data[VEH_CELL_PANELS];
	veh_Data[vehicleid][veh_doors]				= data[VEH_CELL_DOORS];
	veh_Data[vehicleid][veh_lights]				= data[VEH_CELL_LIGHTS];
	veh_Data[vehicleid][veh_tires]				= data[VEH_CELL_TIRES];
	veh_Data[vehicleid][veh_armour]				= data[VEH_CELL_ARMOUR];
	veh_Data[vehicleid][veh_colour1]			= data[VEH_CELL_COL1];
	veh_Data[vehicleid][veh_colour2]			= data[VEH_CELL_COL2];
	veh_Data[vehicleid][veh_key]				= data[VEH_CELL_KEY];

	SetVehicleExternalLock(vehicleid, data[VEH_CELL_LOCKED]);

	if(VehicleFuelData[data[VEH_CELL_MODEL]-400][veh_trunkSize] > 0)
	{
		new
			ItemType:itemtype,
			itemid,
			itemlist;

		containerid = CreateContainer("Trunk", VehicleFuelData[data[VEH_CELL_MODEL]-400][veh_trunkSize], .virtual = 1);
		SetVehicleContainer(vehicleid, containerid);

		length = modio_read(filename, !"TRNK", vehicle_ItemList, true);

		itemlist = ExtractItemList(vehicle_ItemList, length);

		for(new i, j = GetItemListItemCount(itemlist); i < j; i++)
		{
			itemtype = GetItemListItem(itemlist, i);

			if(length == 0)
				break;

			if(itemtype == INVALID_ITEM_TYPE)
				break;

			if(itemtype == ItemType:0)
				break;

			itemid = CreateItem(itemtype);

			if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
				SetItemArrayDataFromListItem(itemid, itemlist, i);

			AddItemToContainer(containerid, itemid);
		}

		DestroyItemList(itemlist);
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


/*==============================================================================

	Save vehicle for a specific name

==============================================================================*/


SavePlayerVehicle(vehicleid, name[MAX_PLAYER_NAME], prints = false)
{
	UpdateVehicleOwner(vehicleid, name);
	UpdateVehicleFile(vehicleid, prints);

	return 1;
}

UpdateVehicleOwner(vehicleid, name[MAX_PLAYER_NAME], prints = false)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	new lastvehicleid;

	for(lastvehicleid = 1; lastvehicleid < MAX_SPAWNED_VEHICLES; lastvehicleid++)
	{
		if(lastvehicleid == vehicleid)
		{
			if(isnull(veh_Owner[lastvehicleid]))
				continue;

			if(!strcmp(veh_Owner[lastvehicleid], name))
				return 1;

			else
				continue;
		}

		if(isnull(veh_Owner[lastvehicleid]))
			continue;

		if(!strcmp(veh_Owner[lastvehicleid], name))
			veh_Owner[lastvehicleid][0] = EOS;
	}

	if(!isnull(veh_Owner[vehicleid]))
	{
		if(strcmp(veh_Owner[vehicleid], name))
			RemoveVehicleFileByID(vehicleid, prints);
	}

	veh_Owner[vehicleid] = name;

	return 1;
}


/*==============================================================================

	Write vehicle data to file

==============================================================================*/


UpdateVehicleFile(vehicleid, prints = false)
{
	new
		filename[MAX_PLAYER_NAME + 22],
		session,
		data[VEH_CELL_END];

	format(filename, sizeof(filename), DIRECTORY_VEHICLE"%s.dat", veh_Owner[vehicleid]);

	session = modio_getsession_write(filename);

	if(session != -1)
		modio_close_session_write(session);

	data[VEH_CELL_MODEL] = GetVehicleModel(vehicleid);

	if(GetVehicleType(data[VEH_CELL_MODEL]) == VTYPE_TRAIN)
		return 0;

	GetVehicleHealth(vehicleid, Float:data[1]);

	data[VEH_CELL_FUEL] = _:GetVehicleFuel(vehicleid);
	GetVehiclePos(vehicleid, Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);
	GetVehicleZAngle(vehicleid, Float:data[VEH_CELL_ROTZ]);
	data[VEH_CELL_COL1] = veh_Data[vehicleid][veh_colour1];
	data[VEH_CELL_COL2] = veh_Data[vehicleid][veh_colour2];
	GetVehicleDamageStatus(vehicleid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
	data[VEH_CELL_ARMOUR] = 0;
	data[VEH_CELL_KEY] = veh_Data[vehicleid][veh_key];

	if(prints)
		printf("[SAVE] Vehicle %d (%s): %s for %s at %f, %f, %f", vehicleid, IsVehicleLocked(vehicleid) ? ("L") : ("U"), VehicleNames[data[VEH_CELL_MODEL]-400], veh_Owner[vehicleid], Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);

	if(!IsVehicleOccupied(vehicleid))
		data[VEH_CELL_LOCKED] = IsVehicleLocked(vehicleid);

	// push the data, forcewrite is false
	// forceclose is also false, the file will be closed on the next call
	// autowrite is set to false to stop the timer from going off
	modio_push(filename, !"DATA", VEH_CELL_END, data, false, false, false);

	new containerid = GetVehicleContainer(vehicleid);

	if(!IsValidContainer(containerid))
	{
		modio_close_session_write(modio_getsession_write(filename));
		return 1;
	}

	new
		items[64],
		itemcount,
		itemlist;

	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		items[i] = GetContainerSlotItem(containerid, i);

		if(!IsValidItem(items[i]))
			break;

		itemcount++;
	}

	itemlist = CreateItemList(items, itemcount);
	GetItemList(itemlist, vehicle_ItemList);

	// forcewrite is true, and forceclose is true by default.
	// File will be written and closed ready for the next call.
	// Resulting in reusing modio sessions instead of registering new ones.
	modio_push(filename, !"TRNK", GetItemListSize(itemlist), vehicle_ItemList, true, true);

	DestroyItemList(itemlist);

	return 1;
}

RemoveVehicleFileByID(vehicleid, prints = true)
{
	new owner[MAX_PLAYER_NAME];

	GetVehicleOwner(vehicleid, owner);

	return RemoveVehicleFile(owner, prints);
}

RemoveVehicleFile(owner[MAX_PLAYER_NAME], prints = true)
{
	if(isnull(owner))
		return 0;

	if(prints)
		printf("[DELT] Removing player vehicle. Owner: %s", owner);

	new filename[MAX_PLAYER_NAME + 22];

	format(filename, sizeof(filename), DIRECTORY_VEHICLE"%s.dat", owner);
	fremove(filename);

	return 1;
}


/*==============================================================================

	Legacy format (Load only)

==============================================================================*/


OLD_LoadPlayerVehicles(printeach = false, printtotal = false)
{
	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE_DAT),
		item[28],
		type;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			OLD_LoadPlayerVehicle(item, printeach);
		}
	}

	dir_close(direc);

	dir_delete(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE_DAT);
	dir_delete(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE_INV);

	SavePlayerVehicles(printeach, printtotal);

	if(printtotal)
		printf("Loaded %d Player vehicles (old format)\n", Iter_Count(veh_Index));

	return 1;
}

OLD_LoadPlayerVehicle(filename[], prints)
{
	new
		File:file,
		filedir[64],
		vehicleid,
		vehicletype,
		owner[MAX_PLAYER_NAME],
		containerid,
		array_data[VEH_CELL_END],
		array_inv[CNT_MAX_SLOTS * 3],
		itemid;

	filedir = DIRECTORY_VEHICLE_DAT;
	strcat(filedir, filename);

	if(strlen(filename) < 3)
	{
		fremove(filedir);
		return 0;
	}

	file = fopen(filedir, io_read);

	if(!file)
		return 0;

	fblockread(file, array_data, sizeof(array_data));
	fclose(file);

	if(!(400 <= array_data[VEH_CELL_MODEL] <= 612))
	{
		printf("ERROR: Removing Vehicle file: %s. Invalid model ID %d.", filename, array_data[VEH_CELL_MODEL]);
		fremove(filedir);
		return 0;
	}

	if(Float:array_data[VEH_CELL_HEALTH] < 255.5)
	{
		printf("ERROR: Removing Vehicle %s file: %s due to low health.", VehicleNames[array_data[VEH_CELL_MODEL]-400], filename);
		fremove(filedir);
		return 0;
	}

	vehicletype = GetVehicleType(array_data[VEH_CELL_MODEL]);

	if(vehicletype == VTYPE_TRAIN)
	{
		printf("ERROR: Removing Vehicle %s file: %s because train.", VehicleNames[array_data[VEH_CELL_MODEL]-400], filename);
		fremove(filedir);
		return 0;
	}

	if(vehicletype != VTYPE_SEA)
	{
		if(!IsPointInMapBounds(Float:array_data[VEH_CELL_POSX], Float:array_data[VEH_CELL_POSY], Float:array_data[VEH_CELL_POSZ]))
		{
			if(vehicletype == VTYPE_HELI || vehicletype == VTYPE_PLANE)
			{
				array_data[VEH_CELL_POSZ] = _:(Float:array_data[VEH_CELL_POSZ] + 10.0);
			}
			else
			{
				printf("ERROR: Removing Vehicle %s file: %s because it's out of the map bounds.", VehicleNames[array_data[VEH_CELL_MODEL]-400], filename);
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
		array_data[VEH_CELL_MODEL],
		Float:array_data[VEH_CELL_POSX],
		Float:array_data[VEH_CELL_POSY],
		Float:array_data[VEH_CELL_POSZ],
		Float:array_data[VEH_CELL_ROTZ],
		array_data[VEH_CELL_COL1],
		array_data[VEH_CELL_COL2],
		86400);

	if(!IsValidVehicleID(vehicleid))
		return 0;

	SetVehicleSpawnPoint(vehicleid,
		Float:array_data[VEH_CELL_POSX],
		Float:array_data[VEH_CELL_POSY],
		Float:array_data[VEH_CELL_POSZ],
		Float:array_data[VEH_CELL_ROTZ]);

	veh_Owner[vehicleid] = owner;

	if(prints)
		printf("\t[LOAD] [OLD] Vehicle %d (%s): %s for %s at %f, %f, %f", vehicleid, array_data[VEH_CELL_LOCKED] ? ("L") : ("U"), VehicleNames[array_data[VEH_CELL_MODEL]-400], owner, array_data[VEH_CELL_POSX], array_data[VEH_CELL_POSY], array_data[VEH_CELL_POSZ], array_data[VEH_CELL_ROTZ]);

	Iter_Add(veh_Index, vehicleid);

	if(Float:array_data[VEH_CELL_HEALTH] > 990.0)
		array_data[VEH_CELL_HEALTH] = _:990.0;

	veh_Data[vehicleid][veh_health]				= Float:array_data[VEH_CELL_HEALTH];
	veh_Data[vehicleid][veh_Fuel]				= Float:array_data[VEH_CELL_FUEL];
	veh_Data[vehicleid][veh_panels]				= array_data[VEH_CELL_PANELS];
	veh_Data[vehicleid][veh_doors]				= array_data[VEH_CELL_DOORS];
	veh_Data[vehicleid][veh_lights]				= array_data[VEH_CELL_LIGHTS];
	veh_Data[vehicleid][veh_tires]				= array_data[VEH_CELL_TIRES];
	veh_Data[vehicleid][veh_armour]				= array_data[VEH_CELL_ARMOUR];
	veh_Data[vehicleid][veh_colour1]			= array_data[VEH_CELL_COL1];
	veh_Data[vehicleid][veh_colour2]			= array_data[VEH_CELL_COL2];
	veh_Data[vehicleid][veh_key]				= array_data[VEH_CELL_KEY];

	SetVehicleExternalLock(vehicleid, array_data[VEH_CELL_LOCKED]);

	if(VehicleFuelData[array_data[VEH_CELL_MODEL]-400][veh_trunkSize] > 0)
	{
		filedir = DIRECTORY_VEHICLE_INV;
		strcat(filedir, filename);

		file = fopen(filedir, io_read);

		if(!file)
		{
			printf("ERROR: Vehicle inventory file for '%s' is missing!", filedir);
			return 0;
		}

		fblockread(file, array_inv, sizeof(array_inv));
		fclose(file);

		containerid = CreateContainer("Trunk", VehicleFuelData[array_data[VEH_CELL_MODEL]-400][veh_trunkSize], .virtual = 1);
		SetVehicleContainer(vehicleid, containerid);

		for(new i, j; j < CNT_MAX_SLOTS; i += 3, j++)
		{
			if(!IsValidItemType(ItemType:array_inv[i]) || array_inv[i] == 0)
				continue;

			itemid = CreateItem(ItemType:array_inv[i], 0.0, 0.0, 0.0);

			if(array_inv[i + 1] == 1)
			{
				if(!IsItemTypeSafebox(ItemType:array_inv[i]) && !IsItemTypeBag(ItemType:array_inv[i]))
				{
					SetItemExtraData(itemid, array_inv[i + 2]);
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
