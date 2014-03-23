#include <YSI\y_hooks>


static
		tags_Toggle[MAX_PLAYERS],
Text3D:	tags_Nametag[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...},
Text3D:	tags_NametagLOS[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};


hook OnPlayerConnect(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		players[MAX_PLAYERS],
		maxplayers;

	foreach(new i : Player)
	{
		if(tags_Toggle[i])
			players[maxplayers++] = i;
	}

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	tags_Nametag[playerid] = CreateDynamic3DTextLabelEx(name, YELLOW, 0.0, 0.0, 0.5, 6000.0, playerid, _, 0, 6000.0, _, _, players, 1, 1, maxplayers);
	tags_NametagLOS[playerid] = CreateDynamic3DTextLabelEx("[VISIBLE]", BLUE, 0.5, 0.5, -0.5, 6000.0, playerid, _, 1, 6000.0, _, _, players, 1, 1, maxplayers);

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
		Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_Nametag[i], E_STREAMER_PLAYER_ID, playerid);
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
