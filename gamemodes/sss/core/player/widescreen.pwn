/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


enum e_UI_SCALE_PROFILES
{
	e_UI_SCALE_NORMAL,
	e_UI_SCALE_HUDSCALEFIX,
	e_UI_SCALE_WIDESCREENFIX,
}

static UIScaleProfileName[e_UI_SCALE_PROFILES][] = {
	"Normal",
	"With /hudscalefix Enabled",
	"With WidescreenFix Mod"
};

static e_UI_SCALE_PROFILES:UIScaleProfile[MAX_PLAYERS];


stock DisplayHudScaleProfileSelect(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(!response)
			return;

		switch(listitem)
		{
			case 0: SetPlayerUIScaleProfile(playerid, e_UI_SCALE_NORMAL);
			case 1: SetPlayerUIScaleProfile(playerid, e_UI_SCALE_HUDSCALEFIX);
			case 2: SetPlayerUIScaleProfile(playerid, e_UI_SCALE_WIDESCREENFIX);
		}

		UpdateWatchWithScaleProfile(playerid);
		DisplayHudScaleProfileSelect(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Select HUD Scale Profile", "Normal\nWith /hudscalefix Enabled\nWith WidescreenFix Mod", "Select", "Close");
}

stock e_UI_SCALE_PROFILES:GetPlayerUIScaleProfile(playerid)
{
	if(!IsPlayerConnected(playerid))
		return e_UI_SCALE_NORMAL;

	return UIScaleProfile[playerid];
}

stock SetPlayerUIScaleProfile(playerid, e_UI_SCALE_PROFILES:profile)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	UIScaleProfile[playerid] = profile;
	return 1;
}

hook OnPlayerSave(playerid, filename[])
{
	new data[1];
	data[0] = _:UIScaleProfile[playerid];
	modio_push(filename, _T<W,S,U,I>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[1];
	modio_read(filename, _T<W,S,U,I>, sizeof(data), data);
	UIScaleProfile[playerid] = e_UI_SCALE_PROFILES:data[0];
	ChatMsg(playerid, YELLOW, "Widescreen UI scaling %s", UIScaleProfileName[UIScaleProfile[playerid]]);
}
