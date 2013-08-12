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

ACMD:reports[1](playerid, params[])
{
	new ret;

	ret = ShowListOfReports(playerid);

	if(ret == 0)
		Msg(playerid, YELLOW, " >  There are no reports to show.");

	return 1;
}

ShowReportMenu(playerid)
{	
	ShowPlayerDialog(playerid, d_ReportMenu, DIALOG_STYLE_LIST, "Report a player", "Specific player ID (who is online now)\nSpecific Player Name (Who isn't online now)\nPlayer that last killed me\nPlayer closest to me", "Send", "Cancel");
}

ReportPlayer(name[], reason[], reporter, type, Float:posx, Float:posy, Float:posz, infostring[])
{
	new reportername[MAX_PLAYER_NAME];

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

	stmt_bind_value(gStmt_ReportInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(gStmt_ReportInsert, 1, DB::TYPE_STRING, reason, 128);
	stmt_bind_value(gStmt_ReportInsert, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(gStmt_ReportInsert, 3, DB::TYPE_INTEGER, type);
	stmt_bind_value(gStmt_ReportInsert, 4, DB::TYPE_FLOAT, posx);
	stmt_bind_value(gStmt_ReportInsert, 5, DB::TYPE_FLOAT, posy);
	stmt_bind_value(gStmt_ReportInsert, 6, DB::TYPE_FLOAT, posz);
	stmt_bind_value(gStmt_ReportInsert, 7, DB::TYPE_STRING, infostring, 128);
	stmt_bind_value(gStmt_ReportInsert, 8, DB::TYPE_STRING, reportername, MAX_PLAYER_NAME);

	if(stmt_execute(gStmt_ReportInsert))
	{
		return 1;
	}

	return 0;
}

DeleteReport(name[], timestamp)
{
	if(!IsPlayerReported(name))
		return 0;

	stmt_bind_value(gStmt_ReportDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(gStmt_ReportDelete, 1, DB::TYPE_INTEGER, timestamp);

	if(stmt_execute(gStmt_ReportDelete))
		return 1;

	return 0;
}

DeleteReportsOfPlayer(name[])
{
	if(!IsPlayerReported(name))
		return 0;

	stmt_bind_value(gStmt_ReportDeleteName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(gStmt_ReportDeleteName))
		return 1;

	return 0;
}

ShowListOfReports(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		timestamp,
		reportread,
		reporttype,

		colour[9],
		item[(8 + MAX_PLAYER_NAME + 13 + 1)],
		list[(8 + MAX_PLAYER_NAME + 13 + 1) * MAX_REPORTS_PER_PAGE],
		index;

	stmt_bind_result_field(gStmt_ReportList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_ReportList, 2, DB::TYPE_INTEGER, timestamp);
	stmt_bind_result_field(gStmt_ReportList, 3, DB::TYPE_INTEGER, reportread);
	stmt_bind_result_field(gStmt_ReportList, 4, DB::TYPE_INTEGER, reporttype);
	stmt_execute(gStmt_ReportList);

	while(stmt_fetch_row(gStmt_ReportList) && index < MAX_REPORTS_PER_PAGE)
	{
		report_NameIndex[playerid][index] = name;
		report_TimestampIndex[playerid][index] = timestamp;

		if(IsPlayerBanned(name))
		{
			colour = "{FF0000}";
		}
		else
		{
			if(!reportread)
				colour = "{FFFF00}";

			else
				colour = "{FFFFFF}";
		}

		format(item, sizeof(item), "%s%s (%s)\n", colour, name, report_TypeNames[reporttype]);
		strcat(list, item);

		index++;
	}

	ShowPlayerDialog(playerid, d_ReportList, DIALOG_STYLE_LIST, "Reports", list, "Open", "Close");

	return 1;
}

ShowReport(playerid, name[MAX_PLAYER_NAME], timestamp)
{
	stmt_bind_value(gStmt_ReportInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(gStmt_ReportInfo, 1, DB::TYPE_INTEGER, timestamp);

	stmt_bind_result_field(gStmt_ReportInfo, 1, DB::TYPE_STRING, report_CurrentReason[playerid], 128);
	stmt_bind_result_field(gStmt_ReportInfo, 4, DB::TYPE_INTEGER, report_CurrentType[playerid]);
	stmt_bind_result_field(gStmt_ReportInfo, 5, DB::TYPE_FLOAT, report_CurrentPos[playerid][0]);
	stmt_bind_result_field(gStmt_ReportInfo, 6, DB::TYPE_FLOAT, report_CurrentPos[playerid][1]);
	stmt_bind_result_field(gStmt_ReportInfo, 7, DB::TYPE_FLOAT, report_CurrentPos[playerid][2]);
	stmt_bind_result_field(gStmt_ReportInfo, 8, DB::TYPE_STRING, report_CurrentInfo[playerid], 128);
	stmt_bind_result_field(gStmt_ReportInfo, 9, DB::TYPE_STRING, report_CurrentReporter[playerid], MAX_PLAYER_NAME);

	if(stmt_execute(gStmt_ReportInfo))
	{
		stmt_fetch_row(gStmt_ReportInfo);

		new message[512];

		format(message, sizeof(message), "\
			"#C_YELLOW"Date:\n\t\t"#C_BLUE"%s\n\n\n\
			"#C_YELLOW"Reason:\n\t\t"#C_BLUE"%s\n\n\n\
			"#C_YELLOW"By:\n\t\t"#C_BLUE"%s",
			TimestampToDateTime(timestamp), report_CurrentReason[playerid], report_CurrentReporter[playerid]);

		report_CurrentName[playerid] = name;

		ShowPlayerDialog(playerid, d_Report, DIALOG_STYLE_MSGBOX, name, message, "Options", "Back");

		SetReportRead(name, timestamp, 1);

		return 1;
	}

	return 0;
}

SetReportRead(name[], timestamp, read)
{
	stmt_bind_value(gStmt_ReportSetRead, 0, DB::TYPE_INTEGER, read);
	stmt_bind_value(gStmt_ReportSetRead, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(gStmt_ReportSetRead, 2, DB::TYPE_INTEGER, timestamp);

	if(stmt_execute(gStmt_ReportSetRead))
		return 1;

	return 0;
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

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{


	// Submitting reports


	if(dialogid == d_ReportMenu && response)
	{
		switch(listitem)
		{
			case 0: // Specific player ID (who is online now)
			{
				new
					name[MAX_PLAYER_NAME],
					list[MAX_PLAYERS * (MAX_PLAYER_NAME + 1)];

				foreach(new i : Player)
				{
					GetPlayerName(i, name, MAX_PLAYER_NAME);
					strcat(list, name);
					strcat(list, "\n");
				}

				ShowPlayerDialog(playerid, d_ReportPlayerList, DIALOG_STYLE_LIST, "Report Online Player", list, "Report", "Back");
				send_TargetType[playerid] = REPORT_TYPE_PLAYER_ID;
			}
			case 1: // Specific Player Name (Who isn't online now)
			{
				ShowPlayerDialog(playerid, d_ReportNameInput, DIALOG_STYLE_INPUT, "Report Offline Player", "Enter name to report below", "Report", "Back");
				send_TargetType[playerid] = REPORT_TYPE_PLAYER_NAME;
			}
			case 2: // Player that last killed me
			{
				if(!isnull(gPlayerData[playerid][ply_LastKilledBy]))
				{
					send_TargetName[playerid][0] = EOS;
					strcat(send_TargetName[playerid], gPlayerData[playerid][ply_LastKilledBy]);
				}
				else
				{
					if(!isnull(gPlayerData[playerid][ply_LastHitBy]))
					{
						send_TargetName[playerid][0] = EOS;
						strcat(send_TargetName[playerid], gPlayerData[playerid][ply_LastHitBy]);
					}
					else
					{
						Msg(playerid, RED, " >  No player could be found.");
						return 1;
					}
				}

				send_TargetPos[playerid][0] = gPlayerData[playerid][ply_DeathPosX];
				send_TargetPos[playerid][1] = gPlayerData[playerid][ply_DeathPosY];
				send_TargetPos[playerid][2] = gPlayerData[playerid][ply_DeathPosZ];

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
					DeleteReport(report_CurrentName[playerid], report_TimestampIndex[playerid][report_CurrentItem[playerid]]);

					ShowListOfReports(playerid);
				}
				case 2:
				{
					DeleteReportsOfPlayer(report_CurrentName[playerid]);

					ShowListOfReports(playerid);
				}
				case 3:
				{
					SetReportRead(report_CurrentName[playerid], report_TimestampIndex[playerid][report_CurrentItem[playerid]], 0);

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

GetUnreadReports()
{
	new count;

	stmt_bind_result_field(gStmt_ReportGetUnread, 0, DB::TYPE_INTEGER, count);	
	stmt_execute(gStmt_ReportGetUnread);
	stmt_fetch_row(gStmt_ReportGetUnread);

	return count;
}

IsPlayerReported(name[])
{
	new count;

	stmt_bind_value(gStmt_ReportNameExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_ReportNameExists, 0, DB::TYPE_INTEGER, count);
	stmt_execute(gStmt_ReportNameExists);
	stmt_fetch_row(gStmt_ReportNameExists);

	if(count > 0)
		return 1;

	return 0;
}
