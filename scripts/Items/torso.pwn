#include <YSI\y_hooks>


static gut_TargetItem[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	gut_TargetItem[playerid] = INVALID_ITEM_ID;
}


public OnPlayerUseWeaponWithItem(playerid, weapon, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(weapon == 4 && itemtype == item_Torso)
	{
		if(GetItemExtraData(itemid) != -1)
		{
			StartHoldAction(playerid, 3000);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
			gut_TargetItem[playerid] = itemid;
		}
	}
	return CallLocalFunction("tor_OnPlayerUseWeaponWithItem", "ddd", playerid, weapon, itemid);
}
#if defined _ALS_OnPlayerUseWeaponWithItem
	#undef OnPlayerUseWeaponWithItem
#else
	#define _ALS_OnPlayerUseWeaponWithItem
#endif
#define OnPlayerUseWeaponWithItem tor_OnPlayerUseWeaponWithItem
forward tor_OnPlayerUseWeaponWithItem(playerid, weapon, itemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		if(IsValidItem(gut_TargetItem[playerid]))
		{
			StopHoldAction(playerid);
			ClearAnimations(playerid);
		}
	}

	return 1;
}

public OnHoldActionFinish(playerid)
{
	if(IsValidItem(gut_TargetItem[playerid]))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		GetItemPos(gut_TargetItem[playerid], x, y, z);
		GetItemRot(gut_TargetItem[playerid], r, r, r);

		CreateItem(item_Meat,
			x + (0.5 * floatsin(-r + 90.0, degrees)),
			y + (0.5 * floatcos(-r + 90.0, degrees)),
			z, .rz = r);

		CreateItem(item_Meat,
			x + (0.5 * floatsin(-r + 270.0, degrees)),
			y + (0.5 * floatcos(-r + 270.0, degrees)),
			z, .rz = r);

		SetItemExtraData(gut_TargetItem[playerid], -1);
		ClearAnimations(playerid);

		gut_TargetItem[playerid] = INVALID_ITEM_ID;

		return 1;
	}

	return CallLocalFunction("gut_OnHoldActionFinish", "d", playerid);
}


// Hooks


#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish gut_OnHoldActionFinish
forward gut_OnHoldActionFinish(playerid);
