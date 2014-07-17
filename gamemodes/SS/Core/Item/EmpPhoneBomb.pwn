new empp_SyncTick[MAX_PLAYERS];

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_MobilePhone && GetItemType(withitemid) == item_EmpPhoneBomb)
	{
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
		SetItemExtraData(itemid, withitemid);
		SetItemExtraData(withitemid, 1);
		empp_SyncTick[playerid] = GetTickCount();
		Msg(playerid, YELLOW, " >  Cell phones synced, use phone to detonate.");
	}
	#if defined empp_OnPlayerUseItemWithItem
		return empp_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem empp_OnPlayerUseItemWithItem
#if defined empp_OnPlayerUseItemWithItem
	forward empp_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_MobilePhone)
	{
		new bombitem = GetItemExtraData(itemid);

		if(IsValidItem(bombitem) && GetItemType(bombitem) == item_EmpPhoneBomb && GetItemExtraData(bombitem) == 1)
		{
			if(GetTickCountDifference(GetTickCount(), empp_SyncTick[playerid]) > 1000)
			{
				SetItemToExplode(bombitem, 0, 12.0, EXPLOSION_PRESET_EMP, 0);
				SetItemExtraData(itemid, INVALID_ITEM_ID);
			}
		}
	}
	#if defined empp_OnPlayerUseItem
		return empp_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem empp_OnPlayerUseItem
#if defined empp_OnPlayerUseItem
	forward empp_OnPlayerUseItem(playerid, itemid);
#endif
