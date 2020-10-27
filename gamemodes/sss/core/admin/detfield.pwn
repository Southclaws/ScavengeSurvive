/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_DETFIELD				(128)
#define MAX_DETFIELD_NAME			(64)
#define MAX_DETFIELD_EXCEPTIONS		(32)

/*
	Schema:
		field_list(name, vert1..4, minz, maxz)
		- Contains a list of detection fields.

		field_logs(field, name, pos, time)
		- Contains every log record for each field.
*/

#define DETFIELD_DATABASE			DIRECTORY_MAIN"detfield.db"

#define DETFIELD_TABLE_MAIN			"field_list"
#define FIELD_DETFIELD_NAME			"name"		// 00
#define FIELD_DETFIELD_VERT1		"vert1"		// 01
#define FIELD_DETFIELD_VERT2		"vert2"		// 02
#define FIELD_DETFIELD_VERT3		"vert3" 	// 03
#define FIELD_DETFIELD_VERT4		"vert4"		// 04
#define FIELD_DETFIELD_Z1			"minz"		// 05
#define FIELD_DETFIELD_Z2			"maxz"		// 06
#define FIELD_DETFIELD_EXCEPTIONS	"excps"		// 07
#define FIELD_DETFIELD_ACTIVE		"active"	// 08

enum
{
			FIELD_ID_DETFIELD_NAME,
			FIELD_ID_DETFIELD_VERT1,
			FIELD_ID_DETFIELD_VERT2,
			FIELD_ID_DETFIELD_VERT3,
			FIELD_ID_DETFIELD_VERT4,
			FIELD_ID_DETFIELD_Z1,
			FIELD_ID_DETFIELD_Z2,
			FIELD_ID_DETFIELD_EXCEPTIONS,
			FIELD_ID_DETFIELD_ACTIVE
}

#define DETFIELD_TABLE_LOGS			"field_logs"
#define FIELD_DETLOG_DETFIELD		"field"		// 00
#define FIELD_DETLOG_NAME			"name"		// 01
#define FIELD_DETLOG_POS			"pos"		// 02
#define FIELD_DETLOG_DATE			"time"		// 03
#define FIELD_DETLOG_ACTIVE			"active"	// 04

enum
{
			FIELD_ID_DETLOG_FIELD,
			FIELD_ID_DETLOG_NAME,
			FIELD_ID_DETLOG_POS,
			FIELD_ID_DETLOG_DATE,
			FIELD_ID_DETLOG_ACTIVE
}

enum E_DETLOG_BUFFER_DATA
{
			DETLOG_BUFFER_ROW_ID,
			DETLOG_BUFFER_NAME[MAX_DETFIELD_NAME],
Float:		DETLOG_BUFFER_POS_X,
Float:		DETLOG_BUFFER_POS_Y,
Float:		DETLOG_BUFFER_POS_Z,
			DETLOG_BUFFER_DATE
}


static
			det_Name			[MAX_DETFIELD][MAX_DETFIELD_NAME],
			det_AreaID			[MAX_DETFIELD],
Float:		det_Points			[MAX_DETFIELD][10],
			det_Exceptions		[MAX_DETFIELD][MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME],
			det_ExceptionCount	[MAX_DETFIELD],
Float:		det_MinZ			[MAX_DETFIELD],
Float:		det_MaxZ			[MAX_DETFIELD];

new
   Iterator:det_Index<MAX_DETFIELD>;

static
DB:			det_Database,
DBStatement:det_Stmt_DetfieldAdd,
DBStatement:det_Stmt_DetfieldExists,
DBStatement:det_Stmt_DetfieldDelete,
DBStatement:det_Stmt_DetfieldRename,
DBStatement:det_Stmt_DetfieldRenameRecords,
DBStatement:det_Stmt_DetfieldSetExcps,
DBStatement:det_Stmt_DetfieldLoad,
DBStatement:det_Stmt_DetfieldLogEntry,
DBStatement:det_Stmt_DetfieldLogEntryCount,
DBStatement:det_Stmt_DetfieldLogList,
DBStatement:det_Stmt_DetfieldLogGetName,
DBStatement:det_Stmt_DetfieldLogGetPos,
DBStatement:det_Stmt_DetfieldLogGetTime,
DBStatement:det_Stmt_DetfieldLogDelete,
DBStatement:det_Stmt_DetfieldLogDeleteN,
DBStatement:det_Stmt_DetfieldGetNameLogs;


hook OnScriptInit()
{
	det_Database = db_open_persistent(DETFIELD_DATABASE);

	db_free_result(db_query(det_Database, "CREATE TABLE IF NOT EXISTS "DETFIELD_TABLE_MAIN" (\
		"FIELD_DETFIELD_NAME" TEXT,\
		"FIELD_DETFIELD_VERT1" TEXT,\
		"FIELD_DETFIELD_VERT2" TEXT,\
		"FIELD_DETFIELD_VERT3" TEXT,\
		"FIELD_DETFIELD_VERT4" TEXT,\
		"FIELD_DETFIELD_Z1" REAL,\
		"FIELD_DETFIELD_Z2" REAL,\
		"FIELD_DETFIELD_EXCEPTIONS" TEXT,\
		"FIELD_DETFIELD_ACTIVE" INTEGER)", false));

	db_free_result(db_query(det_Database, "CREATE TABLE IF NOT EXISTS "DETFIELD_TABLE_LOGS" (\
		"FIELD_DETLOG_DETFIELD" TEXT,\
		"FIELD_DETLOG_NAME" TEXT,\
		"FIELD_DETLOG_POS" TEXT,\
		"FIELD_DETLOG_DATE" INTEGER,\
		"FIELD_DETLOG_ACTIVE" INTEGER)", false));

	det_Stmt_DetfieldAdd			= db_prepare(det_Database, "INSERT INTO "DETFIELD_TABLE_MAIN" VALUES(?, ?, ?, ?, ?, ?, ?, ?, 1)");
	det_Stmt_DetfieldExists			= db_prepare(det_Database, "SELECT COUNT(*) FROM "DETFIELD_TABLE_MAIN" WHERE "FIELD_DETFIELD_NAME" = ?");
	det_Stmt_DetfieldDelete			= db_prepare(det_Database, "UPDATE "DETFIELD_TABLE_MAIN" SET "FIELD_DETFIELD_ACTIVE" = 0 WHERE "FIELD_DETFIELD_NAME" = ?");
	det_Stmt_DetfieldRename			= db_prepare(det_Database, "UPDATE "DETFIELD_TABLE_MAIN" SET "FIELD_DETFIELD_NAME" = ? WHERE "FIELD_DETFIELD_NAME" = ?");
	det_Stmt_DetfieldRenameRecords	= db_prepare(det_Database, "UPDATE "DETFIELD_TABLE_LOGS" SET "FIELD_DETLOG_DETFIELD" = ? WHERE "FIELD_DETLOG_DETFIELD" = ?");
	det_Stmt_DetfieldSetExcps		= db_prepare(det_Database, "UPDATE "DETFIELD_TABLE_MAIN" SET "FIELD_DETFIELD_EXCEPTIONS" = ? WHERE "FIELD_DETFIELD_NAME" = ?");
	det_Stmt_DetfieldLoad			= db_prepare(det_Database, "SELECT * FROM "DETFIELD_TABLE_MAIN" WHERE "FIELD_DETFIELD_ACTIVE" = 1");
	det_Stmt_DetfieldLogEntry		= db_prepare(det_Database, "INSERT INTO "DETFIELD_TABLE_LOGS" VALUES(?, ?, ?, ?, 1)");
	det_Stmt_DetfieldLogEntryCount	= db_prepare(det_Database, "SELECT COUNT(*) FROM "DETFIELD_TABLE_LOGS" WHERE "FIELD_DETLOG_DETFIELD" = ?");
	det_Stmt_DetfieldLogList		= db_prepare(det_Database, "SELECT rowid, "FIELD_DETLOG_NAME", "FIELD_DETLOG_POS", "FIELD_DETLOG_DATE" FROM "DETFIELD_TABLE_LOGS" WHERE "FIELD_DETLOG_DETFIELD" = ? AND "FIELD_DETLOG_ACTIVE" = 1 ORDER BY "FIELD_DETLOG_DATE" DESC LIMIT ? OFFSET ? COLLATE NOCASE");
	det_Stmt_DetfieldLogGetName		= db_prepare(det_Database, "SELECT "FIELD_DETLOG_NAME" FROM "DETFIELD_TABLE_LOGS" WHERE "FIELD_DETLOG_DETFIELD" = ? AND rowid = ?");
	det_Stmt_DetfieldLogGetPos		= db_prepare(det_Database, "SELECT "FIELD_DETLOG_POS" FROM "DETFIELD_TABLE_LOGS" WHERE "FIELD_DETLOG_DETFIELD" = ? AND rowid = ?");
	det_Stmt_DetfieldLogGetTime		= db_prepare(det_Database, "SELECT "FIELD_DETLOG_DATE" FROM "DETFIELD_TABLE_LOGS" WHERE "FIELD_DETLOG_DETFIELD" = ? AND rowid = ?");
	det_Stmt_DetfieldLogDelete		= db_prepare(det_Database, "UPDATE "DETFIELD_TABLE_LOGS" SET "FIELD_DETLOG_ACTIVE" = 0 WHERE "FIELD_DETLOG_DETFIELD" = ? AND rowid = ?");
	det_Stmt_DetfieldLogDeleteN		= db_prepare(det_Database, "UPDATE "DETFIELD_TABLE_LOGS" SET "FIELD_DETLOG_ACTIVE" = 0 WHERE "FIELD_DETLOG_DETFIELD" = ? AND "FIELD_DETLOG_NAME" = ?");
	det_Stmt_DetfieldGetNameLogs	= db_prepare(det_Database, "SELECT "FIELD_DETLOG_DETFIELD", "FIELD_DETLOG_DATE" FROM "DETFIELD_TABLE_LOGS" WHERE "FIELD_DETLOG_NAME" = ? ORDER BY "FIELD_DETLOG_DATE" DESC LIMIT ? OFFSET ? COLLATE NOCASE");


	DatabaseTableCheck(det_Database, DETFIELD_TABLE_MAIN, 9);
	DatabaseTableCheck(det_Database, DETFIELD_TABLE_LOGS, 5);

	new
		name[MAX_DETFIELD_NAME],
		vert1[64],
		vert2[64],
		vert3[64],
		vert4[64],
		Float:minz,
		Float:maxz,
		exceptions[MAX_PLAYER_NAME * 32],

		Float:points[10],
		exceptionlist[MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME];

	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_NAME, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_VERT1, DB::TYPE_STRING, vert1, sizeof(vert1));
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_VERT2, DB::TYPE_STRING, vert2, sizeof(vert2));
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_VERT3, DB::TYPE_STRING, vert3, sizeof(vert3));
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_VERT4, DB::TYPE_STRING, vert4, sizeof(vert4));
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_Z1, DB::TYPE_FLOAT, minz);
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_Z2, DB::TYPE_FLOAT, maxz);
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_EXCEPTIONS, DB::TYPE_STRING, exceptions, sizeof(exceptions));

	stmt_execute(det_Stmt_DetfieldLoad);

	while(stmt_fetch_row(det_Stmt_DetfieldLoad))
	{
		if(isnull(name))
			continue;

		sscanf(vert1, "ff", points[00], points[01]);
		sscanf(vert2, "ff", points[02], points[03]);
		sscanf(vert3, "ff", points[04], points[05]);
		sscanf(vert4, "ff", points[06], points[07]);
		points[08] = points[00];
		points[09] = points[01];

		// Temp, to prevent data "leaking" to the next slot.
		for(new i; i < MAX_DETFIELD_EXCEPTIONS; i++)
			exceptionlist[i][0] = EOS;

		sscanf(exceptions, "a<s[24]>[32]", exceptionlist);

		CreateDetectionField(name, points, minz, maxz, exceptionlist);
	}

	Logger_Log("loaded detection fields", Logger_I("count", Iter_Count(det_Index)));

	return 1;
}


