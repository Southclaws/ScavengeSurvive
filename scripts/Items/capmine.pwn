#define MAX_CAPMINES


new
	ItemType:item_CapMine = INVALID_ITEM_TYPE,
	ItemType:item_CapMineBad = INVALID_ITEM_TYPE;


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_CapMine || GetItemType(itemid) == item_CapMineBad)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
		Msg(playerid, YELLOW, " >  Mine primed");
		return 1;
	}
	return CallLocalFunction("cap_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem cap_OnPlayerUseItem
forward cap_OnPlayerUseItem(playerid, itemid);

public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_CapMineBad)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			if(random(100) < 50)
			{
				new
					Float:x,
					Float:y,
					Float:z;

				GetItemPos(itemid, x, y, z);
				CreateExplosion(x, y, z, 11, 8.0);

				DestroyItem(itemid);

				return 1;
			}
		}
	}
	if(GetItemType(itemid) == item_CapMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(itemid, x, y, z);
			CreateExplosion(x, y, z, 11, 8.0);

			DestroyItem(itemid);

			return 1;
		}
	}
	return CallLocalFunction("cap_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem cap_OnPlayerPickUpItem
forward cap_OnPlayerPickUpItem(playerid, itemid);
