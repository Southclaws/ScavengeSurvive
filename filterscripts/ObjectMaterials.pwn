/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


/*
 *  Southclaws' Texture Workshop (Version 1.6)
 *      ~ Highlight indexes
 *      ~ Texture library, powered by the community!
 *      ~ Save multiple textures on one object
 *      ~ Easy to use GUI!
 *
 */


#include <a_samp>
#include <sscanf2>


#define MAX_MATERIAL		120
#define MAX_INDEX			16
#define DIALOG_OFFSET		5040
#define MAX_OBJECT_TEXT 	128

#define MAX_MATERIAL_SIZE	14
#define MAX_MATERIAL_LEN	8

#define MAX_FONT_TYPE       8 // I don't really know how many fonts are available to use!
#define MAX_FONT_LEN		32

#define MAX_COLOUR			14
#define MAX_COLOUR_NAME     8

#define MAX_ALIGNMENT_TYPE  3
#define MAX_ALIGNMENT_LEN   7

#define IDX_TYPE_UNUSED     -1
#define IDX_TYPE_MATERIAL   0
#define IDX_TYPE_TEXT       1

#define Msg					SendClientMessage
#define strcpy(%0,%1)		strcat((%0[0] = '\0', %0), %1)
#define YELLOW				0xFFFF00FF

// Thanks Y_Less
#define MAKE_COLOUR_ALPHA(%0,%1,%2,%3) ((((%0) & 0xFF) << 24) | (((%1) & 0xFF) << 16) | (((%2) & 0xFF) << 8) | (((%3) & 0xFF) << 0))


#define OUTPUT_FILE			"MaterialDataOutput.txt"
#define DATA_FILE			"MaterialData.txt"
#define ANGLE_ROTATION		0
#define ANGLE_ELEVATION		1


enum
{
	d_MainMenu = DIALOG_OFFSET,
	d_ObjIdInput,
	d_MaterialList,
	d_SaveNameInput,

	d_TexIdxInput,
	d_ModelIdInput,
	d_TxdNameInput,
	d_TexNameInput,
	d_MatColourInput,
	d_MatOpacityInput,
	
	d_TextMenu,
	
	d_TxtInput,
	d_TxtMatSzInput,
	d_TxtFontInput,
	d_TxtFontSzInput,
	d_TxtFontColInput,
	d_TxtFontOpcInput,
	d_TxtBackColInput,
	d_TxtBackOpcInput,
	d_TxtAlignInput

}

enum MATERIAL_ENUM
{
	MODELID,
	TXDNAME[32],
	TEXNAME[32]
}

new
	bool:inEditMode	[MAX_PLAYERS],
	editObj			[MAX_PLAYERS],
	Float:camAngle	[MAX_PLAYERS][2],
	Float:camDist	[MAX_PLAYERS],
	Float:objPos	[MAX_PLAYERS][3],
	Float:oldCam	[MAX_PLAYERS][3],
	previewIdx		[MAX_PLAYERS],
	editModel		[MAX_PLAYERS],
	editTimer		[MAX_PLAYERS],
	flashTimer		[MAX_PLAYERS],

	tmpTexIdx		[MAX_PLAYERS],
	tmpModelId      [MAX_PLAYERS][MAX_INDEX],
	tmpTxdName      [MAX_PLAYERS][MAX_INDEX][32],
	tmpTexName      [MAX_PLAYERS][MAX_INDEX][32],
	tmpMatColour    [MAX_PLAYERS][MAX_INDEX],
	tmpMatOpacity   [MAX_PLAYERS][MAX_INDEX],
	
	tmpIdxType		[MAX_PLAYERS][MAX_INDEX],
	
	tmpObjText		[MAX_PLAYERS][MAX_INDEX][MAX_OBJECT_TEXT],
	tmpObjMatSz		[MAX_PLAYERS][MAX_INDEX],
	tmpObjFont		[MAX_PLAYERS][MAX_INDEX][MAX_FONT_LEN],
	tmpObjFontSz	[MAX_PLAYERS][MAX_INDEX],
	tmpObjBold		[MAX_PLAYERS][MAX_INDEX],
	tmpObjFontCol	[MAX_PLAYERS][MAX_INDEX],
	tmpObjFontOpc   [MAX_PLAYERS][MAX_INDEX],
	tmpObjBackCol	[MAX_PLAYERS][MAX_INDEX],
	tmpObjBackOpc   [MAX_PLAYERS][MAX_INDEX],
	tmpObjAlign		[MAX_PLAYERS][MAX_INDEX],


	fileData		[MAX_MATERIAL][MATERIAL_ENUM],

	PlayerText:txtLeft,
	PlayerText:txtData,
	PlayerText:txtRight,
	PlayerText:txtSave,

	PlayerText:txtContU,
	PlayerText:txtContD,
	PlayerText:txtContL,
	PlayerText:txtContR;

enum COL_DATA
{
	COLOUR_NAME[MAX_COLOUR_NAME],
	COLOUR_VALUE
}

new
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
    },
    fontTable[MAX_FONT_TYPE][MAX_FONT_LEN] =
    {
        "Arial",
        "Arial Black",
        "Courier New",
        "Georgia",
        "Impact",
        "Tahoma",
        "Times New Roman",
        "Verdana"
    },
    colourTable[MAX_COLOUR][COL_DATA]=
    {
		{"Black",	0xFF000000},
		{"White",	0xFFFFFFFF},
		{"Yellow",	0xFFFFFF00},
		{"Red",		0xFFAA3333},
		{"Green",	0xFF33AA33},
		{"Blue",	0xFF33CCFF},
		{"Orange",	0xFFFF9900},
		{"Grey",	0xFFAFAFAF},
		{"Pink",	0xFFFFC0CB},
		{"Navy",	0xFF000080},
		{"Gold",	0xFFB8860B},
		{"Teal",	0xFF008080},
		{"Brown",	0xFFA52A2A},
		{"Aqua",	0xFFF0F8FF}
    },
    textAlignmentTable[MAX_ALIGNMENT_TYPE][MAX_ALIGNMENT_LEN] =
    {
		"Left",
		"Center",
		"Right"
    };

forward editorUpdate(playerid);
forward FlashObjectTexture(playerid);

