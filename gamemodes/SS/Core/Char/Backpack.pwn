/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


#define MAX_BAG_TYPE (10)


enum E_BAG_TYPE_DATA
{
			bag_name[ITM_MAX_NAME],
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
			bag_ItemTypeBagType[ITM_MAX_TYPES] = {-1, ...};

static
			bag_ContainerItem		[CNT_MAX],
			bag_ContainerPlayer		[CNT_MAX];

static
			bag_PlayerBagID			[MAX_PLAYERS],
			bag_InventoryOptionID	[MAX_PLAYERS],
bool:		bag_PuttingInBag		[MAX_PLAYERS],
bool:		bag_TakingOffBag		[MAX_PLAYERS],
			bag_CurrentBag			[MAX_PLAYERS],
			bag_PickUpTick			[MAX_PLAYERS],
Timer:		bag_PickUpTimer			[MAX_PLAYERS],
Timer:		bag_OtherPlayerEnter	[MAX_PLAYERS],
			bag_LookingInBag		[MAX_PLAYERS];

static		HANDLER = -1;


forward OnPlayerWearBag(playerid, itemid);
forward OnPlayerRemoveBag(playerid, itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Backpack'...");

	HANDLER = debug_register_handler("char/backpack");

	for(new i; i < CNT_MAX; i++)
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


stock DefineBagType(name[ITM_MAX_NAME], ItemType:itemtype, size, Float:attachOffsetX, Float:attachOffsetY, Float:attachOffsetZ, Float:attachRotX, Float:attachRotY, Float:attachRotZ, Float:attachScaleX, Float:attachScaleY, Float:attachScaleZ)
{
	d:1:HANDLER("[DefineBagType] name:'%s' itemtype:%d size:%d", name, _:itemtype, size);

	if(bag_TypeTotal == MAX_BAG_TYPE)
		return -1;

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

stock GivePlayerBag(playerid, itemid)
{
	d:1:HANDLER("[GivePlayerBag] playerid:%d itemid:%d", playerid, itemid);

	if(!IsValidItem(itemid))
		return 0;

	new bagtype = bag_ItemTypeBagType[GetItemType(itemid)];

	if(bagtype != -1)
	{
		new containerid = GetItemArrayDataAtCell(itemid, 1);

		if(!IsValidContainer(containerid))
		{
			printf("[GivePlayerBag] ERROR: Bag (%d) container ID (%d) was invalid container has to be recreated.", itemid, containerid);

			containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

			SetItemArrayDataAtCell(itemid, containerid, 1);
		}

		new colour = GetItemTypeColour(bag_TypeData[bagtype][bag_itemtype]);

		bag_PlayerBagID[playerid] = itemid;

		SetPlayerAttachedObject(playerid, ATTACHSLOT_BAG, GetItemTypeModel(bag_TypeData[bagtype][bag_itemtype]), 1,
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

		return 1;
	}

	return 0;
}

stock RemovePlayerBag(playerid)
{
	d:1:HANDLER("[RemovePlayerBag] playerid:%d", playerid);

	if(!IsPlayerConnected(playerid))
		return 0;

	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	new containerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);

	if(!IsValidContainer(containerid))
	{
		new bagtype = bag_ItemTypeBagType[GetItemType(bag_PlayerBagID[playerid])];

		if(bagtype == -1)
		{
			printf("[RemovePlayerBag] ERROR: Player (%d) bag item type (%d) is not a valid bag type.", playerid, bagtype);
			return 0;
		}

		printf("[RemovePlayerBag] ERROR: Bag (%d) container ID (%d) was invalid container has to be recreated.", bag_PlayerBagID[playerid], containerid);

		containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

		SetItemArrayDataAtCell(bag_PlayerBagID[playerid], containerid, 1);
	}

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	CreateItemInWorld(bag_PlayerBagID[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));

	bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;

	return 1;
}

stock DestroyPlayerBag(playerid)
{
	d:1:HANDLER("[DestroyPlayerBag] playerid:%d", playerid);

	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	new containerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);

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
stock AddItemToPlayer(playerid, itemid, useinventory = false, playeraction = true)
{
	d:1:HANDLER("[AddItemToPlayer] itemid %d playerid %d useinventory %d playeraction %d", itemid, playerid, useinventory, playeraction);

	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeCarry(itemtype))
		return -1;

	if(WillItemTypeFitInInventory(playerid, itemtype))
	{
		d:1:HANDLER("[AddItemToPlayer] Item fits in inventory");
		if(useinventory)
			AddItemToInventory(playerid, itemid);

		return -2;
	}

	new containerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);

	if(!IsValidContainer(containerid))
		return -3;

	new
		itemsize = GetItemTypeSize(GetItemType(itemid)),
		freeslots = GetContainerFreeSlots(containerid);

	if(itemsize > freeslots)
	{
		ShowActionText(playerid, sprintf("Extra %d bag slots required", itemsize - freeslots), 3000, 150);
		return -4;
	}

	if(playeraction)
	{
		ShowActionText(playerid, "Item added to bag", 3000, 150);
		ApplyAnimation(playerid, "PED", "PHONE_IN", 4.0, 1, 0, 0, 0, 300);
		bag_PuttingInBag[playerid] = true;
		defer bag_PutItemIn(playerid, itemid, containerid);
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

public OnItemCreate(itemid)
{
	new bagtype = bag_ItemTypeBagType[GetItemType(itemid)];

	if(bagtype != -1)
	{
		d:2:HANDLER("[OnItemCreate] itemid:%d itemtype:%d bagtype:%d", itemid, _:GetItemType(itemid), bagtype);

		new
			containerid,
			lootindex = GetItemLootIndex(itemid);

		containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

		bag_ContainerItem[containerid] = itemid;
		bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;

		SetItemArrayDataSize(itemid, 2);
		SetItemArrayDataAtCell(itemid, containerid, 1);

		if(lootindex != -1)
		{
			if(!IsValidContainer(GetItemContainer(itemid)))
				FillContainerWithLoot(containerid, random(4), lootindex);
		}
	}

	#if defined bag_OnItemCreate
		return bag_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate bag_OnItemCreate
#if defined bag_OnItemCreate
	forward bag_OnItemCreate(itemid);
#endif

public OnItemCreateInWorld(itemid)
{
	if(IsItemTypeBag(GetItemType(itemid)))
	{
		SetButtonText(GetItemButtonID(itemid), "Hold "KEYTEXT_INTERACT" to pick up~n~Press "KEYTEXT_INTERACT" to open");
	}

	#if defined bag_OnItemCreateInWorld
		return bag_OnItemCreateInWorld(itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemCreateInWorld
	#undef OnItemCreateInWorld
#else
	#define _ALS_OnItemCreateInWorld
#endif
#define OnItemCreateInWorld bag_OnItemCreateInWorld
#if defined bag_OnItemCreateInWorld
	forward bag_OnItemCreateInWorld(itemid);
#endif

public OnItemDestroy(itemid)
{
	if(IsItemTypeBag(GetItemType(itemid)))
	{
		new containerid = GetItemArrayDataAtCell(itemid, 1);

		if(IsValidContainer(containerid))
		{
			bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
			bag_ContainerItem[containerid] = INVALID_ITEM_ID;
			DestroyContainer(containerid);
		}
	}

	#if defined bag_OnItemDestroy
		return bag_OnItemDestroy(itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemDestroy
	#undef OnItemDestroy
#else
	#define _ALS_OnItemDestroy
#endif
#define OnItemDestroy bag_OnItemDestroy
#if defined bag_OnItemDestroy
	forward bag_OnItemDestroy(itemid);
#endif

public OnPlayerPickUpItem(playerid, itemid)
{
	if(BagInteractionCheck(playerid, itemid))
		return 1;

	#if defined bag_OnPlayerPickUpItem
		return bag_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem bag_OnPlayerPickUpItem
#if defined bag_OnPlayerPickUpItem
	forward bag_OnPlayerPickUpItem(playerid, itemid);
#endif

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(BagInteractionCheck(playerid, withitemid))
		return 1;

	#if defined bag_OnPlayerUseItemWithItem
		return bag_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem bag_OnPlayerUseItemWithItem
#if defined bag_OnPlayerUseItemWithItem
	forward bag_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif

BagInteractionCheck(playerid, itemid)
{
	d:1:HANDLER("[BagInteractionCheck] playerid:%d itemid:%d", playerid, itemid);

	if(IsItemTypeBag(GetItemType(itemid)))
	{
		d:2:HANDLER("[BagInteractionCheck] is bag, itemtype:%d bagtype:%d", _:GetItemType(itemid), bag_ItemTypeBagType[GetItemType(itemid)]);

		stop bag_PickUpTimer[playerid];
		bag_PickUpTimer[playerid] = defer bag_PickUp(playerid, itemid);

		bag_PickUpTick[playerid] = GetTickCount();
		bag_CurrentBag[playerid] = itemid;

		return 1;
	}

	return 0;
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

	if(oldkeys & 16)
	{
		_BagReleaseInteractHandler(playerid);
	}

	return 1;
}

_BagEquipHandler(playerid)
{
	new itemid = GetPlayerItem(playerid);

	if(!IsValidItem(itemid))
		return 0;

	if(bag_PuttingInBag[playerid])
		return 0;

	if(GetTickCountDifference(GetTickCount(), GetPlayerLastHolsterTick(playerid)) < 1000)
		return 0;

	new ItemType:itemtype = GetItemType(itemid);

	if(!IsValidItem(bag_PlayerBagID[playerid]))
	{
		if(IsItemTypeBag(itemtype))
		{
			if(CallLocalFunction("OnPlayerWearBag", "dd", playerid, itemid))
				return 0;

			GivePlayerBag(playerid, itemid);
		}

		return 1;
	}

	if(IsItemTypeBag(itemtype))
	{
		new currentbagitem = bag_PlayerBagID[playerid];

		RemovePlayerBag(playerid);
		GivePlayerBag(playerid, itemid);
		GiveWorldItemToPlayer(playerid, currentbagitem, 1);
		return 0;
	}

	AddItemToPlayer(playerid, itemid);

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

	if(CallLocalFunction("OnPlayerRemoveBag", "dd", playerid, bag_PlayerBagID[playerid]))
		return 0;

	new containerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);

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
		if(IsPlayerInPlayerArea(playerid, i))
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

_BagReleaseInteractHandler(playerid)
{
	stop bag_OtherPlayerEnter[playerid];

	if(GetTickCountDifference(GetTickCount(), bag_PickUpTick[playerid]) < 200)
	{
		if(IsValidItem(bag_CurrentBag[playerid]))
		{
			d:1:HANDLER("[_BagReleaseInteractHandler] Current bag item %d is valid", bag_CurrentBag[playerid]);
			DisplayContainerInventory(playerid, GetItemArrayDataAtCell(bag_CurrentBag[playerid], 1));
			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);
			stop bag_PickUpTimer[playerid];
			bag_PickUpTick[playerid] = 0;
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
	bag_PuttingInBag[playerid] = false;
}

timer bag_EnterOtherPlayer[250](playerid, targetid)
{
	d:1:HANDLER("[bag_EnterOtherPlayer] playerid:%d targetid:%d", playerid, targetid);
	CancelPlayerMovement(playerid);
	DisplayContainerInventory(playerid, GetItemArrayDataAtCell(bag_PlayerBagID[targetid], 1));
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

public OnPlayerAddToInventory(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeBag(itemtype))
		return 1;

	if(IsItemTypeCarry(itemtype))
		return 1;

	#if defined bag_OnPlayerAddToInventory
		return bag_OnPlayerAddToInventory(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerAddToInventory
	#undef OnPlayerAddToInventory
#else
	#define _ALS_OnPlayerAddToInventory
#endif
#define OnPlayerAddToInventory bag_OnPlayerAddToInventory
#if defined bag_OnPlayerAddToInventory
	forward bag_OnPlayerAddToInventory(playerid, itemid);
#endif

public OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidItem(bag_CurrentBag[playerid]))
	{
		ClearAnimations(playerid);
		bag_CurrentBag[playerid] = INVALID_ITEM_ID;
		bag_LookingInBag[playerid] = -1;
	}

	#if defined bag_OnPlayerCloseContainer
		return bag_OnPlayerCloseContainer(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer bag_OnPlayerCloseContainer
#if defined bag_OnPlayerCloseContainer
	forward bag_OnPlayerCloseContainer(playerid, containerid);
#endif

public OnPlayerUseItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeBag(itemtype))
	{
		d:1:HANDLER("[OnPlayerUseItem] Item %d type %d is bag type %d", itemid, _:GetItemType(itemid), bag_ItemTypeBagType[GetItemType(itemid)]);
		CancelPlayerMovement(playerid);
		DisplayContainerInventory(playerid, GetItemArrayDataAtCell(itemid, 1));
	}

	#if defined bag_OnPlayerUseItem
		return bag_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem bag_OnPlayerUseItem
#if defined bag_OnPlayerUseItem
	forward bag_OnPlayerUseItem(playerid, itemid);
#endif

public OnPlayerDropItem(playerid, itemid)
{
	if(IsItemTypeBag(GetItemType(itemid)))
	{
		if(bag_TakingOffBag[playerid])
		{
			bag_TakingOffBag[playerid] = false;
			return 1;
		}
	}

	#if defined bag_OnPlayerDropItem
		return bag_OnPlayerDropItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem bag_OnPlayerDropItem
#if defined bag_OnPlayerDropItem
	forward bag_OnPlayerDropItem(playerid, itemid);
#endif

public OnPlayerGiveItem(playerid, targetid, itemid)
{
	if(IsItemTypeBag(GetItemType(itemid)))
	{
		if(bag_TakingOffBag[playerid])
		{
			bag_TakingOffBag[playerid] = false;
			return 1;
		}
	}

	#if defined bag_OnPlayerGiveItem
		return bag_OnPlayerGiveItem(playerid, targetid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerGiveItem
	#undef OnPlayerGiveItem
#else
	#define _ALS_OnPlayerGiveItem
#endif
#define OnPlayerGiveItem bag_OnPlayerGiveItem
#if defined bag_OnPlayerGiveItem
	forward bag_OnPlayerGiveItem(playerid, targetid, itemid);
#endif

public OnPlayerViewInventoryOpt(playerid)
{
	if(IsValidItem(bag_PlayerBagID[playerid]) && !IsValidContainer(GetPlayerCurrentContainer(playerid)))
	{
		bag_InventoryOptionID[playerid] = AddInventoryOption(playerid, "Move to bag");
	}

	#if defined bag_OnPlayerViewInventoryOpt
		return bag_OnPlayerViewInventoryOpt(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerViewInventoryOpt
	#undef OnPlayerViewInventoryOpt
#else
	#define _ALS_OnPlayerViewInventoryOpt
#endif
#define OnPlayerViewInventoryOpt bag_OnPlayerViewInventoryOpt
#if defined bag_OnPlayerViewInventoryOpt
	forward bag_OnPlayerViewInventoryOpt(playerid);
#endif

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
			
			containerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);
			slot = GetPlayerSelectedInventorySlot(playerid);
			itemid = GetInventorySlotItem(playerid, slot);

			if(!IsValidItem(itemid))
			{
				DisplayPlayerInventory(playerid);
				return 0;
			}

			new required = AddItemToContainer(containerid, itemid, playerid);

			if(required > 0)
				ShowActionText(playerid, sprintf("Extra %d slots required", required), 3000, 150);

			DisplayPlayerInventory(playerid);
		}
	}

	#if defined bag_PlayerSelectInventoryOption
		return bag_PlayerSelectInventoryOption(playerid, option);
	#else
		return 0;
	#endif
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
	if(IsValidItem(bag_PlayerBagID[playerid]) && containerid != GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1))
	{
		bag_InventoryOptionID[playerid] = AddContainerOption(playerid, "Move to bag");
	}

	#if defined bag_OnPlayerViewContainerOpt
		return bag_OnPlayerViewContainerOpt(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt bag_OnPlayerViewContainerOpt
#if defined bag_OnPlayerViewContainerOpt
	forward bag_OnPlayerViewContainerOpt(playerid, containerid);
#endif

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	if(IsValidItem(bag_PlayerBagID[playerid]) && containerid != GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1))
	{
		if(option == bag_InventoryOptionID[playerid])
		{
			new
				bagcontainerid,
				slot,
				itemid;

			bagcontainerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);
			slot = GetPlayerContainerSlot(playerid);
			itemid = GetContainerSlotItem(containerid, slot);

			if(!IsValidItem(itemid))
			{
				DisplayContainerInventory(playerid, containerid);
				return 0;
			}

			new required = AddItemToContainer(bagcontainerid, itemid, playerid);

			if(required > 0)
				ShowActionText(playerid, sprintf("Extra %d slots required", required), 3000, 150);

			DisplayContainerInventory(playerid, containerid);
		}
	}

	#if defined bag_OnPlayerSelectContainerOpt
		return bag_OnPlayerSelectContainerOpt(playerid, containerid, option);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt bag_OnPlayerSelectContainerOpt
#if defined bag_OnPlayerSelectContainerOpt
	forward bag_OnPlayerSelectContainerOpt(playerid, containerid, option);
#endif

public OnItemAddToContainer(containerid, itemid, playerid)
{
	d:1:HANDLER("[OnItemAddToContainer] containerid %d itemid %d playerid %d", containerid, itemid, playerid);
	if(GetContainerBagItem(containerid) != INVALID_ITEM_ID)
	{
		d:1:HANDLER("[OnItemAddToContainer] Container is a bag");
		if(IsItemTypeCarry(GetItemType(itemid)))
		{
			d:1:HANDLER("[OnItemAddToContainer] Item is carry, cancel adding");
			return 1;
		}
	}

	#if defined bag_OnItemAddToContainer
		return bag_OnItemAddToContainer(containerid, itemid, playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemAddToContainer
	#undef OnItemAddToContainer
#else
	#define _ALS_OnItemAddToContainer
#endif
 
#define OnItemAddToContainer bag_OnItemAddToContainer
#if defined bag_OnItemAddToContainer
	forward bag_OnItemAddToContainer(containerid, itemid, playerid);
#endif


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

stock GetPlayerBagItem(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return INVALID_ITEM_ID;

	return bag_PlayerBagID[playerid];
}

stock GetContainerPlayerBag(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_PLAYER_ID;

	return bag_ContainerPlayer[containerid];
}

stock GetContainerBagItem(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_ITEM_ID;

	return bag_ContainerItem[containerid];
}

stock GetBagItemContainerID(itemid)
{
	if(!IsItemTypeBag(GetItemType(itemid)))
		return INVALID_CONTAINER_ID;

	return GetItemArrayDataAtCell(itemid, 1);
}

public OnPlayerWearBag(playerid, itemid)
{
	// Temp fix for circular dependency.

	#if defined bag_OnPlayerWearBag
		return bag_OnPlayerWearBag(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerWearBag
	#undef OnPlayerWearBag
#else
	#define _ALS_OnPlayerWearBag
#endif
 
#define OnPlayerWearBag bag_OnPlayerWearBag
#if defined bag_OnPlayerWearBag
	forward bag_OnPlayerWearBag(playerid, itemid);
#endif
