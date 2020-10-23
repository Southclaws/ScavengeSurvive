/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 "Southclaws" Keene

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
