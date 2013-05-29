#include <YSI\y_hooks>


#define MAX_REPORTS (32)


new
		report_TargetName			[MAX_PLAYERS][MAX_PLAYER_NAME],
		report_TargetType			[MAX_PLAYERS],
Float:	report_TargetPos			[MAX_PLAYERS][3],

		report_CurrentName			[MAX_PLAYERS][MAX_PLAYER_NAME],
		report_CurrentReason		[MAX_PLAYERS][128],
		report_CurrentType			[MAX_PLAYERS],
Float:	report_CurrentReportPos		[MAX_PLAYERS][3],
Float:	report_CurrentReportPos2	[MAX_PLAYERS][3],
		report_CurrentItem			[MAX_PLAYERS],
		report_TimestampIndex		[MAX_REPORTS];


CMD:report(playerid, params[])
{
	ShowReportMenu(playerid);

	return 1;
}

ShowReportMenu(playerid)
{	
	ShowPlayerDialog(playerid, d_ReportMenu, DIALOG_STYLE_LIST, "Report a player", "Specific player ID (who is online now)\nSpecific Player Name (Who isn't online now)\nPlayer that last killed me\nPlayer closest to me", "Send", "Cancel");
}

ACMD:reports[1](playerid, params[])
{
	new ret;

	ret = ShowListOfReports(playerid);

	if(ret == 0)
		Msg(playerid, YELLOW, " >  There are no reports to show.");

	return 1;
}

