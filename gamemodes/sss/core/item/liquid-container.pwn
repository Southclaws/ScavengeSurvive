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


#include <YSI\y_hooks>


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
			liq_ItemTypeLiquidContainer[ITM_MAX_TYPES] = {INVALID_LIQUID_CONTAINER, ...},
			liq_Total;

static
			liq_CurrentItem[MAX_PLAYERS];


forward OnPlayerDrink(playerid, itemid);
forward OnPlayerDrank(playerid, itemid);
forward OnPlayerDank(memes);


stock DefineLiquidContainerItem(ItemType:itemtype, Float:capacity, bool:reusable, {Float, _}:...)
{
	if(liq_Total >= MAX_LIQUID_TYPES - 1)
	{
		print("ERROR: MAX_LIQUID_TYPES limit reached!");
		return -1;
	}

	liq_Data[liq_Total][liq_itemtype] = itemtype;
	liq_Data[liq_Total][liq_capacity] = capacity;
	liq_Data[liq_Total][liq_reusable] = reusable;

	liq_ItemTypeLiquidContainer[itemtype] = liq_Total;

	for(new i = 3; i < numargs(); i += 2)
	{
		liq_Data[liq_Total][liq_liquidType][ liq_Data[liq_Total][liq_liquidnum] ] = getarg(i);
		liq_Data[liq_Total][liq_liquidProb][ liq_Data[liq_Total][liq_liquidnum] ] = getarg(i + 1);

	}

	return liq_Total++;
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{
	if(liq_ItemTypeLiquidContainer[itemtype] != INVALID_LIQUID_CONTAINER)
	{
		new
			data[2],
			name[MAX_LIQUID_NAME];

		GetItemArrayData(itemid, data);
		GetLiquidName(data[1], name);

		SetItemNameExtra(itemid, sprintf("%s %.1f/%.2f", name, float(data[0]), liq_Data[liq_ItemTypeLiquidContainer[itemtype]][liq_capacity]));
	}
}

hook OnPlayerUseItem(playerid, itemid)
{
	if(liq_ItemTypeLiquidContainer[GetItemType(itemid)] != INVALID_LIQUID_CONTAINER)
	{
		_StartDrinking(playerid, itemid);
	}
}

_StartDrinking(playerid, itemid, continuing = false)
{
	if(!IsPlayerIdle(playerid) && !continuing)
		return;

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return;

	liq_CurrentItem[playerid] = itemid;

	if(CallLocalFunction("OnPlayerDrink", "dd", playerid, itemid))
	{
		_StopDrinking(playerid);
		return;
	}

	ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 0, 1);
	StartHoldAction(playerid, 1000);

	return;
}

_StopDrinking(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	liq_CurrentItem[playerid] = -1;
}

_DrinkItem(playerid, itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	if(GetPlayerItem(playerid) != itemid)
		return 0;

	new liqcont = liq_ItemTypeLiquidContainer[GetItemType(itemid)];

	if(liqcont == -1)
		return 0;

	if(CallLocalFunction("OnPlayerDrank", "dd", playerid, itemid))
	{
		_StopDrinking(playerid);
		return 0;
	}

	if(GetItemExtraData(itemid) > 0)
	{
		new Float:amount = GetItemArrayDataAtCell(itemid, LIQUID_ITEM_ARRAY_CELL_AMOUNT);
		SetPlayerFP(playerid, GetPlayerFP(playerid) + GetLiquidFoodValue(GetItemArrayDataAtCell(itemid, LIQUID_ITEM_ARRAY_CELL_TYPE)));

		printf("amount pre %f", amount);
		amount -= 0.2;
		printf("amount aft %f", amount);
		SetItemArrayDataAtCell(itemid, _:amount, LIQUID_ITEM_ARRAY_CELL_AMOUNT);
	}

	if(GetItemExtraData(itemid) > 0)
		_StartDrinking(playerid, itemid, true);

	else
		_StopDrinking(playerid);

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionFinish] in /gamemodes/sss/core/item/food.pwn");

	if(liq_CurrentItem[playerid] != -1)
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
		if(liq_CurrentItem[playerid] != -1)
			_StopDrinking(playerid);
	}
}

hook OnPlayerCrafted(playerid, craftset, result)
{
	d:3:GLOBAL_DEBUG("[OnPlayerCrafted] in /gamemodes/sss/core/item/bottle.pwn");

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


stock IsItemTypeLiquidContainer(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return false;

	return liq_ItemTypeLiquidContainer[itemtype];
}

stock Float:GetLiquidItemLiquidAmount(itemid)
{
	if(!IsValidItem(itemid))
		return -1;

	if(liq_ItemTypeLiquidContainer[GetItemType(itemid)] == -1)
		return -1;

	return float(GetItemArrayDataAtCell(itemid, LIQUID_ITEM_ARRAY_CELL_AMOUNT));
}

stock SetLiquidItemLiquidAmount(itemid, Float:amount)
{
	if(!IsValidItem(itemid))
		return -1;

	if(liq_ItemTypeLiquidContainer[GetItemType(itemid)] == -1)
		return -1;

	return SetItemArrayDataAtCell(itemid, _:amount, LIQUID_ITEM_ARRAY_CELL_AMOUNT);
}

stock GetLiquidItemLiquidType(itemid)
{
	if(!IsValidItem(itemid))
		return -1;

	if(liq_ItemTypeLiquidContainer[GetItemType(itemid)] == -1)
		return -1;

	return GetItemArrayDataAtCell(itemid, LIQUID_ITEM_ARRAY_CELL_TYPE);
}

stock SetLiquidItemLiquidType(itemid, type)
{
	if(!IsValidItem(itemid))
		return -1;

	if(liq_ItemTypeLiquidContainer[GetItemType(itemid)] == -1)
		return -1;

	return SetItemArrayDataAtCell(itemid, type, LIQUID_ITEM_ARRAY_CELL_TYPE);
}
