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
#define ACCOUNTS_TABLE_BANS			"Bans"
#define FIELD_BANS_NAME				"name"		// 00
#define FIELD_BANS_IPV4				"ipv4"		// 01
#define FIELD_BANS_DATE				"date"		// 02
#define FIELD_BANS_REASON			"reason"	// 03
#define FIELD_BANS_BY				"by"		// 04
#define FIELD_BANS_DURATION			"duration"	// 05
#define FIELD_BANS_ACTIVE			"active"	// 06

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
	new name[MAX_PLAYER_NAME];

	if(byid == -1)
		name = "Server";

	else
		GetPlayerName(byid, name, MAX_PLAYER_NAME);

	// BanInsert, 0, DB::TYPE_PLAYER_NAME, playerid
	// BanInsert, 1, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid)
	// BanInsert, 2, DB::TYPE_INTEGER, gettime()
	// BanInsert, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON
	// BanInsert, 4, DB::TYPE_STRING, name, MAX_PLAYER_NAME
	// BanInsert, 5, DB::TYPE_INTEGER, duration

	ChatMsgLang(playerid, YELLOW, "BANNEDMESSG", reason);
	defer KickPlayerDelay(playerid);

	return 0;
}

BanPlayerByName(name[], reason[], byid, duration)
{
	new
		forname[MAX_PLAYER_NAME],
		id = INVALID_PLAYER_ID,
		ip,
		byname[MAX_PLAYER_NAME];

	if(byid == -1)
		byname = "Server";

	else
		GetPlayerName(byid, byname, MAX_PLAYER_NAME);

	foreach(new i : Player)
	{
		GetPlayerName(i, forname, MAX_PLAYER_NAME);

		if(!strcmp(forname, name))
			id = i;
	}

	if(id == INVALID_PLAYER_ID)
	{
		GetAccountIP(name, ip);
	}
	else
	{
		ip = GetPlayerIpAsInt(id);
		defer KickPlayerDelay(id);
	}

	// BanInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME
	// BanInsert, 1, DB::TYPE_INTEGER, ip
	// BanInsert, 2, DB::TYPE_INTEGER, gettime()
	// BanInsert, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON
	// BanInsert, 4, DB::TYPE_STRING, byname, MAX_PLAYER_NAME
	// BanInsert, 5, DB::TYPE_INTEGER, duration

	return 1;
}

UpdateBanInfo(name[], reason[], duration)
{
	// BanUpdateInfo, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON
	// BanUpdateInfo, 1, DB::TYPE_INTEGER, duration
	// BanUpdateInfo, 2, DB::TYPE_STRING, name, MAX_PLAYER_NAME
	
	return 0;
}

UnBanPlayer(name[])
{
	if(!IsPlayerBanned(name))
		return 0;

	// BanUnban, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return 0;
}

BanCheck(playerid)
{
	new
		banned,
		timestamp,
		reason[MAX_BAN_REASON],
		duration;

	// BanGetFromNameIp, 0, DB::TYPE_PLAYER_NAME, playerid
	// BanGetFromNameIp, 1, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid)

	// BanGetFromNameIp, 0, DB::TYPE_INTEGER, banned
	// BanGetFromNameIp, 1, DB::TYPE_INTEGER, timestamp
	// BanGetFromNameIp, 2, DB::TYPE_STRING, reason, MAX_BAN_REASON
	// BanGetFromNameIp, 3, DB::TYPE_INTEGER, duration

	if(banned)
	{
		if(duration > 0)
		{
			if(gettime() > (timestamp + duration))
			{
				new name[MAX_PLAYER_NAME];
				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
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

		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Banned", string, "Close", "");

		// BanSetIpv4, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
		// BanSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);

		defer KickPlayerDelay(playerid);

		return 1;
	}

	return 0;
}


/*==============================================================================

	Interface functions

==============================================================================*/


forward external_BanPlayer(name[], reason[], duration);
public external_BanPlayer(name[], reason[], duration)
{
	BanPlayerByName(name, reason, -1, duration);
}

stock IsPlayerBanned(name[])
{
	return 0;
}

stock GetBanList(string[][MAX_PLAYER_NAME], limit, offset)
{
	// new name[MAX_PLAYER_NAME];

	// BanGetList, 0, DB::TYPE_INTEGER, offset
	// BanGetList, 1, DB::TYPE_INTEGER, limit
	// BanGetList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME

	new idx;
/*
	while()
	{
		string[idx] = name;
		idx++;
	}
*/
	return idx;
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
