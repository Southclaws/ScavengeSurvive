/*==============================================================================

# Southclaws's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

Generic debug label module that allows adding debug labels to any entity.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_DEBUG_LABELS_INCLUDED
	#endinput
#endif

#include <streamer>

#define _SIF_DEBUG_LABELS_INCLUDED


#if !defined SIF_USE_DEBUG_LABELS
	#endinput
#endif


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


#if !defined MAX_DEBUG_LABELS
	#define MAX_DEBUG_LABELS			(65535)
#endif

#if !defined MAX_DEBUG_LABEL_TYPES
	#define MAX_DEBUG_LABEL_TYPES		(32)
#endif

#if !defined MAX_DEBUG_LABEL_TYPE_NAME
	#define MAX_DEBUG_LABEL_TYPE_NAME	(32)
#endif

#if !defined MAX_DEBUG_LABEL_STRING_LEN
	#define MAX_DEBUG_LABEL_STRING_LEN	(128)
#endif

#define INVALID_DEBUG_LABEL_TYPE		(-1)
#define INVALID_DEBUG_LABEL_ID			(-2)


// Functions


forward DefineDebugLabelType(const name[], colour = 0xFFFFFFFF);
/*
# Description:
-
*/

forward CreateDebugLabel(type, entityid, Float:x, Float:y, Float:z, const string[] = "", worldid = -1, interiorid = -1);
/*
# Description:
-
*/

forward DestroyDebugLabel(labelid);
/*
# Description:
-
*/

forward ShowDebugLabelsForPlayer(playerid, type);
/*
# Description:
-
*/

forward ShowAllDebugLabelsForPlayer(playerid);
/*
# Description:
-
*/

forward HideDebugLabelsForPlayer(playerid, type);
/*
# Description:
-
*/

forward HideAllDebugLabelsForPlayer(playerid);
/*
# Description:
-
*/

forward UpdateDebugLabelString(labelid, const string[]);
/*
# Description:
-
*/

forward IsValidDebugLabel(labelid);
/*
# Description:
-
*/

forward SetDebugLabelPos(labelid, Float:x, Float:y, Float:z);
/*
# Description:
-
*/

forward IsPlayerToggledDebugLabels(playerid, type);
/*
# Description:
-
*/

forward IsPlayerToggledAllDebugLabels(playerid);
/*
# Description:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


enum E_DEBUG_LABEL_TYPE_DATA
{
			dbl_name[MAX_DEBUG_LABEL_TYPE_NAME],
			dbl_colour
}

enum E_DEBUG_LABEL_DATA
{
Text3D:		dbl_labelID,
			dbl_type,
			dbl_entityID,
Float:		dbl_posX,
Float:		dbl_posY,
Float:		dbl_posZ,
			dbl_string[MAX_DEBUG_LABEL_STRING_LEN]
}


static
			dbl_TypeData[MAX_DEBUG_LABEL_TYPES][E_DEBUG_LABEL_TYPE_DATA],
			dbl_TypeCount,
			dbl_Data[MAX_DEBUG_LABELS][E_DEBUG_LABEL_DATA],
   Iterator:dbl_Index<MAX_DEBUG_LABELS>;

static
			dbl_DebugLabelToggle[MAX_PLAYERS][MAX_DEBUG_LABEL_TYPES];


/*==============================================================================

	Core Functions

==============================================================================*/


stock DefineDebugLabelType(const name[], colour = 0xFFFFFFFF)
{
	if(dbl_TypeCount == MAX_DEBUG_LABEL_TYPES)
		return -1;

	strcat(dbl_TypeData[dbl_TypeCount][dbl_name], name, MAX_DEBUG_LABEL_TYPE_NAME);
	dbl_TypeData[dbl_TypeCount][dbl_colour] = colour;

	printf("Defined new debug label type '%s' ID: %d", dbl_TypeData[dbl_TypeCount][dbl_name], dbl_TypeCount);

	return dbl_TypeCount++;
}