public OnFilterScriptInit()
{
}
public OnFilterScriptExit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		if(IsValidPlayerObject(i, editObj[i]))DestroyPlayerObject(i, editObj[i]);
		KillTimer(editTimer[i]);
		ToggleGUI(i, false);
	}
}
public OnPlayerConnect(playerid)
{
	LoadTextDrawsForPlayer(playerid);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/editmode"))
	{
	    EnterEditMode(playerid);
		LoadTextDrawsForPlayer(playerid);
		return 1;
	}
	if(!strcmp(cmdtext, "/exitedit"))
	{
	    ExitEditMode(playerid);
		return 1;
	}
	if(!strcmp(cmdtext, "/menu")) // This is a command for in case your keyboard explodes and only has the 't', '/', 'm', 'e', 'n', and 'u' keys available
	{
	    FormatMainMenu(playerid);
	    return 1;
	}
	if(!strcmp(cmdtext, "/td"))
	{
	    LoadTextDrawsForPlayer(playerid);
	    Msg(playerid, YELLOW, "GUI Loaded!");
		return 1;
	}
	return 0;
}


FormatMainMenu(playerid)
{
	previewIdx[playerid] = -1;
	new
		str[256],
		title[64];

	format(title, 64, "Currently Editing IDX: %d ('IDX' is short for 'Index'!)", tmpTexIdx[playerid]);
	format(str, 256,
		"Change Model (%d)\n\
		Change Texture From List\n\
		Manually Change Texture\n\
		Text Editor\n\
		Change IDX\n\
		Material Colour\n\
		Material Opacity\n\
		Save Material\n\
		Reset Material\n\
		Reset Current IDX\n\
		Move Object", editModel[playerid]);

    ShowPlayerDialog(playerid, d_MainMenu, DIALOG_STYLE_LIST, title, str, "Accept", "Back");

}
FormatMaterialList(playerid)
{
	new
		strList[1024],
		strCaption[32],
		File:objData = fopen(DATA_FILE, io_read),
		line[128],
		idx,
		Title[32];

	// Loop through the material data file and read each line.
	// It should follow the format "NAME, MODEL ID, TXD NAME, TEXTURE NAME"
	// Separated by commas
	while(fread(objData, line))
	{
		new len;

	    sscanf(line, "p<,>s[32]ds[32]s[32]", Title, fileData[idx][MODELID], fileData[idx][TXDNAME], fileData[idx][TEXNAME]);

		// This is to remove the nextline and return characters.
		// Now works with all lines except the last one because of
		// how pastebin trims the end empty line.
		if(strfind(fileData[idx][TEXNAME], "\n")!=-1)
		{
			len = strlen(fileData[idx][TEXNAME]);
			strdel(fileData[idx][TEXNAME], len-2, len);
		}
		strcat(strList, Title);
		strcat(strList, "\n");
		idx++;
	}
	format(strCaption, 32, "%d Materials", idx);
	ShowPlayerDialog(playerid, d_MaterialList, DIALOG_STYLE_LIST, strCaption, strList, "Accept", "Back");
	fclose(objData);
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_MainMenu)
	{
	    if(response)
	    {
			if(listitem == 0)ShowPlayerDialog(playerid, d_ObjIdInput, DIALOG_STYLE_INPUT, "Change Model", "Enter an object model ID to change the current object to\n{FF0000}WARNING: You will lose all unsaved data for the current object!", "Accept", "Cancel");
			if(listitem == 1)FormatMaterialList(playerid);
			if(listitem == 2)ShowPlayerDialog(playerid, d_TexIdxInput, DIALOG_STYLE_INPUT, "Change Texture", "Enter a material index to edit", "Accept", "Cancel");
			if(listitem == 3)FormatTextMenu(playerid);
			if(listitem == 4)
			{
		        tmpTexIdx[playerid] = 0;
		        previewIdx[playerid] = 1;
		        flashTimer[playerid] = SetTimerEx("FlashObjectTexture", 1000, true, "d", playerid);
		        ToggleGUI(playerid, true);
		        UpdateGUI(playerid);
			}
			if(listitem == 5)FormatColourInput(playerid, d_MatColourInput, "Material Colour");
			if(listitem == 6)ShowPlayerDialog(playerid, d_MatOpacityInput, DIALOG_STYLE_INPUT, "Material Opacity", "Enter a Material colour opacity between 0 and 255", "Accept", "Back");
			if(listitem == 7)ShowPlayerDialog(playerid, d_SaveNameInput, DIALOG_STYLE_INPUT, "Save Material", "Type a name to tag the data in the file:", "Accept", "Back");
			if(listitem == 8)ResetObject(playerid);
			if(listitem == 9)ResetCurrentIdxToOriginal(playerid);
			if(listitem == 10)EnterObjectPosEdit(playerid);
		}
		else return 0;
	}
	if(dialogid == d_ObjIdInput)
	{
	    if(response)
	    {
			SetEditObjectModel(playerid, strval(inputtext));
	    }
	    else FormatMainMenu(playerid);
	}
	if(dialogid == d_MaterialList)
	{
	    if(response)
	    {
	        new tmpIdx = tmpTexIdx[playerid];
			tmpModelId[playerid][tmpIdx] = fileData[listitem][MODELID];
			strcpy(tmpTxdName[playerid][tmpIdx], fileData[listitem][TXDNAME]);
			strcpy(tmpTexName[playerid][tmpIdx], fileData[listitem][TEXNAME]);
	        UpdateObjectMaterial(playerid);
	    }
	    else FormatMainMenu(playerid);
	}
	if(dialogid == d_MatColourInput)
	{
	    if(response)
	    {
			new tmpIdx = tmpTexIdx[playerid];
			tmpMatColour[playerid][tmpIdx] = listitem;
			UpdateObjectMaterial(playerid);
			FormatMainMenu(playerid);
	    }
	    else FormatMainMenu(playerid);
	}
	if(dialogid == d_MatOpacityInput)
	{
		if(response)
		{
		    new opc = strval(inputtext);
			if(0 <= opc < 256)
		    {
				new tmpIdx = tmpTexIdx[playerid];
		        tmpMatOpacity[playerid][tmpIdx] = opc;
				UpdateObjectMaterial(playerid);
		        FormatMainMenu(playerid);
		    }
		    else ShowPlayerDialog(playerid, d_MatOpacityInput, DIALOG_STYLE_INPUT, "Material Opacity", "Enter a Material colour opacity {FF0000}between 0 and 255", "Accept", "Back");
		}
		else FormatTextMenu(playerid);
	}
	if(dialogid == d_SaveNameInput)
	{
	    if(response)
	    {
	        SavePlayerMaterialData(playerid, inputtext);
	        Msg(playerid, YELLOW, "Material Data Saved!");
	    }
	    else FormatMainMenu(playerid);
	}



	if(dialogid == d_TexIdxInput)
	{
	    if(response)
	    {
	        tmpTexIdx[playerid] = strval(inputtext);
			ShowPlayerDialog(playerid, d_ModelIdInput, DIALOG_STYLE_INPUT, "Change Texture", "Enter a model ID to use", "Accept", "Cancel");
	    }
	    else FormatMainMenu(playerid);
	}
	if(dialogid == d_ModelIdInput)
	{
	    if(response)
	    {
	        new tmpIdx = tmpTexIdx[playerid];
	        tmpModelId[playerid][tmpIdx] = strval(inputtext);
	        ShowPlayerDialog(playerid, d_TxdNameInput, DIALOG_STYLE_INPUT, "Change Texture", "Enter a TXD Name to use", "Accept", "Cancel");
	    }
	    else ShowPlayerDialog(playerid, d_TexIdxInput, DIALOG_STYLE_INPUT, "Change Texture", "Enter a material index to edit", "Accept", "Cancel");
	}
	if(dialogid == d_TxdNameInput)
	{
	    if(response)
	    {
	        new tmpIdx = tmpTexIdx[playerid];
	        strcpy(tmpTxdName[playerid][tmpIdx], inputtext);
	        ShowPlayerDialog(playerid, d_TexNameInput, DIALOG_STYLE_INPUT, "Change Texture", "Enter a Texture Name to use", "Accept", "Cancel");
	    }
	    else ShowPlayerDialog(playerid, d_ModelIdInput, DIALOG_STYLE_INPUT, "Change Texture", "Enter a model ID to use", "Accept", "Cancel");
	}
	if(dialogid == d_TexNameInput)
	{
	    if(response)
	    {
	        new tmpIdx = tmpTexIdx[playerid];
	        strcpy(tmpTexName[playerid][tmpIdx], inputtext);
	        UpdateObjectMaterial(playerid);
	    }
	    else ShowPlayerDialog(playerid, d_TxdNameInput, DIALOG_STYLE_INPUT, "Change Texture", "Enter a TXD Name to use", "Accept", "Cancel");
	}
	
	if(dialogid == d_TextMenu)
	{
	    if(response)
	    {
	        if(listitem == 0)ShowPlayerDialog(playerid, d_TxtInput, DIALOG_STYLE_INPUT, "Enter Text", "Enter text to be shown on the object", "Accept", "Back");
			if(listitem == 1)FormatMaterialSizeMenu(playerid);	// d_TxtMatSzInput
			if(listitem == 2)FormatFontList(playerid); 			// d_TxtFontInput
			if(listitem == 3)ShowPlayerDialog(playerid, d_TxtFontSzInput, DIALOG_STYLE_INPUT, "Font Size", "Type a font size:", "Accept", "Back");
			if(listitem == 4)
			{
			    new tmpIdx = tmpTexIdx[playerid];
			    if(tmpObjBold[playerid][tmpIdx])tmpObjBold[playerid][tmpIdx] = false;
			    else tmpObjBold[playerid][tmpIdx] = true;
				UpdateObjectMaterial(playerid, IDX_TYPE_TEXT);
				FormatTextMenu(playerid);
			}
			if(listitem == 5)FormatColourInput(playerid, d_TxtFontColInput, "Choose a font colour");
			if(listitem == 6)ShowPlayerDialog(playerid, d_TxtFontOpcInput, DIALOG_STYLE_INPUT, "Set a font opacity", "Enter a font colour opacity between 0 and 255", "Accept", "Back");
			if(listitem == 7)FormatColourInput(playerid, d_TxtBackColInput, "Choose a background colour");
			if(listitem == 8)ShowPlayerDialog(playerid, d_TxtBackOpcInput, DIALOG_STYLE_INPUT, "Set a background opacity", "Enter a background colour opacity between 0 and 255", "Accept", "Back");
			if(listitem == 9)FormatAlignmentList(playerid);		// d_TxtAllignInput
	    }
	    else FormatMainMenu(playerid);
	}
	
	if(dialogid == d_TxtInput)
	{
	    if(response)
	    {
	        new tmpIdx = tmpTexIdx[playerid];
	        strcpy(tmpObjText[playerid][tmpIdx], inputtext);
	        UpdateObjectMaterial(playerid, IDX_TYPE_TEXT);
			FormatTextMenu(playerid);
	    }
	    else FormatTextMenu(playerid);
	}

	if(dialogid == d_TxtMatSzInput)
	{
	    if(response)
	    {
	        new tmpIdx = tmpTexIdx[playerid];
	        // cell 0 will be 10 cell 1 will be 20 etc:
	        tmpObjMatSz[playerid][tmpIdx] = (listitem + 1)*10;
	        UpdateObjectMaterial(playerid, IDX_TYPE_TEXT);
			FormatTextMenu(playerid);
	    }
	    else FormatTextMenu(playerid);
	}
	if(dialogid == d_TxtFontInput)
	{
	    if(response)
	    {
	        new tmpIdx = tmpTexIdx[playerid];
	        tmpObjFont[playerid][tmpIdx] = fontTable[listitem];
	        UpdateObjectMaterial(playerid, IDX_TYPE_TEXT);
			FormatTextMenu(playerid);
	    }
	    else FormatTextMenu(playerid);
	}
	if(dialogid == d_TxtFontSzInput)
	{
	    if(response)
	    {
	        new tmpIdx = tmpTexIdx[playerid];
	        tmpObjFontSz[playerid][tmpIdx] = strval(inputtext);
	        UpdateObjectMaterial(playerid, IDX_TYPE_TEXT);
			FormatTextMenu(playerid);
	    }
	    else FormatTextMenu(playerid);
	}
	if(dialogid == d_TxtFontColInput)
	{
	    if(response)
	    {
			new tmpIdx = tmpTexIdx[playerid];
			tmpObjFontCol[playerid][tmpIdx] = listitem;
			UpdateObjectMaterial(playerid, IDX_TYPE_TEXT);
			FormatTextMenu(playerid);
	    }
	    else FormatTextMenu(playerid);
	}
	if(dialogid == d_TxtFontOpcInput)
	{
		if(response)
		{
		    new opc = strval(inputtext);
			if(0 <= opc < 256)
		    {
		        tmpObjFontOpc[playerid][tmpTexIdx[playerid]] = opc;
				UpdateObjectMaterial(playerid, IDX_TYPE_TEXT);
		        FormatTextMenu(playerid);
		    }
		    else ShowPlayerDialog(playerid, d_TxtFontOpcInput, DIALOG_STYLE_INPUT, "Set a font opacity", "Enter a font colour opacity between 0 and 255", "Accept", "Back");
		}
		else FormatTextMenu(playerid);
	}
	if(dialogid == d_TxtBackColInput)
	{
	    if(response)
	    {
	        new tmpIdx = tmpTexIdx[playerid];
			tmpObjBackCol[playerid][tmpIdx] = listitem;
			UpdateObjectMaterial(playerid, IDX_TYPE_TEXT);
			FormatTextMenu(playerid);
	    }
	    else FormatTextMenu(playerid);
	}
	if(dialogid == d_TxtBackOpcInput)
	{
		if(response)
		{
		    new opc = strval(inputtext);
		    if(0 <= opc < 256)
		    {
		        tmpObjBackOpc[playerid][tmpTexIdx[playerid]] = opc;
				UpdateObjectMaterial(playerid, IDX_TYPE_TEXT);
		        FormatTextMenu(playerid);
		    }
		    else ShowPlayerDialog(playerid, d_TxtBackOpcInput, DIALOG_STYLE_INPUT, "Set a background opacity", "Enter a background colour opacity between 0 and 255", "Accept", "Back");
		}
		else FormatTextMenu(playerid);
	}
	if(dialogid == d_TxtAlignInput)
	{
	    if(response)
	    {
	        new tmpIdx = tmpTexIdx[playerid];
	        tmpObjAlign[playerid][tmpIdx] = listitem;
	        UpdateObjectMaterial(playerid, IDX_TYPE_TEXT);
			FormatTextMenu(playerid);
	    }
	    else FormatTextMenu(playerid);
	}
	return 1;
}
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == txtLeft)
	{
	    ResetCurrentIdx(playerid);
		tmpTexIdx[playerid]--;
		if(tmpTexIdx[playerid]<0)tmpTexIdx[playerid]=0;
		UpdateGUI(playerid);
	}
	if(playertextid == txtRight)
	{
	    ResetCurrentIdx(playerid);
		tmpTexIdx[playerid]++;
		UpdateGUI(playerid);
	}
	if(playertextid == txtSave)
	{
		KillTimer(flashTimer[playerid]);
		previewIdx[playerid]=-1;
		FormatMainMenu(playerid);
		ResetCurrentIdx(playerid);
		ToggleGUI(playerid, false);
	}

	if(playertextid == txtContU)
	{
		if(camAngle[playerid][ANGLE_ELEVATION]<90.0)
		{
			camAngle[playerid][ANGLE_ELEVATION]+=10.0;
			UpdateCameraPos(playerid);
		}
	}
	if(playertextid == txtContD)
	{
		if(camAngle[playerid][ANGLE_ELEVATION]>-90.0)
		{
			camAngle[playerid][ANGLE_ELEVATION]-=10.0;
			UpdateCameraPos(playerid);
		}
	}
	if(playertextid == txtContL)
	{
		camAngle[playerid][ANGLE_ROTATION]+=45.0;
		UpdateCameraPos(playerid);
	}
	if(playertextid == txtContR)
	{
		camAngle[playerid][ANGLE_ROTATION]-=45.0;
		UpdateCameraPos(playerid);
	}
}

