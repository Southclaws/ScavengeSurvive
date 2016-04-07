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


hook OnItemCreate(itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_Bottle || GetItemType(itemid) == item_CanDrink)
		{
			SetFoodItemSubType(itemid, GetTotalLiquidTypes());
		}
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype)
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
}

hook OnPlayerEaten(playerid, itemid)
{
	if(GetItemType(itemid) == item_Bottle || GetItemType(itemid) == item_CanDrink)
	{
		new type = GetFoodItemSubType(itemid);

		if(type == 1)
			SetPlayerDrunkLevel(playerid, GetPlayerDrunkLevel(playerid) + 1000);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCrafted(playerid, craftset, result)
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

	return Y_HOOKS_CONTINUE_RETURN_0;
}
