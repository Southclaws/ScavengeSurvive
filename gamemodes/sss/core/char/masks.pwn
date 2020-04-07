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


#include <YSI_Coding\y_hooks>


#define MAX_MASK_ITEMS	(32)


enum E_MASK_SKIN_DATA
{
Float:		mask_offsetX,
Float:		mask_offsetY,
Float:		mask_offsetZ,
Float:		mask_rotX,
Float:		mask_rotY,
Float:		mask_rotZ,
Float:		mask_scaleX,
Float:		mask_scaleY,
Float:		mask_scaleZ
}


new
ItemType:	mask_ItemType[MAX_MASK_ITEMS],
			mask_Data[MAX_MASK_ITEMS][MAX_SKINS][E_MASK_SKIN_DATA],
			mask_Total,
			mask_ItemTypeMask[ITM_MAX_TYPES] = {-1, ...},
			mask_CurrentMaskItem[MAX_PLAYERS];


// Zeroing


hook OnPlayerConnect(playerid)
{
	mask_CurrentMaskItem[playerid] = -1;
}


// Core


stock DefineMaskItem(ItemType:itemtype)
{
	mask_ItemType[mask_Total] = itemtype;
	mask_ItemTypeMask[itemtype] = mask_Total;

	return mask_Total++;
}

stock SetMaskOffsetsForSkin(maskid, skinid, Float:offsetx, Float:offsety, Float:offsetz, Float:rotx, Float:roty, Float:rotz, Float:scalex, Float:scaley, Float:scalez)
{
	if(!(0 <= maskid < mask_Total))
		return 0;

	mask_Data[maskid][skinid][mask_offsetX] = offsetx;
	mask_Data[maskid][skinid][mask_offsetY] = offsety;
	mask_Data[maskid][skinid][mask_offsetZ] = offsetz;
	mask_Data[maskid][skinid][mask_rotX] = rotx;
	mask_Data[maskid][skinid][mask_rotY] = roty;
	mask_Data[maskid][skinid][mask_rotZ] = rotz;
	mask_Data[maskid][skinid][mask_scaleX] = scalex;
	mask_Data[maskid][skinid][mask_scaleY] = scaley;
	mask_Data[maskid][skinid][mask_scaleZ] = scalez;

	return 1;
}


stock SetPlayerMaskItem(playerid, itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	new ItemType:itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
		return 0;

	new maskid = mask_ItemTypeMask[itemtype];

	if(maskid == -1)
		return 0;

	new skinid = GetPlayerClothes(playerid);

	if(!GetClothesMaskStatus(skinid))
		return 0;

	SetPlayerAttachedObject(
		playerid, ATTACHSLOT_FACE, GetItemTypeModel(itemtype), 2,
		mask_Data[maskid][skinid][mask_offsetX], mask_Data[maskid][skinid][mask_offsetY], mask_Data[maskid][skinid][mask_offsetZ],
		mask_Data[maskid][skinid][mask_rotX], mask_Data[maskid][skinid][mask_rotY], mask_Data[maskid][skinid][mask_rotZ],
		mask_Data[maskid][skinid][mask_scaleX], mask_Data[maskid][skinid][mask_scaleY], mask_Data[maskid][skinid][mask_scaleZ]);

	RemoveItemFromWorld(itemid);
	RemoveCurrentItem(GetItemHolder(itemid));
	mask_CurrentMaskItem[playerid] = itemid;

	return 1;
}

stock RemovePlayerMaskItem(playerid)
{
	new itemid = mask_CurrentMaskItem[playerid];

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_FACE);
	mask_CurrentMaskItem[playerid] = -1;

	return itemid;
}

stock TogglePlayerMaskItemVisibility(playerid, bool:toggle)
{
	if(!IsValidItem(mask_CurrentMaskItem[playerid]))
		return 0;

	if(toggle)
	{
		new ItemType:itemtype = GetItemType(mask_CurrentMaskItem[playerid]);

		if(!IsValidItemType(itemtype))
			return 0;

		new maskid = mask_ItemTypeMask[itemtype];

		if(maskid == -1)
			return 0;

		new skinid = GetPlayerClothes(playerid);

		SetPlayerAttachedObject(
			playerid, ATTACHSLOT_FACE, GetItemTypeModel(itemtype), 2,
			mask_Data[maskid][skinid][mask_offsetX], mask_Data[maskid][skinid][mask_offsetY], mask_Data[maskid][skinid][mask_offsetZ],
			mask_Data[maskid][skinid][mask_rotX], mask_Data[maskid][skinid][mask_rotY], mask_Data[maskid][skinid][mask_rotZ],
			mask_Data[maskid][skinid][mask_scaleX], mask_Data[maskid][skinid][mask_scaleY], mask_Data[maskid][skinid][mask_scaleZ]);
	}
	else
	{
		RemovePlayerAttachedObject(playerid, ATTACHSLOT_FACE);
	}

	return 1;
}


// Hooks and Internal


hook OnPlayerUseItem(playerid, itemid)
{
	if(SetPlayerMaskItem(playerid, itemid))
		CancelPlayerMovement(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}


// Interface


stock IsValidMask(maskid)
{
	if(!(0 <= maskid < mask_Total))
		return 0;

	return 1;
}

forward ItemType:GetItemTypeFromMask(maskid);
stock ItemType:GetItemTypeFromMask(maskid)
{
	if(!(0 <= maskid < mask_Total))
		return INVALID_ITEM_TYPE;

	return mask_ItemType[maskid];
}

stock GetMaskFromItem(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	return mask_ItemTypeMask[itemtype];
}

stock GetPlayerMaskItem(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_ITEM_ID;

	return mask_CurrentMaskItem[playerid];
}
