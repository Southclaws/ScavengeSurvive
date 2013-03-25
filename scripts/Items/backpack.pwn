#include <YSI\y_hooks>


new
	ItemType:item_Backpack = INVALID_ITEM_TYPE,
	ItemType:item_Satchel = INVALID_ITEM_TYPE,
	ItemType:item_ParaBag = INVALID_ITEM_TYPE,
	bag_PlayerBagID[MAX_PLAYERS],
	bag_InventoryOptionID[MAX_PLAYERS],
	bool:gTakingOffBag[MAX_PLAYERS];


new
Iterator:	bag_Index<ITM_MAX>,
			bag_CurrentBag[MAX_PLAYERS],
			bag_PickUpTick[MAX_PLAYERS],
Timer:		bag_PickUpTimer[MAX_PLAYERS],
			bag_LookingInBag[MAX_PLAYERS];



stock GivePlayerBackpack(playerid, itemid)
{
	if(GetItemType(itemid) == item_Backpack)
	{
		bag_PlayerBagID[playerid] = itemid;
		SetPlayerAttachedObject(playerid, ATTACHSLOT_BAG, 3026, 1, -0.110900, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
		RemoveItemFromWorld(itemid);
	}
	else if(GetItemType(itemid) == item_Satchel)
	{
		bag_PlayerBagID[playerid] = itemid;
		SetPlayerAttachedObject(playerid, ATTACHSLOT_BAG, 363, 1, 0.241894, -0.160918, 0.181463, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
		RemoveItemFromWorld(itemid);
	}
	else if(GetItemType(itemid) == item_ParaBag)
	{
		bag_PlayerBagID[playerid] = itemid;
		SetPlayerAttachedObject(playerid, ATTACHSLOT_BAG, 371, 1, 0.039470, -0.088898, -0.009887, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
		RemoveItemFromWorld(itemid);
	}
	else
	{
		return 0;
	}

	return 1;
}

stock RemovePlayerBackpack(playerid)
{
	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	CreateItemInWorld(bag_PlayerBagID[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;
}

stock GetPlayerBackpackItem(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return INVALID_ITEM_ID;

	return bag_PlayerBagID[playerid];
}

stock IsItemTypeBag(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(itemtype == item_Satchel || itemtype == item_Backpack || itemtype == item_ParaBag)
		return 1;

	return 0;
}

hook OnPlayerConnect(playerid)
{
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;
	bag_LookingInBag[playerid] = INVALID_PLAYER_ID;
}

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_Backpack)
	{
		SetItemExtraData(itemid, CreateContainer("Backpack", 8, .virtual = 1, .max_med = 4, .max_large = 2, .max_carry = 0));
		Iter_Add(bag_Index, itemid);
	}
	if(GetItemType(itemid) == item_Satchel)
	{
		SetItemExtraData(itemid, CreateContainer("Small Bag", 4, .virtual = 1, .max_med = 2, .max_large = 1, .max_carry = 0));
		Iter_Add(bag_Index, itemid);
	}
	if(GetItemType(itemid) == item_ParaBag)
	{
		SetItemExtraData(itemid, CreateContainer("Parachute Bag", 6, .virtual = 1, .max_med = 4, .max_large = 2, .max_carry = 0));
		Iter_Add(bag_Index, itemid);
	}

	return CallLocalFunction("bag_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate bag_OnItemCreate
forward bag_OnItemCreate(itemid);

public OnItemDestroy(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Satchel || itemtype == item_Backpack || itemtype == item_ParaBag)
	{
		new containerid = GetItemExtraData(itemid);

		for(new j; j < GetContainerSize(containerid); j++)
			DestroyItem(GetContainerSlotItem(containerid, j));

		DestroyContainer(containerid);
		Iter_Remove(bag_Index, itemid);
	}

	return CallLocalFunction("bag_OnItemDestroy", "d", itemid);
}
#if defined _ALS_OnItemDestroy
	#undef OnItemDestroy
#else
	#define _ALS_OnItemDestroy
#endif
#define OnItemDestroy bag_OnItemDestroy
forward bag_OnItemDestroy(itemid);

public OnPlayerPickUpItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Satchel || itemtype == item_Backpack || itemtype == item_ParaBag)
	{
		bag_PickUpTick[playerid] = tickcount();
		stop bag_PickUpTimer[playerid];

		if(!IsValidItem(GetPlayerItem(playerid)) && GetPlayerWeapon(playerid) == 0)
		{
			bag_CurrentBag[playerid] = itemid;
			bag_PickUpTimer[playerid] = defer bag_PickUp(playerid, itemid);
		}

		return 1;
	}

	return CallLocalFunction("bag_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem bag_OnPlayerPickUpItem
forward bag_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerUseItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Backpack || itemtype == item_Satchel || itemtype == item_ParaBag)
	{
		CancelPlayerMovement(playerid);
		DisplayContainerInventory(playerid, GetItemExtraData(itemid));
	}
	return CallLocalFunction("bag_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem bag_OnPlayerUseItem
forward bag_OnPlayerUseItem(playerid, itemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(IsValidItem(bag_PlayerBagID[playerid]))
	{
		if(newkeys & KEY_NO)
		{
			if(!IsValidItem(GetPlayerItem(playerid)) && GetPlayerWeapon(playerid) == 0 && !IsValidItem(GetPlayerInteractingItem(playerid)))
			{
				RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
				CreateItemInWorld(bag_PlayerBagID[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
				GiveWorldItemToPlayer(playerid, bag_PlayerBagID[playerid], 1);
				bag_PlayerBagID[playerid] = INVALID_ITEM_ID;
				gTakingOffBag[playerid] = true;
			}
		}
		if(newkeys & KEY_YES)
		{
			new itemid = GetPlayerItem(playerid);

			if(IsPlayerInventoryFull(playerid) || GetItemTypeSize(GetItemType(itemid)) == ITEM_SIZE_MEDIUM)
			{
				new containerid = GetItemExtraData(bag_PlayerBagID[playerid]);

				if(IsValidContainer(containerid) && IsValidItem(itemid))
				{
					if(IsContainerFull(containerid))
					{
						ShowMsgBox(playerid, "Bag full", 3000, 150);
					}
					else
					{
						ShowMsgBox(playerid, "Item added to bag", 3000, 150);
						ApplyAnimation(playerid, "PED", "PHONE_IN", 4.0, 1, 0, 0, 0, 300);
						defer bag_PutItemIn(playerid, itemid, containerid);
					}
				}
			}
		}
	}
	else
	{
		if(newkeys & KEY_YES)
		{
			new itemid = GetPlayerItem(playerid);

			if(GetItemType(itemid) == item_Satchel || GetItemType(itemid) == item_Backpack || GetItemType(itemid) == item_ParaBag)
				GivePlayerBackpack(playerid, itemid);
		}
	}

	if(newkeys & 16)
	{
		foreach(new i : Player)
		{
			if(IsPlayerInPlayerArea(playerid, i))
			{
				if(IsValidItem(bag_PlayerBagID[i]))
				{
					DisplayContainerInventory(playerid, GetItemExtraData(bag_PlayerBagID[i]));
					bag_LookingInBag[playerid] = i;
				}
			}
		}
	}

	if(oldkeys & 16)
	{
		if(tickcount() - bag_PickUpTick[playerid] < 200)
		{
			if(IsValidItem(bag_CurrentBag[playerid]))
			{
				DisplayContainerInventory(playerid, GetItemExtraData(bag_CurrentBag[playerid]));
				ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);
				stop bag_PickUpTimer[playerid];
				bag_PickUpTick[playerid] = 0;
			}
		}
	}

	return 1;
}

timer bag_PickUp[250](playerid, itemid)
{
	if(IsValidItem(GetPlayerItem(playerid)) || GetPlayerWeapon(playerid) != 0)
		return;

	PlayerPickUpItem(playerid, itemid);

	return;
}

timer bag_PutItemIn[300](playerid, itemid, containerid)
{
	AddItemToContainer(containerid, itemid, playerid);
}

public OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidItem(bag_CurrentBag[playerid]))
	{
//		ApplyAnimation(playerid, "BOMBER", "BOM_Plant_2Idle", 4.0, 0, 0, 0, 0, 0);
		ClearAnimations(playerid);
		bag_CurrentBag[playerid] = INVALID_ITEM_ID;
		bag_LookingInBag[playerid] = -1;
	}

	return CallLocalFunction("bag_OnPlayerCloseContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer bag_OnPlayerCloseContainer
forward bag_OnPlayerCloseContainer(playerid, containerid);

public OnPlayerDropItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Backpack || GetItemType(itemid) == item_Satchel || GetItemType(itemid) == item_ParaBag)
	{
		if(gTakingOffBag[playerid])
		{
			gTakingOffBag[playerid] = false;
			return 1;
		}
	}

	return CallLocalFunction("bag_OnPlayerDropItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem bag_OnPlayerDropItem
forward bag_OnPlayerDropItem(playerid, itemid);

public OnPlayerGiveItem(playerid, targetid, itemid)
{
	if(GetItemType(itemid) == item_Backpack || GetItemType(itemid) == item_Satchel || GetItemType(itemid) == item_ParaBag)
	{
		if(gTakingOffBag[playerid])
		{
			gTakingOffBag[playerid] = false;
			return 1;
		}
	}

	return CallLocalFunction("bag_OnPlayerGiveItem", "ddd", playerid, targetid, itemid);
}
#if defined _ALS_OnPlayerGiveItem
	#undef OnPlayerGiveItem
#else
	#define _ALS_OnPlayerGiveItem
#endif
#define OnPlayerGiveItem bag_OnPlayerGiveItem
forward bag_OnPlayerGiveItem(playerid, targetid, itemid);

public OnPlayerViewInventoryOpt(playerid)
{
	if(IsValidItem(bag_PlayerBagID[playerid]) && !IsValidContainer(GetPlayerCurrentContainer(playerid)))
	{
		bag_InventoryOptionID[playerid] = AddInventoryOption(playerid, "Move to bag");
	}

	return CallLocalFunction("bag_PlayerViewInventoryOpt", "d", playerid);
}
#if defined _ALS_OnPlayerViewInventoryOpt
	#undef OnPlayerViewInventoryOpt
#else
	#define _ALS_OnPlayerViewInventoryOpt
#endif
#define OnPlayerViewInventoryOpt bag_PlayerViewInventoryOpt
forward bag_PlayerViewInventoryOpt(playerid);

public OnPlayerSelectInventoryOpt(playerid, option)
{
	if(IsValidItem(bag_PlayerBagID[playerid]) && !IsValidContainer(GetPlayerCurrentContainer(playerid)))
	{
		if(option == bag_InventoryOptionID[playerid])
		{
			new
				containerid,
				slot,
				itemid;
			
			containerid = GetItemExtraData(bag_PlayerBagID[playerid]);
			slot = GetPlayerSelectedInventorySlot(playerid);
			itemid = GetInventorySlotItem(playerid, slot);

			if(!IsValidItem(itemid))
			{
				DisplayPlayerInventory(playerid);
				return 0;
			}

			if(IsContainerFull(containerid))
			{
				new
					str[CNT_MAX_NAME + 6],
					name[CNT_MAX_NAME];

				GetContainerName(containerid, name);
				format(str, sizeof(str), "%s full", name);
				ShowMsgBox(playerid, str, 3000, 100);
				DisplayPlayerInventory(playerid);
				return 0;
			}

			RemoveItemFromInventory(playerid, slot);
			AddItemToContainer(containerid, itemid, playerid);
			DisplayPlayerInventory(playerid);
		}
	}

	return CallLocalFunction("bag_PlayerSelectInventoryOption", "dd", playerid, option);
}
#if defined _ALS_OnPlayerSelectInventoryOpt
	#undef OnPlayerSelectInventoryOpt
#else
	#define _ALS_OnPlayerSelectInventoryOpt
#endif
#define OnPlayerSelectInventoryOpt bag_PlayerSelectInventoryOpt
forward bag_PlayerSelectInventoryOpt(playerid, option);

public OnPlayerViewContainerOpt(playerid, containerid)
{
	if(IsValidItem(bag_PlayerBagID[playerid]) && containerid != GetItemExtraData(bag_PlayerBagID[playerid]))
	{
		bag_InventoryOptionID[playerid] = AddContainerOption(playerid, "Move to bag");
	}

	return CallLocalFunction("bag_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt bag_OnPlayerViewContainerOpt
forward bag_OnPlayerViewContainerOpt(playerid, containerid);

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	if(IsValidItem(bag_PlayerBagID[playerid]) && containerid != GetItemExtraData(bag_PlayerBagID[playerid]))
	{
		if(option == bag_InventoryOptionID[playerid])
		{
			new
				bagcontainerid,
				slot,
				itemid;

			bagcontainerid = GetItemExtraData(bag_PlayerBagID[playerid]);
			slot = GetPlayerContainerSlot(playerid);
			itemid = GetContainerSlotItem(containerid, slot);

			if(!IsValidItem(itemid))
			{
				DisplayContainerInventory(playerid, containerid);
				return 0;
			}

			if(IsContainerFull(bagcontainerid))
			{
				new
					str[CNT_MAX_NAME + 6],
					name[CNT_MAX_NAME];

				GetContainerName(bagcontainerid, name);
				format(str, sizeof(str), "%s full", name);
				ShowMsgBox(playerid, str, 3000, 100);
				DisplayContainerInventory(playerid, containerid);
				return 0;
			}

			if(!WillItemTypeFitInContainer(bagcontainerid, GetItemType(itemid)))
			{
				ShowMsgBox(playerid, "Item won't fit", 3000, 140);
				DisplayContainerInventory(playerid, containerid);
				return 0;
			}

			RemoveItemFromContainer(containerid, slot);
			AddItemToContainer(bagcontainerid, itemid, playerid);
			DisplayContainerInventory(playerid, containerid);
		}
	}

	return CallLocalFunction("bag_OnPlayerSelectContainerOpt", "ddd", playerid, containerid, option);
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt bag_OnPlayerSelectContainerOpt
forward bag_OnPlayerSelectContainerOpt(playerid, containerid, option);

