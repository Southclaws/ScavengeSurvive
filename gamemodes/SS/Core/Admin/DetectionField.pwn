#include <YSI\y_hooks>


#define MAX_DETECTION_FIELD			(32)
#define MAX_DETECTION_FIELD_NAME	(24)
#define MAX_DETECTION_FIELD_ENTRIES	(32)
#define DET_DATA_FOLDER				"SSS/DetField/"
#define DET_DATA_DIR				"./scriptfiles/SSS/DetField/"


enum E_DETECTION_FIELD_DATA
{
			det_areaId,
			det_name[MAX_DETECTION_FIELD_NAME],
Float:		det_posX,
Float:		det_posY,
Float:		det_posZ
}


static
			det_Data[MAX_DETECTION_FIELD][E_DETECTION_FIELD_DATA],
Iterator:	det_Index<MAX_DETECTION_FIELD>;


/*==============================================================================

	Core

==============================================================================*/


stock CreateDetectionField(name[MAX_DETECTION_FIELD_NAME], Float:x, Float:y, Float:z, Float:range)
{
	new id = Iter_Free(det_Index);

	if(id == -1)
	{
		print("ERROR: MAX_DETECTION_FIELD limit reached.");
		return -1;
	}

	det_Data[id][det_areaId] = CreateDynamicSphere(x, y, z, range);
	det_Data[id][det_name] = name;
	det_Data[id][det_posX] = x;
	det_Data[id][det_posY] = y;
	det_Data[id][det_posZ] = z;

	Iter_Add(det_Index, id);

	return id;
}

stock DestroyDetectionField(id)
{
	if(!Iter_Contains(det_Index, id))
		return 0;

	DestroyDynamicArea(det_Data[id][det_areaId]);
	det_Data[id][det_name][0] = EOS;
	det_Data[id][det_posX] = 0.0;
	det_Data[id][det_posY] = 0.0;
	det_Data[id][det_posZ] = 0.0;

	Iter_Remove(det_Index, id);

	return 1;
}

stock AddDetectionField(name[MAX_DETECTION_FIELD_NAME], Float:x, Float:y, Float:z, Float:range)
{
	new
		File:file,
		filename[64],
		line[MAX_PLAYER_NAME + 36 + 2];

	format(filename, 64, ""DET_DATA_FOLDER"%s.txt", name);

	if(fexist(filename))
		return -1;

	if(CreateDetectionField(name, x, y, z, range) == -1)
		return 0;

	file = fopen(filename, io_write);

	if(!file)
		return -2;

	format(line, sizeof(line), "%s, %f, %f, %f, %f\r\n", name, x, y, z, range);

	fwrite(file, line);
	fclose(file);

	return 1;
}

stock RemoveDetectionField(id)
{
	if(!Iter_Contains(det_Index, id))
		return 0;

	new filename[64];

	format(filename, 64, ""DET_DATA_DIR"%s.txt", det_Data[id][det_name]);

	if(!file_exists(filename))
		return -1;

	file_delete(filename);

	DestroyDetectionField(id);

	return 1;
}

stock ShowDetectionFieldLog(playerid, id)
{
	new
		File:file,
		filename[64],
		line[MAX_PLAYER_NAME + 36 + 2],
		list[MAX_DETECTION_FIELD_ENTRIES * sizeof(line)],
		idx;

	format(filename, 64, ""DET_DATA_FOLDER"%s.txt", det_Data[id][det_name]);

	file = fopen(filename, io_read);

	if(!file)
		return 0;

	while(fread(file, line))
	{
		if(idx == MAX_DETECTION_FIELD_ENTRIES)
			break;

		strcat(list, line);

		idx++;
	}

	fclose(file);

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_LIST, det_Data[id][det_name], list, "Close", "");

	return 1;
}

ShowDetectionFieldList(playerid)
{
	new
		list[MAX_DETECTION_FIELD * (MAX_DETECTION_FIELD_NAME + 1)];

	foreach(new i : det_Index)
	{
		strcat(list, det_Data[i][det_name]);
		strcat(list, "\n");
	}

	ShowPlayerDialog(playerid, d_DetFieldList, DIALOG_STYLE_LIST, "Detection Fields", list, "View", "Close");
}


/*==============================================================================

	Internal

==============================================================================*/


