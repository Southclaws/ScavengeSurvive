/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_BBQ				(256)

#define COOKER_STATE_NONE	(0)
#define COOKER_STATE_COOK	(1)


// Struct for item data
enum e_BBQ_DATA
{
	bbq_state,
	bbq_fuel,
	Item:bbq_grillItem1,
	Item:bbq_grillItem2, 
	bbq_grillPart1,
	bbq_grillPart2,
	bbq_cookTimer
}


static
			bbq_PlaceFoodTick[MAX_PLAYERS],
Item:		bbq_ItemBBQ[MAX_ITEM] = {INVALID_ITEM_ID, ...};


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Barbecue"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Barbecue"), 7);
}

hook OnItemCreate(Item:itemid)
{	if(GetItemType(itemid) == item_Barbecue)
	{
		new data[e_BBQ_DATA];

		if(GetItemLootIndex(itemid) != -1)
		{
			data[bbq_fuel] = random(10);
		}

		data[bbq_state] = COOKER_STATE_NONE;
		data[bbq_grillItem1] = INVALID_ITEM_ID;
		data[bbq_grillItem2] = INVALID_ITEM_ID;
		data[bbq_grillPart1] = 0;
		data[bbq_grillPart2] = 0;
		data[bbq_cookTimer] = 0;

		SetItemArrayData(itemid, _:data, 7);
	}
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(withitemid) == item_Barbecue)
	{
		if(_UseBbqHandler(playerid, itemid, withitemid))
			return 1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_UseBbqHandler(playerid, Item:itemid, Item:withitemid)
{
	new data[e_BBQ_DATA];

	GetItemArrayData(withitemid, _:data);

	new ItemType:itemtype = GetItemType(itemid);

	if(GetItemTypeLiquidContainerType(itemtype) != -1)
	{
		if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
		{
			ShowActionText(playerid, ls(playerid, "FUELNOTPETR", true), 3000);
			return 1;
		}

		new 
			Float:canfuel = GetLiquidItemLiquidAmount(itemid),
			Float:transfer;

		if(canfuel > 0.0)
		{
			transfer = (canfuel - 0.6 < 0.0) ? canfuel : 0.6;
			SetLiquidItemLiquidAmount(itemid, canfuel - transfer);
			SetItemArrayDataAtCell(withitemid, data[bbq_fuel] + 10, bbq_fuel);
			ShowActionText(playerid, ls(playerid, "BBQADDPETRO", true), 3000);
		}
		else
		{
			ShowActionText(playerid, ls(playerid, "PETROLEMPTY", true), 3000);
		}

		return 1;
	}

	if(IsItemTypeFood(itemtype))
	{
		new cooking;
		GetItemExtraData(itemid, cooking);
		if(cooking != 0)
		{
			ShowActionText(playerid, ls(playerid, "BBQALREADYC", true), 3000);
			return 1;
		}

		new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		GetItemPos(withitemid, x, y, z);
		GetItemRot(withitemid, r, r, r);

		if(data[bbq_grillItem1] == INVALID_ITEM_ID)
		{
			CreateItemInWorld(itemid,
				x + (0.25 * floatsin(-r + 90.0, degrees)),
				y + (0.25 * floatcos(-r + 90.0, degrees)),
				z + 0.818,
				.rz = r);

			bbq_ItemBBQ[itemid] = withitemid;
			SetItemArrayDataAtCell(withitemid, _:itemid, bbq_grillItem1);
			bbq_PlaceFoodTick[playerid] = GetTickCount();
			ShowActionText(playerid, ls(playerid, "BBQFOODADDE", true), 3000);

			return 1;
		}
		else if(data[bbq_grillItem2]  == INVALID_ITEM_ID)
		{
			CreateItemInWorld(itemid,
				x + (0.25 * floatsin(-r - 90.0, degrees)),
				y + (0.25 * floatcos(-r - 90.0, degrees)),
				z + 0.818,
				.rz = r);

			bbq_ItemBBQ[itemid] = withitemid;
			SetItemArrayDataAtCell(withitemid, _:itemid, bbq_grillItem2);
			bbq_PlaceFoodTick[playerid] = GetTickCount();
			ShowActionText(playerid, ls(playerid, "BBQFOODADDE", true), 3000);

			return 1;
		}
	}

	if(itemtype == item_FireLighter)
	{
		if(data[bbq_fuel] <= 0)
		{
			ShowActionText(playerid, ls(playerid, "BBQFUELEMPT", true), 3000);
			return 1;
		}

		new Timer:timerid = defer bbq_FinishCooking(_:withitemid);

		SetItemArrayDataAtCell(withitemid, _:timerid, bbq_cookTimer);
		SetItemArrayDataAtCell(withitemid, COOKER_STATE_COOK, bbq_state);

		_LightBBQ(withitemid);

		ShowActionText(playerid, ls(playerid, "BBQLITSTART", true), 3000);

		return 1;
	}

	return 0;
}

_LightBBQ(Item:itemid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, r, r, r);

	SetItemArrayDataAtCell(itemid, CreateDynamicObject(18701,
		x + (0.25 * floatsin(-r + 90.0, degrees)),
		y + (0.25 * floatcos(-r + 90.0, degrees)),
		z - 0.6,
		0.0, 0.0, r), bbq_grillPart1);

	SetItemArrayDataAtCell(itemid, CreateDynamicObject(18701,
		x + (0.25 * floatsin(-r + 270.0, degrees)),
		y + (0.25 * floatcos(-r + 270.0, degrees)),
		z - 0.6,
		0.0, 0.0, r), bbq_grillPart2);

	return 1;
}

