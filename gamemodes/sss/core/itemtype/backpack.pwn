/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_BAG_TYPE (10)


enum E_BAG_TYPE_DATA
{
			bag_name[MAX_ITEM_NAME],
ItemType:	bag_itemtype,
			bag_size,
Float:		bag_attachOffsetX,
Float:		bag_attachOffsetY,
Float:		bag_attachOffsetZ,
Float:		bag_attachRotX,
Float:		bag_attachRotY,
Float:		bag_attachRotZ,
Float:		bag_attachScaleX,
Float:		bag_attachScaleY,
Float:		bag_attachScaleZ
}


static
			bag_TypeData[MAX_BAG_TYPE][E_BAG_TYPE_DATA],
			bag_TypeTotal,
			bag_ItemTypeBagType[MAX_ITEM_TYPE] = {-1, ...};

static
Item:		bag_ContainerItem		[MAX_CONTAINER],
			bag_ContainerPlayer		[MAX_CONTAINER];

static
Item:		bag_PlayerBagID			[MAX_PLAYERS],
			bag_InventoryOptionID	[MAX_PLAYERS],
bool:		bag_PuttingInBag		[MAX_PLAYERS],
bool:		bag_TakingOffBag		[MAX_PLAYERS],
Item:		bag_CurrentBag			[MAX_PLAYERS],
Timer:		bag_OtherPlayerEnter	[MAX_PLAYERS],
			bag_LookingInBag		[MAX_PLAYERS];


forward OnPlayerWearBag(playerid, Item:itemid);
forward OnPlayerRemoveBag(playerid, Item:itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	for(new Container:i; i < MAX_CONTAINER; i++)
	{
		bag_ContainerPlayer[i] = INVALID_PLAYER_ID;
		bag_ContainerItem[i] = INVALID_ITEM_ID;
	}
}

