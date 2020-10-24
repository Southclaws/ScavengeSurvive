/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


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
	if(IsBadInteract(playerid))
		return 1;

	if(newkeys & 16)
	{
		new Item:itemid = GetPlayerItem(playerid);

		if(GetItemType(itemid) == item_HandCuffs)
		{
			foreach(new i : Character)
			{
				if(i == playerid)
					continue;

				if(IsPlayerNextToPlayer(playerid, i))
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

				if(IsPlayerNextToPlayer(playerid, i))
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

hook OnHoldActionUpdate(playerid, progress)
{
	if(cuf_TargetPlayer[playerid] != INVALID_PLAYER_ID)
	{
		if(!CanPlayerHandcuffPlayer(playerid, cuf_TargetPlayer[playerid]))
		{
			StopApplyingHandcuffs(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(cuf_TargetPlayer[playerid] != INVALID_PLAYER_ID)
	{
		if(!CanPlayerHandcuffPlayer(playerid, cuf_TargetPlayer[playerid]))
		{
			StopApplyingHandcuffs(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(IsPlayerCuffed(cuf_TargetPlayer[playerid]))
		{
			new Item:itemid = CreateItem(item_HandCuffs);

			SetPlayerCuffs(cuf_TargetPlayer[playerid], false);
			GiveWorldItemToPlayer(playerid, itemid, 0);
		}
		else
		{
			DestroyItem(GetPlayerItem(playerid));

			SetPlayerCuffs(cuf_TargetPlayer[playerid], true);
			StopApplyingHandcuffs(playerid);
		}

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

CanPlayerHandcuffPlayer(playerid, targetid)
{
	if(!IsPlayerNextToPlayer(playerid, targetid))
		return 0;

	if(GetPlayerWeapon(targetid) != 0)
		return 0;

	if(IsValidItem(GetPlayerItem(targetid)))
		return 0;

	return 1;
}