/*==============================================================================

	Core

==============================================================================*/


stock CreateDetectionField(const name[MAX_DETFIELD_NAME], const Float:points[10], Float:minz, Float:maxz, const exceptionlist[MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME])
{
	new id = Iter_Free(det_Index);

	if(id == ITER_NONE)
	{
		err("MAX_DETFIELD limit reached.");
		return -1;
	}

	if(!IsValidDetectionFieldName(name))
		return -2;

	det_AreaID[id] = CreateDynamicPolygon(points, minz, maxz, .maxpoints = 10);
	det_Name[id] = name;
	det_Points[id] = points;
	det_MinZ[id] = minz;
	det_MaxZ[id] = maxz;
	det_ExceptionCount[id] = 0;

	for(new i; i < MAX_DETFIELD_EXCEPTIONS; i++)
	{
		if(!isnull(exceptionlist[det_ExceptionCount[id]]))
			det_Exceptions[id][det_ExceptionCount[id]++] = exceptionlist[i];
	}

	Iter_Add(det_Index, id);

	return id;
}

stock DestroyDetectionField(detfieldid)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	DestroyDynamicArea(det_AreaID[detfieldid]);
	det_Name[detfieldid][0] = EOS;

	DestroyDetfieldPoly(detfieldid);

	Iter_Remove(det_Index, detfieldid);

	return 1;
}

