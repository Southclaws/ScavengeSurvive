#include <YSI\y_hooks>


#define MAX_BANS_PER_PAGE (20)


static
	banlist_CurrentIndex[MAX_PLAYERS],
	banlist_CurrentName[MAX_PLAYERS][MAX_PLAYER_NAME],
	banlist_ItemsOnPage[MAX_PLAYERS];


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
		bannedby[MAX_PLAYER_NAME],
		duration;

	stmt_bind_value(gStmt_BanGetInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	stmt_bind_result_field(gStmt_BanGetInfo, FIELD_ID_BANS_DATE, DB::TYPE_INTEGER, timestamp);
	stmt_bind_result_field(gStmt_BanGetInfo, FIELD_ID_BANS_REASON, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_result_field(gStmt_BanGetInfo, FIELD_ID_BANS_BY, DB::TYPE_STRING, bannedby, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_BanGetInfo, FIELD_ID_BANS_DURATION, DB::TYPE_INTEGER, duration);

	if(stmt_execute(gStmt_BanGetInfo))
	{
		stmt_fetch_row(gStmt_BanGetInfo);

		new str[256];

		format(str, 256, "\
			"C_YELLOW"Date:\n\t\t"C_BLUE"%s - %s\n\n\n\
			"C_YELLOW"By:\n\t\t"C_BLUE"%s\n\n\n\
			"C_YELLOW"Reason:\n\t\t"C_BLUE"%s",
			TimestampToDateTime(timestamp),
			duration ? TimestampToDateTime(timestamp + duration) : "Never",
			bannedby,
			reason);

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
			if(!strcmp(inputtext, "next"))
			{
				ShowListOfBans(playerid, banlist_CurrentIndex[playerid] + MAX_BANS_PER_PAGE);
			}
			else if(!strcmp(inputtext, "prev"))
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

