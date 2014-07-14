public OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, knockmult)
{
	new itemid = GetPlayerItem(playerid);

	if(GetItemType(itemid) == item_StunGun)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerPos(targetid, x, y, z);

			KnockOutPlayer(targetid, 60000);
			SetItemExtraData(itemid, 0);
			CreateTimedDynamicObject(18724, x, y, z-1.0, 0.0, 0.0, 0.0, 1000);

			return 1;
		}
		else
		{
			ShowActionText(playerid, "Out of charge", 3000);
			return 1;
		}
	}

	#if defined stun_OnPlayerMeleePlayer
		return stun_OnPlayerMeleePlayer(playerid, targetid, bleedrate, knockmult);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerMeleePlayer
	#undef OnPlayerMeleePlayer
#else
	#define _ALS_OnPlayerMeleePlayer
#endif
 
#define OnPlayerMeleePlayer stun_OnPlayerMeleePlayer
#if defined stun_OnPlayerMeleePlayer
	forward stun_OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, knockmult);
#endif

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_StunGun && GetItemType(withitemid))
	{
		SetItemExtraData(itemid, 1);
		DestroyItem(withitemid);
		ShowActionText(playerid, "Stun Gun Charged", 3000);
	}

	#if defined stun_OnPlayerUseItemWithItem
		return stun_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif

#define OnPlayerUseItemWithItem stun_OnPlayerUseItemWithItem
#if defined stun_OnPlayerUseItemWithItem
	forward stun_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif
