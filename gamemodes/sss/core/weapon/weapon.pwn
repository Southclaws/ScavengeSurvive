/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_ITEM_WEAPON	(64)


enum (<<= 1)
{
	WEAPON_FLAG_ASSISTED_FIRE_ONCE = 1,	// fired once by server fire key event.
	WEAPON_FLAG_ASSISTED_FIRE,			// fired repeatedly while key pressed.
	WEAPON_FLAG_ONLY_FIRE_AIMED,		// only run a fire event while RMB held.
	WEAPON_FLAG_LIQUID_AMMO				// calibre argument is a liquid type
}

enum E_ITEM_WEAPON_DATA
{
ItemType:	itmw_itemType,
			itmw_baseWeapon,
			itmw_calibre,
Float:		itmw_muzzVelocity,
			itmw_magSize,
			itmw_maxReserveMags,
			itmw_animSet,
			itmw_flags
}

enum // Item array data structure
{
			WEAPON_ITEM_ARRAY_CELL_MAG,
			WEAPON_ITEM_ARRAY_CELL_RESERVE,
			WEAPON_ITEM_ARRAY_CELL_AMMOITEM,
			WEAPON_ITEM_ARRAY_CELL_MODS
}


static
			itmw_Data[MAX_ITEM_WEAPON][E_ITEM_WEAPON_DATA],
			itmw_Total,
			itmw_ItemTypeWeapon[MAX_ITEM_TYPE] = {-1, ...};

