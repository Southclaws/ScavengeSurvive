#include <YSI\y_hooks>


new
	bool:para_TakingOff[MAX_PLAYERS];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_YES)
	{
		new itemid = GetPlayerItem(playerid);
		if(GetItemType(itemid) == item_Parachute)
		{
			if(!IsValidItem(GetPlayerBackpackItem(playerid)))
			{
				gPlayerArmedWeapon[playerid] = 46;
				GivePlayerWeapon(playerid, 46, 1);
				DestroyItem(GetPlayerItem(playerid));
			}
		}
	}
	if(newkeys & KEY_NO)
	{
		if(GetPlayerWeapon(playerid) == 46)
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				para_TakingOff[playerid] = true;
				ResetPlayerWeapons(playerid);
				GiveWorldItemToPlayer(playerid, CreateItem(item_Parachute, 0.0, 0.0, 0.0));
			}
		}
	}
}

public OnPlayerDropItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Parachute)
	{
		if(para_TakingOff[playerid])
		{
			para_TakingOff[playerid] = false;
			return 1;
		}
	}

	return CallLocalFunction("para_OnPlayerDropItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem para_OnPlayerDropItem
forward para_OnPlayerDropItem(playerid, itemid);
