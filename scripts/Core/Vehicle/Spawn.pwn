#include <YSI\y_hooks>


#define VEHICLE_INDEX_FILE			"vehicles/index.ini"
#define VEHICLE_DATA_FILE			"vehicles/%s.dat"
#define VEHICLE_SPAWN_CHANCE		(4) // Percent


enum (<<=1)
{
		veh_Used = 1,
		veh_Occupied,
		veh_Player,
		veh_Dead
}

enum E_VEHICLE_DATA
{
Float:	veh_health,
Float:	veh_Fuel,
		veh_engine,
		veh_panels,
		veh_doors,
		veh_lights,
		veh_tires,
		veh_armour,
		veh_colour1,
		veh_colour2
}


new
			veh_Data				[MAX_SPAWNED_VEHICLES][E_VEHICLE_DATA],
			veh_BitData				[MAX_SPAWNED_VEHICLES],
Iterator:	veh_Index<MAX_SPAWNED_VEHICLES>;

new
			veh_TrunkLock			[MAX_SPAWNED_VEHICLES],
			veh_Area				[MAX_SPAWNED_VEHICLES],
			veh_Container			[MAX_SPAWNED_VEHICLES],
			veh_Owner				[MAX_SPAWNED_VEHICLES][MAX_PLAYER_NAME],
			veh_CurrentModelGroup;


LoadVehicles(bool:prints = false)
{
	LoadPlayerVehicles(prints);
	LoadAllVehicles();
	LoadStaticVehiclesFromFile("vehicles/special/trains.dat");

	if(prints)
		printf("Total Vehicles: %d", Iter_Count(veh_Index));
}

LoadAllVehicles(bool:prints = false)
{
	new
		File:f=fopen(VEHICLE_INDEX_FILE, io_read),
		line[128],
		str[128];

	while(fread(f, line))
	{
		if(line[strlen(line)-2] == '\r')line[strlen(line) - 2] = EOS;
		format(str, 128, VEHICLE_DATA_FILE, line);
		LoadVehiclesFromFile(str, prints);
	}

	fclose(f);
}

LoadStaticVehiclesFromFile(file[], bool:prints = false)
{
	if(!fexist(file))return print("VEHICLE FILE NOT FOUND");

	new
		File:f = fopen(file, io_read),
		line[128],
		Float:posX,
		Float:posY,
		Float:posZ,
		Float:rotZ,
		model,
		count;

	while(fread(f, line))
	{
		if(!sscanf(line, "p<,>ffffD(0)", posX, posY, posZ, rotZ, model))
		{
			new id;
			id = AddStaticVehicle(model, posX, posY, posZ, rotZ, -1, -1);

			GenerateVehicleData(id);
			SetVehicleData(id);
			Iter_Add(veh_Index, id);

			count++;
		}
	}
	fclose(f);

	if(prints)
		printf("Loaded %d vehicles from %s", count, file);

	return 1;
}


LoadVehiclesFromFile(file[], bool:prints = false)
{
	if(!fexist(file))
	{
		print("VEHICLE FILE NOT FOUND");
		return 0;
	}

	new
		File:f = fopen(file, io_read),
		line[128],
		modelgroupname[28],
		Float:posX,
		Float:posY,
		Float:posZ,
		Float:rotZ,
		model,
		tmpid,
		count;

	while(fread(f, line))
	{
		if(!sscanf(line, "p<,>ffffD(-1)", posX, posY, posZ, rotZ, model))
		{
			if(tmpid - 1 >= MAX_SPAWNED_VEHICLES)
				break;

			if(random(100) < 100 - VEHICLE_SPAWN_CHANCE)
				continue;

			if(model == -1)
			{
				model = PickRandomVehicleFromGroup(veh_CurrentModelGroup);
			}
			else if(0 <= model <= 12)
			{
				model = PickRandomVehicleFromGroup(model);
			}
			else if(400 <= model < 612)
			{
				if(frandom(1.0) > VehicleFuelData[model - 400][veh_spawnRate])
					continue;
			}
			else
			{
				continue;
			}

			switch(model)
			{
				case 403, 443, 514, 515:
				{
					posZ += 2.0;
				}
			}

			switch(veh_CurrentModelGroup)
			{
				case VEHICLE_GROUP_CASUAL, VEHICLE_GROUP_TRUCK_S, VEHICLE_GROUP_SPORT, VEHICLE_GROUP_BIKE:
				{
					rotZ += random(2) ? 0.0 : 180.0;
				}
			}

			tmpid = CreateNewVehicle(model, posX, posY, posZ, rotZ);

			if(!IsValidVehicleID(tmpid))
				continue;

			Iter_Add(veh_Index, tmpid);

			count++;
		}
		else
		{
			if(!sscanf(line, "'MODELGROUP:'s[28]", modelgroupname))
			{
				strtrim(modelgroupname);

				new newgroup = GetVehicleGroupFromName(modelgroupname);

				if(newgroup != -1 && newgroup != veh_CurrentModelGroup)
					veh_CurrentModelGroup = newgroup;
			}
			else
			{
				if(strlen(line) > 3)
					print("LINE ERROR");
			}
		}
	}
	fclose(f);

	if(prints)
		printf("\t-Loaded %d vehicles from %s", count, file);

	return 1;
}

