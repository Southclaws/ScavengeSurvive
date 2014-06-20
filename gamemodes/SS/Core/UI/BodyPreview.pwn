#include <YSI\y_hooks>


#define MAX_BODY_LABEL (16)


enum E_BODY_LABEL_DATA
{
bool:		bl_valid,
PlayerText:	bl_textdraw,
Float:		bl_posY
}


static
Float:		bod_UIWidth		[MAX_PLAYERS] = {120.0, ...},
Float:		bod_UIPositionX	[MAX_PLAYERS] = {100.0, ...},
Float:		bod_UIPositionY	[MAX_PLAYERS] = {120.0, ...},
Float:		bod_UIFontSizeX	[MAX_PLAYERS] = {0.2, ...},
Float:		bod_UIFontSizeY	[MAX_PLAYERS] = {1.0, ...},
PlayerText:	bod_Header		[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	bod_Background	[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	bod_BodyPreview	[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},

			bod_LabelData0	[MAX_PLAYERS][MAX_BODY_LABEL][E_BODY_LABEL_DATA],
			bod_LabelData1	[MAX_PLAYERS][MAX_BODY_LABEL][E_BODY_LABEL_DATA],
			bod_LabelIndex0	[MAX_PLAYERS],
			bod_LabelIndex1	[MAX_PLAYERS];


static HANDLER;


hook OnGameModeInit()
{
	HANDLER = debug_register_handler("bodypreview");
}

hook OnPlayerConnect(playerid)
{
	bod_LabelIndex0[playerid] = 0;
	bod_LabelIndex1[playerid] = 0;

	for(new i; i < MAX_BODY_LABEL; i++)
	{
		bod_LabelData0[playerid][i][bl_valid] = false;
		bod_LabelData1[playerid][i][bl_valid] = false;
		bod_LabelData0[playerid][i][bl_textdraw] = PlayerText:INVALID_TEXT_DRAW;
		bod_LabelData1[playerid][i][bl_textdraw] = PlayerText:INVALID_TEXT_DRAW;
	}

	CreateBodyPreviewUI(playerid);
}


CreateBodyPreviewUI(playerid)
{
	bod_Header[playerid]			=CreatePlayerTextDraw(playerid, bod_UIPositionX[playerid], bod_UIPositionY[playerid], "Health status and wounds");
	PlayerTextDrawAlignment			(playerid, bod_Header[playerid], 2);
	PlayerTextDrawFont				(playerid, bod_Header[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, bod_Header[playerid], 0.2, 1.0);
	PlayerTextDrawColor				(playerid, bod_Header[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, bod_Header[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, bod_Header[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, bod_Header[playerid], 1);
	PlayerTextDrawUseBox			(playerid, bod_Header[playerid], 1);
	PlayerTextDrawTextSize			(playerid, bod_Header[playerid], 0.0, bod_UIWidth[playerid]);

	bod_Background[playerid]		=CreatePlayerTextDraw(playerid, bod_UIPositionX[playerid], bod_UIPositionY[playerid], "~n~");
	PlayerTextDrawAlignment			(playerid, bod_Background[playerid], 2);
	PlayerTextDrawFont				(playerid, bod_Background[playerid], 1);

	PlayerTextDrawLetterSize		(playerid, bod_Background[playerid], 0.50, 23.6);
	PlayerTextDrawColor				(playerid, bod_Background[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, bod_Background[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, bod_Background[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, bod_Background[playerid], 1);
	PlayerTextDrawUseBox			(playerid, bod_Background[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, bod_Background[playerid], 128);
	PlayerTextDrawTextSize			(playerid, bod_Background[playerid], 0.0, bod_UIWidth[playerid]);

	bod_BodyPreview[playerid]		=CreatePlayerTextDraw(playerid, bod_UIPositionX[playerid] - (bod_UIWidth[playerid] * 0.666666667), bod_UIPositionY[playerid] + 10.0, "~n~");
	PlayerTextDrawAlignment			(playerid, bod_BodyPreview[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, bod_BodyPreview[playerid], 0x0);
	PlayerTextDrawFont				(playerid, bod_BodyPreview[playerid], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize		(playerid, bod_BodyPreview[playerid], 0.50, 27.0);
	PlayerTextDrawUseBox			(playerid, bod_BodyPreview[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, bod_BodyPreview[playerid], 0x0);
	PlayerTextDrawTextSize			(playerid, bod_BodyPreview[playerid], bod_UIWidth[playerid] * 1.333333333, 210.0);
	PlayerTextDrawSetPreviewModel	(playerid, bod_BodyPreview[playerid], 60);
	PlayerTextDrawSetPreviewRot		(playerid, bod_BodyPreview[playerid], 0.0, 0.0, 0.0, 1.0);
}

stock ShowBodyPreviewUI(playerid)
{
	d:1:HANDLER("[ShowBodyPreviewUI]");
	PlayerTextDrawShow(playerid, bod_Header[playerid]);
	PlayerTextDrawShow(playerid, bod_Background[playerid]);
	PlayerTextDrawShow(playerid, bod_BodyPreview[playerid]);
}

stock HideBodyPreviewUI(playerid)
{
	d:1:HANDLER("[HideBodyPreviewUI]");
	PlayerTextDrawHide(playerid, bod_Header[playerid]);
	PlayerTextDrawHide(playerid, bod_Background[playerid]);
	PlayerTextDrawHide(playerid, bod_BodyPreview[playerid]);

	d:2:HANDLER("[HideBodyPreviewUI] LabelIndex0 %d LabelIndex1 %d", bod_LabelIndex0[playerid], bod_LabelIndex1[playerid]);
	for(new i; i <= bod_LabelIndex0[playerid]; i++)
	{
		PlayerTextDrawDestroy(playerid, bod_LabelData0[playerid][i][bl_textdraw]);
		bod_LabelData0[playerid][i][bl_valid] = false;
		bod_LabelData0[playerid][i][bl_textdraw] = PlayerText:INVALID_TEXT_DRAW;
	}

	for(new i; i <= bod_LabelIndex1[playerid]; i++)
	{
		PlayerTextDrawDestroy(playerid, bod_LabelData1[playerid][i][bl_textdraw]);
		bod_LabelData1[playerid][i][bl_valid] = false;
		bod_LabelData1[playerid][i][bl_textdraw] = PlayerText:INVALID_TEXT_DRAW;
	}

	bod_LabelIndex0[playerid] = 0;
	bod_LabelIndex1[playerid] = 0;
}

stock SetBodyPreviewLabel(playerid, side, index, Float:spacing, string[], textcolour)
{
	d:1:HANDLER("[SetBodyPreviewLabel] side:%d index:%d spacing:%.2f string:'%s' col:%x", side, index, spacing, string, textcolour);

	new Float:ypos;

	// left
	if(!side)
	{
		if(bod_LabelData0[playerid][index][bl_valid])
		{
			d:2:HANDLER("[SetBodyPreviewLabel] Updating left side index: %d", index);

			PlayerTextDrawSetString(playerid, bod_LabelData0[playerid][index][bl_textdraw], string);
			PlayerTextDrawColor(playerid, bod_LabelData0[playerid][index][bl_textdraw], textcolour);
			PlayerTextDrawShow(playerid, bod_LabelData0[playerid][index][bl_textdraw]);
		}
		else
		{
			d:2:HANDLER("[SetBodyPreviewLabel] Adding to left side index: %d", index);

			bod_LabelData0[playerid][index][bl_valid] = true;

			if(index > bod_LabelIndex0[playerid])
				bod_LabelIndex0[playerid] = index;

			if(index == 0)
				ypos = bod_UIPositionY[playerid] + spacing;

			else
				ypos = bod_LabelData0[playerid][index - 1][bl_posY] + spacing;

			bod_LabelData0[playerid][index][bl_posY] = ypos;

			bod_LabelData0[playerid][index][bl_textdraw]=CreatePlayerTextDraw(playerid, bod_UIPositionX[playerid] - 55.0, ypos, string);
			PlayerTextDrawAlignment			(playerid, bod_LabelData0[playerid][index][bl_textdraw], 1);
			PlayerTextDrawBackgroundColor	(playerid, bod_LabelData0[playerid][index][bl_textdraw], 255);
			PlayerTextDrawFont				(playerid, bod_LabelData0[playerid][index][bl_textdraw], 1);
			PlayerTextDrawLetterSize		(playerid, bod_LabelData0[playerid][index][bl_textdraw], bod_UIFontSizeX[playerid], bod_UIFontSizeY[playerid]);
			PlayerTextDrawColor				(playerid, bod_LabelData0[playerid][index][bl_textdraw], textcolour);
			PlayerTextDrawSetOutline		(playerid, bod_LabelData0[playerid][index][bl_textdraw], 0);
			PlayerTextDrawSetProportional	(playerid, bod_LabelData0[playerid][index][bl_textdraw], 1);
			PlayerTextDrawSetShadow			(playerid, bod_LabelData0[playerid][index][bl_textdraw], 0);
			PlayerTextDrawTextSize			(playerid, bod_LabelData0[playerid][index][bl_textdraw], bod_UIPositionX[playerid], 10.0);
			PlayerTextDrawSetSelectable		(playerid, bod_LabelData0[playerid][index][bl_textdraw], true);

			PlayerTextDrawShow(playerid, bod_LabelData0[playerid][index][bl_textdraw]);
		}
	}
	// Right
	else
	{
		if(bod_LabelData1[playerid][index][bl_valid])
		{
			d:2:HANDLER("[SetBodyPreviewLabel] Updating right side index: %d", index);

			PlayerTextDrawSetString(playerid, bod_LabelData1[playerid][index][bl_textdraw], string);
			PlayerTextDrawColor(playerid, bod_LabelData1[playerid][index][bl_textdraw], textcolour);
			PlayerTextDrawShow(playerid, bod_LabelData1[playerid][index][bl_textdraw]);
		}
		else
		{
			d:2:HANDLER("[SetBodyPreviewLabel] Adding to right side index: %d", index);

			bod_LabelData1[playerid][index][bl_valid] = true;

			if(index > bod_LabelIndex1[playerid])
				bod_LabelIndex1[playerid] = index;

			if(index == 0)
				ypos = bod_UIPositionY[playerid] + spacing;

			else
				ypos = bod_LabelData1[playerid][index - 1][bl_posY] + spacing;
			
			bod_LabelData1[playerid][index][bl_posY] = ypos;

			bod_LabelData1[playerid][index][bl_textdraw]=CreatePlayerTextDraw(playerid, bod_UIPositionX[playerid] + 55.0, ypos, string);
			PlayerTextDrawAlignment			(playerid, bod_LabelData1[playerid][index][bl_textdraw], 3);
			PlayerTextDrawBackgroundColor	(playerid, bod_LabelData1[playerid][index][bl_textdraw], 255);
			PlayerTextDrawFont				(playerid, bod_LabelData1[playerid][index][bl_textdraw], 1);
			PlayerTextDrawLetterSize		(playerid, bod_LabelData1[playerid][index][bl_textdraw], bod_UIFontSizeX[playerid], bod_UIFontSizeY[playerid]);
			PlayerTextDrawColor				(playerid, bod_LabelData1[playerid][index][bl_textdraw], textcolour);
			PlayerTextDrawSetOutline		(playerid, bod_LabelData1[playerid][index][bl_textdraw], 0);
			PlayerTextDrawSetProportional	(playerid, bod_LabelData1[playerid][index][bl_textdraw], 1);
			PlayerTextDrawSetShadow			(playerid, bod_LabelData1[playerid][index][bl_textdraw], 0);
			PlayerTextDrawTextSize			(playerid, bod_LabelData1[playerid][index][bl_textdraw], bod_UIPositionX[playerid], 10.0);
			PlayerTextDrawSetSelectable		(playerid, bod_LabelData1[playerid][index][bl_textdraw], true);

			PlayerTextDrawShow(playerid, bod_LabelData1[playerid][index][bl_textdraw]);
		}
	}

	return index;
}

stock SetBodyPreviewUIOffsets(playerid, Float:x, Float:y)
{
	bod_UIPositionX[playerid] = x;
	bod_UIPositionY[playerid] = y;

	PlayerTextDrawDestroy(playerid, bod_Header[playerid]);
	PlayerTextDrawDestroy(playerid, bod_Background[playerid]);
	PlayerTextDrawDestroy(playerid, bod_BodyPreview[playerid]);

	CreateBodyPreviewUI(playerid);

	return 1;
}

CMD:bodyuioffsets(playerid, params[])
{
	new
		Float:x,
		Float:y;

	if(sscanf(params, "ff", x, y))
	{
		MsgF(playerid, YELLOW, " >  Current offsets: %f, %f", bod_UIPositionX[playerid], bod_UIPositionY[playerid]);
		return 1;
	}

	SetBodyPreviewUIOffsets(playerid, x, y);

	return 1;
}
