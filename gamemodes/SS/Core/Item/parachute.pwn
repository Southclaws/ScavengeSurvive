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
			if(!IsValidItem(GetPlayerBagItem(playerid)))
			{
				_EquipParachute(playerid);
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
				RemovePlayerWeapon(playerid);
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

	#if defined para_OnPlayerDropItem
		return para_OnPlayerDropItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem para_OnPlayerDropItem
#if defined para_OnPlayerDropItem
	forward para_OnPlayerDropItem(playerid, itemid);
#endif


_EquipParachute(playerid)
{
	Msg(playerid, YELLOW, " >  Not implemented.");
}
