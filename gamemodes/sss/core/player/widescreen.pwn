/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static bool:WideScreenUI[MAX_PLAYERS];


stock bool:IsPlayerWideScreen(playerid)
{
	if(!IsPlayerConnected(playerid))
		return false;

	return WideScreenUI[playerid];
}

stock TogglePlayerWideScreenUI(playerid, bool:toggle)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	WideScreenUI[playerid] = toggle;
	return 1;
}

hook OnPlayerSave(playerid, filename[])
{
	new data[1];
	data[0] = WideScreenUI[playerid];
	modio_push(filename, _T<W,S,U,I>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[1];
	modio_read(filename, _T<W,S,U,I>, sizeof(data), data);
	WideScreenUI[playerid] = !!data[0];
	ChatMsg(playerid, YELLOW, "Widescreen UI scaling %s", WideScreenUI[playerid] ? ("enabled") : ("disabled"));
}