static
PlayerText:	WeaponAmmoUI[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
			tick_LastReload[MAX_PLAYERS],
			tick_GetWeaponTick[MAX_PLAYERS],
Timer:		itmw_RepeatingFireTimer[MAX_PLAYERS],
Item:		itmw_DropItemID[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
Timer:		itmw_DropTimer[MAX_PLAYERS];


forward ItemType:GetItemWeaponItemAmmoItem(Item:itemid);


/*==============================================================================

	Core

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	WeaponAmmoUI[playerid]			=CreatePlayerTextDraw(playerid, 520.411254, 62.649990, "500/500");
	PlayerTextDrawAlignment			(playerid, WeaponAmmoUI[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WeaponAmmoUI[playerid], 255);
	PlayerTextDrawFont				(playerid, WeaponAmmoUI[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, WeaponAmmoUI[playerid], 0.278114, 1.372495);
	PlayerTextDrawColor				(playerid, WeaponAmmoUI[playerid], -1);
	PlayerTextDrawSetShadow(playerid, WeaponAmmoUI[playerid], 0);
	PlayerTextDrawSetOutline		(playerid, WeaponAmmoUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WeaponAmmoUI[playerid], 1);
	PlayerTextDrawTextSize			(playerid, WeaponAmmoUI[playerid], 1613.000000, -118.533325);

	itmw_DropItemID[playerid] = INVALID_ITEM_ID;
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineItemTypeWeapon(ItemType:itemtype, baseweapon, calibre, Float:muzzvelocity, magsize, maxreservemags, animset = -1, flags = 0)
{
	SetItemTypeMaxArrayData(itemtype, 4);

	itmw_Data[itmw_Total][itmw_itemType] = itemtype;
	itmw_Data[itmw_Total][itmw_baseWeapon] = baseweapon;
	itmw_Data[itmw_Total][itmw_calibre] = calibre;
	itmw_Data[itmw_Total][itmw_muzzVelocity] = muzzvelocity;
	itmw_Data[itmw_Total][itmw_magSize] = magsize;
	itmw_Data[itmw_Total][itmw_maxReserveMags] = maxreservemags;
	itmw_Data[itmw_Total][itmw_animSet] = animset;
	itmw_Data[itmw_Total][itmw_flags] = flags;

	itmw_ItemTypeWeapon[itemtype] = itmw_Total;

	return itmw_Total++;
}

stock GivePlayerAmmo(playerid, amount)
{
	dbg("weapon-core", 1, "[GivePlayerAmmo] player %d amount %d", playerid, amount);
	new Item:itemid = GetPlayerItem(playerid);

	if(!IsValidItem(itemid))
		return 0;

	new remainder = AddAmmoToWeapon(itemid, amount);
	UpdatePlayerWeaponItem(playerid);
	_UpdateWeaponUI(playerid);

	dbg("weapon-core", 2, "[GivePlayerAmmo] Remainder of added ammo: %d", remainder);

	return remainder;
}

stock AddAmmoToWeapon(Item:itemid, amount)
{
	new ItemType:ammoitem = GetItemWeaponItemAmmoItem(itemid);

	if(!IsValidItemType(ammoitem))
		return amount;

	new
		ItemType:itemtype,
		magsize,
		reserveammo,
		maxammo,
		remainder = amount;

	itemtype = GetItemType(itemid);
	reserveammo = GetItemWeaponItemReserve(itemid);
	magsize = GetItemTypeWeaponMagSize(itemtype);
	maxammo = itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_maxReserveMags] * magsize;

	dbg("weapon-core", 1, "[AddAmmoToWeapon] item ammo item: %d mag size: %d", _:ammoitem, magsize);

	if(maxammo == 0)
	{
		dbg("weapon-core", 2, "[AddAmmoToWeapon] Adding %d ammo to item %d: ammoitem type: %d magsize: %d reserve: %d", amount, _:itemid, _:ammoitem, magsize, reserveammo);

		if(amount > magsize)
		{
			remainder = (reserveammo + amount) - magsize;
			amount = magsize;
		}
		else
		{
			remainder = 0;
		}

		dbg("weapon-core", 2, "[AddAmmoToWeapon] Setting just mag to %d", amount);

		SetItemWeaponItemReserve(itemid, amount);
	}
	else
	{
		if(reserveammo == maxammo)
			return remainder;

		dbg("weapon-core", 2, "[AddAmmoToWeapon] Adding %d ammo to item %d: ammoitem type: %d reserve: %d max reserve: %d", amount, _:itemid, _:ammoitem, reserveammo, maxammo);

		if(reserveammo + amount > maxammo)
		{
			remainder = (reserveammo + amount) - maxammo;
			amount = maxammo - reserveammo;
		}
		else
		{
			remainder = 0;
		}

		dbg("weapon-core", 2, "[AddAmmoToWeapon] Setting just reserve to %d", amount);

		SetItemWeaponItemReserve(itemid, amount + reserveammo);
	}

	dbg("weapon-core", 2, "[AddAmmoToWeapon] Returning remainder of %d", remainder);

	return remainder;
}


/*==============================================================================

	Hooks and Internal

==============================================================================*/


stock UpdatePlayerWeaponItem(playerid)
{
	dbg("weapon-core", 1, "[UpdatePlayerWeaponItem]");
	if(!IsPlayerConnected(playerid))
		return 0;

	new
		Item:itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(!IsValidItem(itemid))
	{
		dbg("weapon-core", 2, "[UpdatePlayerWeaponItem] ERROR: Invalid item ID %d", _:itemid);
		return 0;
	}

	if(itmw_ItemTypeWeapon[itemtype] == -1)
	{
		dbg("weapon-core", 2, "[UpdatePlayerWeaponItem] ERROR: Item type is not a weapon %d", itmw_ItemTypeWeapon[itemtype]);
		return 0;
	}

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] == NO_CALIBRE)
	{
		GivePlayerWeapon(playerid, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon], 99999);
		return 1;
	}

	// Get the item type used as ammo for this weapon item
	new ItemType:ammoitem = GetItemWeaponItemAmmoItem(itemid);

	// If it's not a valid ammo type, the gun has no ammo loaded.
	if(GetItemTypeAmmoType(ammoitem) == -1)
	{
		ResetPlayerWeapons(playerid);
		_UpdateWeaponUI(playerid);
		ShowActionText(playerid, ls(playerid, "WEAPNOAMMOL", true), 3000);
		return 0;
	}

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_magSize] > 0)
	{
		if(GetItemWeaponItemMagAmmo(itemid) > itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_magSize])
		{
			SetItemWeaponItemMagAmmo(itemid, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_magSize]);
			SetItemWeaponItemReserve(itemid, GetItemWeaponItemReserve(itemid) + (GetItemWeaponItemMagAmmo(itemid) - itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_magSize]));
		}
	}
	else
	{
		dbg("weapon-core", 2, "ERROR: Item weapon %d uses ammo item %d which has a max ammo of %d.", _:itemtype, _:ammoitem, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_magSize]);
	}

	new
		magammo = GetItemWeaponItemMagAmmo(itemid),
		reserveammo = GetItemWeaponItemReserve(itemid);

	ResetPlayerWeapons(playerid);

	if(magammo == 0)
	{
		if(reserveammo > 0)
			_ReloadWeapon(playerid);
	}
	else if(magammo > 0)
	{
		GivePlayerWeapon(playerid, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon], 99999);
	}

	_UpdateWeaponUI(playerid);

	tick_GetWeaponTick[playerid] = GetTickCount();

	return 1;
}

