/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


/*==============================================================================


	Southclaws' Terrain Painting Tool

		Paint objects directly onto the terrain using the heightmap plugin from
		Kalcor (MapAndreas). Includes a polygon selection tool for painting on
		specific areas as well as brush size and density settings.


==============================================================================*/


#include <a_samp>
#include <streamer>
#include <sscanf2>
#include <zcmd>
#include <YSI\y_timers>
#include "../scripts/utils/math.pwn"
#include "../scripts/API/Line/Line.pwn"
#include <mapandreas>


#define MAX_FOLIAGE_OBJECTS (65535)
#define INTERACTION_KEYTEXT "~k~~PED_LOCK_TARGET~"
#define INTERACTION_KEYCODE (128)
#define MAX_SELECTION_NODES (128)
#define OUTPUT_FILE         "Foliage.pwn"


enum
{
		CREATE_MODE_NONE,
		CREATE_MODE_FOLIAGE,
		CREATE_MODE_SELECTION
}

enum
{
Float:  COORD_X,
Float:  COORD_Y,
Float:  COORD_Z
}

enum E_OBJECT_TYPE_DATA
{
		fol_modelId,
		fol_spawnRate,
Float:  fol_zOffset
}

enum E_SELECTION_NODE_DATA
{
		sel_objId,
Float:  sel_posX,
Float:  sel_posY,
Float:  sel_posZ
}


new
		fol_ObjectTypes[][E_OBJECT_TYPE_DATA]=
		{
			{647, 100, 0.0},
			{692, 100, 0.0},
			{759, 100, 0.0},
			{760, 100, 0.0},
			{762, 100, 0.0},
			{800, 100, -0.5},
			{801, 100, 0.0},
			{802, 100, 0.0},
			{803, 100, 0.0},
			{804, 100, 0.0},
			{805, 100, 0.0},
			{806, 100, 0.0},
			{807, 100, 0.0},
			{808, 100, 0.0},
			{809, 100, 0.0},
			{810, 100, 0.0},
			{811, 100, 0.0},
			{812, 100, 0.0},
			{813, 100, 0.0},
			{814, 100, 0.0},
			{815, 100, 0.0},
			{816, 100, 0.0},
			{818, 100, 0.0},
			{819, 100, 0.0},
			{820, 100, 0.0},
			{821, 100, 0.0},
			{822, 100, 0.0},
			{823, 100, 0.0},
			{824, 100, 0.0},
			{825, 100, 0.0},
			{826, 100, 0.0},
			{827, 100, 0.0}
		};

new
		fol_CreateMode[MAX_PLAYERS],
Timer:  fol_UpdateTimer[MAX_PLAYERS],
		fol_ClickTick[MAX_PLAYERS],
Float:  fol_LastPos[MAX_PLAYERS][3],
Float:  fol_BrushSize[MAX_PLAYERS],
		fol_ObjAmount[MAX_PLAYERS];

new
		fol_Objects[MAX_FOLIAGE_OBJECTS],
		fol_TotalObjects;

new
		sel_NodeData[MAX_PLAYERS][MAX_SELECTION_NODES][E_SELECTION_NODE_DATA],
		sel_LineData[MAX_PLAYERS][MAX_SELECTION_NODES],
		sel_TotalNodes[MAX_PLAYERS],
		sel_Complete[MAX_PLAYERS],
		sel_AreaID[MAX_PLAYERS];


public OnFilterScriptInit()
{
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);

	for(new i; i < MAX_PLAYERS; i++)
	{
		fol_BrushSize[i] = 10.0;
		fol_ObjAmount[i] = 10;

		for(new j; j < MAX_SELECTION_NODES; j++)
		{
			sel_LineData[i][j] = INVALID_LINE_SEGMENT_ID;
			sel_NodeData[i][j][sel_objId] = INVALID_OBJECT_ID;
		}
	}

	fol_TotalObjects = 0;
}


CMD:foliage(playerid, params[])
{

	if(fol_CreateMode[playerid] == CREATE_MODE_FOLIAGE)
	{
		fol_CreateMode[playerid] = CREATE_MODE_NONE;
		stop fol_UpdateTimer[playerid];
		SendClientMessage(playerid, -1, "Foliage hot-key disabled.");
	}
	else
	{
		fol_CreateMode[playerid] = CREATE_MODE_FOLIAGE;
		SendClientMessage(playerid, -1, "Foliage hot-key enabled, press "INTERACTION_KEYTEXT" to place foliage");
	}

	return 1;
}

