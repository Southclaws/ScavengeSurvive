#include <YSI\y_hooks>


#define MAX_FOOD_ITEM (8)


enum E_FOOD_DATA
{
ItemType:	food_itemType,
Float:		food_foodValue
}


new
			food_Data[MAX_FOOD_ITEM][E_FOOD_DATA],
Iterator:	food_Index<MAX_FOOD_ITEM>,
			food_CurrentlyEating[MAX_PLAYERS],
Float:		food_EatProgress[MAX_PLAYERS],
Timer:		food_UpdateTimer[MAX_PLAYERS];


DefineFoodItem(ItemType:itemtype, Float:foodvalue)
{
	new id = Iter_Free(food_Index);

	food_Data[id][food_itemType] = itemtype;
	food_Data[id][food_foodValue] = foodvalue;

	Iter_Add(food_Index, id);

	return id;
}

IsItemTypeFood(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	foreach(new i : food_Index)
	{
		if(itemtype == food_Data[i][food_itemType])
			return 1;
	}

	return 0;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16)
	{
		new itemid = GetPlayerItem(playerid);
		if(IsValidItem(itemid))
		{
			foreach(new i : food_Index)
			{
				if(GetItemType(itemid) == food_Data[i][food_itemType])
				{
					StartEating(playerid, i);
				}
			}
		}
	}
	if(oldkeys & 16 && Iter_Contains(food_Index, food_CurrentlyEating[playerid]))
	{
		StopEating(playerid);
	}
	return 1;
}

StartEating(playerid, foodtype)
{
	food_CurrentlyEating[playerid] = foodtype;
	stop food_UpdateTimer[playerid];
	food_UpdateTimer[playerid] = repeat EatUpdate(playerid);
	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0);
}
timer EatUpdate[100](playerid)
{
	if(!IsValidItem(GetPlayerItem(playerid)))
	{
		StopEating(playerid);
		return;
	}

	if(food_EatProgress[playerid] == 32.0)
	{
		if(GetItemExtraData(GetPlayerItem(playerid)) == 0)
			gPlayerFP[playerid] += food_Data[food_CurrentlyEating[playerid]][food_foodValue] / 4;

		else
			gPlayerFP[playerid] += food_Data[food_CurrentlyEating[playerid]][food_foodValue];

		DestroyItem(GetPlayerItem(playerid));
		StopEating(playerid);
		return;
	}

	SetPlayerProgressBarValue(playerid, ActionBar, food_EatProgress[playerid]);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, 30.0);
	UpdatePlayerProgressBar(playerid, ActionBar);

	food_EatProgress[playerid] += 1.0;

	return;
}

StopEating(playerid)
{
	stop food_UpdateTimer[playerid];
	food_EatProgress[playerid] = 0.0;
	food_CurrentlyEating[playerid] = -1;
	HidePlayerProgressBar(playerid, ActionBar);
	ClearAnimations(playerid);
}