stock RemovePlayerWeapon(playerid)
{
	dbg("weapon-core", 1, "[RemovePlayerWeapon]");
	if(!IsPlayerConnected(playerid))
		return 0;

	PlayerTextDrawHide(playerid, WeaponAmmoUI[playerid]);
	ResetPlayerWeapons(playerid);

	return 1;
}

hook OnPlayerUpdate(playerid)
{
	_FastUpdateHandler(playerid);

	return 1;
}

_FastUpdateHandler(playerid)
{
	new
		Item:itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
	{
		if(GetPlayerWeapon(playerid) > 0)
			RemovePlayerWeapon(playerid);

		return;
	}

	if(itmw_ItemTypeWeapon[itemtype] == -1)
		return;

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] == NO_CALIBRE)
	{
		if(IsBaseWeaponThrowable(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon]))
		{
			if(GetPlayerWeapon(playerid) == 0)
			{
				if(GetTickCountDifference(GetTickCount(), tick_GetWeaponTick[playerid]) > 1000)
					DestroyItem(itemid);
			}
		}

		return;
	}

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		SetPlayerArmedWeapon(playerid, 0);
		return;
	}

	new magammo = GetItemWeaponItemMagAmmo(itemid);

	if(magammo <= 0)
		return;

	SetPlayerArmedWeapon(playerid, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon]);

	return;
}

timer _RepeatingFire[1000](playerid)
{
	new
		Item:itemid,
		ItemType:itemtype,
		magammo;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);
	magammo = GetItemWeaponItemMagAmmo(itemid);

	if(!IsValidItemType(itemtype))
	{
		stop itmw_RepeatingFireTimer[playerid];
		return;
	}

	if(itmw_ItemTypeWeapon[itemtype] == -1)
	{
		stop itmw_RepeatingFireTimer[playerid];
		return;
	}

	if(IsPlayerKnockedOut(playerid))
	{
		stop itmw_RepeatingFireTimer[playerid];
		return;
	}

	if(!(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_flags] & WEAPON_FLAG_ASSISTED_FIRE))
	{
		stop itmw_RepeatingFireTimer[playerid];
		return;
	}

	if(GetTickCountDifference(GetTickCount(), tick_LastReload[playerid]) < 1300)
		return;

	new k, ud, lr;

	GetPlayerKeys(playerid, k, ud, lr);

	if(k & KEY_FIRE)
	{
		magammo -= itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_maxReserveMags];
		SetItemWeaponItemMagAmmo(itemid, magammo);

		if(magammo <= 0)
			_ReloadWeapon(playerid);

		_UpdateWeaponUI(playerid);
	}
	else
	{
		stop itmw_RepeatingFireTimer[playerid];
	}

	return;
}

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	dbg("weapon-core", 1, "[OnPlayerWeaponShot] %d fired weapon %d", playerid, weaponid);
	if(!_FireWeapon(playerid, weaponid, hittype, hitid, fX, fY, fZ))
		return Y_HOOKS_BREAK_RETURN_0;

	return Y_HOOKS_CONTINUE_RETURN_1;
}


_FireWeapon(playerid, weaponid, hittype = -1, hitid = -1, Float:fX = 0.0, Float:fY = 0.0, Float:fZ = 0.0)
{
	#pragma unused hittype, hitid, fX, fY, fZ
	dbg("weapon-core", 2, "[_FireWeapon] %p fired weapon %d", playerid, weaponid);
	new
		Item:itemid,
		ItemType:itemtype,
		magammo;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid),
	magammo = GetItemWeaponItemMagAmmo(itemid);

	if(!IsValidItemType(itemtype))
	{
		ChatMsgAdmins(1, YELLOW, "[TEST] Player %p fired weapon type %d without having any item equipped.", playerid, weaponid);
		dbg("weapon-core", 2, "[TMPREPORT] Player %p fired weapon type %d without having any item equipped.", playerid, weaponid);
		return 0;
	}

	if(itmw_ItemTypeWeapon[itemtype] == -1)
	{
		ChatMsgAdmins(1, YELLOW, "[TEST] Player %p fired weapon type %d while having a non-weapon item (%d) equipped.", playerid, weaponid, _:itemtype);
		dbg("weapon-core", 2, "[TMPREPORT] Player %p fired weapon type %d while having a non-weapon item (%d) equipped.", playerid, weaponid, _:itemtype);
		return 0;
	}

	magammo -= 1;

	SetItemWeaponItemMagAmmo(itemid, magammo);

	if(magammo == 0 && !(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_flags] & WEAPON_FLAG_ASSISTED_FIRE_ONCE))
		_ReloadWeapon(playerid);

	_UpdateWeaponUI(playerid);

	return 1;
}

