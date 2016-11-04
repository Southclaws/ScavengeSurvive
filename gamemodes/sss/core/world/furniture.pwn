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
		fur_ItemTypeFurnitureType[ITM_MAX_TYPES] = {-1, ...};


stock DefineItemTypeFurniture(ItemType:itemtype, Float:px, Float:py, Float:pz, Float:rx, Float:ry, Float:rz)
{
	fur_Data[fur_Total][fur_itemPosX] = px;
	fur_Data[fur_Total][fur_itemPosY] = py;
	fur_Data[fur_Total][fur_itemPosZ] = pz;
	fur_Data[fur_Total][fur_itemRotX] = rx;
	fur_Data[fur_Total][fur_itemRotY] = ry;
	fur_Data[fur_Total][fur_itemRotZ] = rz;

	fur_ItemTypeFurnitureType[itemtype] = fur_Total;

	return fur_Total++;
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(fur_ItemTypeFurnitureType[GetItemType(itemid)] != -1)
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
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
		Float:rz;

	GetItemPos(withitemid, x, y, z);
	GetItemRot(withitemid, rx, ry, rz);

	x += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemPosX];
	y += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemPosY];
	z += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemPosZ];
	ry += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemRotX];
	rx += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemRotY];
	rz += fur_Data[fur_ItemTypeFurnitureType[itemtype]][fur_itemRotZ];

	CreateItemInWorld(itemid, x, y, z, rx, ry, rz);

	return Y_HOOKS_CONTINUE_RETURN_0;
}
