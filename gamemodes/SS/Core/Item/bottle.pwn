#define BOTTLE_DATA_TYPE(%0)		((%0 >> 8) & 0xFF)
#define BOTTLE_DATA_AMOUNT(%0)		(%0 & 0xFF)
#define BOTTLE_DATA_COMBINE(%0,%1)	(%0 << 8 | %1)

enum
{
	BOTTLE_CONTENTS_WATER,		// 0
	BOTTLE_CONTENTS_BEER		// 1
}



public OnItemCreate(itemid)
{
	if(IsItemLoot(itemid))
	{
		if(GetItemType(itemid) == item_Bottle)
		{
			// First 8 bits represent the type last 8 bits represent the amount
			new
				type = random(2),
				amount = random(10);

			SetItemExtraData(itemid, BOTTLE_DATA_COMBINE(type, amount));
		}
	}

	#if defined bot_OnItemCreate
		return bot_OnItemCreate(itemid);
	#else
		return 1;
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


public OnItemNameRender(itemid)
{
	if(GetItemType(itemid) == item_Bottle)
	{
		new
			data,
			type,
			amount;

		data = GetItemExtraData(itemid);
		type = BOTTLE_DATA_TYPE(data);
		amount = BOTTLE_DATA_AMOUNT(data);

		if(amount > 0)
		{
			new str[12];

			switch(type)
			{
				case BOTTLE_CONTENTS_WATER:
					format(str, sizeof(str), "Water %d", amount);

				case BOTTLE_CONTENTS_BEER:
					format(str, sizeof(str), "Beer %d", amount);

				default:
					format(str, sizeof(str), "Unknown %d", amount);
			}

			SetItemNameExtra(itemid, str);
		}
		else
		{
			SetItemNameExtra(itemid, "Empty");
		}
	}

	return CallLocalFunction("bot_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender bot_OnItemNameRender
forward bot_OnItemNameRender(itemid);

public OnPlayerEaten(playerid, itemid)
{
	if(GetItemType(itemid) == item_Bottle)
	{
		new
			data,
			type,
			amount;

		data = GetItemExtraData(itemid);
		type = BOTTLE_DATA_TYPE(data);
		amount = BOTTLE_DATA_AMOUNT(data);

		if(amount > 0)
		{
			SetItemExtraData(itemid, BOTTLE_DATA_COMBINE(type, amount - 1));

			if(type == BOTTLE_CONTENTS_BEER)
				SetPlayerDrunkLevel(playerid, GetPlayerDrunkLevel(playerid) + 500);
		}
		else
		{
			ShowActionText(playerid, "Empty", 2000, 70);
			return 1;
		}
	}
	return CallLocalFunction("bot_OnPlayerEaten", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerEaten
	#undef OnPlayerEaten
#else
	#define _ALS_OnPlayerEaten
#endif
#define OnPlayerEaten bot_OnPlayerEaten
forward bot_OnPlayerEaten(playerid, itemid);
