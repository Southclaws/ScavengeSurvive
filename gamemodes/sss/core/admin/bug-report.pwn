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


#define MAX_ISSUE_LENGTH			(128)
#define MAX_ISSUES_PER_PAGE			(32)
#define ACCOUNTS_TABLE_BUGS			"Bugs"
#define FIELD_BUGS_NAME				"name"		// 00
#define FIELD_BUGS_REASON			"reason"	// 01
#define FIELD_BUGS_DATE				"date"		// 02

enum
{
	FIELD_ID_BUGS_NAME,
	FIELD_ID_BUGS_REASON,
	FIELD_ID_BUGS_DATE
}


static
	issue_RowIndex[MAX_ISSUES_PER_PAGE];


hook OnGameModeInit()
{
	//
}


/*==============================================================================

	Submitting reports

==============================================================================*/


CMD:bug(playerid, params[])
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			ReportBug(playerid, inputtext);
			ChatMsgLang(playerid, YELLOW, "BUGREPORTSU");
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Bug report", ls(playerid, "BUGREPORTDI"), "Submit", "Cancel");

	return 1;
}

ReportBug(playerid, bug[])
{
	// BugInsert, 0, DB::TYPE_PLAYER_NAME, playerid);
	// BugInsert, 1, DB::TYPE_STRING, bug, MAX_ISSUE_LENGTH);
	// BugInsert, 2, DB::TYPE_INTEGER, gettime());

	ChatMsgAdmins(1, YELLOW, " >  %P"C_YELLOW" reported bug %s", playerid, bug);
}


/*==============================================================================

	Listing reports

==============================================================================*/


CMD:issues(playerid, params[])
{
	new ret;

	ret = ShowListOfBugs(playerid);

	if(ret == 0)
		ChatMsg(playerid, YELLOW, " >  There are no bug reports to show.");

	return 1;
}

ShowListOfBugs(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		bug[32],
		rowid;

	// BugList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME
	// BugList, 1, DB::TYPE_STRING, bug, 32
	// BugList, 2, DB::TYPE_INTEGER, rowid

	new
		list[(MAX_PLAYER_NAME + 2 + 32 + 1) * MAX_ISSUES_PER_PAGE],
		idx;
/*
	while(idx < MAX_ISSUES_PER_PAGE)
	{
		strcat(list, name);
		strcat(list, ": ");

		strcat(list, bug);

		if(bug[30] != EOS)
			strcat(list, "[...]");

		strcat(list, "\n");

		issue_RowIndex[idx++] = rowid;
	}
*/
	if(idx == 0)
		return 0;

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			ShowBugReportInfo(playerid, issue_RowIndex[listitem]);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Issues", list, "Open", "Close");

	return 1;
}

ShowBugReportInfo(playerid, rowid)
{
	new
		name[MAX_PLAYER_NAME],
		bug[MAX_ISSUE_LENGTH],
		date,
		message[512];

	// BugInfo, 0, DB::TYPE_INTEGER, rowid
	// BugInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME
	// BugInfo, 1, DB::TYPE_STRING, bug, MAX_ISSUE_LENGTH
	// BugInfo, 2, DB::TYPE_INTEGER, date

	format(message, sizeof(message),
		""C_YELLOW"Reporter:\n\t\t"C_BLUE"%s\n\n\
		"C_YELLOW"Reason:\n\t\t"C_BLUE"%s\n\n\
		"C_YELLOW"Date:\n\t\t"C_BLUE"%s",
		name, bug, TimestampToDateTime(date));

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			if(GetPlayerAdminLevel(playerid) > 1)
			{
				// BugDelete, 0, DB::TYPE_INTEGER, rowid);
			}
		}

		ShowListOfBugs(playerid);
	}

	if(GetPlayerAdminLevel(playerid) > 1)
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Issues", message, "Delete", "Back");

	else
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Issues", message, "Back", "");

	return 1;
}

/*==============================================================================

	Interface

==============================================================================*/


stock GetBugReports()
{
	new count;

	// BugTotal, 0, DB::TYPE_INTEGER, count);

	return count;
}
