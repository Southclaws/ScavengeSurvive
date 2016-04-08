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


hook OnItemCreate(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemCreate] in /gamemodes/sss/core/item/gascan.pwn");

	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_GasCan)
		{
			SetItemExtraData(itemid, random(10));
		}
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{
	d:3:GLOBAL_DEBUG("[OnItemNameRender] in /gamemodes/sss/core/item/gascan.pwn");

	if(itemtype == item_GasCan)
	{
		new str[4];
		valstr(str, GetItemExtraData(itemid));
		strcat(str, "L");
		SetItemNameExtra(itemid, str);
	}
}