CreateNewVehicle(model, Float:x, Float:y, Float:z, Float:r)
{
	if(!(400 <= model < 612))
		return 0;

	new
		vehicleid,
		colour1,
		colour2;

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

	vehicleid = CreateVehicle(model, x, y, z, r, colour1, colour2, 86400);

	if(vehicleid >= MAX_SPAWNED_VEHICLES)
	{
		print("ERROR: Vehicle limit reached.");
		DestroyVehicle(vehicleid);
		return 0;
	}

	veh_Data[vehicleid][veh_colour1] = colour1;
	veh_Data[vehicleid][veh_colour2] = colour2;

	CreateVehicleArea(vehicleid);
	GenerateVehicleData(vehicleid);
	SetVehicleData(vehicleid);

	return vehicleid;
}

CreateVehicleArea(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	new
		Float:x,
		Float:y,
		Float:z;

	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, x, y, z);

	veh_Area[vehicleid] = CreateDynamicSphere(0.0, 0.0, 0.0, (y / 2.0) + 3.0, 0);
	AttachDynamicAreaToVehicle(veh_Area[vehicleid], vehicleid);

	return 1;
}

RespawnVehicle(vehicleid)
{
	SetVehicleToRespawn(vehicleid);
	SetVehicleData(vehicleid);
}

GenerateVehicleData(vehicleid)
{
	new
		model,
		type,
		chance,
		panels,
		doors,
		lights,
		tires;

	model = GetVehicleModel(vehicleid);
	type = GetVehicleType(model);

// Health

	chance = random(100);

	if(chance < 1)
		veh_Data[vehicleid][veh_health] = 500 + random(200);

	else if(chance < 5)
		veh_Data[vehicleid][veh_health] = 400 + random(200);

	else
		veh_Data[vehicleid][veh_health] = 300 + random(200);

	SetVehicleHealth(vehicleid, veh_Data[vehicleid][veh_health]);

// Fuel

	chance = random(100);

	if(chance < 1)
		veh_Data[vehicleid][veh_Fuel] = VehicleFuelData[model-400][veh_maxFuel] / 2 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 2);

	else if(chance < 5)
		veh_Data[vehicleid][veh_Fuel] = VehicleFuelData[model-400][veh_maxFuel] / 4 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 3);

	else if(chance < 10)
		veh_Data[vehicleid][veh_Fuel] = VehicleFuelData[model-400][veh_maxFuel] / 8 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 4);

	else
		veh_Data[vehicleid][veh_Fuel] = frandom(1.0);

// Visual Damage

	if(type < VTYPE_BICYCLE)
	{
		veh_Data[vehicleid][veh_panels]	= encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4));
		veh_Data[vehicleid][veh_doors]	= encode_doors(random(5), random(5), random(5), random(5));
		veh_Data[vehicleid][veh_lights] = encode_lights(random(2), random(2), random(2), random(2));
		veh_Data[vehicleid][veh_tires] = encode_tires(random(2), random(2), random(2), random(2));

		UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	}
	if(type == VTYPE_PLANE)
	{
		veh_Data[vehicleid][veh_panels]	= encode_panels(0, 0, random(4), 0, random(4), 0, 0);
	}


// Locks

	if(VehicleFuelData[model - 400][veh_maxFuel] == 0.0)
	{
		SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);
	}
	else
	{
		new locked;

		if(doors == 0)
			locked = random(2);

		if(panels == 0)
			veh_TrunkLock[vehicleid] = random(2);

		SetVehicleParamsEx(vehicleid, 0, random(2), !random(100), locked, random(2), random(2), 0);
	}

// Putting loot in trunks

	if(VehicleFuelData[model - 400][veh_lootIndex] != -1 && 0 < VehicleFuelData[model - 400][veh_trunkSize] <= CNT_MAX_SLOTS)
	{
		veh_Container[vehicleid] = CreateContainer("Trunk", VehicleFuelData[model-400][veh_trunkSize], .virtual = 1);
		FillContainerWithLoot(veh_Container[vehicleid], random(4), VehicleFuelData[model-400][veh_lootIndex]);
	}
	else
	{
		veh_Container[vehicleid] = INVALID_CONTAINER_ID;
	}

// Number plate

	SetVehicleNumberPlate(vehicleid, RandomNumberPlateString());
}

