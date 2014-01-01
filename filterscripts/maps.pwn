/*==============================================================================


	Southclaw's Map Loader/Parser

		Loads .map files populated with CreateObject (or any variation) lines.
		Existence of a 'maps.cfg' file enables Unix style option input.
		Currently only supports '-d<0-4>' for various levels of debugging.


==============================================================================*/


#define FILTERSCRIPT

#include <a_samp>


/*==============================================================================

	Predefinitions and External Dependencies

==============================================================================*/


#undef MAX_PLAYERS
#define MAX_PLAYERS (32)

#include <streamer>					// By Incognito:			http://forum.sa-mp.com/showthread.php?t=102865
#include <sscanf2>					// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=120356
#include <zcmd>						// ZeeX						http://forum.sa-mp.com/showthread.php?t=91354
#include <FileManager>				// By JaTochNietDan:		http://forum.sa-mp.com/showthread.php?t=92246


/*==============================================================================

	Constants

==============================================================================*/


#define ROOT_FOLDER			"Maps/"
#define CONFIG_FILE			ROOT_FOLDER"maps.cfg"

#define MAX_REMOVED_OBJECTS	(1000)
#define MAX_MATERIAL_SIZE	(14)
#define MAX_MATERIAL_LEN	(8)


/*==============================================================================

	Debug levels

==============================================================================*/


enum
{
	DEBUG_LEVEL_NONE,		// (-1) No prints
	DEBUG_LEVEL_INFO,		// (0) Print information messages
	DEBUG_LEVEL_FOLDERS,	// (1) Print each folder
	DEBUG_LEVEL_FILES,		// (2) Print each loaded file
	DEBUG_LEVEL_DATA,		// (3) Print each loaded data line in each file
	DEBUG_LEVEL_LINES		// (4) Print each line in each file
}

enum E_REMOVE_DATA
{
		remove_Model,
Float:	remove_PosX,
Float:	remove_PosY,
Float:	remove_PosZ,
Float:	remove_Range
}


/*==============================================================================

	Variables

==============================================================================*/


new
		gDebugLevel = 0,
		gTotalLoadedObjects,
		gModelRemoveData[MAX_REMOVED_OBJECTS][E_REMOVE_DATA],
		gTotalObjectsToRemove;


/*==============================================================================

	Core

==============================================================================*/


public OnFilterScriptInit()
{
	// Load config if exists
	if(fexist(CONFIG_FILE))
		LoadConfig();

	if(gDebugLevel > DEBUG_LEVEL_NONE)
		printf("DEBUG: [Init] Debug Level: %d", gDebugLevel);

	LoadMapsFromFolder(ROOT_FOLDER);

	for(new i; i < MAX_PLAYERS; i++)
		RemoveObjectsForPlayer(i);

	if(gDebugLevel >= DEBUG_LEVEL_INFO)
	{
		printf("%d Total objects", gTotalLoadedObjects);
		printf("%d Objects to remove", gTotalObjectsToRemove);
	}

	return 1;
}

LoadConfig()
{
	print("Loading config");
	new
		File:file,
		line[32];

	file = fopen(CONFIG_FILE, io_read);

	if(file)
	{
		new len;

		fread(file, line, 32);

		len = strlen(line);

		for(new i; i < len; i++)
		{
			if(line[i] == ' ')
				continue;

			if(line[i] == '-')
				continue;

			if(line[i] == 'd' && (i < len - 3))
			{
				i++;

				new val = line[i] - 48;

				if(DEBUG_LEVEL_NONE < val <= DEBUG_LEVEL_LINES)
					gDebugLevel = val;
			}

			/*
				Ideas for future options:
				-r[path] = set the root directory to load maps from
				-s[value] = set default stream distance
				-S[value] = override all per-file stream distances
				-m[value] = set object limit
				-I[path] = include another directory for loading maps
			*/

		}

		fclose(file);
	}

	return 1;
}

