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


public OnItemCreate(itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_GasCan)
		{
			SetItemExtraData(itemid, random(10));
		}
	}

	#if defined gas_OnItemCreate
		return gas_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate gas_OnItemCreate
#if defined gas_OnItemCreate
	forward gas_OnItemCreate(itemid);
#endif

public OnItemNameRender(itemid, ItemType:itemtype)
{
	if(itemtype == item_GasCan)
	{
		new str[4];
		valstr(str, GetItemExtraData(itemid));
		strcat(str, "L");
		SetItemNameExtra(itemid, str);
	}

	#if defined gas_OnItemNameRender
		return gas_OnItemNameRender(itemid, itemtype);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender gas_OnItemNameRender
#if defined gas_OnItemNameRender
	forward gas_OnItemNameRender(itemid, ItemType:itemtype);
#endif
