/*==============================================================================

# Southclaws's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

Multi-button trigger system for puzzles and the like.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_MULTI_BUTTON_INCLUDED
	#endinput
#endif

#if !defined _SIF_DEBUG_INCLUDED
	#include "debug.inc"
#endif

#if !defined _SIF_CORE_INCLUDED
	#include "core.inc"
#endif

#if !defined _SIF_BUTTON_INCLUDED
	#include "button.inc"
#endif

#include <YSI_Coding\y_iterate>
#include <YSI_Coding\y_hooks>

#define _SIF_MULTI_BUTTON_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


#if !defined MBT_MAX
	#define MBT_MAX (64)
#endif

#if !defined MBT_MAX_BUTTONS
	#define MBT_MAX_BUTTONS (8)
#endif


#define INVALID_MBT_ID (-1)


// Functions


forward CreateMultiButtonTrigger(type, timewindow, list[], count = sizeof(list));
/*
# Description:
-
*/

forward DestroyMultiButtonTrigger(triggerid);
/*
# Description:
-
*/


// Events


forward OnMultiButtonTrigger(triggerid, success);
/*
# Called:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


enum
{
			MBT_TYPE_SIMULTANEOUS,
			MBT_TYPE_SEQUENCE
}

enum E_MULTI_BUTTON_TRIGGER_DATA
{
			mbt_type,
			mbt_time,
			mbt_buttons[MBT_MAX_BUTTONS],
			mbt_buttonCount,
			mbt_active,
			mbt_activateTick,
			mbt_buttonsActive[MBT_MAX_BUTTONS]
}

static
			mbt_Data[MBT_MAX][E_MULTI_BUTTON_TRIGGER_DATA],
   Iterator:mbt_Index<MBT_MAX>,
			mbt_ButtonMbTriggerID[BTN_MAX] = {INVALID_MBT_ID, ...};


static MBT_DEBUG = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	MBT_DEBUG = sif_debug_register_handler("SIF/MultiButton");
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:MBT_DEBUG("[OnScriptInit]");
}


/*==============================================================================

	Core

==============================================================================*/


stock CreateMultiButtonTrigger(type, timewindow, list[], count = sizeof(list))
{
	sif_d:SIF_DEBUG_LEVEL_CORE:MBT_DEBUG("[CreateMultiButtonTrigger]");
	if(count >= MBT_MAX_BUTTONS)
		return INVALID_MBT_ID;

	new id = Iter_Free(mbt_Index);

	mbt_Data[id][mbt_type] = type;
	mbt_Data[id][mbt_time] = timewindow;

	for(new i; i < count; i++)
	{
		if(!IsValidButton(list[i]))
			return INVALID_MBT_ID;

		mbt_Data[id][mbt_buttons][i] = list[i];
		mbt_Data[id][mbt_buttonsActive][i] = 0;

		mbt_ButtonMbTriggerID[list[i]] = id;
	}

	mbt_Data[id][mbt_buttonCount] = count;
	mbt_Data[id][mbt_active] = 0;
	mbt_Data[id][mbt_activateTick] = 0;

	Iter_Add(mbt_Index, id);

	return id;
}

stock DestroyMultiButtonTrigger(triggerid)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:MBT_DEBUG("[DestroyMultiButtonTrigger]");
	if(!Iter_Contains(mbt_Index, triggerid))
		return 0;

	mbt_Data[id][mbt_buttonCount] = 0;
	Iter_Remove(mbt_Index, triggerid);

	return 1;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnButtonPress(playerid, buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:MBT_DEBUG("[OnButtonPress]");
	_mbt_ButtonPress(buttonid);

	return 0;
}

_mbt_ButtonPress(buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:MBT_DEBUG("[_mbt_ButtonPress]");
	if(!Iter_Contains(mbt_Index, mbt_ButtonMbTriggerID[buttonid]))
		return;

	_mbt_HandleTriggerButton(mbt_ButtonMbTriggerID[buttonid], buttonid);

	return;
}

