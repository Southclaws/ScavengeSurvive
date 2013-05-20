#include <YSI\y_hooks>


#define MAX_REPORTS (32)


new
	report_CurrentName[MAX_PLAYERS][MAX_PLAYER_NAME],
	report_CurrentReason[MAX_PLAYER_NAME][96],
	report_CurrentItem[MAX_PLAYER_NAME],
	report_TimestampIndex[MAX_REPORTS];


CMD:report(playerid, params[])
{
	new
		id,
		name[MAX_PLAYER_NAME],
		reason[96];

	if(!sscanf(params, "ds[96]", id, reason))
	{
		if(!IsPlayerConnected(id))
			return 4;

		ReportPlayer(gPlayerName[id], reason, playerid);

		Msg(playerid, YELLOW, " >  Your report has been submitted! If there are no admins online, they will receive it when they next login.");
	}
	else if(!sscanf(params, "s[24]s[96]", name, reason))
	{
		ReportPlayer(name, reason, playerid);

		Msg(playerid, YELLOW, " >  Your report has been submitted! If there are no admins online, they will receive it when they next login.");
	}
	else
	{
		Msg(playerid, YELLOW, " >  Usage: /report [playerid/name] [reason]");
	}

	return 1;
}

ACMD:reports[1](playerid, params[])
{
	new ret;

	ret = ShowListOfReports(playerid);

	if(ret == 0)
		Msg(playerid, YELLOW, " >  There are no reports to show.");

	return 1;
}

ReportPlayer(name[], reason[], reporter)
{
	new query[256];

	format(query, sizeof(query), "\
		INSERT INTO `Reports`\
		(`"#ROW_NAME"`, `"#ROW_REAS"`, `"#ROW_DATE"`, `"#ROW_READ"`)\
		VALUES('%s', '%s', '%d', '0')",
		name, db_escape(reason), gettime());

	db_free_result(db_query(gAccounts, query));

	if(reporter == -1)
		MsgAdminsF(1, YELLOW, " >  Server reported %s, reason: %s", name, reason);

	else
		MsgAdminsF(1, YELLOW, " >  %p reported %s, reason: %s", reporter, name, reason);
}

ShowListOfReports(playerid)
{
	new
		DBResult:result,
		rowcount;

	result = db_query(gAccounts, "SELECT * FROM `Reports`");
	rowcount = db_num_rows(result);

	if(rowcount > 0)
	{
		new
			field[MAX_PLAYER_NAME + 1],
			list[(MAX_PLAYER_NAME + 1 + 8) * MAX_REPORTS],
			read;

		for(new i; i < rowcount && i < MAX_REPORTS; i++)
		{
			db_get_field(result, 3, field, 2);

			if(field[0] == '0')
				read = 1;

			else
				read = 0;

			db_get_field(result, 2, field, 12);
			report_TimestampIndex[i] = strval(field);

			db_get_field(result, 0, field, MAX_PLAYER_NAME + 1);

			if(IsPlayerBanned(field))
			{
				printf("%s is banned", field);
				strcat(list, "{FF0000}");
			}
			else
			{
				printf("%s is NOT banned", field);
				if(read)
					strcat(list, "{FFFF00}");

				else
					strcat(list, "{FFFFFF}");
			}

			strcat(list, field);
			strcat(list, "\n");
			db_next_row(result);
		}

		ShowPlayerDialog(playerid, d_ReportList, DIALOG_STYLE_LIST, "Reports", list, "Open", "Close");

		db_free_result(result);

		return 1;
	}
	else
	{
		db_free_result(result);
	
		return 0;
	}
}

GetUnreadReports()
{
	new
		DBResult:result,
		rowcount;

	result = db_query(gAccounts, "SELECT * FROM `Reports` WHERE `"#ROW_READ"` = '0'");
	rowcount = db_num_rows(result);
	db_free_result(result);

	return rowcount;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_ReportList && response)
	{
		new
			query[128],
			DBResult:result,
			reason[96],
			timeval[12],
			date[32],
			tm<timestamp>,
			message[512];

		strtrim(inputtext);
	
		format(query, sizeof(query), "SELECT * FROM `Reports` WHERE `"#ROW_NAME"` = '%s' AND `"#ROW_DATE"` = '%d'", inputtext, report_TimestampIndex[listitem]);
		result = db_query(gAccounts, query);

		db_get_field(result, 1, reason, 96);
		db_get_field(result, 2, timeval, 12);

		db_free_result(result);

		localtime(Time:strval(timeval), timestamp);
		strftime(date, 64, "%A %b %d %Y at %X", timestamp);

		format(message, sizeof(message), "\
			"#C_YELLOW"Date:\n\t\t"#C_BLUE"%s\n\n\n\
			"#C_YELLOW"Reason:\n\t\t"#C_BLUE"%s", date, reason);

		report_CurrentName[playerid][0] = EOS;
		strcat(report_CurrentName[playerid], inputtext);
		report_CurrentReason[playerid][0] = EOS;
		strcat(report_CurrentReason[playerid], reason);

		ShowPlayerDialog(playerid, d_Report, DIALOG_STYLE_MSGBOX, inputtext, message, "Options", "Back");

		format(query, sizeof(query), "UPDATE `Reports` SET `"#ROW_READ"` = '1' WHERE `"#ROW_NAME"` = '%s' AND `"#ROW_DATE"` = '%d'", inputtext, report_TimestampIndex[listitem]);
		result = db_query(gAccounts, query);
		db_free_result(result);

		report_CurrentItem[playerid] = listitem;
	}

	if(dialogid == d_Report)
	{
		if(response)
		{
			ShowPlayerDialog(playerid, d_ReportOptions, DIALOG_STYLE_LIST, report_CurrentName[playerid], "Ban\nDelete\nDelete all reports of this player\nMark Unread", "Select", "Back");
		}
		else
		{
			ShowListOfReports(playerid);
		}
	}

	if(dialogid == d_ReportOptions)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					BanPlayerByName(report_CurrentName[playerid], report_CurrentReason[playerid], playerid);

					ShowListOfReports(playerid);
				}
				case 1:
				{
					new
						query[128];

					format(query, sizeof(query), "DELETE FROM `Reports` WHERE `"#ROW_NAME"` = '%s' AND `"#ROW_DATE"` = '%d'", report_CurrentName[playerid], report_TimestampIndex[report_CurrentItem[playerid]]);
					db_free_result(db_query(gAccounts, query));

					ShowListOfReports(playerid);
				}
				case 2:
				{
					new
						query[128];

					format(query, sizeof(query), "DELETE FROM `Reports` WHERE `"#ROW_NAME"` = '%s'", report_CurrentName[playerid]);
					db_free_result(db_query(gAccounts, query));

					ShowListOfReports(playerid);
				}
				case 3:
				{
					new
						query[128];

					format(query, sizeof(query), "UPDATE `Reports` SET `"#ROW_READ"` = '0' WHERE `"#ROW_NAME"` = '%s'", report_CurrentName[playerid]);
					db_free_result(db_query(gAccounts, query));

					ShowListOfReports(playerid);
				}
			}
		}
		else
		{
			ShowListOfReports(playerid);
		}
	}

	return 1;
}
