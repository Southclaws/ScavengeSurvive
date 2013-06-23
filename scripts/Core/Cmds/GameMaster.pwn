// 8 commands

new gAdminCommandList_Lvl1[] =
{
	"/kick - kick a player from the server\n\
	/(un)freeze - freeze/unfreeze a player\n\
	/(un)mute - mute/unmute a player\n\
	/warn - give a player a warning\n\
	/msg - send a chat announcement\n\
	/unstick - move a player upwards (Duty only)"
};

new
	Timer:UnfreezeTimer[MAX_PLAYERS],
	Timer:UnmuteTimer[MAX_PLAYERS],
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
		MsgAllF(PINK, " >  %P"#C_PINK" failed and kicked themselves", playerid);

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
	t:bPlayerGameSettings[targetid]<Frozen>;
	
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
	f:bPlayerGameSettings[playerid]<Frozen>;

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
	f:bPlayerGameSettings[targetid]<Frozen>;
	stop UnfreezeTimer[targetid];

	MsgF(playerid, YELLOW, " >  Unfrozen %P", targetid);
	Msg(playerid, YELLOW, " >  Unfrozen");

	return 1;
}


ACMD:mute[1](playerid, params[])
{
	new
		targetid,
		delay,
		reason[128];


	if(sscanf(params, "dds[128]", targetid, delay, reason))
		return Msg(playerid,YELLOW," >  Usage: /mute [playerid] [seconds] [reason]");

	if(!IsPlayerConnected(targetid))
		return Msg(playerid,RED, " >  Invalid targetid");

	if(gPlayerData[targetid][ply_Admin] >= gPlayerData[playerid][ply_Admin])
		return 3;

	if(bPlayerGameSettings[targetid] & Muted)
		return Msg(playerid, YELLOW, " >  Player Already Muted");

	t:bPlayerGameSettings[targetid]<Muted>;

	if(delay > 0)
	{
		stop UnmuteTimer[targetid];
		UnmuteTimer[targetid] = defer CmdDelay_unmute(targetid, delay * 1000);
		MsgF(targetid, YELLOW, " >  Muted from global chat for "#C_ORANGE"%d "#C_YELLOW"seconds, Reason: "#C_BLUE"%s", delay, reason);
		MsgF(playerid, YELLOW, " >  Muted player %P "#C_WHITE"for %d seconds.", targetid, delay);
	}
	else
	{
		MsgF(targetid, YELLOW, " >  Muted from global chat, Reason: "#C_BLUE"%s", reason);
		MsgF(playerid, YELLOW, " >  Muted player %P", targetid);
	}

	return 1;
}

timer CmdDelay_unmute[time](playerid, time)
{
	#pragma unused time
	
	f:bPlayerGameSettings[playerid]<Muted>;

	Msg(playerid, YELLOW, " >  You are now un-muted.");

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

	f:bPlayerGameSettings[targetid]<Muted>;
	stop UnmuteTimer[targetid];

	MsgF(playerid, YELLOW, " >  Un-muted %P", targetid);
	MsgF(targetid, YELLOW, " >  %P"#C_YELLOW" has un-muted you.", targetid);

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

	gPlayerWarnings[targetid]++;

	MsgF(playerid, ORANGE, " >  %P"#C_YELLOW" Has been warned (%d/5) for: %s", targetid, gPlayerWarnings[targetid], reason);
	MsgF(targetid, ORANGE, " >  You been warned (%d/5) for: %s", gPlayerWarnings[targetid], reason);

	if(gPlayerWarnings[targetid] >= 5)
	{
		BanPlayer(targetid, "Getting 5 warnings", playerid);
	}

	return 1;
}


ACMD:msg[1](playerid, params[])
{
	if(!(0 < strlen(params) < 128))
		Msg(playerid,YELLOW," >  Usage: /msg [Message]");

	new str[130] = {" >  "#C_BLUE""};

	strcat(str, TagScan(params));

	MsgAll(YELLOW, str);
	return 1;
}


ACMD:unstick[1](playerid, params[])
{
	if(!(bPlayerGameSettings[playerid] & AdminDuty))
		return 6;

	if(tickcount() - tick_UnstickUsage[playerid] < 1000)
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

	tick_UnstickUsage[playerid] = tickcount();

	return 1;
}
