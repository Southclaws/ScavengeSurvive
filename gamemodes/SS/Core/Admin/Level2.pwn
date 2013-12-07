// 9 commands

new gAdminCommandList_Lvl2[] =
{
	"/duty - go on admin duty\n\
	/spec - spectate\n\
	/unstick - move player up\n\
	/(un)freeze - freeze/unfreeze player\n\
	/kick - kick player\n\
	/(un)ban - ban/unban player\n\
	/banlist - show list of bans\n\
	/isbanned - check if banned\n\
	/aliases - check aliases\n\
	/motd - set message of the day\n"
};

new
	Timer:UnfreezeTimer[MAX_PLAYERS],
	tick_UnstickUsage[MAX_PLAYERS];


ACMD:spec[2](playerid, params[])
{
	if(!(gPlayerBitData[playerid] & AdminDuty))
		return 6;

	if(isnull(params))
	{
		ExitSpectateMode(playerid);
	}
	else
	{
		new targetid = strval(params);

		if(IsPlayerConnected(targetid) && targetid != playerid)
		{
			if(gPlayerData[playerid][ply_Admin] == 1)
			{
				if(!IsPlayerReported(gPlayerName[targetid]))
				{
					Msg(playerid, YELLOW, " >  You can only spectate reported players.");
					return 1;
				}
			}

			EnterSpectateMode(playerid, targetid);
		}
	}

	return 1;
}

ACMD:unstick[2](playerid, params[])
{
	if(!(gPlayerBitData[playerid] & AdminDuty))
		return 6;

	if(GetTickCountDifference(GetTickCount(), tick_UnstickUsage[playerid]) < 1000)
	{
		Msg(playerid, RED, " >  You cannot use that command that often.");
		return 1;
	}

	new targetid;

	if(sscanf(params, "d", targetid))
	{
		Msg(playerid, YELLOW, " >  Usage: /unstick [playerid]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(targetid, x, y, z);
	SetPlayerPos(targetid, x, y, z + 1.0);

	tick_UnstickUsage[playerid] = GetTickCount();

	return 1;
}

ACMD:freeze[2](playerid, params[])
{
	new targetid, delay;

	if(sscanf(params, "dD(0)", targetid, delay))
		return Msg(playerid, YELLOW, " >  Usage: /freeze [playerid] (seconds)");

	if(gPlayerData[targetid][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	TogglePlayerControllable(targetid, false);
	t:gPlayerBitData[targetid]<Frozen>;
	
	if(delay > 0)
	{
		stop UnfreezeTimer[targetid];
		UnfreezeTimer[targetid] = defer CmdDelay_unfreeze(targetid, delay * 1000);
		MsgF(playerid, YELLOW, " >  Frozen %P for %d seconds", targetid, delay);
		MsgF(targetid, YELLOW, " >  Frozen by admin for %d seconds", delay);
	}
	else
	{
		MsgF(playerid, YELLOW, " >  Frozen %P", targetid);
		Msg(targetid, YELLOW, " >  Frozen by admin");
	}

	return 1;
}

timer CmdDelay_unfreeze[time](playerid, time)
{
	#pragma unused time

	TogglePlayerControllable(playerid, true);
	f:gPlayerBitData[playerid]<Frozen>;

	Msg(playerid, YELLOW, " >  You are now unfrozen.");
}

ACMD:unfreeze[2](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))
		return Msg(playerid, YELLOW, " >  Usage: /unfreeze [playerid]");

	if(!IsPlayerConnected(targetid))
		return 4;

	TogglePlayerControllable(targetid, true);
	f:gPlayerBitData[targetid]<Frozen>;
	stop UnfreezeTimer[targetid];

	MsgF(playerid, YELLOW, " >  Unfrozen %P", targetid);
	Msg(targetid, YELLOW, " >  Unfrozen");

	return 1;
}

ACMD:kick[2](playerid, params[])
{
	new
		targetid,
		reason[64],
		highestadmin;

	foreach(new i : Player)
	{
		if(gPlayerData[i][ply_Admin] > gPlayerData[highestadmin][ply_Admin])
			highestadmin = i;
	}

	if(sscanf(params, "ds[64]", targetid, reason))
		return Msg(playerid, YELLOW, " >  Usage: /kick [playerid] [reason]");

	if(gPlayerData[targetid][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	if(gPlayerData[playerid][ply_Admin] != gPlayerData[highestadmin][ply_Admin])
		return MsgF(highestadmin, YELLOW, " >  %p kick request: (%d)%p reason: %s", playerid, targetid, targetid, reason);

	if(playerid == targetid)
		MsgAllF(PINK, " >  %P"C_PINK" failed and kicked themselves", playerid);

	KickPlayer(targetid, reason);

	return 1;
}

ACMD:ban[2](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name))
	{
		Msg(playerid, YELLOW, " >  Usage: /ban [playerid/name]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		else
			MsgF(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);
	}

	if(!AccountExists(name))
	{
		MsgF(playerid, YELLOW, " >  The account '%s' does not exist.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > 0)
		return 2;

	BanAndEnterInfo(playerid, name);

	MsgF(playerid, YELLOW, " >  Preparing ban for %s", name);

	return 1;
}

ACMD:unban[2](playerid, params[])
{
	new name[24];

	if(sscanf(params, "s[24]", name))
		return Msg(playerid, YELLOW, " >  Usage: /unban [player name]");

	if(UnBanPlayer(name))
		MsgF(playerid, YELLOW, " >  Unbanned "C_BLUE"%s"C_YELLOW".", name);

	else
		MsgF(playerid, YELLOW, " >  Player '%s' is not banned.");

	return 1;
}

ACMD:banlist[2](playerid, params[])
{
	ShowListOfBans(playerid, 0);
	return 1;
}

ACMD:isbanned[2](playerid, params[])
{
	if(!(3 < strlen(params) < MAX_PLAYER_NAME))
	{
		MsgF(playerid, RED, " >  Invalid player name '%s'.", params);
		return 1;
	}

	if(IsPlayerBanned(params))
		Msg(playerid, YELLOW, " >  Player '%s' "C_BLUE"is "C_YELLOW"banned.");

	else
		Msg(playerid, YELLOW, " >  Player '%s' "C_BLUE"isn't "C_YELLOW"banned.");

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

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		else
			MsgF(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);
	}

	if(!AccountExists(name))
	{
		MsgF(playerid, YELLOW, " >  The account '%s' does not exist.", name);
		return 1;
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
		ret = GetAccountAliasesByPass(name, list, count, 6, adminlevel);
	}
	else if(!strcmp(type, "byhash", true))
	{
		ret = GetAccountAliasesByHash(name, list, count, 6, adminlevel);
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
