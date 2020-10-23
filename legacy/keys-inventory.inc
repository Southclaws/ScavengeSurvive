/*==============================================================================

# Southclaws's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

An extension script for SIF/Inventory that allows players to interact with their
inventory using key presses.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_INVENTORY_KEYS_INCLUDED
	#endinput
#endif

#include <YSI_Coding\y_hooks>

#define _SIF_INVENTORY_KEYS_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


// Events

forward OnPlayerAddToInventory(playerid, Item:itemid, bool:success);
/*
# Called:
When a player adds an item to their inventory using a key.
*/

forward OnPlayerAddedToInventory(playerid, Item:itemid);
/*
# Called:
After a player has added an item to their inventory.
*/


/*==============================================================================

	Setup

==============================================================================*/


static
		inv_PutAwayTick				[MAX_PLAYERS],
Timer:	inv_PutAwayTimer			[MAX_PLAYERS];


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		if(newkeys & KEY_CTRL_BACK)
		{
			DisplayPlayerInventory(playerid);
		}

		if(newkeys & KEY_YES)
		{
			_HandlePutItemAway(playerid);
		}
	}

	return 1;
}

_HandlePutItemAway(playerid)
{
	if(GetTickCountDifference(GetTickCount(), inv_PutAwayTick[playerid]) < 1000)
		return;

	new Item:itemid = GetPlayerItem(playerid);

	if(!IsValidItem(itemid))
		return;

	new
		itemsize,
		freeslots;

	GetItemTypeSize(GetItemType(itemid), itemsize);
	GetInventoryFreeSlots(playerid, freeslots);

	if(itemsize > freeslots)
	{
		CallLocalFunction("OnPlayerAddToInventory", "ddd", playerid, _:itemid, 0);
		return;
	}

	if(CallLocalFunction("OnPlayerAddToInventory", "ddd", playerid, _:itemid, 1))
		return;

	inv_PutAwayTick[playerid] = GetTickCount();

	ApplyAnimation(playerid, "PED", "PHONE_IN", 4.0, 1, 0, 0, 0, 300);
	stop inv_PutAwayTimer[playerid];
	inv_PutAwayTimer[playerid] = defer PlayerPutItemInInventory(playerid, _:itemid);

	return;
}

timer PlayerPutItemInInventory[300](playerid, itemid)
{
	AddItemToInventory(playerid, Item:itemid);
	CallLocalFunction("OnPlayerAddedToInventory", "dd", playerid, itemid);
}
