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


public OnItemCreate(itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_Bottle || GetItemType(itemid) == item_CanDrink)
		{
			SetFoodItemSubType(itemid, GetTotalLiquidTypes());
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

		if(IsValidLiquidType(subtype))
		{
			new name[MAX_LIQUID_NAME];
			GetLiquidName(subtype, name);
			SetItemNameExtra(itemid, sprintf("%s, %d/%d", name, amount, GetFoodTypeMaxBites(foodtype)));
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

public OnPlayerCrafted(playerid, craftset, result)
{
	if(GetItemType(result) == item_Bottle)
	{
		new
			itemid1,
			itemid2,
			amount;

		itemid1 = GetPlayerSelectedCraftItemID(playerid, 0);
		itemid2 = GetPlayerSelectedCraftItemID(playerid, 1);
		amount = GetFoodItemAmount(itemid1) + GetFoodItemAmount(itemid2);

		printf("1: %b, 2: %b combined: %b", GetFoodItemSubType(itemid1), GetFoodItemSubType(itemid2), GetFoodItemSubType(itemid1) | GetFoodItemSubType(itemid2));

		SetFoodItemSubType(itemid1, GetFoodItemSubType(itemid1) | GetFoodItemSubType(itemid2));
		SetFoodItemAmount(itemid1, (amount > 10) ? 10 : amount);

		SetFoodItemAmount(itemid2, 0);
		SetFoodItemSubType(itemid2, -1);
	}

	#if defined liq_OnPlayerCrafted
		return liq_OnPlayerCrafted(playerid, craftset, result);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerCrafted
	#undef OnPlayerCrafted
#else
	#define _ALS_OnPlayerCrafted
#endif

#define OnPlayerCrafted liq_OnPlayerCrafted
#if defined liq_OnPlayerCrafted
	forward liq_OnPlayerCrafted(playerid, craftset, result);
#endif