LoadMapsFromFolder(folder[])
{
	new
		foldername[256],
		dir:dirhandle,
		item[64],
		type,
		filename[256];

	format(foldername, sizeof(foldername), "./scriptfiles/%s", folder);
	dirhandle = dir_open(foldername);

	if(gDebugLevel >= DEBUG_LEVEL_FOLDERS)
	{
		new
			totalfiles,
			totalmapfiles,
			totalfolders;

		while(dir_list(dirhandle, item, type))
		{
			if(type == FM_FILE)
			{
				totalfiles++;

				if(!strcmp(item[strlen(item) - 4], ".map"))
					totalmapfiles++;
			}

			if(type == FM_DIR && strcmp(item, "..") && strcmp(item, ".") && strcmp(item, "_"))
				totalfolders++;
		}

		// Reopen the directory so the next code can run properly.
		dir_close(dirhandle);
		dirhandle = dir_open(foldername);

		printf("DEBUG: [LoadMapsFromFolder] Reading directory '%s': %d files, %d .map files, %d folders", foldername, totalfiles, totalmapfiles, totalfolders);
	}

	while(dir_list(dirhandle, item, type))
	{
		if(type == FM_FILE)
		{
			if(!strcmp(item[strlen(item) - 4], ".map"))
			{
				filename[0] = EOS;
				format(filename, sizeof(filename), "%s%s", folder, item);
				LoadMap(filename);
			}
		}

		if(type == FM_DIR && strcmp(item, "..") && strcmp(item, ".") && strcmp(item, "_"))
		{
			filename[0] = EOS;
			format(filename, sizeof(filename), "%s%s/", folder, item);
			LoadMapsFromFolder(filename);
		}
	}

	dir_close(dirhandle);

	if(gDebugLevel >= DEBUG_LEVEL_FOLDERS)
		print("DEBUG: [LoadMapsFromFolder] Finished reading directory.");
}

