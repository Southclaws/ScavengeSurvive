/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


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
	if(IsBadInteract(playerid))
		return 1;

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
		if(!CanPlayerHandcuffPlayer(playerid, cuf_TargetPlayer[playerid]))
		{
			StopApplyingHandcuffs(playerid);
			return 1;
		}
	}

	#if defined cuf_OnHoldActionUpdate
		return cuf_OnHoldActionUpdate(playerid, progress);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate cuf_OnHoldActionUpdate
#if defined cuf_OnHoldActionUpdate
	forward cuf_OnHoldActionUpdate(playerid, progress);
#endif

public OnHoldActionFinish(playerid)
{
	if(cuf_TargetPlayer[playerid] != INVALID_PLAYER_ID)
	{
		if(!CanPlayerHandcuffPlayer(playerid, cuf_TargetPlayer[playerid]))
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

	#if defined cuf_OnHoldActionFinish
		return cuf_OnHoldActionFinish(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish cuf_OnHoldActionFinish
#if defined cuf_OnHoldActionFinish
	forward cuf_OnHoldActionFinish(playerid);
#endif

CanPlayerHandcuffPlayer(playerid, targetid)
{
	if(!IsPlayerInPlayerArea(playerid, targetid))
		return 0;

	if(GetPlayerWeapon(targetid) != 0)
		return 0;

	if(IsValidItem(GetPlayerItem(targetid)))
		return 0;

	return 1;
}
