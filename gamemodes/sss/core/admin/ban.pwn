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


hook OnGameModeInit()
{
	//
}

BanPlayer(playerid, reason[], byid, duration)
{
	new
		name_banned[MAX_PLAYER_NAME],
		name_by[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name_banned, MAX_PLAYER_NAME);

	if(byid == -1)
		name_by = "Server";

	else
		GetPlayerName(byid, name_by, MAX_PLAYER_NAME);

	BanIO_Create(name_banned,
		GetPlayerIpAsInt(playerid),
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
		ip,
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
		GetAccountIP(name, ip);
	}
	else
	{
		ip = GetPlayerIpAsInt(id);
		ChatMsgLang(id, YELLOW, "BANNEDMESSG", reason);
		defer KickPlayerDelay(id);
	}

	BanIO_Create(name_banned,
		ip,
		gettime(),
		reason,
		name_by,
		duration);

	return 1;
}

UpdateBanInfo(name[], reason[], duration)
{
	BanIO_UpdateReasonDuration(name, reason, duration);
	
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
		BanIO_ShowBanInfo(playerid, "OnBanResult");
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

	new string[256];

	format(string, 256, "\
		"C_YELLOW"Date:\n\t\t"C_BLUE"%s\n\n\
		"C_YELLOW"Reason:\n\t\t"C_BLUE"%s\n\n\
		"C_YELLOW"Unban:\n\t\t"C_BLUE"%s",
		TimestampToDateTime(timestamp),
		reason,
		duration ? (TimestampToDateTime(timestamp + duration)) : "Never");

	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Banned", string, "Close", "");

	BanIO_UpdateIpv4(name, GetPlayerIpAsInt(playerid));

	defer KickPlayerDelay(playerid);

	return 0;
}


/*==============================================================================

	Interface functions

==============================================================================*/


stock IsPlayerBanned(name[])
{
	// redis get account property "banned"
	return 0;
}

stock GetBanList(string[][MAX_PLAYER_NAME], limit, offset)
{
	// BanIO_GetList
	return 0;
}

stock GetTotalBans()
{
	new total;

	return total;
}

stock GetBanInfo(name[], &timestamp, reason[], bannedby[], &duration)
{
	// BanGetInfo, FIELD_ID_BANS_DATE, DB::TYPE_INTEGER, timestamp);
	// BanGetInfo, FIELD_ID_BANS_REASON, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	// BanGetInfo, FIELD_ID_BANS_BY, DB::TYPE_STRING, bannedby, MAX_PLAYER_NAME);
	// BanGetInfo, FIELD_ID_BANS_DURATION, DB::TYPE_INTEGER, duration);

	return 1;
}

stock SetBanIpv4(name[], ipv4)
{
	// BanSetIpv4, 0, DB::TYPE_INTEGER, ipv4);
	// BanSetIpv4, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return 0;
}

stock SetBanReason(name[], reason[])
{
	// BanSetReason, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON
	// BanSetReason, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME

	return 0;
}

stock SetBanDuration(name[], duration)
{
	// BanSetDuration, 0, DB::TYPE_INTEGER, duration
	// BanSetDuration, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME

	return 0;
}
