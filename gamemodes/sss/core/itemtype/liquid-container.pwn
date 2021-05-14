/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_LIQUID_CONTAINER		(16)
#define INVALID_LIQUID_CONTAINER	(-1)


enum e_LIQUID_CONTAINER_ITEM_DATA
{
Float:		LIQUID_ITEM_ARRAY_CELL_AMOUNT,
			LIQUID_ITEM_ARRAY_CELL_TYPE
}

enum E_LIQUID_CONTAINER_DATA
{
ItemType:	liq_itemtype,
Float:		liq_capacity,		// measured in litres
bool:		liq_reusable,		// once opened, can be refilled and sealed?
			liq_liquidType[8],	// list of liquids that can spawn inside
			liq_liquidProb[8],	// list of probabilities for above liquids
			liq_liquidnum
}


static
			liq_Data[MAX_LIQUID_TYPES][E_LIQUID_CONTAINER_DATA],
			liq_ItemTypeLiquidContainer[MAX_ITEM_TYPE] = {INVALID_LIQUID_CONTAINER, ...},
			liq_Total;

static
Item:		liq_CurrentItem[MAX_PLAYERS],
			liq_UseWithItemTick[MAX_PLAYERS];


forward OnPlayerDrink(playerid, itemid);
forward OnPlayerDrank(playerid, itemid);
forward OnPlayerDank(memes);


hook OnPlayerConnect(playerid)
{
	liq_CurrentItem[playerid] = INVALID_ITEM_ID;
	liq_UseWithItemTick[playerid] = 0;
}

stock DefineLiquidContainerItem(ItemType:itemtype, Float:capacity, bool:reusable, {Float, _}:...)
{
	if(liq_Total >= MAX_LIQUID_TYPES - 1)
	{
		err("MAX_LIQUID_TYPES limit reached!");
		return -1;
	}

	SetItemTypeMaxArrayData(itemtype, 2);

	liq_Data[liq_Total][liq_itemtype] = itemtype;
	liq_Data[liq_Total][liq_capacity] = capacity;
	liq_Data[liq_Total][liq_reusable] = reusable;

	liq_ItemTypeLiquidContainer[itemtype] = liq_Total;

	for(new i = 3; i < numargs(); i += 2)
	{
		liq_Data[liq_Total][liq_liquidType][ liq_Data[liq_Total][liq_liquidnum] ] = getarg(i);
		liq_Data[liq_Total][liq_liquidProb][ liq_Data[liq_Total][liq_liquidnum] ] = getarg(i + 1);
		liq_Data[liq_Total][liq_liquidnum]++;
	}

	return liq_Total++;
}

hook OnItemCreateInWorld(Item:itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		new
			ItemType:itemtype,
			liqcont,
			liqlist[8],
			size;

		itemtype = GetItemType(itemid);
		liqcont = liq_ItemTypeLiquidContainer[itemtype];

		if(liqcont != INVALID_LIQUID_CONTAINER)
		{
			for(new i; i < liq_Data[liqcont][liq_liquidnum]; i++)
			{
				if(random(100) > liq_Data[liqcont][liq_liquidProb][i])
					continue;

				liqlist[size++] = liq_Data[liqcont][liq_liquidType][i];
			}

			if(size > 0)
			{
				SetItemArrayDataAtCell(itemid, _:frandom(liq_Data[liqcont][liq_capacity]), LIQUID_ITEM_ARRAY_CELL_AMOUNT, true);
				SetItemArrayDataAtCell(itemid, liqlist[random(size)], LIQUID_ITEM_ARRAY_CELL_TYPE, true);
			}
		}
	}
}

hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	if(liq_ItemTypeLiquidContainer[itemtype] != INVALID_LIQUID_CONTAINER)
	{
		new
			data[2],
			name[MAX_LIQUID_NAME];

		GetItemArrayData(itemid, data);

		if(Float:data[0] > 0.001)
		{
			GetLiquidName(data[1], name);
			SetItemNameExtra(itemid, sprintf("%s %.1f/%.2f", name, Float:data[0], liq_Data[liq_ItemTypeLiquidContainer[itemtype]][liq_capacity]));
		}
		else
		{
			SetItemNameExtra(itemid, "Empty");
		}
	}
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(liq_ItemTypeLiquidContainer[GetItemType(itemid)] != INVALID_LIQUID_CONTAINER)
	{
		liq_UseWithItemTick[playerid] = GetTickCount();
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(liq_ItemTypeLiquidContainer[GetItemType(itemid)] != INVALID_LIQUID_CONTAINER)
	{
		if(GetTickCountDifference(GetTickCount(), liq_UseWithItemTick[playerid]) > 10)
			_StartDrinking(playerid, itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_StartDrinking(playerid, Item:itemid, continuing = false)
{
	if(!IsPlayerIdle(playerid) && !continuing)
		return;

	if(CallLocalFunction("OnPlayerDrink", "dd", playerid, _:itemid))
	{
		if(continuing)
			_StopDrinking(playerid);

		return;
	}

	liq_CurrentItem[playerid] = itemid;

	ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 0, 1);
	StartHoldAction(playerid, 1000);

	return;
}

_StopDrinking(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	liq_CurrentItem[playerid] = INVALID_ITEM_ID;
}

_DrinkItem(playerid, Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	if(GetPlayerItem(playerid) != itemid)
		return 0;

	new liqcont = liq_ItemTypeLiquidContainer[GetItemType(itemid)];

	if(liqcont == -1)
		return 0;

	if(CallLocalFunction("OnPlayerDrank", "dd", playerid, _:itemid))
	{
		_StopDrinking(playerid);
		return 0;
	}

	new ed;
	GetItemExtraData(itemid, ed);
	if(ed > 0)
	{
		new
			liquidtype,
			Float:liquidamount;
		GetItemArrayDataAtCell(itemid, liquidtype, LIQUID_ITEM_ARRAY_CELL_TYPE);
		GetItemArrayDataAtCell(itemid, _:liquidamount, LIQUID_ITEM_ARRAY_CELL_AMOUNT);

		SetPlayerFP(playerid, GetPlayerFP(playerid) + GetLiquidFoodValue(liquidtype));
		SetItemArrayDataAtCell(itemid, _:(liquidamount - 0.2), LIQUID_ITEM_ARRAY_CELL_AMOUNT, true);

		_StartDrinking(playerid, itemid, true);
	}
	else
	{
		_StopDrinking(playerid);
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	if(liq_CurrentItem[playerid] != INVALID_ITEM_ID)
	{
		_DrinkItem(playerid, liq_CurrentItem[playerid]);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16 && !(newkeys & 16))
	{
		if(liq_CurrentItem[playerid] != INVALID_ITEM_ID)
			_StopDrinking(playerid);
	}
}

hook OnPlayerCrafted(playerid, CraftSet:craftset, result)
{
	/*
		Todo:
		Implement generic crafting (without craftsets)
		Check if crafted craftset is a temp craftset
		Check if amount of items is 2
		Check if both items were liquid containers

	if(GetItemType(result) == item_Bottle)
	{
		new
			itemid1,
			itemid2,
			amount;

		itemid1 = GetPlayerSelectedCraftItemID(playerid, 0);
		itemid2 = GetPlayerSelectedCraftItemID(playerid, 1);
		amount = GetFoodItemAmount(itemid1) + GetFoodItemAmount(itemid2);

		SetFoodItemSubType(itemid1, GetFoodItemSubType(itemid1) | GetFoodItemSubType(itemid2));
		SetFoodItemAmount(itemid1, (amount > 10) ? 10 : amount);

		SetFoodItemAmount(itemid2, 0);
		SetFoodItemSubType(itemid2, -1);
	}
	*/
	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Core

==============================================================================*/


stock GetItemTypeLiquidContainerType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	return liq_ItemTypeLiquidContainer[itemtype];
}

//liq_itemtype
stock GetLiquidContainerTypeItemType(liqcont)
{
	if(!(0 <= liqcont < liq_Total))
		return 0;

	return liq_Data[liqcont][liq_itemtype]
}

//liq_capacity
stock Float:GetLiquidContainerTypeCapacity(liqcont)
{
	if(!(0 <= liqcont < liq_Total))
		return 0.0;

	return liq_Data[liqcont][liq_capacity];
}

//liq_reusable
stock IsLiquidContainerTypeReusable(liqcont)
{
	if(!(0 <= liqcont < liq_Total))
		return 0;

	return liq_Data[liqcont][liq_reusable];
}

stock Float:GetLiquidItemLiquidAmount(Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0.0;

	if(liq_ItemTypeLiquidContainer[GetItemType(itemid)] == -1)
		return 0.0;

	new Float:amount;
	GetItemArrayDataAtCell(itemid, _:amount, LIQUID_ITEM_ARRAY_CELL_AMOUNT);
	return amount;
}

stock Error:SetLiquidItemLiquidAmount(Item:itemid, Float:amount)
{
	if(!IsValidItem(itemid))
		return NoError();

	new ItemType:itemtype = GetItemType(itemid);
	if(liq_ItemTypeLiquidContainer[itemtype] == -1)
		return NoError();

	if(amount > liq_Data[liq_ItemTypeLiquidContainer[itemtype]][liq_capacity])
	{
		return SetItemArrayDataAtCell(itemid, _:liq_Data[liq_ItemTypeLiquidContainer[itemtype]][liq_capacity], LIQUID_ITEM_ARRAY_CELL_AMOUNT, true);
	}

	return SetItemArrayDataAtCell(itemid, _:amount, LIQUID_ITEM_ARRAY_CELL_AMOUNT, true);
}

stock GetLiquidItemLiquidType(Item:itemid)
{
	if(!IsValidItem(itemid))
		return -1;

	if(liq_ItemTypeLiquidContainer[GetItemType(itemid)] == -1)
		return -1;

	new type;
	GetItemArrayDataAtCell(itemid, type, LIQUID_ITEM_ARRAY_CELL_TYPE);
	return type;
}

stock Error:SetLiquidItemLiquidType(Item:itemid, type)
{
	if(!IsValidItem(itemid))
		return NoError();

	if(liq_ItemTypeLiquidContainer[GetItemType(itemid)] == -1)
		return NoError();

	return SetItemArrayDataAtCell(itemid, type, LIQUID_ITEM_ARRAY_CELL_TYPE, true);
}
