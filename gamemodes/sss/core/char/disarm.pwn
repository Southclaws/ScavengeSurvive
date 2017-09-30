/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/char/disarm.pwn");

	if(GetPlayerWeapon(playerid) != 0 || IsValidItem(GetPlayerItem(playerid)))
		return 1;

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	if(newkeys & 16)
	{
		foreach(new i : Player)
		{
			if(IsPlayerInPlayerArea(playerid, i))
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

	new itemid = GetPlayerItem(i);

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
