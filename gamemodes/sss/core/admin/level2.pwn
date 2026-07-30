/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/duty - go on admin duty\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/goto, /get - teleport players\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/gotopos - go to coordinates\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/(un)freeze - freeze/unfreeze player\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/(un)ban - ban/unban player\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/banlist - show list of bans\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/banned - check if banned\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/setmotd - set message of the day\n");
}


/*==============================================================================

	Enter admin duty mode, disabling normal gameplay mechanics

==============================================================================*/


ACMD:duty[2](playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
	{
		ChatMsg(playerid, YELLOW, " >  You cannot do that while spectating.");
		return 1;
	}

	if(IsPlayerOnAdminDuty(playerid))
		TogglePlayerAdminDuty(playerid, false);

	else
		TogglePlayerAdminDuty(playerid, true);

	return 1;
}


/*==============================================================================

	Teleport players to other players or yourself to 

==============================================================================*/


ACMD:goto[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	new targetid;

	if(sscanf(params, "u", targetid))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /goto [target]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	TeleportPlayerToPlayer(playerid, targetid);

	ChatMsg(playerid, YELLOW, " >  You have teleported to %P", targetid);
	ChatMsgLang(targetid, YELLOW, "TELEPORTEDT", playerid);

	return 1;
}

ACMD:get[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	new targetid;

	if(sscanf(params, "u", targetid))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /get [target]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	TeleportPlayerToPlayer(targetid, playerid);

	ChatMsg(playerid, YELLOW, " >  You have teleported %P", targetid);
	ChatMsgLang(targetid, YELLOW, "TELEPORTEDY", playerid);

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
		return ChatMsg(playerid, YELLOW, "Usage: /gotopos x, y, z (With or without commas)");

	ChatMsg(playerid, YELLOW, " >  Teleported to %f, %f, %f", x, y, z);
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
		return ChatMsg(playerid, YELLOW, " >  Usage: /freeze [playerid] (seconds)");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	FreezePlayer(targetid, delay * 1000, true);
	
	if(delay > 0)
	{
		ChatMsg(playerid, YELLOW, " >  Frozen %P for %d seconds", targetid, delay);
		ChatMsgLang(targetid, YELLOW, "FREEZETIMER", delay);
	}
	else
	{
		ChatMsg(playerid, YELLOW, " >  Frozen %P (performing 'mod_sa' check)", targetid);
		ChatMsgLang(targetid, YELLOW, "FREEZEFROZE");
	}

	return 1;
}

ACMD:unfreeze[2](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))
		return ChatMsg(playerid, YELLOW, " >  Usage: /unfreeze [playerid]");

	if(!IsPlayerConnected(targetid))
		return 4;

	UnfreezePlayer(targetid);

	ChatMsg(playerid, YELLOW, " >  Unfrozen %P", targetid);
	ChatMsgLang(targetid, YELLOW, "FREEZEUNFRE");

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
		ChatMsg(playerid, YELLOW, " >  Usage: /ban [playerid/name]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		else
			ChatMsg(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, YELLOW, " >  The account '%s' does not exist.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > STAFF_LEVEL_NONE)
		return 2;

	BanAndEnterInfo(playerid, name);

	ChatMsg(playerid, YELLOW, " >  Preparing ban for %s", name);

	return 1;
}

ACMD:unban[2](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name))
		return ChatMsg(playerid, YELLOW, " >  Usage: /unban [player name]");

	if(UnBanPlayer(name))
		ChatMsg(playerid, YELLOW, " >  Unbanned "C_BLUE"%s"C_YELLOW".", name);

	else
		ChatMsg(playerid, YELLOW, " >  Player '%s' is not banned.");

	return 1;
}


/*==============================================================================

	Show the list of banned players and check if someone is banned

==============================================================================*/


ACMD:banlist[2](playerid, params[])
{
	new ret = ShowListOfBans(playerid, 0);

	if(ret == 0)
		ChatMsg(playerid, YELLOW, " >  No bans to list.");

	if(ret == -1)
		ChatMsg(playerid, YELLOW, " >  An error occurred while executing 'stmt_BanGetList'.");

	return 1;
}

ACMD:banned[2](playerid, params[])
{
	if(!(3 < strlen(params) < MAX_PLAYER_NAME))
	{
		ChatMsg(playerid, RED, " >  Invalid player name '%s'.", params);
		return 1;
	}

	new name[MAX_PLAYER_NAME];

	strcat(name, params);

	if(IsPlayerBanned(name))
		ShowBanInfo(playerid, name);

	else
		ChatMsg(playerid, YELLOW, " >  Player '%s' "C_BLUE"isn't "C_YELLOW"banned.", name);

	return 1;
}


/*==============================================================================

	Set the message of the day

==============================================================================*/


ACMD:setmotd[2](playerid, params[])
{
	if(sscanf(params, "s[128]", gMessageOfTheDay))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /setmotd [message]");
		return 1;
	}

	ChatMsgAll(YELLOW, " >  MOTD updated: "C_BLUE"%s", gMessageOfTheDay);

	return 1;
}
