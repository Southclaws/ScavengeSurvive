#include <YSI\y_hooks>

#define MAX_SPAWNED_VEHICLES		(400)
#define VEHICLE_INDEX_FILE			"vehicles/index.ini"
#define VEHICLE_DATA_FILE			"vehicles/%s.dat"
#define PLAYER_VEHICLE_DIRECTORY	"./scriptfiles/SSS/Vehicles/"
#define PLAYER_VEHICLE_FILE			"SSS/Vehicles/%s.dat"


enum (<<=1)
{
	v_Used = 1,
	v_Occupied,
	v_Player,
	v_Dead
}
enum E_PLAYER_VEHICLE_DATA
{
	Float:pv_health,
	pv_panels,
	pv_doors,
	pv_lights,
	pv_tires,
	pv_armour
}


new
			gTotalVehicles,
			gCurModelGroup,
			bVehicleSettings[MAX_VEHICLES],
Iterator:	gVehicleIndex<MAX_VEHICLES>,
Float:		gVehicleFuel[MAX_VEHICLES],
			gVehicleTrunkLocked[MAX_VEHICLES],
			gVehicleArea[MAX_VEHICLES],
			gVehicleContainer[MAX_VEHICLES],
			gVehicleOwner[MAX_VEHICLES][MAX_PLAYER_NAME],
			gVehicleColours[MAX_VEHICLES][2],
			gPlayerVehicleData[MAX_VEHICLES][E_PLAYER_VEHICLE_DATA];

new
			gCurrentContainerVehicle[MAX_PLAYERS];


