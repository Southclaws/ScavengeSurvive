#include <YSI\y_hooks>


#define MAX_BAN_REASON (128)


BanPlayer(playerid, reason[], byid, duration)
{
	new name[MAX_PLAYER_NAME];

	if(byid == -1)
		name = "Server";

	else
		GetPlayerName(byid, name, MAX_PLAYER_NAME);

	stmt_bind_value(gStmt_BanInsert, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(gStmt_BanInsert, 1, DB::TYPE_INTEGER, gPlayerData[playerid][ply_IP]);
	stmt_bind_value(gStmt_BanInsert, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(gStmt_BanInsert, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(gStmt_BanInsert, 4, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(gStmt_BanInsert, 5, DB::TYPE_INTEGER, duration);

	if(stmt_execute(gStmt_BanInsert))
	{
		MsgF(playerid, YELLOW, " >  "C_RED"You are banned! "C_YELLOW"Reason: "C_BLUE"%s", reason);
		defer KickPlayerDelay(playerid);

		return 1;
	}

	return 0;
}

BanPlayerByName(name[], reason[], byid, duration)
{
	new
		id,
		ip,
		by[MAX_PLAYER_NAME],
		bool:online;

	if(byid == -1)
		by = "Server";

	else
		GetPlayerName(byid, by, MAX_PLAYER_NAME);

	foreach(new i : Player)
	{
		if(!strcmp(gPlayerName[i], name))
		{
			id = i;
			ip = gPlayerData[id][ply_IP];
			online = true;
		}
	}

	stmt_bind_value(gStmt_BanInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(gStmt_BanInsert, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_value(gStmt_BanInsert, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(gStmt_BanInsert, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(gStmt_BanInsert, 4, DB::TYPE_STRING, by, MAX_PLAYER_NAME);
	stmt_bind_value(gStmt_BanInsert, 5, DB::TYPE_INTEGER, duration);

	if(stmt_execute(gStmt_BanInsert))
	{
		if(online)
		{
			MsgF(id, YELLOW, " >  "C_RED"You are banned! "C_YELLOW", reason: "C_BLUE"%s", reason);
			defer KickPlayerDelay(id);
		}

		return 1;
	}

	return 0;
}

UpdateBanInfo(name[], reason[], duration)
{
	stmt_bind_value(gStmt_BanUpdateInfo, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(gStmt_BanUpdateInfo, 1, DB::TYPE_INTEGER, duration);
	stmt_bind_value(gStmt_BanUpdateInfo, 2, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(gStmt_BanUpdateInfo))
		return 1;
	
	return 0;
}

UnBanPlayer(name[])
{
	if(!IsPlayerBanned(name))
		return 0;

	stmt_bind_value(gStmt_BanDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(gStmt_BanDelete))
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

	stmt_bind_value(gStmt_BanGetFromNameIp, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(gStmt_BanGetFromNameIp, 1, DB::TYPE_INTEGER, gPlayerData[playerid][ply_IP]);

	stmt_bind_result_field(gStmt_BanGetFromNameIp, 0, DB::TYPE_INTEGER, banned);
	stmt_bind_result_field(gStmt_BanGetFromNameIp, 1, DB::TYPE_INTEGER, timestamp);
	stmt_bind_result_field(gStmt_BanGetFromNameIp, 2, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_result_field(gStmt_BanGetFromNameIp, 3, DB::TYPE_INTEGER, duration);

	if(stmt_execute(gStmt_BanGetFromNameIp))
	{
		stmt_fetch_row(gStmt_BanGetFromNameIp);

		if(banned)
		{
			if(duration > 0)
			{
				if(gettime() > (timestamp + duration))
				{
					new name[MAX_PLAYER_NAME];
					GetPlayerName(playerid, name, MAX_PLAYER_NAME);
					UnBanPlayer(name);

					MsgF(playerid, YELLOW, " >  Your ban from %s has been lifted. Do not break the rules again.", TimestampToDateTime(timestamp));
					logf("[UNBAN] Ban lifted automatically for %s", name);

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

			ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Banned", string, "Close", "");

			stmt_bind_value(gStmt_BanUpdateIpv4, 0, DB::TYPE_INTEGER, gPlayerData[playerid][ply_IP]);
			stmt_bind_value(gStmt_BanUpdateIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
			stmt_execute(gStmt_BanUpdateIpv4);

			defer KickPlayerDelay(playerid);

			return 1;
		}
	}

	return 0;
}

forward external_BanPlayer(name[], reason[], duration);
public external_BanPlayer(name[], reason[], duration)
{
	BanPlayerByName(name, reason, -1, duration);
}

stock IsPlayerBanned(name[])
{
	new count;

	stmt_bind_value(gStmt_BanNameCheck, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_BanNameCheck, 0, DB::TYPE_INTEGER, count);

	if(stmt_execute(gStmt_BanNameCheck))
	{
		stmt_fetch_row(gStmt_BanNameCheck);

		if(count > 0)
			return 1;
	}

	return 0;
}
