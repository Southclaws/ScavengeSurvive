#include <YSI\y_hooks>


static
	tnt_CurrentTentItem[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;
}


public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_Hammer && GetItemType(withitemid) == item_TentPack)
	{
		StartBuildingTent(playerid, withitemid);
	}

	return CallLocalFunction("tnt_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem tnt_OnPlayerUseItemWithItem
forward tnt_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		StopBuildingTent(playerid);
	}
}

StartBuildingTent(playerid, itemid)
{
	tnt_CurrentTentItem[playerid] = itemid;
	StartHoldAction(playerid, 10000);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
}

StopBuildingTent(playerid)
{
	if(!IsValidItem(GetPlayerItem(playerid)))
		return;

	if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID)
	{
		tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		return;
	}
	return;
}

public OnHoldActionFinish(playerid)
{
	if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:rz;

		GetItemPos(tnt_CurrentTentItem[playerid], x, y, z);
		GetItemRot(tnt_CurrentTentItem[playerid], rz, rz, rz);

		CreateTent(x, y, z + 0.4, rz);
		DestroyItem(tnt_CurrentTentItem[playerid]);
		ClearAnimations(playerid);

		tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;
	}

	return CallLocalFunction("tnt1_OnHoldActionFinish", "d", playerid);
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish tnt1_OnHoldActionFinish
forward tnt1_OnHoldActionFinish(playerid);
