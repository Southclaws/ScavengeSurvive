/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_FURNITURE_TYPES (10)


enum e_FURNITURE_TYPE_DATA
{
Float:	fur_itemPosX,
Float:	fur_itemPosY,
Float:	fur_itemPosZ,
Float:	fur_itemRotX,
Float:	fur_itemRotY,
Float:	fur_itemRotZ
}

static
		fur_Data[MAX_FURNITURE_TYPES][e_FURNITURE_TYPE_DATA],
		fur_Total,
		fur_ItemTypeFurnitureType[MAX_ITEM_TYPE] = {-1, ...};


stock DefineItemTypeFurniture(ItemType:itemtype, Float:px, Float:py, Float:pz, Float:rx, Float:ry, Float:rz)
{
	SetItemTypeMaxArrayData(itemtype, 2);

	fur_Data[fur_Total][fur_itemPosX] = px;
	fur_Data[fur_Total][fur_itemPosY] = py;
	fur_Data[fur_Total][fur_itemPosZ] = pz;
	fur_Data[fur_Total][fur_itemRotX] = rx;
	fur_Data[fur_Total][fur_itemRotY] = ry;
	fur_Data[fur_Total][fur_itemRotZ] = rz;

	fur_ItemTypeFurnitureType[itemtype] = fur_Total;

	return fur_Total++;
}

hook OnItemCreate(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(fur_ItemTypeFurnitureType[itemtype] != -1)
	{
		if(IsItemTypeSafebox(itemtype))
			SetItemArrayDataAtCell(itemid, INVALID_OBJECT_ID, 1, true);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(fur_ItemTypeFurnitureType[GetItemType(itemid)] != -1)
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	new ItemType:itemtype = GetItemType(withitemid);

	if(fur_ItemTypeFurnitureType[itemtype] == -1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:ry,
		Float:rx,
		Float:rz,
		Container:containerid;

	GetItemPos(withitemid, x, y, z);
	GetItemRot(withitemid, rx, ry, rz);
	GetItemArrayDataAtCell(withitemid, _:containerid, 0);

	x += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemPosX];
	y += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemPosY];
	z += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemPosZ];
	ry += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemRotX];
	rx += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemRotY];
	rz += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemRotZ];

	if(IsItemTypeSafebox(itemtype))
	{
		if(IsValidContainer(containerid))
		{
			new objectid;
			GetItemArrayDataAtCell(withitemid, objectid, 1);
			if(!IsValidDynamicObject(objectid))
			{
				new
					ItemType:helditemtype = GetItemType(itemid),
					Float:ox,
					Float:oy,
					Float:oz;

				GetItemTypeRotation(helditemtype, ox, oy, oz);

				new required = AddItemToContainer(containerid, itemid);

				if(required > 0)
				{
					ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO", true), required), 3000, 150);
				}
				else if(required == 0)
				{
					new world, interior, model;
					GetItemWorld(withitemid, world);
					GetItemInterior(withitemid, interior);
					GetItemTypeModel(helditemtype, model);

					objectid = CreateDynamicObject(model, x, y, z, rx + ox, ry + oy, rz + oz, world, interior);
					SetItemArrayDataAtCell(withitemid, objectid, 1, true);
					RemoveCurrentItem(playerid);
				}
			}
		}
	}
	else
	{
		CreateItemInWorld(itemid, x, y, z, rx, ry, rz);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(fur_ItemTypeFurnitureType[itemtype] == -1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(!IsItemTypeSafebox(itemtype))
		return Y_HOOKS_CONTINUE_RETURN_0;

	new Container:containerid;
	GetItemArrayDataAtCell(itemid, _:containerid, 0);

	if(!IsValidContainer(containerid))
		return Y_HOOKS_CONTINUE_RETURN_0;

	new Item:subitem;
	GetContainerSlotItem(containerid, 0, subitem);

	if(!IsValidItem(subitem))
		return Y_HOOKS_CONTINUE_RETURN_0;

	new objectid;
	GetItemArrayDataAtCell(itemid, objectid, 1);

	DestroyDynamicObject(objectid);

	RemoveItemFromContainer(containerid, 0);
	GiveWorldItemToPlayer(playerid, subitem);
	SetItemArrayDataAtCell(itemid, INVALID_OBJECT_ID, 1, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}
