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


static
		send_TargetName				[MAX_PLAYERS][MAX_PLAYER_NAME],
		send_TargetType				[MAX_PLAYERS],
Float:	send_TargetPos				[MAX_PLAYERS][3],
		send_TargetWorld			[MAX_PLAYERS],
		send_TargetInterior			[MAX_PLAYERS],

		report_CurrentReportList	[MAX_PLAYERS][MAX_REPORTS_PER_PAGE][GEID_LEN],

		report_CurrentReason		[MAX_PLAYERS][MAX_REPORT_REASON_LENGTH],
		report_CurrentType			[MAX_PLAYERS][MAX_REPORT_TYPE_LENGTH],
Float:	report_CurrentPos			[MAX_PLAYERS][3],
		report_CurrentWorld			[MAX_PLAYERS],
		report_CurrentInterior		[MAX_PLAYERS],
		report_CurrentInfo			[MAX_PLAYERS][MAX_REPORT_INFO_LENGTH],
		report_CurrentItem			[MAX_PLAYERS];


forward OnReportList(playerid, totalreports, listitems, index, dialog_string_key[], idlist_string_key[]);
forward OnReportInfo(playerid, name[], reason[], date, read, type, Float:posx, Float:posy, Float:posz, posw, posi, info[], by[], active);


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
	Dialog_Show(playerid, ReportMenu, DIALOG_STYLE_LIST, "Report a player", "Specific player ID (who is online now)\nSpecific Player Name (Who isn't online now)\nPlayer that last killed me\nPlayer closest to me", "Send", "Cancel");
	return 1;
}

Dialog:ReportMenu(playerid, response, listitem, inputtext[])
{
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

				if(!IsPlayerConnected(targetid))
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

	return 0;
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

	Dialog_Show(playerid, ReportOnlinePlayer, DIALOG_STYLE_LIST, "Report Online Player", list, "Report", "Back");

	return 1;
}

Dialog:ReportOnlinePlayer(playerid, response, listitem, inputtext[])
{
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

ShowReportOfflinePlayer(playerid)
{
	Dialog_Show(playerid, ReportOfflinePlayer, DIALOG_STYLE_INPUT, "Report Offline Player", "Enter name to report below", "Report", "Back");

	return 1;
}

Dialog:ReportOfflinePlayer(playerid, response, listitem, inputtext[])
{
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

ShowReportReasonInput(playerid)
{
	Dialog_Show(playerid, ReportReasonInput, DIALOG_STYLE_INPUT, "Enter report reason", "Enter the reason for your report below.", "Report", "Back");
}

Dialog:ReportReasonInput(playerid, response, listitem, inputtext[])
{
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
	return ReportIO_GetList(playerid, MAX_REPORTS_PER_PAGE, 0, "OnReportList");
}

public OnReportList(playerid, totalreports, listitems, index, dialog_string_key[], idlist_string_key[])
{
	// Dialog_Show(playerid, ListOfReports, DIALOG_STYLE_LIST, "Reports", string, "Open", "Close");
}

Dialog:ListOfReports(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		// get id from idmap (from idlist_string_key)
		ShowReport(playerid, listitem);
		report_CurrentItem[playerid] = listitem;
	}
}

ShowReport(playerid, id[])
{
	return ReportIO_GetInfo(playerid, id, "OnReportInfo");
}

public OnReportInfo(playerid, name[], reason[], date, read, type, Float:posx, Float:posy, Float:posz, posw, posi, info[], by[], active)
{
/*
	new message[512];
	format(message, sizeof(message), "\
		"C_YELLOW"Date:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"Reason:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"By:\n\t\t"C_BLUE"%s",
		TimestampToDateTime(timestamp),
		report_CurrentReason[playerid],
		reporter);
	SetReportRead(report_CurrentReportList[playerid][reportlistitem][report_rowid], 1);
	Dialog_Show(playerid, Report, DIALOG_STYLE_MSGBOX, report_CurrentReportList[playerid][reportlistitem][report_name], message, "Options", "Back");
*/
}

Dialog:Report(playerid, response, listitem, inputtext[])
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

	Dialog_Show(playerid, ReportOptions, DIALOG_STYLE_LIST, report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name], options, "Select", "Back");
}

Dialog:ReportOptions(playerid, response, listitem, inputtext[])
{
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

ShowReportBanPrompt(playerid)
{
	if(GetPlayerAdminLevel(playerid) < 2)
	{
		ChatMsg(playerid, RED, "You do not have permission to ban players.");
		ShowReportOptions(playerid);

		return 0;
	}

	Dialog_Show(playerid, BanPrompt, DIALOG_STYLE_INPUT, "Please enter ban duration", "Enter the ban duration below. You can type a number then one of either: 'days', 'weeks' or 'months'. Type 'forever' for perma-ban.", "Continue", "Cancel");

	return 1;
}

Dialog:BanPrompt(playerid, response, listitem, inputtext[])
{
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

	return 0;
}
