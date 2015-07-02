#include <YSI\y_hooks>


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

public OnItemCreate(itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_AutoInjec)
		{
			SetItemExtraData(itemid, 1 + random(3));
		}
	}

	#if defined inj_OnItemCreate
		return inj_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate inj_OnItemCreate
#if defined inj_OnItemCreate
	forward inj_OnItemCreate(itemid);
#endif

public OnItemNameRender(itemid, ItemType:itemtype)
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

	#if defined inj_OnItemNameRender
		return inj_OnItemNameRender(itemid, itemtype);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender inj_OnItemNameRender
#if defined inj_OnItemNameRender
	forward inj_OnItemNameRender(itemid, ItemType:itemtype);
#endif

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

	#if defined inj_OnPlayerUseItem
		return inj_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem inj_OnPlayerUseItem
#if defined inj_OnPlayerUseItem
	forward inj_OnPlayerUseItem(playerid, itemid);
#endif

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

	#if defined inj_OnHoldActionFinish
		return inj_OnHoldActionFinish(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish inj_OnHoldActionFinish
#if defined inj_OnHoldActionFinish
	forward inj_OnHoldActionFinish(playerid);
#endif

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
