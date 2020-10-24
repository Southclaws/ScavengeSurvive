/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


enum e_CAMPFIRE_DATA
{
			cmp_objSmoke,
Item:		cmp_foodItem,
Timer:		cmp_LifeTimer,
Timer:		cmp_CookTimer
}


static Item:cmp_ItemBeingCooked[MAX_ITEM] = {INVALID_ITEM_ID, ...};


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Campfire"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Campfire"), _:e_CAMPFIRE_DATA);
}

hook OnItemCreateInWorld(Item:itemid)
{
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
				data[cmp_LifeTimer] = defer cmp_BurnOut(_:itemid, 120000);
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
			data[cmp_LifeTimer] = defer cmp_BurnOut(_:itemid, 600000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(Item:itemid)
{
	if(GetItemType(itemid) == item_Campfire)
	{
		new Item:fooditem;
		GetItemArrayDataAtCell(itemid, _:fooditem, cmp_foodItem);

		if(IsValidItem(fooditem))
			cmp_ItemBeingCooked[fooditem] = INVALID_ITEM_ID;
	}
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_Campfire)
		return Y_HOOKS_BREAK_RETURN_1;

	if(cmp_ItemBeingCooked[itemid] != INVALID_ITEM_ID)
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(withitemid) == item_Campfire)
	{
		if(IsItemTypeFood(GetItemType(itemid)))
		{
			new Item:fooditem;
			GetItemArrayDataAtCell(withitemid, _:fooditem, cmp_foodItem);
			if(fooditem == INVALID_ITEM_ID)
			{
				cmp_CookItem(withitemid, itemid);
				ShowActionText(playerid, ls(playerid, "FIRELITSTAR", true), 3000);
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

cmp_CookItem(Item:itemid, Item:fooditem)
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
	data[cmp_CookTimer] = defer cmp_FinishCooking(_:itemid);
	SetItemArrayData(itemid, data, e_CAMPFIRE_DATA);
}

timer cmp_BurnOut[time](itemid, time)
{
	#pragma unused time
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(Item:itemid, x, y, z);
	DestroyItem(Item:itemid);

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
		Item:fooditem;
	GetItemArrayDataAtCell(Item:itemid, _:fooditem, cmp_foodItem);

	if(!IsValidItem(fooditem))
		return;

	GetItemPos(Item:itemid, x, y, z);

	CreateTimedDynamicObject(18726, x, y, z - 1.0, 0.0, 0.0, 0.0, 2000);
	SetFoodItemCooked(fooditem, 1);
	cmp_ItemBeingCooked[fooditem] = INVALID_ITEM_ID;

	return;
}
