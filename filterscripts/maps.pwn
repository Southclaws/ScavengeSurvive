#define FILTERSCRIPT

#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS (32)

#include <streamer>					// By Incognito:			http://forum.sa-mp.com/showthread.php?t=102865
#include <sscanf2>					// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=120356
#include <zcmd>						// ZeeX						http://forum.sa-mp.com/showthread.php?t=91354
#include <FileManager>				// By JaTochNietDan:		http://forum.sa-mp.com/showthread.php?t=92246


#define MAX_REMOVED_OBJECTS	(1000)
#define MAX_MATERIAL_SIZE	(14)
#define MAX_MATERIAL_LEN	(8)


enum E_REMOVE_DATA
{
		remove_Model,
Float:	remove_PosX,
Float:	remove_PosY,
Float:	remove_PosZ,
Float:	remove_Range
}


new
		gModelRemoveData[MAX_REMOVED_OBJECTS][E_REMOVE_DATA],
		gTotalObjectsToRemove;


public OnFilterScriptInit()
{
	print("\n---------------------------");
	print(" Object Placement Script Loaded");

	LoadMapsFromFolder("Maps");

	printf("   %d - Total Objects", CountDynamicObjects());
	printf("   %d - Objects to remove", gTotalObjectsToRemove);
	print("---------------------------\n");

	for(new i; i < MAX_PLAYERS; i++)
		RemoveObjectsForPlayer(i);

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

	format(foldername, sizeof(foldername), "./scriptfiles/%s/", folder);
	dirhandle = dir_open(foldername);

	while(dir_list(dirhandle, item, type))
	{
		if(type == FM_DIR && strcmp(item, "..") && strcmp(item, ".") && strcmp(item, "_"))
		{
			filename[0] = EOS;
			format(filename, sizeof(filename), "%s/%s", folder, item);
			LoadMapsFromFolder(filename);
		}
		if(type == FM_FILE)
		{
			if(!strcmp(item[strlen(item) - 4], ".map"))
			{
				filename[0] = EOS;
				format(filename, sizeof(filename), "%s/%s", folder, item);
				LoadMap(filename);
			}
		}
	}

	dir_close(dirhandle);
}

LoadMap(filename[])
{
	new
		File:file,
		loadedmeta,
		str[192],
		
		world[1],
		interior[1],
		streamdist,

		modelid,
		Float:data[6],
		line,
		
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

	while(fread(file, str))
	{
		if(!loadedmeta)
		{
			if(!sscanf(str, "p<,>ddd", world[0], interior[0], streamdist))
			{
				loadedmeta = true;
			}

			if(line > 1)
			{
				world[0] = -1;
				interior[0] = -1;
				streamdist = 350;
				loadedmeta = true;

				printf("ERROR: Map file '%s' metadata must be defined on first line. Defaults loaded.", filename);
			}
		}

		if(!sscanf(str, "p<(>{s[32]}p<,>dfffffp<)>f{s[4]}", modelid, data[0], data[1], data[2], data[3], data[4], data[5]))
		{
			tmpObjID = CreateDynamicObjectEx(modelid, data[0], data[1], data[2], data[3], data[4], data[5], streamdist, streamdist + 100.0, world, interior);
		}
		else if(!sscanf(str, "'objtxt(' p<\">{s[1]}s[32]p<,>{s[1]} ds[32]p<\">{s[1]}s[32]p<,>{s[1]}ddddp<)>d", tmpObjText, tmpObjIdx, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign))
		{
			new len = strlen(tmpObjText);

			for(new i;i<sizeof matSizeTable;i++)
				if(strfind(tmpObjResName, matSizeTable[i]) != -1)
					tmpObjRes = (i + 1) * 10;

			for(new c;c<len;c++)
			{
				if(tmpObjText[c] == '\\' && c != len-1)
				{
					if(tmpObjText[c+1] == 'n')
					{
						strdel(tmpObjText, c, c+1);
						tmpObjText[c] = '\n';
					}
				}
			}

			SetDynamicObjectMaterialText(tmpObjID, tmpObjIdx, tmpObjText, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
		}
		else if(!sscanf(str, "'objmat('p<,>dd p<\">{s[1]}s[32]p<,>{s[1]} p<\">{s[1]}s[32]p<,>{s[1]} p<)>d", tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol))
		{
			SetDynamicObjectMaterial(tmpObjID, tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol);
		}
		else if(!sscanf(str, "p<(>{s[32]}p<,>'playerid'dfffp<)>f{s[8]}", modelid, data[0], data[1], data[2], data[3]))
		{
			gModelRemoveData[gTotalObjectsToRemove][remove_Model] = modelid;
			gModelRemoveData[gTotalObjectsToRemove][remove_PosX] = data[0];
			gModelRemoveData[gTotalObjectsToRemove][remove_PosY] = data[1];
			gModelRemoveData[gTotalObjectsToRemove][remove_PosZ] = data[2];
			gModelRemoveData[gTotalObjectsToRemove][remove_Range] = data[3];

			gTotalObjectsToRemove++;
		}

		line++;
	}

	fclose(file);

	return line;
}

public OnPlayerConnect(playerid)
{
	RemoveObjectsForPlayer(playerid);
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
