/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


/*==============================================================================


	Southclaws' Map Loader/Parser

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
#include <fsutil>


/*==============================================================================

	Constants

==============================================================================*/


#define DIRECTORY_SCRIPTFILES	"./scriptfiles/"
#define DIRECTORY_MAPS			"maps/"
#define DIRECTORY_SESSION		"session/"
#define CONFIG_FILE				DIRECTORY_MAPS"maps.cfg"

#define MAX_REMOVED_OBJECTS		(1000)
#define MAX_MATERIAL_SIZE		(14)
#define MAX_MATERIAL_LEN		(8)
#define SESSION_NAME_LEN		(40)


/*==============================================================================

	Debug levels

==============================================================================*/


enum
{
	DEBUG_LEVEL_NONE = -1,	// (-1) No prints
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
		gLoadedRemoveBuffer[MAX_PLAYERS][MAX_REMOVED_OBJECTS][5],
		gTotalObjectsToRemove;


/*==============================================================================

	Core

==============================================================================*/


public OnFilterScriptInit()
{
	if(!Exists(DIRECTORY_SCRIPTFILES))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES"' not found. Creating directory.");
		CreateDir(DIRECTORY_SCRIPTFILES);
	}

	if(!Exists(DIRECTORY_SCRIPTFILES DIRECTORY_MAPS))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_MAPS"' not found. Creating directory.");
		CreateDir(DIRECTORY_SCRIPTFILES DIRECTORY_MAPS);
	}

	if(!Exists(DIRECTORY_SCRIPTFILES DIRECTORY_MAPS DIRECTORY_SESSION))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_MAPS DIRECTORY_SESSION"' not found. Creating directory.");
		CreateDir(DIRECTORY_SCRIPTFILES DIRECTORY_MAPS DIRECTORY_SESSION);
	}

	// Load config if exists
	if(fexist(CONFIG_FILE))
		LoadConfig();

	if(gDebugLevel > DEBUG_LEVEL_NONE)
		printf("INFO: [Init] Debug Level: %d", gDebugLevel);

	LoadMapsFromFolder(DIRECTORY_SCRIPTFILES DIRECTORY_MAPS);

	// Yes a standard loop is required here.
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
			RemoveObjects_OnLoad(i);
	}

	if(gDebugLevel >= DEBUG_LEVEL_INFO)
	{
		printf("INFO: [Init] %d Total objects", gTotalLoadedObjects);
		printf("INFO: [Init] %d Objects to remove", gTotalObjectsToRemove);
	}

	return 1;
}