CMD:saveall(playerid, params[])
{
	SendClientMessage(playerid, -1, "Saving...");
	SaveAllObjects();
	SendClientMessage(playerid, -1, "Saved!");
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & INTERACTION_KEYCODE)
	{
		if(fol_CreateMode[playerid] == CREATE_MODE_FOLIAGE)
		{
			stop fol_UpdateTimer[playerid];
			fol_UpdateTimer[playerid] = repeat fol_Update(playerid);
			fol_ClickTick[playerid] = tickcount();
		}
		if(fol_CreateMode[playerid] == CREATE_MODE_SELECTION)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				ret;

			GetPlayerPos(playerid, x, y, z);
			ret = Selection_AddNode(playerid, x, y, z);

			if(ret == 0)
				SendClientMessage(playerid, -1, "Selection already completed, no more nodes can be added");

			if(ret == 1)
				SendClientMessage(playerid, -1, "Selection node added");

			if(ret == 2)
				SendClientMessage(playerid, -1, "Selection completed");
		}
	}
	if(oldkeys & INTERACTION_KEYCODE)
	{
		if(fol_CreateMode[playerid])
		{
			stop fol_UpdateTimer[playerid];

			if(tickcount() - fol_ClickTick[playerid] < 200)
			{
				new
					Float:x,
					Float:y,
					Float:z;

				GetPlayerPos(playerid, x, y, z);
				CreateFoliage(playerid, x, y);
			}
		}
	}
	return 1;
}

timer fol_Update[1000](playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	if(Distance2D(fol_LastPos[playerid][COORD_X], fol_LastPos[playerid][COORD_Y], x, y) > fol_BrushSize[playerid])
	{
		CreateFoliage(playerid, x, y);

		fol_LastPos[playerid][COORD_X] = x;
		fol_LastPos[playerid][COORD_Y] = y;
		fol_LastPos[playerid][COORD_Z] = z;
	}
}


CreateFoliage(playerid, Float:x, Float:y)
{
	new
		Float:z,
		Float:dist,
		Float:angle;

	for(new i; i < fol_ObjAmount[playerid]; i++)
	{
		dist = frandom(fol_BrushSize[playerid]);
		angle = frandom(360.0);

		x += dist * floatsin(angle, degrees);
		y += dist * floatcos(angle, degrees);

		if(sel_Complete[playerid])
		{
			if(!IsPointInDynamicArea(sel_AreaID[playerid], x, y, 0.0))
				continue;
		}

		for(new j; j < fol_TotalObjects; j++)
		{
			new
				Float:jx,
				Float:jy,
				Float:jz;

			GetDynamicObjectPos(fol_Objects[j], jx, jy, jz);

			if(Distance2D(x, y, jx, jy) < 1.0)
				continue;
		}

		MapAndreas_FindAverageZ(x, y, z);
		CreateFoliageObject(x, y, z);
	}
}

CreateFoliageObject(Float:x, Float:y, Float:z)
{
	new
		list[sizeof(fol_ObjectTypes)],
		idx,
		cell;

	for(new i; i < sizeof(fol_ObjectTypes); i++)
	{
		if(random(100) < fol_ObjectTypes[i][fol_spawnRate])
			list[idx++] = i;
	}

	cell = list[random(idx)];

	fol_Objects[fol_TotalObjects++] = CreateDynamicObject(fol_ObjectTypes[cell][fol_modelId], x, y, z + fol_ObjectTypes[cell][fol_zOffset], 0.0, 0.0, random(360));
}

SaveAllObjects()
{
	new
		File:file,
		line[128],
		model,
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz;

	file = fopen(OUTPUT_FILE, io_write);
	
	for(new i; i < fol_TotalObjects; i++)
	{
		model = Streamer_GetIntData(STREAMER_TYPE_OBJECT, fol_Objects[i], E_STREAMER_MODEL_ID);
		GetDynamicObjectPos(fol_Objects[i], x, y, z);
		GetDynamicObjectRot(fol_Objects[i], rx, ry, rz);

		format(line, 128, "CreateObject(%d, %f, %f, %f, %f, %f, %f);\r\n",
			model, x, y, z, rx, ry, rz);

		fwrite(file, line);
	}

	fclose(file);
}


