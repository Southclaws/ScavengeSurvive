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


==============================================================================*/


#include <YSI_4\y_hooks>


static scr_TargetItem[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	scr_TargetItem[playerid] = INVALID_ITEM_ID;
}


public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_Screwdriver)
	{
		new ItemType:itemtype = GetItemType(withitemid);

		if(
			itemtype == item_TntPhoneBomb ||
			itemtype == item_TntTripMine ||
			itemtype == item_IedPhoneBomb ||
			itemtype == item_IedTripMine ||
			itemtype == item_EmpPhoneBomb ||
			itemtype == item_EmpTripMine)
		{
			if(GetItemExtraData(withitemid) == 1)
			{
				StartHoldAction(playerid, 2000);
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
				scr_TargetItem[playerid] = withitemid;
			}
		}
	}
	#if defined scr_OnPlayerUseItemWithItem
		return scr_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem scr_OnPlayerUseItemWithItem
#if defined scr_OnPlayerUseItemWithItem
	forward scr_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		if(IsValidItem(scr_TargetItem[playerid]))
			StopHoldAction(playerid);
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	if(IsValidItem(scr_TargetItem[playerid]))
	{
		ClearAnimations(playerid);
		SetItemExtraData(scr_TargetItem[playerid], 0);
		scr_TargetItem[playerid] = INVALID_ITEM_ID;

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
