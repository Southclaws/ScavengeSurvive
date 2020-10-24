/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_FOOD_ITEM (64)


enum e_FOOD_ITEM_DATA
{
			food_cooked,
			food_amount,
			food_subType
}

enum E_FOOD_DATA
{
ItemType:	food_itemType,
			food_maxBites,
Float:		food_biteValue,
			food_canCook,
			food_canRawInfect,
			food_destroyOnEnd
}


static
			food_Data[MAX_FOOD_ITEM][E_FOOD_DATA],
			food_ItemTypeFoodType[MAX_ITEM_TYPE] = {-1, ...},
			food_Total,
Item:		food_CurrentItem[MAX_PLAYERS];


forward OnPlayerEat(playerid, itemid);
forward OnPlayerEaten(playerid, itemid);


hook OnPlayerConnect(playerid)
{
	food_CurrentItem[playerid] = INVALID_ITEM_ID;
}


/*==============================================================================

	Core

==============================================================================*/


DefineFoodItem(ItemType:itemtype, maxbites, Float:bitevalue, cancook, canrawinfect, destroyonend)
{
	SetItemTypeMaxArrayData(itemtype, 3);

	food_Data[food_Total][food_itemType]		= itemtype;
	food_Data[food_Total][food_maxBites]		= maxbites;
	food_Data[food_Total][food_biteValue]		= bitevalue;
	food_Data[food_Total][food_canCook]			= cancook;
	food_Data[food_Total][food_canRawInfect]	= canrawinfect;
	food_Data[food_Total][food_destroyOnEnd]	= destroyonend;

	food_ItemTypeFoodType[itemtype] = food_Total;

	return food_Total++;
}


/*==============================================================================

	Hooks and Internal

==============================================================================*/


hook OnItemCreate(Item:itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		new foodtype = food_ItemTypeFoodType[GetItemType(itemid)];

		if(foodtype != -1)
		{
			SetItemArrayDataAtCell(itemid, 0, food_cooked, true);
			SetItemArrayDataAtCell(itemid, food_Data[_:foodtype][food_maxBites] - random(food_Data[_:foodtype][food_maxBites] / 2), food_amount, true);
		}
	}
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(food_ItemTypeFoodType[GetItemType(itemid)] != -1)
		_StartEating(playerid, itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16 && food_CurrentItem[playerid] != INVALID_ITEM_ID)
	{
		_StopEating(playerid);
	}

	return 1;
}

_StartEating(playerid, Item:itemid, continuing = false)
{
	if(!IsPlayerIdle(playerid) && !continuing)
		return;

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return;

	food_CurrentItem[playerid] = itemid;

	if(CallLocalFunction("OnPlayerEat", "dd", playerid, _:itemid))
	{
		_StopEating(playerid);
		return;
	}

	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0);
	StartHoldAction(playerid, 3200);

	return;
}

_StopEating(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	food_CurrentItem[playerid] = INVALID_ITEM_ID;
}

_EatItem(playerid, Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	if(GetPlayerItem(playerid) != itemid)
		return 0;

	new foodtype = food_ItemTypeFoodType[GetItemType(itemid)];

	if(foodtype == -1)
		return 0;

	if(CallLocalFunction("OnPlayerEaten", "dd", playerid, _:itemid))
	{
		_StopEating(playerid);
		return 0;
	}

	new amount, cooked;
	GetItemArrayDataAtCell(itemid, amount, food_amount);
	GetItemArrayDataAtCell(itemid, cooked, food_cooked);

	if(amount > 0)
	{
		if(food_Data[foodtype][food_canCook] && cooked == 0)
		{
			SetPlayerFP(playerid, GetPlayerFP(playerid) + food_Data[foodtype][food_biteValue] * 0.7);

			if(food_Data[foodtype][food_canRawInfect])
				SetPlayerInfectionIntensity(playerid, 0, 1);
		}
		else
		{
			SetPlayerFP(playerid, GetPlayerFP(playerid) + food_Data[foodtype][food_biteValue]);
		}

		SetItemArrayDataAtCell(itemid, amount - 1, food_amount, false);
	}

	if(amount > 0)
	{
		_StartEating(playerid, itemid, true);
	}
	else
	{
		_StopEating(playerid);

		if(food_Data[foodtype][food_destroyOnEnd])
			DestroyItem(itemid);
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	if(food_CurrentItem[playerid] != INVALID_ITEM_ID)
	{
		_EatItem(playerid, food_CurrentItem[playerid]);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	new foodtype = food_ItemTypeFoodType[itemtype];
	if(foodtype != -1)
	{
		new data[e_FOOD_ITEM_DATA];
		GetItemArrayData(itemid, data);

		new amount = data[food_amount];
		if(food_Data[foodtype][food_canCook])
		{
			if(data[food_cooked] == 1)
				SetItemNameExtra(itemid, sprintf("Cooked, %d%%", floatround((float(amount) / food_Data[foodtype][food_maxBites]) * 100.0)));

			else
				SetItemNameExtra(itemid, sprintf("Uncooked, %d%%", floatround((float(amount) / food_Data[foodtype][food_maxBites]) * 100.0)));
		}
		else
		{
			SetItemNameExtra(itemid, sprintf("%d%%", floatround((float(amount) / food_Data[foodtype][food_maxBites]) * 100.0)));
		}
	}
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsItemTypeFood(ItemType:itemtype)
{
	return GetItemTypeFoodType(itemtype) != -1;
}

stock GetItemTypeFoodType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	return food_ItemTypeFoodType[itemtype];
}

// food_itemType
stock ItemType:GetFoodTypeItemType(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return INVALID_ITEM_TYPE;

	return food_Data[foodtype][food_itemType];
}

// food_maxBites
stock GetFoodTypeMaxBites(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return 0;

	return food_Data[foodtype][food_maxBites];
}

// food_biteValue
stock Float:GetFoodTypeBiteValue(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return 0.0;

	return food_Data[foodtype][food_biteValue];
}

// food_canCook
stock GetFoodTypeCanCook(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return 0;

	return food_Data[foodtype][food_canCook];
}

// food_canRawInfect
stock GetFoodTypeCanRawInfect(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return 0;

	return food_Data[foodtype][food_canRawInfect];
}

// food_destroyOnEnd
stock GetFoodTypeDestroyOnEnd(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return 0;

	return food_Data[foodtype][food_destroyOnEnd];
}

// Item specific

// food_cooked
stock GetFoodItemCooked(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, food_cooked);
}

stock Error:SetFoodItemCooked(Item:itemid, value)
{
	return SetItemArrayDataAtCell(itemid, value, food_cooked);
}

// food_amount
stock GetFoodItemAmount(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, food_amount);
}

stock SetFoodItemAmount(Item:itemid, value)
{
	return SetItemArrayDataAtCell(itemid, value, food_amount);
}

// food_subType
stock GetFoodItemSubType(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, food_subType);
}

stock SetFoodItemSubType(Item:itemid, value)
{
	return SetItemArrayDataAtCell(itemid, value, food_subType);
}
