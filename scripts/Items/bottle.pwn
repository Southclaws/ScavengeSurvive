#define BOTTLE_CONTENTS_WATER		(0)
#define BOTTLE_CONTENTS_BEER		(1)

#define BOTTLE_DATA_CONTENTS(%0)	((%0 >> 8) & 0xFFFF)
#define BOTTLE_DATA_AMOUNT(%0)		(%0 & 0xFFFF)


public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_Bottle)
	{
		// First 8 bits represent the type last 8 bits represent the amount
		new
			a = random(2),
			b = random(10);

		SetItemExtraData(itemid, a << 8 | b);
	}

	return CallLocalFunction("bot_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate bot_OnItemCreate
forward bot_OnItemCreate(itemid);


public OnItemNameRender(itemid)
{
	if(GetItemType(itemid) == item_Bottle)
	{
		new data = GetItemExtraData(itemid);

		if(data & 0xFFFF > 0)
		{
			new str[12];

			switch((data >> 8) & 0xFFFF)
			{
				case BOTTLE_CONTENTS_WATER:
					format(str, sizeof(str), "Water %d", data & 0xFFFF);

				case BOTTLE_CONTENTS_BEER:
					format(str, sizeof(str), "Beer %d", data & 0xFFFF);

				default:
					format(str, sizeof(str), "Unknown %d", data & 0xFFFF);
			}
			SetItemNameExtra(itemid, str);
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


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Bottle)
	{
		new data = GetItemExtraData(itemid);

		if(data & 0xFFFF > 0)
		{
			ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 0, 1);
			SetPlayerDrunkLevel(playerid, GetPlayerDrunkLevel(playerid) + 400);
			SetItemExtraData(itemid, ((data >> 8) & 0xFFFF) << 8 | ((data & 0xFFFF) - 1));
		}
		else
		{
			ShowActionText(playerid, "Empty", 2000, 70);
		}
	}
	return CallLocalFunction("bot_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem bot_OnPlayerUseItem
forward bot_OnPlayerUseItem(playerid, itemid);

