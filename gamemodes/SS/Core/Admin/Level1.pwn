// 7 commands

new gAdminCommandList_Lvl1[] =
{
	"/(un)mute - mute/unmute player\n\
	/warn - warn a player\n\
	/kick - kick player\n\
	/msg - send chat announcement\n\
	/(all)country - show country data\n\
	/clearchat - clear the chatbox\n\
	/aliases - check aliases\n"
};


/*==============================================================================

	Mute a player for some seconds or forever (saves to their account)

==============================================================================*/


ACMD:mute[1](playerid, params[])
{
	new
		targetid,
		delay,
		reason[128];

	if(sscanf(params, "dds[128]", targetid, delay, reason))
		return Msg(playerid,YELLOW," >  Usage: /mute [playerid] [seconds] [reason] - use -1 as a seconds duration for a permanent mute.");

	if(!IsPlayerConnected(targetid))
		return Msg(playerid,RED, " >  Invalid targetid");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid))
		return 3;

	if(IsPlayerMuted(targetid))
		return Msg(playerid, YELLOW, " >  Player Already Muted");

	if(delay > 0)
	{
		TogglePlayerMute(targetid, true, delay * 1000);
		MsgF(playerid, YELLOW, " >  Muted player %P "C_WHITE"for %d seconds.", targetid, delay);
		MsgF(targetid, YELLOW, " >  Muted from global chat for "C_ORANGE"%d "C_YELLOW"seconds, Reason: "C_BLUE"%s", delay, reason);
	}
	else
	{
		TogglePlayerMute(targetid, true);
		MsgF(playerid, YELLOW, " >  Muted player %P", targetid);
		MsgF(targetid, YELLOW, " >  Muted from global chat, Reason: "C_BLUE"%s", reason);
	}

	return 1;
}

ACMD:unmute[1](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))
		return Msg(playerid, YELLOW, " >  Usage: /unmute [playerid]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	TogglePlayerMute(targetid, false);

	MsgF(playerid, YELLOW, " >  Un-muted %P", targetid);
	Msg(targetid, YELLOW, " >  You are now un-muted.");

	return 1;
}


/*==============================================================================

	Warn a player for misconduct, 5 warnings = 1 day ban

==============================================================================*/


ACMD:warn[1](playerid, params[])
{
	new
		targetid,
		reason[128];

	if(sscanf(params, "ds[128]", targetid, reason))
		return Msg(playerid, YELLOW, " >  Usage: /warn [playerid] [reason]");

	if(!IsPlayerConnected(targetid))
		return Msg(playerid,RED, " >  Invalid targetid");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	new warnings = GetPlayerWarnings(targetid) + 1;

	SetPlayerWarnings(targetid, warnings);

	MsgF(playerid, ORANGE, " >  %P"C_YELLOW" Has been warned (%d/5) for: %s", targetid, warnings, reason);
	MsgF(targetid, ORANGE, " >  You been warned (%d/5) for: %s. 5 warnings = 1 day ban.", warnings, reason);

	if(warnings >= 5)
	{
		BanPlayer(targetid, "Getting 5 warnings", playerid, 86400);
	}

	return 1;
}


/*==============================================================================

	Kick a player from the server so they must rejoin

==============================================================================*/


