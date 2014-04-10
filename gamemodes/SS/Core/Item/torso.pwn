#include <YSI\y_hooks>


static
		gut_TargetItem[MAX_PLAYERS],
Timer:	gut_PickUpTimer[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	gut_TargetItem[playerid] = INVALID_ITEM_ID;
}

public OnItemCreateInWorld(itemid)
{
	if(GetItemType(itemid) == item_Torso)
	{
		if(GetItemExtraData(itemid) != -1)
			SetButtonText(GetItemButtonID(itemid), "Hold "KEYTEXT_INTERACT" to pick up/harvest with knife~n~Press "KEYTEXT_INTERACT" to investigate");
	}

	return CallLocalFunction("tor_OnItemCreateInWorld", "d", itemid);
}
#if defined _ALS_OnItemCreateInWorld
	#undef OnItemCreateInWorld
#else
	#define _ALS_OnItemCreateInWorld
#endif
#define OnItemCreateInWorld tor_OnItemCreateInWorld
forward tor_OnItemCreateInWorld(itemid);

public OnPlayerUseWeaponWithItem(playerid, weapon, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(weapon == 4 && itemtype == item_Torso)
	{
		if(gettime() - GetItemArrayDataAtCell(itemid, 2) < 86400)
		{
			StartHoldAction(playerid, 3000);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
			gut_TargetItem[playerid] = itemid;
		}
		else
		{
			ShowActionText(playerid, "The body has decomposed too much to harvest", 3000);
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

public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Torso)
	{
		if(GetItemExtraData(itemid) != -1)
		{
			gut_PickUpTimer[playerid] = defer PickUpTorso(playerid);
			gut_TargetItem[playerid] = itemid;
			return 1;
		}
	}

	return CallLocalFunction("tor_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem tor_OnPlayerPickUpItem
forward tor_OnPlayerPickUpItem(playerid, itemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys == 16)
	{
		if(IsValidItem(gut_TargetItem[playerid]))
		{
			StopHoldAction(playerid);
			ClearAnimations(playerid);

			if(GetPlayerWeapon(playerid) != 4)
			{
				ShowTorsoDetails(playerid, gut_TargetItem[playerid]);

				stop gut_PickUpTimer[playerid];
				gut_TargetItem[playerid] = INVALID_ITEM_ID;
			}
		}
	}
}

timer PickUpTorso[250](playerid)
{
	if(GetPlayerWeapon(playerid) == 0)
	{
		PlayerPickUpItem(playerid, gut_TargetItem[playerid]);
		gut_TargetItem[playerid] = INVALID_ITEM_ID;
	}
}


public OnHoldActionFinish(playerid)
{
	if(IsValidItem(gut_TargetItem[playerid]))
	{
		if(GetItemExtraData(gut_TargetItem[playerid]) == -1)
			return 1;

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

		SetItemArrayDataAtCell(gut_TargetItem[playerid], 0, 0);
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