EnterEditMode(playerid)
{
	GetPlayerPos(playerid, objPos[0][playerid], objPos[1][playerid], objPos[2][playerid]);
	GetPlayerFacingAngle(playerid, camAngle[playerid][ANGLE_ROTATION]);
	GetXYFromAngle(objPos[0][playerid], objPos[1][playerid], camAngle[playerid][ANGLE_ROTATION], 5.0);

	TogglePlayerControllable(playerid, false);
	inEditMode[playerid]=true;
	camAngle[playerid][ANGLE_ROTATION] = 0.0;
	camAngle[playerid][ANGLE_ELEVATION] = 45.0;
	camDist[playerid] = 5.0;
	previewIdx[playerid] = -1;
	editModel[playerid] = 1337;

	editObj[playerid] = CreatePlayerObject(playerid, 1337, objPos[0][playerid], objPos[1][playerid], objPos[2][playerid], 0.0, 0.0, 0.0);
	
	ResetEditVariables(playerid);
	
	GetPlayerCameraPos(playerid, oldCam[playerid][0], oldCam[playerid][1], oldCam[playerid][2]);
	UpdateCameraPos(playerid);
	
	editTimer[playerid] = SetTimerEx("editorUpdate", 100, true, "d", playerid);

}
ExitEditMode(playerid)
{
	KillTimer(editTimer[playerid]);
	TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
}
UpdateCameraPos(playerid)
{
	new
	    Float:tmpX = oldCam[playerid][0],
	    Float:tmpY = oldCam[playerid][1],
	    Float:tmpZ = oldCam[playerid][2],

	    Float:prjX,
	    Float:prjY,
	    Float:prjZ;

	if(camAngle[playerid][ANGLE_ROTATION]<0.0)camAngle[playerid][ANGLE_ROTATION]=360+camAngle[playerid][ANGLE_ROTATION];
	if(camAngle[playerid][ANGLE_ROTATION]>360.0)camAngle[playerid][ANGLE_ROTATION]=-360.0;

    prjX = objPos[0][playerid];
    prjY = objPos[1][playerid];
    prjZ = objPos[2][playerid];

	GetXYZFromAngle(prjX, prjY, prjZ, camAngle[playerid][ANGLE_ROTATION], camAngle[playerid][ANGLE_ELEVATION], camDist[playerid]);

	InterpolateCameraPos(playerid, tmpX, tmpY, tmpZ, prjX, prjY, prjZ, 100, CAMERA_MOVE);
	InterpolateCameraLookAt(playerid, objPos[0][playerid], objPos[1][playerid], objPos[2][playerid], objPos[0][playerid], objPos[1][playerid], objPos[2][playerid], 1000);

	oldCam[playerid][0] = prjX;
	oldCam[playerid][1] = prjY;
	oldCam[playerid][2] = prjZ;
}
public editorUpdate(playerid)
{
	if(inEditMode[playerid])
	{
		new k, ud, lr;
		GetPlayerKeys(playerid, k, ud, lr);
		if(ud == KEY_UP)
		{
			if(camAngle[playerid][ANGLE_ELEVATION]<90.0)
			{
				camAngle[playerid][ANGLE_ELEVATION]+=10.0;
				UpdateCameraPos(playerid);
			}
		}
		if(ud == KEY_DOWN)
		{
			if(camAngle[playerid][ANGLE_ELEVATION]>-90.0)
			{
				camAngle[playerid][ANGLE_ELEVATION]-=10.0;
				UpdateCameraPos(playerid);
			}
		}
		if(lr == KEY_LEFT)
		{
			camAngle[playerid][ANGLE_ROTATION]+=45.0;
			UpdateCameraPos(playerid);
		}
		if(lr == KEY_RIGHT)
		{
			camAngle[playerid][ANGLE_ROTATION]-=45.0;
			UpdateCameraPos(playerid);
		}
		
		if(k == KEY_SPRINT)
		{
		    camDist[playerid]+=1.0;
		    UpdateCameraPos(playerid);
		}
		if(k == KEY_CROUCH)
		{
		    camDist[playerid]-=1.0;
		    UpdateCameraPos(playerid);
		}
		
		if(k == 16)FormatMainMenu(playerid);
	}
	return 1;
}