hook OnPlayerConnect(playerid)
{
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;
	bag_PuttingInBag[playerid] = false;
	bag_TakingOffBag[playerid] = false;
	bag_CurrentBag[playerid] = INVALID_ITEM_ID;
	bag_LookingInBag[playerid] = INVALID_PLAYER_ID;
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineBagType(const name[MAX_ITEM_NAME], ItemType:itemtype, size, Float:attachOffsetX, Float:attachOffsetY, Float:attachOffsetZ, Float:attachRotX, Float:attachRotY, Float:attachRotZ, Float:attachScaleX, Float:attachScaleY, Float:attachScaleZ)
{
	if(bag_TypeTotal == MAX_BAG_TYPE)
		return -1;

	SetItemTypeMaxArrayData(itemtype, 2);

	bag_TypeData[bag_TypeTotal][bag_name]			= name;
	bag_TypeData[bag_TypeTotal][bag_itemtype]		= itemtype;
	bag_TypeData[bag_TypeTotal][bag_size]			= size;
	bag_TypeData[bag_TypeTotal][bag_attachOffsetX]	= attachOffsetX;
	bag_TypeData[bag_TypeTotal][bag_attachOffsetY]	= attachOffsetY;
	bag_TypeData[bag_TypeTotal][bag_attachOffsetZ]	= attachOffsetZ;
	bag_TypeData[bag_TypeTotal][bag_attachRotX]		= attachRotX;
	bag_TypeData[bag_TypeTotal][bag_attachRotY]		= attachRotY;
	bag_TypeData[bag_TypeTotal][bag_attachRotZ]		= attachRotZ;
	bag_TypeData[bag_TypeTotal][bag_attachScaleX]	= attachScaleX;
	bag_TypeData[bag_TypeTotal][bag_attachScaleY]	= attachScaleY;
	bag_TypeData[bag_TypeTotal][bag_attachScaleZ]	= attachScaleZ;

	bag_ItemTypeBagType[itemtype] = bag_TypeTotal;

	return bag_TypeTotal++;
}

stock GivePlayerBag(playerid, Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	new bagtype = bag_ItemTypeBagType[GetItemType(itemid)];

	if(bagtype != -1)
	{
		new Container:containerid;
		GetItemArrayDataAtCell(itemid, _:containerid, 1);

		if(!IsValidContainer(containerid))
		{
			err("Bag (%d) container ID (%d) was invalid container has to be recreated.", _:itemid, _:containerid);

			containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

			SetItemArrayDataAtCell(itemid, _:containerid, 1);
		}

		new colour;
		GetItemTypeColour(bag_TypeData[bagtype][bag_itemtype], colour);

		bag_PlayerBagID[playerid] = itemid;

		new model;
		GetItemTypeModel(bag_TypeData[bagtype][bag_itemtype], model);

		SetPlayerAttachedObject(playerid, ATTACHSLOT_BAG, model, 1,
			bag_TypeData[bagtype][bag_attachOffsetX],
			bag_TypeData[bagtype][bag_attachOffsetY],
			bag_TypeData[bagtype][bag_attachOffsetZ],
			bag_TypeData[bagtype][bag_attachRotX],
			bag_TypeData[bagtype][bag_attachRotY],
			bag_TypeData[bagtype][bag_attachRotZ],
			bag_TypeData[bagtype][bag_attachScaleX],
			bag_TypeData[bagtype][bag_attachScaleY],
			bag_TypeData[bagtype][bag_attachScaleZ], colour, colour);

		bag_ContainerItem[containerid] = itemid;
		bag_ContainerPlayer[containerid] = playerid;
		RemoveItemFromWorld(itemid);
		RemoveCurrentItem(GetItemHolder(itemid));

		return 1;
	}

	return 0;
}

stock RemovePlayerBag(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	new Container:containerid;
	GetItemArrayDataAtCell(bag_PlayerBagID[playerid], _:containerid, 1);

	if(!IsValidContainer(containerid))
	{
		new bagtype = bag_ItemTypeBagType[GetItemType(bag_PlayerBagID[playerid])];

		if(bagtype == -1)
		{
			err("Player (%d) bag item type (%d) is not a valid bag type.", playerid, bagtype);
			return 0;
		}

		err("Bag (%d) container ID (%d) was invalid container has to be recreated.", _:bag_PlayerBagID[playerid], _:containerid);

		containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

		SetItemArrayDataAtCell(bag_PlayerBagID[playerid], _:containerid, 1);
	}

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	CreateItemInWorld(bag_PlayerBagID[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));

	bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;

	return 1;
}

stock DestroyPlayerBag(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	new Container:containerid;
	GetItemArrayDataAtCell(bag_PlayerBagID[playerid], _:containerid, 1);

	if(IsValidContainer(containerid))
	{
		bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
		DestroyContainer(containerid);
	}

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	DestroyItem(bag_PlayerBagID[playerid]);

	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;

	return 1;
}

/*
	Automatically determines whether to add to the player's inventory or bag.
*/
stock AddItemToPlayer(playerid, Item:itemid, useinventory = false, playeraction = true)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeCarry(itemtype)  || IsValidHolsterItem(itemtype))
		return -1;

	new required;

	if(useinventory)
		required = AddItemToInventory(playerid, itemid);

	if(required == 0)
		return 0;

	if(!IsValidItem(bag_PlayerBagID[playerid]))
	{
		if(required > 0)
			ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO", true), required), 3000, 150);

		return -3;
	}

	new Container:containerid;
	GetItemArrayDataAtCell(bag_PlayerBagID[playerid], _:containerid, 1);

	if(!IsValidContainer(containerid))
		return -3;

	new
		itemsize,
		freeslots;

	GetItemTypeSize(GetItemType(itemid), itemsize);
	GetContainerFreeSlots(containerid, freeslots);

	if(itemsize > freeslots)
	{
		ShowActionText(playerid, sprintf(ls(playerid, "BAGEXTRASLO", true), itemsize - freeslots), 3000, 150);
		return -4;
	}

	if(playeraction)
	{
		ShowActionText(playerid, ls(playerid, "BAGITMADDED", true), 3000, 150);
		ApplyAnimation(playerid, "PED", "PHONE_IN", 4.0, 1, 0, 0, 0, 300);
		bag_PuttingInBag[playerid] = true;
		defer bag_PutItemIn(playerid, _:itemid, _:containerid);
	}
	else
	{
		return AddItemToContainer(containerid, itemid, playerid);
	}

	return 0;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnItemCreate(Item:itemid)
{
	new bagtype = bag_ItemTypeBagType[GetItemType(itemid)];

	if(bagtype != -1)
	{
		new
			Container:containerid,
			lootindex = GetItemLootIndex(itemid);

		containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

		bag_ContainerItem[containerid] = itemid;
		bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;

		SetItemArrayDataSize(itemid, 2);
		SetItemArrayDataAtCell(itemid, _:containerid, 1);

		if(lootindex != -1)
		{
			FillContainerWithLoot(containerid, random(4), lootindex);
		}
	}
}

