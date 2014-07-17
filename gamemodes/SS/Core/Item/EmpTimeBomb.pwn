public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_EmpTimebomb)
	{
		PlayerDropItem(playerid);
		defer EmpTimeBombExplode(itemid);
		return 1;
	}
    #if defined emptbm_OnPlayerUseItem
		return emptbm_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem emptbm_OnPlayerUseItem
#if defined emptbm_OnPlayerUseItem
	forward emptbm_OnPlayerUseItem(playerid, itemid);
#endif


timer EmpTimeBombExplode[5000](itemid)
{
	SetItemToExplode(itemid, 0, 12.0, EXPLOSION_PRESET_EMP, 0);
}
