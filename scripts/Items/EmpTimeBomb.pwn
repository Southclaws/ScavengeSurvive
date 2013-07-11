public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_EmpTimebomb)
	{
		PlayerDropItem(playerid);
		defer EmpTimeBombExplode(itemid);
		return 1;
	}
    return CallLocalFunction("emptbm_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem emptbm_OnPlayerUseItem
forward emptbm_OnPlayerUseItem(playerid, itemid);


timer EmpTimeBombExplode[5000](itemid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	DestroyItem(itemid);
	CreateEmpExplosion(x, y, z, 12.0);
}
