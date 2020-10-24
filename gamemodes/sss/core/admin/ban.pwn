/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


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


static
DBStatement:	stmt_BanInsert,
DBStatement:	stmt_BanUnban,
DBStatement:	stmt_BanGetFromNameIp,
DBStatement:	stmt_BanNameCheck,
DBStatement:	stmt_BanGetList,
DBStatement:	stmt_BanGetTotal,
DBStatement:	stmt_BanGetInfo,
DBStatement:	stmt_BanUpdateInfo,
DBStatement:	stmt_BanSetIpv4,
DBStatement:	stmt_BanSetReason,
DBStatement:	stmt_BanSetDuration;


hook OnGameModeInit()
{
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_BANS" (\
		"FIELD_BANS_NAME" TEXT,\
		"FIELD_BANS_IPV4" INTEGER,\
		"FIELD_BANS_DATE" INTEGER,\
		"FIELD_BANS_REASON" TEXT,\
		"FIELD_BANS_BY" TEXT,\
		"FIELD_BANS_DURATION" INTEGER,\
		"FIELD_BANS_ACTIVE" INTEGER)"));

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_BANS, 7);

	stmt_BanInsert				= db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_BANS" VALUES(?, ?, ?, ?, ?, ?, 1)");
	stmt_BanUnban				= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_BANS" SET "FIELD_BANS_ACTIVE"=0 WHERE "FIELD_BANS_NAME" = ? COLLATE NOCASE");
	stmt_BanGetFromNameIp		= db_prepare(gAccounts, "SELECT COUNT(*), "FIELD_BANS_DATE", "FIELD_BANS_REASON", "FIELD_BANS_DURATION" FROM "ACCOUNTS_TABLE_BANS" WHERE ("FIELD_BANS_NAME" = ? COLLATE NOCASE OR "FIELD_BANS_IPV4" = ?) AND "FIELD_BANS_ACTIVE"=1 ORDER BY "FIELD_BANS_DATE" DESC");
	stmt_BanNameCheck			= db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_BANS" WHERE "FIELD_BANS_ACTIVE"=1 AND "FIELD_BANS_NAME" = ? COLLATE NOCASE ORDER BY "FIELD_BANS_DATE" DESC");
	stmt_BanGetList				= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_BANS" WHERE "FIELD_BANS_ACTIVE"=1 ORDER BY "FIELD_BANS_DATE" DESC LIMIT ?, ? COLLATE NOCASE");
	stmt_BanGetTotal			= db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_BANS" WHERE "FIELD_BANS_ACTIVE"=1");
	stmt_BanGetInfo				= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_BANS" WHERE "FIELD_BANS_NAME" = ? COLLATE NOCASE ORDER BY "FIELD_BANS_DATE" DESC");
	stmt_BanUpdateInfo			= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_BANS" SET "FIELD_BANS_REASON" = ?, "FIELD_BANS_DURATION" = ? WHERE "FIELD_BANS_NAME" = ? COLLATE NOCASE");
	stmt_BanSetIpv4				= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_BANS" SET "FIELD_BANS_IPV4" = ? WHERE "FIELD_BANS_NAME" = ? COLLATE NOCASE");
	stmt_BanSetReason			= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_BANS" SET "FIELD_BANS_REASON" = ? WHERE "FIELD_BANS_NAME" = ? COLLATE NOCASE");
	stmt_BanSetDuration			= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_BANS" SET "FIELD_BANS_DURATION" = ? WHERE "FIELD_BANS_NAME" = ? COLLATE NOCASE");
}

BanPlayer(playerid, const reason[], byid, duration)
{
	new name[MAX_PLAYER_NAME];

	if(byid == -1)
		name = "Server";

	else
		GetPlayerName(byid, name, MAX_PLAYER_NAME);

	stmt_bind_value(stmt_BanInsert, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(stmt_BanInsert, 1, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
	stmt_bind_value(stmt_BanInsert, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_BanInsert, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanInsert, 4, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_BanInsert, 5, DB::TYPE_INTEGER, duration);

	if(stmt_execute(stmt_BanInsert))
	{
		ChatMsgLang(playerid, YELLOW, "BANNEDMESSG", reason);
		defer KickPlayerDelay(playerid);

		return 1;
	}

	return 0;
}

BanPlayerByName(const name[], const reason[], byid, duration)
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

	stmt_bind_value(stmt_BanInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_BanInsert, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_BanInsert, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_BanInsert, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanInsert, 4, DB::TYPE_STRING, byname, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_BanInsert, 5, DB::TYPE_INTEGER, duration);

	if(!stmt_execute(stmt_BanInsert))
		return 0;

	return 1;
}

UpdateBanInfo(const name[], const reason[], duration)
{
	stmt_bind_value(stmt_BanUpdateInfo, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanUpdateInfo, 1, DB::TYPE_INTEGER, duration);
	stmt_bind_value(stmt_BanUpdateInfo, 2, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_BanUpdateInfo))
		return 1;
	
	return 0;
}