ToggleGUI(playerid, toggle)
{
	if(toggle)
	{
		PlayerTextDrawShow(playerid, txtLeft);
		PlayerTextDrawShow(playerid, txtData);
		PlayerTextDrawShow(playerid, txtRight);
		PlayerTextDrawShow(playerid, txtSave);
		PlayerTextDrawShow(playerid, txtContU);
		PlayerTextDrawShow(playerid, txtContD);
		PlayerTextDrawShow(playerid, txtContL);
		PlayerTextDrawShow(playerid, txtContR);
		SelectTextDraw(playerid, 0x00000055);
	}
	else
	{
		PlayerTextDrawHide(playerid, txtLeft);
		PlayerTextDrawHide(playerid, txtData);
		PlayerTextDrawHide(playerid, txtRight);
		PlayerTextDrawHide(playerid, txtSave);
		PlayerTextDrawHide(playerid, txtContU);
		PlayerTextDrawHide(playerid, txtContD);
		PlayerTextDrawHide(playerid, txtContL);
		PlayerTextDrawHide(playerid, txtContR);
		CancelSelectTextDraw(playerid);
	}
}
UpdateGUI(playerid)
{
	new str[3];
	format(str, 3, "%d", tmpTexIdx[playerid]);
	PlayerTextDrawSetString(playerid, txtData, str);
}