_ReloadWeapon(playerid)
{
	dbg("weapon-core", 1, "[_ReloadWeapon]");
	if(GetTickCountDifference(GetTickCount(), tick_LastReload[playerid]) < 1000)
		return 0;

	new
		Item:itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] == NO_CALIBRE)
		return 0;

	new
		magammo,
		reserveammo,
		magsize;

	magammo = GetItemWeaponItemMagAmmo(itemid);
	reserveammo = GetItemWeaponItemReserve(itemid);
	magsize = GetItemTypeWeaponMagSize(itemtype);

	if(reserveammo == 0)
	{
		dbg("weapon-core", 2, "no reserve ammo left to reload with");

		if(magammo == 0)
		{
			SetItemWeaponItemAmmoItem(itemid, INVALID_ITEM_TYPE);
			ResetPlayerWeapons(playerid);
		}

		return 0;
	}

	if(magammo == magsize)
	{
		dbg("weapon-core", 2, "Mag ammo is the same as mag size");
		return 0;
	}

	if(magsize <= 0)
		return 0;

	ResetPlayerWeapons(playerid);

	//if(!IsBaseWeaponClipBased(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon]))
	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] == NO_CALIBRE)
	{
		dbg("weapon-core", 2, "Weapon has no calibre, cancelling reload");
		return 0;
	}

	if(reserveammo + magammo > magsize)
	{
		SetItemWeaponItemMagAmmo(itemid, magsize);
		SetItemWeaponItemReserve(itemid, reserveammo - (magsize - magammo));
	}
	else
	{
		SetItemWeaponItemMagAmmo(itemid, reserveammo + magammo);
		SetItemWeaponItemReserve(itemid, 0);
	}

	switch(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon])
	{
		default:
			ApplyAnimation(playerid, "COLT45", "COLT45_RELOAD", 2.0, 0, 1, 1, 0, 0);
	}

	UpdatePlayerWeaponItem(playerid);
	_UpdateWeaponUI(playerid);

	tick_LastReload[playerid] = GetTickCount();

	return 1;
}

_UpdateWeaponUI(playerid)
{
	new
		Item:itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	dbg("weapon-core", 1, "[_UpdateWeaponUI] updating weapon UI for item %d", _:itemid);

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] == NO_CALIBRE)
	{
		dbg("weapon-core", 2, "weapon is not clip based");
		PlayerTextDrawHide(playerid, WeaponAmmoUI[playerid]);
		return;
	}

	dbg("weapon-core", 2, "[_UpdateWeaponUI] item %d magammo %d reserve %d", _:itemid, GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid));

	new str[8];

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_maxReserveMags] > 0)
		format(str, 8, "%d/%d", GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid));

	else
		format(str, 8, "%d", GetItemWeaponItemMagAmmo(itemid));

	PlayerTextDrawSetString(playerid, WeaponAmmoUI[playerid], str);
	PlayerTextDrawShow(playerid, WeaponAmmoUI[playerid]);

	return;
}

