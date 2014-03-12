#include <YSI\y_hooks>


#define MAX_DETFIELD				(128)
#define MAX_DETFIELD_NAME			(64)
#define MAX_DETFIELD_EXCEPTIONS		(32)
#define MAX_DETFIELD_PAGESIZE		(20)
#define MAX_DETFIELD_LOG_PAGESIZE	(32)

#define DETFIELD_DATABASE			"SSS/detfield.db"
#define DETFIELD_TABLE_MAIN			"detfield"

#define FIELD_DETFIELD_NAME			"name"		// 00
#define FIELD_DETFIELD_VERT1		"vert1"		// 01
#define FIELD_DETFIELD_VERT2		"vert2"		// 02
#define FIELD_DETFIELD_VERT3		"vert3" 	// 03
#define FIELD_DETFIELD_VERT4		"vert4"		// 04
#define FIELD_DETFIELD_Z1			"minz"		// 05
#define FIELD_DETFIELD_Z2			"maxz"		// 06
#define FIELD_DETFIELD_EXCEPTIONS	"excps"		// 07

enum
{
	FIELD_ID_DETFIELD_NAME,
	FIELD_ID_DETFIELD_VERT1,
	FIELD_ID_DETFIELD_VERT2,
	FIELD_ID_DETFIELD_VERT3,
	FIELD_ID_DETFIELD_VERT4,
	FIELD_ID_DETFIELD_Z1,
	FIELD_ID_DETFIELD_Z2,
	FIELD_ID_DETFIELD_EXCEPTIONS
}

#define FIELD_DETLOG_NAME			"name"		// 00
#define FIELD_DETLOG_POS			"pos"		// 01
#define FIELD_DETLOG_DATE			"time"		// 02

enum
{
	FIELD_ID_DETLOG_NAME,
	FIELD_ID_DETLOG_POS,
	FIELD_ID_DETLOG_DATE
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
Iterator:	det_Index<MAX_DETFIELD>;

static stock
DB:			det_Database,
DBStatement:det_Stmt_DetfieldAdd,
DBStatement:det_Stmt_DetfieldAddTable,
DBStatement:det_Stmt_DetfieldExists,
DBStatement:det_Stmt_DetfieldDelete,
DBStatement:det_Stmt_DetfieldRename,
DBStatement:det_Stmt_DetfieldSetExcps,
DBStatement:det_Stmt_DetfieldLoad,
DBStatement:det_Stmt_DetfieldLogEntry,
DBStatement:det_Stmt_DetfieldLogList,
DBStatement:det_Stmt_DetfieldLogGetName,
DBStatement:det_Stmt_DetfieldLogGetPos,
DBStatement:det_Stmt_DetfieldLogGetTime,
DBStatement:det_Stmt_DetfieldLogDelete,
DBStatement:det_Stmt_DetfieldLogDeleteN,
DBStatement:det_Stmt_DetfieldGet;


/*==============================================================================

	Core

==============================================================================*/


stock CreateDetectionField(name[MAX_DETFIELD_NAME], Float:points[10], Float:minz, Float:maxz, exceptionlist[MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME])
{
	new id = Iter_Free(det_Index);

	if(id == -1)
	{
		print("ERROR: MAX_DETFIELD limit reached.");
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

stock AddDetectionField(name[MAX_DETFIELD_NAME], Float:points[10], Float:minz, Float:maxz, exceptionlist[MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME])
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

	stmt_bind_value(det_Stmt_DetfieldAddTable, 0, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);

	if(!stmt_execute(det_Stmt_DetfieldAddTable))
		return -5;

	return id;
}

stock RemoveDetectionField(detfieldid)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	stmt_bind_value(det_Stmt_DetfieldDelete, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);

	stmt_execute(det_Stmt_DetfieldDelete);

	new query[256];

	format(query, sizeof(query), "DROP TABLE %s", det_Name[detfieldid]);
	db_query(det_Database, query);

	DestroyDetectionField(detfieldid);

	return 1;
}

stock DetectionFieldExists(name[])
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

stock SetDetectionFieldName(detfieldid, name[MAX_DETFIELD_NAME])
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
				strcat(string, "\n", (limit + offset) * (MAX_DETFIELD_NAME + 1));

			strcat(string, det_Name[i], (limit + offset) * (MAX_DETFIELD_NAME + 1));
		}

		j++;
	}

	return j - offset;
}