public FlashObjectTexture(playerid)
{
	new tex[8] = {"white"};
	if(previewIdx[playerid]==1)
	{
	    tex = "red";
    	previewIdx[playerid] = 0;
    }
	else previewIdx[playerid] = 1;

	SetPlayerObjectMaterial(playerid, editObj[playerid], tmpTexIdx[playerid], 18646, "matcolours", tex);
}
ResetCurrentIdx(playerid)
{
	new tmpIdx = tmpTexIdx[playerid];
	if(tmpIdxType[playerid][tmpIdx] != IDX_TYPE_UNUSED)UpdateObjectMaterial(playerid, tmpIdxType[playerid][tmpIdx]);
	else ResetCurrentIdxToOriginal(playerid);
}
ResetCurrentIdxToOriginal(playerid)
{
	new tmpIdx = tmpTexIdx[playerid];
	SetPlayerObjectMaterial(playerid, editObj[playerid], tmpTexIdx[playerid], 19341, "invalid", "invalid");
	tmpIdxType[playerid][tmpIdx] = IDX_TYPE_UNUSED;
}
ResetObject(playerid)
{
	new
	    Float:objX,
	    Float:objY,
	    Float:objZ;

	GetPlayerObjectPos(playerid, editObj[playerid], objX, objY, objZ);
	DestroyPlayerObject(playerid, editObj[playerid]);
	editObj[playerid] = CreatePlayerObject(playerid, editModel[playerid], objX, objY, objZ, 0.0, 0.0, 0.0);
	for(new i;i<MAX_INDEX;i++)tmpIdxType[playerid][i] = IDX_TYPE_UNUSED;
}
SetEditObjectModel(playerid, modelid)
{
	new
	    Float:objX,
	    Float:objY,
	    Float:objZ;
	GetPlayerObjectPos(playerid, editObj[playerid], objX, objY, objZ);
	DestroyPlayerObject(playerid, editObj[playerid]);
	editObj[playerid] = CreatePlayerObject(playerid, modelid, objX, objY, objZ, 0.0, 0.0, 0.0);
	ResetEditVariables(playerid);
	editModel[playerid] = modelid;
}
UpdateObjectMaterial(playerid, type=IDX_TYPE_MATERIAL)
{
	new tmpIdx = tmpTexIdx[playerid];
	if(!type)
	{
		new
			tmpA, tmpR, tmpG, tmpB,
			tmpMatCol;

		HexToARGB(colourTable[tmpMatColour[playerid][tmpIdx]][COLOUR_VALUE], tmpA, tmpR, tmpG, tmpB);
		tmpMatCol = ARGBToHex(tmpMatOpacity[playerid][tmpIdx], tmpR, tmpG, tmpB);

		SetPlayerObjectMaterial(playerid, editObj[playerid], tmpIdx, tmpModelId[playerid][tmpIdx], tmpTxdName[playerid][tmpIdx], tmpTexName[playerid][tmpIdx], tmpMatCol);
	}
	else
	{
	    new
	        tmpText[MAX_OBJECT_TEXT], // Temp var so the global isn't changed
	        tmpA, tmpR, tmpG, tmpB,
			tmpFontCol,
	    	tmpBackCol,

			len = strlen(tmpObjText[playerid][tmpIdx]);

		HexToARGB(colourTable[tmpObjFontCol[playerid][tmpIdx]][COLOUR_VALUE], tmpA, tmpR, tmpG, tmpB);
		tmpFontCol = ARGBToHex(tmpObjFontOpc[playerid][tmpIdx], tmpR, tmpG, tmpB);

		HexToARGB(colourTable[tmpObjBackCol[playerid][tmpIdx]][COLOUR_VALUE], tmpA, tmpR, tmpG, tmpB);
		tmpBackCol = ARGBToHex(tmpObjBackOpc[playerid][tmpIdx], tmpR, tmpG, tmpB);

		tmpText = tmpObjText[playerid][tmpIdx];

		for(new c;c<len;c++)
		{ // The end bit on this statement prevents invalid memory access, for instance if this loop reaches the last cell and tries to access c+1
		    if(tmpText[c] == 92 /*92 is the \, pawno didn't let me put the literal*/ && c != len-1)
			{
			    if(tmpText[c+1] == 'n')
			    {
					strdel(tmpText, c, c+1);
					tmpText[c] = '\n';
			    }
			    // I will add more if needed, like the \t or any others that people suggest!
		    }
		}

	    SetPlayerObjectMaterialText(
			playerid,
			editObj[playerid],
			tmpText,
			tmpIdx,
			tmpObjMatSz[playerid][tmpIdx],
			tmpObjFont[playerid][tmpIdx],
			tmpObjFontSz[playerid][tmpIdx],
			tmpObjBold[playerid][tmpIdx],
			tmpFontCol,
			tmpBackCol,
			tmpObjAlign[playerid][tmpIdx] );
	}

	tmpIdxType[playerid][tmpIdx] = type;
}
ResetEditVariables(playerid)
{
	tmpTexIdx		[playerid] = 0;
	for(new i;i<MAX_INDEX;i++)
	{
		tmpModelId[playerid][i]		= 0;
		tmpTxdName[playerid][i][0]	= EOS;
		tmpTexName[playerid][i][0]	= EOS;
		tmpMatColour[playerid][i]	= 0;
		tmpIdxType[playerid][i]		= IDX_TYPE_UNUSED;

		tmpObjText[playerid][i]		= "_";
		tmpObjMatSz[playerid][i]	= OBJECT_MATERIAL_SIZE_256x128;
		tmpObjFont[playerid][i]		= "Arial";
		tmpObjFontSz[playerid][i]	= 24;
		tmpObjBold[playerid][i]		= 1;
		tmpObjFontCol[playerid][i]	= 0;
		tmpObjFontOpc[playerid][i]	= 255;
		tmpObjBackCol[playerid][i]	= 0;
		tmpObjBackOpc[playerid][i]	= 255;
		tmpObjAlign[playerid][i]	= 0;
	}
}


