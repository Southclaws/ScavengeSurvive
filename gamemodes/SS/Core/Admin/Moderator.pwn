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

	if(!sscanf(params, "d", id))
	{
		if(gPlayerData[id][ply_Admin] > 0)
			return 2;

		if(!IsPlayerConnected(id))
			return 4;

		if(playerid == id)
			return Msg(playerid, RED, " >  You typed your own player ID and nearly banned yourself! Now that would be embarrassing!");

		MsgF(playerid, YELLOW, " >  Preparing ban for %P", id);

		BanPlayerByCommand(playerid, id);

		return 1;
	}

	if(!sscanf(params, "s[24]s[64]", playername, reason))
	{
		if(strlen(reason) > 64)
			return Msg(playerid, RED, " >  Reason must be below 64 characters");

		if(GetAdminLevelByName(playername) > 0)
			return 2;

		MsgF(playerid, YELLOW, " >  Banned "C_ORANGE"%s"C_YELLOW" reason: "C_BLUE"%s", playername, reason);

		BanPlayerByName(playername, reason, playerid, 0);

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
	
	MsgF(playerid, YELLOW, " >  Unbanned "C_BLUE"%s"C_YELLOW".", name);

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
			MsgF(playerid, YELLOW, " >  Added "C_BLUE"%s "C_YELLOW"to whitelist.", name);

		if(result == 0)
			Msg(playerid, YELLOW, " >  That name "C_ORANGE"is already "C_YELLOW"in the whitelist.");

		if(result == -1)
			Msg(playerid, RED, " >  An error occurred.");
	}
	else if(!strcmp(command, "remove", true) && !isnull(name))
	{
		new result = RemoveNameFromWhitelist(name);

		if(result == 1)
			MsgF(playerid, YELLOW, " >  Removed "C_BLUE"%s "C_YELLOW"from whitelist.", name);

		if(result == 0)
			Msg(playerid, YELLOW, " >  That name "C_ORANGE"is not "C_YELLOW"in the whitelist.");

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
			Msg(playerid, YELLOW, " >  That name "C_BLUE"is "C_YELLOW"in the whitelist.");

		else
			Msg(playerid, YELLOW, " >  That name "C_ORANGE"is not "C_YELLOW"in the whitelist");
	}

	return 1;
}


ACMD:aliases[2](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		type[7];

	if(sscanf(params, "s[24]S(byip)[7]", name, type))
	{
		Msg(playerid, YELLOW, " >  Usage: /aliases [playerid/name] [byip/bypass/byhash]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(!IsPlayerConnected(targetid))
			return Msg(playerid,RED, " >  Invalid ID");

		GetPlayerName(targetid, name, MAX_PLAYER_NAME);
	}
	else
	{
		if(!AccountExists(name))
		{
			Msg(playerid, YELLOW, " >  That account does not exist.");
			return 1;
		}
	}

	if(GetAdminLevelByName(name) > gPlayerData[playerid][ply_Admin])
	{
		new playername[MAX_PLAYER_NAME];

		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(strcmp(name, playername))
		{
			MsgF(playerid, YELLOW, " >  No aliases found for %s", name);
			return 1;
		}
	}

	new
		ret,
		list[6][MAX_PLAYER_NAME],
		count,
		adminlevel,
		string[(MAX_PLAYER_NAME + 2) * 6];

	if(!strcmp(type, "byip", true))
	{
		ret = GetAccountAliasesByIP(name, list, count, 6, adminlevel);
	}
	else if(!strcmp(type, "bypass", true))
	{
		// ret = GetAccountAliasesByPass(name, list, count, 6, adminlevel);
		Msg(playerid, YELLOW, " >  Lookup type unavailable.");
		return 1;
	}
	else if(!strcmp(type, "byhash", true))
	{
		// ret = GetAccountAliasesByHash(name, list, count, 6, adminlevel);
		Msg(playerid, YELLOW, " >  Lookup type unavailable.");
		return 1;
	}
	else
	{
		Msg(playerid, YELLOW, " >  Lookup type must be one of: 'byip', 'bypass', 'byhash'");
		return 1;
	}

	if(ret == 0)
	{
		Msg(playerid, RED, " >  An error occurred.");
		return 1;
	}

	if(count == 0)
	{
		MsgF(playerid, YELLOW, " >  No aliases found for %s", name);
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

			if(i < count - 1)
				strcat(string, ", ");
		}
	}

	if(adminlevel <= gPlayerData[playerid][ply_Admin])
		MsgF(playerid, YELLOW, " >  Aliases: "C_BLUE"(%d)"C_ORANGE" %s", count, string);

	else
		MsgF(playerid, YELLOW, " >  No aliases found for %s", name);

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

	MsgAllF(YELLOW, " >  MOTD updated: "C_BLUE"%s", gMessageOfTheDay);

	djStyled(true);
	djSet(SETTINGS_FILE, "server/motd", gMessageOfTheDay);

	return 1;
}
