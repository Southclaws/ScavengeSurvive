/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


#include <YSI\y_hooks>


enum e_CAMPFIRE_DATA
{
			cmp_objSmoke,
			cmp_foodItem,
Timer:		cmp_LifeTimer,
Timer:		cmp_CookTimer
}


static
			cmp_ItemBeingCooked[ITM_MAX] = {INVALID_ITEM_ID, ...};


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Campfire"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Campfire"), _:e_CAMPFIRE_DATA);
}

hook OnItemCreateInWorld(itemid)
{
	dbg("global", CORE, "[OnItemCreateInWorld] in /gamemodes/sss/core/item/campfire.pwn");

	if(GetItemType(itemid) == item_Campfire)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			weatherid = GetGlobalWeather(),
			data[e_CAMPFIRE_DATA];

		GetItemPos(itemid, x, y, z);

		data[cmp_objSmoke] = INVALID_OBJECT_ID;
		data[cmp_foodItem] = INVALID_ITEM_ID;

		SetItemArrayData(itemid, data, _:e_CAMPFIRE_DATA);

		if(weatherid == 8 || weatherid == 16)
		{
			if(random(100) < 40)
			{
				data[cmp_LifeTimer] = defer cmp_BurnOut(itemid, 120000);
			}
			else
			{
				DestroyItem(itemid);
				CreateItem(item_WoodLog, x - 0.25 + frandom(0.5), y - 0.25 + frandom(0.5), z, .rz = random(360));
				CreateItem(item_WoodLog, x - 0.25 + frandom(0.5), y - 0.25 + frandom(0.5), z, .rz = random(360));
				CreateItem(item_WoodLog, x - 0.25 + frandom(0.5), y - 0.25 + frandom(0.5), z, .rz = random(360));
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
		else
		{
			data[cmp_LifeTimer] = defer cmp_BurnOut(itemid, 600000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(itemid)
{
	if(GetItemType(itemid) == item_Campfire)
	{
		new fooditem = GetItemArrayDataAtCell(itemid, cmp_foodItem);

		if(IsValidItem(fooditem))
			cmp_ItemBeingCooked[fooditem] = INVALID_ITEM_ID;
	}
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerPickedUpItem] in /gamemodes/sss/core/item/campfire.pwn");

	if(GetItemType(itemid) == item_Campfire)
		return Y_HOOKS_BREAK_RETURN_1;

	if(cmp_ItemBeingCooked[itemid] != INVALID_ITEM_ID)
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	dbg("global", CORE, "[OnPlayerUseItemWithItem] in /gamemodes/sss/core/world/campfire.pwn");

	if(GetItemType(withitemid) == item_Campfire)
	{
		if(IsItemTypeFood(GetItemType(itemid)))
		{
			if(GetItemArrayDataAtCell(withitemid, cmp_foodItem) == INVALID_ITEM_ID)
			{
				cmp_CookItem(withitemid, itemid);
				ShowActionText(playerid, ls(playerid, "FIRELITSTAR", true), 3000);
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

cmp_CookItem(itemid, fooditem)
{
	new
		Float:x,
		Float:y,
		Float:z,
		data[e_CAMPFIRE_DATA];

	GetItemPos(itemid, x, y, z);

	CreateItemInWorld(fooditem, x, y, z + 0.3, .rz = frandom(360.0));

	cmp_ItemBeingCooked[fooditem] = itemid;
	data[cmp_foodItem] = fooditem;
	data[cmp_CookTimer] = defer cmp_FinishCooking(itemid);
	SetItemArrayData(itemid, data, e_CAMPFIRE_DATA);
}

timer cmp_BurnOut[time](itemid, time)
{
	#pragma unused time
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	DestroyItem(itemid);

	CreateItem(item_BurntLog, x - 0.25 + frandom(0.5), y - 0.25 + frandom(0.5), z, .rz = random(360));
	CreateItem(item_BurntLog, x - 0.25 + frandom(0.5), y - 0.25 + frandom(0.5), z, .rz = random(360));
	CreateItem(item_BurntLog, x - 0.25 + frandom(0.5), y - 0.25 + frandom(0.5), z, .rz = random(360));
}

timer cmp_FinishCooking[60000](itemid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		fooditem = GetItemArrayDataAtCell(itemid, cmp_foodItem);

	if(!IsValidItem(fooditem))
		return;

	GetItemPos(itemid, x, y, z);

	CreateTimedDynamicObject(18726, x, y, z - 1.0, 0.0, 0.0, 0.0, 2000);
	SetFoodItemCooked(fooditem, 1);
	cmp_ItemBeingCooked[fooditem] = INVALID_ITEM_ID;

	return;
}
