// 6 commands

new gAdminCommandList_Lvl2[] =
{
	"/(un)ban - ban/unban a player from the server\n\
	/banlist - show a list of banned players\n\
	/whitelist - add/remove name or turn whitelist on/off\n\
	/aliases - check aliases\n\
	/clearchat - clear the chatbox\n\
	/motd - set the message of the day\n"
};


ACMD:ban[2](playerid, params[])
{
	new
		id = -1,
		playername[MAX_PLAYER_NAME],
		reason[64];

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

		MsgF(playerid, YELLOW, " >  Banned %P"#C_YELLOW" reason: "#C_BLUE"%s", id, reason);

		BanPlayer(id, reason, playerid);

		return 1;
	}
	if(!sscanf(params, "s[24]S(None)[64]", playername, reason))
	{
		if(strlen(reason) > 64)
			return Msg(playerid, RED, " >  Reason must be below 64 characters");

		if(GetAdminLevelByName(playername) > 0)
			return 2;

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

	if(sscanf(params, "s[7]S()[24]", command, name))
	{
		MsgF(playerid, YELLOW, " >  Usage: /whitelist [add/remove/on/off] [name] - the whitelist is currently %s", gWhitelist ? ("on") : ("off"));
		return 1;
	}

	if(!strcmp(command, "add", true) && !isnull(name))
	{
		new result = AddNameToWhitelist(name);

		if(result == 1)
			MsgF(playerid, YELLOW, " >  Added "#C_BLUE"%s "#C_YELLOW"to whitelist.", name);

		if(result == 0)
			Msg(playerid, YELLOW, " >  That name "#C_ORANGE"is already "#C_YELLOW"in the whitelist.");

		if(result == -1)
			Msg(playerid, RED, " >  An error occurred.");
	}
	else if(!strcmp(command, "remove", true) && !isnull(name))
	{
		new result = RemoveNameFromWhitelist(name);

		if(result == 1)
			MsgF(playerid, YELLOW, " >  Removed "#C_BLUE"%s "#C_YELLOW"from whitelist.", name);

		if(result == 0)
			Msg(playerid, YELLOW, " >  That name "#C_ORANGE"is not "#C_YELLOW"in the whitelist.");

		if(result == -1)
			Msg(playerid, RED, " >  An error occurred.");
	}
	else if(!strcmp(command, "on", true))
	{
		MsgAdmins(1, YELLOW, " >  Whitelist activated, only whitelisted players may join.");
		gWhitelist = true;
	}
	else if(!strcmp(command, "off", true))
	{
		MsgAdmins(1, YELLOW, " >  Whitelist deactivated, anyone may join the server.");
		gWhitelist = false;
	}
	else if(!strcmp(command, "?", true))
	{
		if(IsNameInWhitelist(name))
			Msg(playerid, YELLOW, " >  That name "#C_BLUE"is "#C_YELLOW"in the whitelist.");

		else
			Msg(playerid, YELLOW, " >  That name "#C_ORANGE"is not "#C_YELLOW"in the whitelist");
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
		list[6][MAX_PLAYER_NAME],
		count,
		adminlevel,
		string[(MAX_PLAYER_NAME + 2) * 6];

	GetAccountAliases(gPlayerName[targetid], gPlayerData[targetid][ply_IP], list, count, 6, adminlevel);

	if(count == 0)
	{
		Msg(playerid, YELLOW, " >  No other accounts used by that players IP address.");
		return 1;
	}

	if(count == 1)
	{
		strcat(string, list[0]);
	}

	if(count > 1)
	{
		for(new i; i < count; i++)
		{
			strcat(string, list[i]);
			strcat(string, ", ");
		}
	}

	if(adminlevel < gPlayerData[playerid][ply_Admin])
		MsgF(playerid, YELLOW, " >  Aliases: "#C_BLUE"(%d)"#C_ORANGE" %s", count, string);

	else
		MsgF(playerid, YELLOW, " >  Aliases: "#C_BLUE"(1)"#C_ORANGE" %p", targetid);

	return 1;
}


ACMD:clearchat[2](playerid, params[])
{
	for(new i;i<100;i++)
		MsgAll(WHITE, " ");

	return 1;
}


ACMD:motd[2](playerid, params[])
{
	if(sscanf(params, "s[128]", gMessageOfTheDay))
	{
		Msg(playerid, YELLOW, " >  Usage: /motd [message]");
		return 1;
	}

	MsgAllF(YELLOW, " >  MOTD updated: "#C_BLUE"%s", gMessageOfTheDay);

	new INI:ini = INI_Open(SETTINGS_FILE);

	INI_WriteString(ini, "motd", gMessageOfTheDay);
	INI_Close(ini);

	return 1;
}
