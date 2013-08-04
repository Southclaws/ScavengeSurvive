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
	stmt_bind_value(gStmt_BugInsert, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(gStmt_BugInsert, 1, DB::TYPE_STRING, bug, 128);
	stmt_bind_value(gStmt_BugInsert, 2, DB::TYPE_INTEGER, gettime());

	if(stmt_execute(gStmt_BugInsert))
	{
		MsgAdminsF(1, YELLOW, " >  %P"#C_YELLOW" reported bug %s", playerid, bug);
	}
}

ShowListOfBugs(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		bug[128],
		datetime;

	stmt_bind_result_field(gStmt_BugList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_BugList, 1, DB::TYPE_STRING, bug, 128);
	stmt_bind_result_field(gStmt_BugList, 2, DB::TYPE_INTEGER, datetime);

	if(stmt_execute(gStmt_BugList))
	{
		new
			list[(MAX_PLAYER_NAME + 16 + 1) * MAX_ISSUES],
			idx;

		while(stmt_fetch_row(gStmt_BugList))
		{
			strcat(list, name);
			strcat(list, " - ");

			strcat(list, bug);
			strcat(list, "\n");

			issue_TimestampIndex[idx++] = datetime;
		}
		ShowPlayerDialog(playerid, d_IssueList, DIALOG_STYLE_LIST, "Issues", list, "Open", "Close");

		return 1;
	}

	return 0;
}

GetBugReports()
{
	new count;

	stmt_bind_result_field(gStmt_BugTotal, 0, DB::TYPE_INTEGER, count);
	stmt_execute(gStmt_BugTotal);
	stmt_fetch_row(gStmt_BugTotal);

	return count;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_IssueList && response)
	{
		new
			name[MAX_PLAYER_NAME],
			bug[128],
			message[512];

		stmt_bind_value(gStmt_BugInfo, 0, DB::TYPE_INTEGER, issue_TimestampIndex[listitem]);
		stmt_bind_result_field(gStmt_BugInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_result_field(gStmt_BugInfo, 1, DB::TYPE_STRING, bug, 128);

		if(stmt_execute(gStmt_BugInfo))
		{
			stmt_fetch_row(gStmt_BugInfo);

			format(message, sizeof(message),
				""#C_YELLOW"Reporter:\n\t\t"#C_BLUE"%s\n\n\
				"#C_YELLOW"Reason:\n\t\t"#C_BLUE"%s\n\n\
				"#C_YELLOW"Date:\n\t\t"#C_BLUE"%s",
				name, bug, TimestampToDateTime(issue_TimestampIndex[listitem]));

			if(gPlayerData[playerid][ply_Admin] > 1)
				ShowPlayerDialog(playerid, d_Issue, DIALOG_STYLE_MSGBOX, inputtext, message, "Delete", "Back");

			else
				ShowPlayerDialog(playerid, d_Issue, DIALOG_STYLE_MSGBOX, inputtext, message, "Back", "");

			issue_CurrentItem[playerid] = listitem;
		}
	}

	if(dialogid == d_Issue)
	{
		if(response)
		{
			if(gPlayerData[playerid][ply_Admin] > 1)
			{
				stmt_bind_value(gStmt_BugDelete, 0, DB::TYPE_INTEGER, issue_TimestampIndex[issue_CurrentItem[playerid]]);
				stmt_execute(gStmt_BugDelete);
			}
		}

		ShowListOfBugs(playerid);
	}

	return 1;
}
