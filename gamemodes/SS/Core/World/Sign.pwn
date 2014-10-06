#include <YSI\y_hooks>


#define DIRECTORY_SIGNS		DIRECTORY_MAIN"Signs/"
#define MAX_SIGN			(1024)
#define MAX_SIGN_TEXT		(128)
#define INVALID_SIGN_ID		(-1)

#define SIGN_DATA_DIR		"./scriptfiles/SSS/Signs/"


enum E_SIGN_DATA
{
			sgn_object,
			sgn_button,
			sgn_text[MAX_SIGN_TEXT],
Float:		sgn_posX,
Float:		sgn_posY,
Float:		sgn_posZ,
Float:		sgn_rotZ,
}


new
			sgn_Data[MAX_SIGN][E_SIGN_DATA],
Iterator:	sgn_Index<MAX_SIGN>;

static
			sgn_CurrentSign[MAX_PLAYERS],
Timer:		sgn_PickUpTimer[MAX_PLAYERS],
			sgn_PressSignTick[MAX_SIGN_TEXT];

// Settings: Prefixed camel case here and dashed in settings.json
static
bool:		sgn_PrintEachLoad,
bool:		sgn_PrintTotalLoad,
bool:		sgn_PrintEachSave,
bool:		sgn_PrintEachRuntimeSave,
bool:		sgn_PrintTotalSave,
bool:		sgn_PrintRemoves;


/*==============================================================================

	Directory check

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Sign'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_SIGNS);

	GetSettingInt("sign/print-each-load", false, sgn_PrintEachLoad);
	GetSettingInt("sign/print-total-load", true, sgn_PrintTotalLoad);
	GetSettingInt("sign/print-each-save", false, sgn_PrintEachSave);
	GetSettingInt("sign/print-each-runtime-save", false, sgn_PrintEachRuntimeSave);
	GetSettingInt("sign/print-total-save", true, sgn_PrintTotalSave);
	GetSettingInt("sign/print-removes", false, sgn_PrintRemoves);
}


/*==============================================================================

	Core

==============================================================================*/


stock CreateSign(text[MAX_SIGN_TEXT], Float:x, Float:y, Float:z, Float:rot)
{
	new id = Iter_Free(sgn_Index);

	if(id == -1)
		return INVALID_SIGN_ID;


	sgn_Data[id][sgn_object] = CreateDynamicObject(19471, x, y, z, 0.0, 0.0, rot);
	sgn_Data[id][sgn_button] = CreateButton(x, y, z + 0.8, "Press F to edit");

	sgn_Data[id][sgn_text] = text;
	sgn_Data[id][sgn_posX] = x;
	sgn_Data[id][sgn_posY] = y;
	sgn_Data[id][sgn_posZ] = z;
	sgn_Data[id][sgn_rotZ] = rot;

	SetDynamicObjectMaterialText(sgn_Data[id][sgn_object], 0, text, OBJECT_MATERIAL_SIZE_512x512, "Arial", 72, 1, -16777216, -1, 1);


	Iter_Add(sgn_Index, id);

	return id;
}

stock DestroySign(signid)
{
	if(!Iter_Contains(sgn_Index, signid))
		return 0;

	new next;

	DestroyDynamicObject(sgn_Data[signid][sgn_object]);
	DestroyButton(sgn_Data[signid][sgn_button]);

	sgn_Data[signid][sgn_text][0] = EOS;
	sgn_Data[signid][sgn_posX] = 0.0;
	sgn_Data[signid][sgn_posY] = 0.0;
	sgn_Data[signid][sgn_posZ] = 0.0;
	sgn_Data[signid][sgn_rotZ] = 0.0;

	Iter_SafeRemove(sgn_Index, signid, next);

	return next;
}


SetSignText(signid, text[])
{
	if(!Iter_Contains(sgn_Index, signid))
		return 0;

	strreplace(text, "\\n", "\n", .maxlength = MAX_SIGN_TEXT);

	strcpy(sgn_Data[signid][sgn_text], text, MAX_SIGN_TEXT);
	strcat(sgn_Data[signid][sgn_text], "\n\n\n");

	SetDynamicObjectMaterialText(sgn_Data[signid][sgn_object], 0, text, OBJECT_MATERIAL_SIZE_512x512, "Arial", 72, 1, -16777216, -1, 1);

	return 1;
}

