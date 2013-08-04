#include <YSI\y_hooks>


#define MAX_FOOD_ITEM (16)


enum E_FOOD_DATA
{
ItemType:	food_itemType,
Float:		food_foodValue,
			food_canRawInfect,
			food_consumeType
}


static
			food_Data[MAX_FOOD_ITEM][E_FOOD_DATA],
			food_Total,
			food_CurrentlyEating[MAX_PLAYERS];


forward OnPlayerEat(playerid, itemid);
forward OnPlayerEaten(playerid, itemid);


hook OnPlayerConnect(playerid)
{
	food_CurrentlyEating[playerid] = -1;
}


/*==============================================================================

	Core

==============================================================================*/


DefineFoodItem(ItemType:itemtype, Float:foodvalue, canrawinfect, consumetype)
{
	food_Data[food_Total][food_itemType] = itemtype;
	food_Data[food_Total][food_foodValue] = foodvalue;
	food_Data[food_Total][food_canRawInfect] = canrawinfect;
	food_Data[food_Total][food_consumeType] = consumetype;

	return food_Total++;
}


/*==============================================================================

	Hooks and Internal

==============================================================================*/


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16 && IsPlayerIdle(playerid))
	{
		new itemid = GetPlayerItem(playerid);

		if(IsValidItem(itemid))
		{
			for(new i; i < food_Total; i++)
			{
				if(GetItemType(itemid) == food_Data[i][food_itemType])
				{
					StartEating(playerid, i, itemid);
				}
			}
		}
	}
	if(oldkeys & 16 && food_CurrentlyEating[playerid] != -1)
	{
		StopEating(playerid);
	}
	return 1;
}

StartEating(playerid, foodtype, itemid)
{
	food_CurrentlyEating[playerid] = foodtype;

	if(CallLocalFunction("OnPlayerEat", "dd", playerid, itemid))
	{
		food_CurrentlyEating[playerid] = -1;
		return;
	}

	if(food_Data[foodtype][food_consumeType] == 0)
	{
		ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0);
		StartHoldAction(playerid, 3200);
	}
	else
	{
		ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 0, 1);
		FinishEating(playerid);
	}

	return;
}

StopEating(playerid)
{
	if(food_Data[food_CurrentlyEating[playerid]][food_consumeType] == 0)
	{
		ClearAnimations(playerid);
		StopHoldAction(playerid);
	}

	food_CurrentlyEating[playerid] = -1;
}

FinishEating(playerid)
{
	new itemid = GetPlayerItem(playerid);

	if(CallLocalFunction("OnPlayerEaten", "dd", playerid, itemid))
	{
		StopEating(playerid);
		return;
	}

	if(GetItemExtraData(GetPlayerItem(playerid)) == 0)
	{
		gPlayerFP[playerid] += food_Data[food_CurrentlyEating[playerid]][food_foodValue] / 4;

		if(food_Data[food_CurrentlyEating[playerid]][food_canRawInfect])
			t:bPlayerGameSettings[playerid]<Infected>;
	}
	else
	{
		gPlayerFP[playerid] += food_Data[food_CurrentlyEating[playerid]][food_foodValue];
	}

	if(food_Data[food_CurrentlyEating[playerid]][food_consumeType] == 0)
		DestroyItem(itemid);

	StopEating(playerid);

	return;
}

public OnHoldActionFinish(playerid)
{
	if(food_CurrentlyEating[playerid] != -1)
	{
		FinishEating(playerid);
		return 1;
	}

	return CallLocalFunction("food_OnHoldActionFinish", "d", playerid);
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish food_OnHoldActionFinish
forward food_OnHoldActionFinish(playerid);

public OnItemNameRender(itemid)
{
	new foodtype = GetItemTypeFoodType(GetItemType(itemid));

	if(foodtype != -1)
	{
		if(food_Data[foodtype][food_consumeType] == 0)
		{
			if(GetItemExtraData(itemid) == 1)
				SetItemNameExtra(itemid, "Cooked");

			else
				SetItemNameExtra(itemid, "Uncooked");
		}
	}

	return CallLocalFunction("bbq_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender bbq_OnItemNameRender
forward bbq_OnItemNameRender(itemid);


/*==============================================================================

	Interface

==============================================================================*/


IsItemTypeFood(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	for(new i; i < food_Total; i++)
	{
		if(itemtype == food_Data[i][food_itemType])
			return 1;
	}

	return 0;
}

GetItemTypeFoodType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	for(new i; i < food_Total; i++)
	{
		if(itemtype == food_Data[i][food_itemType])
			return i;
	}

	return -1;
}
