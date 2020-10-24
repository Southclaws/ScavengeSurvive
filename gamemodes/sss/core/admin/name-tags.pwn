/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
		tags_Toggle[MAX_PLAYERS],
Text3D:	tags_Nametag[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...},
Text3D:	tags_NametagLOS[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};


hook OnPlayerConnect(playerid)
{
	new
		string[MAX_PLAYER_NAME + 6],
		name[MAX_PLAYER_NAME],
		players[MAX_PLAYERS],
		maxplayers;

	tags_Toggle[playerid] = false;

	foreach(new i : Player)
	{
		if(tags_Toggle[i])
			players[maxplayers++] = i;
	}

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	format(string, sizeof(string), "(%d) %s", playerid, name);

	tags_Nametag[playerid] = CreateDynamic3DTextLabelEx(
		string, YELLOW, 0.0, 0.0, 0.0, 6000.0, playerid,
		.testlos = 0,
		.streamdistance = 6000.0,
		.players = players,
		.maxworlds = 1,
		.maxinteriors = 1,
		.maxplayers = maxplayers);

	tags_NametagLOS[playerid] = CreateDynamic3DTextLabelEx(
		"[|                                           |]", BLUE, 0.0, 0.0, 0.0, 6000.0, playerid,
		.testlos = 1,
		.streamdistance = 6000.0,
		.players = players,
		.maxworlds = 1,
		.maxinteriors = 1,
		.maxplayers = maxplayers);

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	DestroyDynamic3DTextLabel(tags_Nametag[playerid]);
	DestroyDynamic3DTextLabel(tags_NametagLOS[playerid]);

	tags_Nametag[playerid] = Text3D:INVALID_3DTEXT_ID;
	tags_NametagLOS[playerid] = Text3D:INVALID_3DTEXT_ID;

	foreach(new i : Player)
	{
		if(IsValidDynamic3DTextLabel(tags_Nametag[i]))
			Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_Nametag[i], E_STREAMER_PLAYER_ID, playerid);

		if(IsValidDynamic3DTextLabel(tags_NametagLOS[i]))
			Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_NametagLOS[i], E_STREAMER_PLAYER_ID, playerid);
	}		

	return 1;
}

ToggleNameTagsForPlayer(playerid, toggle)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	tags_Toggle[playerid] = toggle;

	if(toggle)
	{
		foreach(new i : Player)
		{
			if(!Streamer_IsInArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_Nametag[i], E_STREAMER_PLAYER_ID, playerid))
				Streamer_AppendArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_Nametag[i], E_STREAMER_PLAYER_ID, playerid);

			if(!Streamer_IsInArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_NametagLOS[i], E_STREAMER_PLAYER_ID, playerid))
				Streamer_AppendArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_NametagLOS[i], E_STREAMER_PLAYER_ID, playerid);
		}
	}
	else
	{
		foreach(new i : Player)
		{
			Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_Nametag[i], E_STREAMER_PLAYER_ID, playerid);
			Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_NametagLOS[i], E_STREAMER_PLAYER_ID, playerid);
		}
	}

	return 1;
}

stock GetPlayerNameTagsToggle(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return tags_Toggle[playerid];
}
