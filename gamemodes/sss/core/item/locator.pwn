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
	if(!strcmp(uname, "Locator"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Locator"), 1);
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(itemid) == item_Locator && GetItemType(withitemid) == item_MobilePhone)
	{
		SetItemExtraData(itemid, _:withitemid);
		SetItemExtraData(withitemid, 1);

		ChatMsgLang(playerid, YELLOW, "LOCATORSYNC");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) != item_Locator)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new Item:phoneitemid;
	GetItemExtraData(itemid, _:phoneitemid);

	if(!IsValidItem(phoneitemid) || GetItemType(phoneitemid) != item_MobilePhone)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new active;
	GetItemExtraData(phoneitemid, active);
	if(active != 1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:phone_x,
		Float:phone_y,
		Float:phone_z,
		Float:distance;

	GetPlayerPos(playerid, x, y, z);
	GetItemAbsolutePos(phoneitemid, phone_x, phone_y, phone_z);
	distance = Distance(phone_x, phone_y, phone_z, x, y, z);

	ShowActionText(playerid, sprintf(ls(playerid, "DISTANCEVAL", true), distance), 2000);

	// ShowActionText(playerid, ls(playerid, "LOCATORDIS", true), 2000);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemCreate(Item:itemid)
{
	if(GetItemType(itemid) == item_Locator)
	{
		SetItemExtraData(itemid, _:INVALID_ITEM_ID);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
