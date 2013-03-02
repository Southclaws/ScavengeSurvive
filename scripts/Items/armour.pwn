new ItemType:item_Armour = INVALID_ITEM_TYPE;


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Armour)
	{
		DestroyItem(itemid);
		gPlayerAP[playerid] = 100.0;
	}
    return CallLocalFunction("armour_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem armour_OnPlayerUseItem
forward armour_OnPlayerUseItem(playerid, itemid);

