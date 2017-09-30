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


#define MAX_BAN_REASON (128)


enum
{
	FIELD_ID_BANS_NAME,
	FIELD_ID_BANS_IPV4,
	FIELD_ID_BANS_DATE,
	FIELD_ID_BANS_REASON,
	FIELD_ID_BANS_BY,
	FIELD_ID_BANS_DURATION,
	FIELD_ID_BANS_ACTIVE
}


forward OnBanResult(playerid, bool:banned, timestamp, reason[], duration);


hook OnGameModeInit()
{
	//
}

BanPlayer(playerid, reason[], byid, duration)
{
	new
		name_banned[MAX_PLAYER_NAME],
		name_by[MAX_PLAYER_NAME],
		ipv4[16];

	GetPlayerName(playerid, name_banned, MAX_PLAYER_NAME);
	GetPlayerIp(playerid, ipv4, 16);

	if(byid == -1)
		name_by = "Server";

	else
		GetPlayerName(byid, name_by, MAX_PLAYER_NAME);

	BanIO_Create(name_banned,
		ipv4,
		gettime(),
		reason,
		name_by,
		duration);

	ChatMsgLang(playerid, YELLOW, "BANNEDMESSG", reason);
	defer KickPlayerDelay(playerid);

	return 0;
}

BanPlayerByName(name[], reason[], byid, duration)
{
	new
		name_banned[MAX_PLAYER_NAME],
		id = INVALID_PLAYER_ID,
		ipv4[16],
		name_by[MAX_PLAYER_NAME];

	if(byid == -1)
		name_by = "Server";

	else
		GetPlayerName(byid, name_by, MAX_PLAYER_NAME);

	foreach(new i : Player)
	{
		GetPlayerName(i, name_banned, MAX_PLAYER_NAME);

		if(!strcmp(name_banned, name))
			id = i;
	}

	if(id == INVALID_PLAYER_ID)
	{
		GetAccountIP(name, ipv4);
	}
	else
	{
		GetPlayerIp(id, ipv4, sizeof(ipv4));
		ChatMsgLang(id, YELLOW, "BANNEDMESSG", reason);
		defer KickPlayerDelay(id);
	}

	BanIO_Create(name_banned,
		ipv4,
		gettime(),
		reason,
		name_by,
		duration);

	return 1;
}

UpdateBanInfo(name[], reason[], duration)
{
	BanIO_UpdateReason(name, reason);
	BanIO_UpdateDuration(name, duration);
	
	return 0;
}

UnBanPlayer(name[])
{
	if(!IsPlayerBanned(name))
		return 0;

	BanIO_Remove(name);

	return 0;
}

hook OnPlayerConnect(playerid)
{
	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	if(IsPlayerBanned(name))
	{
		BanIO_GetInfo(playerid, name, "OnBanResult");
	}
}

public OnBanResult(playerid, bool:banned, timestamp, reason[], duration)
{
	if(!banned)
		return 0;

	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	if(duration > 0)
	{
		if(gettime() > (timestamp + duration))
		{
			UnBanPlayer(name);

			ChatMsgLang(playerid, YELLOW, "BANLIFMESSG", TimestampToDateTime(timestamp));
			log("[UNBAN] Ban lifted automatically for %s", name);

			return 0;
		}
	}

	new
		ipv4[16],
		string[256];

	GetPlayerIp(playerid, ipv4, 16);
	format(string, 256, "\
		"C_YELLOW"Date:\n\t\t"C_BLUE"%s\n\n\
		"C_YELLOW"Reason:\n\t\t"C_BLUE"%s\n\n\
		"C_YELLOW"Unban:\n\t\t"C_BLUE"%s",
		TimestampToDateTime(timestamp),
		reason,
		duration ? (TimestampToDateTime(timestamp + duration)) : "Never");

	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Banned", string, "Close", "");

	BanIO_UpdateIpv4(name, ipv4);

	defer KickPlayerDelay(playerid);

	return 0;
}


/*==============================================================================

	Interface functions

==============================================================================*/


stock IsPlayerBanned(name[])
{
	new banned;
	GetAccountBannedState(name, banned);
	return banned;
}

stock GetBanList(playerid, limit, offset, callback[])
{
	return BanIO_GetList(playerid, limit, offset, callback);
}

stock GetBanInfo(playerid, name[], callback[])
{
	return BanIO_GetInfo(playerid, name, callback);
}

stock SetBanIpv4(name[], ipv4[])
{
	return BanIO_UpdateIpv4(name, ipv4);
}

stock SetBanReason(name[], reason[])
{
	return BanIO_UpdateReason(name, reason);
}

stock SetBanDuration(name[], duration)
{
	return BanIO_UpdateDuration(name, duration);
}
