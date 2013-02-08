#include <YSI\y_hooks>


new
	ItemType:item_Backpack = INVALID_ITEM_TYPE,
	ItemType:item_Satchel = INVALID_ITEM_TYPE,
	gPlayerBackpack[MAX_PLAYERS],
	pack_InventoryOptionID[MAX_PLAYERS],
	bool:gTakingOffBag[MAX_PLAYERS];


stock GivePlayerBackpack(playerid, itemid)
{
	if(GetItemType(itemid) == item_Backpack)
	{
		gPlayerBackpack[playerid] = itemid;
		SetPlayerAttachedObject(playerid, 1, 3026, 1, -0.110900, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
		RemoveItemFromWorld(itemid);
	}
	else if(GetItemType(itemid) == item_Satchel)
	{
		gPlayerBackpack[playerid] = itemid;
		SetPlayerAttachedObject(playerid, 1, 363, 1, 0.241894, -0.160918, 0.181463, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
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
	RemovePlayerAttachedObject(playerid, 1);
	CreateItemInWorld(gPlayerBackpack[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
	gPlayerBackpack[playerid] = INVALID_ITEM_ID;
}

stock GetPlayerBackpackItem(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return INVALID_ITEM_ID;

	return gPlayerBackpack[playerid];
}

stock IsItemTypeBag(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(itemtype == item_Satchel || itemtype == item_Backpack)
		return 1;

	return 0;
}

hook OnPlayerConnect(playerid)
{
	gPlayerBackpack[playerid] = INVALID_ITEM_ID;
}

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_Backpack)
	{
		SetItemExtraData(itemid, CreateContainer("Backpack", 8, .virtual = 1, .max_med = 4, .max_large = 2, .max_carry = 0));
	}
	if(GetItemType(itemid) == item_Satchel)
	{
		SetItemExtraData(itemid, CreateContainer("Patrol Pack", 4, .virtual = 1, .max_med = 2, .max_large = 1, .max_carry = 0));
	}

	return CallLocalFunction("pack_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate pack_OnItemCreate
forward pack_OnItemCreate(itemid);


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Backpack || GetItemType(itemid) == item_Satchel)
	{
		CancelPlayerMovement(playerid);
		DisplayContainerInventory(playerid, GetItemExtraData(itemid));
	}
	return CallLocalFunction("pack_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem pack_OnPlayerUseItem
forward pack_OnPlayerUseItem(playerid, itemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(IsValidItem(gPlayerBackpack[playerid]))
	{
		if(newkeys & KEY_NO)
		{
			if(!IsValidItem(GetPlayerItem(playerid)) && GetPlayerWeapon(playerid) == 0)
			{
				RemovePlayerAttachedObject(playerid, 1);
				CreateItemInWorld(gPlayerBackpack[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
				GiveWorldItemToPlayer(playerid, gPlayerBackpack[playerid], 1);
				gPlayerBackpack[playerid] = INVALID_ITEM_ID;
				gTakingOffBag[playerid] = true;
			}
		}
		if(newkeys & KEY_YES)
		{
			if(IsPlayerInventoryFull(playerid))
			{
				new
					itemid = GetPlayerItem(playerid),
					containerid = GetItemExtraData(gPlayerBackpack[playerid]);

				if(IsValidContainer(containerid) && IsValidItem(itemid))
				{
					new containername[CNT_MAX_NAME];

					GetContainerName(containerid, containername);

					if(AddItemToContainer(containerid, itemid, playerid))
					{
						new str[32];
						format(str, 32, "Item added to %s", containername);
						ShowMsgBox(playerid, str, 3000, 150);
						return 1;
					}
					else
					{
						new str[32];
						format(str, 32, "%s full", containername);
						ShowMsgBox(playerid, str, 3000, 100);
						return 1;
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

			if(GetItemType(itemid) == item_Satchel || GetItemType(itemid) == item_Backpack)
				GivePlayerBackpack(playerid, itemid);
		}
	}

	return 1;
}

public OnPlayerDropItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Backpack || GetItemType(itemid) == item_Satchel)
	{
		if(gTakingOffBag[playerid])
		{
			gTakingOffBag[playerid] = false;
			return 1;
		}
	}

	return CallLocalFunction("pack_OnPlayerDropItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem pack_OnPlayerDropItem
forward pack_OnPlayerDropItem(playerid, itemid);

public OnPlayerGiveItem(playerid, targetid, itemid)
{
	if(GetItemType(itemid) == item_Backpack || GetItemType(itemid) == item_Satchel)
	{
		if(gTakingOffBag[playerid])
		{
			gTakingOffBag[playerid] = false;
			return 1;
		}
	}

	return CallLocalFunction("pack_OnPlayerGiveItem", "ddd", playerid, targetid, itemid);
}
#if defined _ALS_OnPlayerGiveItem
	#undef OnPlayerGiveItem
#else
	#define _ALS_OnPlayerGiveItem
#endif
#define OnPlayerGiveItem pack_OnPlayerGiveItem
forward pack_OnPlayerGiveItem(playerid, targetid, itemid);

public OnPlayerViewInventoryOpt(playerid)
{
	print("OnPlayerViewInventoryOpt");
	if(IsValidItem(gPlayerBackpack[playerid]) && !IsValidContainer(GetPlayerCurrentContainer(playerid)))
	{
		pack_InventoryOptionID[playerid] = AddInventoryOption(playerid, "Move to bag");
	}

	return CallLocalFunction("pack_PlayerViewInventoryOpt", "d", playerid);
}
#if defined _ALS_OnPlayerViewInventoryOpt
	#undef OnPlayerViewInventoryOpt
#else
	#define _ALS_OnPlayerViewInventoryOpt
#endif
#define OnPlayerViewInventoryOpt pack_PlayerViewInventoryOpt
forward pack_PlayerViewInventoryOpt(playerid);

public OnPlayerSelectInventoryOpt(playerid, option)
{
	print("OnPlayerSelectInventoryOpt");
	if(IsValidItem(gPlayerBackpack[playerid]))
	{
		if(option == pack_InventoryOptionID[playerid])
		{
			new
				containerid,
				slot,
				itemid;
			
			containerid = GetItemExtraData(gPlayerBackpack[playerid]);
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

	return CallLocalFunction("pack_PlayerSelectInventoryOption", "dd", playerid, option);
}
#if defined _ALS_OnPlayerSelectInventoryOpt
	#undef OnPlayerSelectInventoryOpt
#else
	#define _ALS_OnPlayerSelectInventoryOpt
#endif
#define OnPlayerSelectInventoryOpt pack_PlayerSelectInventoryOpt
forward pack_PlayerSelectInventoryOpt(playerid, option);

public OnPlayerViewContainerOpt(playerid, containerid)
{
	print("OnPlayerViewContainerOpt");
	if(IsValidItem(gPlayerBackpack[playerid]) && containerid != GetItemExtraData(gPlayerBackpack[playerid]))
	{
		pack_InventoryOptionID[playerid] = AddContainerOption(playerid, "Move to bag");
	}

	return CallLocalFunction("pack_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt pack_OnPlayerViewContainerOpt
forward pack_OnPlayerViewContainerOpt(playerid, containerid);

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	if(IsValidItem(gPlayerBackpack[playerid]))
	{
		if(option == pack_InventoryOptionID[playerid])
		{
			new
				bagcontainerid,
				slot,
				itemid;

			bagcontainerid = GetItemExtraData(gPlayerBackpack[playerid]);
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

	return CallLocalFunction("pack_OnPlayerSelectContainerOpt", "ddd", playerid, containerid, option);
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt pack_OnPlayerSelectContainerOpt
forward pack_OnPlayerSelectContainerOpt(playerid, containerid, option);

