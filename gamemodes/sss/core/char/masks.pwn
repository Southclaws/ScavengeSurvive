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


#define MAX_MASK_ITEMS	(22)
#define MAX_MASK_SKINS	(22)


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
			mask_Data[MAX_MASK_ITEMS][MAX_MASK_SKINS][E_MASK_SKIN_DATA],
   Iterator:mask_Index<MAX_MASK_ITEMS>,
			mask_CurrentMask[MAX_PLAYERS];


// Zeroing


hook OnPlayerConnect(playerid)
{
	mask_CurrentMask[playerid] = -1;
}

hook OnItemCreate(itemid)
{
	foreach(new i : mask_Index)
	{
		if(GetItemType(itemid) == mask_ItemType[i])
		{
			SetItemExtraData(itemid, i);
		}
	}
}


// Core


DefineMaskItem(ItemType:itemtype)
{
	new id = Iter_Free(mask_Index);

	mask_ItemType[id] = itemtype;

	Iter_Add(mask_Index, id);
	return id;
}

SetMaskOffsetsForSkin(maskid, skinid, Float:offsetx, Float:offsety, Float:offsetz, Float:rotx, Float:roty, Float:rotz, Float:scalex, Float:scaley, Float:scalez)
{
	if(!Iter_Contains(mask_Index, maskid))
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


stock SetPlayerMask(playerid, maskid)
{
	if(!Iter_Contains(mask_Index, maskid))
		return 0;

	new skinid = GetPlayerClothes(playerid);

	SetPlayerAttachedObject(
		playerid, ATTACHSLOT_FACE, GetItemTypeModel(mask_ItemType[maskid]), 2,
		mask_Data[maskid][skinid][mask_offsetX], mask_Data[maskid][skinid][mask_offsetY], mask_Data[maskid][skinid][mask_offsetZ],
		mask_Data[maskid][skinid][mask_rotX], mask_Data[maskid][skinid][mask_rotY], mask_Data[maskid][skinid][mask_rotZ],
		mask_Data[maskid][skinid][mask_scaleX], mask_Data[maskid][skinid][mask_scaleY], mask_Data[maskid][skinid][mask_scaleZ]);

	mask_CurrentMask[playerid] = maskid;

	return 1;
}

stock RemovePlayerMask(playerid)
{
	RemovePlayerAttachedObject(playerid, ATTACHSLOT_FACE);
	mask_CurrentMask[playerid] = -1;
}

TogglePlayerMask(playerid, bool:toggle)
{
	if(mask_CurrentMask[playerid] == -1)
		return 0;

	if(toggle)
	{
		new skinid = GetPlayerClothes(playerid);

		SetPlayerAttachedObject(
			playerid, ATTACHSLOT_FACE, GetItemTypeModel(mask_ItemType[mask_CurrentMask[playerid]]), 2,
			mask_Data[mask_CurrentMask[playerid]][skinid][mask_offsetX], mask_Data[mask_CurrentMask[playerid]][skinid][mask_offsetY], mask_Data[mask_CurrentMask[playerid]][skinid][mask_offsetZ],
			mask_Data[mask_CurrentMask[playerid]][skinid][mask_rotX], mask_Data[mask_CurrentMask[playerid]][skinid][mask_rotY], mask_Data[mask_CurrentMask[playerid]][skinid][mask_rotZ],
			mask_Data[mask_CurrentMask[playerid]][skinid][mask_scaleX], mask_Data[mask_CurrentMask[playerid]][skinid][mask_scaleY], mask_Data[mask_CurrentMask[playerid]][skinid][mask_scaleZ]);
	}
	else
	{
		RemovePlayerAttachedObject(playerid, ATTACHSLOT_FACE);
	}

	return 1;
}


// Hooks and Internal


public OnPlayerUseItem(playerid, itemid)
{
	if(mask_CurrentMask[playerid] == -1)
	{
		foreach(new i : mask_Index)
		{
			if(GetItemType(itemid) == mask_ItemType[i])
			{
				SetPlayerMask(playerid, i);
				DestroyItem(itemid);
				CancelPlayerMovement(playerid);
				break;
			}
		}
	}

	#if defined mask_OnPlayerUseItem
		return mask_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem mask_OnPlayerUseItem
#if defined mask_OnPlayerUseItem
	forward mask_OnPlayerUseItem(playerid, itemid);
#endif


// Interface


stock IsValidMask(maskid)
{
	if(!Iter_Contains(mask_Index, maskid))
		return 0;

	return 1;
}

forward ItemType:GetItemTypeFromMask(maskid);
stock ItemType:GetItemTypeFromMask(maskid)
{
	if(!Iter_Contains(mask_Index, maskid))
		return INVALID_ITEM_TYPE;

	return mask_ItemType[maskid];
}

stock GetMaskFromItem(ItemType:itemtype)
{
	foreach(new i : mask_Index)
	{
		if(mask_ItemType[i] == itemtype)
			return i;
	}
	return -1;
}

stock GetPlayerMask(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return -1;

	return mask_CurrentMask[playerid];
}
