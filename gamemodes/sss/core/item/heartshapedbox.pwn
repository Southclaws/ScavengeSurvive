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


hook OnGameModeInit()
{
	CreateItem(item_HeartShapedBox, 2912.3301, 2910.2800, 29.7780);
}

hook OnItemCreate(Item:itemid)
{
	dbg("global", CORE, "[OnItemCreate] in /gamemodes/sss/core/item/heartshapedbox.pwn");

	if(GetItemType(itemid) == item_HeartShapedBox)
	{
		if(GetItemLootIndex(itemid) != -1)
		{
			new containerid = GetItemArrayDataAtCell(itemid, 1);

			if(IsValidContainer(containerid))
			{
				AddItemToContainer(containerid, CreateItem(item_Dildo1));
				AddItemToContainer(containerid, CreateItem(item_Flowers));
				AddItemToContainer(containerid, CreateItem(item_AntiSepBandage));
				AddItemToContainer(containerid, CreateItem(item_ZorroMask));
			}
		}
	}
}