_mbt_HandleTriggerButton(triggerid, buttonid)
{
	if(!mbt_Data[triggerid][mbt_active])
	{
		mbt_Data[triggerid][mbt_active] = 1;
		mbt_Data[triggerid][mbt_activateTick] = GetTickCount();
	}
	else
	{
		if(sif_GetTickCountDiff(mbt_Data[triggerid][mbt_activateTick], GetTickCount()) > mbt_Data[triggerid][mbt_time])
		{
			sif_d:SIF_DEBUG_LEVEL_INTERNAL:MBT_DEBUG("[_mbt_ButtonPress]");
			_mbt_Reset(triggerid);
			return;
		}
	}

	switch(mbt_Data[triggerid][mbt_type])
	{
		case MBT_TYPE_SEQUENCE:
			_mbt_HandleSequential(triggerid, buttonid);

		case MBT_TYPE_SIMULTANEOUS:
			_mbt_HandleSimultaneous(triggerid, buttonid);
	}

	return;
}

_mbt_HandleSequential(triggerid, buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:MBT_DEBUG("[_mbt_HandleSequential]");
	new activecount;

	for(new i; i < mbt_Data[triggerid][mbt_buttonCount]; i++)
	{
		sif_d:SIF_DEBUG_LEVEL_LOOPS:MBT_DEBUG("[_mbt_HandleSequential] [%d/%d] Checking %d == %d", i, mbt_Data[triggerid][mbt_buttonCount], buttonid, mbt_Data[triggerid][mbt_buttons][i], mbt_Data[triggerid][mbt_buttonsActive][i]);

		if(mbt_Data[triggerid][mbt_buttonsActive][i])
		{
			activecount++;
			continue;
		}

		if(mbt_Data[triggerid][mbt_buttons][i] == buttonid)
		{
			sif_d:SIF_DEBUG_LEVEL_LOOPS:MBT_DEBUG("[_mbt_HandleSequential] Button is a match, stop loop and wait for next button.");
			mbt_Data[triggerid][mbt_buttonsActive][i] = 1;
			activecount++;
			break;
		}
		else
		{
			sif_d:SIF_DEBUG_LEVEL_LOOPS:MBT_DEBUG("[_mbt_HandleSequential] Next button was incorrect, fail state.");
			CallLocalFunction("OnMultiButtonTrigger", "dd", triggerid, 0);
			_mbt_Reset(triggerid);
			return 0;
		}
	}

	sif_d:SIF_DEBUG_LEVEL_INTERNAL:MBT_DEBUG("[_mbt_HandleSequential] activecount: %d", activecount);

	if(activecount == mbt_Data[triggerid][mbt_buttonCount])
	{
		CallLocalFunction("OnMultiButtonTrigger", "dd", triggerid, 1);
		_mbt_Reset(triggerid);
	}

	return 1;
}

_mbt_HandleSimultaneous(triggerid, buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:MBT_DEBUG("[_mbt_HandleSimultaneous]");
	new activecount;

	for(new i; i < mbt_Data[triggerid][mbt_buttonCount]; i++)
	{
		if(mbt_Data[triggerid][mbt_buttonsActive][i])
		{
			activecount++;
			continue;
		}

		if(mbt_Data[triggerid][mbt_buttons][i] == buttonid)
		{
			mbt_Data[triggerid][mbt_buttonsActive][i] = 1;
			activecount++;
		}
	}

	if(activecount == mbt_Data[triggerid][mbt_buttonCount])
	{
		CallLocalFunction("OnMultiButtonTrigger", "dd", triggerid, 1);
		_mbt_Reset(triggerid);
	}
}

_mbt_Reset(triggerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:MBT_DEBUG("[_mbt_Reset]");

	for(new i; i < mbt_Data[triggerid][mbt_buttonCount]; i++)
		mbt_Data[triggerid][mbt_buttonsActive][i] = 0;

	mbt_Data[triggerid][mbt_active] = 0;
}
