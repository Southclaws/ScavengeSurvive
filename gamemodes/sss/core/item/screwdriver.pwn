/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static Item:scr_TargetItem[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	scr_TargetItem[playerid] = INVALID_ITEM_ID;
}


hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(itemid) == item_Screwdriver)
	{
		new
			ItemType:itemtype,
			explosiontype;

		itemtype = GetItemType(withitemid);
		explosiontype = GetItemTypeExplosiveType(itemtype);

		if(explosiontype != INVALID_EXPLOSIVE_TYPE)
		{
			new EXP_TRIGGER:trigger = GetExplosiveTypeTrigger(explosiontype);

			if(trigger == RADIO || trigger == MOTION)
			{
				new armed;
				GetItemExtraData(withitemid, armed);
				if(armed == 1)
				{
					StartHoldAction(playerid, 2000);
					ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
					scr_TargetItem[playerid] = withitemid;
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


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
		ShowActionText(playerid, ls(playerid, "DISARMEDBOM", true), 5000);
		scr_TargetItem[playerid] = INVALID_ITEM_ID;

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