stock AddDetectionField(const name[MAX_DETFIELD_NAME], Float:points[10], Float:minz, Float:maxz, const exceptionlist[MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME])
{
	if(DetectionFieldExists(name))
		return -1;

	if(!IsValidDetectionFieldName(name))
		return -2;

	new id = CreateDetectionField(name, points, minz, maxz, exceptionlist);

	if(id < 0)
		return -1;

	new
		vert1[32],
		vert2[32],
		vert3[32],
		vert4[32],
		exceptions[MAX_DETFIELD_EXCEPTIONS * (MAX_PLAYER_NAME + 1) + 1];

	format(vert1, sizeof(vert1), "%f %f", points[0], points[1]);
	format(vert2, sizeof(vert2), "%f %f", points[2], points[3]);
	format(vert3, sizeof(vert3), "%f %f", points[4], points[5]);
	format(vert4, sizeof(vert4), "%f %f", points[6], points[7]);

	for(new i; i < det_ExceptionCount[id]; i++)
	{
		if(i > 0)
			strcat(exceptions, " ");

		strcat(exceptions, exceptionlist[i]);
	}

	stmt_bind_value(det_Stmt_DetfieldAdd, 0, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldAdd, 1, DB::TYPE_STRING, vert1, sizeof(vert1));
	stmt_bind_value(det_Stmt_DetfieldAdd, 2, DB::TYPE_STRING, vert2, sizeof(vert2));
	stmt_bind_value(det_Stmt_DetfieldAdd, 3, DB::TYPE_STRING, vert3, sizeof(vert3));
	stmt_bind_value(det_Stmt_DetfieldAdd, 4, DB::TYPE_STRING, vert4, sizeof(vert4));
	stmt_bind_value(det_Stmt_DetfieldAdd, 5, DB::TYPE_FLOAT, minz);
	stmt_bind_value(det_Stmt_DetfieldAdd, 6, DB::TYPE_FLOAT, maxz);
	stmt_bind_value(det_Stmt_DetfieldAdd, 7, DB::TYPE_STRING, exceptions, sizeof(exceptions));

	if(!stmt_execute(det_Stmt_DetfieldAdd))
		return -4;

	return id;
}

