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


#include <YSI_Coding\y_hooks>


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Locator"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Locator"), 1);
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	dbg("global", CORE, "[OnPlayerUseItemWithItem] in /gamemodes/sss/core/item/locator.pwn");

	if(GetItemType(itemid) == item_Locator && GetItemType(withitemid) == item_MobilePhone)
	{
		SetItemExtraData(itemid, withitemid);
		SetItemExtraData(withitemid, 1);

		ChatMsgLang(playerid, YELLOW, "LOCATORSYNC");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/item/locator.pwn");

	if(GetItemType(itemid) != item_Locator)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new phoneitemid = GetItemExtraData(itemid);

	if(!IsValidItem(phoneitemid) || GetItemType(phoneitemid) != item_MobilePhone)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetItemExtraData(phoneitemid) != 1)
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

hook OnItemCreate(itemid)
{
	dbg("global", CORE, "[OnItemCreate] in /gamemodes/sss/core/item/locator.pwn");

	if(GetItemType(itemid) == item_Locator)
	{
		SetItemExtraData(itemid, INVALID_ITEM_ID);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