ReportPlayer(name[], reason[], reporter, type = REPORT_TYPE_PLAYER, Float:posx = 0.0, Float:posy = 0.0, Float:posz = 0.0)
{
	new query[256];

	format(query, sizeof(query), "\
		INSERT INTO `Reports`\
		(`"#ROW_NAME"`, `"#ROW_REAS"`, `"#ROW_DATE"`, `"#ROW_READ"`, `"#ROW_TYPE"`, `"#ROW_POSX"`, `"#ROW_POSY"`, `"#ROW_POSZ"`)\
		VALUES('%s', '%s', '%d', '0', '%d', '%.1f', '%.1f', '%.1f')",
		name, db_escape(reason), gettime(), type, posx, posy, posz);

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
				strcat(list, "{FF0000}");
			}
			else
			{
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
	if(dialogid == d_ReportMenu && response)
	{
		switch(listitem)
		{
			case 0:// Specific player ID (who is online now)
			{
				new list[MAX_PLAYERS * (MAX_PLAYER_NAME + 1)];

				foreach(new i : Player)
				{
					strcat(list, gPlayerName[i]);
					strcat(list, "\n");
				}

				ShowPlayerDialog(playerid, d_ReportPlayerList, DIALOG_STYLE_LIST, "Report Online Player", list, "Report", "Back");
				report_TargetType[playerid] = 0;
			}
			case 1:// Specific Player Name (Who isn't online now)
			{
				ShowPlayerDialog(playerid, d_ReportNameInput, DIALOG_STYLE_INPUT, "Report Offline Player", "Enter name to report below", "Report", "Back");
				report_TargetType[playerid] = 0;
			}
			case 2:// Player that last killed me
			{
				if(!isnull(gLastKilledBy[playerid]))
				{
					report_TargetName[playerid] = gLastKilledBy[playerid];
				}
				else
				{
					if(!isnull(gLastHitBy[playerid]))	
					{
						report_TargetName[playerid] = gLastHitBy[playerid];						
					}
					else
					{
						Msg(playerid, RED, " >  No player could be found.");
						return 1;
					}
				}

				report_TargetPos[playerid][0] = gPlayerDeathPos[playerid][0];
				report_TargetPos[playerid][1] = gPlayerDeathPos[playerid][1];
				report_TargetPos[playerid][2] = gPlayerDeathPos[playerid][2];

				ShowPlayerDialog(playerid, d_ReportReason, DIALOG_STYLE_INPUT, "Enter reason", "Enter the report reason below", "Report", "Back");
				report_TargetType[playerid] = 1;
			}
			case 3:// Player closest to me
			{
				new targetid = GetClosestPlayerFromPlayer(playerid, 100.0);

				if(!IsPlayerConnected(targetid))
				{
					Msg(playerid, RED, " >  No player could be found within 100m");
					return 1;
				}

				report_TargetName[playerid] = gPlayerName[targetid];
				GetPlayerPos(targetid, report_TargetPos[playerid][0], report_TargetPos[playerid][1], report_TargetPos[playerid][2]);
	
				ShowPlayerDialog(playerid, d_ReportReason, DIALOG_STYLE_INPUT, "Enter reason", "Enter the report reason below", "Report", "Back");
				report_TargetType[playerid] = 2;
			}
		}
	}

	if(dialogid == d_ReportPlayerList)
	{
		if(response)
		{
			GetPlayerPos(playerid, report_TargetPos[playerid][0], report_TargetPos[playerid][1], report_TargetPos[playerid][2]);
			strmid(report_TargetName[playerid], inputtext, 0, strlen(inputtext));

			ShowPlayerDialog(playerid, d_ReportReason, DIALOG_STYLE_INPUT, "Enter reason", "Enter the report reason below", "Report", "Back");
		}
		else
		{
			ShowReportMenu(playerid);
		}
	}

	if(dialogid == d_ReportNameInput)
	{
		if(response)
		{
			report_TargetName[playerid][0] = EOS;
			strcat(report_TargetName[playerid], inputtext);

			report_TargetPos[playerid][0] = 0.0;
			report_TargetPos[playerid][1] = 0.0;
			report_TargetPos[playerid][2] = 0.0;

			ShowPlayerDialog(playerid, d_ReportReason, DIALOG_STYLE_INPUT, "Enter reason", "Enter the report reason below", "Report", "Back");
		}
		else
		{
			ShowReportMenu(playerid);
		}
	}

	if(dialogid == d_ReportReason)
	{
		if(response)
		{
			ReportPlayer(report_TargetName[playerid], inputtext, playerid, REPORT_TYPE_PLAYER, report_TargetPos[playerid][0], report_TargetPos[playerid][1], report_TargetPos[playerid][2]);
		}
		else
		{
			ShowReportMenu(playerid);
		}
	}

	if(dialogid == d_ReportList && response)
	{
		new
			query[128],
			DBResult:result,
			reason[96],
			timeval[12],
			reporttype[2],
			posx[8],
			posy[8],
			posz[8],
			date[32],
			tm<timestamp>,
			message[512];

		strtrim(inputtext);
	

		format(query, sizeof(query), "SELECT * FROM `Reports` WHERE `"#ROW_NAME"` = '%s' AND `"#ROW_DATE"` = '%d'", inputtext, report_TimestampIndex[listitem]);
		result = db_query(gAccounts, query);

		db_get_field(result, 1, reason, 96);
		db_get_field(result, 2, timeval, 12);
		db_get_field(result, 4, reporttype, 2);
		db_get_field(result, 5, posx, 8);
		db_get_field(result, 6, posy, 8);
		db_get_field(result, 7, posz, 8);

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

		report_CurrentType[playerid] = strval(reporttype);

		report_CurrentReportPos[playerid][0] = floatstr(posx);
		report_CurrentReportPos[playerid][1] = floatstr(posy);
		report_CurrentReportPos[playerid][2] = floatstr(posz);


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
			new options[128];

			options = "Ban\nDelete\nDelete all reports of this player\nMark Unread\n";

			if(bPlayerGameSettings[playerid] & AdminDuty)
			{
				strcat(options, "Go to position of report\n");

				switch(report_CurrentType[playerid])
				{
					case REPORT_TYPE_TELEPORT:
					{
						new pos = strfind(report_CurrentReason[playerid], ">");

						sscanf(report_CurrentReason[playerid][pos+2], "p<,>ffp<)>f",
							report_CurrentReportPos2[playerid][0], report_CurrentReportPos2[playerid][1], report_CurrentReportPos2[playerid][2]);

						strcat(options, "Go to teleport destination\n");
					}
				}
			}
			else
			{
				strcat(options, "(Go on duty to see more options)");	
			}

			ShowPlayerDialog(playerid, d_ReportOptions, DIALOG_STYLE_LIST, report_CurrentName[playerid], options, "Select", "Back");
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
				case 4:
				{
					if(bPlayerGameSettings[playerid] & AdminDuty)
					{
						SetPlayerPos(playerid, report_CurrentReportPos[playerid][0], report_CurrentReportPos[playerid][1], report_CurrentReportPos[playerid][2]);
					}
				}
				case 5:
				{
					switch(report_CurrentType[playerid])
					{
						case REPORT_TYPE_TELEPORT:
						{
							if(bPlayerGameSettings[playerid] & AdminDuty)
							{
								SetPlayerPos(playerid, report_CurrentReportPos2[playerid][0], report_CurrentReportPos2[playerid][1], report_CurrentReportPos2[playerid][2]);
							}
						}
					}
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

IsPlayerReported(name[])
{
	new
		query[128],
		DBResult:result,
		numrows;

	format(query, sizeof(query), "SELECT * FROM `Reports` WHERE `"#ROW_NAME"` = '%s'", name);
	result = db_query(gAccounts, query);
	numrows = db_num_rows(result);
	db_free_result(result);

	if(numrows > 0)
		return 1;

	return 0;
}