LoadConfig()
{
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
			switch(line[i])
			{
				case ' ', '-', '\r', '\n':
					continue;
			}

			if(line[i] == 'd' && (i < len - 3))
			{
				i++;

				new val = line[i] - 48;

				if(DEBUG_LEVEL_NONE < val <= DEBUG_LEVEL_LINES)
					gDebugLevel = val;

				continue;
			}

			printf("ERROR: Unknown option character at column %d.", i);

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

LoadMapsFromFolder(const foldername[])
{
	new
		Directory:dirhandle,
		item[64],
		ENTRY_TYPE:type,
		trimlength = strlen("./scriptfiles/");

	dirhandle = OpenDir(foldername);

	if(gDebugLevel >= DEBUG_LEVEL_FOLDERS)
	{
		new
			totalfiles,
			totalmapfiles,
			totalfolders;

		while(DirNext(dirhandle, type, item))
		{
			if(type == E_REGULAR)
			{
				totalfiles++;

				if(!strcmp(item[strlen(item) - 4], ".map"))
					totalmapfiles++;
			}

			if(type == E_DIRECTORY && strcmp(item, "..") && strcmp(item, ".") && strcmp(item, "_"))
				totalfolders++;
		}

		// Reopen the directory so the next code can run properly.
		CloseDir(dirhandle);
		dirhandle = OpenDir(foldername);

		printf("DEBUG: [LoadMapsFromFolder] Reading directory '%s': %d files, %d .map files, %d folders", foldername, totalfiles, totalmapfiles, totalfolders);
	}

	while(DirNext(dirhandle, type, item))
	{
		if(type == E_REGULAR)
		{
			if(!strcmp(item[strlen(item) - 4], ".map"))
			{
				LoadMap(item[trimlength]);
			}
		}

		if(type == E_DIRECTORY && strcmp(item, "..") && strcmp(item, ".") && strcmp(item, "_"))
		{
			LoadMapsFromFolder(item);
		}
	}

	CloseDir(dirhandle);

	if(gDebugLevel >= DEBUG_LEVEL_FOLDERS)
		print("DEBUG: [LoadMapsFromFolder] Finished reading directory.");
}

LoadMap(filename[])
{
	new
		File:file,
		line[256],

		linenumber = 1,
		objects,
		operations,
		
		funcname[32],
		funcargs[128],
		
		globalworld = -1,
		globalinterior = -1,
		Float:globalrange = 350.0,

		modelid,
		Float:posx,
		Float:posy,
		Float:posz,
		Float:rotx,
		Float:roty,
		Float:rotz,
		world,
		interior,
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
			if(!sscanf(funcargs, "p<,>ddf", globalworld, globalinterior, globalrange))
			{
				if(gDebugLevel >= DEBUG_LEVEL_DATA)
					printf(" DEBUG: [LoadMap] Updated options to: %d, %d, %f", globalworld, globalinterior, globalrange);

				operations++;
			}
		}

		if(!strcmp(funcname, "Create", false, 6)) // Scan for any function starting with 'Create', this covers CreateObject, CreateDynamicObject, CreateStreamedObject, etc.
		{
			if(!sscanf(funcargs, "p<,>dffffffD(-1)D(-1){D(-1)}F(-1.0)", modelid, posx, posy, posz, rotx, roty, rotz, world, interior, range))
			{
				if(world == -1)
					world = globalworld;

				if(interior == -1)
					interior = globalinterior;

				if(range == -1.0)
					range = globalrange;

				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object: %d, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f (%d, %d, %f)",
						modelid, posx, posy, posz, rotx, roty, rotz, world, interior, range);
				}

				tmpObjID = CreateDynamicObject(modelid, posx, posy, posz, rotx, roty, rotz, world, interior, -1, range + 100.0, range);

				gTotalLoadedObjects++;
				objects++;
				operations++;
			}
		}

		if(!strcmp(funcname, "SetObjectMaterialText"))
		{
			if(!sscanf(funcargs, "p<,>{s[32]} d p<\">{s[2]}s[32]p<,>{s[2]} s[32] p<\">{s[2]}s[32]p<,>{s[2]} ddxxd", tmpObjIdx, tmpObjText, tmpObjResName, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign))
			{
				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object Text: '%s', %d, '%s', '%s', %d, %d, %x, %x, %d",
						tmpObjText, tmpObjIdx, tmpObjResName, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
				}

				new len = strlen(tmpObjText);

				tmpObjRes = strval(tmpObjResName[0]);

				if(tmpObjRes == 0)
				{
					for(new i; i < sizeof(matSizeTable); i++)
					{
						if(strfind(tmpObjResName, matSizeTable[i]) != -1)
							tmpObjRes = (i + 1) * 10;
					}
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

		if(!strcmp(funcname, "SetDynamicObjectMaterialText"))
		{
			if(!sscanf(funcargs, "p<,>{s[16]} p<\">{s[1]}s[32]p<,>{s[1]} d s[32] p<\">{s[1]}s[32]p<,>{s[1]} ddxxd", tmpObjText, tmpObjIdx, tmpObjResName, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign))
			{
				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object Text: '%s', %d, '%s', '%s', %d, %d, %x, %x, %d",
						tmpObjText, tmpObjIdx, tmpObjResName, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
				}

				new len = strlen(tmpObjText);

				tmpObjRes = strval(tmpObjResName[0]);

				if(tmpObjRes == 0)
				{
					for(new i; i < sizeof(matSizeTable); i++)
					{
						if(strfind(tmpObjResName, matSizeTable[i]) != -1)
							tmpObjRes = (i + 1) * 10;
					}
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
			if(!sscanf(funcargs, "p<,>{s[16]}dd p<\">{s[1]}s[32]p<,>{s[1]} p<\">{s[1]}s[32]p<,>{s[1]} x", tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol))
			{
				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object Material: %d, %d, '%s', '%s', %x",
						tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol);
				}

				SetDynamicObjectMaterial(tmpObjID, tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol);
				operations++;
			}
		}

		if(!strcmp(funcname, "RemoveBuildingForPlayer"))
		{
			if(gTotalObjectsToRemove < MAX_REMOVED_OBJECTS)
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
			else
			{
				printf(" ERROR: [LoadMap] Removal on line %d failed. Removal limit reached.", linenumber);
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
	RemoveObjects_FirstLoad(playerid);

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new
		name[MAX_PLAYER_NAME],
		filename[SESSION_NAME_LEN];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	format(filename, sizeof(filename), DIRECTORY_MAPS DIRECTORY_SESSION"%s.dat", name);

	if(gDebugLevel >= DEBUG_LEVEL_INFO)
		printf("INFO: [OnPlayerDisconnect] Removing session data file for %s", name);

	fremove(filename);

	return 1;
}

RemoveObjects_FirstLoad(playerid)
{
	new
		File:file,
		name[MAX_PLAYER_NAME],
		filename[SESSION_NAME_LEN],
		buffer[5];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	format(filename, sizeof(filename), DIRECTORY_MAPS DIRECTORY_SESSION"%s.dat", name);

	file = fopen(filename, io_write);

	if(!file)
		printf("ERROR: [RemoveObjects_FirstLoad] Opening file '%s' for write.", filename);

	if(gDebugLevel >= DEBUG_LEVEL_INFO)
		printf("INFO: [RemoveObjects_FirstLoad] Created session data for %s", name);

	for(new i; i < gTotalObjectsToRemove; i++)
	{
		RemoveBuildingForPlayer(playerid,
			gModelRemoveData[i][remove_Model],
			gModelRemoveData[i][remove_PosX],
			gModelRemoveData[i][remove_PosY],
			gModelRemoveData[i][remove_PosZ],
			gModelRemoveData[i][remove_Range]);

		// Build a list of removed objects for checking against when the script is
		// reloaded. This way, the reload function isn't called unnecessarily.

		buffer[0] = gModelRemoveData[i][remove_Model];
		buffer[1] = _:gModelRemoveData[i][remove_PosX];
		buffer[2] = _:gModelRemoveData[i][remove_PosY];
		buffer[3] = _:gModelRemoveData[i][remove_PosZ];
		buffer[4] = _:gModelRemoveData[i][remove_Range];

		if(gDebugLevel >= DEBUG_LEVEL_DATA)
			printf("INFO: [RemoveObjects_FirstLoad] Write: [%x.%x.%x.%x.%x]", buffer[0], buffer[1], buffer[2], buffer[3], buffer[4]);

		fblockwrite(file, buffer);
	}

	fclose(file);

	return 1;
}

RemoveObjects_OnLoad(playerid)
{
	new
		File:file,
		name[MAX_PLAYER_NAME],
		filename[SESSION_NAME_LEN],
		buffer[5],
		idx;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	format(filename, sizeof(filename), DIRECTORY_MAPS DIRECTORY_SESSION"%s.dat", name);

	if(!fexist(filename))
	{
		if(gDebugLevel >= DEBUG_LEVEL_INFO)
			printf("INFO: [RemoveObjects_OnLoad] Session data for %s doesn't exist, running firstload.", name);

		RemoveObjects_FirstLoad(playerid);

		return 0;
	}

	file = fopen(filename, io_read);

	if(gDebugLevel >= DEBUG_LEVEL_INFO)
		printf("INFO: [RemoveObjects_OnLoad] Loading removals for %s", name);

	// Build a list of existing removed objects for this player

	while(fblockread(file, gLoadedRemoveBuffer[playerid][idx], 5))
		idx++;

	fclose(file);

	file = fopen(filename, io_append);

	for(new i; i < gTotalObjectsToRemove; i++)
	{
		new skip;

		for(new j; j < idx; j++)
		{
			if(
				_:gModelRemoveData[i][remove_Model] == gLoadedRemoveBuffer[playerid][j][0] &&
				_:gModelRemoveData[i][remove_PosX] == gLoadedRemoveBuffer[playerid][j][1] &&
				_:gModelRemoveData[i][remove_PosY] == gLoadedRemoveBuffer[playerid][j][2] &&
				_:gModelRemoveData[i][remove_PosZ] == gLoadedRemoveBuffer[playerid][j][3] &&
				_:gModelRemoveData[i][remove_Range] == gLoadedRemoveBuffer[playerid][j][4])
			{
				skip = true;
				break;
			}
		}

		if(skip)
		{
			if(gDebugLevel == DEBUG_LEVEL_DATA)
				printf(" DEBUG: [RemoveObjects_OnLoad] Skipping object removal %d (model: %d)", i, gModelRemoveData[i][remove_Model]);

			continue;
		}

		if(gDebugLevel == DEBUG_LEVEL_DATA)
			printf(" DEBUG: [RemoveObjects_OnLoad] Removing object %d (model: %d)", i, gModelRemoveData[i][remove_Model]);

		RemoveBuildingForPlayer(playerid,
			gModelRemoveData[i][remove_Model],
			gModelRemoveData[i][remove_PosX],
			gModelRemoveData[i][remove_PosY],
			gModelRemoveData[i][remove_PosZ],
			gModelRemoveData[i][remove_Range]);

		// This object is new, append it to the player's session data file.

		buffer[0] = gModelRemoveData[i][remove_Model];
		buffer[1] = _:gModelRemoveData[i][remove_PosX];
		buffer[2] = _:gModelRemoveData[i][remove_PosY];
		buffer[3] = _:gModelRemoveData[i][remove_PosZ];
		buffer[4] = _:gModelRemoveData[i][remove_Range];

		if(gDebugLevel >= DEBUG_LEVEL_DATA)
			printf("INFO: [RemoveObjects_OnLoad] Append: [%x.%x.%x.%x.%x]", buffer[0], buffer[1], buffer[2], buffer[3], buffer[4]);

		fblockwrite(file, buffer);
	}

	fclose(file);

	return 1;
}