stock RemoveDetectionField(detfieldid)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;


	stmt_bind_value(det_Stmt_DetfieldDelete, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);

	DestroyDetectionField(detfieldid);

	if(!stmt_execute(det_Stmt_DetfieldDelete))
		return 0;

	return 1;
}

stock DetectionFieldExists(const name[])
{
	new count;

	stmt_bind_value(det_Stmt_DetfieldExists, 0, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldExists, 0, DB::TYPE_INTEGER, count);

	if(!stmt_execute(det_Stmt_DetfieldExists))
		return 0;

	stmt_fetch_row(det_Stmt_DetfieldExists);
	
	if(count != 0)
		return 1;

	return 0;
}

stock SetDetectionFieldName(detfieldid, const name[MAX_DETFIELD_NAME])
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	if(DetectionFieldExists(name))
		return -1;

	if(!IsValidDetectionFieldName(name))
		return -2;

	stmt_bind_value(det_Stmt_DetfieldRename, 0, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldRename, 1, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);

	stmt_execute(det_Stmt_DetfieldRename);

	stmt_bind_value(det_Stmt_DetfieldRenameRecords, 0, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldRenameRecords, 1, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);

	stmt_execute(det_Stmt_DetfieldRenameRecords);
	new query[256];

	format(query, sizeof(query), "ALTER TABLE %s RENAME TO %s", det_Name[detfieldid], name);
	db_query(det_Database, query);

	det_Name[detfieldid] = name;

	return 1;
}

stock GetDetectionFieldList(list[], string[], limit, offset)
{
	new
		j,
		count = Iter_Count(det_Index);

	if(offset > count)
		offset = count;

	foreach(new i : det_Index)
	{
		if(j >= offset)
		{
			if(j >= offset + limit)
				break;

			list[j - offset] = i;

			if(i > 0)
				strcat(string, "\n", limit * (MAX_DETFIELD_NAME + 1));

			strcat(string, det_Name[i], limit * (MAX_DETFIELD_NAME + 1));
		}

		j++;
	}

	return j - offset;
}

stock GetDetectionFieldNameLog(name[], string[], limit, offset, len = sizeof(string))
{
	new
		fieldname[MAX_PLAYER_NAME],
		timestamp,
		count;

	stmt_bind_value(det_Stmt_DetfieldGetNameLogs, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(det_Stmt_DetfieldGetNameLogs, 1, DB::TYPE_INTEGER, limit);
	stmt_bind_value(det_Stmt_DetfieldGetNameLogs, 2, DB::TYPE_INTEGER, offset);
	stmt_bind_result_field(det_Stmt_DetfieldGetNameLogs, 0, DB::TYPE_STRING, fieldname, MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldGetNameLogs, 1, DB::TYPE_INTEGER, timestamp);

	if(!stmt_execute(det_Stmt_DetfieldGetNameLogs))
		return 0;

	while(stmt_fetch_row(det_Stmt_DetfieldGetNameLogs))
	{
		format(string, len, "%s%s %s\n", string, fieldname, TimestampToDateTime(timestamp, "%d/%m/%y %X"));
		count++;
	}

	return count;
}

stock GetDetectionFieldLogBuffer(detfieldid, output[][E_DETLOG_BUFFER_DATA], limit, offset)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	new
		rowid,
		name[MAX_PLAYER_NAME],
		pos[32],
		timestamp,
		Float:x,
		Float:y,
		Float:z,
		count;

	stmt_bind_value(det_Stmt_DetfieldLogList, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogList, 1, DB::TYPE_INTEGER, limit);
	stmt_bind_value(det_Stmt_DetfieldLogList, 2, DB::TYPE_INTEGER, offset);

	stmt_bind_result_field(det_Stmt_DetfieldLogList, 0, DB::TYPE_INTEGER, rowid);
	stmt_bind_result_field(det_Stmt_DetfieldLogList, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLogList, 2, DB::TYPE_STRING, pos, sizeof(pos));
	stmt_bind_result_field(det_Stmt_DetfieldLogList, 3, DB::TYPE_INTEGER, timestamp);

	if(!stmt_execute(det_Stmt_DetfieldLogList))
		return -1;

	while(stmt_fetch_row(det_Stmt_DetfieldLogList))
	{
		sscanf(pos, "fff", x, y, z);

		output[count][DETLOG_BUFFER_ROW_ID] = rowid;
		output[count][DETLOG_BUFFER_NAME][0] = EOS;
		strcpy(output[count][DETLOG_BUFFER_NAME], name, MAX_PLAYER_NAME);
		output[count][DETLOG_BUFFER_POS_X] = x;
		output[count][DETLOG_BUFFER_POS_Y] = y;
		output[count][DETLOG_BUFFER_POS_Z] = z;
		output[count][DETLOG_BUFFER_DATE] = timestamp;
		count++;
	}

	return count;
}

