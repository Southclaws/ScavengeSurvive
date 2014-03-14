#include <YSI\y_hooks>


#define INJECT_TYPE_EMPTY		(0)
#define INJECT_TYPE_MORPHINE	(1)
#define INJECT_TYPE_ADRENALINE	(2)
#define INJECT_TYPE_HEROINE		(3)


static
	inj_CurrentItem[MAX_PLAYERS],
	inj_CurrentTarget[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	inj_CurrentItem[playerid] = -1;
	inj_CurrentTarget[playerid] = -1;
}

public OnItemCreate(itemid)
{
	if(IsItemLoot(itemid))
	{
		if(GetItemType(itemid) == item_AutoInjec)
		{
			SetItemExtraData(itemid, 1 + random(3));
		}
	}

	return CallLocalFunction("inj_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate inj_OnItemCreate
forward inj_OnItemCreate(itemid);

public OnItemNameRender(itemid)
{
	if(GetItemType(itemid) == item_AutoInjec)
	{
		switch(GetItemExtraData(itemid))
		{
			case INJECT_TYPE_EMPTY:			SetItemNameExtra(itemid, "Empty");
			case INJECT_TYPE_MORPHINE:		SetItemNameExtra(itemid, "Morphine");
			case INJECT_TYPE_ADRENALINE:	SetItemNameExtra(itemid, "Adrenaline");
			case INJECT_TYPE_HEROINE:		SetItemNameExtra(itemid, "Heroine");
			default:						SetItemNameExtra(itemid, "Empty");
		}
	}

	return CallLocalFunction("inj_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender inj_OnItemNameRender
forward inj_OnItemNameRender(itemid);

public OnPlayerUseItem(playerid, itemid)
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

	return CallLocalFunction("inj_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem inj_OnPlayerUseItem
forward inj_OnPlayerUseItem(playerid, itemid);

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

public OnHoldActionFinish(playerid)
{
	if(inj_CurrentItem[playerid] != -1)
	{
		if(!IsPlayerConnected(inj_CurrentTarget[playerid]))
			return 0;

		if(!IsValidItem(inj_CurrentItem[playerid]))
			return 0;

		if(GetPlayerItem(playerid) != inj_CurrentItem[playerid])
			return 0;

		switch(GetItemExtraData(inj_CurrentItem[playerid]))
		{
			case INJECT_TYPE_EMPTY:
			{
				ApplyDrug(inj_CurrentTarget[playerid], DRUG_TYPE_AIR);
			}

			case INJECT_TYPE_MORPHINE:
			{
				ApplyDrug(inj_CurrentTarget[playerid], DRUG_TYPE_MORPHINE);
			}

			case INJECT_TYPE_ADRENALINE:
			{
				ApplyDrug(inj_CurrentTarget[playerid], DRUG_TYPE_ADRENALINE);

				if(IsPlayerKnockedOut(inj_CurrentTarget[playerid]) && inj_CurrentTarget[playerid] != playerid)
					WakeUpPlayer(inj_CurrentTarget[playerid]);
			}

			case INJECT_TYPE_HEROINE:
			{
				ApplyDrug(inj_CurrentTarget[playerid], DRUG_TYPE_HEROINE);
			}
		}

		SetItemExtraData(inj_CurrentItem[playerid], INJECT_TYPE_EMPTY);
	}

	return CallLocalFunction("inj_OnHoldActionFinish", "d", playerid);
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish inj_OnHoldActionFinish
forward inj_OnHoldActionFinish(playerid);
