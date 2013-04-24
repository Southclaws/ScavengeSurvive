#include "a_samp"
#include "zcmd"


enum
{
	DIALOG_MAIN = 4000,
	DIALOG_INDEX_SELECT,
	DIALOG_MODEL_SELECT,
	DIALOG_BONE_SELECT
}
enum
{
	Float:COORD_X,
	Float:COORD_Y,
	Float:COORD_Z
}


new
	AttachmentBones[18][16] =
	{
		{"Spine"},
		{"Head"},
		{"Left upper arm"},
		{"Right upper arm"},
		{"Left hand"},
		{"Right hand"},
		{"Left thigh"},
		{"Right thigh"},
		{"Left foot"},
		{"Right foot"},
		{"Right calf"},
		{"Left calf"},
		{"Left forearm"},
		{"Right forearm"},
		{"Left clavicle"},
		{"Right clavicle"},
		{"Neck"},
		{"Jaw"}
	};

new
	gCurrentAttachIndex[MAX_PLAYERS],
	bool:gIndexUsed[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS],
	gIndexModel[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS],
	gIndexBone[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS],
	Float:gIndexPos[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][3],
	Float:gIndexRot[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][3],
	Float:gIndexSca[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][3];
	

public OnFilterScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		gCurrentAttachIndex[i] = 0;
		gIndexModel[i][0] = 18636;

		for(new j; j < MAX_PLAYER_ATTACHED_OBJECTS; j++)
		{
			gIndexUsed[i][j] = false;
			gIndexBone[i][j] = 1;
			gIndexSca[i][j][COORD_X] = 1.0;
			gIndexSca[i][j][COORD_Y] = 1.0;
			gIndexSca[i][j][COORD_Z] = 1.0;
		}
	}
}


CMD:hold(playerid,params[])
{
	ShowMainEditMenu(playerid);
	return 1;
}

ShowMainEditMenu(playerid)
{
	new string[89];

	format(string, sizeof(string), "Select Index (%d)\nSelect Model (%d)\nSelect Bone (%d)\nEdit\nClear Index\nSave Attachments",
		gCurrentAttachIndex[playerid], gIndexModel[playerid][gCurrentAttachIndex[playerid]], gIndexBone[playerid][gCurrentAttachIndex[playerid]]);

	ShowPlayerDialog(playerid, DIALOG_MAIN, DIALOG_STYLE_LIST, "Attachment Editor / Main Menu", string, "Accept", "Cancel");
}

ShowIndexList(playerid)
{
	new string[512];
	
	for(new i; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, i))
		{
			if(gIndexUsed[playerid][i])
				format(string, sizeof(string), "%sSlot %d (%s - %d)\n", string, i, AttachmentBones[gIndexBone[playerid][i]], gIndexModel[playerid][i]);

			else
				format(string, sizeof(string), "%sSlot %d (External)\n", string, i);
		}
		else
		{
			format(string, sizeof(string), "%sSlot %d\n", string, i);
		}
	}

	ShowPlayerDialog(playerid, DIALOG_INDEX_SELECT, DIALOG_STYLE_LIST, "Attachment Editor / Index", string, "Accept", "Cancel");
}

ShowModelInput(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_MODEL_SELECT, DIALOG_STYLE_INPUT, "Attachment Editor / Model", "Enter a model to attach", "Accept", "Cancel");
}

ShowBoneList(playerid)
{
	new string[512];
	
	for(new i; i < sizeof(AttachmentBones); i++)
	{
		format(string, sizeof(string), "%s%s\n", string, AttachmentBones[i]);
	}

	ShowPlayerDialog(playerid, DIALOG_BONE_SELECT, DIALOG_STYLE_LIST, "Attachment Editor / Bone", string, "Accept", "Cancel");
}

EditAttachment(playerid)
{
	SetPlayerAttachedObject(playerid,
		gCurrentAttachIndex[playerid],
		gIndexModel[playerid][gCurrentAttachIndex[playerid]],
		gIndexBone[playerid][gCurrentAttachIndex[playerid]],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Z]);

	EditAttachedObject(playerid, gCurrentAttachIndex[playerid]);

	gIndexUsed[playerid][gCurrentAttachIndex[playerid]] = true;
}

ClearCurrentIndex(playerid)
{
	gIndexModel[playerid][gCurrentAttachIndex[playerid]] = 0;
	gIndexBone[playerid][gCurrentAttachIndex[playerid]] = 1;
	gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X] = 0.0;
	gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = 0.0;
	gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = 0.0;
	gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_X] = 0.0;
	gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = 0.0;
	gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = 0.0;
	gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_X] = 0.0;
	gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = 0.0;
	gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = 0.0;
	gIndexUsed[playerid][gCurrentAttachIndex[playerid]] = false;

	RemovePlayerAttachedObject(playerid, gCurrentAttachIndex[playerid]);
	ShowMainEditMenu(playerid);
}

SaveAttachedObjects(playerid)
{
	SendClientMessage(playerid, -1, "Not implemented");

	printf("SetPlayerAttachedObject(playerid, %d, %d, %d,  %f, %f, %f,  %f, %f, %f,  %f, %f, %f);",
		gCurrentAttachIndex[playerid],
		gIndexModel[playerid][gCurrentAttachIndex[playerid]],
		gIndexBone[playerid][gCurrentAttachIndex[playerid]],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_X],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Y],
		gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Z]);

	ShowMainEditMenu(playerid);
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_MAIN)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:ShowIndexList(playerid);
				case 1:ShowModelInput(playerid);
				case 2:ShowBoneList(playerid);
				case 3:EditAttachment(playerid);
				case 4:ClearCurrentIndex(playerid);
				case 5:SaveAttachedObjects(playerid);
			}
		}
	}
	if(dialogid == DIALOG_INDEX_SELECT)
	{
		if(response)
		{
			gCurrentAttachIndex[playerid] = listitem;
			ShowMainEditMenu(playerid);
		}
		else
		{
			ShowMainEditMenu(playerid);
		}

		return 1;
	}
	if(dialogid == DIALOG_MODEL_SELECT)
	{
		if(response)
		{
			gIndexModel[playerid][gCurrentAttachIndex[playerid]] = strval(inputtext);
			ShowMainEditMenu(playerid);
		}
		else
		{
			ShowMainEditMenu(playerid);
		}
	}

	if(dialogid == DIALOG_BONE_SELECT)
	{
		if(response)
		{
			gIndexBone[playerid][gCurrentAttachIndex[playerid]] = listitem + 1;
			ShowMainEditMenu(playerid);
		}
		else
		{
			ShowMainEditMenu(playerid);
		}
	}
	return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	SetPlayerAttachedObject(playerid, index, modelid, boneid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);
	ShowMainEditMenu(playerid);

	gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_X] = fOffsetX;
	gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = fOffsetY;
	gIndexPos[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = fOffsetZ;
	gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_X] = fRotX;
	gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = fRotY;
	gIndexRot[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = fRotZ;
	gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_X] = fScaleX;
	gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Y] = fScaleY;
	gIndexSca[playerid][gCurrentAttachIndex[playerid]][COORD_Z] = fScaleZ;

	return 1;
}
