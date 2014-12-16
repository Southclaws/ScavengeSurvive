static
	drink_Types[2][6]=
	{
		"Water",
		"Beer"
	};


public OnItemCreate(itemid)
{
	if(IsItemLoot(itemid))
	{
		if(GetItemType(itemid) == item_Bottle || GetItemType(itemid) == item_CanDrink)
		{
			SetFoodItemSubType(itemid, random(2));
		}
	}

	#if defined bot_OnItemCreate
		return bot_OnItemCreate(itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate bot_OnItemCreate
#if defined bot_OnItemCreate
	forward bot_OnItemCreate(itemid);
#endif


public OnItemNameRender(itemid, ItemType:itemtype)
{
	if(itemtype == item_Bottle || itemtype == item_CanDrink)
	{
		new
			foodtype = GetItemTypeFoodType(itemtype),
			subtype = GetFoodItemSubType(itemid),
			amount = GetFoodItemAmount(itemid);

		if(amount > 0 && subtype < sizeof(drink_Types))
		{
			SetItemNameExtra(itemid, sprintf("%s, %d/%d", drink_Types[subtype], amount, GetFoodTypeMaxBites(foodtype)));
		}
		else
		{
			SetItemNameExtra(itemid, "Empty");
		}
	}

	#if defined bot_OnItemNameRender
		return bot_OnItemNameRender(itemid, itemtype);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender bot_OnItemNameRender
#if defined bot_OnItemNameRender
	forward bot_OnItemNameRender(itemid, ItemType:itemtype);
#endif

public OnPlayerEaten(playerid, itemid)
{
	if(GetItemType(itemid) == item_Bottle || GetItemType(itemid) == item_CanDrink)
	{
		new type = GetFoodItemSubType(itemid);

		if(type == 1)
			SetPlayerDrunkLevel(playerid, GetPlayerDrunkLevel(playerid) + 1000);
	}
	#if defined bot_OnPlayerEaten
		return bot_OnPlayerEaten(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerEaten
	#undef OnPlayerEaten
#else
	#define _ALS_OnPlayerEaten
#endif
#define OnPlayerEaten bot_OnPlayerEaten
#if defined bot_OnPlayerEaten
	forward bot_OnPlayerEaten(playerid, itemid);
#endif