LoadVehicles(bool:prints = true)
{
	LoadPlayerVehicles(prints);
	LoadAllVehicles();
	LoadStaticVehiclesFromFile("vehicles/special/trains.dat");

	defer ApplyVehicleConditionToAll();

	if(prints)
		printf("Total Vehicles: %d", gTotalVehicles);
}
SaveVehicles(prints)
{
	for(new i; i < MAX_VEHICLES; i++)
	{
		if(IsValidVehicle(i))
		{
			if(strlen(gVehicleOwner[i]) >= 3)
				SavePlayerVehicle(i, gVehicleOwner[i], prints);
		}
		else
		{
			if(strlen(gVehicleOwner[i]) >= 3)
				RemovePlayerVehicle(i);
		}
	}

    gTotalVehicles = 0;
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

			if(GetVehicleType(model) == VTYPE_TRAIN)
			{
				Iter_Add(gVehicleIndex, id);
				ApplyVehicleData(id);
			}

			gTotalVehicles++;
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
		tmpid;

	while(fread(f, line) && gTotalVehicles < MAX_SPAWNED_VEHICLES)
	{
		if(!sscanf(line, "p<,>ffffD(-1)", posX, posY, posZ, rotZ, model))
		{
			if(tmpid >= MAX_SPAWNED_VEHICLES)
				break;

			if(random(100) < 95)
				continue;

			if(model == -1)
			{
				model = PickRandomVehicleFromGroup(gCurModelGroup);
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

			switch(gCurModelGroup)
			{
				case VEHICLE_GROUP_CASUAL, VEHICLE_GROUP_TRUCK_S, VEHICLE_GROUP_SPORT, VEHICLE_GROUP_BIKE:
				{
					rotZ += random(2) ? 0.0 : 180.0;
				}
			}

			tmpid = CreateVehicle(model, posX, posY, posZ, rotZ, -1, -1, 86400);

			if(IsValidVehicle(tmpid))
			{
				Iter_Add(gVehicleIndex, tmpid);

				switch(model)
				{
					case 416, 433, 523, 427, 490, 528, 407, 544, 596, 597, 598, 599, 432, 601:
					{
						gVehicleColours[tmpid][0] = -1;
						gVehicleColours[tmpid][1] = -1;
					}
					default:
					{
						gVehicleColours[tmpid][0] = 128 + random(128);
						gVehicleColours[tmpid][1] = 128 + random(128);
					}
				}
				ChangeVehicleColor(tmpid, gVehicleColours[tmpid][0], gVehicleColours[tmpid][1]);
				gTotalVehicles++;
			}
		}
		else
		{
			if(!sscanf(line, "'MODELGROUP:'s[28]", modelgroupname))
			{
				strtrim(modelgroupname);

				new newgroup = GetVehicleGroupFromName(modelgroupname);

				if(newgroup != -1 && newgroup != gCurModelGroup)
					gCurModelGroup = newgroup;
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
		printf("\t-Loaded %d vehicles from %s", gTotalVehicles, file);

	return 1;
}

LoadPlayerVehicles(bool:prints = true)
{
	new
		dir:direc = dir_open(PLAYER_VEHICLE_DIRECTORY),
		item[28],
		type,
		File:file,
		filedir[64],
		vehicleid;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			new
				array[14 + (CNT_MAX_SLOTS * 3)],
				itemid;

			filedir = "SSS/Vehicles/";
			strcat(filedir, item);
			file = fopen(filedir, io_read);

			if(file)
			{
				if(strlen(item) <= 4)
				{
					fclose(file);
					fremove(filedir);
					continue;
				}
				fblockread(file, array, sizeof(array));
				fclose(file);

				if(!(400 <= array[0] <= 612))
				{
					printf("ERROR: Removing Vehicle file: %s. Invalid model ID.", item);
					fremove(filedir);
					continue;
				}

				if(Float:array[1] < 255.5)
				{
					printf("ERROR: Removing Vehicle %s file: %s due to low health.", VehicleNames[array[0]-400], item);
					fremove(filedir);
					continue;
				}

				if(GetVehicleType(array[0]) == VTYPE_TRAIN)
				{
					printf("ERROR: Removing Vehicle %s file: %s because train.", VehicleNames[array[0]-400], item);
					fremove(filedir);
					continue;
				}

				if(GetVehicleType(array[0]) != VTYPE_BOAT)
				{
					if(Float:array[3] > 3000.0 ||
						Float:array[3] < -3000.0 ||
						Float:array[4] > 3000.0 ||
						Float:array[4] < -3000.0)
						array[5] = _:(Float:array[5] + 2.0);
				}

				vehicleid = CreateVehicle(array[0], Float:array[3], Float:array[4], Float:array[5], Float:array[6], array[7], array[8], 86400);

				strmid(gVehicleOwner[vehicleid], item, 0, strlen(item) - 4);

				if(strlen(gVehicleOwner[vehicleid]) < 3)
				{
					printf("ERROR: Vehicle owner name is invalid: '%s' Length: %d", gVehicleOwner[vehicleid], strlen(gVehicleOwner[vehicleid]));
					DestroyVehicle(vehicleid);
					fremove(filedir);
					continue;
				}

				printf("\t[LOAD] vehicle %d: %s for %s", vehicleid, VehicleNames[array[0]-400], gVehicleOwner[vehicleid]);

				if(IsValidVehicle(vehicleid))
				{
					Iter_Add(gVehicleIndex, vehicleid);

					if(Float:array[1] > 990.0)
						array[1] = _:990.0;

					gVehicleFuel[vehicleid]						= Float:array[2];
					gVehicleColours[vehicleid][0]				= array[7];
					gVehicleColours[vehicleid][1]				= array[8];
					gPlayerVehicleData[vehicleid][pv_health]	= Float:array[1];
					gPlayerVehicleData[vehicleid][pv_panels]	= array[9];
					gPlayerVehicleData[vehicleid][pv_doors]		= array[10];
					gPlayerVehicleData[vehicleid][pv_lights]	= array[11];
					gPlayerVehicleData[vehicleid][pv_tires]		= array[12];
					gPlayerVehicleData[vehicleid][pv_armour]	= array[13];

					if(VehicleFuelData[array[0]-400][veh_trunkSize] > 0)
					{
						gVehicleContainer[vehicleid] = CreateContainer("Trunk", VehicleFuelData[array[0]-400][veh_trunkSize], .virtual = 1);
						for(new i, j; j < CNT_MAX_SLOTS; i += 3, j++)
						{
							if(!IsValidItemType(ItemType:array[14 + i]) || array[i + 14] == 0)
								continue;

							itemid = CreateItem(ItemType:array[14 + i], 0.0, 0.0, 0.0);

							if(array[14 + i + 1] == 1)
							{
								if(!IsItemTypeSafebox(ItemType:array[14 + i]) && !IsItemTypeBag(ItemType:array[14 + i]))
								{
									SetItemExtraData(itemid, array[14 + i + 2]);
								}

								AddItemToContainer(gVehicleContainer[vehicleid], itemid);
							}

						}
					}
					else
					{
						gVehicleContainer[vehicleid] = INVALID_CONTAINER_ID;
					}

					t:bVehicleSettings[vehicleid]<v_Player>;
					gTotalVehicles++;
				}
			}
		}
	}

	dir_close(direc);

	if(prints)
		printf("Loaded %d Player vehicles\n", gTotalVehicles);

	return;
}

SavePlayerVehicle(vehicleid, name[MAX_PLAYER_NAME], prints = false)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	if(isnull(name))
		return 0;

	new
		File:file,
		filename[MAX_PLAYER_NAME + 18],
		array[14 + (CNT_MAX_SLOTS * 3)],
		itemid;

	array[0] = GetVehicleModel(vehicleid);

	if(GetVehicleType(array[0]) == VTYPE_TRAIN)
		return 0;

	GetVehicleHealth(vehicleid, Float:array[1]);

	array[2] = _:gVehicleFuel[vehicleid];
	GetVehiclePos(vehicleid, Float:array[3], Float:array[4], Float:array[5]);
	GetVehicleZAngle(vehicleid, Float:array[6]);
	array[7] = gVehicleColours[vehicleid][0];
	array[8] = gVehicleColours[vehicleid][1];
	GetVehicleDamageStatus(vehicleid, array[9], array[10], array[11], array[12]);
	array[13] = 0;

	if(prints)
		printf("\t[SAVE] Vehicle %d: %s for %s", vehicleid, VehicleNames[array[0]-400], name);

	if(IsValidContainer(gVehicleContainer[vehicleid]))
	{
		for(new i, j; j < CNT_MAX_SLOTS; i += 3, j++)
		{
			if(IsContainerSlotUsed(gVehicleContainer[vehicleid], j))
			{
				itemid = GetContainerSlotItem(gVehicleContainer[vehicleid], j);
				array[14 + i] = _:GetItemType(itemid);
				array[14 + i + 1] = 1;
				array[14 + i + 2] = GetItemExtraData(itemid);

				if(array[14 + i] == 0)
					return 0;
			}
			else
			{
				array[14 + i] = -1;
				array[14 + i + 1] = 1;
				array[14 + i + 2] = 0;
			}
		}
	}

	if(!isnull(gVehicleOwner[vehicleid]))
	{
		if(strcmp(gVehicleOwner[vehicleid], name, true))
		{
			format(filename, sizeof(filename), PLAYER_VEHICLE_FILE, gVehicleOwner[vehicleid]);

			if(fexist(filename))
			{
				printf("[DELT] Removing vehicle: %s for player: %s", VehicleNames[array[0]-400], gVehicleOwner[vehicleid]);
				fremove(filename);
			}
		}
	}

	gVehicleOwner[vehicleid] = name;

	for(new i; i < MAX_VEHICLES; i++)
	{
		if(i == vehicleid)
			continue;

		if(!strcmp(gVehicleOwner[i], gVehicleOwner[vehicleid]))
			gVehicleOwner[i][0] = EOS;
	}

	format(filename, sizeof(filename), "SSS/Vehicles/%s.dat", gVehicleOwner[vehicleid]);
	file = fopen(filename, io_write);

	fblockwrite(file, array, sizeof(array));

	fclose(file);

	return 1;
}

RemovePlayerVehicle(vehicleid, prints = false)
{
	if(isnull(gVehicleOwner[vehicleid]))
		return 0;

	if(prints)
		printf("[DELT] Removing vehicle: %d for player: %s", vehicleid, gVehicleOwner[vehicleid]);

	new filename[MAX_PLAYER_NAME + 18];

	format(filename, sizeof(filename), "SSS/Vehicles/%s.dat", gVehicleOwner[vehicleid]);
	fremove(filename);

	return 1;
}

timer ApplyVehicleConditionToAll[1000]()
{
	foreach(new i : gVehicleIndex)
	{
		ApplyVehicleData(i);
	}
}

ApplyVehicleData(vehicleid)
{
	new
		model = GetVehicleModel(vehicleid),
		Float:sx,
		Float:sy,
		Float:sz;

	if(!(400 <= model < 612))
		return 0;

	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

	gVehicleArea[vehicleid] = CreateDynamicSphere(0.0, 0.0, 0.0, (sy / 2.0) + 3.0, 0);
	AttachDynamicAreaToVehicle(gVehicleArea[vehicleid], vehicleid);

	SetVehicleNumberPlate(vehicleid, RandomNumberPlateString());

	if(bVehicleSettings[vehicleid] & v_Player)
	{
		SetVehicleHealth(vehicleid, gPlayerVehicleData[vehicleid][pv_health]);

		if(GetVehicleType(GetVehicleModel(vehicleid)) == VTYPE_BMX)
			SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);

		else
			SetVehicleParamsEx(vehicleid, 0, 0, 0, 0, 0, 0, 0);

		UpdateVehicleDamageStatus(vehicleid,
			gPlayerVehicleData[vehicleid][pv_panels],
			gPlayerVehicleData[vehicleid][pv_doors],
			gPlayerVehicleData[vehicleid][pv_lights],
			gPlayerVehicleData[vehicleid][pv_tires]);
	}
	else
	{
		new
			chance = random(100),
			panels,
			doors,
			lights,
			tires;

		if(chance < 1)
			SetVehicleHealth(vehicleid, 500 + random(200));

		else if(chance < 5)
			SetVehicleHealth(vehicleid, 400 + random(200));

		else
			SetVehicleHealth(vehicleid, 300 + random(200));

		chance = random(100);

		if(chance < 1)
			gVehicleFuel[vehicleid] = VehicleFuelData[model-400][veh_maxFuel] / 2 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 2);

		else if(chance < 5)
			gVehicleFuel[vehicleid] = VehicleFuelData[model-400][veh_maxFuel] / 4 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 3);

		else if(chance < 10)
			gVehicleFuel[vehicleid] = VehicleFuelData[model-400][veh_maxFuel] / 8 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 4);

		else
			gVehicleFuel[vehicleid] = frandom(1.0);


		if(random(100) < 60)
			panels	= encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4));

		if(random(100) < 60)
			doors	= encode_doors(random(5), random(5), random(5), random(5), random(5), random(5));

		lights	= encode_lights(random(2), random(2), random(2), random(2));
		tires	= encode_tires(random(2), random(2), random(2), random(2));

		UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

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
				gVehicleTrunkLocked[vehicleid] = random(2);

			SetVehicleParamsEx(vehicleid, 0, random(2), !random(100), locked, random(2), random(2), 0);
		}

		if(VehicleFuelData[model - 400][veh_lootIndex] != -1 && 0 < VehicleFuelData[model - 400][veh_trunkSize] <= CNT_MAX_SLOTS)
		{
			gVehicleContainer[vehicleid] = CreateContainer("Trunk", VehicleFuelData[model-400][veh_trunkSize], .virtual = 1);
			FillContainerWithLoot(gVehicleContainer[vehicleid], random(4), VehicleFuelData[model-400][veh_lootIndex]);
		}
		else
		{
			gVehicleContainer[vehicleid] = INVALID_CONTAINER_ID;
		}
	}

	return 1;
}

