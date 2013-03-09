ACMD:setadmin[2](playerid, params[])
{
	new
		id,
		level;

	if (sscanf(params, "dd", id, level))
		return Msg(playerid, YELLOW, " >  Usage: /setadmin [playerid] [level]");

	if(playerid == id)
		return Msg(playerid, RED, " >  You cannot set your own level");

	if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin] && gPlayerData[playerid][ply_Admin] < 3)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(!SetPlayerAdminLevel(id, level))
		return Msg(playerid, RED, " >  Admin level must be equal to or between 0 and 3");


	MsgF(playerid, YELLOW, " >  You made %P"#C_YELLOW" a Level %d Admin", id, level);
	MsgF(id, YELLOW, " >  %P"#C_YELLOW" Made you a Level %d Admin", playerid, level);

	return 1;
}

ACMD:setvip[2](playerid, params[])
{
	new id, toggle;

	if(sscanf(params, "dd", id, toggle))
		return Msg(playerid, YELLOW, " >  Usage: /setvip [playerid]");

	if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != id)
		return 3;

	if(toggle)
	{
		t:bPlayerGameSettings[id]<IsVip>;
		MsgF(playerid, YELLOW, " >  You gave VIP status to %P", id);
	}
	else
	{
		f:bPlayerGameSettings[id]<IsVip>;
		MsgF(playerid, YELLOW, " >  You removed VIP status from %P", id);
	}
	return 1;
}



//==========================================================================Player Control

ACMD:ban[2](playerid, params[])
{
	new
		id = -1,
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

		if(gPlayerData[playerid][ply_Admin]!=gPlayerData[highestadmin][ply_Admin])
			return MsgF(highestadmin, YELLOW, " >  %P"#C_YELLOW" Is trying to ban %P"#C_YELLOW", You are the highest online admin, it's your decision.", playerid, id);

		BanPlayer(id, reason, playerid);

		MsgAllF(YELLOW, " >  %P"#C_YELLOW" banned %P"#C_YELLOW" Reason: "#C_BLUE"%s", playerid, id, reason);

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
	
	MsgF(playerid, YELLOW, " >  Banned "#C_BLUE"%s "#C_YELLOW"from the server.", name);

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
