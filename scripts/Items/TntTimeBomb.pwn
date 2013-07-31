public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntTimebomb)
	{
		PlayerDropItem(playerid);
		defer TimeBombExplode(itemid);
		return 1;
	}
    return CallLocalFunction("tntt_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem tntt_OnPlayerUseItem
forward tntt_OnPlayerUseItem(playerid, itemid);


timer TimeBombExplode[5000](itemid)
{
	SetItemToExplode(itemid, 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);
}
