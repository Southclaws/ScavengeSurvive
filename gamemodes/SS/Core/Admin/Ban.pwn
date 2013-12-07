#include <YSI\y_hooks>


#define MAX_BANS_PER_PAGE	(20)
#define MAX_BAN_REASON		(128)


new
	banlist_CurrentIndex[MAX_PLAYERS],
	banlist_CurrentName[MAX_PLAYERS][MAX_PLAYER_NAME],
	banlist_ItemsOnPage[MAX_PLAYERS];


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

ShowListOfBans(playerid, index = 0)
{
	new name[MAX_PLAYER_NAME + 1];

	stmt_bind_value(gStmt_BanGetList, 0, DB::TYPE_INTEGER, index);
	stmt_bind_value(gStmt_BanGetList, 1, DB::TYPE_INTEGER, MAX_BANS_PER_PAGE);
	stmt_bind_result_field(gStmt_BanGetList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME + 1);

	banlist_ItemsOnPage[playerid] = 0;

	if(stmt_execute(gStmt_BanGetList))
	{
		new
			list[((MAX_PLAYER_NAME + 1) * MAX_BANS_PER_PAGE) + 24],
			total,
			title[22];

		while(stmt_fetch_row(gStmt_BanGetList))
		{
			strcat(list, name);
			strcat(list, "\n");
			banlist_ItemsOnPage[playerid]++;
		}

		stmt_bind_result_field(gStmt_BanGetTotal, 0, DB::TYPE_INTEGER, total);
		stmt_execute(gStmt_BanGetTotal);
		stmt_fetch_row(gStmt_BanGetTotal);

		format(title, sizeof(title), "Bans (%d-%d of %d)", index, index + MAX_BANS_PER_PAGE, total);

		if(index + MAX_BANS_PER_PAGE < total)
			strcat(list, ""C_YELLOW"Next\n");

		if(index >= MAX_BANS_PER_PAGE)
			strcat(list, ""C_YELLOW"Prev");

		ShowPlayerDialog(playerid, d_BanList, DIALOG_STYLE_LIST, title, list, "Open", "Close");
		banlist_CurrentIndex[playerid] = index;

		return 1;
	}

	return 0;
}

DisplayBanInfo(playerid, name[MAX_PLAYER_NAME])
{
	new
		timestamp,
		reason[MAX_BAN_REASON],
		bannedby[MAX_PLAYER_NAME];

	stmt_bind_value(gStmt_BanGetInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	stmt_bind_result_field(gStmt_BanGetInfo, 2, DB::TYPE_INTEGER, timestamp);
	stmt_bind_result_field(gStmt_BanGetInfo, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_result_field(gStmt_BanGetInfo, 4, DB::TYPE_STRING, bannedby, MAX_PLAYER_NAME);

	if(stmt_execute(gStmt_BanGetInfo))
	{
		stmt_fetch_row(gStmt_BanGetInfo);

		new str[256];

		format(str, 256, "\
			"C_YELLOW"Date:\n\t\t"C_BLUE"%s\n\n\n\
			"C_YELLOW"By:\n\t\t"C_BLUE"%s\n\n\n\
			"C_YELLOW"Reason:\n\t\t"C_BLUE"%s",
			TimestampToDateTime(timestamp), bannedby, reason);

		ShowPlayerDialog(playerid, d_BanInfo, DIALOG_STYLE_MSGBOX, name, str, "Un-ban", "Back");

		banlist_CurrentName[playerid] = name;

		return 1;
	}

	return 0;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_BanList)
	{
		if(response)
		{
			if(listitem == banlist_ItemsOnPage[playerid])
			{
				ShowListOfBans(playerid, banlist_CurrentIndex[playerid] + MAX_BANS_PER_PAGE);
			}
			else if(listitem == banlist_ItemsOnPage[playerid] + 1)
			{
				ShowListOfBans(playerid, banlist_CurrentIndex[playerid] - MAX_BANS_PER_PAGE);
			}
			else
			{
				new name[MAX_PLAYER_NAME];
				strmid(name, inputtext, 0, MAX_PLAYER_NAME);
				DisplayBanInfo(playerid, name);
			}
		}
	}

	if(dialogid == d_BanInfo)
	{
		if(response)
			UnBanPlayer(banlist_CurrentName[playerid]);

		ShowListOfBans(playerid, banlist_CurrentIndex[playerid]);
	}

	return 1;
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
