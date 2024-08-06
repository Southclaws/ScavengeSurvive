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
PlayerText:	ToolTipText[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
Timer:		ToolTipTimer[MAX_PLAYERS] = {Timer:0, ...};

ShowHelpTip(playerid, const text[], time = 0)
{
	if(!ToolTips[playerid])
		return 0;

	stop ToolTipTimer[playerid];

	PlayerTextDrawSetString(playerid, ToolTipText[playerid], text);
	PlayerTextDrawShow(playerid, ToolTipText[playerid]);

	if(time > 0)
		ToolTipTimer[playerid] = defer HideHelpTip_Delay(playerid, time);

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
	PlayerTextDrawLetterSize		(playerid, ToolTipText[playerid], 0.3, 1.2);
	PlayerTextDrawColor				(playerid, ToolTipText[playerid], 0x2f5a26ff);
	PlayerTextDrawSetOutline		(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ToolTipText[playerid], 0);
	PlayerTextDrawUseBox			(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ToolTipText[playerid], 0);
	PlayerTextDrawTextSize			(playerid, ToolTipText[playerid], 490.000000, 0.000000);
}

hook OnPlayerGetItem(playerid, Item:itemid)
{
	if(ToolTips[playerid])
	{
		new
			itemname[MAX_ITEM_NAME],
			itemtipkey[12],
			str[390],
			ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

		GetItemTypeUniqueName(itemtype, itemname);

		if(strlen(itemname) > 9)
			itemname[9] = EOS;

		format(itemtipkey, sizeof(itemtipkey), "%s_T", itemname);
		itemtipkey[11] = EOS;
		
		GetItemTypeName(itemtype, itemname);

		format(str, sizeof(str), "~y~%s: ~g~%s~n~~n~~b~%s", itemname, ls(playerid, itemtipkey, true), ls(playerid, "TOOLTIPTG", true));

		ShowHelpTip(playerid, str, 20000);
	}
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid)
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
