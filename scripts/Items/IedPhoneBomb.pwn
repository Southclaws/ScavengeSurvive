public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_MobilePhone && GetItemType(withitemid) == item_IedPhoneBomb)
	{
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
		SetItemExtraData(itemid, withitemid);
		SetItemExtraData(withitemid, 1);
		Msg(playerid, YELLOW, " >  Cell phones synced, use phone to detonate.");
	}
	return CallLocalFunction("iedp_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem iedp_OnPlayerUseItemWithItem
forward iedp_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_MobilePhone)
	{
		new bombitem = GetItemExtraData(itemid);

		if(IsValidItem(bombitem) && GetItemType(bombitem) == item_IedPhoneBomb && GetItemExtraData(bombitem) == 1)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(bombitem, x, y, z);
			CreateStructuralExplosion(x, y, z, 11, 8.0);
			DestroyItem(bombitem);
			SetItemExtraData(itemid, INVALID_ITEM_ID);
		}
	}
	return CallLocalFunction("iedp_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem iedp_OnPlayerUseItem
forward iedp_OnPlayerUseItem(playerid, itemid);
