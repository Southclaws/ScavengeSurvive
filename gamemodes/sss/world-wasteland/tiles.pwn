/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define MAX_OBJECTS_PER_TILE	(64)
#define MAX_TILE_TYPE			(8)
#define TILE_HEIGHT				(500.0)
#define TILE_DATA_FOLDER		"TerrainTiles/"
#define TILE_DATA_DIR			"./scriptfiles/TerrainTiles/"


enum
{
		TILE_OBJECT_TYPE_MODEL,
		TILE_OBJECT_TYPE_VEHICLE,
		TILE_OBJECT_TYPE_LOOTSPAWN
}

enum E_TILE_OBJECT_DATA
{
		tileobj_type,
		tileobj_id,
Float:	tileobj_posX,
Float:	tileobj_posY,
Float:	tileobj_posZ,
Float:	tileobj_rotX,
Float:	tileobj_rotY,
Float:	tileobj_rotZ
}

enum E_TILE_TYPE_DATA
{
		tiletype_name[24],
		tiletype_totalObj,
		tiletype_rarity
}


static
		tiletype_Data[MAX_TILE_TYPE][E_TILE_TYPE_DATA],
		tiletype_Objects[MAX_TILE_TYPE][MAX_OBJECTS_PER_TILE][E_TILE_OBJECT_DATA],
		tiletype_Uses[MAX_TILE_TYPE],
		tiletype_Total;

static
		tile_Total;


LoadTiles()
{
	new
		dir:direc = dir_open(TILE_DATA_DIR),
		item[46],
		type;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			LoadTile(item);
		}
	}

	dir_close(direc);

	log("Total Tile Types: %d", tiletype_Total);
}

LoadTile(filename[])
{
	new
		filedir[64],
		File:file,
		line[128],
		loadedmeta,
		rarity,
		objects[MAX_OBJECTS_PER_TILE][E_TILE_OBJECT_DATA],
		total,
		tilename[24];

	filedir = TILE_DATA_FOLDER;
	strcat(filedir, filename);
	file = fopen(filedir, io_read);

	while(fread(file, line))
	{
		if(!loadedmeta)
		{
			if(!sscanf(line, "d", rarity))
			{
				loadedmeta = true;
			}
			else
			{
				err("in file '%s': tile rarity must be defined on line 1", filename);
			}
		}

		if(!sscanf(line, "p<(>{s[20]}p<,>dfffffp<)>f{s[4]}",
			objects[total][tileobj_id],
			objects[total][tileobj_posX], objects[total][tileobj_posY], objects[total][tileobj_posZ],
			objects[total][tileobj_rotX], objects[total][tileobj_rotY], objects[total][tileobj_rotZ]))
		{
			objects[total][tileobj_type] = TILE_OBJECT_TYPE_MODEL;
			total++;
		}
	}

	fclose(file);

	strcat(tilename, filename);
	tilename[strlen(tilename) - 4] = EOS;

	AddTerrainTile(tilename, objects, rarity, total);
}

AddTerrainTile(name[24], objects[MAX_OBJECTS_PER_TILE][E_TILE_OBJECT_DATA], rarity, total)
{
	if(tiletype_Total == MAX_TILE_TYPE)
	{
		err("MAX_TILE_TYPE limit reached.");
		return;
	}

	tiletype_Data[tiletype_Total][tiletype_name] = name;
	tiletype_Data[tiletype_Total][tiletype_rarity] = rarity;
	tiletype_Data[tiletype_Total][tiletype_totalObj] = total;

	for(new i; i < total; i++)
	{
		tiletype_Objects[tiletype_Total][i][tileobj_type]	= objects[i][tileobj_type];
		tiletype_Objects[tiletype_Total][i][tileobj_id]		= objects[i][tileobj_id];
		tiletype_Objects[tiletype_Total][i][tileobj_posX]	= objects[i][tileobj_posX];
		tiletype_Objects[tiletype_Total][i][tileobj_posY]	= objects[i][tileobj_posY];
		tiletype_Objects[tiletype_Total][i][tileobj_posZ]	= objects[i][tileobj_posZ];
		tiletype_Objects[tiletype_Total][i][tileobj_rotX]	= objects[i][tileobj_rotX];
		tiletype_Objects[tiletype_Total][i][tileobj_rotY]	= objects[i][tileobj_rotY];
		tiletype_Objects[tiletype_Total][i][tileobj_rotZ]	= objects[i][tileobj_rotZ];
	}

	log("Added Terrain Tile '%s' (%d objects)", tiletype_Data[tiletype_Total][tiletype_name], total);

	tiletype_Total++;

	return;
}