hook OnItemCreateInWorld(Item:itemid)
{
	if(IsItemTypeBag(GetItemType(itemid)))
	{
		new Button:buttonid;
		GetItemButtonID(itemid, buttonid);
		SetButtonText(buttonid, "Hold "KEYTEXT_INTERACT" to pick up~n~Press "KEYTEXT_INTERACT" to open");
	}
}

hook OnItemDestroy(Item:itemid)
{
	if(IsItemTypeBag(GetItemType(itemid)))
	{
		new Container:containerid;
		GetItemArrayDataAtCell(itemid, _:containerid, 1);
		if(IsValidContainer(containerid))
		{
			bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
			bag_ContainerItem[containerid] = INVALID_ITEM_ID;
			DestroyContainer(containerid);
		}
	}
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(bag_ItemTypeBagType[GetItemType(itemid)] != -1)
	{
		new Container:containerid;
		GetPlayerCurrentContainer(playerid, containerid);
		if(IsValidContainer(containerid))
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(IsItemInWorld(itemid))
			_DisplayBagDialog(playerid, itemid, true);

		else
			_DisplayBagDialog(playerid, itemid, false);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(bag_ItemTypeBagType[GetItemType(withitemid)] != -1)
	{
		_DisplayBagDialog(playerid, withitemid, true);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381 || GetTickCountDifference(GetTickCount(), GetPlayerLastHolsterTick(playerid)) < 1000)
		return 1;

	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(newkeys & KEY_YES)
	{
		_BagEquipHandler(playerid);
	}

	if(newkeys & KEY_NO)
	{
		_BagDropHandler(playerid);
	}

	if(newkeys & 16)
	{
		_BagRummageHandler(playerid);
	}

	return 1;
}

_BagEquipHandler(playerid)
{
	new Item:itemid = GetPlayerItem(playerid);

	if(!IsValidItem(itemid))
		return 0;

	if(bag_PuttingInBag[playerid])
		return 0;

	if(GetTickCountDifference(GetTickCount(), GetPlayerLastHolsterTick(playerid)) < 1000)
		return 0;

	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeBag(itemtype))
	{
		if(IsValidItem(bag_PlayerBagID[playerid]))
		{
			new Item:currentbagitem = bag_PlayerBagID[playerid];

			RemovePlayerBag(playerid);
			GivePlayerBag(playerid, itemid);
			GiveWorldItemToPlayer(playerid, currentbagitem, 1);
		}
		else
		{
			if(CallLocalFunction("OnPlayerWearBag", "dd", playerid, _:itemid))
				return 0;

			GivePlayerBag(playerid, itemid);
		}

		return 0;
	}
	else
	{
		AddItemToPlayer(playerid, itemid, true);
	}

	return 1;
}

