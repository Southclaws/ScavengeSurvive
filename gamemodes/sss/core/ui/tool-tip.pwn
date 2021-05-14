/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
bool:		ToolTips[MAX_PLAYERS],
PlayerText:	ToolTipText[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

ShowHelpTip(playerid, const text[], time = 0)
{
	if(!ToolTips[playerid])
		return 0;

	PlayerTextDrawSetString(playerid, ToolTipText[playerid], text);
	PlayerTextDrawShow(playerid, ToolTipText[playerid]);

	if(time > 0)
		defer HideHelpTip_Delay(playerid, time);

	return 1;
}

timer HideHelpTip_Delay[time](playerid, time)
{
	HideHelpTip(playerid);
	#pragma unused time
}

HideHelpTip(playerid)
{
	PlayerTextDrawHide(playerid, ToolTipText[playerid]);
}

hook OnPlayerConnect(playerid)
{
	ToolTipText[playerid]			=CreatePlayerTextDraw(playerid, 150.000000, 350.000000, "Tip: You can access the trunks of cars by pressing F at the back");
	PlayerTextDrawBackgroundColor	(playerid, ToolTipText[playerid], 255);
	PlayerTextDrawFont				(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ToolTipText[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, ToolTipText[playerid], 16711935);
	PlayerTextDrawSetOutline		(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ToolTipText[playerid], 0);
	PlayerTextDrawUseBox			(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ToolTipText[playerid], 0);
	PlayerTextDrawTextSize			(playerid, ToolTipText[playerid], 520.000000, 0.000000);
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(ToolTips[playerid])
	{
		new
			itemname[MAX_ITEM_NAME],
			itemtipkey[12],
			str[288];

		GetItemTypeUniqueName(GetItemType(itemid), itemname);

		if(strlen(itemname) > 9)
			itemname[9] = EOS;

		format(itemtipkey, sizeof(itemtipkey), "%s_T", itemname);
		itemtipkey[11] = EOS;
		
		format(str, sizeof(str), "%s~n~~n~~b~Type /tooltips to toggle these messages", ls(playerid, itemtipkey, true));

		ShowHelpTip(playerid, str, 20000);
	}
}

hook OnPlayerDropItem(playerid, Item:itemid)
{
	if(ToolTips[playerid])
		HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock IsPlayerToolTipsOn(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ToolTips[playerid];
}

stock SetPlayerToolTips(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ToolTips[playerid] = st;

	return 1;
}
