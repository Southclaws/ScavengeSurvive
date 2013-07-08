#include <YSI\y_hooks>


#define MAX_REPORTS_PER_PAGE	(32)
#define MAX_REPORT_TYPES		(5)


enum
{
	REPORT_TYPE_PLAYER_ID,
	REPORT_TYPE_PLAYER_NAME,
	REPORT_TYPE_PLAYER_CLOSE,
	REPORT_TYPE_PLAYER_KILLER,
	REPORT_TYPE_TELEPORT,
	REPORT_TYPE_SWIMFLY,
	REPORT_TYPE_VHEALTH,
	REPORT_TYPE_CAMDIST,
	REPORT_TYPE_CARNITRO,
	REPORT_TYPE_CARHYDRO,
	REPORT_TYPE_CARTELE,
	REPORT_TYPE_END
}

new
		report_TypeNames			[REPORT_TYPE_END][10]=
		{
			"PLY ID",
			"PLY NAME",
			"PLY CLOSE",
			"PLY KILL",
			"TELE",
			"FLY",
			"VHP",
			"CAM",
			"NOS",
			"HYDRO",
			"VTP"
		};


new
		send_TargetName				[MAX_PLAYERS][MAX_PLAYER_NAME],
		send_TargetType				[MAX_PLAYERS],
Float:	send_TargetPos				[MAX_PLAYERS][3],

		report_CurrentName			[MAX_PLAYERS][MAX_PLAYER_NAME],
		report_CurrentReason		[MAX_PLAYERS][128],
		report_CurrentType			[MAX_PLAYERS],
Float:	report_CurrentPos			[MAX_PLAYERS][3],
		report_CurrentInfo			[MAX_PLAYERS][128],
		report_CurrentReporter		[MAX_PLAYERS][MAX_PLAYER_NAME],

		report_CurrentItem			[MAX_PLAYERS],
		report_NameIndex			[MAX_PLAYERS][MAX_REPORTS_PER_PAGE][MAX_PLAYER_NAME],
		report_TimestampIndex		[MAX_PLAYERS][MAX_REPORTS_PER_PAGE];


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