_BagDropHandler(playerid)
{
	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	if(IsValidItem(GetPlayerItem(playerid)))
		return 0;

	if(IsValidItem(GetPlayerInteractingItem(playerid)))
		return 0;

	if(CallLocalFunction("OnPlayerRemoveBag", "dd", playerid, _:bag_PlayerBagID[playerid]))
		return 0;

	new Container:containerid;
	GetItemArrayDataAtCell(bag_PlayerBagID[playerid], _:containerid, 1);

	if(!IsValidContainer(containerid))
		return 0;

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	CreateItemInWorld(bag_PlayerBagID[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
	GiveWorldItemToPlayer(playerid, bag_PlayerBagID[playerid], 1);
	bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;
	bag_TakingOffBag[playerid] = true;

	return 1;
}

_BagRummageHandler(playerid)
{
	foreach(new i : Player)
	{
		if(IsPlayerNextToPlayer(playerid, i))
		{
			if(IsValidItem(bag_PlayerBagID[i]))
			{
				new
					Float:px,
					Float:py,
					Float:pz,
					Float:tx,
					Float:ty,
					Float:tz,
					Float:tr,
					Float:angle;

				GetPlayerPos(playerid, px, py, pz);
				GetPlayerPos(i, tx, ty, tz);
				GetPlayerFacingAngle(i, tr);

				angle = absoluteangle(tr - GetAngleToPoint(tx, ty, px, py));

				if(155.0 < angle < 205.0)
				{
					CancelPlayerMovement(playerid);
					bag_OtherPlayerEnter[playerid] = defer bag_EnterOtherPlayer(playerid, i);
					break;
				}
			}
		}
	}

	return 1;
}

timer bag_PutItemIn[300](playerid, itemid, containerid)
{
	AddItemToContainer(Container:containerid, Item:itemid, playerid);
	bag_PuttingInBag[playerid] = false;
}

timer bag_EnterOtherPlayer[250](playerid, targetid)
{
	_DisplayBagDialog(playerid, Item:bag_PlayerBagID[targetid], false);
	bag_LookingInBag[playerid] = targetid;
}

PlayerBagUpdate(playerid)
{
	if(IsPlayerConnected(bag_LookingInBag[playerid]))
	{
		if(GetPlayerDist3D(playerid, bag_LookingInBag[playerid]) > 1.0)
		{
			ClosePlayerContainer(playerid);
			CancelSelectTextDraw(playerid);
			bag_LookingInBag[playerid] = -1;
		}
	}
}

_DisplayBagDialog(playerid, Item:itemid, animation)
{
	new Container:containerid;
	GetItemArrayDataAtCell(itemid, _:containerid, 1);
	DisplayContainerInventory(playerid, containerid);
	bag_CurrentBag[playerid] = itemid;

	if(animation)
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);

	else
		CancelPlayerMovement(playerid);
}

hook OnItemAddToInventory(playerid, Item:itemid, slot)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeBag(itemtype))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsItemTypeCarry(itemtype))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerAddToInventory(playerid, Item:itemid, success)
{
	if(success)
	{
		new ItemType:itemtype = GetItemType(itemid);

		if(IsItemTypeBag(itemtype))
			return Y_HOOKS_BREAK_RETURN_1;

		if(IsItemTypeCarry(itemtype))
			return Y_HOOKS_BREAK_RETURN_1;
	}
	else
	{
		new ItemType:itemtype = GetItemType(itemid);

		if(IsItemTypeBag(itemtype))
			return Y_HOOKS_BREAK_RETURN_1;

		if(IsItemTypeCarry(itemtype) || IsValidHolsterItem(itemtype))
			return Y_HOOKS_BREAK_RETURN_1;

		new
			itemsize,
			freeslots;

		GetItemTypeSize(GetItemType(itemid), itemsize);
		GetInventoryFreeSlots(playerid, freeslots);

		ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO", true), itemsize - freeslots), 3000, 150);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidItem(bag_CurrentBag[playerid]))
	{
		ClearAnimations(playerid);
		bag_CurrentBag[playerid] = INVALID_ITEM_ID;
		bag_LookingInBag[playerid] = -1;
	}
}

hook OnPlayerDropItem(playerid, Item:itemid)
{
	if(IsItemTypeBag(GetItemType(itemid)))
	{
		if(bag_TakingOffBag[playerid])
		{
			bag_TakingOffBag[playerid] = false;
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, Item:itemid)
{
	if(IsItemTypeBag(GetItemType(itemid)))
	{
		if(bag_TakingOffBag[playerid])
		{
			bag_TakingOffBag[playerid] = false;
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewInvOpt(playerid)
{
	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);
	if(IsValidItem(bag_PlayerBagID[playerid]) && !IsValidContainer(containerid))
	{
		bag_InventoryOptionID[playerid] = AddInventoryOption(playerid, "Move to bag");
	}
}

hook OnPlayerSelectInvOpt(playerid, option)
{
	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);
	if(IsValidItem(bag_PlayerBagID[playerid]) && !IsValidContainer(containerid))
	{
		if(option == bag_InventoryOptionID[playerid])
		{
			new
				slot,
				Item:itemid;
			
			GetItemArrayDataAtCell(bag_PlayerBagID[playerid], _:containerid, 1);
			slot = GetPlayerSelectedInventorySlot(playerid);
			GetInventorySlotItem(playerid, slot, itemid);

			if(!IsValidItem(itemid))
			{
				DisplayPlayerInventory(playerid);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			new required = AddItemToContainer(containerid, itemid, playerid);

			if(required > 0)
				ShowActionText(playerid, sprintf(ls(playerid, "BAGEXTRASLO", true), required), 3000, 150);

			DisplayPlayerInventory(playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewCntOpt(playerid, Container:containerid)
{
	new Container:bagcontainerid;
	GetItemArrayDataAtCell(bag_PlayerBagID[playerid], _:bagcontainerid, 1);
	if(IsValidItem(bag_PlayerBagID[playerid]) && containerid != bagcontainerid)
	{
		bag_InventoryOptionID[playerid] = AddContainerOption(playerid, "Move to bag");
	}
}

hook OnPlayerSelectCntOpt(playerid, Container:containerid, option)
{
	new Container:bagcontainerid;
	GetItemArrayDataAtCell(bag_PlayerBagID[playerid], _:bagcontainerid, 1);
	if(IsValidItem(bag_PlayerBagID[playerid]) && containerid != bagcontainerid)
	{
		if(option == bag_InventoryOptionID[playerid])
		{
			new
				slot,
				Item:itemid;

			GetPlayerContainerSlot(playerid, slot);
			GetContainerSlotItem(containerid, slot, itemid);

			if(!IsValidItem(itemid))
			{
				DisplayContainerInventory(playerid, containerid);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			new required = AddItemToContainer(bagcontainerid, itemid, playerid);

			if(required > 0)
				ShowActionText(playerid, sprintf(ls(playerid, "BAGEXTRASLO", true), required), 3000, 150);

			DisplayContainerInventory(playerid, containerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddToContainer(Container:containerid, Item:itemid, playerid)
{
	if(GetContainerBagItem(containerid) != INVALID_ITEM_ID)
	{
		if(IsItemTypeCarry(GetItemType(itemid)))
		{
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsItemTypeBag(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	return (bag_ItemTypeBagType[itemtype] != -1) ? (true) : (false);
}

stock GetItemBagType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	return bag_ItemTypeBagType[itemtype];
}

stock Item:GetPlayerBagItem(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return INVALID_ITEM_ID;

	return bag_PlayerBagID[playerid];
}

stock GetContainerPlayerBag(Container:containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_PLAYER_ID;

	return bag_ContainerPlayer[containerid];
}

stock Item:GetContainerBagItem(Container:containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_ITEM_ID;

	return bag_ContainerItem[containerid];
}

stock Container:GetBagItemContainerID(Item:itemid)
{
	if(!IsItemTypeBag(GetItemType(itemid)))
		return INVALID_CONTAINER_ID;

	new Container:containerid;
	GetItemArrayDataAtCell(itemid, _:containerid, 1);
	return containerid;
}
