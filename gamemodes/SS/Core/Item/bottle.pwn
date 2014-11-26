enum
{
	E_BOTTLE_AMOUNT,
	E_BOTTLE_TYPE
}


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
		if(GetItemType(itemid) == item_Bottle)
		{
			SetItemArrayDataAtCell(itemid, random(10), E_BOTTLE_AMOUNT);
			SetItemArrayDataAtCell(itemid, random(2), E_BOTTLE_TYPE);
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
	if(itemtype == item_Bottle)
	{
		new
			amount,
			type;

		amount = GetItemArrayDataAtCell(itemid, E_BOTTLE_AMOUNT);
		type = GetItemArrayDataAtCell(itemid, E_BOTTLE_TYPE);

		if(amount > 0)
		{
			SetItemNameExtra(itemid, drink_Types[type]);
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
	if(GetItemType(itemid) == item_Bottle)
	{
		new
			type,
			amount;

		type = GetItemArrayDataAtCell(itemid, E_BOTTLE_AMOUNT);
		amount = GetItemArrayDataAtCell(itemid, E_BOTTLE_TYPE);

		if(amount > 0)
		{
			SetItemArrayDataAtCell(itemid, amount - 1, E_BOTTLE_AMOUNT);

			if(type == 1)
				SetPlayerDrunkLevel(playerid, GetPlayerDrunkLevel(playerid) + 500);
		}
		else
		{
			ShowActionText(playerid, "Empty", 2000, 70);
			return 1;
		}
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