ReportPlayer(name[], reason[], reporter, type, Float:posx, Float:posy, Float:posz, infostring[])
{
	new
		query[512],
		reportername[MAX_PLAYER_NAME];

	if(reporter == -1)
	{
		MsgAdminsF(1, YELLOW, " >  Server reported %s, reason: %s", name, reason);
		reportername = "Server";
	}
	else
	{
		MsgAdminsF(1, YELLOW, " >  %p reported %s, reason: %s", reporter, name, reason);
		GetPlayerName(reporter, reportername, MAX_PLAYER_NAME);
	}

	format(query, sizeof(query), "\
		INSERT INTO `Reports`\
		(`"#ROW_NAME"`, `"#ROW_REAS"`, `"#ROW_DATE"`, `"#ROW_READ"`, `"#ROW_TYPE"`, `"#ROW_POSX"`, `"#ROW_POSY"`, `"#ROW_POSZ"`, `"#ROW_INFO"`, `"#ROW_BY"`)\
		VALUES('%s', '%s', '%d', '0', '%d', '%.0f', '%.0f', '%.0f', '%s', '%s')",
		name, db_escape(reason), gettime(), type, posx, posy, posz, infostring, reportername);

	db_free_result(db_query(gAccounts, query));
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
			name[MAX_PLAYER_NAME],
			timestamp[12],
			reportread[2],
			reporttype[10],

			colour[9],
			item[(8 + MAX_PLAYER_NAME + 13 + 1)],
			list[(8 + MAX_PLAYER_NAME + 13 + 1) * MAX_REPORTS_PER_PAGE],
			read;

		for(new i; i < rowcount && i < MAX_REPORTS_PER_PAGE; i++)
		{
			db_get_field(result, 0, name, MAX_PLAYER_NAME + 1);
			db_get_field(result, 2, timestamp, 12);
			db_get_field(result, 3, reportread, 2);
			db_get_field(result, 4, reporttype, 2);

			report_NameIndex[playerid][i] = name;
			report_TimestampIndex[playerid][i] = strval(timestamp);

			if(reportread[0] == '0')
				read = 1;

			else
				read = 0;

			if(IsPlayerBanned(name))
			{
				colour = "{FF0000}";
			}
			else
			{
				if(read)
					colour = "{FFFF00}";

				else
					colour = "{FFFFFF}";
			}

			format(item, sizeof(item), "%s%s (%s)\n", colour, name, report_TypeNames[strval(reporttype)]);
			strcat(list, item);

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

ShowReport(playerid, name[], reporttimestamp)
{
	new
		query[128],
		DBResult:result,
		timeval[12],
		reporttype[2],
		posx[8],
		posy[8],
		posz[8],
		date[32],
		tm<timestamp>,
		message[512];

	format(query, sizeof(query), "SELECT * FROM `Reports` WHERE `"#ROW_NAME"` = '%s' AND `"#ROW_DATE"` = '%d'", name, reporttimestamp);
	result = db_query(gAccounts, query);

	db_get_field(result, 1, report_CurrentReason[playerid], 128);
	db_get_field(result, 2, timeval, 12);
	db_get_field(result, 4, reporttype, 2);
	db_get_field(result, 5, posx, 8);
	db_get_field(result, 6, posy, 8);
	db_get_field(result, 7, posz, 8);
	db_get_field(result, 8, report_CurrentInfo[playerid], 128);
	db_get_field(result, 9, report_CurrentReporter[playerid], 128);

	db_free_result(result);

	localtime(Time:strval(timeval), timestamp);
	strftime(date, 64, "%A %b %d %Y at %X", timestamp);

	format(message, sizeof(message), "\
		"#C_YELLOW"Date:\n\t\t"#C_BLUE"%s\n\n\n\
		"#C_YELLOW"Reason:\n\t\t"#C_BLUE"%s", date, report_CurrentReason[playerid]);

	report_CurrentName[playerid][0] = EOS;
	strcat(report_CurrentName[playerid], name);

	report_CurrentType[playerid] = strval(reporttype);

	report_CurrentPos[playerid][0] = floatstr(posx);
	report_CurrentPos[playerid][1] = floatstr(posy);
	report_CurrentPos[playerid][2] = floatstr(posz);


	ShowPlayerDialog(playerid, d_Report, DIALOG_STYLE_MSGBOX, name, message, "Options", "Back");

	format(query, sizeof(query), "UPDATE `Reports` SET `"#ROW_READ"` = '1' WHERE `"#ROW_NAME"` = '%s' AND `"#ROW_DATE"` = '%d'", name, reporttimestamp);
	result = db_query(gAccounts, query);
	db_free_result(result);
}

ShowReportOptions(playerid)
{
	new options[128];

	options = "Ban\nDelete\nDelete all reports of this player\nMark Unread\n";

	if(GetPlayerDataBitmask(playerid) & AdminDuty)
	{
		strcat(options, "Go to position of report\n");

		switch(report_CurrentType[playerid])
		{
			case REPORT_TYPE_TELEPORT:
			{
				strcat(options, "Go to teleport destination\n");
			}
			case REPORT_TYPE_CAMDIST:
			{
				strcat(options, "Go to camera location\n");
				strcat(options, "View camera\n");
			}
			case REPORT_TYPE_CARTELE:
			{
				strcat(options, "Go to vehicle pos\n");
			}
		}
	}
	else
	{
		strcat(options, "(Go on duty to see more options)");	
	}

	ShowPlayerDialog(playerid, d_ReportOptions, DIALOG_STYLE_LIST, report_CurrentName[playerid], options, "Select", "Back");
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


	// Submitting reports


	if(dialogid == d_ReportMenu && response)
	{
		switch(listitem)
		{
			case 0:// Specific player ID (who is online now)
			{
				new
					name[MAX_PLAYER_NAME],
					list[MAX_PLAYERS * (MAX_PLAYER_NAME + 1)];

				foreach(new i : Player)
				{
					GetPlayerName(playerid, name, MAX_PLAYER_NAME);
					strcat(list, name);
					strcat(list, "\n");
				}

				ShowPlayerDialog(playerid, d_ReportPlayerList, DIALOG_STYLE_LIST, "Report Online Player", list, "Report", "Back");
				send_TargetType[playerid] = REPORT_TYPE_PLAYER_ID;
			}
			case 1:// Specific Player Name (Who isn't online now)
			{
				ShowPlayerDialog(playerid, d_ReportNameInput, DIALOG_STYLE_INPUT, "Report Offline Player", "Enter name to report below", "Report", "Back");
				send_TargetType[playerid] = REPORT_TYPE_PLAYER_NAME;
			}
			case 2:// Player that last killed me
			{
				if(!isnull(gLastKilledBy[playerid]))
				{
					send_TargetName[playerid] = gLastKilledBy[playerid];
				}
				else
				{
					if(!isnull(gLastHitBy[playerid]))	
					{
						send_TargetName[playerid] = gLastHitBy[playerid];						
					}
					else
					{
						Msg(playerid, RED, " >  No player could be found.");
						return 1;
					}
				}

				send_TargetPos[playerid][0] = gPlayerDeathPos[playerid][0];
				send_TargetPos[playerid][1] = gPlayerDeathPos[playerid][1];
				send_TargetPos[playerid][2] = gPlayerDeathPos[playerid][2];

				ShowPlayerDialog(playerid, d_ReportReason, DIALOG_STYLE_INPUT, "Enter reason", "Enter the report reason below", "Report", "Back");
				send_TargetType[playerid] = REPORT_TYPE_PLAYER_KILLER;
			}
			case 3: // Player closest to me
			{
				new
					Float:distance = 100.0,
					targetid;

				targetid = GetClosestPlayerFromPlayer(playerid, distance);

				if(!IsPlayerConnected(targetid))
				{
					Msg(playerid, RED, " >  No player could be found within 100m");
					return 1;
				}

				GetPlayerName(targetid, send_TargetName[playerid], MAX_PLAYER_NAME);
				GetPlayerPos(targetid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
	
				ShowPlayerDialog(playerid, d_ReportReason, DIALOG_STYLE_INPUT, "Enter reason", "Enter the report reason below", "Report", "Back");
				send_TargetType[playerid] = REPORT_TYPE_PLAYER_CLOSE;
			}
		}
	}

	if(dialogid == d_ReportPlayerList)
	{
		if(response)
		{
			GetPlayerPos(playerid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
			strmid(send_TargetName[playerid], inputtext, 0, strlen(inputtext));

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
			send_TargetName[playerid][0] = EOS;
			strcat(send_TargetName[playerid], inputtext);

			send_TargetPos[playerid][0] = 0.0;
			send_TargetPos[playerid][1] = 0.0;
			send_TargetPos[playerid][2] = 0.0;

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
			ReportPlayer(send_TargetName[playerid], inputtext, playerid, send_TargetType[playerid], send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2], "");
		}
		else
		{
			ShowReportMenu(playerid);
		}
	}


	// Reading reports


	if(dialogid == d_ReportList && response)
	{
		ShowReport(playerid, report_NameIndex[playerid][listitem], report_TimestampIndex[playerid][listitem]);
		report_CurrentItem[playerid] = listitem;
	}

	if(dialogid == d_Report)
	{
		if(response)
		{
			ShowReportOptions(playerid);
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

					format(query, sizeof(query), "DELETE FROM `Reports` WHERE `"#ROW_NAME"` = '%s' AND `"#ROW_DATE"` = '%d'", report_CurrentName[playerid], report_TimestampIndex[playerid][report_CurrentItem[playerid]]);
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
					if(GetPlayerDataBitmask(playerid) & AdminDuty)
					{
						SetPlayerPos(playerid, report_CurrentPos[playerid][0], report_CurrentPos[playerid][1], report_CurrentPos[playerid][2]);
					}
				}
				case 5:
				{
					switch(report_CurrentType[playerid])
					{
						case REPORT_TYPE_TELEPORT:
						{
							if(GetPlayerDataBitmask(playerid) & AdminDuty)
							{
								new
									Float:x,
									Float:y,
									Float:z;

								sscanf(report_CurrentInfo[playerid], "p<,>fff", x, y, z);
								SetPlayerPos(playerid, x, y, z);
							}
						}
						case REPORT_TYPE_CAMDIST:
						{
							if(GetPlayerDataBitmask(playerid) & AdminDuty)
							{
								new
									Float:x,
									Float:y,
									Float:z;

								sscanf(report_CurrentInfo[playerid], "p<,>fff{fff}", x, y, z);
								SetPlayerPos(playerid, x, y, z);
							}
						}
						case REPORT_TYPE_CARTELE:
						{
							if(GetPlayerDataBitmask(playerid) & AdminDuty)
							{
								new
									Float:x,
									Float:y,
									Float:z;

								sscanf(report_CurrentInfo[playerid], "p<,>fff", x, y, z);
								SetPlayerPos(playerid, x, y, z);
							}
						}
					}
				}
				case 6:
				{
					switch(report_CurrentType[playerid])
					{
						case REPORT_TYPE_CAMDIST:
						{
							if(GetPlayerDataBitmask(playerid) & AdminDuty)
							{
								new
									Float:x,
									Float:y,
									Float:z,
									Float:vx,
									Float:vy,
									Float:vz;

								sscanf(report_CurrentInfo[playerid], "p<,>ffffff", x, y, z, vx, vy, vz);

								SetPlayerPos(playerid, report_CurrentPos[playerid][0], report_CurrentPos[playerid][1], report_CurrentPos[playerid][2]);
								SetPlayerCameraPos(playerid, x, y, z);
								SetPlayerCameraLookAt(playerid, x + vx, y + vy, z + vz);

								Msg(playerid, YELLOW, " >  Type /recam to reset your camera");
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
