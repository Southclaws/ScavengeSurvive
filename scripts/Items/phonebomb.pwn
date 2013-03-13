new
	ItemType:item_PhoneBomb = INVALID_ITEM_TYPE;


public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_MobilePhone)
	{
		SetItemExtraData(itemid, INVALID_ITEM_ID);
	}

	return CallLocalFunction("pbm_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate pbm_OnItemCreate
forward pbm_OnItemCreate(itemid);

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_MobilePhone && GetItemType(withitemid) == item_PhoneBomb)
	{
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
		SetItemExtraData(itemid, withitemid);
		Msg(playerid, YELLOW, " >  Cell phones synced, use phone to detonate.");
	}
	return CallLocalFunction("pbm_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem pbm_OnPlayerUseItemWithItem
forward pbm_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_MobilePhone)
	{
		new bombitem = GetItemExtraData(itemid);

		if(IsValidItem(bombitem) && GetItemType(bombitem) == item_PhoneBomb)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(bombitem, x, y, z);
			CreateStructuralExplosion(x, y, z, 7, 15.0);
			DestroyItem(bombitem);
			SetItemExtraData(itemid, INVALID_ITEM_ID);
		}
	}
	return CallLocalFunction("pbm_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem pbm_OnPlayerUseItem
forward pbm_OnPlayerUseItem(playerid, itemid);
