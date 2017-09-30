/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


#define MAX_REPORT_REASON_LENGTH	(128)
#define MAX_REPORT_TYPE_LENGTH		(10)
#define MAX_REPORT_INFO_LENGTH		(128)
#define MAX_REPORTS_PER_PAGE		(32)
#define MAX_REPORT_TYPES			(5)

// Report types
#define REPORT_TYPE_PLAYER_ID		"PLY ID"
#define REPORT_TYPE_PLAYER_NAME		"PLY NAME"
#define REPORT_TYPE_PLAYER_CLOSE	"PLY CLOSE"
#define REPORT_TYPE_PLAYER_KILLER	"PLY KILL"
#define REPORT_TYPE_TELEPORT		"TELE"
#define REPORT_TYPE_SWIMFLY			"FLY"
#define REPORT_TYPE_VHEALTH			"VHP"
#define REPORT_TYPE_CAMDIST			"CAM"
#define REPORT_TYPE_CARNITRO		"NOS"
#define REPORT_TYPE_CARHYDRO		"HYDRO"
#define REPORT_TYPE_CARTELE			"VTP"
#define REPORT_TYPE_HACKTRAP		"TRAP"
#define REPORT_TYPE_LOCKEDCAR		"LCAR"
#define REPORT_TYPE_AMMO			"AMMO"
#define REPORT_TYPE_SHOTANIM		"ANIM"
#define REPORT_TYPE_BADHITOFFSET	"BHIT"
#define REPORT_TYPE_BAD_SHOT_WEAP	"BSHT"


/*==============================================================================

	Core

==============================================================================*/


stock ReportPlayer(name[], reason[], reporter, type[], Float:posx, Float:posy, Float:posz, world, interior, infostring[])
{
	new reportername[MAX_PLAYER_NAME];

	if(reporter == -1)
	{
		ChatMsgAdmins(1, YELLOW, " >  Server reported %s, reason: %s", name, reason);
		reportername = "Server";
	}
	else
	{
		ChatMsgAdmins(1, YELLOW, " >  %p reported %s, reason: %s", reporter, name, reason);
		GetPlayerName(reporter, reportername, MAX_PLAYER_NAME);
	}

	ReportIO_Create(name, reason, gettime(), type, posx, posy, posz, world, interior, infostring, reportername);

	return 0;
}

stock DeleteReport(id[])
{
	return ReportIO_Remove(id);
}

stock DeleteReportsOfPlayer(name[])
{
	return ReportIO_RemoveOfName(name);
}

stock DeleteReadReports()
{
	return ReportIO_RemoveRead();
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetReportList(playerid, limit, offset, callback[])
{
	return ReportIO_GetList(playerid, limit, offset, callback);
}

stock GetReportInfo(playerid, name[], callback[])
{
	return ReportIO_GetInfo(playerid, name, callback);
}

stock SetReportRead(id[], read)
{
	return ReportIO_SetRead(id, read);
}

stock GetUnreadReports()
{
	new
		count,
		ret;

	ret = ReportIO_GetUnread(count);
	if(ret)
		err("ReportIO_GetUnread failed: %d", ret);

	return count;
}

stock IsPlayerReported(name[])
{
	new
		reported,
		ret;

	ret = GetAccountReported(name, reported);
	if(ret)
		err("GetAccountReported failed: %d", ret);

	return reported;
}
