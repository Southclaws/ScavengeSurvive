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

// Settings: Prefixed camel case here and dashed in settings.json
Float:	veh_SpawnChance = 4.0,
bool:	veh_PrintEach,
bool:	veh_PrintTotal;


static	veh_DebugLabelType;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Vehicle/Spawn'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLESPAWNS);

	GetSettingFloat("vehicle-spawn/spawn-chance", 4.0, veh_SpawnChance);
	GetSettingInt("vehicle-spawn/print-each", false, veh_PrintEach);
	GetSettingInt("vehicle-spawn/print-total", true, veh_PrintTotal);
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Vehicle/Spawn'...");

	//LoadPlayerVehicles(true, true);
	LoadVehiclesFromFolder(DIRECTORY_VEHICLESPAWNS);

	printf("Loaded %d Vehicles", Iter_Count(veh_Index));

	if(veh_PrintTotal)
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

	veh_DebugLabelType = DefineDebugLabelType("VEHICLESPAWN", 0xFFCCFFFF);
}

LoadVehiclesFromFolder(foldername[])
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
			LoadVehiclesFromFolder(next_path);
		}
		if(type == FM_FILE)
		{
			if(!strcmp(item[strlen(item) - 4], ".vpl"))
			{
				next_path[0] = EOS;
				format(next_path, sizeof(next_path), "%s%s", foldername, item);
				LoadVehiclesFromFile(next_path);
			}
		}
	}

	dir_close(dirhandle);

	return 1;
}

LoadVehiclesFromFile(file[])
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
				printf("ERROR: [LoadVehiclesFromFile] reading 'Vehicle' in '%s':%d.", file, linenum);
				continue;
			}

			rotZ += (random(2) ? 0.0 : 180.0);

			veh_SpawnData[count][vspawn_posX] = posX;
			veh_SpawnData[count][vspawn_posY] = posY;
			veh_SpawnData[count][vspawn_posZ] = posZ;
			veh_SpawnData[count][vspawn_posR] = rotZ;

			/*
				Vehicle group
			*/
			if(isnull(group))
			{
				if(default_group == -2)
				{
					printf("ERROR: Default group is invalid (%d) in '%s':%d", default_group, file, linenum);
					continue;
				}
				else
				{
					veh_SpawnData[count][vspawn_group] = default_group;
				}
			}
			else
			{
				veh_SpawnData[count][vspawn_group] = GetVehicleGroupFromName(group);
			}

			if(veh_SpawnData[count][vspawn_group] != -1)
			{
				/*
					Vehicle categories
				*/
				if(isnull(categories) || !strcmp(categories, "_"))
				{
					if(default_maxcategories == 0)
					{
						printf("ERROR: Default categories are empty in '%s':%d", file, linenum);
						continue;
					}

					for(new i; i < default_maxcategories; i++)
						veh_SpawnData[count][vspawn_categories][i] = default_categories[i];

					maxcategories = default_maxcategories;
				}
				else
				{
					if(!_CatStringToInts(categories, veh_SpawnData[count][vspawn_categories], strlen(categories)))
						printf("ERROR: [Vehicle] Invalid category character in '%s':%d", file, linenum);
				}

				/*
					Vehicle sizes
				*/
				if(isnull(sizes) || !strcmp(sizes, "_"))
				{
					if(default_maxsizes == 0)
					{
						printf("ERROR: Default sizes are empty in '%s':%d", file, linenum);
						continue;
					}

					for(new i; i < default_maxsizes; i++)
						veh_SpawnData[count][vspawn_sizes][i] = default_sizes[i];

					maxsizes = default_maxsizes;
				}
				else
				{
					if(!_SizeStringToInts(sizes, veh_SpawnData[count][vspawn_sizes], strlen(sizes)))
						printf("ERROR: [Vehicle] Invalid size character in '%s':%d", file, linenum);
				}

				type = PickRandomVehicleTypeFromGroup(veh_SpawnData[count][vspawn_group], veh_SpawnData[count][vspawn_categories], maxcategories, veh_SpawnData[count][vspawn_sizes], maxsizes);
			}
			else
			{
				type = GetVehicleTypeFromName(group);

				if(!IsValidVehicleType(type))
				{
					printf("ERROR: Explicit vehicle type '%s' is invalid in '%s':%d", group, file, linenum);
					continue;
				}

				if(!(frandom(100.0) < GetVehicleTypeSpawnChance(type)))
					continue;
			}

			CreateDebugLabel(veh_DebugLabelType, count, posX, posY, posZ, sprintf("GRP: '%d' CAT: '%s' SIZ: '%s'",
				veh_SpawnData[count][vspawn_group],
				categories,
				sizes));

			if(!IsValidVehicleType(type))
				continue;

			vehicleid = CreateLootVehicle(type, posX, posY, posZ, rotZ);

			if(vehicleid == MAX_VEHICLES - 1)
			{
				printf("WARNING: MAX_VEHICLES limit reached at '%s':%d", file, linenum);
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
				printf("ERROR: [LoadVehiclesFromFile] reading 'Defaults' in '%s'%d.", file, linenum);
				continue;
			}

			default_group = GetVehicleGroupFromName(group);
			default_maxcategories = strlen(categories);
			default_maxsizes = strlen(sizes);

			if(!_CatStringToInts(categories, default_categories, strlen(categories)))
				printf("ERROR: [Defaults] Invalid category character in '%s':%d", file, linenum);

			if(!_SizeStringToInts(sizes, default_sizes, strlen(sizes)))
				printf("ERROR: [Defaults] Invalid size character in '%s':%d", file, linenum);
		}
	}

	fclose(f);

	if(veh_PrintEach)
		printf("\t[LOAD] %d vehicles from %s (from total %d spawns)", count, file, total);

	return 1;
}


_CatStringToInts(input[], output[], len)
{
	for(new i; i < len; i++)
	{
		switch(input[i])
		{
			case 'C': output[i] = VEHICLE_CATEGORY_CAR;
			case 'T': output[i] = VEHICLE_CATEGORY_TRUCK;
			case 'M': output[i] = VEHICLE_CATEGORY_MOTORBIKE;
			case 'B': output[i] = VEHICLE_CATEGORY_PUSHBIKE;
			case 'H': output[i] = VEHICLE_CATEGORY_HELICOPTER;
			case 'P': output[i] = VEHICLE_CATEGORY_PLANE;
			case 'S': output[i] = VEHICLE_CATEGORY_BOAT;
			case 'L': output[i] = VEHICLE_CATEGORY_TRAIN;
			default: return 0;
		}
	}

	return 1;
}

_SizeStringToInts(input[], output[], len)
{
	for(new i; i < len; i++)
	{
		switch(input[i])
		{
			case 'S': output[i] = VEHICLE_SIZE_SMALL;
			case 'M': output[i] = VEHICLE_SIZE_MEDIUM;
			case 'L': output[i] = VEHICLE_SIZE_LARGE;
			default: return 0;
		}
	}

	return 1;
}