LoadMap(filename[])
{
	new
		File:file,
		line[256],

		linenumber,
		objects,
		operations,
		
		funcname[32],
		funcargs[128],
		
		globalworld[1],
		globalinterior[1],
		Float:globalrange,

		modelid,
		Float:posx,
		Float:posy,
		Float:posz,
		Float:rotx,
		Float:roty,
		Float:rotz,
		world[1],
		interior[1],
		Float:range,

		tmpObjID,
		tmpObjIdx,
		tmpObjMod,
		tmpObjTxd[32],
		tmpObjTex[32],
		tmpObjMatCol,

		tmpObjText[128],
		tmpObjResName[32],
		tmpObjRes,
		tmpObjFont[32],
		tmpObjFontSize,
		tmpObjBold,
		tmpObjFontCol,
		tmpObjBackCol,
		tmpObjAlign,

		matSizeTable[MAX_MATERIAL_SIZE][MAX_MATERIAL_LEN] =
		{
			"32x32",
			"64x32",
			"64x64",
			"128x32",
			"128x64",
			"128x128",
			"256x32",
			"256x64",
			"256x128",
			"256x256",
			"512x64",
			"512x128",
			"512x256",
			"512x512"
		};

	globalworld[0] = -1;
	globalinterior[0] = -1;
	globalrange = 350.0;

	if(!fexist(filename))
	{
		printf("ERROR: file: \"%s\" NOT FOUND", filename);
		return 0;
	}

	file = fopen(filename, io_read);

	if(!file)
	{
		printf("ERROR: file: \"%s\" NOT LOADED", filename);
		return 0;
	}

	if(gDebugLevel >= DEBUG_LEVEL_FILES)
	{
		new totallines;

		while(fread(file, line))
			totallines++;

		// Reopen the file so the actual read code runs properly.
		fclose(file);
		file = fopen(filename, io_read);

		printf("\nDEBUG: [LoadMap] Reading file '%s': %d lines.", filename, totallines);
	}

	while(fread(file, line))
	{
		if(gDebugLevel == DEBUG_LEVEL_LINES)
			print(line);

		if(line[0] < 65)
		{
			linenumber++;
			continue;
		}

		if(sscanf(line, "p<(>s[32]p<)>s[128]{s[96]}", funcname, funcargs))
		{
			linenumber++;
			continue;
		}

		if(!strcmp(funcname, "options", false))
		{
			if(!sscanf(funcargs, "p<,>ddf", globalworld[0], globalinterior[0], globalrange))
			{
				if(gDebugLevel >= DEBUG_LEVEL_INFO)
					printf(" DEBUG: [LoadMap] Updated options to: %d, %d, %f", globalworld[0], globalinterior[0], globalrange);

				operations++;
			}
		}

		if(!strcmp(funcname, "Create", false, 6)) // Scan for any function starting with 'Create', this covers CreateObject, CreateDynamicObject, CreateStreamedObject, etc.
		{
			if(!sscanf(funcargs, "p<,>dffffffD(-1)D(-1){D(-1)}F(-1.0)", modelid, posx, posy, posz, rotx, roty, rotz, world[0], interior[0], range))
			{
				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object: %d, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f",
						modelid, posx, posy, posz, rotx, roty, rotz);
				}

				if(range == -1.0)
					range = globalrange;

				if(world[0] == -1)
					world = globalworld;

				if(interior[0] == -1)
					interior = globalinterior;

				tmpObjID = CreateDynamicObjectEx(modelid, posx, posy, posz, rotx, roty, rotz, range, range + 100.0, world, interior);

				gTotalLoadedObjects++;
				objects++;
				operations++;
			}
		}

		if(!strcmp(funcname, "SetObjectMaterialText"))
		{
			if(!sscanf(funcargs, "p<,>{s[16]} p<\">{s[1]}s[32]p<,>{s[1]} d s[32] p<\">{s[1]}s[32]p<,>{s[1]} ddddd", tmpObjText, tmpObjIdx, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign))
			{
				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object Text: '%s', %d, '%s', '%s', %d, %d, %d, %d, %d",
						tmpObjText, tmpObjIdx, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
				}

				new len = strlen(tmpObjText);

				for(new i; i < sizeof(matSizeTable); i++)
				{
					if(strfind(tmpObjResName, matSizeTable[i]) != -1)
						tmpObjRes = (i + 1) * 10;
				}

				for(new i; i < len; i++)
				{
					if(tmpObjText[i] == '\\' && i != len-1)
					{
						if(tmpObjText[i+1] == 'n')
						{
							strdel(tmpObjText, i, i+1);
							tmpObjText[i] = '\n';
						}
					}
				}

				SetDynamicObjectMaterialText(tmpObjID, tmpObjIdx, tmpObjText, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
				operations++;
			}
		}

		if(!strcmp(funcname, "SetObjectMaterial"))
		{
			if(!sscanf(funcargs, "p<,>{s[16]}dd p<\">{s[1]}s[32]p<,>{s[1]} p<\">{s[1]}s[32]p<,>{s[1]} d", tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol))
			{
				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object Material: %d, %d, '%s', '%s', %d",
						tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol);
				}

				SetDynamicObjectMaterial(tmpObjID, tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol);
				operations++;
			}
		}

		if(!strcmp(funcname, "RemoveBuildingForPlayer"))
		{
			if(!sscanf(funcargs, "p<,>{s[16]}dffff", modelid, posx, posy, posz, range))
			{
				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Removal: %d, %.2f, %.2f, %.2f, %.2f",
						modelid, posx, posy, posz, range);
				}
		
				gModelRemoveData[gTotalObjectsToRemove][remove_Model] = modelid;
				gModelRemoveData[gTotalObjectsToRemove][remove_PosX] = posx;
				gModelRemoveData[gTotalObjectsToRemove][remove_PosY] = posy;
				gModelRemoveData[gTotalObjectsToRemove][remove_PosZ] = posz;
				gModelRemoveData[gTotalObjectsToRemove][remove_Range] = range;
		
				gTotalObjectsToRemove++;
				operations++;
			}
		}

		linenumber++;
	}

	fclose(file);

	if(gDebugLevel >= DEBUG_LEVEL_FILES)
		printf("DEBUG: [LoadMap] Finished reading file. %d objects loaded from %d lines, %d total operations.", objects, linenumber, operations);

	return linenumber;
}

public OnPlayerConnect(playerid)
{
	RemoveObjectsForPlayer(playerid);

	return 1;
}

RemoveObjectsForPlayer(playerid)
{
	for(new i; i < gTotalObjectsToRemove; i++)
	{
		RemoveBuildingForPlayer(playerid,
			gModelRemoveData[i][remove_Model],
			gModelRemoveData[i][remove_PosX],
			gModelRemoveData[i][remove_PosY],
			gModelRemoveData[i][remove_PosZ],
			gModelRemoveData[i][remove_Range]);
	}
}
