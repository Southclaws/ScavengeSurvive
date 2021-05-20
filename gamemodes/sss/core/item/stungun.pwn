/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "StunGun"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("StunGun"), 1);
}

hook OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult)
{
	new Item:itemid = GetPlayerItem(playerid);

	if(GetItemType(itemid) == item_StunGun)
	{
		new charged;
		GetItemExtraData(itemid, charged);
		if(charged == 1)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerPos(targetid, x, y, z);

			KnockOutPlayer(targetid, 60000);
			SetItemExtraData(itemid, 0);
			CreateTimedDynamicObject(18724, x, y, z-1.0, 0.0, 0.0, 0.0, 1000);

			return Y_HOOKS_BREAK_RETURN_1;
		}
		else
		{
			ShowActionText(playerid, ls(playerid, "STUNGUNOUTC", true), 3000);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(itemid) == item_StunGun && GetItemType(withitemid) == item_Battery)
	{
		SetItemExtraData(itemid, 1);
		DestroyItem(withitemid);
		ShowActionText(playerid, ls(playerid, "STUNGUNCHAR", true), 3000);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	if(itemtype == item_StunGun)
	{
		new charged;
		GetItemExtraData(itemid, charged);
		if(charged == 1)
			SetItemNameExtra(itemid, "Charged");

		else
			SetItemNameExtra(itemid, "Uncharged");
	}
}
