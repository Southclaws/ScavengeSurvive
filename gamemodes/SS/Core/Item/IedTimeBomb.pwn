public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_IedTimebomb)
	{
		PlayerDropItem(playerid);
		defer IedTimeBombExplode(itemid);
		logf("[EXPLOSIVE] IED TIMEBOMB placed by %p", playerid);
		return 1;
	}
    #if defined iedt_OnPlayerUseItem
		return iedt_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem iedt_OnPlayerUseItem
#if defined iedt_OnPlayerUseItem
	forward iedt_OnPlayerUseItem(playerid, itemid);
#endif


timer IedTimeBombExplode[5000](itemid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);

	logf("[EXPLOSIVE] IED TIMEBOMB detonated at %f, %f, %f", x, y, z);

	SetItemToExplode(itemid, 11, 8.0, EXPLOSION_PRESET_STRUCTURAL, 1);
}