ACMD:kick[1](playerid, params[])
{
	new
		targetid,
		reason[64],
		highestadmin;

	foreach(new i : Player)
	{
		if(GetPlayerAdminLevel(i) > GetPlayerAdminLevel(highestadmin))
			highestadmin = i;
	}

	if(sscanf(params, "ds[64]", targetid, reason))
		return Msg(playerid, YELLOW, " >  Usage: /kick [playerid] [reason]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	if(GetPlayerAdminLevel(playerid) != GetPlayerAdminLevel(highestadmin))
		return MsgF(highestadmin, YELLOW, " >  %p kick request: (%d)%p reason: %s", playerid, targetid, targetid, reason);

	if(playerid == targetid)
		MsgAllF(PINK, " >  %P"C_PINK" failed and kicked themselves", playerid);

	KickPlayer(targetid, reason);

	return 1;
}


/*==============================================================================

	Output a non-player chat box message to all players in the server

==============================================================================*/


ACMD:msg[1](playerid, params[])
{
	if(!(0 < strlen(params) < 128))
		Msg(playerid,YELLOW," >  Usage: /msg [Message]");

	new str[130] = {" >  "C_BLUE""};

	strcat(str, TagScan(params));

	MsgAll(YELLOW, str);
	return 1;
}


/*==============================================================================

	Display player countries

==============================================================================*/


ACMD:country[1](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
	{
		Msg(playerid, YELLOW, " >  Usage: /country [id]");
		return 1;
	}

	if(!IsPlayerConnected(id))
	{
		return 4;
	}

	new country[32];

	if(GetPlayerAdminLevel(id) > GetPlayerAdminLevel(playerid))
		country = "Unknown";

	else
		GetPlayerCountry(id, country);

	MsgF(playerid, YELLOW, " >  %P"C_YELLOW"'s current GeoIP location: "C_BLUE"%s", id, country);

	return 1;
}

ACMD:allcountry[1](playerid, params[])
{
	new
		country[32],
		list[(MAX_PLAYER_NAME + 3 + 32 + 1) * MAX_PLAYERS];

	foreach(new i : Player)
	{
		if(GetPlayerAdminLevel(i) > GetPlayerAdminLevel(playerid))
			country = "Unknown";

		else
			GetPlayerCountry(i, country);

		format(list, sizeof(list), "%s%p - %s\n", list, i, country);
	}

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_LIST, "Countries", list, "Close", "");

	return 1;
}


/*==============================================================================

	Clear the chat box

==============================================================================*/


ACMD:clearchat[1](playerid, params[])
{
	for(new i;i<100;i++)
		MsgAll(WHITE, " ");

	return 1;
}


/*==============================================================================

	Display a player's aliases (other accounts they have used)

==============================================================================*/


ACMD:aliases[1](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		type[7];

	if(sscanf(params, "s[24]S(byip)[7]", name, type))
	{
		Msg(playerid, YELLOW, " >  Usage: /aliases [playerid/name] [i/p/h]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		else if(targetid > 99)
			MsgF(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);

		else
			return 4;
	}

	if(!AccountExists(name))
	{
		MsgF(playerid, YELLOW, " >  The account '%s' does not exist.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > GetPlayerAdminLevel(playerid))
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
		list[6][E_ALIAS_DATA],
		count,
		adminlevel,
		string[(MAX_PLAYER_NAME + 10) * 6];

	if(!strcmp(type, "a", true) || isnull(type))
	{
		ret = GetAccountAliasesByAll(name, list, count, 6, adminlevel);
	}
	else if(!strcmp(type, "i", true))
	{
		ret = GetAccountAliasesByIP(name, list, count, 6, adminlevel);
	}
	else if(!strcmp(type, "p", true))
	{
		ret = GetAccountAliasesByPass(name, list, count, 6, adminlevel);
	}
	else if(!strcmp(type, "h", true))
	{
		ret = GetAccountAliasesByHash(name, list, count, 6, adminlevel);
	}
	else
	{
		Msg(playerid, YELLOW, " >  Lookup type must be one of: 'i'(ip) 'p'(password) 'h'(hash) 'a'(all)");
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
		if(list[0][alias_Banned])
			strcat(string, C_RED);

		else
			strcat(string, C_ORANGE);

		strcat(string, list[0][alias_Name]);
	}

	if(count > 1)
	{
		for(new i; i < count; i++)
		{
			if(i >= 6)
				break;

			if(list[i][alias_Banned])
				strcat(string, C_RED);

			else
				strcat(string, C_ORANGE);

			strcat(string, list[i][alias_Name]);

			if(i < count - 1)
				strcat(string, ", ");
		}
	}

	if(adminlevel <= GetPlayerAdminLevel(playerid))
	{
		MsgF(playerid, YELLOW, " >  Aliases: "C_BLUE"(%d) %s", count, string);
	}
	else
	{
		MsgF(playerid, YELLOW, " >  No aliases found for %s", name);
	}

	return 1;
}
