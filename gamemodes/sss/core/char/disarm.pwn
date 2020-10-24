/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerWeapon(playerid) != 0 || IsValidItem(GetPlayerItem(playerid)))
		return 1;

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	if(newkeys & 16)
	{
		foreach(new i : Player)
		{
			if(IsPlayerNextToPlayer(playerid, i))
			{
				if(IsPlayerKnockedOut(i) || GetPlayerAnimationIndex(i) == 1381)
				{
					DisarmPlayer(playerid, i);
					break;
				}
			}
		}
	}

	return 1;
}

DisarmPlayer(playerid, i)
{
	if(IsValidItem(GetPlayerItem(playerid)))
		return 0;

	new Item:itemid = GetPlayerItem(i);

	if(IsValidItem(itemid))
	{
		RemoveCurrentItem(i);
		GiveWorldItemToPlayer(playerid, itemid);

		return 1;
	}

	itemid = GetPlayerHolsterItem(i);

	if(IsValidItem(itemid))
	{
		RemovePlayerHolsterItem(i);
		CreateItemInWorld(itemid);
		GiveWorldItemToPlayer(playerid, itemid);

		return 1;
	}

	return 0;
}
