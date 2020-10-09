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


#include <YSI_Coding\y_hooks>


// The directory from which vehicle spawn positions are loaded
#define DIRECTORY_VEHICLESPAWNS		"vspawn/"


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
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLESPAWNS);

	GetSettingFloat("vehicle-spawn/spawn-chance", 4.0, veh_SpawnChance);
	GetSettingInt("vehicle-spawn/print-each", false, veh_PrintEach);
	GetSettingInt("vehicle-spawn/print-total", true, veh_PrintTotal);
}

hook OnGameModeInit()
{
	if(veh_SpawnChance == 0.0)
		return Y_HOOKS_CONTINUE_RETURN_0;

	LoadVehiclesFromFolder(DIRECTORY_VEHICLESPAWNS);

	log("Loaded %d Vehicles", Iter_Count(veh_Index));

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
				log("[%02d] Spawned %d '%s'", i, vehicletypecount, vehicletypename);
			}
		}
	}

	veh_DebugLabelType = DefineDebugLabelType("VEHICLESPAWN", 0xFFCCFFFF);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

LoadVehiclesFromFolder(const directory_with_root[])
{
	log("[LoadVehiclesFromFolder] Loading vehicles from: '%s'...", directory_with_root);
	new
		Directory:direc,
		entry[64],
		ENTRY_TYPE:type,
		trimlength = strlen("./scriptfiles/");

	direc = OpenDir(directory_with_root);

	if(!direc)
	{
		err("[LoadVehiclesFromFolder] Reading directory '%s'.", directory_with_root);
		return 0;
	}

	while(DirNext(direc, type, entry))
	{
		if(type == ENTRY_TYPE:2 && strcmp(entry, "..") && strcmp(entry, ".") && strcmp(entry, "_"))
		{
			LoadVehiclesFromFolder(entry);
		}
		if(type == ENTRY_TYPE:1)
		{
			if(!strcmp(entry[strlen(entry) - 4], ".vpl"))
			{
				LoadVehiclesFromFile(entry[trimlength]);
			}
		}
	}

	CloseDir(direc);

	return 1;
}

LoadVehiclesFromFile(file[])
{
	if(!fexist(file))
	{
		err("[LoadVehiclesFromFile] File '%s' not found.", file);
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

	if(!f)
	{
		err("Reading file '%s'.", file);
		return 0;
	}

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
				err("[LoadVehiclesFromFile] reading 'Vehicle' in '%s':%d.", file, linenum);
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
					err("Default group is invalid (%d) in '%s':%d", default_group, file, linenum);
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
						err("Default categories are empty in '%s':%d", file, linenum);
						continue;
					}

					for(new i; i < default_maxcategories; i++)
						veh_SpawnData[count][vspawn_categories][i] = default_categories[i];

					maxcategories = default_maxcategories;
				}
				else
				{
					if(!_CatStringToInts(categories, veh_SpawnData[count][vspawn_categories], strlen(categories)))
						err("[Vehicle] Invalid category character in '%s':%d", file, linenum);
				}

				/*
					Vehicle sizes
				*/
				if(isnull(sizes) || !strcmp(sizes, "_"))
				{
					if(default_maxsizes == 0)
					{
						err("Default sizes are empty in '%s':%d", file, linenum);
						continue;
					}

					for(new i; i < default_maxsizes; i++)
						veh_SpawnData[count][vspawn_sizes][i] = default_sizes[i];

					maxsizes = default_maxsizes;
				}
				else
				{
					if(!_SizeStringToInts(sizes, veh_SpawnData[count][vspawn_sizes], strlen(sizes)))
						err("[Vehicle] Invalid size character in '%s':%d", file, linenum);
				}

				type = PickRandomVehicleTypeFromGroup(veh_SpawnData[count][vspawn_group], veh_SpawnData[count][vspawn_categories], maxcategories, veh_SpawnData[count][vspawn_sizes], maxsizes);
			}
			else
			{
				type = GetVehicleTypeFromName(group);

				if(!IsValidVehicleType(type))
				{
					err("Explicit vehicle type '%s' is invalid in '%s':%d", group, file, linenum);
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
				err("MAX_VEHICLES limit reached at '%s':%d", file, linenum);
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
				err("[LoadVehiclesFromFile] reading 'Defaults' in '%s'%d.", file, linenum);
				continue;
			}

			default_group = GetVehicleGroupFromName(group);
			default_maxcategories = strlen(categories);
			default_maxsizes = strlen(sizes);

			if(!_CatStringToInts(categories, default_categories, strlen(categories)))
				err("[Defaults] Invalid category character in '%s':%d", file, linenum);

			if(!_SizeStringToInts(sizes, default_sizes, strlen(sizes)))
				err("[Defaults] Invalid size character in '%s':%d", file, linenum);
		}
	}

	fclose(f);

	if(veh_PrintEach)
		log("[LOAD] %d vehicles from %s (from total %d spawns)", count, file, total);

	return 1;
}


_CatStringToInts(const input[], output[], len)
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

_SizeStringToInts(const input[], output[], len)
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
