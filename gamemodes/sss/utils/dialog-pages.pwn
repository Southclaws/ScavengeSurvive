/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
Text:	page_Left,
Text:	page_Right;


forward OnPlayerDialogPage(playerid, direction);


ShowPlayerPageButtons(playerid)
{
	TextDrawShowForPlayer(playerid, page_Left);
	TextDrawShowForPlayer(playerid, page_Right);
	SelectTextDraw(playerid, YELLOW);
}

HidePlayerPageButtons(playerid)
{
	TextDrawHideForPlayer(playerid, page_Left);
	TextDrawHideForPlayer(playerid, page_Right);
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == page_Left)
	{
		CallLocalFunction("OnPlayerDialogPage", "dd", playerid, 0);
	}
	if(clickedid == page_Right)
	{
		CallLocalFunction("OnPlayerDialogPage", "dd", playerid, 1);
	}
}

hook OnGameModeInit()
{
	page_Left					=TextDrawCreate(280.0, 360.0, "<");
	TextDrawAlignment			(page_Left, TEXT_DRAW_ALIGN_CENTRE);
	TextDrawBackgroundColour		(page_Left, 255);
	TextDrawFont				(page_Left, TEXT_DRAW_FONT_1);
	TextDrawLetterSize			(page_Left, 0.5, 2.0);
	TextDrawColour				(page_Left, -1);
	TextDrawSetOutline			(page_Left, 0);
	TextDrawSetProportional		(page_Left, true);
	TextDrawSetShadow			(page_Left, 1);
	TextDrawUseBox				(page_Left, true);
	TextDrawBoxColour			(page_Left, 128);
	TextDrawTextSize			(page_Left, 25.0, 75.0);
	TextDrawSetSelectable		(page_Left, true);

	page_Right					=TextDrawCreate(360.0, 360.0, ">");
	TextDrawAlignment			(page_Right, TEXT_DRAW_ALIGN_CENTRE);
	TextDrawBackgroundColour		(page_Right, 255);
	TextDrawFont				(page_Right, TEXT_DRAW_FONT_1);
	TextDrawLetterSize			(page_Right, 0.5, 2.0);
	TextDrawColour				(page_Right, -1);
	TextDrawSetOutline			(page_Right, 0);
	TextDrawSetProportional		(page_Right, true);
	TextDrawSetShadow			(page_Right, 1);
	TextDrawUseBox				(page_Right, true);
	TextDrawBoxColour			(page_Right, 128);
	TextDrawTextSize			(page_Right, 25.0, 75.0);
	TextDrawSetSelectable		(page_Right, true);
}
