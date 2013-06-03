// 8 commands

new gAdminCommandList_Lvl2[] =
{
	"/(un)ban - ban/unban a player from the server\n\
	/banlist - show a list of banned players\n\
	/whitelist - add/remove a player from the whitelist\n\
	/aliases - check aliases\n\
	/clearchat - clear the chatbox\n\
	/ann - send an on-screen announcement to everyone\n\
	/motd - set the message of the day\n"
};


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
	if(!sscanf(params, "s[24]S(None)[64]", playername, reason))
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


ACMD:banlist[2](playerid, params[])
{
	ShowListOfBans(playerid, 0);
	return 1;
}


ACMD:unban[2](playerid, params[])
{
	new name[24];

	if(sscanf(params, "s[24]", name))
		return Msg(playerid, YELLOW, " >  Usage: /unban [player name]");

	UnBanPlayer(name);
	
	MsgF(playerid, YELLOW, " >  Unbanned "#C_BLUE"%s"#C_YELLOW".", name);

	return 1;
}


ACMD:whitelist[2](playerid, params[])
{
	new
		command[7],
		name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[7]s[24]", command, name))
	{
		Msg(playerid, YELLOW, " >  Usage: /whitelist [add/remove] [name]");
		return 1;
	}

	if(!strcmp(command, "add", true))
	{
		MsgF(playerid, YELLOW, " >  Added "#C_BLUE"%s "#C_YELLOW"to whitelist.", name);
		AddNameToWhitelist(name);
	}
	else if(!strcmp(command, "remove", true))
	{
		MsgF(playerid, YELLOW, " >  Removed "#C_BLUE"%s "#C_YELLOW"from whitelist.", name);
		RemoveNameFromWhitelist(name);
	}

	return 1;
}


ACMD:aliases[2](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))
		return Msg(playerid, YELLOW, " >  Usage: /aliases [playerid]");

	if(!IsPlayerConnected(targetid))
		return Msg(playerid,RED, " >  Invalid targetid");

	if(gPlayerData[targetid][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != targetid)
	{
		MsgF(playerid, YELLOW, " >  Aliases: "#C_BLUE"(1)"#C_ORANGE" %p", targetid);
		return 1;
	}

	new
		rowCount,
		tmpIpQuery[128],
		tmpIpField[32],
		DBResult:tmpIpResult,
		tmpNameList[128];

	format(tmpIpQuery, 128,
		"SELECT * FROM `Player` WHERE `"#ROW_IPV4"` = '%d' AND `"#ROW_NAME"` != '%s'",
		gPlayerData[targetid][ply_IP], gPlayerName[playerid]);

	tmpIpResult = db_query(gAccounts, tmpIpQuery);

	rowCount = db_num_rows(tmpIpResult);

	if(rowCount > 0)
	{
		for(new i; i < rowCount && i < 5;i++)
		{
			db_get_field(tmpIpResult, 0, tmpIpField, 128);

			if(i > 0)
				strcat(tmpNameList, ", ");

			strcat(tmpNameList, tmpIpField);
			db_next_row(tmpIpResult);
		}
		MsgF(playerid, YELLOW, " >  Aliases: "#C_BLUE"(%d)"#C_ORANGE" %s", rowCount, tmpNameList);
	}
	db_free_result(tmpIpResult);

	return 1;
}


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