stock GetDetectionFields()
{
	return Iter_Count(det_Index);
}

stock GetDetectionFieldLogEntries(detfieldid)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	new count;

	stmt_bind_value(det_Stmt_DetfieldLogEntryCount, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLogEntryCount, 0, DB::TYPE_INTEGER, count);

	if(!stmt_execute(det_Stmt_DetfieldLogEntryCount))
		return 0;

	stmt_fetch_row(det_Stmt_DetfieldLogEntryCount);

	return count;
}

stock GetDetectionFieldExceptions(detfieldid, list[MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME])
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	new i;

	for(i = 0; i < det_ExceptionCount[detfieldid]; i++)
	{
		if(isnull(det_Exceptions[detfieldid][i]))
			break;

		list[i] = det_Exceptions[detfieldid][i];
	}

	return i;
}

stock GetDetectionFieldExceptionsList(detfieldid, list[], length, delimiter = '\n')
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	new i;

	for(i = 0; i < det_ExceptionCount[detfieldid]; i++)
	{
		if(isnull(det_Exceptions[detfieldid][i]))
			break;

		if(i > 0)
			list[strlen(list)] = delimiter;

		strcat(list, det_Exceptions[detfieldid][i], length);
	}

	return i;
}

stock AddDetectionFieldException(detfieldid, const name[MAX_PLAYER_NAME])
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	if(det_ExceptionCount[detfieldid] == MAX_DETFIELD_EXCEPTIONS)
		return -1;

	if(!IsValidUsername(name))
		return -2;

	if(IsNameInExceptionList(detfieldid, name))
		return -3;

	det_Exceptions[detfieldid][det_ExceptionCount[detfieldid]] = name;
	det_ExceptionCount[detfieldid]++;

	UpdateDetectionFieldExceptions(detfieldid);

	return det_ExceptionCount[detfieldid];
}

stock RemoveDetectionFieldExceptionID(detfieldid, exceptionid)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	if(det_ExceptionCount[detfieldid] == 0)
		return -1;

	if(exceptionid > det_ExceptionCount[detfieldid])
		return -2;

	for(new i = exceptionid; i < det_ExceptionCount[detfieldid]; i++)
	{
		if(i + 1 == det_ExceptionCount[detfieldid])
		{
			det_Exceptions[detfieldid][i][0] = EOS;
			break;
		}

		det_Exceptions[detfieldid][i] = det_Exceptions[detfieldid][i + 1];
	}

	det_ExceptionCount[detfieldid]--;
	UpdateDetectionFieldExceptions(detfieldid);

	return det_ExceptionCount[detfieldid];
}

