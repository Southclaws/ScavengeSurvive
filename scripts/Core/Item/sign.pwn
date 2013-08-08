#include <YSI\y_hooks>


#define MAX_SIGN			(128)
#define MAX_SIGN_TEXT		(128)
#define INVALID_SIGN_ID		(-1)

#define SIGN_DATA_FOLDER	"SSS/Signs/"
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


static
			sgn_Data[MAX_SIGN][E_SIGN_DATA],
Iterator:	sgn_Index<MAX_SIGN>;

static
			sgn_CurrentSign[MAX_PLAYERS],
Timer:		sgn_PickUpTimer[MAX_PLAYERS],
			sgn_PressSignTick[MAX_SIGN_TEXT];


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

	DestroyDynamicObject(sgn_Data[signid][sgn_object]);
	DestroyButton(sgn_Data[signid][sgn_button]);

	sgn_Data[signid][sgn_text][0] = EOS;
	sgn_Data[signid][sgn_posX] = 0.0;
	sgn_Data[signid][sgn_posY] = 0.0;
	sgn_Data[signid][sgn_posZ] = 0.0;
	sgn_Data[signid][sgn_rotZ] = 0.0;

	Iter_Remove(sgn_Index, signid);

	return 1;
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
	ShowPlayerDialog(playerid, d_SignEdit, DIALOG_STYLE_INPUT, "Sign", "Enter the text to display below\nTyping '\\n' will start a new line.", "Accept", "Close");
	sgn_CurrentSign[playerid] = signid;
}


public OnButtonPress(playerid, buttonid)
{
	if(!IsValidItem(GetPlayerItem(playerid)))
	{
		foreach(new i : sgn_Index)
		{
			if(buttonid == sgn_Data[i][sgn_button])
			{
				sgn_PressSignTick[playerid] = tickcount();
				sgn_CurrentSign[playerid] = i;

				stop sgn_PickUpTimer[playerid];
				sgn_PickUpTimer[playerid] = defer PickUpSign(playerid);
				break;
			}
		}
	}

	return CallLocalFunction("sgn_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress sgn_OnButtonPress
forward sgn_OnButtonPress(playerid, buttonid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		if(tickcount() - sgn_PressSignTick[playerid] < 250)
		{
			EditSign(playerid, sgn_CurrentSign[playerid]);
			stop sgn_PickUpTimer[playerid];
		}
	}
}

timer PickUpSign[250](playerid)
{
	new filename[64];

	format(filename, sizeof(filename), ""#SIGN_DATA_FOLDER"%d_%d_%d_%d",
		sgn_Data[sgn_CurrentSign[playerid]][sgn_posX],
		sgn_Data[sgn_CurrentSign[playerid]][sgn_posY],
		sgn_Data[sgn_CurrentSign[playerid]][sgn_posZ],
		sgn_Data[sgn_CurrentSign[playerid]][sgn_rotZ]);

	fremove(filename);

	DestroySign(sgn_CurrentSign[playerid]);
	GiveWorldItemToPlayer(playerid, CreateItem(item_Sign, 0.0, 0.0, 0.0), true);
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_SignEdit)
	{
		if(response)
		{
			if(!isnull(inputtext))
				SetSignText(sgn_CurrentSign[playerid], inputtext);
		}
	}
}

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Sign)
	{
		new
			tmpsign,
			Float:x,
			Float:y,
			Float:z,
			Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		DestroyItem(itemid);
		tmpsign = CreateSign("I am a sign.", x + floatsin(-a, degrees), y + floatcos(-a, degrees), z - 1.0, a - 90.0);
		EditSign(playerid, tmpsign);

		return 1;
	}
	return CallLocalFunction("sgn_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem sgn_OnPlayerUseItem
forward sgn_OnPlayerUseItem(playerid, itemid);


hook OnGameModeInit()
{
	new
		dir:direc = dir_open(SIGN_DATA_DIR),
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
			filedir = SIGN_DATA_FOLDER;
			strcat(filedir, item);
			file = fopen(filedir, io_read);

			if(file)
			{
				fblockread(file, text, sizeof(text));
				fclose(file);

				sscanf(item, "p<_>dddd", _:x, _:y, _:z, _:r);

				CreateSign(text, Float:x, Float:y, Float:z, Float:r);
			}
		}
	}

	dir_close(direc);
}

hook OnGameModeExit()
{
	foreach(new i : sgn_Index)
	{
		new
			filename[64],
			File:file;

		format(filename, sizeof(filename), ""#SIGN_DATA_FOLDER"%d_%d_%d_%d",
			sgn_Data[i][sgn_posX], sgn_Data[i][sgn_posY], sgn_Data[i][sgn_posZ], sgn_Data[i][sgn_rotZ]);

		file = fopen(filename, io_write);

		if(file)
		{
			fblockwrite(file, sgn_Data[i][sgn_text], MAX_SIGN_TEXT);
			fclose(file);
		}
		else
		{
			printf("ERROR: Saving sign, filename: '%s'", filename);
		}
	}
	return 1;
}
