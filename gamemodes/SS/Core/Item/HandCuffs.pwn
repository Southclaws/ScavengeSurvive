#include <YSI\y_hooks>


new
	cuf_TargetPlayer[MAX_PLAYERS],
	cuf_BeingCuffedBy[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	cuf_TargetPlayer[playerid] = INVALID_PLAYER_ID;
	cuf_BeingCuffedBy[playerid] = INVALID_PLAYER_ID;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16)
	{
		new itemid = GetPlayerItem(playerid);
		if(GetItemType(itemid) == item_HandCuffs)
		{
			foreach(new i : Character)
			{
				if(i == playerid)
					continue;

				if(IsPlayerInPlayerArea(playerid, i))
				{
					if(GetPlayerItem(i) == INVALID_ITEM_ID && GetPlayerWeapon(i) == 0 && cuf_BeingCuffedBy[i] == INVALID_PLAYER_ID)
					{
						ApplyAnimation(playerid, "CASINO", "DEALONE", 4.0, 1, 0, 0, 0, 0);
						StartHoldAction(playerid, 3000);

						cuf_TargetPlayer[playerid] = i;
						cuf_BeingCuffedBy[i] = playerid;

						return 1;
					}
				}
			}
		}
		else
		{
			foreach(new i : Character)
			{
				if(i == playerid)
					continue;

				if(IsPlayerInPlayerArea(playerid, i))
				{
					if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_CUFFED)
					{
						if(GetPlayerItem(playerid) == INVALID_ITEM_ID && GetPlayerWeapon(playerid) == 0 && cuf_BeingCuffedBy[playerid] == INVALID_PLAYER_ID)
						{
							cuf_TargetPlayer[playerid] = i;
							cuf_BeingCuffedBy[i] = playerid;

							ApplyAnimation(playerid, "CASINO", "DEALONE", 4.0, 1, 0, 0, 0, 0);
							StartHoldAction(playerid, 3000);

							return 1;
						}
					}
				}
			}
		}
	}
	if(oldkeys & 16)
	{
		StopApplyingHandcuffs(playerid);
	}
	return 1;
}

StopApplyingHandcuffs(playerid)
{
	if(cuf_TargetPlayer[playerid] != INVALID_PLAYER_ID)
	{
		StopHoldAction(playerid);
		ClearAnimations(playerid);

		cuf_BeingCuffedBy[cuf_TargetPlayer[playerid]] = INVALID_PLAYER_ID;
		cuf_TargetPlayer[playerid] = INVALID_PLAYER_ID;
	}
}

public OnHoldActionUpdate(playerid, progress)
{
	if(cuf_TargetPlayer[playerid] != INVALID_PLAYER_ID)
	{
		if(!IsPlayerInPlayerArea(playerid, cuf_TargetPlayer[playerid]))
		{
			StopApplyingHandcuffs(playerid);
			return 1;
		}

		if(GetPlayerWeapon(cuf_TargetPlayer[playerid]) != 0)
		{
			StopApplyingHandcuffs(playerid);
			return 1;
		}

		if(GetPlayerItem(cuf_TargetPlayer[playerid]) != INVALID_ITEM_ID)
		{
			StopApplyingHandcuffs(playerid);
			return 1;
		}
	}

	return CallLocalFunction("cuf_OnHoldActionUpdate", "dd", playerid, progress);
}
#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate cuf_OnHoldActionUpdate
forward cuf_OnHoldActionUpdate(playerid, progress);

public OnHoldActionFinish(playerid)
{
	if(cuf_TargetPlayer[playerid] != INVALID_PLAYER_ID)
	{
		if(!IsPlayerInPlayerArea(playerid, cuf_TargetPlayer[playerid]))
		{
			StopApplyingHandcuffs(playerid);
			return 1;
		}

		if(IsPlayerCuffed(cuf_TargetPlayer[playerid]))
		{
			new itemid = CreateItem(item_HandCuffs);
			SetPlayerCuffs(cuf_TargetPlayer[playerid], false);
			GiveWorldItemToPlayer(playerid, itemid, 0);
		}
		else
		{
			DestroyItem(GetPlayerItem(playerid));
			SetPlayerCuffs(cuf_TargetPlayer[playerid], true);
			StopApplyingHandcuffs(playerid);
		}

		return 1;
	}

	return CallLocalFunction("cuf_OnHoldActionFinish", "d", playerid);
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish cuf_OnHoldActionFinish
forward cuf_OnHoldActionFinish(playerid);