SetVehicleData(vehicleid)
{
	SetVehicleHealth(vehicleid, veh_Data[vehicleid][veh_health]);

	UpdateVehicleDamageStatus(vehicleid, veh_Data[vehicleid][veh_panels], veh_Data[vehicleid][veh_doors], veh_Data[vehicleid][veh_lights], veh_Data[vehicleid][veh_tires]);

	if(GetVehicleType(GetVehicleModel(vehicleid)) == VTYPE_BICYCLE)
		SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);

	else
		SetVehicleParamsEx(vehicleid, 0, 0, 0, 0, 0, 0, 0);

	return 1;
}



public OnVehicleDeath(vehicleid)
{
	t:veh_BitData[vehicleid]<veh_Dead>;
	printf("Vehicle %d Died", vehicleid);
}

public OnVehicleSpawn(vehicleid)
{
	if(veh_BitData[vehicleid] & veh_Dead)
	{
		printf("Dead Vehicle %d Spawned, destroying.", vehicleid);

		if(IsValidContainer(veh_Container[vehicleid]))
			DestroyContainer(veh_Container[vehicleid]);

		DestroyDynamicArea(veh_Area[vehicleid]);
		DestroyVehicle(vehicleid);
		Iter_Remove(veh_Index, vehicleid);
	}
}


hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(oldstate == PLAYER_STATE_DRIVER)
	{
		new name[MAX_PLAYER_NAME];

		GetPlayerName(playerid, name, MAX_PLAYER_NAME);

		SavePlayerVehicle(GetPlayerLastVehicle(playerid), name, true);
		SetCameraBehindPlayer(playerid);
	}
}

RandomNumberPlateString()
{
	new str[9];
	for(new c; c < 8; c++)
	{
		if(c<4)str[c] = 'A' + random(26);
		else if(c>4)str[c] = '0' + random(10);
		str[4] = ' ';
	}
	return str;
}


/*==============================================================================


	Interface


==============================================================================*/

stock IsPlayerInVehicleArea(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
			return 0;

	if(!IsValidVehicleID(vehicleid))
		return 0;

	return IsPlayerInDynamicArea(playerid, veh_Area[vehicleid]);
}

forward Float:GetVehicleFuelCapacity(vehicleid);
stock Float:GetVehicleFuelCapacity(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0.0;

	return VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel];
}

forward Float:GetVehicleFuel(vehicleid);
stock Float:GetVehicleFuel(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0.0;

	return veh_Data[vehicleid][veh_Fuel];
}

stock SetVehicleFuel(vehicleid, Float:amount)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(amount > VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel])
		amount = VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel];

	veh_Data[vehicleid][veh_Fuel] = amount;

	return 1;
}

stock GiveVehicleFuel(vehicleid, Float:amount)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	veh_Data[vehicleid][veh_Fuel] += amount;

	if(veh_Data[vehicleid][veh_Fuel] > VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel])
		veh_Data[vehicleid][veh_Fuel] = VehicleFuelData[GetVehicleModel(vehicleid) - 400][veh_maxFuel];

	return 1;
}

stock GetVehicleOwner(vehicleid, name[MAX_PLAYER_NAME])
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	name = veh_Owner[vehicleid];

	return 1;
}

stock GetVehicleContainer(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return INVALID_CONTAINER_ID;

	return veh_Container[vehicleid];
}

stock SetVehicleContainer(vehicleid, containerid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	veh_Container[vehicleid] = containerid;

	return 1;
}

stock IsVehicleTrunkLocked(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	return veh_TrunkLock[vehicleid];
}

stock SetVehicleTrunkLock(vehicleid, toggle)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	veh_TrunkLock[vehicleid] = toggle;
	return 1;
}

stock SetVehicleUsed(vehicleid, toggle)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(toggle)
		t:veh_BitData[vehicleid]<veh_Used>;

	else
		f:veh_BitData[vehicleid]<veh_Used>;

	return 1;
}

stock SetVehicleOccupied(vehicleid, toggle)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	if(toggle)
		t:veh_BitData[vehicleid]<veh_Occupied>;

	else
		f:veh_BitData[vehicleid]<veh_Occupied>;

	return 1;
}

stock GetVehicleArea(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return -1;

	return veh_Area[vehicleid];
}

stock IsVehicleOccupied(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	return veh_BitData[vehicleid] & veh_Occupied;
}

stock IsValidVehicleID(vehicleid)
{
	if(IsValidVehicle(vehicleid) && vehicleid < MAX_SPAWNED_VEHICLES)
		return 1;

	return 0;
}

stock GetVehicleEngine(vehicleid)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	return veh_Data[vehicleid][veh_engine];
}

stock SetVehicleEngine(vehicleid, toggle)
{
	if(!IsValidVehicleID(vehicleid))
		return 0;

	veh_Data[vehicleid][veh_engine] = toggle;
	VehicleEngineState(vehicleid, toggle);

	return 1;
}

