/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


	This source code was written & provided by Adam Kadar @ github.com/Kadaradam


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_FISHING_DISTANCE	(10000)
#define MIN_FISHING_TIME		(30000)
#define MAX_FISHING_TIME		(120000)
#define FISHING_CHANCE			(300) // value in percentage


enum
{
	FISH_STATUS_NONE,
	FISH_STATUS_CASTING,
	FISH_STATUS_WAITING
}
static
		fish_Status[MAX_PLAYERS],
Float:	fish_Distance[MAX_PLAYERS],
Timer:	fish_Timer[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	fish_Status[playerid] = FISH_STATUS_NONE;
	stop fish_Timer[playerid];
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_FishRod)
	{
		_PlayerStartFishing(playerid);

		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_FishRod)
	{
		if(newkeys == 16)
		{
			if(fish_Status[playerid] == FISH_STATUS_WAITING)
				_PlayerStopFishing(playerid);
		}
		else if(oldkeys == 16)
		{
			if(fish_Status[playerid] == FISH_STATUS_CASTING)
				_CatchFish(playerid, fish_Distance[playerid]);
		}
	}
	return 1;
}

_PlayerStartFishing(playerid)
{
	if(fish_Status[playerid] != FISH_STATUS_NONE)
		_PlayerStopFishing(playerid);

	StartHoldAction(playerid, MAX_FISHING_DISTANCE);
	fish_Status[playerid] = FISH_STATUS_CASTING;

	ApplyAnimation(playerid, "SAMP", "FishingIdle", 4.1, 1, 0, 0, 0, 0);
}

_PlayerStopFishing(playerid)
{
	StopHoldAction(playerid);
	HideActionText(playerid);
	ClearAnimations(playerid);
	fish_Status[playerid] = FISH_STATUS_NONE;
	stop fish_Timer[playerid];
}

_CatchFish(playerid, Float:distance)
{
	fish_Status[playerid] = FISH_STATUS_WAITING;
	StopHoldAction(playerid);

	new
		Float: x,
		Float: y,
		Float: z,
		Float: a;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));

	if(IsPosInWater(x, y, z) && -0.01 < z < 0.01)
	{
		fish_Timer[playerid] = defer _TryCatch(playerid, GetPlayerSkillTimeModifier(playerid, MIN_FISHING_TIME + random(MAX_FISHING_TIME - MIN_FISHING_TIME), "Fishing"));
		ShowActionText(playerid, ls(playerid, "FISHFISHING", true));
	}
	else
	{
		_PlayerStopFishing(playerid);
		ShowActionText(playerid, ls(playerid, "FISHNCLOSER", true), 8000);
	}

	// Debugging purposes
	// CreateDynamicObject(18728, x, y, z, 0, 0, 0, -1, -1);
}

timer _TryCatch[catchtime](playerid, catchtime)
{
	#pragma unused catchtime

	if(random(1000) < 1000 - GetPlayerSkillTimeModifier(playerid, 1000 - FISHING_CHANCE, "Fishing"))
	{
		ApplyAnimation(playerid, "SWORD", "sword_block", 50.0, 1, 0, 0, 0, 0);

		fish_Timer[playerid] = defer _CatchDelay(playerid);
		ShowActionText(playerid, ls(playerid, "FISHLINETUG", true), floatround(fish_Distance[playerid], floatround_round) * 100);
		PlayerGainSkillExperience(playerid, "Fishing");
	}
	else
	{
		_PlayerStopFishing(playerid);
		ShowActionText(playerid, ls(playerid, "FISHUNLUCKY", true), 8000);
	}
}

timer _CatchDelay[floatround(fish_Distance[playerid], floatround_round) * 100](playerid)
{
	new
		Item:itemid,
		Float: x,
		Float: y,
		Float: z;

	GetPlayerPos(playerid, x, y, z);

	itemid = CreateItem(item_RawFish, x, y, z - ITEM_FLOOR_OFFSET, 90.0);
	SetItemArrayDataAtCell(itemid, 0, food_cooked, true);
	SetItemArrayDataAtCell(itemid, 4, food_amount, true);
	// todo: multiple fish types
	
	_PlayerStopFishing(playerid);
}

hook OnHoldActionUpdate(playerid, progress)
{
	if(fish_Status[playerid] == FISH_STATUS_CASTING)
		fish_Distance[playerid] = progress / 100;

	return Y_HOOKS_CONTINUE_RETURN_0;
}
