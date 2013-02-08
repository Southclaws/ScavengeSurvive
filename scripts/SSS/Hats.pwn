#define MAX_HAT_ITEMS	(22)
#define MAX_HAT_SKINS	(22)


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
			hat_Data[MAX_HAT_ITEMS][MAX_HAT_SKINS][E_HAT_SKIN_DATA],
Iterator:	hat_Index<MAX_HAT_ITEMS>,
			hat_CurrentHat[MAX_PLAYERS];


// Zeroing


hook OnPlayerConnect(playerid)
{
	hat_CurrentHat[playerid] = -1;
}

public OnItemCreate(itemid)
{
	foreach(new i : hat_Index)
	{
		if(GetItemType(itemid) == hat_ItemType[i])
		{
			SetItemExtraData(itemid, i);
		}
	}

	return CallLocalFunction("hat_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate hat_OnItemCreate
forward hat_OnItemCreate(itemid);


// Core


DefineHatItem(ItemType:itemtype)
{
	new id = Iter_Free(hat_Index);

	hat_ItemType[id] = itemtype;

	Iter_Add(hat_Index, id);
	return id;
}

SetHatOffsetsForSkin(hatid, skinid, Float:offsetx, Float:offsety, Float:offsetz, Float:rotx, Float:roty, Float:rotz, Float:scalex, Float:scaley, Float:scalez)
{
	if(!Iter_Contains(hat_Index, hatid))
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


stock SetPlayerHat(playerid, hatid)
{
	if(!Iter_Contains(hat_Index, hatid))
		return 0;

	new skinid = GetPlayerClothes(playerid);

	SetPlayerAttachedObject(
		playerid, ATTACHSLOT_HAT, GetItemTypeModel(hat_ItemType[hatid]), 2,
		hat_Data[hatid][skinid][hat_offsetX], hat_Data[hatid][skinid][hat_offsetY], hat_Data[hatid][skinid][hat_offsetZ],
		hat_Data[hatid][skinid][hat_rotX], hat_Data[hatid][skinid][hat_rotY], hat_Data[hatid][skinid][hat_rotZ],
		hat_Data[hatid][skinid][hat_scaleX], hat_Data[hatid][skinid][hat_scaleY], hat_Data[hatid][skinid][hat_scaleZ]);

	hat_CurrentHat[playerid] = hatid;

	return 1;
}

stock RemovePlayerHat(playerid)
{
	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HAT);
	hat_CurrentHat[playerid] = -1;
}


// Hooks and Internal


public OnPlayerUseItem(playerid, itemid)
{
	foreach(new i : hat_Index)
	{
		if(GetItemType(itemid) == hat_ItemType[i])
		{
			SetPlayerHat(playerid, i);
			DestroyItem(itemid);
			CancelPlayerMovement(playerid);
			break;
		}
	}

	return CallLocalFunction("hat_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem hat_OnPlayerUseItem
forward hat_OnPlayerUseItem(playerid, itemid);


// Interface


stock IsValidHat(hatid)
{
	if(!Iter_Contains(hat_Index, hatid))
		return 0;

	return 1;
}

forward ItemType:GetItemTypeFromHat(hatid);
stock ItemType:GetItemTypeFromHat(hatid)
{
	if(!Iter_Contains(hat_Index, hatid))
		return INVALID_ITEM_TYPE;

	return hat_ItemType[hatid];
}

stock GetHatFromItem(ItemType:itemtype)
{
	foreach(new i : hat_Index)
	{
		if(hat_ItemType[i] == itemtype)
			return i;
	}
	return -1;
}

stock GetPlayerHat(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return -1;

	return hat_CurrentHat[playerid];
}
