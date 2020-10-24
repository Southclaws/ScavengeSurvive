/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define INJECT_TYPE_EMPTY		(0)
#define INJECT_TYPE_MORPHINE	(1)
#define INJECT_TYPE_ADRENALINE	(2)
#define INJECT_TYPE_HEROIN		(3)


static
Item:inj_CurrentItem[MAX_PLAYERS],
	inj_CurrentTarget[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "AutoInjec"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("AutoInjec"), 1);
}

hook OnPlayerConnect(playerid)
{
	inj_CurrentItem[playerid] = INVALID_ITEM_ID;
	inj_CurrentTarget[playerid] = -1;
}

hook OnItemCreate(Item:itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_AutoInjec)
		{
			SetItemExtraData(itemid, 1 + random(3));
		}
	}
}

hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	if(itemtype == item_AutoInjec)
	{
		new type;
		GetItemExtraData(itemid, type);
		switch(type)
		{
			case INJECT_TYPE_EMPTY:			SetItemNameExtra(itemid, "Empty");
			case INJECT_TYPE_MORPHINE:		SetItemNameExtra(itemid, "Morphine");
			case INJECT_TYPE_ADRENALINE:	SetItemNameExtra(itemid, "Adrenaline");
			case INJECT_TYPE_HEROIN:		SetItemNameExtra(itemid, "Heroin");
			default:						SetItemNameExtra(itemid, "Empty");
		}
	}
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_AutoInjec)
	{
		new targetid = playerid;

		foreach(new i : Player)
		{
			if(IsPlayerNextToPlayer(playerid, i))
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
	if(oldkeys & 16 && inj_CurrentItem[playerid] != INVALID_ITEM_ID)
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

	inj_CurrentItem[playerid] = INVALID_ITEM_ID;
	inj_CurrentTarget[playerid] = -1;
}

hook OnHoldActionFinish(playerid)
{
	if(inj_CurrentItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsPlayerConnected(inj_CurrentTarget[playerid]))
			return Y_HOOKS_BREAK_RETURN_1;

		if(!IsValidItem(inj_CurrentItem[playerid]))
			return Y_HOOKS_BREAK_RETURN_1;

		if(GetPlayerItem(playerid) != inj_CurrentItem[playerid])
			return Y_HOOKS_BREAK_RETURN_1;

		new type;
		GetItemExtraData(inj_CurrentItem[playerid], type);
		switch(type)
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

hook OnPlayerDrugWearOff(playerid, drugtype)
{
	if(drugtype == drug_Heroin)
	{
		SetTimeForPlayer(playerid, -1, -1, true);
		SetWeatherForPlayer(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
