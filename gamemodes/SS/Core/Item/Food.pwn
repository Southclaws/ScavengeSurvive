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
			food_CurrentItem[MAX_PLAYERS],
			food_CurrentFoodType[MAX_PLAYERS];


forward OnPlayerEat(playerid, itemid);
forward OnPlayerEaten(playerid, itemid);


hook OnPlayerConnect(playerid)
{
	food_CurrentItem[playerid] = -1;
	food_CurrentFoodType[playerid] = -1;
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


public OnPlayerUseItem(playerid, itemid)
{
	if(IsPlayerIdle(playerid))
	{
		if(!IsPlayerAtAnyVehicleTrunk(playerid))
		{
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
	}

	#if defined food_OnPlayerUseItem
		return food_OnPlayerUseItem(playerid, itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
 
#define OnPlayerUseItem food_OnPlayerUseItem
#if defined food_OnPlayerUseItem
	forward food_OnPlayerUseItem(playerid, itemid);
#endif

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16 && food_CurrentItem[playerid] != -1)
	{
		StopEating(playerid);
	}

	return 1;
}

StartEating(playerid, foodtype, itemid)
{
	food_CurrentItem[playerid] = itemid;
	food_CurrentFoodType[playerid] = foodtype;

	if(CallLocalFunction("OnPlayerEat", "dd", playerid, itemid))
	{
		food_CurrentItem[playerid] = -1;
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
		StartHoldAction(playerid, 1000);
	}

	return;
}

StopEating(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	food_CurrentItem[playerid] = -1;
}

public OnHoldActionFinish(playerid)
{
	if(food_CurrentItem[playerid] != -1)
	{
		if(!IsValidItem(food_CurrentItem[playerid]))
			return 0;

		if(GetPlayerItem(playerid) != food_CurrentItem[playerid])
			return 0;

		if(!IsItemTypeFood(GetItemType(food_CurrentItem[playerid])))
			return 0;

		if(CallLocalFunction("OnPlayerEaten", "dd", playerid, food_CurrentItem[playerid]))
		{
			StopEating(playerid);
			return 0;
		}

		if(GetItemExtraData(GetPlayerItem(playerid)) == 0)
		{
			SetPlayerFP(playerid, GetPlayerFP(playerid) + food_Data[food_CurrentFoodType[playerid]][food_foodValue] / 4);

			if(food_Data[food_CurrentFoodType[playerid]][food_canRawInfect])
				SetPlayerBitFlag(playerid, Infected, true);
		}
		else
		{
			SetPlayerFP(playerid, GetPlayerFP(playerid) + food_Data[food_CurrentFoodType[playerid]][food_foodValue]);
		}

		if(food_Data[food_CurrentFoodType[playerid]][food_consumeType] == 0)
		{
			DestroyItem(food_CurrentItem[playerid]);
			StopEating(playerid);
		}
		else
		{
			StartEating(playerid, food_CurrentFoodType[playerid], food_CurrentItem[playerid]);
		}

		return 1;
	}

	#if defined food_OnHoldActionFinish
		return food_OnHoldActionFinish(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish food_OnHoldActionFinish
#if defined food_OnHoldActionFinish
	forward food_OnHoldActionFinish(playerid);
#endif

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

	#if defined bbq_OnItemNameRender
		return bbq_OnItemNameRender(itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender bbq_OnItemNameRender
#if defined bbq_OnItemNameRender
	forward bbq_OnItemNameRender(itemid);
#endif


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
