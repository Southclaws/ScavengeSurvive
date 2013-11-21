new tntp_SyncTick[MAX_PLAYERS];

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_MobilePhone && GetItemType(withitemid) == item_TntPhoneBomb)
	{
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
		SetItemExtraData(itemid, withitemid);
		SetItemExtraData(withitemid, 1);
		tntp_SyncTick[playerid] = GetTickCount();
		Msg(playerid, YELLOW, " >  Cell phones synced, use phone to detonate.");
	}
	return CallLocalFunction("tntp_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem tntp_OnPlayerUseItemWithItem
forward tntp_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_MobilePhone)
	{
		new bombitem = GetItemExtraData(itemid);

		if(IsValidItem(bombitem) && GetItemType(bombitem) == item_TntPhoneBomb && GetItemExtraData(bombitem) == 1)
		{
			if(GetTickCountDifference(GetTickCount(), tntp_SyncTick[playerid]) > 1000)
			{
				new
					Float:x,
					Float:y,
					Float:z;

				GetItemPos(bombitem, x, y, z);

				logf("[EXPLOSIVE] TNT PHONEBOMB detonated by %p at %f, %f, %f", playerid, x, y, z);

				SetItemToExplode(bombitem, 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);
				SetItemExtraData(itemid, INVALID_ITEM_ID);
			}
		}
	}
	return CallLocalFunction("tntp_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem tntp_OnPlayerUseItem
forward tntp_OnPlayerUseItem(playerid, itemid);

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_MobilePhone)
	{
		SetItemExtraData(itemid, INVALID_ITEM_ID);
	}

	return CallLocalFunction("tntp_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate tntp_OnItemCreate
forward tntp_OnItemCreate(itemid);