hook OnPlayerHolsteredItem(playerid, Item:itemid)
{
	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		new Item:helditemid = GetPlayerItem(playerid);

		if(GetItemTypeWeaponBaseWeapon(GetItemType(helditemid)) > 0)
		{
			if(GetItemWeaponItemMagAmmo(helditemid) == 0)
				RemovePlayerWeapon(playerid);
		}
		else
		{
			RemovePlayerWeapon(playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUnHolsteredItem(playerid, Item:itemid)
{
	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		UpdatePlayerWeaponItem(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Interaction

==============================================================================*/


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 1)
	{
		if(IsPlayerKnockedOut(playerid))
			return Y_HOOKS_CONTINUE_RETURN_1;

		if(IsPlayerInAnyVehicle(playerid))
			return Y_HOOKS_CONTINUE_RETURN_1;

		if(GetItemTypeWeapon(GetItemType(GetPlayerItem(playerid))) != -1)
			_ReloadWeapon(playerid);
	}

	if(newkeys & KEY_FIRE)
	{
		new
			Item:itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(!IsValidItemType(itemtype))
			return Y_HOOKS_CONTINUE_RETURN_1;

		if(itmw_ItemTypeWeapon[itemtype] == -1)
			return Y_HOOKS_CONTINUE_RETURN_1;

		if(IsBaseWeaponThrowable(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon]))
		{
			defer DestroyThrowable(playerid, _:itemid);
			return Y_HOOKS_CONTINUE_RETURN_1;
		}

		if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_flags] & WEAPON_FLAG_ONLY_FIRE_AIMED)
		{
			if(!(newkeys & KEY_HANDBRAKE))
				return Y_HOOKS_CONTINUE_RETURN_1;
		}

		if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_flags] & WEAPON_FLAG_ASSISTED_FIRE_ONCE)
		{
			_FireWeapon(playerid, WEAPON_ROCKETLAUNCHER);
		}
		else if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_flags] & WEAPON_FLAG_ASSISTED_FIRE)
		{
			itmw_RepeatingFireTimer[playerid] = repeat _RepeatingFire(playerid);
		}
	}

	if(oldkeys & KEY_FIRE)
	{
		if(GetItemTypeWeaponBaseWeapon(GetItemType(GetPlayerItem(playerid))) == WEAPON_FLAMETHROWER)
		{
			stop itmw_RepeatingFireTimer[playerid];
		}
	}

	if(oldkeys & KEY_NO)
	{
		new Item:itemid = itmw_DropItemID[playerid];
		if(!IsValidItem(itmw_DropItemID[playerid]))
			return Y_HOOKS_CONTINUE_RETURN_1;

		new ItemType:itemtype = GetItemType(itemid);
		if(itmw_ItemTypeWeapon[itemtype] == -1)
			return Y_HOOKS_CONTINUE_RETURN_1;

		dbg("weapon-core", 2, "[OnPlayerKeyStateChange] dropping item %d magammo %d reserve %d",
			_:itemid,
			GetItemWeaponItemMagAmmo(itemid),
			GetItemWeaponItemReserve(itemid));

		stop itmw_DropTimer[playerid];
		PlayerDropItem(playerid);
		itmw_DropItemID[playerid] = INVALID_ITEM_ID;
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

timer DestroyThrowable[1000](playerid, itemid)
{
	DestroyItem(Item:itemid);
	ResetPlayerWeapons(playerid);
}

hook OnPlayerDropItem(playerid, Item:itemid)
{
	if(_unload_DropHandler(playerid, itemid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_unload_DropHandler(playerid, Item:itemid)
{
	new
		ItemType:itemtype,
		weapontype;

	itemtype = GetItemType(itemid);
	weapontype = GetItemTypeWeapon(itemtype);

	if(weapontype == -1)
		return 0;

	if(itmw_Data[weapontype][itmw_maxReserveMags] == 0)
		return 0;

	if(itmw_DropItemID[playerid] != INVALID_ITEM_ID)
		return 0;

	if(itmw_Data[weapontype][itmw_flags] & WEAPON_FLAG_LIQUID_AMMO)
		return 0;

	dbg("weapon-core", 1, "[OnPlayerDropItem] dropping item %d magammo %d reserve %d", _:itemid, GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid));
	itmw_DropItemID[playerid] = itemid;
	itmw_DropTimer[playerid] = defer _UnloadWeapon(playerid, _:itemid);

	return 1;
}

timer _UnloadWeapon[300](playerid, _itemid)
{
	new Item:itemid = Item:_itemid;

	dbg("weapon-core", 1, "[_UnloadWeapon] unloading item %d magammo %d reserve %d", _:itemid, GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid));
	if(GetPlayerItem(playerid) != itemid)
	{
		itmw_DropItemID[playerid] = INVALID_ITEM_ID;
		return;
	}

	if(itmw_DropItemID[playerid] != itemid)
	{
		itmw_DropItemID[playerid] = INVALID_ITEM_ID;
		return;
	}

	new
		ItemType:ammoitemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		Item:ammoitemid;

	ammoitemtype = GetItemWeaponItemAmmoItem(itemid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	dbg("weapon-core", 2, "[_UnloadWeapon] ammo item type %d amount: %d", _:ammoitemtype, GetItemWeaponItemMagAmmo(itemid) + GetItemWeaponItemReserve(itemid));

	ammoitemid = CreateItem(ammoitemtype,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)),
		z - ITEM_FLOOR_OFFSET,
		.world = GetPlayerVirtualWorld(playerid),
		.interior = GetPlayerInterior(playerid));

	SetItemExtraData(ammoitemid, GetItemWeaponItemMagAmmo(itemid) + GetItemWeaponItemReserve(itemid));

	SetItemWeaponItemMagAmmo(itemid, 0);
	SetItemWeaponItemReserve(itemid, 0);
	SetItemWeaponItemAmmoItem(itemid, INVALID_ITEM_TYPE);
	UpdatePlayerWeaponItem(playerid);
	itmw_DropItemID[playerid] = INVALID_ITEM_ID;

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
	ShowActionText(playerid, ls(playerid, "WEAPAUNLOAD", true), 3000);

	return;
}

hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	new itemweaponid = GetItemTypeWeapon(itemtype);

	if(itemweaponid == -1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] == NO_CALIBRE)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new
		ammotype = GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemid)),
		calibrename[MAX_AMMO_CALIBRE_NAME],
		ammoname[MAX_AMMO_CALIBRE_NAME],
		exname[MAX_ITEM_TEXT];

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_flags] & WEAPON_FLAG_LIQUID_AMMO)
		calibrename = "Liquid";

	else
		GetCalibreName(itmw_Data[itemweaponid][itmw_calibre], calibrename);

	if(ammotype == -1)
		ammoname = "Unloaded";

	else
		GetAmmoTypeName(ammotype, ammoname);

	new name[MAX_ITEM_NAME];
	GetItemTypeName(itemtype, name);

	format(exname, sizeof(exname), "%d/%d, %s, %s", GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid), calibrename, ammoname);

	SetItemNameExtra(itemid, exname);

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Interface Functions

