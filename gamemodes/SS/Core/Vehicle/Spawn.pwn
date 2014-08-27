#include <YSI\y_hooks>


// The directory from which vehicle spawn positions are loaded
#define DIRECTORY_VEHICLESPAWNS		"Vehicles/"


enum E_VEHICLE_SPAWN_DATA
{
Float:	vspawn_posX,
Float:	vspawn_posY,
Float:	vspawn_posZ,
Float:	vspawn_posR,
		vspawn_group,
		vspawn_categories[8],
		vspawn_sizes[3]
}


static
		veh_SpawnData[MAX_VEHICLES][E_VEHICLE_SPAWN_DATA],

Float:	veh_SpawnChance = 4.0;


hook OnGameModeInit()
{
	print("[OnGameModeInit] Initialising 'Vehicle/Spawn'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLESPAWNS);

	GetSettingFloat("server/vehicle-spawn-multiplier", 4.0, veh_SpawnChance);
}


LoadVehicles(printeach = false, printtotal = false)
{
	LoadPlayerVehicles(printeach, printtotal);
	LoadVehiclesFromFolder(DIRECTORY_VEHICLESPAWNS, printeach);

	printf("Loaded %d Vehicles\n", Iter_Count(veh_Index));

	if(printtotal)
	{
		new
			vehicletypename[MAX_VEHICLE_TYPE_NAME],
			vehicletypecount;

		for(new i; i < veh_TypeTotal; i++)
		{
			vehicletypecount = GetVehicleTypeCount(i);

			if(vehicletypecount > 0)
			{
				GetVehicleTypeName(i, vehicletypename);
				logf("[%02d] Spawned %d '%s'", i, vehicletypecount, vehicletypename);
			}
		}
	}
}

LoadVehiclesFromFolder(foldername[], prints)
{
	new
		dir:dirhandle,
		directory_with_root[256],
		item[64],
		type,
		next_path[256];

	strcat(directory_with_root, DIRECTORY_SCRIPTFILES);
	strcat(directory_with_root, foldername);

	dirhandle = dir_open(directory_with_root);

	if(!dirhandle)
	{
		printf("ERROR: [LoadVehiclesFromFolder] Reading directory '%s'.", foldername);
		return 0;
	}

	while(dir_list(dirhandle, item, type))
	{
		if(type == FM_DIR && strcmp(item, "..") && strcmp(item, ".") && strcmp(item, "_"))
		{
			next_path[0] = EOS;
			format(next_path, sizeof(next_path), "%s%s/", foldername, item);
			LoadVehiclesFromFolder(next_path, prints);
		}
		if(type == FM_FILE)
		{
			if(!strcmp(item[strlen(item) - 4], ".vpl"))
			{
				next_path[0] = EOS;
				format(next_path, sizeof(next_path), "%s%s", foldername, item);
				LoadVehiclesFromFile(next_path, prints);
			}
		}
	}

	dir_close(dirhandle);

	return 1;
}

LoadVehiclesFromFile(file[], prints)
{
	if(!fexist(file))
	{
		printf("ERROR: [LoadVehiclesFromFile] File '%s' not found.", file);
		return 0;
	}

	new
		File:f = fopen(file, io_read),
		line[128],
		func[32],
		args[192],
		Float:posX,
		Float:posY,
		Float:posZ,
		Float:rotZ,
		group[32],
		categories[9],
		maxcategories,
		sizes[4],
		maxsizes,
		type,
		vehicleid,
		linenum,
		count,
		total,
		default_group = -2,
		default_categories[9],
		default_maxcategories,
		default_sizes[4],
		default_maxsizes;

	while(fread(f, line))
	{
		linenum++;

		if(sscanf(line, "p<(>s[32]p<)>s[192]{s[4]}", func, args))
			continue;

		if(!strcmp(func, "Vehicle"))
		{
			total++;

			if(frandom(100.0) < 100.0 - veh_SpawnChance)
				continue;

			if(sscanf(args, "P<,>ffffS()[32]S()[9]S()[4]", posX, posY, posZ, rotZ, group, categories, sizes))
			{
				printf("ERROR: [LoadVehiclesFromFile] reading 'Vehicle' args on line %d.", linenum);
				continue;
			}

			rotZ += (random(2) ? 0.0 : 180.0);

			veh_SpawnData[count][vspawn_posX] = posX;
			veh_SpawnData[count][vspawn_posY] = posY;
			veh_SpawnData[count][vspawn_posZ] = posZ;
			veh_SpawnData[count][vspawn_posR] = rotZ;

			if(isnull(categories) || !strcmp(categories, "_"))
			{
				if(default_maxcategories == 0)
				{
					print("ERROR: Tried to assign default categories to vehicle spawn but defaults are empty.");
					continue;
				}

				for(new i; i < default_maxcategories; i++)
					veh_SpawnData[count][vspawn_categories][i] = default_categories[i];

				maxcategories = default_maxcategories;
			}
			else
			{
				for(new i, j = strlen(categories); i < j; i++)
				{
					switch(categories[i])
					{
						case 'C': veh_SpawnData[count][vspawn_categories][i] = VEHICLE_CATEGORY_CAR;
						case 'T': veh_SpawnData[count][vspawn_categories][i] = VEHICLE_CATEGORY_TRUCK;
						case 'M': veh_SpawnData[count][vspawn_categories][i] = VEHICLE_CATEGORY_MOTORBIKE;
						case 'B': veh_SpawnData[count][vspawn_categories][i] = VEHICLE_CATEGORY_PUSHBIKE;
						case 'H': veh_SpawnData[count][vspawn_categories][i] = VEHICLE_CATEGORY_HELICOPTER;
						case 'P': veh_SpawnData[count][vspawn_categories][i] = VEHICLE_CATEGORY_PLANE;
						case 'S': veh_SpawnData[count][vspawn_categories][i] = VEHICLE_CATEGORY_BOAT;
						case 'L': veh_SpawnData[count][vspawn_categories][i] = VEHICLE_CATEGORY_TRAIN;
						case 'A': veh_SpawnData[count][vspawn_categories][i] = VEHICLE_CATEGORY_TRAILER;
						default: printf("ERROR: Invalid category character (%c) found in spawn category list.", categories[i]);
					}
					maxcategories++;
				}
			}

			if(isnull(sizes) || !strcmp(sizes, "_"))
			{
				if(default_maxsizes == 0)
				{
					print("ERROR: Tried to assign default sizes to vehicle spawn but defaults are empty.");
					continue;
				}

				for(new i; i < default_maxsizes; i++)
					veh_SpawnData[count][vspawn_sizes][i] = default_sizes[i];

				maxsizes = default_maxsizes;
			}
			else
			{
				for(new i, j = strlen(sizes); i < j; i++)
				{
					switch(sizes[i])
					{
						case 'S': veh_SpawnData[count][vspawn_sizes][i] = VEHICLE_SIZE_SMALL;
						case 'M': veh_SpawnData[count][vspawn_sizes][i] = VEHICLE_SIZE_MEDIUM;
						case 'L': veh_SpawnData[count][vspawn_sizes][i] = VEHICLE_SIZE_LARGE;
						default: printf("ERROR: Invalid size character (%c) found in spawn size list.", sizes[i]);
					}
					maxsizes++;
				}
			}

			if(isnull(group))
				veh_SpawnData[count][vspawn_group] = default_group;

			else
				veh_SpawnData[count][vspawn_group] = GetVehicleGroupFromName(group);

			if(veh_SpawnData[count][vspawn_group] != -1)
			{
				type = PickRandomVehicleTypeFromGroup(veh_SpawnData[count][vspawn_group], veh_SpawnData[count][vspawn_categories], maxcategories, veh_SpawnData[count][vspawn_sizes], maxsizes);
			}
			else
			{
				type = GetVehicleTypeFromName(group);

				if(!(frandom(100.0) < GetVehicleTypeSpawnChance(type)))
					continue;
			}

			if(!IsValidVehicleType(type))
			{
				printf("ERROR: [LoadVehiclesFromFile] Determined vehicle type is invalid (%d).", type);
				continue;
			}

			vehicleid = CreateNewVehicle(type, posX, posY, posZ, rotZ);

			if(vehicleid == MAX_VEHICLES - 1)
			{
				print("WARNING: MAX_VEHICLES limit reached.");
				break;
			}

			if(!IsValidVehicle(vehicleid))
				continue;

			count++;
		}

		if(!strcmp(func, "Defaults"))
		{
			if(sscanf(args, "p<,>s[32]s[9]s[4]", group, categories, sizes))
			{
				printf("ERROR: [LoadVehiclesFromFile] reading 'Defaults' args on line %d.", linenum);
				continue;
			}

			default_group = GetVehicleGroupFromName(group);
			default_maxcategories = 0;
			default_maxsizes = 0;

			for(new i, j = strlen(categories); i < j; i++)
			{
				switch(categories[i])
				{
					case 'C': default_categories[i] = VEHICLE_CATEGORY_CAR;
					case 'T': default_categories[i] = VEHICLE_CATEGORY_TRUCK;
					case 'M': default_categories[i] = VEHICLE_CATEGORY_MOTORBIKE;
					case 'B': default_categories[i] = VEHICLE_CATEGORY_PUSHBIKE;
					case 'H': default_categories[i] = VEHICLE_CATEGORY_HELICOPTER;
					case 'P': default_categories[i] = VEHICLE_CATEGORY_PLANE;
					case 'S': default_categories[i] = VEHICLE_CATEGORY_BOAT;
					case 'L': default_categories[i] = VEHICLE_CATEGORY_TRAIN;
					case 'A': default_categories[i] = VEHICLE_CATEGORY_TRAILER;
					default: printf("ERROR: Invalid category character (%c) found in default category list.", categories[i]);
				}
				default_maxcategories++;
			}

			for(new i, j = strlen(sizes); i < j; i++)
			{
				switch(sizes[i])
				{
					case 'S': default_sizes[i] = VEHICLE_SIZE_SMALL;
					case 'M': default_sizes[i] = VEHICLE_SIZE_MEDIUM;
					case 'L': default_sizes[i] = VEHICLE_SIZE_LARGE;
					default: printf("ERROR: Invalid size character (%c) found in spawn size list.", sizes[i]);
				}
				default_maxsizes++;
			}
		}
	}

	fclose(f);

	if(prints)
		printf("\t[LOAD] %d vehicles from %s (from total %d spawns)", count, file, total);

	return 1;
}
