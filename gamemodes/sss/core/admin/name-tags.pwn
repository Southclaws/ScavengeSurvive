/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


static
		tags_Toggle[MAX_PLAYERS],
Text3D:	tags_Nametag[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...},
Text3D:	tags_NametagLOS[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};


hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/admin/name-tags.pwn");

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

	tags_Nametag[playerid] = CreateDynamic3DTextLabelEx(string, YELLOW, 0.0, 0.0, 0.0, 6000.0, playerid, _, 0, 6000.0, _, _, players, 1, 1, maxplayers);
	tags_NametagLOS[playerid] = CreateDynamic3DTextLabelEx("[|                                           |]", BLUE, 0.0, 0.0, 0.0, 6000.0, playerid, _, 1, 6000.0, _, _, players, 1, 1, maxplayers);

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDisconnect] in /gamemodes/sss/core/admin/name-tags.pwn");

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
