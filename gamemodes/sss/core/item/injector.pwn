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


#include <YSI_4\y_hooks>


#define INJECT_TYPE_EMPTY		(0)
#define INJECT_TYPE_MORPHINE	(1)
#define INJECT_TYPE_ADRENALINE	(2)
#define INJECT_TYPE_HEROIN		(3)


static
	inj_CurrentItem[MAX_PLAYERS],
	inj_CurrentTarget[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	inj_CurrentItem[playerid] = -1;
	inj_CurrentTarget[playerid] = -1;
}

hook OnItemCreate(itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_AutoInjec)
		{
			SetItemExtraData(itemid, 1 + random(3));
		}
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{
	if(itemtype == item_AutoInjec)
	{
		switch(GetItemExtraData(itemid))
		{
			case INJECT_TYPE_EMPTY:			SetItemNameExtra(itemid, "Empty");
			case INJECT_TYPE_MORPHINE:		SetItemNameExtra(itemid, "Morphine");
			case INJECT_TYPE_ADRENALINE:	SetItemNameExtra(itemid, "Adrenaline");
			case INJECT_TYPE_HEROIN:		SetItemNameExtra(itemid, "Heroin");
			default:						SetItemNameExtra(itemid, "Empty");
		}
	}
}

hook OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_AutoInjec)
	{
		new targetid = playerid;

		foreach(new i : Player)
		{
			if(IsPlayerInPlayerArea(playerid, i))
			{
				targetid = i;
				break;
			}
		}

		StartInjecting(playerid, targetid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16 && inj_CurrentItem[playerid] != -1)
	{
		StopInjecting(playerid);
	}

	return 1;
}

StartInjecting(playerid, targetid)
{
	if(playerid == targetid)
	{
		ApplyAnimation(playerid, "PED", "IDLE_CSAW", 4.0, 0, 1, 1, 0, 500, 1);
	//	ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 500, 1);
	}

	else
	{
		if(IsPlayerKnockedOut(targetid))
			ApplyAnimation(playerid, "KNIFE", "KNIFE_G", 2.0, 0, 0, 0, 0, 0);

		else
			ApplyAnimation(playerid, "ROCKET", "IDLE_ROCKET", 4.0, 0, 1, 1, 0, 500, 1);
	}

	inj_CurrentItem[playerid] = GetPlayerItem(playerid);
	inj_CurrentTarget[playerid] = targetid;

	StartHoldAction(playerid, 1000);
}

StopInjecting(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	inj_CurrentItem[playerid] = -1;
	inj_CurrentTarget[playerid] = -1;
}

hook OnHoldActionFinish(playerid)
{
	if(inj_CurrentItem[playerid] != -1)
	{
		if(!IsPlayerConnected(inj_CurrentTarget[playerid]))
			return Y_HOOKS_BREAK_RETURN_1;

		if(!IsValidItem(inj_CurrentItem[playerid]))
			return Y_HOOKS_BREAK_RETURN_1;

		if(GetPlayerItem(playerid) != inj_CurrentItem[playerid])
			return Y_HOOKS_BREAK_RETURN_1;

		switch(GetItemExtraData(inj_CurrentItem[playerid]))
		{
			case INJECT_TYPE_EMPTY:
			{
				ApplyDrug(inj_CurrentTarget[playerid], drug_Air);
			}

			case INJECT_TYPE_MORPHINE:
			{
				ApplyDrug(inj_CurrentTarget[playerid], drug_Morphine);
			}

			case INJECT_TYPE_ADRENALINE:
			{
				ApplyDrug(inj_CurrentTarget[playerid], drug_Adrenaline);

				if(IsPlayerKnockedOut(inj_CurrentTarget[playerid]) && inj_CurrentTarget[playerid] != playerid)
					WakeUpPlayer(inj_CurrentTarget[playerid]);
			}

			case INJECT_TYPE_HEROIN:
			{
				ApplyDrug(inj_CurrentTarget[playerid], drug_Heroin);

				new
					hour = 22,
					minute = 30,
					weather = 33;

				SetTimeForPlayer(playerid, hour, minute);
				SetWeatherForPlayer(playerid, weather);
			}
		}

		SetItemExtraData(inj_CurrentItem[playerid], INJECT_TYPE_EMPTY);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

public OnPlayerDrugWearOff(playerid, drugtype)
{
	if(drugtype == drug_Heroin)
	{
		SetTimeForPlayer(playerid, -1, -1, true);
		SetWeatherForPlayer(playerid);
	}

	#if defined inj_OnPlayerDrugWearOff
		return inj_OnPlayerDrugWearOff(playerid, drugtype);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDrugWearOff
	#undef OnPlayerDrugWearOff
#else
	#define _ALS_OnPlayerDrugWearOff
#endif

#define OnPlayerDrugWearOff inj_OnPlayerDrugWearOff
#if defined inj_OnPlayerDrugWearOff
	forward inj_OnPlayerDrugWearOff(playerid, drugtype);
#endif
