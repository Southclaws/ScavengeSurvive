#define PILL_TYPE_ANTIBIOTICS	(0)
#define PILL_TYPE_PAINKILL		(1)
#define PILL_TYPE_LSD			(2)


public OnItemCreate(itemid)
{
	if(IsItemLoot(itemid))
	{
		if(GetItemType(itemid) == item_Pills)
		{
			SetItemExtraData(itemid, random(3));
		}
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
		switch(GetItemExtraData(itemid))
		{
			case PILL_TYPE_ANTIBIOTICS:			SetItemNameExtra(itemid, "Antibiotics");
			case PILL_TYPE_PAINKILL:		SetItemNameExtra(itemid, "Painkiller");
			case PILL_TYPE_LSD:				SetItemNameExtra(itemid, "LSD");
			default:						SetItemNameExtra(itemid, "Empty");
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
	switch(GetItemExtraData(itemid))
	{
		case PILL_TYPE_ANTIBIOTICS:
		{
			f:gPlayerBitData[playerid]<Infected>;
		}
		case PILL_TYPE_PAINKILL:
		{
			GivePlayerHP(playerid, 10.0);
			ApplyDrug(playerid, DRUG_TYPE_PAINKILL);
		}
		case PILL_TYPE_LSD:
		{
			ApplyDrug(playerid, DRUG_TYPE_LSD);
		}
	}
	DestroyItem(itemid);
}
