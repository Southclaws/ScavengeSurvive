//==========================================================================Player Control

ACMD:ban[2](playerid, params[])
{
	new
		id = -1,
		playername[MAX_PLAYER_NAME],
		reason[64],
		highestadmin;

	foreach(new i : Player)
	{
		if(gPlayerData[i][ply_Admin] > gPlayerData[highestadmin][ply_Admin])
			highestadmin = i;
	}

	if(!sscanf(params, "dS(None)[64]", id, reason))
	{
		if(strlen(reason) > 64)
			return Msg(playerid, RED, " >  Reason must be below 64 characters");

		if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != id)
			return 2;

		if(!IsPlayerConnected(id))
			return 4;

		if(playerid == id)
			return Msg(playerid, RED, " >  You typed your own player ID and nearly banned yourself! Now that would be embarrassing!");

		if(gPlayerData[playerid][ply_Admin] != gPlayerData[highestadmin][ply_Admin])
			return MsgF(highestadmin, YELLOW, " >  %P"#C_YELLOW" Is trying to ban %P"#C_YELLOW", You are the highest online admin, it's your decision.", playerid, id);

		MsgF(playerid, YELLOW, " >  Banned %P"#C_YELLOW" reason: "#C_BLUE"%s", id, reason);

		BanPlayer(id, reason, playerid);

		return 1;
	}
	if(!sscanf(params, "sS(None)[64]", playername, reason))
	{
		if(strlen(reason) > 64)
			return Msg(playerid, RED, " >  Reason must be below 64 characters");

		for(new idx; idx<gTotalAdmins; idx++)
		{
			if(!strcmp(playername, gAdminData[idx][admin_Name]))
			{
				return 2;
			}
		}

		if(gPlayerData[playerid][ply_Admin] != gPlayerData[highestadmin][ply_Admin])
			return MsgF(highestadmin, YELLOW, " >  %P"#C_YELLOW" Is trying to ban "#C_BLUE"%s"#C_YELLOW", You are the highest online admin, it's your decision.", playerid, playername);

		MsgF(playerid, YELLOW, " >  Banned "#C_ORANGE"%s"#C_YELLOW" reason: "#C_BLUE"%s", playername, reason);

		BanPlayerByName(playername, reason, playerid);

		return 1;
	}

	Msg(playerid, YELLOW, " >  Usage: /ban [playerid] [reason]");

	return 1;
}

ACMD:unban[2](playerid, params[])
{
	new name[24];

	if(sscanf(params, "s[24]", name))
		return Msg(playerid, YELLOW, " >  Usage: /unban [player name]");

	new
		tmpQuery[128];

	format(tmpQuery, 128, "DELETE FROM `Bans` WHERE `"#ROW_NAME"` = '%s'", name);
	
	db_free_result(db_query(gAccounts, tmpQuery));
	
	MsgF(playerid, YELLOW, " >  Unbanned "#C_BLUE"%s "#C_YELLOW".", name);

	return 1;
}


//==========================================================================Server Control

ACMD:clearchat[2](playerid, params[])
{
	for(new i;i<100;i++)
		MsgAll(WHITE, " ");

	return 1;
}

ACMD:ann[2](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /ann [Message]");

	GameTextForAll(params, 5000, 5);

	return 1;
}

ACMD:motd[2](playerid, params[])
{
	if(sscanf(params, "s[128]", gMessageOfTheDay))
		return Msg(playerid, YELLOW, " >  Usage: /motd [message]");

	MsgAllF(YELLOW, " >  MOTD updated: "#C_BLUE"%s", gMessageOfTheDay);
	file_Open(SETTINGS_FILE);
	file_SetStr("motd", gMessageOfTheDay);
	file_Save(SETTINGS_FILE);
	file_Close();

	return 1;
}
