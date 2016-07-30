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


	This source code was written & provided by Adam Kadar @ github.com/Kadaradam


==============================================================================*/


#include <YSI\y_hooks>


#define MAX_FISHING_DISTANCE	(10000)
#define MIN_FISHING_TIME		(30000)
#define MAX_FISHING_TIME		(120000)
#define FISHING_CHANCE			(30) // value in percentage


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
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/item/fishingrod.pwn");

	fish_Status[playerid] = FISH_STATUS_NONE;
	stop fish_Timer[playerid];
}

hook OnPlayerUseItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItem] in /gamemodes/sss/core/item/fishingrod.pwn");

	if(GetItemType(itemid) == item_FishRod)
	{
		_PlayerStartFishing(playerid);

		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/item/fishingrod.pwn");

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
	MapAndreas_FindZ_For2DCoord(x, y, z);

	if(IsPosInWater(x, y, z) && -0.01 < z < 0.01)
	{
		fish_Timer[playerid] = defer _TryCatch(playerid);
		ShowActionText(playerid, ls(playerid, "FISHFISHING"));
	}
	else
	{
		_PlayerStopFishing(playerid);
		ShowActionText(playerid, ls(playerid, "FISHNCLOSER"), 8000);
	}

	// Debugging purposes
	// CreateDynamicObject(18728, x, y, z, 0, 0, 0, -1, -1);
}

timer _TryCatch[MIN_FISHING_TIME + random(MAX_FISHING_TIME - MIN_FISHING_TIME)](playerid)
{
	if(random(100) < FISHING_CHANCE)
	{
		ApplyAnimation(playerid, "SWORD", "sword_block", 50.0, 1, 0, 0, 0, 0);
		
		fish_Timer[playerid] = defer _CatchDelay(playerid);
		ShowActionText(playerid, ls(playerid, "FISHLINETUG"), floatround(fish_Distance[playerid], floatround_round) * 100);
	}
	else
	{
		_PlayerStopFishing(playerid);
		ShowActionText(playerid, ls(playerid, "FISHUNLUCKY"), 8000);
	}
}

timer _CatchDelay[floatround(fish_Distance[playerid], floatround_round) * 100](playerid)
{
	new
		Float: x,
		Float: y,
		Float: z;

	GetPlayerPos(playerid, x, y, z);
	CreateItem(item_RawFish, x, y, z - FLOOR_OFFSET, 90.0);
	// todo: multiple fish types
	
	_PlayerStopFishing(playerid);
}

hook OnHoldActionUpdate(playerid, progress)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionUpdate] in /gamemodes/sss/core/item/fishingrod.pwn");

	if(fish_Status[playerid] == FISH_STATUS_CASTING)
		fish_Distance[playerid] = progress / 100;

	return Y_HOOKS_CONTINUE_RETURN_0;
}