FormatTextMenu(playerid)
{
	new
		list[256],
		tmpText[MAX_OBJECT_TEXT],
		len,
		tmpIdx = tmpTexIdx[playerid];

	tmpText = tmpObjText[playerid][tmpIdx];
	len = strlen(tmpObjText[playerid][tmpIdx]);

	for(new c;c<len;c++)
	{
	    if(tmpText[c] == 92 && c != len-1)
		{
		    if(tmpText[c+1] == 'n')
		    {
				strdel(tmpText, c, c+1);
				tmpText[c] = '-';
		    }
	    }
	}

	format(list, 256, "Text ('%s')\nMaterial Size (%s)\nFont (%s)\nFont Size (%d)\nSet Bold (%d)\nFont Colour (%s)\nFont Opacity (%d)\nBackground Colour (%s)\nBackground Opacity (%d)\nAllignment (%s)",
		tmpObjText[playerid][tmpIdx],
		matSizeTable[ (tmpObjMatSz[playerid][tmpIdx]/10) - 1 ],
		tmpObjFont[playerid][tmpIdx],
		tmpObjFontSz[playerid][tmpIdx],
		tmpObjBold[playerid][tmpIdx],
		colourTable[tmpObjFontCol[playerid][tmpIdx]][COLOUR_NAME],
		tmpObjFontOpc[playerid][tmpIdx],
		colourTable[tmpObjBackCol[playerid][tmpIdx]][COLOUR_NAME],
		tmpObjBackOpc[playerid][tmpIdx],
		textAlignmentTable[tmpObjAlign[playerid][tmpIdx]]);

	ShowPlayerDialog(playerid, d_TextMenu, DIALOG_STYLE_LIST, "Edit Text", list, "Accept", "Back");
}

FormatMaterialSizeMenu(playerid)
{
	new
		list[ MAX_MATERIAL_SIZE * (MAX_MATERIAL_LEN+1) ], // Amount of list items X max length of a list item + 1 for the \n character
		tmpStr[MAX_MATERIAL_LEN+1],
		iLoop;

	while(iLoop < MAX_MATERIAL_SIZE)
	{
	    format(tmpStr, MAX_MATERIAL_LEN+1, "%s\n", matSizeTable[iLoop]);
	    strcat(list, tmpStr);
	    iLoop++;
	}
	ShowPlayerDialog(playerid, d_TxtMatSzInput, DIALOG_STYLE_LIST, "Choose a material size template:", list, "Accept", "Back");
}
FormatFontList(playerid)
{
	new
		list[ MAX_FONT_TYPE * (MAX_FONT_LEN+1) ],
		tmpStr[MAX_FONT_LEN+1],
		iLoop;

	while(iLoop < MAX_FONT_TYPE)
	{
	    format(tmpStr, MAX_FONT_LEN+1, "%s\n", fontTable[iLoop]);
	    strcat(list, tmpStr);
	    iLoop++;
	}
	ShowPlayerDialog(playerid, d_TxtFontInput, DIALOG_STYLE_LIST, "Choose a text font to use:", list, "Accept", "Back");
}
FormatColourInput(playerid, dialogid, caption[])
{
	new
		list[ MAX_COLOUR * (MAX_COLOUR_NAME+1) ],
		tmpStr[MAX_COLOUR_NAME+1],
		iLoop;

	while(iLoop < MAX_COLOUR)
	{
	    format(tmpStr, MAX_COLOUR_NAME+1, "%s\n", colourTable[iLoop][COLOUR_NAME]);
	    strcat(list, tmpStr);
	    iLoop++;
	}
	ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, caption, list, "Accept", "Back");
}
FormatAlignmentList(playerid)
{
	new
		list[ MAX_ALIGNMENT_TYPE * (MAX_ALIGNMENT_LEN+1) ],
		tmpStr[MAX_ALIGNMENT_LEN+1],
		iLoop;

	while(iLoop < MAX_ALIGNMENT_TYPE)
	{
	    format(tmpStr, MAX_ALIGNMENT_LEN+1, "%s\n", textAlignmentTable[iLoop]);
	    strcat(list, tmpStr);
	    iLoop++;
	}
	ShowPlayerDialog(playerid, d_TxtAlignInput, DIALOG_STYLE_LIST, "Choose a text alignment type:", list, "Accept", "Back");
}