CMD:setamount(playerid, params[])
{
	new
		value,
		str[128];

	sscanf(params, "d", value);

	fol_ObjAmount[playerid] = value;
	format(str, 128, "Amount set to %d", value);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setsize(playerid, params[])
{
	new
		Float:value,
		str[128];

	sscanf(params, "f", value);

	fol_BrushSize[playerid] = value;
	format(str, 128, "Amount set to %.2f", value);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:select(playerid, params[])
{
	if(fol_CreateMode[playerid] == CREATE_MODE_SELECTION)
	{
		fol_CreateMode[playerid] = CREATE_MODE_NONE;
		SendClientMessage(playerid, -1, "Selection hot-key disabled.");
	}
	else
	{
		fol_CreateMode[playerid] = CREATE_MODE_SELECTION;
		SendClientMessage(playerid, -1, "Selection hot-key enabled, press "INTERACTION_KEYTEXT" to place selection polygon vertices");
	}

	return 1;
}

CMD:deselect(playerid, params[])
{
	Selection_Clear(playerid);
	SendClientMessage(playerid, -1, "Selection cleared");
	return 1;
}

Selection_AddNode(playerid, Float:x, Float:y, Float:z)
{
	if(sel_Complete[playerid])
		return 0;

	if(sel_TotalNodes[playerid] > 2 && Distance(x, y, z, sel_NodeData[playerid][0][sel_posX], sel_NodeData[playerid][0][sel_posY], sel_NodeData[playerid][0][sel_posZ]) < 1.0)
	{
		sel_NodeData[playerid][sel_TotalNodes[playerid]][sel_posX] = sel_NodeData[playerid][0][sel_posX];
		sel_NodeData[playerid][sel_TotalNodes[playerid]][sel_posY] = sel_NodeData[playerid][0][sel_posY];
		sel_NodeData[playerid][sel_TotalNodes[playerid]][sel_posZ] = sel_NodeData[playerid][0][sel_posZ];

		sel_TotalNodes[playerid]++;
		sel_Complete[playerid] = 1;

		Selection_Draw(playerid);

		return 2;
	}
	else
	{
		sel_NodeData[playerid][sel_TotalNodes[playerid]][sel_posX] = x;
		sel_NodeData[playerid][sel_TotalNodes[playerid]][sel_posY] = y;
		sel_NodeData[playerid][sel_TotalNodes[playerid]][sel_posZ] = z;

		sel_TotalNodes[playerid]++;

		Selection_Draw(playerid);

		return 1;
	}
}

Selection_Clear(playerid)
{
	for(new i; i < sel_TotalNodes[playerid]; i++)
	{
		DestroyLineSegment(sel_LineData[playerid][i]);
		DestroyDynamicObject(sel_NodeData[playerid][i][sel_objId]);
	}

	DestroyDynamicArea(sel_AreaID[playerid]);

	sel_TotalNodes[playerid] = 0;
	sel_Complete[playerid] = 0;

	Selection_Draw(playerid);
}

Selection_Draw(playerid)
{
	new
		Float:points[MAX_SELECTION_NODES],
		pointcell;

	for(new i; i < sel_TotalNodes[playerid]; i++)
	{
		points[pointcell] = sel_NodeData[playerid][i][sel_posX];
		points[pointcell + 1] = sel_NodeData[playerid][i][sel_posY];
		pointcell += 2;

		if(IsValidDynamicObject(sel_NodeData[playerid][i][sel_objId]))
			DestroyDynamicObject(sel_NodeData[playerid][i][sel_objId]);

		sel_NodeData[playerid][i][sel_objId] = CreateDynamicObject(18650,
			sel_NodeData[playerid][i][sel_posX],
			sel_NodeData[playerid][i][sel_posY],
			sel_NodeData[playerid][i][sel_posZ],
			90.0, 0.0, 0.0);

		if(sel_TotalNodes[playerid] < 2)
			continue;

		if(i == sel_TotalNodes[playerid] - 1)
			break;

		if(IsValidLineSegment(sel_LineData[playerid][i]))
			DestroyLineSegment(sel_LineData[playerid][i]);

		sel_LineData[playerid][i] = CreateLineSegment(19087, 2.46,
			sel_NodeData[playerid][i][sel_posX],
			sel_NodeData[playerid][i][sel_posY],
			sel_NodeData[playerid][i][sel_posZ],
			sel_NodeData[playerid][i + 1][sel_posX],
			sel_NodeData[playerid][i + 1][sel_posY],
			sel_NodeData[playerid][i + 1][sel_posZ],
			.RotX = 90.0, .maxlength = 1000.0);
	}

	if(pointcell > 6)
	{
		if(IsValidDynamicArea(sel_AreaID[playerid]))
			DestroyDynamicArea(sel_AreaID[playerid]);

		sel_AreaID[playerid] = CreateDynamicPolygon(points);
	}

	return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(areaid == sel_AreaID[playerid])
	{
		SendClientMessage(playerid, -1, "Entered selection area");
	}
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(areaid == sel_AreaID[playerid])
	{
		SendClientMessage(playerid, -1, "Left selection area");
	}
}
