/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static MachineType;

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "WaterMachine"))
		MachineType = DefineMachineType(GetItemTypeFromUniqueName("WaterMachine"), 12);
}

hook OnItemAddToContainer(Container:containerid, Item:itemid, playerid)
{
	if(playerid == INVALID_PLAYER_ID)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new ItemType:itemtype = GetItemType(GetContainerMachineItem(containerid));

	if(itemtype != item_WaterMachine)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(!_machine_isItemBottledSeawater(itemid))
	{
		ShowActionText(playerid, sprintf(
			ls(playerid, "MACHITEMTYP", true),
			"Water Bottle (Sea Water)"
		));
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_machine_isItemBottledSeawater(Item:itemid)
{
	if(GetItemType(itemid) != item_Bottle)
		return false;

	if(GetLiquidItemLiquidType(itemid) != liquid_SeaWater)
		return false;

	if(GetLiquidItemLiquidAmount(itemid) == 0.0)
		return false;

	return true;
}

hook OnMachineFinish(Item:itemid, Container:containerid)
{
	if(GetItemTypeMachineType(GetItemType(itemid)) != MachineType)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new
		Item:subitemid,
		Float:amounts[MAX_MACHINE_ITEMS],
		itemcount;

	GetContainerItemCount(containerid, itemcount);
	for(new i = itemcount - 1; i > -1; i--)
	{
		GetContainerSlotItem(containerid, i, subitemid);
		amounts[itemcount] = GetLiquidItemLiquidAmount(subitemid);
		DestroyItem(subitemid);
		itemcount++;
	}

	for(new i; i < itemcount; i++)
	{
		subitemid = CreateItem(item_Bottle);
		AddItemToContainer(containerid, subitemid);
		SetLiquidItemLiquidAmount(subitemid, amounts[i]);
		SetLiquidItemLiquidType(subitemid, liquid_Water);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
