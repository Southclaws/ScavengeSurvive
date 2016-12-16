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


#define MAX_HAT_ITEMS	(32)


enum E_HAT_SKIN_DATA
{
Float:		hat_offsetX,
Float:		hat_offsetY,
Float:		hat_offsetZ,
Float:		hat_rotX,
Float:		hat_rotY,
Float:		hat_rotZ,
Float:		hat_scaleX,
Float:		hat_scaleY,
Float:		hat_scaleZ
}


new
ItemType:	hat_ItemType[MAX_HAT_ITEMS],
			hat_Data[MAX_HAT_ITEMS][MAX_SKINS][E_HAT_SKIN_DATA],
			hat_Total,
			hat_ItemTypeHat[ITM_MAX_TYPES] = {-1, ...},
			hat_CurrentHatItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


// Zeroing


hook OnPlayerConnect(playerid)
{
	hat_CurrentHatItem[playerid] = INVALID_ITEM_ID;
}


// Core


stock DefineHatItem(ItemType:itemtype)
{
	hat_ItemType[hat_Total] = itemtype;
	hat_ItemTypeHat[itemtype] = hat_Total;

	return hat_Total++;
}

stock SetHatOffsetsForSkin(hatid, skinid, Float:offsetx, Float:offsety, Float:offsetz, Float:rotx, Float:roty, Float:rotz, Float:scalex, Float:scaley, Float:scalez)
{
	if(!(0 <= hatid < hat_Total))
		return 0;

	hat_Data[hatid][skinid][hat_offsetX] = offsetx;
	hat_Data[hatid][skinid][hat_offsetY] = offsety;
	hat_Data[hatid][skinid][hat_offsetZ] = offsetz;
	hat_Data[hatid][skinid][hat_rotX] = rotx;
	hat_Data[hatid][skinid][hat_rotY] = roty;
	hat_Data[hatid][skinid][hat_rotZ] = rotz;
	hat_Data[hatid][skinid][hat_scaleX] = scalex;
	hat_Data[hatid][skinid][hat_scaleY] = scaley;
	hat_Data[hatid][skinid][hat_scaleZ] = scalez;

	return 1;
}


stock SetPlayerHatItem(playerid, itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	new ItemType:itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
		return 0;

	new hatid = hat_ItemTypeHat[itemtype];

	if(hatid == -1)
		return 0;

	new skinid = GetPlayerClothes(playerid);

	if(!GetClothesHatStatus(skinid))
		return 0;

	SetPlayerAttachedObject(
		playerid, ATTACHSLOT_HAT, GetItemTypeModel(itemtype), 2,
		hat_Data[hatid][skinid][hat_offsetX], hat_Data[hatid][skinid][hat_offsetY], hat_Data[hatid][skinid][hat_offsetZ],
		hat_Data[hatid][skinid][hat_rotX], hat_Data[hatid][skinid][hat_rotY], hat_Data[hatid][skinid][hat_rotZ],
		hat_Data[hatid][skinid][hat_scaleX], hat_Data[hatid][skinid][hat_scaleY], hat_Data[hatid][skinid][hat_scaleZ]);

	RemoveItemFromWorld(itemid);
	RemoveCurrentItem(GetItemHolder(itemid));
	hat_CurrentHatItem[playerid] = itemid;

	return 1;
}

stock RemovePlayerHatItem(playerid)
{
	new itemid = hat_CurrentHatItem[playerid];

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HAT);
	hat_CurrentHatItem[playerid] = INVALID_ITEM_ID;

	return itemid;
}

stock TogglePlayerHatItemVisibility(playerid, bool:toggle)
{
	if(!IsValidItem(hat_CurrentHatItem[playerid]))
		return 0;

	if(toggle)
	{
		new ItemType:itemtype = GetItemType(hat_CurrentHatItem[playerid]);

		if(!IsValidItemType(itemtype))
			return 0;

		new hatid = hat_ItemTypeHat[itemtype];

		if(hatid == -1)
			return 0;

		new skinid = GetPlayerClothes(playerid);

		SetPlayerAttachedObject(
			playerid, ATTACHSLOT_HAT, GetItemTypeModel(itemtype), 2,
			hat_Data[hatid][skinid][hat_offsetX], hat_Data[hatid][skinid][hat_offsetY], hat_Data[hatid][skinid][hat_offsetZ],
			hat_Data[hatid][skinid][hat_rotX], hat_Data[hatid][skinid][hat_rotY], hat_Data[hatid][skinid][hat_rotZ],
			hat_Data[hatid][skinid][hat_scaleX], hat_Data[hatid][skinid][hat_scaleY], hat_Data[hatid][skinid][hat_scaleZ]);
	}
	else
	{
		RemovePlayerAttachedObject(playerid, ATTACHSLOT_HAT);
	}

	return 1;
}


// Hooks and Internal


hook OnPlayerUseItem(playerid, itemid)
{
	if(SetPlayerHatItem(playerid, itemid))
		CancelPlayerMovement(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}


// Interface


stock IsValidHat(hatid)
{
	if(!(0 <= hatid < hat_Total))
		return 0;

	return 1;
}

forward ItemType:GetItemTypeFromHat(hatid);
stock ItemType:GetItemTypeFromHat(hatid)
{
	if(!(0 <= hatid < hat_Total))
		return INVALID_ITEM_TYPE;

	return hat_ItemType[hatid];
}

stock GetHatFromItem(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	return hat_ItemTypeHat[itemtype];
}

stock GetPlayerHatItem(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_ITEM_ID;

	return hat_CurrentHatItem[playerid];
}
