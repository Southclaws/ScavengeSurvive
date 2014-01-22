public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntTimebomb)
	{
		PlayerDropItem(playerid);
		defer TimeBombExplode(itemid);
		logf("[EXPLOSIVE] TNT TIMEBOMB placed by %p", playerid);
		return 1;
	}
    #if defined tntt_OnPlayerUseItem
        return tntt_OnPlayerUseItem(playerid, itemid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem tntt_OnPlayerUseItem
#if defined tntt_OnPlayerUseItem
    forward tntt_OnPlayerUseItem(playerid, itemid);
#endif


timer TimeBombExplode[5000](itemid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);

	logf("[EXPLOSIVE] TNT TIMEBOMB detonated at %f, %f, %f", x, y, z);

	SetItemToExplode(itemid, 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);
}
