public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_GasCan && GetItemType(withitemid) == ItemType:18)
	{
		if(GetItemExtraData(itemid) > 0)
		{
			if(GetItemExtraData(withitemid) == 0)
			{
				SetItemExtraData(itemid, GetItemExtraData(itemid) - 1);
				SetItemExtraData(withitemid, 1);
			}
		}
	}
	return CallLocalFunction("bot_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem bot_OnPlayerUseItemWithItem
forward bot_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
