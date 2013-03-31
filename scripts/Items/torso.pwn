public OnPlayerUseItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Torso)
	{
		if(GetPlayerWeapon(playerid) == 4)
		{
			print("Used knife with torso");
		}
	}
	return CallLocalFunction("tor_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem tor_OnPlayerUseItem
forward tor_OnPlayerUseItem(playerid, itemid);
