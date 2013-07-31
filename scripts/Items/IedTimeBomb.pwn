public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_IedTimebomb)
	{
		PlayerDropItem(playerid);
		defer IedTimeBombExplode(itemid);
		return 1;
	}
    return CallLocalFunction("iedt_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem iedt_OnPlayerUseItem
forward iedt_OnPlayerUseItem(playerid, itemid);


timer IedTimeBombExplode[5000](itemid)
{
	SetItemToExplode(itemid, 11, 8.0, EXPLOSION_PRESET_STRUCTURAL, 1);
}