stock GetDetectionFieldLog(detfieldid, output[], limit, offset)
{
	if(!Iter_Contains(det_Index, detfieldid))
		return 0;

	new
		line[MAX_PLAYER_NAME + 18 + 2],
		name[MAX_PLAYER_NAME],
		timestamp,
		count;

	stmt_bind_value(det_Stmt_DetfieldLogList, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogList, 1, DB::TYPE_INTEGER, limit);
	stmt_bind_value(det_Stmt_DetfieldLogList, 2, DB::TYPE_INTEGER, offset);

	stmt_bind_result_field(det_Stmt_DetfieldLogList, FIELD_ID_DETLOG_NAME, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLogList, FIELD_ID_DETLOG_DATE, DB::TYPE_INTEGER, timestamp);

	if(!stmt_execute(det_Stmt_DetfieldLogList))
		return -1;

	while(stmt_fetch_row(det_Stmt_DetfieldLogList))
	{
		format(line, sizeof(line), "%s %s\n", name, TimestampToDateTime(timestamp, "%d/%m/%y %X"));
		strcat(output, line, MAX_DETFIELD_LOG_PAGESIZE * sizeof(line));
		count++;
	}

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

stock AddDetectionFieldException(detfieldid, name[MAX_PLAYER_NAME])
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

	stmt_bind_value(det_Stmt_DetfieldLogGetName, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogGetName, 1, DB::TYPE_INTEGER, logentry);
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

	stmt_bind_value(det_Stmt_DetfieldLogGetTime, 0, DB::TYPE_STRING, det_Name[detfieldid], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogGetTime, 1, DB::TYPE_INTEGER, logentry);
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

stock DeleteDetectionFieldLogsOfName(detfieldid, name[MAX_PLAYER_NAME])
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


public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : det_Index)
	{
		if(areaid == det_AreaID[i])
		{
			if(!IsPlayerOnAdminDuty(playerid))
			{
				DetectionFieldLogPlayer(playerid, i);

				if(GetPlayerAdminLevel(playerid) >= 3)
					MsgF(playerid, YELLOW, " >  Entered detection field '%s'", det_Name[i]);
			}
		}
	}

	return CallLocalFunction("det_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea det_OnPlayerEnterDynamicArea
forward det_OnPlayerEnterDynamicArea(playerid, areaid);

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

	printf("[DET] %p entered %s at %s", playerid, det_Name[detfieldid], TimestampToDateTime(gettime()));

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

hook OnGameModeInit()
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
		"FIELD_DETFIELD_EXCEPTIONS" TEXT)", false));

	det_Stmt_DetfieldAdd		= db_prepare(det_Database, "INSERT INTO "DETFIELD_TABLE_MAIN" VALUES(?, ?, ?, ?, ?, ?, ?, ?)");
	det_Stmt_DetfieldAddTable	= db_prepare(det_Database, "CREATE TABLE IF NOT EXISTS ? ("FIELD_DETLOG_NAME" TEXT,"FIELD_DETLOG_POS" TEXT,"FIELD_DETLOG_DATE" TEXT)");
	det_Stmt_DetfieldExists		= db_prepare(det_Database, "SELECT COUNT(*) FROM "DETFIELD_TABLE_MAIN" WHERE "FIELD_DETFIELD_NAME" = ?");
	det_Stmt_DetfieldDelete		= db_prepare(det_Database, "DELETE FROM "DETFIELD_TABLE_MAIN" WHERE "FIELD_DETFIELD_NAME" = ?");
	det_Stmt_DetfieldRename		= db_prepare(det_Database, "UPDATE "DETFIELD_TABLE_MAIN" SET "FIELD_DETFIELD_NAME" = ? WHERE "FIELD_DETFIELD_NAME" = ?");
	det_Stmt_DetfieldSetExcps	= db_prepare(det_Database, "UPDATE "DETFIELD_TABLE_MAIN" SET "FIELD_DETFIELD_EXCEPTIONS" = ? WHERE "FIELD_DETFIELD_NAME" = ?");
	det_Stmt_DetfieldLoad		= db_prepare(det_Database, "SELECT * FROM "DETFIELD_TABLE_MAIN"");
	det_Stmt_DetfieldLogEntry	= db_prepare(det_Database, "INSERT INTO ? VALUES(?, ?, ?)");
	det_Stmt_DetfieldLogList	= db_prepare(det_Database, "SELECT * FROM ? ORDER BY "FIELD_DETLOG_DATE" DESC LIMIT ? OFFSET ? COLLATE NOCASE");
	det_Stmt_DetfieldLogGetName	= db_prepare(det_Database, "SELECT "FIELD_DETLOG_NAME" FROM ? WHERE rowid = ?");
	det_Stmt_DetfieldLogGetPos	= db_prepare(det_Database, "SELECT "FIELD_DETLOG_POS" FROM ? WHERE rowid = ?");
	det_Stmt_DetfieldLogGetTime	= db_prepare(det_Database, "SELECT "FIELD_DETLOG_DATE" FROM ? WHERE rowid = ?");
	det_Stmt_DetfieldLogDelete	= db_prepare(det_Database, "DELETE FROM ? WHERE rowid = ?");
	det_Stmt_DetfieldLogDeleteN	= db_prepare(det_Database, "DELETE FROM ? WHERE "FIELD_DETLOG_NAME" = ?");


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

		sscanf(exceptions, "a<s[24]>[32]", exceptionlist);

		CreateDetectionField(name, points, minz, maxz, exceptionlist);
	}

	printf("Loaded %d Detection Fields\n", Iter_Count(det_Index));

	return 1;
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

stock GetDetectionFieldIdFromName(name[], bool:ignorecase = false)
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

stock IsValidDetectionFieldName(name[])
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

stock IsNameInExceptionList(detfieldid, name[MAX_PLAYER_NAME])
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
