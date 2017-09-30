/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/(un)mute - mute/unmute player\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/warn - warn a player\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/kick - kick player\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/msg - send chat announcement\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/(all)country - show country data\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/clearchat - clear the chatbox\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/aliases - check aliases\n");
}


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
		return ChatMsg(playerid,YELLOW," >  Usage: /mute [playerid] [seconds] [reason] - use -1 as a seconds duration for a permanent mute.");

	if(!IsPlayerConnected(targetid))
		return ChatMsg(playerid,RED, " >  Invalid targetid");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid))
		return 3;

	if(IsPlayerMuted(targetid))
		return ChatMsg(playerid, YELLOW, " >  Player Already Muted");

	if(delay > 0)
	{
		TogglePlayerMute(targetid, true, delay);
		ChatMsg(playerid, YELLOW, " >  Muted player %P "C_WHITE"for %d seconds.", targetid, delay);
		ChatMsgLang(targetid, YELLOW, "MUTEDANTIME", delay, reason);
	}
	else
	{
		TogglePlayerMute(targetid, true);
		ChatMsg(playerid, YELLOW, " >  Muted player %P", targetid);
		ChatMsgLang(targetid, YELLOW, "MUTEDREASON", reason);
	}

	return 1;
}

ACMD:unmute[1](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))
		return ChatMsg(playerid, YELLOW, " >  Usage: /unmute [playerid]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	TogglePlayerMute(targetid, false);

	ChatMsg(playerid, YELLOW, " >  Un-muted %P", targetid);
	ChatMsgLang(targetid, YELLOW, "MUTEDUNMUTE");

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
		return ChatMsg(playerid, YELLOW, " >  Usage: /warn [playerid] [reason]");

	if(!IsPlayerConnected(targetid))
		return ChatMsg(playerid,RED, " >  Invalid targetid");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	new warnings = GetPlayerWarnings(targetid) + 1;

	SetPlayerWarnings(targetid, warnings);

	ChatMsg(playerid, ORANGE, " >  %P"C_YELLOW" Has been warned (%d/5) for: %s", targetid, warnings, reason);
	ChatMsgLang(targetid, ORANGE, "WARNEDMESSG", warnings, reason);

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
		return ChatMsg(playerid, YELLOW, " >  Usage: /kick [playerid] [reason]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	if(GetPlayerAdminLevel(playerid) != GetPlayerAdminLevel(highestadmin))
		return ChatMsg(highestadmin, YELLOW, " >  %p kick request: (%d)%p reason: %s", playerid, targetid, targetid, reason);

	if(playerid == targetid)
		ChatMsgAll(PINK, " >  %P"C_PINK" failed and kicked themselves", playerid);

	KickPlayer(targetid, reason);

	return 1;
}


/*==============================================================================

	Output a non-player chat box message to all players in the server

==============================================================================*/


ACMD:msg[1](playerid, params[])
{
	if(!(0 < strlen(params) < 128))
		ChatMsg(playerid,YELLOW," >  Usage: /msg [Message]");

	new str[130] = {" >  "C_BLUE""};

	strcat(str, TagScan(params));

	ChatMsgAll(YELLOW, str);
	return 1;
}


/*==============================================================================

	Display player countries

==============================================================================*/


ACMD:country[1](playerid, params[])
{
	if(isnumeric(params))
	{
		new targetid = strval(params);

		if(!IsPlayerConnected(targetid))
		{
			if(targetid > 99)
				ChatMsg(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);

			else
				return 4;
		}

		new data[256];

		GetPlayerCountryDataAsString(targetid, data);

		ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "IP Data", data, "Close", "");
	}
	else
	{
		if(!AccountExists(params))
		{
			ChatMsg(playerid, YELLOW, " >  The account '%s' does not exist.", params);
			return 1;
		}

		new
			ipv4[16],
			country[32];

		GetAccountIP(params, ipv4);
		GetIPCountry(ipv4, country);

		ChatMsg(playerid, YELLOW, " >  "C_BLUE"%s"C_YELLOW"'s GeoIP location: "C_BLUE"%s", params, country);
	}

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
			GetPlayerCachedCountryName(i, country);

		format(list, sizeof(list), "%s%p - %s\n", list, i, country);
	}

	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_LIST, "Countries", list, "Close", "");

	return 1;
}


/*==============================================================================

	Clear the chat box

==============================================================================*/


ACMD:clearchat[1](playerid, params[])
{
	for(new i;i<100;i++)
		ChatMsgAll(WHITE, " ");

	return 1;
}


/*==============================================================================

	Display a player's aliases (other accounts they have used)

==============================================================================*/


ACMD:aliases[1](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		type;

	if(sscanf(params, "s[24]C(a)", name, type))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /aliases [playerid/name] [i/p/h/a]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		else if(targetid > 99)
			ChatMsg(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);

		else
			return 4;
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, YELLOW, " >  The account '%s' does not exist.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > GetPlayerAdminLevel(playerid))
	{
		new playername[MAX_PLAYER_NAME];

		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(strcmp(name, playername))
		{
			ChatMsg(playerid, YELLOW, " >  No aliases found for %s", name);
			return 1;
		}
	}

	//

	return 1;
}

ACMD:history[1](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		type,
		lookup;

	if(sscanf(params, "s[24]C(a)C()", name, type, lookup))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /history [playerid/name] [i/h] [n]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		else if(targetid > 99)
			ChatMsg(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);

		else
			return 4;
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, YELLOW, " >  The account '%s' does not exist.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > GetPlayerAdminLevel(playerid))
	{
		new playername[MAX_PLAYER_NAME];

		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(strcmp(name, playername))
		{
			ChatMsg(playerid, YELLOW, " >  No aliases found for %s", name);
			return 1;
		}
	}

	//

	return 1;
}
