// 9 commands

new gAdminCommandList_Lvl2[] =
{
	"/duty - go on admin duty\n\
	/spec - spectate\n\
	/tp - teleport players or positions\n\
	/gotopos - go to coordinates\n\
	/(un)freeze - freeze/unfreeze player\n\
	/(un)ban - ban/unban player\n\
	/banlist - show list of bans\n\
	/isbanned - check if banned\n\
	/motd - set message of the day\n"
};


static
	Timer:UnfreezeTimer[MAX_PLAYERS],
	tick_UnstickUsage[MAX_PLAYERS];


/*==============================================================================

	Enter admin duty mode, disabling normal gameplay mechanics

==============================================================================*/


ACMD:duty[2](playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
	{
		Msg(playerid, YELLOW, " >  You cannot do that while spectating.");
		return 1;
	}

	if(IsPlayerOnAdminDuty(playerid))
		TogglePlayerAdminDuty(playerid, false);

	else
		TogglePlayerAdminDuty(playerid, true);

	return 1;
}


/*==============================================================================

	Enter spectate mode on a specific player

==============================================================================*/


ACMD:spec[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)))
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
			if(GetPlayerAdminLevel(playerid) == 1)
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

ACMD:recam[2](playerid, params[])
{
	SetCameraBehindPlayer(playerid);
	return 1;
}


/*==============================================================================

	Teleport players to other players or yourself to 

==============================================================================*/


ACMD:tp[2](playerid, params[])
{
	if(GetPlayerAdminLevel(playerid) < 4)
	{
		if(!(IsPlayerOnAdminDuty(playerid)))
			return 6;
	}

	if(GetTickCountDifference(GetTickCount(), tick_UnstickUsage[playerid]) < 1000)
	{
		Msg(playerid, RED, " >  You cannot use that command that often.");
		return 1;
	}

	new
		targetid,
		command[6];

	if(sscanf(params, "uS()", targetid, command))
	{
		Msg(playerid, YELLOW, " >  Usage: /tp [target] [optional:'to me']");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	if(!isnull(command))
	{
		if(!strcmp(command, "to me", true))
		{
			TeleportPlayerToPlayer(targetid, playerid);

			MsgF(playerid, YELLOW, " >  %P"C_YELLOW" Has teleported to you", targetid);
			MsgF(targetid, YELLOW, " >  You have teleported to %P", playerid);

			return 1;
		}
	}

	TeleportPlayerToPlayer(playerid, targetid);

	MsgF(playerid, YELLOW, " >  You have teleported to %P", targetid);
	MsgF(targetid, YELLOW, " >  %P"C_YELLOW" Has teleported to you", playerid);

	return 1;
}


/*==============================================================================

	Teleport to a specific position

==============================================================================*/


ACMD:gotopos[2](playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	if(sscanf(params, "fff", x, y, z) && sscanf(params, "p<,>fff", x, y, z))
		return Msg(playerid, YELLOW, "Usage: /gotopos x, y, z (With or without commas)");

	MsgF(playerid, YELLOW, " >  Teleported to %f, %f, %f", x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}


/*==============================================================================

	Freeze a player for questioning/investigation

==============================================================================*/


ACMD:freeze[2](playerid, params[])
{
	new targetid, delay;

	if(sscanf(params, "dD(0)", targetid, delay))
		return Msg(playerid, YELLOW, " >  Usage: /freeze [playerid] (seconds)");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	TogglePlayerControllable(targetid, false);
	SetPlayerBitFlag(targetid, Frozen, true);
	
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
	SetPlayerBitFlag(playerid, Frozen, false);

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
	SetPlayerBitFlag(targetid, Frozen, false);
	stop UnfreezeTimer[targetid];

	MsgF(playerid, YELLOW, " >  Unfrozen %P", targetid);
	Msg(targetid, YELLOW, " >  Unfrozen");

	return 1;
}


/*==============================================================================

	Ban a player from the server for a set time or forever

==============================================================================*/


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


/*==============================================================================

	Show the list of banned players and check if someone is banned

==============================================================================*/


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
		MsgF(playerid, YELLOW, " >  Player '%s' "C_BLUE"is "C_YELLOW"banned.", params);

	else
		MsgF(playerid, YELLOW, " >  Player '%s' "C_BLUE"isn't "C_YELLOW"banned.", params);

	return 1;
}


/*==============================================================================

	Set the message of the day

==============================================================================*/


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