public OnVehicleDeath(vehicleid)
{
	t:bVehicleSettings[vehicleid]<v_Dead>;
	printf("Vehicle %d Died", vehicleid);
}

public OnVehicleSpawn(vehicleid)
{
	if(bVehicleSettings[vehicleid] & v_Dead)
	{
		printf("Dead Vehicle %d Spawned, destroying.", vehicleid);

		if(IsValidContainer(gVehicleContainer[vehicleid]))
		{
			for(new i; i < CNT_MAX_SLOTS; i++)
			{
				DestroyItem(GetContainerSlotItem(gVehicleContainer[vehicleid], i));
			}
			DestroyContainer(gVehicleContainer[vehicleid]);
		}

		DestroyDynamicArea(gVehicleArea[vehicleid]);
		DestroyVehicle(vehicleid);
		Iter_Remove(gVehicleIndex, vehicleid);
	}
}


hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(oldstate == PLAYER_STATE_DRIVER)
	{
		SetCameraBehindPlayer(playerid);
		SavePlayerVehicle(gPlayerVehicleID[playerid], gPlayerName[playerid], true);
	}
}

public OnItemAddedToContainer(containerid, itemid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(IsValidVehicle(gCurrentContainerVehicle[playerid]))
		{
			if(!isnull(gVehicleOwner[gCurrentContainerVehicle[playerid]]) && !strcmp(gVehicleOwner[gCurrentContainerVehicle[playerid]], gPlayerName[playerid]))
			{
				SavePlayerVehicle(gCurrentContainerVehicle[playerid], gPlayerName[playerid], true);
			}
		}
	}

	return CallLocalFunction("veh_OnItemAddedToContainer", "ddd", containerid, itemid, playerid);
}
#if defined _ALS_OnItemAddedToContainer
	#undef OnItemAddedToContainer
