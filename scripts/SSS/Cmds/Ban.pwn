#include <YSI\y_hooks>


#define MAX_BANS_PER_PAGE	(20)


new
	ban_CurrentIndex[MAX_PLAYERS],
	ban_CurrentName[MAX_PLAYERS][MAX_PLAYER_NAME],
	ban_ItemsOnPage[MAX_PLAYERS];


BanPlayer(playerid, reason[], byid)
{
	new query[256];

	format(query, sizeof(query), "\
		INSERT INTO `Bans`\
		(`"#ROW_NAME"`, `"#ROW_IPV4"`, `"#ROW_DATE"`, `"#ROW_REAS"`, `"#ROW_BNBY"`)\
		VALUES('%s', '%d', '%d', '%s', '%p')",
		strtolower(gPlayerName[playerid]), gPlayerData[playerid][ply_IP], gettime(), reason, byid);

	db_free_result(db_query(gAccounts, query));

	MsgF(playerid, YELLOW, " >  "#C_RED"You are banned! "#C_YELLOW"Reason: "#C_BLUE"%s", reason);
	defer KickPlayerDelay(playerid);
}

BanPlayerByName(name[], reason[], byid = -1)
{
	new
		id,
		ip,
		by[24],
		bool:online,
		query[256];

	if(byid == -1)
		by = "Server";

	else
		GetPlayerName(byid, by, 24);

	foreach(new i : Player)
	{
		if(!strcmp(gPlayerName[i], name))
		{
			id = i;
			ip = gPlayerData[id][ply_IP];
			online = true;
		}
	}

	format(query, sizeof(query), "\
		INSERT INTO `Bans`\
		(`"#ROW_NAME"`, `"#ROW_IPV4"`, `"#ROW_DATE"`, `"#ROW_REAS"`, `"#ROW_BNBY"`)\
		VALUES('%s', '%d', '%d', '%s', '%s')",
		strtolower(name), ip, gettime(), reason, by);

	db_free_result(db_query(gAccounts, query));

	if(online)
	{
		MsgF(id, YELLOW, " >  "#C_RED"You are banned! "#C_YELLOW", reason: "#C_BLUE"%s", reason);
		defer KickPlayerDelay(id);
	}
}

UnBanPlayer(name[])
{
	new query[128];

	format(query, 128, "DELETE FROM `Bans` WHERE `"#ROW_NAME"` = '%s'", strtolower(name));
	
	db_free_result(db_query(gAccounts, query));
}

ShowListOfBans(playerid, index = 0)
{
	new
		query[128],
		DBResult:result,
		rowcount;

	format(query, sizeof(query), "SELECT "#ROW_NAME", "#ROW_IPV4", "#ROW_DATE", "#ROW_REAS", "#ROW_BNBY" FROM `Bans` ORDER BY `"#ROW_DATE"` DESC LIMIT %d, %d", index, MAX_BANS_PER_PAGE);

	result = db_query(gAccounts, query);
	rowcount = db_num_rows(result);

	ban_ItemsOnPage[playerid] = 0;

	if(rowcount > 0)
	{
		new
			field[MAX_PLAYER_NAME + 1],
			list[((MAX_PLAYER_NAME + 1) * MAX_BANS_PER_PAGE) + 24],
			total,
			title[22];

		for(new i; i < rowcount && i < MAX_BANS_PER_PAGE; i++)
		{
			db_get_field(result, 0, field, MAX_PLAYER_NAME);

			strcat(list, field);
			strcat(list, "\n");
			ban_ItemsOnPage[playerid]++;

			db_next_row(result);
		}

		result = db_query(gAccounts, "SELECT * FROM `Bans`");
		total = db_num_rows(result);

		format(title, sizeof(title), "Bans (%d-%d of %d)", index, index + MAX_BANS_PER_PAGE, total);

		if(index + MAX_BANS_PER_PAGE < total)
			strcat(list, ""#C_YELLOW"Next\n");

		if(index >= MAX_BANS_PER_PAGE)
			strcat(list, ""#C_YELLOW"Prev");

		ShowPlayerDialog(playerid, d_BanList, DIALOG_STYLE_LIST, title, list, "Open", "Close");
		ban_CurrentIndex[playerid] = index;

		db_free_result(result);

		return 1;
	}
	else
	{
		db_free_result(result);
	
		return 0;
	}
}

DisplayBanInfo(playerid, name[MAX_PLAYER_NAME])
{
	new
		query[128],
		DBResult:result,
		str[256],
		tmptime[12],
		tm<timestamp>,
		timestampstr[64],
		reason[64],
		bannedby[24];

	format(query, sizeof(query), "SELECT "#ROW_NAME", "#ROW_IPV4", "#ROW_DATE", "#ROW_REAS", "#ROW_BNBY" FROM `Bans` WHERE `"#ROW_NAME"` = '%s'", name);
	result = db_query(gAccounts, query);

	db_get_field(result, 2, tmptime, 12);
	db_get_field(result, 3, reason, 64);
	db_get_field(result, 4, bannedby, 24);
	
	localtime(Time:strval(tmptime), timestamp);
	strftime(timestampstr, 64, "%A %b %d %Y at %X", timestamp);

	format(str, 256, "\
		"#C_YELLOW"Date:\n\t\t"#C_BLUE"%s\n\n\n\
		"#C_YELLOW"By:\n\t\t"#C_BLUE"%s\n\n\n\
		"#C_YELLOW"Reason:\n\t\t"#C_BLUE"%s",
		timestampstr, bannedby, reason);

	ShowPlayerDialog(playerid, d_BanInfo, DIALOG_STYLE_MSGBOX, name, str, "Un-ban", "Back");

	db_free_result(result);

	ban_CurrentName[playerid] = name;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_BanList)
	{
		if(response)
		{
			if(listitem == ban_ItemsOnPage[playerid])
			{
				ShowListOfBans(playerid, ban_CurrentIndex[playerid] + MAX_BANS_PER_PAGE);
			}
			else if(listitem == ban_ItemsOnPage[playerid] + 1)
			{
				ShowListOfBans(playerid, ban_CurrentIndex[playerid] - MAX_BANS_PER_PAGE);
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
			UnBanPlayer(ban_CurrentName[playerid]);

		ShowListOfBans(playerid, ban_CurrentIndex[playerid]);
	}

	return 1;
}

forward external_BanPlayer(name[], reason[]);
public external_BanPlayer(name[], reason[])
{
	BanPlayerByName(name, reason);
}

IsPlayerBanned(name[])
{
	new
		query[128],
		DBResult:result,
		numrows;

	format(query, sizeof(query), "SELECT * FROM `Bans` WHERE `"#ROW_NAME"` = '%s'", strtolower(name));
	result = db_query(gAccounts, query);
	numrows = db_num_rows(result);
	db_free_result(result);

	if(numrows > 0)
		return 1;

	return 0;
}
