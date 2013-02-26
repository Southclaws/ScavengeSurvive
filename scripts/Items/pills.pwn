#define PILL_TYPE_ASPIRIN	(0)
#define PILL_TYPE_PAINKILL	(1)
#define PILL_TYPE_ECSTASY	(2)


new
	ItemType:item_Pills = INVALID_ITEM_TYPE;


public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_Pills)
	{
		// First 3 bits represent the type (0, 1 or 2) 4th bit determines whether it's labeled or not
		SetItemExtraData(itemid, random(3) | (random(2) << 3));
	}

	return CallLocalFunction("pil_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate pil_OnItemCreate
forward pil_OnItemCreate(itemid);

public OnItemNameRender(itemid)
{
	if(GetItemType(itemid) == item_Pills)
	{
		new data = GetItemExtraData(itemid);

		if(data & 0b1000)
		{
			switch(data & 0b111)
			{
				case PILL_TYPE_ASPIRIN:		SetItemNameExtra(itemid, "Aspirin");
				case PILL_TYPE_PAINKILL:	SetItemNameExtra(itemid, "Painkiller");
				case PILL_TYPE_ECSTASY:		SetItemNameExtra(itemid, "Ecstasy");
			}
		}
		else
		{
			SetItemNameExtra(itemid, "Unlabeled");
		}
	}

	return CallLocalFunction("pil_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender pil_OnItemNameRender
forward pil_OnItemNameRender(itemid);

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Pills)
	{
		ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 500, 1);
		defer TakePills(playerid, itemid);
	}

	return CallLocalFunction("pil_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem pil_OnPlayerUseItem
forward pil_OnPlayerUseItem(playerid, itemid);

timer TakePills[500](playerid, itemid)
{
	switch(GetItemExtraData(itemid) & 0b111)
	{
		case PILL_TYPE_ASPIRIN:
		{
			gPlayerPillUseTick[playerid][0] = tickcount();
			t:bPlayerGameSettings[playerid]<PillEffect_Aspirin>;
		}
		case PILL_TYPE_PAINKILL:
		{
			gPlayerPillUseTick[playerid][1] = tickcount();
			t:bPlayerGameSettings[playerid]<PillEffect_Painkill>;
		}
		case PILL_TYPE_ECSTASY:
		{
			gPlayerPillUseTick[playerid][2] = tickcount();
			t:bPlayerGameSettings[playerid]<PillEffect_Ecstasy>;
		}
	}
	DestroyItem(itemid);
}