UnBanPlayer(const name[])
{
	if(!IsPlayerBanned(name))
		return 0;

	stmt_bind_value(stmt_BanUnban, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_BanUnban))
	{
		return 1;
	}

	return 0;
}

BanCheck(playerid)
{
	new
		banned,
		timestamp,
		reason[MAX_BAN_REASON],
		duration;

	stmt_bind_value(stmt_BanGetFromNameIp, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(stmt_BanGetFromNameIp, 1, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));

	stmt_bind_result_field(stmt_BanGetFromNameIp, 0, DB::TYPE_INTEGER, banned);
	stmt_bind_result_field(stmt_BanGetFromNameIp, 1, DB::TYPE_INTEGER, timestamp);
	stmt_bind_result_field(stmt_BanGetFromNameIp, 2, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_result_field(stmt_BanGetFromNameIp, 3, DB::TYPE_INTEGER, duration);

	if(stmt_execute(stmt_BanGetFromNameIp))
	{
		stmt_fetch_row(stmt_BanGetFromNameIp);

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

			stmt_bind_value(stmt_BanSetIpv4, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
			stmt_bind_value(stmt_BanSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
			stmt_execute(stmt_BanSetIpv4);

			defer KickPlayerDelay(playerid);

			return 1;
		}
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

stock IsPlayerBanned(const name[])
{
	new count;

	stmt_bind_value(stmt_BanNameCheck, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BanNameCheck, 0, DB::TYPE_INTEGER, count);

	if(stmt_execute(stmt_BanNameCheck))
	{
		stmt_fetch_row(stmt_BanNameCheck);

		if(count > 0)
			return 1;
	}

	return 0;
}

stock GetBanList(string[][MAX_PLAYER_NAME], limit, offset)
{
	new name[MAX_PLAYER_NAME];

	stmt_bind_value(stmt_BanGetList, 0, DB::TYPE_INTEGER, offset);
	stmt_bind_value(stmt_BanGetList, 1, DB::TYPE_INTEGER, limit);
	stmt_bind_result_field(stmt_BanGetList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_BanGetList))
		return -1;

	new idx;

	while(stmt_fetch_row(stmt_BanGetList))
	{
		string[idx] = name;
		idx++;
	}

	return idx;
}

stock GetTotalBans()
{
	new total;

	stmt_bind_result_field(stmt_BanGetTotal, 0, DB::TYPE_INTEGER, total);
	stmt_execute(stmt_BanGetTotal);
	stmt_fetch_row(stmt_BanGetTotal);

	return total;
}

stock GetBanInfo(const name[], &timestamp, reason[], bannedby[], &duration)
{
	stmt_bind_value(stmt_BanGetInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	stmt_bind_result_field(stmt_BanGetInfo, FIELD_ID_BANS_DATE, DB::TYPE_INTEGER, timestamp);
	stmt_bind_result_field(stmt_BanGetInfo, FIELD_ID_BANS_REASON, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_result_field(stmt_BanGetInfo, FIELD_ID_BANS_BY, DB::TYPE_STRING, bannedby, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BanGetInfo, FIELD_ID_BANS_DURATION, DB::TYPE_INTEGER, duration);

	if(!stmt_execute(stmt_BanGetInfo))
		return 0;

	stmt_fetch_row(stmt_BanGetInfo);

	return 1;
}

stock SetBanIpv4(const name[], ipv4)
{
	stmt_bind_value(stmt_BanSetIpv4, 0, DB::TYPE_INTEGER, ipv4);
	stmt_bind_value(stmt_BanSetIpv4, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_BanSetIpv4);
}

stock SetBanReason(const name[], reason[])
{
	stmt_bind_value(stmt_BanSetReason, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanSetReason, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_BanSetReason);
}

stock SetBanDuration(const name[], duration)
{
	stmt_bind_value(stmt_BanSetDuration, 0, DB::TYPE_INTEGER, duration);
	stmt_bind_value(stmt_BanSetDuration, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_BanSetDuration);
}