==============================================================================*/


stock GetItemTypeWeapon(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	return itmw_ItemTypeWeapon[itemtype];
}

// itmw_itemType
stock GetItemWeaponItemType(itemweaponid)
{
	if(!(0 <= itemweaponid < itmw_Total))
		return 0;

	return itmw_Data[itemweaponid][itmw_itemType];
}

// itmw_baseWeapon
stock GetItemWeaponBaseWeapon(itemweaponid)
{
	if(!(0 <= itemweaponid < itmw_Total))
		return 0;

	return itmw_Data[itemweaponid][itmw_baseWeapon];
}

// itmw_calibre
stock GetItemWeaponCalibre(itemweaponid)
{
	if(!(0 <= itemweaponid < itmw_Total))
		return 0;

	return itmw_Data[itemweaponid][itmw_calibre];
}

// itmw_muzzVelocity
stock Float:GetItemWeaponMuzzVelocity(itemweaponid)
{
	if(!(0 <= itemweaponid < itmw_Total))
		return 0.0;

	return itmw_Data[itemweaponid][itmw_muzzVelocity];
}

// itmw_magSize
stock GetItemWeaponMagSize(itemweaponid)
{
	if(!(0 <= itemweaponid < itmw_Total))
		return 0;

	return itmw_Data[itemweaponid][itmw_magSize];
}

// itmw_maxReserveMags
stock GetItemWeaponMaxReserveMags(itemweaponid)
{
	if(!(0 <= itemweaponid < itmw_Total))
		return 0;

	return itmw_Data[itemweaponid][itmw_maxReserveMags];
}

// itmw_animSet
stock GetItemWeaponAnimSet(itemweaponid)
{
	if(!(0 <= itemweaponid < itmw_Total))
		return 0;

	return itmw_Data[itemweaponid][itmw_animSet];
}

// itmw_flags
stock GetItemWeaponFlags(itemweaponid)
{
	if(!(0 <= itemweaponid < itmw_Total))
		return 0;

	return itmw_Data[itemweaponid][itmw_flags];
}


/*==============================================================================
	from itemtype
==============================================================================*/


