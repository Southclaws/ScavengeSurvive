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


static
	MachineType,
	ItemTypeScrapValue[ITM_MAX_TYPES] = {-1, ...};

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "ScrapMachine"))
		MachineType = DefineMachineType(GetItemTypeFromUniqueName("ScrapMachine"), 12);
}

stock SetItemTypeScrapValue(ItemType:itemtype, value)
{
	if(!IsValidItemType(itemtype))
	{
		err("Tried to assign scrap value to invalid item type.");
		return;
	}

	ItemTypeScrapValue[itemtype] = value;

	return;
}

hook OnMachineFinish(itemid, containerid)
{
	if(GetItemTypeMachineType(GetItemType(itemid)) != MachineType)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new
		subitemid,
		scrapcount;

	for(new i = GetContainerItemCount(containerid) - 1; i > -1; i--)
	{
		subitemid = GetContainerSlotItem(containerid, i);
		scrapcount += ItemTypeScrapValue[GetItemType(subitemid)];
		DestroyItem(subitemid);
	}

	scrapcount = scrapcount > MAX_MACHINE_ITEMS - 1 ? MAX_MACHINE_ITEMS - 1 : scrapcount;

	for(new i; i < scrapcount; i++)
	{
		subitemid = CreateItem(item_ScrapMetal);
		AddItemToContainer(containerid, subitemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