SavePlayerMaterialData(playerid, tag[])
{
	new
		strSave[256],
		iLoop,
		File:outputFile = fopen(OUTPUT_FILE, io_append);

	format(strSave, 128, "[%s]\r\n", tag);
	fwrite(outputFile, strSave);

	while(iLoop<MAX_INDEX)
	{
	    if(tmpIdxType[playerid][iLoop] == IDX_TYPE_MATERIAL)
	    {
			new
				tmpA, tmpR, tmpG, tmpB,
				tmpMatCol;

			HexToARGB(colourTable[tmpMatColour[playerid][iLoop]][COLOUR_VALUE], tmpA, tmpR, tmpG, tmpB);
			tmpMatCol = ARGBToHex(tmpMatOpacity[playerid][iLoop], tmpR, tmpG, tmpB);

			format(strSave, 256, "SetObjectMaterial(objectid, %d, %d, \"%s\", \"%s\", %d);\r\n",
				iLoop,
				tmpModelId[playerid][iLoop],
				tmpTxdName[playerid][iLoop],
				tmpTexName[playerid][iLoop],
				tmpMatCol);

			fwrite(outputFile, strSave);
		}
	    if(tmpIdxType[playerid][iLoop] == IDX_TYPE_TEXT)
	    {
	        new
		        tmpA, tmpR, tmpG, tmpB,
				tmpFontCol,
		    	tmpBackCol;

			HexToARGB(colourTable[tmpObjFontCol[playerid][iLoop]][COLOUR_VALUE], tmpA, tmpR, tmpG, tmpB);
			tmpFontCol = ARGBToHex(tmpObjFontOpc[playerid][iLoop], tmpR, tmpG, tmpB);

			HexToARGB(colourTable[tmpObjBackCol[playerid][iLoop]][COLOUR_VALUE], tmpA, tmpR, tmpG, tmpB);
			tmpBackCol = ARGBToHex(tmpObjBackOpc[playerid][iLoop], tmpR, tmpG, tmpB);

			format(strSave, 256, "SetObjectMaterialText(objectid, \"%s\", %d, OBJECT_MATERIAL_SIZE_%s, \"%s\", %d, %d, %d, %d, %d);\r\n",
				tmpObjText[playerid][iLoop],
				iLoop,
				matSizeTable[ (tmpObjMatSz[playerid][iLoop]/10) - 1 ],
				tmpObjFont[playerid][iLoop],
				tmpObjFontSz[playerid][iLoop],
				tmpObjBold[playerid][iLoop],
				tmpFontCol,
				tmpBackCol,
				tmpObjAlign[playerid][iLoop]);

			fwrite(outputFile, strSave);
	    }
		iLoop++;
	}
	fwrite(outputFile, "\r\n\r\n"); // Just to separate things up a bit in case you save quite a few times!
	fclose(outputFile);
}


new
    bool:inMoveMode[MAX_PLAYERS];

EnterObjectPosEdit(playerid)
{
    inMoveMode[playerid] = true;
    inEditMode[playerid] = false;
}
ExitObjectPosEdit(playerid)
{
    inMoveMode[playerid] = false;
    inEditMode[playerid] = true;
}

public OnPlayerUpdate(playerid)
{
	if(!inMoveMode[playerid])return 1;

	new
		k, ud, lr,
		Float:x,
		Float:y,
		Float:z,
		Float:speed = 0.5;

	GetPlayerKeys(playerid, k, ud, lr);
	GetObjectPos(editObj[playerid], x, y, z);

	if(k == KEY_JUMP)speed = 1.0;
	if(k == 16)ExitObjectPosEdit(playerid);

	if(ud == KEY_UP)
	{
	    MoveObject(editObj[playerid], x, y+100.0, z, speed);
	}
	else if(ud == KEY_DOWN)
	{
	    MoveObject(editObj[playerid], x, y-100.0, z, speed);
	}
	else StopObject(editObj[playerid]);

	if(lr == KEY_RIGHT)
	{
	    MoveObject(editObj[playerid], x+100.0, y, z, speed);
	}
	else if(lr == KEY_LEFT)
	{
	    MoveObject(editObj[playerid], x-100.0, y, z, speed);
	}
	else StopObject(editObj[playerid]);

	return 1;
}







