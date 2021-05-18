/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


static
		send_TargetName				[MAX_PLAYERS][MAX_PLAYER_NAME],
		send_TargetType				[MAX_PLAYERS],
Float:	send_TargetPos				[MAX_PLAYERS][3],
		send_TargetWorld			[MAX_PLAYERS],
		send_TargetInterior			[MAX_PLAYERS],

		report_CurrentReportList	[MAX_PLAYERS][MAX_REPORTS_PER_PAGE][e_report_list_struct],

		report_CurrentReason		[MAX_PLAYERS][MAX_REPORT_REASON_LENGTH],
		report_CurrentType			[MAX_PLAYERS][MAX_REPORT_TYPE_LENGTH],
Float:	report_CurrentPos			[MAX_PLAYERS][3],
		report_CurrentWorld			[MAX_PLAYERS],
		report_CurrentInterior		[MAX_PLAYERS],
		report_CurrentInfo			[MAX_PLAYERS][MAX_REPORT_INFO_LENGTH],
		report_CurrentItem			[MAX_PLAYERS];


/*==============================================================================

	Submitting reports

==============================================================================*/


CMD:report(playerid, params[])
{
	ShowReportMenu(playerid);

	return 1;
}

ShowReportMenu(playerid)
{	
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			switch(listitem)
			{
				case 0: // Specific player ID (who is online now)
				{
					ShowReportOnlinePlayer(playerid);
					send_TargetType[playerid] = 1;
				}
				case 1: // Specific Player Name (Who isn't online now)
				{
					ShowReportOfflinePlayer(playerid);
					send_TargetType[playerid] = 2;
				}
				case 2: // Player that last killed me
				{
					new name[MAX_PLAYER_NAME];

					GetLastKilledBy(playerid, name);

					if(!isnull(name))
					{
						send_TargetName[playerid][0] = EOS;
						send_TargetName[playerid] = name;
					}
					else
					{
						GetLastHitBy(playerid, name);

						if(!isnull(name))
						{
							send_TargetName[playerid][0] = EOS;
							send_TargetName[playerid] = name;
						}
						else
						{
							ChatMsgLang(playerid, RED, "REPNOPFOUND");
							return 1;
						}
					}

					GetPlayerDeathPos(playerid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
					send_TargetWorld[playerid] = -1;
					send_TargetInterior[playerid] = -1;

					ShowReportReasonInput(playerid);
					send_TargetType[playerid] = 3;
				}
				case 3: // Player closest to me
				{
					new
						Float:distance = 100.0,
						targetid;

					targetid = GetClosestPlayerFromPlayer(playerid, distance);

					if(!IsPlayerConnected(targetid) || IsPlayerOnAdminDuty(targetid))
					{
						ChatMsgLang(playerid, RED, "REPNOPF100M");
						return 1;
					}

					GetPlayerName(targetid, send_TargetName[playerid], MAX_PLAYER_NAME);
					GetPlayerPos(targetid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
					send_TargetWorld[playerid] = GetPlayerVirtualWorld(targetid);
					send_TargetInterior[playerid] = GetPlayerInterior(targetid);
		
					ShowReportReasonInput(playerid);
					send_TargetType[playerid] = 4;
				}
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Report a player", "Specific player ID (who is online now)\nSpecific Player Name (Who isn't online now)\nPlayer that last killed me\nPlayer closest to me", "Send", "Cancel");

	return 1;
}

ShowReportOnlinePlayer(playerid)
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

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			GetPlayerPos(playerid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
			send_TargetWorld[playerid] = -1;
			send_TargetInterior[playerid] = -1;
			strmid(send_TargetName[playerid], inputtext, 0, strlen(inputtext));

			ShowReportReasonInput(playerid);
		}
		else
		{
			ShowReportMenu(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Report Online Player", list, "Report", "Back");

	return 1;
}

ShowReportOfflinePlayer(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			send_TargetName[playerid][0] = EOS;
			strcat(send_TargetName[playerid], inputtext);

			send_TargetPos[playerid][0] = 0.0;
			send_TargetPos[playerid][1] = 0.0;
			send_TargetPos[playerid][2] = 0.0;
			send_TargetWorld[playerid] = -1;
			send_TargetInterior[playerid] = -1;

			ShowReportReasonInput(playerid);
		}
		else
		{
			ShowReportMenu(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Report Offline Player", "Enter name to report below", "Report", "Back");

	return 1;
}

ShowReportReasonInput(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			new reporttype[MAX_REPORT_TYPE_LENGTH];

			switch(send_TargetType[playerid])
			{
				case 1: reporttype = REPORT_TYPE_PLAYER_ID;
				case 2: reporttype = REPORT_TYPE_PLAYER_NAME;
				case 3: reporttype = REPORT_TYPE_PLAYER_KILLER;
				case 4: reporttype = REPORT_TYPE_PLAYER_CLOSE;
			}
			ReportPlayer(send_TargetName[playerid], inputtext, playerid, reporttype, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2], send_TargetWorld[playerid], send_TargetInterior[playerid], "");
		}
		else
		{
			ShowReportMenu(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Enter report reason", "Enter the reason for your report below.", "Report", "Back");
}


/*==============================================================================

	Reading reports

==============================================================================*/


ACMD:reports[1](playerid, params[])
{
	new ret;

	ret = ShowListOfReports(playerid);

	if(ret == 0)
		ChatMsg(playerid, YELLOW, " >  There are no reports to show.");

	return 1;
}

ACMD:deletereports[2](playerid, params[])
{
	DeleteReadReports();
	ChatMsg(playerid, YELLOW, " >  All read reports deleted.");

	return 1;
}

ShowListOfReports(playerid)
{
	new totalreports = GetReportList(report_CurrentReportList[playerid]);

	if(totalreports == 0)
		return 0;

	new
		colour[9],
		string[(8 + MAX_PLAYER_NAME + 13 + 1) * MAX_REPORTS_PER_PAGE],
		idx;

	while(idx < totalreports && idx < MAX_REPORTS_PER_PAGE)
	{
		if(IsPlayerBanned(report_CurrentReportList[playerid][idx][report_name]))
			colour = "{FF0000}";

		else if(!report_CurrentReportList[playerid][idx][report_read])
			colour = "{FFFF00}";

		else
			colour = "{FFFFFF}";

		format(string, sizeof(string), "%s%s%s (%s)\n", string, colour, report_CurrentReportList[playerid][idx][report_name], report_CurrentReportList[playerid][idx][report_type]);

		idx++;
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			ShowReport(playerid, listitem);
			report_CurrentItem[playerid] = listitem;
		}
	}

	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Reports", string, "Open", "Close");

	return 1;
}

ShowReport(playerid, reportlistitem)
{
	new
		ret,
		timestamp,
		reporter[MAX_PLAYER_NAME];

	ret = GetReportInfo(report_CurrentReportList[playerid][reportlistitem][report_rowid],
		report_CurrentReason[playerid],
		timestamp, report_CurrentType[playerid],
		report_CurrentPos[playerid][0],
		report_CurrentPos[playerid][1],
		report_CurrentPos[playerid][2],
		report_CurrentWorld[playerid],
		report_CurrentInterior[playerid],
		report_CurrentInfo[playerid],
		reporter);

	if(!ret)
		return 0;

	new message[512];

	format(message, sizeof(message), "\
		"C_YELLOW"Date:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"Reason:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"By:\n\t\t"C_BLUE"%s",
		TimestampToDateTime(timestamp),
		report_CurrentReason[playerid],
		reporter);

	SetReportRead(report_CurrentReportList[playerid][reportlistitem][report_rowid], 1);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			ShowReportOptions(playerid);
		}
		else
		{
			ShowListOfReports(playerid);
		}
	}

	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, report_CurrentReportList[playerid][reportlistitem][report_name], message, "Options", "Back");

	return 1;
}

ShowReportOptions(playerid)
{
	new options[128];

	options = "Ban\nDelete\nDelete all reports of this player\nMark Unread\n";

	if(IsPlayerOnAdminDuty(playerid))
	{
		strcat(options, "Go to position of report\n");

		if(!strcmp(report_CurrentType[playerid], "TELE"))
		{
			strcat(options, "Go to teleport destination\n");
		}

		if(!strcmp(report_CurrentType[playerid], "CAM"))
		{
			strcat(options, "Go to camera location\n");
			strcat(options, "View camera\n");
		}

		if(!strcmp(report_CurrentType[playerid], "VTP"))
		{
			strcat(options, "Go to vehicle pos\n");
		}
	}
	else
	{
		strcat(options, "(Go on duty to see more options)");	
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					ShowReportBanPrompt(playerid);
				}
				case 1:
				{
					DeleteReport(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_rowid]);

					ShowListOfReports(playerid);
				}
				case 2:
				{
					DeleteReportsOfPlayer(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name]);

					ShowListOfReports(playerid);
				}
				case 3:
				{
					SetReportRead(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_rowid], 0);

					ShowListOfReports(playerid);
				}
				case 4:
				{
					if(IsPlayerOnAdminDuty(playerid))
					{
						SetPlayerPos(playerid, report_CurrentPos[playerid][0], report_CurrentPos[playerid][1], report_CurrentPos[playerid][2]);
						SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
						SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
					}
				}
				case 5:
				{
					if(!strcmp(report_CurrentType[playerid], "TELE"))
					{
						if(IsPlayerOnAdminDuty(playerid))
						{
							new
								Float:x,
								Float:y,
								Float:z;

							sscanf(report_CurrentInfo[playerid], "p<,>fff", x, y, z);
							SetPlayerPos(playerid, x, y, z);
							SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
							SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
						}
					}

					if(!strcmp(report_CurrentType[playerid], "CAM"))
					{
						if(IsPlayerOnAdminDuty(playerid))
						{
							new
								Float:x,
								Float:y,
								Float:z;

							sscanf(report_CurrentInfo[playerid], "p<,>fff{fff}", x, y, z);
							SetPlayerPos(playerid, x, y, z);
							SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
							SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
						}
					}

					if(!strcmp(report_CurrentType[playerid], "VTP"))
					{
						if(IsPlayerOnAdminDuty(playerid))
						{
							new
								Float:x,
								Float:y,
								Float:z;

							sscanf(report_CurrentInfo[playerid], "p<,>fff", x, y, z);
							SetPlayerPos(playerid, x, y, z);
							SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
							SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
						}
					}
				}
				case 6:
				{
					if(!strcmp(report_CurrentType[playerid], "CAM"))
					{
						if(IsPlayerOnAdminDuty(playerid))
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
							SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
							SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
							SetPlayerCameraPos(playerid, x, y, z);
							SetPlayerCameraLookAt(playerid, x + vx, y + vy, z + vz);

							ChatMsg(playerid, YELLOW, " >  Type /recam to reset your camera");
						}
					}
				}
			}
		}
		else
		{
			ShowReport(playerid, report_CurrentItem[playerid]);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name], options, "Select", "Back");
}

ShowReportBanPrompt(playerid)
{
	if(GetPlayerAdminLevel(playerid) < 2)
	{
		ChatMsg(playerid, RED, "You do not have permission to ban players.");
		ShowReportOptions(playerid);

		return 0;
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			new duration;

			if(!strcmp(inputtext, "forever", true))
				duration = 0;

			else
				duration = GetDurationFromString(inputtext);

			if(duration == -1)
			{
				ShowReportBanPrompt(playerid);
				return 0;
			}

			BanPlayerByName(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name], report_CurrentReason[playerid], playerid, duration);
			ShowListOfReports(playerid);
		}
		else
		{
			ShowReportOptions(playerid);
		}
	}

	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Please enter ban duration", "Enter the ban duration below. You can type a number then one of either: 'days', 'weeks' or 'months'. Type 'forever' for perma-ban.", "Continue", "Cancel");

	return 1;
}
