public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_IedTimebomb)
	{
		PlayerDropItem(playerid);
		defer IedTimeBombExplode(itemid);
		return 1;
	}
    return CallLocalFunction("iedtbm_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem iedtbm_OnPlayerUseItem
forward iedtbm_OnPlayerUseItem(playerid, itemid);


timer IedTimeBombExplode[5000](itemid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	DestroyItem(itemid);
	CreateStructuralExplosion(x, y, z, 11, 8.0, 1);
}
