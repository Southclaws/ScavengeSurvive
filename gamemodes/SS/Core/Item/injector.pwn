#define INJECT_TYPE_EMPTY		(0)
#define INJECT_TYPE_MORPHINE	(1)
#define INJECT_TYPE_ADRENALINE	(2)
#define INJECT_TYPE_HEROINE		(3)


public OnItemCreate(itemid)
{
	if(IsItemLoot(itemid))
	{
		if(GetItemType(itemid) == item_AutoInjec)
		{
			SetItemExtraData(itemid, 1 + random(3));
		}
	}

	return CallLocalFunction("inj_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate inj_OnItemCreate
forward inj_OnItemCreate(itemid);

public OnItemNameRender(itemid)
{
	if(GetItemType(itemid) == item_AutoInjec)
	{
		switch(GetItemExtraData(itemid))
		{
			case INJECT_TYPE_EMPTY:			SetItemNameExtra(itemid, "Empty");
			case INJECT_TYPE_MORPHINE:		SetItemNameExtra(itemid, "Morphine");
			case INJECT_TYPE_ADRENALINE:	SetItemNameExtra(itemid, "Adrenaline");
			case INJECT_TYPE_HEROINE:		SetItemNameExtra(itemid, "Heroine");
			default:						SetItemNameExtra(itemid, "Empty");
		}
	}

	return CallLocalFunction("inj_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender inj_OnItemNameRender
forward inj_OnItemNameRender(itemid);

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_AutoInjec)
	{
		foreach(new i : Player)
		{
			if(IsPlayerInPlayerArea(playerid, i))
			{
				InjectPlayer(playerid, i, itemid);
				return 1;
			}
		}

		ApplyAnimation(playerid, "PED", "IDLE_CSAW", 4.0, 0, 1, 1, 0, 500, 1);
		defer Inject(playerid, playerid, itemid);
	}

	return CallLocalFunction("inj_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem inj_OnPlayerUseItem
forward inj_OnPlayerUseItem(playerid, itemid);

InjectPlayer(playerid, targetid, itemid)
{
	if(IsPlayerKnockedOut(targetid))
	{
		ApplyAnimation(playerid, "KNIFE", "KNIFE_G", 2.0, 0, 0, 0, 0, 0);
		defer Inject(playerid, targetid, itemid, 0);
	}
	else
	{
		ApplyAnimation(playerid, "ROCKET", "IDLE_ROCKET", 4.0, 0, 1, 1, 0, 500, 1);
		defer Inject(playerid, targetid, itemid, 1);
	}
}

timer Inject[500](playerid, targetid, itemid, anim)
{
	if(anim)
		ApplyAnimation(playerid, "PED", "IDLE_ARMED", 4.0, 0, 1, 1, 0, 500, 1);

	switch(GetItemExtraData(itemid))
	{
		case INJECT_TYPE_EMPTY:
		{
			ApplyDrug(targetid, DRUG_TYPE_AIR);
		}

		case INJECT_TYPE_MORPHINE:
		{
			ApplyDrug(targetid, DRUG_TYPE_MORPHINE);
		}

		case INJECT_TYPE_ADRENALINE:
		{
			ApplyDrug(targetid, DRUG_TYPE_ADRENALINE);

			if(IsPlayerKnockedOut(targetid))
				WakeUpPlayer(targetid);
		}

		case INJECT_TYPE_HEROINE:
		{
			ApplyDrug(targetid, DRUG_TYPE_HEROINE);
		}
	}

	SetItemExtraData(itemid, INJECT_TYPE_EMPTY);
}