timer bbq_FinishCooking[30000](itemid)
{
	new data[e_BBQ_DATA];

	GetItemArrayData(Item:itemid, data);

	DestroyDynamicObject(data[bbq_grillPart1]);
	DestroyDynamicObject(data[bbq_grillPart2]);

	SetItemExtraData(data[bbq_grillItem1], 1);
	SetItemExtraData(data[bbq_grillItem2], 1);

	SetItemArrayDataAtCell(Item:itemid, data[bbq_fuel] - 1, bbq_fuel);
	SetItemArrayDataAtCell(Item:itemid, COOKER_STATE_NONE, bbq_state);
}


hook OnPlayerPickUpItem(playerid, Item:itemid)
{	if(GetItemType(itemid) == item_Barbecue)
	{
		if(GetTickCountDifference(GetTickCount(), bbq_PlaceFoodTick[playerid]) < 1000)
			return Y_HOOKS_BREAK_RETURN_1;

		new data[e_BBQ_DATA];

		GetItemArrayData(itemid, data);

		if(data[bbq_state] != COOKER_STATE_NONE)
			return Y_HOOKS_BREAK_RETURN_1;

		if(IsValidItem(data[bbq_grillItem1]))
		{
			GiveWorldItemToPlayer(playerid, data[bbq_grillItem1], 1);
			SetItemArrayDataAtCell(itemid, _:INVALID_ITEM_ID, bbq_grillItem1);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(IsValidItem(data[bbq_grillItem2]))
		{
			GiveWorldItemToPlayer(playerid, data[bbq_grillItem2], 1);
			SetItemArrayDataAtCell(itemid, _:INVALID_ITEM_ID, bbq_grillItem2);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	if(bbq_ItemBBQ[itemid] != INVALID_ITEM_ID)
	{
		new grillitem1, grillitem2;
		GetItemArrayDataAtCell(bbq_ItemBBQ[itemid], grillitem1, bbq_grillItem1);
		GetItemArrayDataAtCell(bbq_ItemBBQ[itemid], grillitem2, bbq_grillItem2);
		if(grillitem1 == _:itemid)
		{
			SetItemArrayDataAtCell(bbq_ItemBBQ[itemid], _:INVALID_ITEM_ID, bbq_grillItem1);
		}
		else if(grillitem2 == _:itemid)
		{
			SetItemArrayDataAtCell(bbq_ItemBBQ[itemid], _:INVALID_ITEM_ID, bbq_grillItem2);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
