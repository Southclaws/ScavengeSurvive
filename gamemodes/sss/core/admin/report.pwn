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


#define MAX_REPORT_REASON_LENGTH	(128)
#define MAX_REPORT_TYPE_LENGTH		(10)
#define MAX_REPORT_INFO_LENGTH		(128)
#define MAX_REPORTS_PER_PAGE		(32)
#define MAX_REPORT_TYPES			(5)
#define ACCOUNTS_TABLE_REPORTS		"Reports"
#define FIELD_REPORTS_NAME			"name"		// 00
#define FIELD_REPORTS_REASON		"reason"	// 01
#define FIELD_REPORTS_DATE			"date"		// 02
#define FIELD_REPORTS_READ			"read"		// 03
#define FIELD_REPORTS_TYPE			"type"		// 04
#define FIELD_REPORTS_POSX			"posx"		// 05
#define FIELD_REPORTS_POSY			"posy"		// 06
#define FIELD_REPORTS_POSZ			"posz"		// 07
#define FIELD_REPORTS_POSW			"world"		// 08
#define FIELD_REPORTS_POSI			"interior"	// 09
#define FIELD_REPORTS_INFO			"info"		// 10
#define FIELD_REPORTS_BY			"by"		// 11
#define FIELD_REPORTS_ACTIVE		"active"	// 12

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

enum
{
	FIELD_ID_REPORTS_NAME,
	FIELD_ID_REPORTS_REASON,
	FIELD_ID_REPORTS_DATE,
	FIELD_ID_REPORTS_READ,
	FIELD_ID_REPORTS_TYPE,
	FIELD_ID_REPORTS_POSX,
	FIELD_ID_REPORTS_POSY,
	FIELD_ID_REPORTS_POSZ,
	FIELD_ID_REPORTS_POSW,
	FIELD_ID_REPORTS_POSI,
	FIELD_ID_REPORTS_INFO,
	FIELD_ID_REPORTS_BY,
	FIELD_ID_REPORTS_ACTIVE
}

enum e_report_list_struct
{
	report_name[MAX_PLAYER_NAME],
	report_type[MAX_REPORT_TYPE_LENGTH],
	report_read,
	report_rowid
}


/*==============================================================================

	Initialisation

==============================================================================*/


hook OnGameModeInit()
{
	//
}


/*==============================================================================

	Core

==============================================================================*/


ReportPlayer(name[], reason[], reporter, type[], Float:posx, Float:posy, Float:posz, world, interior, infostring[])
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

	// ReportInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME
	// ReportInsert, 1, DB::TYPE_STRING, reason, MAX_REPORT_REASON_LENGTH
	// ReportInsert, 2, DB::TYPE_INTEGER, gettime()
	// ReportInsert, 3, DB::TYPE_STRING, type, MAX_REPORT_TYPE_LENGTH
	// ReportInsert, 4, DB::TYPE_FLOAT, posx
	// ReportInsert, 5, DB::TYPE_FLOAT, posy
	// ReportInsert, 6, DB::TYPE_FLOAT, posz
	// ReportInsert, 7, DB::TYPE_INTEGER, world
	// ReportInsert, 8, DB::TYPE_INTEGER, interior
	// ReportInsert, 9, DB::TYPE_STRING, infostring, MAX_REPORT_INFO_LENGTH
	// ReportInsert, 10, DB::TYPE_STRING, reportername, MAX_PLAYER_NAME

	// OnPlayerReported

	return 0;
}

DeleteReport(rowid)
{
	return 0;
}

DeleteReportsOfPlayer(name[])
{
	return 0;
}

DeleteReadReports()
{
	return 0;
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetReportList(list[][e_report_list_struct])
{
	new
		name[MAX_PLAYER_NAME],
		type[MAX_REPORT_TYPE_LENGTH],
		read,
		rowid,
		idx;

	// ReportList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	// ReportList, 1, DB::TYPE_INTEGER, read);
	// ReportList, 2, DB::TYPE_STRING, type, MAX_REPORT_TYPE_LENGTH);
	// ReportList, 3, DB::TYPE_INTEGER, rowid);

	return idx;
}

stock GetReportInfo(rowid, reason[], &date, type[], &Float:posx, &Float:posy, &Float:posz, &world, &interior, info[], reporter[])
{
	// ReportInfo, FIELD_ID_REPORTS_REASON, DB::TYPE_STRING, reason, MAX_REPORT_REASON_LENGTH
	// ReportInfo, FIELD_ID_REPORTS_DATE, DB::TYPE_INTEGER, date
	// ReportInfo, FIELD_ID_REPORTS_TYPE, DB::TYPE_STRING, type, MAX_REPORT_TYPE_LENGTH
	// ReportInfo, FIELD_ID_REPORTS_POSX, DB::TYPE_FLOAT, posx
	// ReportInfo, FIELD_ID_REPORTS_POSY, DB::TYPE_FLOAT, posy
	// ReportInfo, FIELD_ID_REPORTS_POSZ, DB::TYPE_FLOAT, posz
	// ReportInfo, FIELD_ID_REPORTS_POSW, DB::TYPE_INTEGER, world
	// ReportInfo, FIELD_ID_REPORTS_POSI, DB::TYPE_INTEGER, interior
	// ReportInfo, FIELD_ID_REPORTS_INFO, DB::TYPE_STRING, info, MAX_REPORT_INFO_LENGTH
	// ReportInfo, FIELD_ID_REPORTS_BY, DB::TYPE_STRING, reporter, MAX_PLAYER_NAME

	return 1;
}

stock SetReportRead(rowid, read)
{
	return 0;
}

stock GetUnreadReports()
{
	new count;

	return count;
}

stock IsPlayerReported(name[])
{
	new count;

	// ReportNameExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME
	// ReportNameExists, 0, DB::TYPE_INTEGER, count

	if(count > 0)
		return 1;

	return 0;
}