#else
	#define _ALS_OnItemAddedToContainer
#endif
#define OnItemAddedToContainer veh_OnItemAddedToContainer
forward veh_OnItemAddedToContainer(containerid, itemid, playerid);

public OnItemRemovedFromContainer(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(IsValidVehicle(gCurrentContainerVehicle[playerid]))
		{
			if(IsValidVehicle(gCurrentContainerVehicle[playerid]))
			{
				if(!isnull(gVehicleOwner[gCurrentContainerVehicle[playerid]]) && !strcmp(gVehicleOwner[gCurrentContainerVehicle[playerid]], gPlayerName[playerid]))
				{
					SavePlayerVehicle(gCurrentContainerVehicle[playerid], gPlayerName[playerid], true);
				}
			}
		}
	}

	return CallLocalFunction("veh_OnItemRemovedFromContainer", "ddd", containerid, slotid, playerid);
}
#if defined _ALS_OnItemRemovedFromContainer
	#undef OnItemRemovedFromContainer
#else
	#define _ALS_OnItemRemovedFromContainer
#endif
#define OnItemRemovedFromContainer veh_OnItemRemovedFromContainer
forward veh_OnItemRemovedFromContainer(containerid, slotid, playerid);


IsPlayerInVehicleArea(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
			return 0;

	if(!IsValidVehicle(vehicleid))
		return 0;

	return IsPlayerInDynamicArea(playerid, gVehicleArea[vehicleid]);
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