LoadTextDrawsForPlayer(playerid)
{
	txtLeft = CreatePlayerTextDraw	(playerid, 260.000000, 340.000000, "<");
	PlayerTextDrawTextSize			(playerid, txtLeft, 300.000000, 40.000000);
	PlayerTextDrawLetterSize		(playerid, txtLeft, 1.400000, 4.000000);
	PlayerTextDrawBackgroundColor	(playerid, txtLeft, 255);
	PlayerTextDrawFont				(playerid, txtLeft, 1);
	PlayerTextDrawColor				(playerid, txtLeft, -1);
	PlayerTextDrawSetOutline		(playerid, txtLeft, 0);
	PlayerTextDrawSetProportional	(playerid, txtLeft, 1);
	PlayerTextDrawSetShadow			(playerid, txtLeft, 1);
	PlayerTextDrawUseBox			(playerid, txtLeft, 1);
	PlayerTextDrawBoxColor			(playerid, txtLeft, 100);
	PlayerTextDrawSetSelectable		(playerid, txtLeft, true);

	txtData = CreatePlayerTextDraw	(playerid, 300.000000, 340.000000, "00");
	PlayerTextDrawTextSize			(playerid, txtData, 340.000000, 40.000000);
	PlayerTextDrawLetterSize		(playerid, txtData, 0.899999, 4.000000);
	PlayerTextDrawBackgroundColor	(playerid, txtData, 255);
	PlayerTextDrawFont				(playerid, txtData, 1);
	PlayerTextDrawColor				(playerid, txtData, -1);
	PlayerTextDrawSetOutline		(playerid, txtData, 0);
	PlayerTextDrawSetProportional	(playerid, txtData, 1);
	PlayerTextDrawSetShadow			(playerid, txtData, 1);
	PlayerTextDrawUseBox			(playerid, txtData, 1);
	PlayerTextDrawBoxColor			(playerid, txtData, 100);
	PlayerTextDrawSetSelectable		(playerid, txtData, false);

	txtRight = CreatePlayerTextDraw	(playerid, 340.000000, 340.000000, ">");
	PlayerTextDrawTextSize			(playerid, txtRight, 380.000000, 40.000000);
	PlayerTextDrawLetterSize		(playerid, txtRight, 1.400000, 4.000000);
	PlayerTextDrawBackgroundColor	(playerid, txtRight, 255);
	PlayerTextDrawFont				(playerid, txtRight, 1);
	PlayerTextDrawColor				(playerid, txtRight, -1);
	PlayerTextDrawSetOutline		(playerid, txtRight, 0);
	PlayerTextDrawSetProportional	(playerid, txtRight, 1);
	PlayerTextDrawSetShadow			(playerid, txtRight, 1);
	PlayerTextDrawUseBox			(playerid, txtRight, 1);
	PlayerTextDrawBoxColor			(playerid, txtRight, 100);
	PlayerTextDrawSetSelectable		(playerid, txtRight, true);


	txtSave = CreatePlayerTextDraw	(playerid, 300.000000, 390.000000, "_");
	PlayerTextDrawTextSize			(playerid, txtSave, 340.000000, 60.000000);
	PlayerTextDrawLetterSize		(playerid, txtSave, 1.400000, 2.000000);
	PlayerTextDrawBackgroundColor	(playerid, txtSave, 255);
	PlayerTextDrawFont				(playerid, txtSave, 1);
	PlayerTextDrawColor				(playerid, txtSave, -1);
	PlayerTextDrawSetOutline		(playerid, txtSave, 0);
	PlayerTextDrawSetProportional	(playerid, txtSave, 1);
	PlayerTextDrawSetShadow			(playerid, txtSave, 1);
	PlayerTextDrawUseBox			(playerid, txtSave, 1);
	PlayerTextDrawBoxColor			(playerid, txtSave, 0x55FF1155);
	PlayerTextDrawSetSelectable		(playerid, txtSave, true);


	txtContU = CreatePlayerTextDraw	(playerid, 300.000000, 10.000000, "~u~");
	PlayerTextDrawTextSize			(playerid, txtContU, 340.000000, 40.000000);
	PlayerTextDrawBackgroundColor	(playerid, txtContU, 255);
	PlayerTextDrawFont				(playerid, txtContU, 1);
	PlayerTextDrawLetterSize		(playerid, txtContU, 0.6, 5.7);
	PlayerTextDrawColor				(playerid, txtContU, -1);
	PlayerTextDrawSetOutline		(playerid, txtContU, 0);
	PlayerTextDrawSetProportional	(playerid, txtContU, 1);
	PlayerTextDrawSetShadow			(playerid, txtContU, 1);
	PlayerTextDrawUseBox			(playerid, txtContU, 1);
	PlayerTextDrawBoxColor			(playerid, txtContU, 100);
	PlayerTextDrawSetSelectable		(playerid, txtContU, true);

	txtContD = CreatePlayerTextDraw	(playerid, 300.000000, 280.000000, "~d~");
	PlayerTextDrawTextSize			(playerid, txtContD, 340.000000, 60.000000);
	PlayerTextDrawBackgroundColor	(playerid, txtContD, 255);
	PlayerTextDrawFont				(playerid, txtContD, 1);
	PlayerTextDrawLetterSize		(playerid, txtContD, 0.6, 5.7);
	PlayerTextDrawColor				(playerid, txtContD, -1);
	PlayerTextDrawSetOutline		(playerid, txtContD, 0);
	PlayerTextDrawSetProportional	(playerid, txtContD, 1);
	PlayerTextDrawSetShadow			(playerid, txtContD, 1);
	PlayerTextDrawUseBox			(playerid, txtContD, 1);
	PlayerTextDrawBoxColor			(playerid, txtContD, 100);
	PlayerTextDrawSetSelectable		(playerid, txtContD, true);

	txtContL = CreatePlayerTextDraw	(playerid, 40.000000, 200.000000, "~<~");
	PlayerTextDrawTextSize			(playerid, txtContL, 80.000000, 60.000000);
	PlayerTextDrawBackgroundColor	(playerid, txtContL, 255);
	PlayerTextDrawFont				(playerid, txtContL, 1);
	PlayerTextDrawLetterSize		(playerid, txtContL, 0.6, 5.7);
	PlayerTextDrawColor				(playerid, txtContL, -1);
	PlayerTextDrawSetOutline		(playerid, txtContL, 0);
	PlayerTextDrawSetProportional	(playerid, txtContL, 1);
	PlayerTextDrawSetShadow			(playerid, txtContL, 1);
	PlayerTextDrawUseBox			(playerid, txtContL, 1);
	PlayerTextDrawBoxColor			(playerid, txtContL, 100);
	PlayerTextDrawSetSelectable		(playerid, txtContL, true);

	txtContR = CreatePlayerTextDraw	(playerid, 560.000000, 200.000000, "~>~");
	PlayerTextDrawTextSize			(playerid, txtContR, 600.000000, 60.000000);
	PlayerTextDrawBackgroundColor	(playerid, txtContR, 255);
	PlayerTextDrawFont				(playerid, txtContR, 1);
	PlayerTextDrawLetterSize		(playerid, txtContR, 0.6, 5.7);
	PlayerTextDrawColor				(playerid, txtContR, -1);
	PlayerTextDrawSetOutline		(playerid, txtContR, 0);
	PlayerTextDrawSetProportional	(playerid, txtContR, 1);
	PlayerTextDrawSetShadow			(playerid, txtContR, 1);
	PlayerTextDrawUseBox			(playerid, txtContR, 1);
	PlayerTextDrawBoxColor			(playerid, txtContR, 100);
	PlayerTextDrawSetSelectable		(playerid, txtContR, true);
}



// Utilities

ARGBToHex(a, r, g, b)
{
    return (a<<24 | r<<16 | g<<8 | b);
}

HexToARGB(colour, &a, &r, &g, &b)
{
    a = (colour >> 24) & 0xFF;
    r = (colour >> 16) & 0xFF;
    g = (colour >> 8) & 0xFF;
    b = colour & 0xFF;
}

GetXYFromAngle(&Float:x, &Float:y, Float:a, Float:distance)
	x+=(distance*floatsin(-a,degrees)),y+=(distance*floatcos(-a,degrees));

GetXYZFromAngle(&Float:x, &Float:y, &Float:z, Float:angle, Float:elevation, Float:distance)
    x += ( distance*floatsin(angle,degrees)*floatcos(elevation,degrees) ),y += ( distance*floatcos(angle,degrees)*floatcos(elevation,degrees) ),z += ( distance*floatsin(elevation,degrees) );


