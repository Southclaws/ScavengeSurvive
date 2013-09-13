#include <YSI\y_hooks>


#define MAX_HOLSTER_ITEM_TYPES	(64)


enum E_HOLSTER_TYPE_DATA
{
ItemType:	hols_itemType,
			hols_boneId,
Float:		hols_offsetPosX,
Float:		hols_offsetPosY,
Float:		hols_offsetPosZ,
Float:		hols_offsetRotX,
Float:		hols_offsetRotY,
Float:		hols_offsetRotZ,
			hols_time,
			hols_animLib[32],
			hols_animName[32]
}


new
			hols_TypeData[MAX_HOLSTER_ITEM_TYPES][E_HOLSTER_TYPE_DATA],
			hols_Total,
			hols_Item[MAX_PLAYERS],
			hols_LastHolster[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	hols_Item[playerid] = INVALID_ITEM_ID;
}

SetItemTypeHolsterable(ItemType:itemtype, boneid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, animtime, animlib[32], animname[32])
{
	if(hols_Total >= MAX_HOLSTER_ITEM_TYPES)
		return -1;

	hols_TypeData[hols_Total][hols_itemType] = itemtype;
	hols_TypeData[hols_Total][hols_boneId] = boneid;
	hols_TypeData[hols_Total][hols_offsetPosX] = x;
	hols_TypeData[hols_Total][hols_offsetPosY] = y;
	hols_TypeData[hols_Total][hols_offsetPosZ] = z;
	hols_TypeData[hols_Total][hols_offsetRotX] = rx;
	hols_TypeData[hols_Total][hols_offsetRotY] = ry;
	hols_TypeData[hols_Total][hols_offsetRotZ] = rz;
	hols_TypeData[hols_Total][hols_time] = animtime;
	hols_TypeData[hols_Total][hols_animLib] = animlib;
	hols_TypeData[hols_Total][hols_animName] = animname;

	return hols_Total++;
}

SetPlayerHolsterItem(playerid, itemid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!IsValidItem(itemid))
		return 0;

	new id;

	while(id < hols_Total)
	{
		if(hols_TypeData[id][hols_itemType] == GetItemType(itemid))
			break;

		id++;
	}

	SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, GetItemTypeModel(GetItemType(itemid)),
		hols_TypeData[id][hols_boneId],
		hols_TypeData[id][hols_offsetPosX],
		hols_TypeData[id][hols_offsetPosY],
		hols_TypeData[id][hols_offsetPosZ],
		hols_TypeData[id][hols_offsetRotX],
		hols_TypeData[id][hols_offsetRotY],
		hols_TypeData[id][hols_offsetRotZ],
		1.0, 1.0, 1.0);

	hols_Item[playerid] = itemid;

	return 1;
}

GetPlayerHolsterItem(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return hols_Item[playerid];
}

RemovePlayerHolsterItem(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER);
	hols_Item[playerid] = INVALID_ITEM_ID;

	return 1;
}

GetPlayerWeaponSwapTick(playerid)
{
	return hols_LastHolster[playerid];
}

CanItemTypeBeHolstered(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	new id;

	while(id < hols_Total)
	{
		if(hols_TypeData[id][hols_itemType] == itemtype)
			return 1;

		id++;
	}

	return 0;
}


// Internal


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || gPlayerBitData[playerid] & AdminDuty || gPlayerBitData[playerid] & KnockedOut || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	if(newkeys & KEY_YES)
	{
		if(GetTickCountDifference(tickcount(), hols_LastHolster[playerid]) < 1000)
			return 1;

		if(!IsPlayerIdle(playerid))
			return 1;

		new weaponid = GetPlayerCurrentWeapon(playerid);

		if(weaponid == 0 && !IsValidItem(GetPlayerItem(playerid)))
		{
			UnholsterItem(playerid);
			return 1;
		}
		else
		{
			if(0 < weaponid < WEAPON_PARACHUTE)
			{
				if(!CanItemTypeBeHolstered(ItemType:weaponid))
					return 0;

				ConvertPlayerWeaponToItem(playerid);
				HolsterItem(playerid);
			}
			else
			{
				HolsterItem(playerid);
			}
			return 1;
		}
	}

	return 1;
}

HolsterItem(playerid)
{
	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(IsValidItem(itemid))
	{
		new holsterid;

		while(holsterid < hols_Total)
		{
			if(hols_TypeData[holsterid][hols_itemType] == itemtype)
				break;

			holsterid++;
		}

		if(holsterid >= hols_Total)
			return 0;

		ApplyAnimation(playerid, hols_TypeData[holsterid][hols_animLib], hols_TypeData[holsterid][hols_animName], 1.7, 0, 0, 0, 0, hols_TypeData[holsterid][hols_time]);
		defer HolsterItemDelay(playerid, itemid, hols_TypeData[holsterid][hols_time]);
		hols_LastHolster[playerid] = tickcount();

		return 1;
	}

	return 0;
}

timer HolsterItemDelay[time](playerid, itemid, time)
{
	#pragma unused time

	if(!IsValidItem(itemid))
		return 0;

	new curitem = hols_Item[playerid];

	SetPlayerHolsterItem(playerid, itemid);
	ClearAnimations(playerid);
	RemoveItemFromWorld(itemid);

	if(IsValidItem(curitem))
	{
		CreateItemInWorld(curitem);
		GiveWorldItemToPlayer(playerid, curitem);
		ConvertPlayerItemToWeapon(playerid);
		ShowActionText(playerid, "Swapped", 3000, 70);
	}
	else
	{
		ShowActionText(playerid, "Holstered", 3000, 70);
	}

	return 1;
}

UnholsterItem(playerid)
{
	if(!IsValidItem(hols_Item[playerid]))
		return 0;

	new holsterid;

	while(holsterid < hols_Total)
	{
		if(hols_TypeData[holsterid][hols_itemType] == GetItemType(hols_Item[playerid]))
			break;

		holsterid++;
	}

	if(holsterid >= hols_Total)
		return 0;

	ApplyAnimation(playerid, hols_TypeData[holsterid][hols_animLib], hols_TypeData[holsterid][hols_animName], 1.7, 0, 0, 0, 0, hols_TypeData[holsterid][hols_time]);
	defer UnholsterItemDelay(playerid, hols_TypeData[holsterid][hols_time]);
	hols_LastHolster[playerid] = tickcount();

	return 0;
}

timer UnholsterItemDelay[time](playerid, time)
{
	#pragma unused time

	if(!IsValidItem(hols_Item[playerid]))
		return 0;

	CreateItemInWorld(hols_Item[playerid]);
	GiveWorldItemToPlayer(playerid, hols_Item[playerid]);
	ConvertPlayerItemToWeapon(playerid);

	RemovePlayerHolsterItem(playerid);
	ShowActionText(playerid, "Equipped", 3000, 70);

	return 1;
}

public OnPlayerAddToInventory(playerid, itemid)
{
	if(!IsValidContainer(GetPlayerCurrentContainer(playerid)) && !IsPlayerViewingInventory(playerid))
	{
		if(CanItemTypeBeHolstered(GetItemType(itemid)))
		{
			return 1;
		}
	}

	return CallLocalFunction("hols_OnPlayerAddToInventory", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerAddToInventory
	#undef OnPlayerAddToInventory
#else
	#define _ALS_OnPlayerAddToInventory
#endif
#define OnPlayerAddToInventory hols_OnPlayerAddToInventory
forward hols_OnPlayerAddToInventory(playerid, itemid);

