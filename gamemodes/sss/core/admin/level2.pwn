/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Admin/Level2'...");

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

	Teleport players to other players or yourself to 

==============================================================================*/


ACMD:goto[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	new targetid;

	if(sscanf(params, "u", targetid))
	{
		Msg(playerid, YELLOW, " >  Usage: /goto [target]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	TeleportPlayerToPlayer(playerid, targetid);

	MsgF(playerid, YELLOW, " >  You have teleported to %P", targetid);
	MsgF(targetid, YELLOW, " >  %P"C_YELLOW" Has teleported to you", playerid);

	return 1;
}

ACMD:get[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	new targetid;

	if(sscanf(params, "u", targetid))
	{
		Msg(playerid, YELLOW, " >  Usage: /get [target]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	TeleportPlayerToPlayer(targetid, playerid);

	MsgF(playerid, YELLOW, " >  You have teleported %P", targetid);
	MsgF(targetid, YELLOW, " >  %P"C_YELLOW" Has teleported you", playerid);

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

	FreezePlayer(targetid, delay * 1000, true);
	
	if(delay > 0)
	{
		MsgF(playerid, YELLOW, " >  Frozen %P for %d seconds", targetid, delay);
		MsgF(targetid, YELLOW, " >  Frozen by admin for %d seconds", delay);
	}
	else
	{
		MsgF(playerid, YELLOW, " >  Frozen %P (performing 'mod_sa' check)", targetid);
		Msg(targetid, YELLOW, " >  Frozen by admin");
	}

	return 1;
}

ACMD:unfreeze[2](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))
		return Msg(playerid, YELLOW, " >  Usage: /unfreeze [playerid]");

	if(!IsPlayerConnected(targetid))
		return 4;

	UnfreezePlayer(targetid);

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

	if(GetAdminLevelByName(name) > STAFF_LEVEL_NONE)
		return 2;

	BanAndEnterInfo(playerid, name);

	MsgF(playerid, YELLOW, " >  Preparing ban for %s", name);

	return 1;
}

ACMD:unban[2](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

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
	new ret = ShowListOfBans(playerid, 0);

	if(ret == 0)
		Msg(playerid, YELLOW, " >  No bans to list.");

	if(ret == -1)
		Msg(playerid, YELLOW, " >  An error occurred while executing 'stmt_BanGetList'.");

	return 1;
}

ACMD:banned[2](playerid, params[])
{
	if(!(3 < strlen(params) < MAX_PLAYER_NAME))
	{
		MsgF(playerid, RED, " >  Invalid player name '%s'.", params);
		return 1;
	}

	new name[MAX_PLAYER_NAME];

	strcat(name, params);

	if(IsPlayerBanned(name))
		ShowBanInfo(playerid, name);

	else
		MsgF(playerid, YELLOW, " >  Player '%s' "C_BLUE"isn't "C_YELLOW"banned.", name);

	return 1;
}


/*==============================================================================

	Set the message of the day

==============================================================================*/


ACMD:setmotd[2](playerid, params[])
{
	if(sscanf(params, "s[128]", gMessageOfTheDay))
	{
		Msg(playerid, YELLOW, " >  Usage: /setmotd [message]");
		return 1;
	}

	MsgAllF(YELLOW, " >  MOTD updated: "C_BLUE"%s", gMessageOfTheDay);

	return 1;
}