public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : det_Index)
	{
		if(areaid == det_Data[i][det_areaId])
		{
			DetectionFieldLogPlayer(playerid, i);

			if(GetPlayerAdminLevel(playerid) >= 3)
				MsgF(playerid, YELLOW, " >  Entered detection field '%s'", det_Data[i][det_name]);
		}
	}

	return CallLocalFunction("det_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea det_OnPlayerEnterDynamicArea
forward det_OnPlayerEnterDynamicArea(playerid, areaid);

DetectionFieldLogPlayer(playerid, id)
{
	new
		File:file,
		filename[64],
		line[MAX_PLAYER_NAME + 36 + 2];

	format(filename, 64, ""DET_DATA_FOLDER"%s.txt", det_Data[id][det_name]);

	file = fopen(filename, io_append);

	if(!file)
	{
		printf("ERROR: Writing to file '%s'", filename);
		return 0;
	}

	format(line, sizeof(line), "%p, %s\r\n", playerid, TimestampToDateTime(gettime()));

	fwrite(file, line);
	fclose(file);

	printf("[DET] %p entered %s at %s", playerid, det_Data[id][det_name], TimestampToDateTime(gettime()));

	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_DetFieldList)
	{
		if(response)
		{
			ShowDetectionFieldLog(playerid, listitem);
		}
	}

	return 1;
}

hook OnGameModeInit()
{
	new
		dir:direc = dir_open(DET_DATA_DIR),
		item[46],
		type,

		File:file,
		filename[64],
		line[128],

		name[MAX_DETECTION_FIELD_NAME],
		Float:x,
		Float:y,
		Float:z,
		Float:range;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			filename = DET_DATA_FOLDER;
			strcat(filename, item);
			file = fopen(filename, io_read);

			if(file)
			{
				fread(file, line, sizeof(line));
				fclose(file);

				sscanf(line, "p<,>s[24]ffff", name, x, y, z, range);

				CreateDetectionField(name, x, y, z, range);
			}
		}
	}

	dir_close(direc);

	printf("Loaded %d Detection Fields\n", Iter_Count(det_Index));
}


/*==============================================================================

	Interface

==============================================================================*/


GetDetectionFieldIdFromName(name[], bool:ignorecase = false)
{
	foreach(new i : det_Index)
	{
		if(!strcmp(name, det_Data[i][det_name], ignorecase))
		{
			return i;
		}
	}

	return -1;
}

ACMD:field[3](playerid, params[])
{
	if(isnull(params))
	{
		Msg(playerid, YELLOW, " >  Usage: /field ['add' <name> <range>] / ['remove' <name>] / ['data' <name>]");
		return 1;
	}

	if(!strcmp(params, "add", true, 3))
	{
		new
			name[MAX_DETECTION_FIELD_NAME],
			Float:x,
			Float:y,
			Float:z,
			Float:range;

		GetPlayerPos(playerid, x, y, z);
		
		if(sscanf(params, "{s[4]}s[24]f", name, range))
		{
			Msg(playerid, YELLOW, " >  Usage: /field add [name] [range]");
			return 1;
		}

		new ret = AddDetectionField(name, x, y, z, range);

		if(ret == 1)
			MsgF(playerid, YELLOW, " >  Detection field '%s' added.", name);

		else if(ret == -1)
			Msg(playerid, RED, " >  Error: already exists, choose a different name.");

		else
			MsgF(playerid, RED, " >  Error code: %d", ret);
	}

	if(!strcmp(params, "remove", true, 6))
	{
		new
			name[MAX_DETECTION_FIELD_NAME],
			id;

		if(sscanf(params, "{s[7]}s[24]", name))
		{
			Msg(playerid, YELLOW, " >  Usage: /field remove [name]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!Iter_Contains(det_Index, id))
		{
			Msg(playerid, YELLOW, " >  Invalid detection field name");
			return 1;
		}

		new ret = RemoveDetectionField(id);

		if(ret == 1)
			MsgF(playerid, YELLOW, " >  Removing Detection Field '%s'.", name);

		else if(ret == -1)
			Msg(playerid, RED, " >  Error: file doesn't exist.");

		else
			MsgF(playerid, YELLOW, " >  Error code: %d", ret);
	}

	if(!strcmp(params, "data", true, 4))
	{
		new
			name[MAX_DETECTION_FIELD_NAME],
			id;

		if(sscanf(params, "{s[5]}s[24]", name))
		{
			Msg(playerid, YELLOW, " >  Usage: /field data [name]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!Iter_Contains(det_Index, id))
		{
			Msg(playerid, YELLOW, " >  Invalid detection field name");
			return 1;
		}

		MsgF(playerid, YELLOW, " >  Displaying log entries for detection field '%s'.", name);

		ShowDetectionFieldLog(playerid, id);
	}

	if(!strcmp(params, "list", true, 4))
	{
		ShowDetectionFieldList(playerid);
	}

	return 1;
}
