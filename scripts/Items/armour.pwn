public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_Armour)
	{
		SetItemExtraData(itemid, random(100) + 1);
	}

	return CallLocalFunction("armour_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate armour_OnItemCreate
forward armour_OnItemCreate(itemid);


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Armour)
	{
		new data = GetItemExtraData(itemid);
		if(data > 0)
		{
			DestroyItem(itemid);
			gPlayerAP[playerid] = Float:data;
		}
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

