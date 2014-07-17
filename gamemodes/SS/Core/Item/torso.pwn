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

	#if defined tor_OnItemCreateInWorld
		return tor_OnItemCreateInWorld(itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemCreateInWorld
	#undef OnItemCreateInWorld
#else
	#define _ALS_OnItemCreateInWorld
#endif
#define OnItemCreateInWorld tor_OnItemCreateInWorld
#if defined tor_OnItemCreateInWorld
	forward tor_OnItemCreateInWorld(itemid);
#endif

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_Knife && GetItemType(withitemid) == item_Torso)
	{
		if(GetItemArrayDataAtCell(withitemid, 0))
		{
			if(gettime() - GetItemArrayDataAtCell(withitemid, 1) < 86400)
			{
				StartHoldAction(playerid, 3000);
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
				gut_TargetItem[playerid] = withitemid;
			}
			else
			{
				ShowActionText(playerid, "The body has decomposed too much to harvest", 3000);
			}
		}
		else
		{
			ShowActionText(playerid, "The body has already been harvested of the edible (tasty) parts", 3000);
		}
	}
	#if defined tor_OnPlayerUseItemWithItem
		return tor_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem tor_OnPlayerUseItemWithItem
#if defined tor_OnPlayerUseItemWithItem
	forward tor_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif

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

	#if defined tor_OnPlayerPickUpItem
		return tor_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem tor_OnPlayerPickUpItem
#if defined tor_OnPlayerPickUpItem
	forward tor_OnPlayerPickUpItem(playerid, itemid);
#endif

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

		CreateItem(item_Meat, x, y, z + 0.3, .rz = r, .zoffset = FLOOR_OFFSET);

		SetItemArrayDataAtCell(gut_TargetItem[playerid], 0, 0);
		ClearAnimations(playerid);

		gut_TargetItem[playerid] = INVALID_ITEM_ID;

		return 1;
	}

	#if defined gut_OnHoldActionFinish
		return gut_OnHoldActionFinish(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
 
#define OnHoldActionFinish gut_OnHoldActionFinish
#if defined gut_OnHoldActionFinish
	forward gut_OnHoldActionFinish(playerid);
#endif