EditSign(playerid, signid)
{
	CancelPlayerMovement(playerid);
	sgn_CurrentSign[playerid] = signid;

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem
		if(response)
		{
			if(!isnull(inputtext))
				SetSignText(sgn_CurrentSign[playerid], inputtext);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Sign", "Enter the text to display below\nTyping '\\n' will start a new line.", "Accept", "Close");

	return 1;
}


/*==============================================================================

	Internal

==============================================================================*/


public OnButtonPress(playerid, buttonid)
{
	if(!IsValidItem(GetPlayerItem(playerid)) && !IsValidItem(GetPlayerInteractingItem(playerid)))
	{
		foreach(new i : sgn_Index)
		{
			if(buttonid == sgn_Data[i][sgn_button])
			{
				sgn_PressSignTick[playerid] = GetTickCount();
				sgn_CurrentSign[playerid] = i;

				stop sgn_PickUpTimer[playerid];
				sgn_PickUpTimer[playerid] = defer PickUpSign(playerid);

				break;
			}
		}
	}

	#if defined sgn_OnButtonPress
		return sgn_OnButtonPress(playerid, buttonid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress sgn_OnButtonPress
#if defined sgn_OnButtonPress
	forward sgn_OnButtonPress(playerid, buttonid);
#endif

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		if(GetTickCountDifference(GetTickCount(), sgn_PressSignTick[playerid]) < 250)
		{
			EditSign(playerid, sgn_CurrentSign[playerid]);
			stop sgn_PickUpTimer[playerid];
		}
	}
}

timer PickUpSign[250](playerid)
{
	if(IsValidItem(GetPlayerItem(playerid)) && IsValidItem(GetPlayerInteractingItem(playerid)))
		return;

	new filename[64];

	format(filename, sizeof(filename), ""DIRECTORY_SIGNS"%d_%d_%d_%d",
		sgn_Data[sgn_CurrentSign[playerid]][sgn_posX],
		sgn_Data[sgn_CurrentSign[playerid]][sgn_posY],
		sgn_Data[sgn_CurrentSign[playerid]][sgn_posZ],
		sgn_Data[sgn_CurrentSign[playerid]][sgn_rotZ]);

	fremove(filename);

	DestroySign(sgn_CurrentSign[playerid]);
	GiveWorldItemToPlayer(playerid, CreateItem(item_Sign, 0.0, 0.0, 0.0), true);
}


/*==============================================================================

	Load/Save

==============================================================================*/


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Sign'...");

	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_SIGNS),
		item[46],
		type,
		File:file,
		filedir[64],

		Float:x,
		Float:y,
		Float:z,
		Float:r,
		text[MAX_SIGN_TEXT];

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			filedir = DIRECTORY_SIGNS;
			strcat(filedir, item);
			file = fopen(filedir, io_read);

			if(file)
			{
				fblockread(file, text, sizeof(text));
				fclose(file);

				sscanf(item, "p<_>dddd", _:x, _:y, _:z, _:r);

				if(sgn_PrintEachLoad)
					printf("\t[LOAD] Sign '%s' at %f, %f, %f", text, x, y, z);

				CreateSign(text, Float:x, Float:y, Float:z, Float:r);
			}
		}
	}

	dir_close(direc);

	if(sgn_PrintTotalLoad)
		printf("Loaded %d Signs", Iter_Count(sgn_Index));

	return 1;
}

hook OnScriptExit()
{
	print("\n[OnScriptExit] Shutting down 'Sign'...");

	foreach(new i : sgn_Index)
	{
		new
			filename[64],
			File:file;

		format(filename, sizeof(filename), ""DIRECTORY_SIGNS"%d_%d_%d_%d",
			sgn_Data[i][sgn_posX], sgn_Data[i][sgn_posY], sgn_Data[i][sgn_posZ], sgn_Data[i][sgn_rotZ]);

		file = fopen(filename, io_write);

		if(file)
		{
			if(sgn_PrintEachSave)
				printf("\t[SAVE] Sign '%s' at %f, %f, %f", sgn_Data[i][sgn_text], sgn_Data[i][sgn_posX], sgn_Data[i][sgn_posY], sgn_Data[i][sgn_posZ]);

			fblockwrite(file, sgn_Data[i][sgn_text], MAX_SIGN_TEXT);
			fclose(file);
		}
		else
		{
			printf("ERROR: Saving sign, filename: '%s'", filename);
		}
	}

	if(sgn_PrintTotalSave)
		printf("Saved %d Signs", Iter_Count(sgn_Index));

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsValidSign(signid)
{
	if(!Iter_Contains(sgn_Index, signid))
		return 0;

	return 1;
}

// sgn_object
stock GetSignObjectID(signid)
{
	if(!Iter_Contains(sgn_Index, signid))
		return INVALID_OBJECT_ID;

	return sgn_Data[signid][sgn_object];
}

// sgn_button
stock GetSignButtonID(signid)
{
	if(!Iter_Contains(sgn_Index, signid))
		return INVALID_BUTTON_ID;

	return sgn_Data[signid][sgn_button];
}

// sgn_text
stock GetSignText(signid, text[MAX_SIGN_TEXT])
{
	if(!Iter_Contains(sgn_Index, signid))
		return 0;

	text = sgn_Data[signid][sgn_text];

	return 1;
}

// sgn_posX
// sgn_posY
// sgn_posZ
stock GetSignPos(signid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(sgn_Index, signid))
		return 0;

	x = sgn_Data[signid][sgn_posX];
	y = sgn_Data[signid][sgn_posY];
	z = sgn_Data[signid][sgn_posZ];

	return 1;
}

stock SetSignPos(signid, Float:x, Float:y, Float:z)
{
	if(!Iter_Contains(sgn_Index, signid))
		return 0;

	sgn_Data[signid][sgn_posX] = x;
	sgn_Data[signid][sgn_posY] = y;
	sgn_Data[signid][sgn_posZ] = z;

	return 1;
}

// sgn_rotZ
stock GetSignRot(signid, &Float:angle)
{
	if(!Iter_Contains(sgn_Index, signid))
		return 0;

	angle = sgn_Data[signid][sgn_rotZ];

	return 1;
}

stock SetSignRot(signid, Float:angle)
{
	if(!Iter_Contains(sgn_Index, signid))
		return 0;

	sgn_Data[signid][sgn_rotZ] = angle;

	return 1;
}