stock RemoveDetectionFieldException(detfieldid, name[MAX_PLAYER_NAME])
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	if(det_ExceptionCount[detfieldid] == 0)
		return -1;

	new found;

	for(new i; i < det_ExceptionCount[detfieldid]; i++)
	{
		if(!found)
		{
			if(!strcmp(det_Exceptions[detfieldid][i], name) && isnull(det_Exceptions[detfieldid][i]))
				found = true;
		}
		else
		{
			if(i + 1 == det_ExceptionCount[detfieldid])
			{
				det_Exceptions[detfieldid][i][0] = EOS;
				break;
			}

			det_Exceptions[detfieldid][i] = det_Exceptions[detfieldid][i + 1];
		}
	}

	det_ExceptionCount[detfieldid]--;
	UpdateDetectionFieldExceptions(detfieldid);

	return det_ExceptionCount[detfieldid];
}

stock GetDetectionFieldLogEntryName(detfieldid, logentry, name[MAX_PLAYER_NAME])
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	stmt_bind_value(det_Stmt_DetfieldLogGetName, 0, DB::TYPE_INTEGER, logentry);
	stmt_bind_value(det_Stmt_DetfieldLogGetName, 1, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLogGetName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(det_Stmt_DetfieldLogGetName))
		return 0;

	stmt_fetch_row(det_Stmt_DetfieldLogGetName);

	return 1;
}

stock GetDetectionFieldLogEntryPos(detfieldid, logentry, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	new pos[32];

	stmt_bind_value(det_Stmt_DetfieldLogGetPos, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogGetPos, 1, DB::TYPE_INTEGER, logentry);
	stmt_bind_result_field(det_Stmt_DetfieldLogGetPos, 0, DB::TYPE_STRING, pos, sizeof(pos));

	if(!stmt_execute(det_Stmt_DetfieldLogGetPos))
		return 0;

	stmt_fetch_row(det_Stmt_DetfieldLogGetPos);

	sscanf(pos, "fff", x, y, z);

	return 1;
}

stock GetDetectionFieldLogEntryTime(detfieldid, logentry)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	new timestamp;

	stmt_bind_value(det_Stmt_DetfieldLogGetTime, 0, DB::TYPE_INTEGER, logentry);
	stmt_bind_value(det_Stmt_DetfieldLogGetTime, 1, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLogGetTime, 0, DB::TYPE_INTEGER, timestamp);

	if(!stmt_execute(det_Stmt_DetfieldLogGetTime))
		return 0;

	stmt_fetch_row(det_Stmt_DetfieldLogGetTime);

	return timestamp;
}

stock DeleteDetectionFieldLogEntry(detfieldid, logentry)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	stmt_bind_value(det_Stmt_DetfieldLogDelete, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogDelete, 1, DB::TYPE_INTEGER, logentry);

	if(!stmt_execute(det_Stmt_DetfieldLogDelete))
		return 0;

	return 1;
}

stock DeleteDetectionFieldLogsOfName(detfieldid, const name[])
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	stmt_bind_value(det_Stmt_DetfieldLogDeleteN, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogDeleteN, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(det_Stmt_DetfieldLogDeleteN))
		return 0;

	return 1;
}


/*==============================================================================

	Internal

==============================================================================*/


hook OnPlayerEnterDynArea(playerid, areaid)
{
	foreach(new i : det_Index)
	{
		if(areaid == det_AreaID[i])
		{
			if(!IsPlayerOnAdminDuty(playerid))
				DetectionFieldLogPlayer(playerid, i);

			if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
			{
				if(GetPlayerAdminLevel(playerid) >= 3)
					ChatMsg(playerid, YELLOW, " >  Entered detection field '%s'", det_Name[i]);
			}
		}
	}
}