GenerateTile(&seed1, &seed2, &tiletype)
{
	new
		list[MAX_TILE_TYPE],
		idx,
		total = 1;

	seed1 = (seed1 + 1073741824) % 100;

	list[0] = -1;

	while(idx < tiletype_Total)
	{
		if(seed1 < tiletype_Data[idx][tiletype_rarity])
		{
			list[total++] = idx;
		}

		idx++;
	}

	seed2 = (seed2 + 1073741824) % total;

	tiletype = list[seed2];

	log("PICKED %d FROM CELL %d OF TOTAL %d", tiletype, seed2, total);
}

CreateTile(tiletype, Float:x, Float:y)
{
	new objectid;

	objectid = CreateDynamicObject(6959, x, y, TILE_HEIGHT, 0.0, 0.0, 0.0, .streamdistance = 3000.0);
	SetDynamicObjectMaterial(objectid, 0, 16202, "des_cen", "des_dirt1");

	if(0 <= tiletype < tiletype_Total)
	{
		tiletype_Uses[tiletype]++;

		log("Creating tile with %d objs", tiletype_Data[tiletype][tiletype_totalObj]);

		for(new i; i < tiletype_Data[tiletype][tiletype_totalObj]; i++)
		{
			log("    obj %d type %d", i, tiletype_Objects[tiletype][i][tileobj_type]);

			switch(tiletype_Objects[tiletype][i][tileobj_type])
			{
				case TILE_OBJECT_TYPE_MODEL:
				{
					log("creating %d", tiletype_Objects[tiletype][i][tileobj_id]);
					CreateDynamicObject(
						tiletype_Objects[tiletype][i][tileobj_id],
						x + tiletype_Objects[tiletype][i][tileobj_posX],
						y + tiletype_Objects[tiletype][i][tileobj_posY],
						TILE_HEIGHT + tiletype_Objects[tiletype][i][tileobj_posZ],
						tiletype_Objects[tiletype][i][tileobj_rotX],
						tiletype_Objects[tiletype][i][tileobj_rotY],
						tiletype_Objects[tiletype][i][tileobj_rotZ]);
				}
				case TILE_OBJECT_TYPE_VEHICLE:
				{
					// Todo
				}
				case TILE_OBJECT_TYPE_LOOTSPAWN:
				{
					// Todo
				}
			}
		}
	}

	tile_Total++;
}


// Interface


stock GetTileName(tiletype, name[])
{
	name[0] = EOS;
	strcat(name, tiletype_Data[tiletype][tiletype_name], 24);
	return 1;
}

stock GetTileTotalObjects(tiletype)
{
	return tiletype_Data[tiletype][tiletype_totalObj];
}

stock GetTileRarity(tiletype)
{	
	return tiletype_Data[tiletype][tiletype_rarity];
}

stock GetTileObjectArray(tiletype, objects[][E_TILE_OBJECT_DATA])
{
	objects = tiletype_Objects[tiletype];

	return 1;
}


stock GetTileUses(tiletype)
{
	return tiletype_Uses[tiletype];
}

stock GetTotalTileTypes()
{
	return tiletype_Total;
}

stock GetTotalTiles()
{
	return tile_Total;
}