stock CreateDebugLabel(type, entityid, Float:x, Float:y, Float:z, const string[] = "", worldid = -1, interiorid = -1)
{
	new id = Iter_Free(dbl_Index);

	if(id == -1)
	{
		print("ERROR: Debug label limit reached.");
		return INVALID_DEBUG_LABEL_ID;
	}

	if(type >= dbl_TypeCount)
	{
		printf("ERROR: Attempted debug label creation with invalid label type (%d).", type);
		return INVALID_DEBUG_LABEL_ID;
	}

	new
		worlds[1],
		interiors[1],
		players[MAX_PLAYERS],
		maxplayers;

	worlds[0] = worldid;
	interiors[0] = interiorid;

	foreach(new i : Player)
	{
		if(dbl_DebugLabelToggle[i][type])
			players[maxplayers++] = i;
	}

	dbl_Data[id][dbl_type] = type;
	dbl_Data[id][dbl_entityID] = entityid;
	dbl_Data[id][dbl_posX] = x;
	dbl_Data[id][dbl_posY] = y;
	dbl_Data[id][dbl_posZ] = z;

	format(dbl_Data[id][dbl_string], MAX_DEBUG_LABEL_STRING_LEN, "[ENTITY TYPE: \"%s\" ID: %d]\n%s", dbl_TypeData[type][dbl_name], entityid, string);

	dbl_Data[id][dbl_labelID] = CreateDynamic3DTextLabelEx(
		dbl_Data[id][dbl_string], dbl_TypeData[type][dbl_colour], x, y, z, 10000.0,
		.testlos = false, .streamdistance = 10.0, .worlds = worlds, .interiors = interiors, .players = players, .maxplayers = maxplayers);

	Iter_Add(dbl_Index, id);

	return id;
}

stock DestroyDebugLabel(labelid)
{
	if(!Iter_Contains(dbl_Index, labelid))
		return 0;

	DestroyDynamic3DTextLabel(dbl_Data[labelid][dbl_labelID]);

	Iter_Remove(dbl_Index, labelid);

	dbl_Data[labelid][dbl_type] = INVALID_DEBUG_LABEL_TYPE;
	dbl_Data[labelid][dbl_entityID] = 0;
	dbl_Data[labelid][dbl_posX] = 0.0;
	dbl_Data[labelid][dbl_posY] = 0.0;
	dbl_Data[labelid][dbl_posZ] = 0.0;
	dbl_Data[labelid][dbl_string][0] = EOS;
	dbl_Data[labelid][dbl_labelID] = Text3D:INVALID_3DTEXT_ID;

	return 1;
}

stock ShowDebugLabelsForPlayer(playerid, type)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(type >= dbl_TypeCount)
		return 0;

	dbl_DebugLabelToggle[playerid][type] = true;

	foreach(new i : dbl_Index)
		Streamer_AppendArrayData(STREAMER_TYPE_3D_TEXT_LABEL, dbl_Data[i][dbl_labelID], E_STREAMER_PLAYER_ID, playerid);

	return 1;
}

stock ShowAllDebugLabelsForPlayer(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	for(new i; i < dbl_TypeCount; i++)
		ShowDebugLabelsForPlayer(playerid, i);

	return 1;
}

stock HideDebugLabelsForPlayer(playerid, type)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(type >= dbl_TypeCount)
		return 0;

	dbl_DebugLabelToggle[playerid][type] = false;

	foreach(new i : dbl_Index)
		Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, dbl_Data[i][dbl_labelID], E_STREAMER_PLAYER_ID, playerid);

	return 1;
}

stock HideAllDebugLabelsForPlayer(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	for(new i; i < dbl_TypeCount; i++)
		HideDebugLabelsForPlayer(playerid, i);

	return 1;
}

stock UpdateDebugLabelString(labelid, const string[])
{
	if(!Iter_Contains(dbl_Index, labelid))
		return 0;

	format(dbl_Data[labelid][dbl_string], MAX_DEBUG_LABEL_STRING_LEN,
		"[ENTITY TYPE: \"%s\" ID: %d]\n%s",
		dbl_TypeData[dbl_Data[labelid][dbl_type]][dbl_name],
		dbl_Data[labelid][dbl_entityID],
		string);

	UpdateDynamic3DTextLabelText(dbl_Data[labelid][dbl_labelID], dbl_TypeData[dbl_Data[labelid][dbl_type]][dbl_colour], dbl_Data[labelid][dbl_string]);

	return 1;
}

stock IsValidDebugLabel(labelid)
{
	if(!Iter_Contains(dbl_Index, labelid))
		return 0;

	return 1;
}

stock SetDebugLabelPos(labelid, Float:x, Float:y, Float:z)
{
	if(!Iter_Contains(dbl_Index, labelid))
		return 0;

	dbl_Data[labelid][dbl_posX] = x;
	dbl_Data[labelid][dbl_posY] = y;
	dbl_Data[labelid][dbl_posZ] = z;

	Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, dbl_Data[labelid][dbl_labelID], E_STREAMER_X, x);
	Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, dbl_Data[labelid][dbl_labelID], E_STREAMER_Y, y);
	Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, dbl_Data[labelid][dbl_labelID], E_STREAMER_Z, z);

	return 1;
}

stock IsPlayerToggledDebugLabels(playerid, type)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dbl_DebugLabelToggle[playerid][type];
}

stock IsPlayerToggledAllDebugLabels(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	for(new i; i < dbl_TypeCount; i++)
	{
		if(!IsPlayerToggledDebugLabels(playerid, i))
			return 0;
	}

	return 1;
}
