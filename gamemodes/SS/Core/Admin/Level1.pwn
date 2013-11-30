// 5 commands

new gAdminCommandList_Lvl1[] =
{
	"/(un)mute - mute/unmute player\n\
	/warn - warn a player\n\
	/msg - send chat announcement\n\
	/(all)country - show country data\n\
	/clearchat - clear the chatbox\n"
};


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

	if(gPlayerData[targetid][ply_Admin] >= gPlayerData[playerid][ply_Admin])
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

	if(gPlayerData[targetid][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	TogglePlayerMute(targetid, false);

	MsgF(playerid, YELLOW, " >  Un-muted %P", targetid);
	Msg(targetid, YELLOW, " >  You are now un-muted.");

	return 1;
}

ACMD:warn[1](playerid, params[])
{
	new
		targetid,
		reason[128];

	if(sscanf(params, "ds[128]", targetid, reason))
		return Msg(playerid, YELLOW, " >  Usage: /warn [playerid] [reason]");

	if(!IsPlayerConnected(targetid))
		return Msg(playerid,RED, " >  Invalid targetid");

	if(gPlayerData[targetid][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != targetid)
		return 3;

	gPlayerData[targetid][ply_Warnings]++;

	MsgF(playerid, ORANGE, " >  %P"C_YELLOW" Has been warned (%d/5) for: %s", targetid, gPlayerData[targetid][ply_Warnings], reason);
	MsgF(targetid, ORANGE, " >  You been warned (%d/5) for: %s", gPlayerData[targetid][ply_Warnings], reason);

	if(gPlayerData[targetid][ply_Warnings] >= 5)
	{
		BanPlayer(targetid, "Getting 5 warnings", playerid, 86400);
	}

	return 1;
}

ACMD:msg[1](playerid, params[])
{
	if(!(0 < strlen(params) < 128))
		Msg(playerid,YELLOW," >  Usage: /msg [Message]");

	new str[130] = {" >  "C_BLUE""};

	strcat(str, TagScan(params));

	MsgAll(YELLOW, str);
	return 1;
}

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

	if(gPlayerData[id][ply_Admin] > gPlayerData[playerid][ply_Admin])
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
		if(gPlayerData[i][ply_Admin] > gPlayerData[playerid][ply_Admin])
			country = "Unknown";

		else
			GetPlayerCountry(i, country);

		format(list, sizeof(list), "%s%p - %s\n", list, i, country);
	}

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_LIST, "Countries", list, "Close", "");

	return 1;
}

ACMD:clearchat[1](playerid, params[])
{
	for(new i;i<100;i++)
		MsgAll(WHITE, " ");

	return 1;
}