DetectionFieldLogPlayer(playerid, detfieldid)
{
	new
		name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	for(new i; i < det_ExceptionCount[detfieldid]; i++)
	{
		if(!strcmp(det_Exceptions[detfieldid][i], name, _, true))
			return 0;
	}

	new
		Float:x,
		Float:y,
		Float:z,
		pos[32],
		timestamp,
		line[MAX_PLAYER_NAME + 36 + 2];

	GetPlayerPos(playerid, x, y, z);
	format(pos, sizeof(pos), "%.2f %.2f %.2f", x, y, z);
	timestamp = gettime();

	stmt_bind_value(det_Stmt_DetfieldLogEntry, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogEntry, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogEntry, 2, DB::TYPE_STRING, pos, sizeof(pos));
	stmt_bind_value(det_Stmt_DetfieldLogEntry, 3, DB::TYPE_INTEGER, timestamp);

	if(!stmt_execute(det_Stmt_DetfieldLogEntry))
		return -1;

	format(line, sizeof(line), "%p, %s\r\n", playerid, TimestampToDateTime(gettime()));

	Logger_Log("player entered detection field",
		Logger_P(playerid),
		Logger_S("field", det_Name[detfieldid])
	);

	return 1;
}

UpdateDetectionFieldExceptions(detfieldid)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	new exceptionlist[MAX_DETFIELD_EXCEPTIONS * (MAX_PLAYER_NAME + 1)];

	for(new i; i < det_ExceptionCount[detfieldid]; i++)
	{
		if(i > 0)
			strcat(exceptionlist, " ");

		strcat(exceptionlist, det_Exceptions[detfieldid][i]);
	}

	stmt_bind_value(det_Stmt_DetfieldSetExcps, 0, DB::TYPE_STRING, exceptionlist, sizeof(exceptionlist));
	stmt_bind_value(det_Stmt_DetfieldSetExcps, 1, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);

	return stmt_execute(det_Stmt_DetfieldSetExcps);
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsValidDetectionField(detfieldid)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	return 1;
}

stock GetTotalDetectionFields()
{
	return Iter_Count(det_Index);
}

stock GetDetectionFieldName(detfieldid, name[MAX_DETFIELD_NAME])
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	name = det_Name[detfieldid];

	return 1;
}

stock GetDetectionFieldPos(detfieldid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	x = (det_Points[detfieldid][0] + det_Points[detfieldid][2] + det_Points[detfieldid][4] + det_Points[detfieldid][6]) / 4;
	y = (det_Points[detfieldid][1] + det_Points[detfieldid][3] + det_Points[detfieldid][5] + det_Points[detfieldid][7]) / 4;
	z = (det_MinZ[detfieldid] + det_MaxZ[detfieldid]) / 2;

	return 1;
}

stock GetDetectionFieldIdFromName(const name[], bool:ignorecase = false)
{
	foreach(new i : det_Index)
	{
		if(!strcmp(name, det_Name[i], ignorecase))
		{
			return i;
		}
	}

	return -1;
}
stock GetDetectionFieldPoints(detfieldid, Float:points[10])
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	points = det_Points[detfieldid];

	return 1;
}

stock GetDetectionFieldMinZ(detfieldid, &Float:minz)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	minz = det_MinZ[detfieldid];

	return 1;
}

stock GetDetectionFieldMaxZ(detfieldid, &Float:maxz)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	maxz = det_MaxZ[detfieldid];

	return 1;
}

stock IsValidDetectionFieldName(const name[])
{
	if(!isalphabetic(name[0]))
		return 0;

	if(!strcmp(name, DETFIELD_TABLE_MAIN))
		return 0;

	new i;

	while(name[i] != EOS)
	{
		if(isalphanumeric(name[i]) || name[i] == '_')
			i++;

		else
			return 0;
	}

	return 1;
}

stock GetDetectionFieldExceptionCount(detfieldid)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	return det_ExceptionCount[detfieldid];
}

stock GetDetectionFieldExceptionName(detfieldid, exceptionid, name[MAX_PLAYER_NAME])
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	if(exceptionid > det_ExceptionCount[detfieldid])
		return -1;

	name = det_Exceptions[detfieldid][exceptionid];

	return 1;
}

stock IsNameInExceptionList(detfieldid, const name[MAX_PLAYER_NAME])
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	for(new i; i < det_ExceptionCount[detfieldid]; i++)
	{
		if(!strcmp(det_Exceptions[detfieldid][i], name) && isnull(det_Exceptions[detfieldid][i]))
			return 1;
	}

	return 0;
}