// itmw_baseWeapon
stock GetItemTypeWeaponBaseWeapon(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon];
}

// itmw_calibre
stock GetItemTypeWeaponCalibre(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre];
}

// itmw_muzzVelocity
stock Float:GetItemTypeWeaponMuzzVelocity(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0.0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0.0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_muzzVelocity];
}

// itmw_magSize
stock GetItemTypeWeaponMagSize(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_magSize];
}

// itmw_maxReserveMags
stock GetItemTypeWeaponMaxReserveMags(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_maxReserveMags];
}

// itmw_animSet
stock GetItemTypeWeaponAnimSet(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_animSet];
}

// itmw_flags
stock GetItemTypeWeaponFlags(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_flags];
}


/*==============================================================================
	Item array data interface
==============================================================================*/


// WEAPON_ITEM_ARRAY_CELL_MAG
stock GetItemWeaponItemMagAmmo(Item:itemid)
{
	dbg("weapon-core", 3, "GetItemWeaponItemMagAmmo itemid:%d", _:itemid);
	new ret;
	GetItemArrayDataAtCell(itemid, ret, WEAPON_ITEM_ARRAY_CELL_MAG);
	return ret < 0 ? 0 : ret;
}

stock Error:SetItemWeaponItemMagAmmo(Item:itemid, amount)
{
	dbg("weapon-core", 3, "SetItemWeaponItemMagAmmo itemid:%d, amount:%d", _:itemid, amount);

	if(amount == 0)
	{
		if(GetItemWeaponItemReserve(itemid) == 0)
			SetItemWeaponItemAmmoItem(itemid, INVALID_ITEM_TYPE);
	}

	SetItemArrayDataSize(itemid, 4);
	return SetItemArrayDataAtCell(itemid, amount, WEAPON_ITEM_ARRAY_CELL_MAG);
}

// WEAPON_ITEM_ARRAY_CELL_RESERVE
stock GetItemWeaponItemReserve(Item:itemid)
{
	dbg("weapon-core", 3, "GetItemWeaponItemReserve itemid:%d", _:itemid);
	new reserve, Error:e;
	e = GetItemArrayDataAtCell(itemid, reserve, WEAPON_ITEM_ARRAY_CELL_RESERVE);
	if(IsError(e))
		return Handled();
	return reserve < 0 ? 0 : reserve;
}

stock Error:SetItemWeaponItemReserve(Item:itemid, amount)
{
	dbg("weapon-core", 3, "SetItemWeaponItemReserve itemid:%d, amount:%d", _:itemid, amount);

	if(amount == 0)
	{
		if(GetItemWeaponItemMagAmmo(itemid) == 0)
			SetItemWeaponItemAmmoItem(itemid, INVALID_ITEM_TYPE);
	}

	SetItemArrayDataSize(itemid, 4);
	return SetItemArrayDataAtCell(itemid, amount, WEAPON_ITEM_ARRAY_CELL_RESERVE);
}

// WEAPON_ITEM_ARRAY_CELL_AMMOITEM
stock ItemType:GetItemWeaponItemAmmoItem(Item:itemid)
{
	dbg("weapon-core", 3, "GetItemWeaponItemAmmoItem itemid:%d", _:itemid);
	new ItemType:itemtype;
	GetItemArrayDataAtCell(itemid, _:itemtype, WEAPON_ITEM_ARRAY_CELL_AMMOITEM);
	return itemtype;
}

stock Error:SetItemWeaponItemAmmoItem(Item:itemid, ItemType:itemtype)
{
	dbg("weapon-core", 3, "SetItemWeaponItemAmmoItem itemid:%d, itemtype:%d", _:itemid, _:itemtype);
	SetItemArrayDataSize(itemid, 4);

	return SetItemArrayDataAtCell(itemid, _:itemtype, WEAPON_ITEM_ARRAY_CELL_AMMOITEM);
}

// From player

stock GetPlayerMagAmmo(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return GetItemWeaponItemMagAmmo(GetPlayerItem(playerid));
}

stock GetPlayerReserveAmmo(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return GetItemWeaponItemReserve(GetPlayerItem(playerid));
}

stock GetPlayerTotalAmmo(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new Item:itemid = GetPlayerItem(playerid);

	return GetItemWeaponItemMagAmmo(itemid) + GetItemWeaponItemReserve(itemid);
}

