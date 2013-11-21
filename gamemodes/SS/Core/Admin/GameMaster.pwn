// 9 commands

new gAdminCommandList_Lvl1[] =
{
	"/kick - kick from the server\n\
	/(un)freeze - freeze/unfreeze player\n\
	/(un)mute - mute/unmute player\n\
	/warn - warn a player\n\
	/msg - send chat announcement\n\
	/unstick - move player up\n\
	/spec - spectate\n\
	/(all)country - show country data"
};

new
	Timer:UnfreezeTimer[MAX_PLAYERS],
	tick_UnstickUsage[MAX_PLAYERS];


ACMD:kick[1](playerid, params[])
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


ACMD:freeze[1](playerid, params[])
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

ACMD:unfreeze[1](playerid, params[])
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


ACMD:unstick[1](playerid, params[])
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

ACMD:spec[1](playerid, params[])
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
