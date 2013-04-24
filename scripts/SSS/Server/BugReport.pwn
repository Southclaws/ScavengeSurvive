#include <YSI\y_hooks>


#define MAX_ISSUES (32)


new
	issue_CurrentItem[MAX_PLAYER_NAME],
	issue_TimestampIndex[MAX_ISSUES];


CMD:bug(playerid, params[])
{
	new bug[98];

	if(!sscanf(params, "s[98]", bug))
	{
		ReportBug(playerid, bug);

		Msg(playerid, YELLOW, " >  Your bug report has been submitted! Thank you for your feedback! You can view a list of current issues with /issues.");
	}
	else
	{
		Msg(playerid, YELLOW, " >  Usage: /bug [description of bug or steps to reproduce, only 98 characters will fit here but feel free to submit multiple reports]");
	}

	return 1;
}

CMD:issues(playerid, params[])
{
	new ret;

	ret = ShowListOfBugs(playerid);

	if(ret == 0)
		Msg(playerid, YELLOW, " >  There are no bug reports to show.");

	return 1;
}

ReportBug(playerid, bug[])
{
	new query[512];

	format(query, sizeof(query), "\
		INSERT INTO `Bugs`\
		(`"#ROW_NAME"`, `"#ROW_REAS"`, `"#ROW_DATE"`)\
		VALUES('%p', '%s', '%d')",
		playerid, db_escape(bug), gettime());

	db_free_result(db_query(gAccounts, query));

	MsgAdminsF(1, YELLOW, " >  %P"#C_YELLOW" reported bug %s", playerid, bug);
}

ShowListOfBugs(playerid)
{
	new
		DBResult:result,
		rowcount;

	result = db_query(gAccounts, "SELECT * FROM `Bugs`");
	rowcount = db_num_rows(result);

	if(rowcount > 0)
	{
		new
			field[MAX_PLAYER_NAME + 16 + 1],
			list[(MAX_PLAYER_NAME + 16 + 1) * MAX_ISSUES];

		for(new i; i < rowcount && i < MAX_ISSUES; i++)
		{
			db_get_field(result, 0, field, MAX_PLAYER_NAME);
			strcat(list, field);
			strcat(list, " - ");

			db_get_field(result, 1, field, 13);
			strcat(list, field);
			strcat(list, "\n");

			db_get_field(result, 2, field, 12);
			issue_TimestampIndex[i] = strval(field);

			db_next_row(result);
		}

		ShowPlayerDialog(playerid, d_IssueList, DIALOG_STYLE_LIST, "Issues", list, "Open", "Close");

		db_free_result(result);

		return 1;
	}
	else
	{
		db_free_result(result);
	
		return 0;
	}
}

GetBugReports()
{
	new
		DBResult:result,
		rowcount;

	result = db_query(gAccounts, "SELECT * FROM `Bugs`");
	rowcount = db_num_rows(result);
	db_free_result(result);

	return rowcount;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_IssueList && response)
	{
		new
			query[128],
			DBResult:result,
			reporter[MAX_PLAYER_NAME],
			bug[96],
			timeval[12],
			date[32],
			tm<timestamp>,
			message[512];

		format(query, sizeof(query), "SELECT * FROM `Bugs` WHERE `"#ROW_DATE"` = '%d'", issue_TimestampIndex[listitem]);
		result = db_query(gAccounts, query);

		db_get_field(result, 0, reporter, MAX_PLAYER_NAME);
		db_get_field(result, 1, bug, 96);
		db_get_field(result, 2, timeval, 12);

		db_free_result(result);

		localtime(Time:strval(timeval), timestamp);
		strftime(date, 64, "%A %b %d %Y at %X", timestamp);

		format(message, sizeof(message),
			""#C_YELLOW"Reporter:\n\t\t"#C_BLUE"%s\n\n\
			"#C_YELLOW"Reason:\n\t\t"#C_BLUE"%s\n\n\
			"#C_YELLOW"Date:\n\t\t"#C_BLUE"%s",
			reporter, bug, date);

		if(gPlayerData[playerid][ply_Admin] > 1)
			ShowPlayerDialog(playerid, d_Report, DIALOG_STYLE_MSGBOX, inputtext, message, "Back", "Delete");

		else
			ShowPlayerDialog(playerid, d_Report, DIALOG_STYLE_MSGBOX, inputtext, message, "Back", "");

		issue_CurrentItem[playerid] = listitem;
	}

	if(dialogid == d_Issue)
	{
		if(response)
		{
			ShowListOfBugs(playerid);
		}
		else
		{
			new
				query[128];

			format(query, sizeof(query), "DELETE FROM `Bugs` WHERE `"#ROW_DATE"` = '%d'", issue_TimestampIndex[issue_CurrentItem[playerid]]);
			db_free_result(db_query(gAccounts, query));

			ShowListOfBugs(playerid);
		}
	}

	return 1;
}
