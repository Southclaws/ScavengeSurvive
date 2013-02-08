#define MAX_SIGN		(128)
#define MAX_SIGN_TEXT	(128)
#define INVALID_SIGN_ID	(-1)


enum E_SIGN_DATA
{
			sgn_object,
			sgn_button,
			sgn_text[MAX_SIGN_TEXT],
			sgn_owner[MAX_PLAYER_NAME],
Float:		sgn_posX,
Float:		sgn_posY,
Float:		sgn_posZ,
Float:		sgn_rotZ,
}


static
			sgn_Data[MAX_SIGN][E_SIGN_DATA],
Iterator:	sgn_Index<MAX_SIGN>;

static
			sgn_CurrentSign[MAX_PLAYERS];

new
ItemType:	item_Sign = INVALID_ITEM_TYPE;


stock CreateSign(playerid, text[MAX_SIGN_TEXT], Float:x, Float:y, Float:z, Float:rot)
{
	new id = Iter_Free(sgn_Index);

	if(id == -1)
		return INVALID_SIGN_ID;


	sgn_Data[id][sgn_object] = CreateDynamicObject(19471, x, y, z, 0.0, 0.0, rot);
	sgn_Data[id][sgn_button] = CreateButton(x, y, z, "Press F to edit");

	sgn_Data[id][sgn_text] = text;
	GetPlayerName(playerid, sgn_Data[id][sgn_owner], MAX_PLAYER_NAME);
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

	sgn_Data[signid][sgn_text] = text;
	sgn_Data[signid][sgn_owner][0] = EOS;
	sgn_Data[signid][sgn_posX] = x;
	sgn_Data[signid][sgn_posY] = y;
	sgn_Data[signid][sgn_posZ] = z;
	sgn_Data[signid][sgn_rotZ] = rot;

	Iter_Remove(sgn_Index, signid);

	return 1;
}





SetSignText(signid, text[])
{
	if(!Iter_Contains(sgn_Index, signid))
		return 0;

	strcpy(sgn_Data[signid][sgn_text], text, MAX_SIGN_TEXT);

	SetDynamicObjectMaterialText(sgn_Data[signid][sgn_object], 0, text, OBJECT_MATERIAL_SIZE_512x512, "Arial", 72, 1, -16777216, -1, 1);

	return 1;
}

EditSign(playerid, signid)
{
	ShowPlayerDialog(playerid, d_SignEdit, DIALOG_STYLE_INPUT, "Sign", "Enter the text to display below\nTyping '\\n' will start a new line.", "Accept", "Close");
	sgn_CurrentSign[playerid] = signid;
}





public OnButtonPress(playerid, buttonid)
{
	foreach(new i : sgn_Index)
	{
		if(buttonid == sgn_Data[i][sgn_button])
		{
			new name[MAX_PLAYER_NAME];
			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			if(!strcmp(sgn_Data[i][sgn_owner], name))
				EditSign(playerid, i);

			else
				SendClientMessage(playerid, YELLOW, "You cannot edit someone elses sign!");

			break;
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

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_SignEdit)
	{
		if(response)
		{
			if(strlen(inputtext) > 2)
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
		tmpsign = CreateSign(playerid, "I am a sign.", x + floatsin(-a, degrees), y + floatcos(-a, degrees), z - 1.0, a - 90.0);
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
