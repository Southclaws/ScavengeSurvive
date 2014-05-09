#include <YSI\y_hooks>


#define MAX_ITEM_WEAPON	(64)
static HANDLER;


enum E_ITEM_WEAPON_DATA
{
ItemType:	itmw_itemType,
			itmw_baseWeapon,
			itmw_calibre,
Float:		itmw_muzzVelocity,
			itmw_maxReserveMags,
			itmw_animSet
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
			itmw_ItemTypeWeapon[ITM_MAX_TYPES] = {-1, ...},
ItemType:	itmw_ItemTypeLowerBound,
ItemType:	itmw_ItemTypeUpperBound;

static
			tick_LastReload[MAX_PLAYERS];


/*==============================================================================

	Core

==============================================================================*/


hook OnGameModeInit()
{
	HANDLER = debug_register_handler("weapon/core");
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineItemTypeWeapon(ItemType:itemtype, baseweapon, calibre, Float:muzzvelocity, maxreservemags, animset = -1)
{
	itmw_Data[itmw_Total][itmw_itemType] = itemtype;
	itmw_Data[itmw_Total][itmw_baseWeapon] = baseweapon;
	itmw_Data[itmw_Total][itmw_calibre] = calibre;
	itmw_Data[itmw_Total][itmw_muzzVelocity] = muzzvelocity;
	itmw_Data[itmw_Total][itmw_maxReserveMags] = maxreservemags;
	itmw_Data[itmw_Total][itmw_animSet] = animset;

	itmw_ItemTypeWeapon[itemtype] = itmw_Total;

	if(itemtype < itmw_ItemTypeLowerBound)
		itmw_ItemTypeLowerBound = itemtype;

	else if(itemtype > itmw_ItemTypeUpperBound)
		itmw_ItemTypeUpperBound = itemtype;

	return itmw_Total++;
}

stock GivePlayerAmmo(playerid, amount)
{
	d:1:HANDLER("\n[GivePlayerAmmo]");
	new itemid = GetPlayerItem(playerid);

	if(!IsValidItem(itemid))
		return 0;

	new remainder = AddAmmoToWeapon(itemid, amount);
	UpdatePlayerWeaponItem(playerid);
	_UpdateWeaponUI(playerid);

	d:1:HANDLER("[GivePlayerAmmo] Remainder of added ammo: %d", remainder);

	return remainder;
}

stock AddAmmoToWeapon(itemid, amount)
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
	magsize = GetItemTypeMagSize(ammoitem);
	reserveammo = GetItemWeaponItemReserve(itemid);
	maxammo = itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_maxReserveMags] * magsize;

	d:1:HANDLER("[AddAmmoToWeapon] item ammo item: %d mag size: %d", _:ammoitem, magsize);

	if(maxammo == 0)
	{
		d:1:HANDLER("[AddAmmoToWeapon] Adding %d ammo to item %d: ammoitem type: %d reserve: %d magsize: %d", amount, itemid, _:ammoitem, reserveammo, magsize);

		if(amount > magsize)
		{
			remainder = (reserveammo + amount) - magsize;
			amount = magsize;
		}
		else
		{
			remainder = 0;
		}

		d:1:HANDLER("[AddAmmoToWeapon] Setting just mag to %d", amount);

		SetItemWeaponItemReserve(itemid, amount);
	}
	else
	{
		if(reserveammo == maxammo)
			return remainder;

		d:1:HANDLER("[AddAmmoToWeapon] Adding %d ammo to item %d: ammoitem type: %d reserve: %d max reserve: %d", amount, itemid, _:ammoitem, reserveammo, maxammo);

		if(reserveammo + amount > maxammo)
		{
			remainder = (reserveammo + amount) - maxammo;
			amount = maxammo - reserveammo;
		}
		else
		{
			remainder = 0;
		}

		d:1:HANDLER("[AddAmmoToWeapon] Setting just reserve to %d", amount);

		SetItemWeaponItemReserve(itemid, amount + reserveammo);
	}

	d:1:HANDLER("[AddAmmoToWeapon] Returning remainder of %d", remainder);

	return remainder;
}


/*==============================================================================

	Hooks and Internal

==============================================================================*/


stock UpdatePlayerWeaponItem(playerid)
{
	d:1:HANDLER("\n[UpdatePlayerWeaponItem]");
	if(!IsPlayerConnected(playerid))
		return 0;

	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(!IsValidItem(itemid))
		return 0;

	if(!(itmw_ItemTypeLowerBound < itemtype < itmw_ItemTypeUpperBound))
		return 0;

	if(itmw_ItemTypeWeapon[itemtype] == -1)
		return 0;

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] == NO_CALIBRE)
	{
		GivePlayerWeapon(playerid, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon], 1);
		return 1;
	}

	// Get the item type used as ammo for this weapon item
	new ItemType:ammoitem = GetItemWeaponItemAmmoItem(itemid);

	// If it's not a valid ammo type, something is wrong.
	if(GetItemTypeAmmoType(ammoitem) == -1)
	{
		ShowActionText(playerid, "There is no ammo loaded in this weapon", 3000);
		return 0;
	}

	new maxammo = GetItemTypeMagSize(ammoitem);

	if(maxammo > 0)
	{
		if(GetItemWeaponItemMagAmmo(itemid) > maxammo)
		{
			SetItemWeaponItemMagAmmo(itemid, maxammo);
			SetItemWeaponItemReserve(itemid, GetItemWeaponItemReserve(itemid) + (GetItemWeaponItemMagAmmo(itemid) - maxammo));
		}
	}
	else
	{
		d:1:HANDLER("ERROR: Item weapon %d uses ammo item %d which has a max ammo of %d.", _:itemtype, _:ammoitem, maxammo);
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
		GivePlayerWeapon(playerid, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon], GetItemWeaponItemMagAmmo(itemid));
	}

	_UpdateWeaponUI(playerid);

	return 1;
}

stock RemovePlayerWeapon(playerid)
{
	d:1:HANDLER("\n[RemovePlayerWeapon]");
	if(!IsPlayerConnected(playerid))
		return 0;

	PlayerTextDrawHide(playerid, WeaponAmmo[playerid]);
	ResetPlayerWeapons(playerid);

	return 1;
}

hook OnPlayerUpdate(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		return 1;

	_FastUpdateHandler(playerid);

	return 1;
}

_FastUpdateHandler(playerid)
{
	new
		itemid,
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

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] != NO_CALIBRE)
		return;

	new magammo = GetItemWeaponItemMagAmmo(itemid);

	if(magammo <= 0)
		return;

	SetPlayerArmedWeapon(playerid, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon]);

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon] == WEAPON_FLAMETHROWER)
	{
		new k;

		GetPlayerKeys(playerid, k, k, k);

		if(k & KEY_FIRE)
		{
			SetItemWeaponItemMagAmmo(itemid, magammo - 1);
		}
	}

	return;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(!_FireWeapon(playerid, weaponid, hittype, hitid, fX, fY, fZ))
		return 0;

	#if defined itmw_OnPlayerWeaponShot
		return itmw_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerWeaponShot
	#undef OnPlayerWeaponShot
#else
	#define _ALS_OnPlayerWeaponShot
#endif
 
#define OnPlayerWeaponShot itmw_OnPlayerWeaponShot
#if defined itmw_OnPlayerWeaponShot
	forward itmw_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
#endif

_FireWeapon(playerid, weaponid, hittype = -1, hitid = -1, Float:fX = 0.0, Float:fY = 0.0, Float:fZ = 0.0)
{
	#pragma unused hittype, hitid, fX, fY, fZ
	new
		itemid,
		ItemType:itemtype,
		magammo;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid),
	magammo = GetItemWeaponItemMagAmmo(itemid);

	if(!IsValidItemType(itemtype))
	{
		MsgAdminsF(1, YELLOW, "[TEST] Player %p fired weapon type %d without having any item equipped.", playerid, weaponid);
		d:1:HANDLER("[TMPREPORT] Player %p fired weapon type %d without having any item equipped.", playerid, weaponid);
		return 0;
	}

	if(itmw_ItemTypeWeapon[itemtype] == -1)
	{
		MsgAdminsF(1, YELLOW, "[TEST] Player %p fired weapon type %d while having a non-weapon item (%d) equipped.", playerid, weaponid, _:itemtype);
		d:1:HANDLER("[TMPREPORT] Player %p fired weapon type %d while having a non-weapon item (%d) equipped.", playerid, weaponid, _:itemtype);
		return 0;
	}

	magammo -= 1;

	SetItemWeaponItemMagAmmo(itemid, magammo);

	if(magammo == 0)
		_ReloadWeapon(playerid);

	_UpdateWeaponUI(playerid);

	return 1;
}

_ReloadWeapon(playerid)
{
	d:1:HANDLER("\n[_ReloadWeapon]");
	if(GetTickCountDifference(GetTickCount(), tick_LastReload[playerid]) < 1000)
		return 0;

	new
		itemid,
		ItemType:itemtype,
		magammo,
		reserveammo,
		magsize;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);
	magammo = GetItemWeaponItemMagAmmo(itemid);
	reserveammo = GetItemWeaponItemReserve(itemid);
	magsize = GetItemTypeMagSize(GetItemWeaponItemAmmoItem(itemid));

	if(reserveammo == 0)
	{
		d:1:HANDLER("no reserve ammo left to reload with");
		return 0;
	}

	if(magammo == magsize)
	{
		d:1:HANDLER("Mag ammo is the same as mag size");
		return 0;
	}

	ResetPlayerWeapons(playerid);

	if(!IsBaseWeaponClipBased(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon]))
	{
		d:1:HANDLER("Weapon is not clip based, cancelling reload");
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
	new itemid = GetPlayerItem(playerid);
	d:1:HANDLER("[_UpdateWeaponUI] updating weapon UI for item %d", itemid);

	if(!IsWeaponClipBased(itemid))
	{
		d:1:HANDLER("weapon is not clip based");
		PlayerTextDrawHide(playerid, WeaponAmmo[playerid]);
		return;
	}

	d:1:HANDLER("[_UpdateWeaponUI] item %d magammo %d reserve %d", itemid, GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid));

	new str[8];

	if(itmw_Data[itmw_ItemTypeWeapon[GetItemType(itemid)]][itmw_maxReserveMags] > 0)
		format(str, 8, "%d/%d", GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid));

	else
		format(str, 8, "%d", GetItemWeaponItemMagAmmo(itemid));

	PlayerTextDrawSetString(playerid, WeaponAmmo[playerid], str);
	PlayerTextDrawShow(playerid, WeaponAmmo[playerid]);

	return;
}

public OnPlayerHolsteredItem(playerid, itemid)
{
	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		new helditemid = GetPlayerItem(playerid);

		if(GetItemTypeWeapon(GetItemType(helditemid)) != -1)
		{
			if(GetItemWeaponItemMagAmmo(helditemid) == 0)
				RemovePlayerWeapon(playerid);
		}
		else
		{
			RemovePlayerWeapon(playerid);
		}
	}

	#if defined itmw_OnPlayerHolsteredItem
		return itmw_OnPlayerHolsteredItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerHolsteredItem
	#undef OnPlayerHolsteredItem
#else
	#define _ALS_OnPlayerHolsteredItem
#endif
 
#define OnPlayerHolsteredItem itmw_OnPlayerHolsteredItem
#if defined itmw_OnPlayerHolsteredItem
	forward itmw_OnPlayerHolsteredItem(playerid, itemid);
#endif

public OnPlayerUnHolsteredItem(playerid, itemid)
{
	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		UpdatePlayerWeaponItem(playerid);
	}

	#if defined itmw_OnPlayerUnHolsteredItem
		return itmw_OnPlayerUnHolsteredItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUnHolsteredItem
	#undef OnPlayerUnHolsteredItem
#else
	#define _ALS_OnPlayerUnHolsteredItem
#endif
 
#define OnPlayerUnHolsteredItem itmw_OnPlayerUnHolsteredItem
#if defined itmw_OnPlayerUnHolsteredItem
	forward itmw_OnPlayerUnHolsteredItem(playerid, itemid);
#endif

public OnItemCreate(itemid)
{
	if(IsItemLoot(itemid))
	{
		new ItemType:itemtype = GetItemType(itemid);

		if(GetItemTypeWeapon(itemtype) != -1)
		{
			if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] != NO_CALIBRE)
			{
				new ammotype = GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemid));

				if(GetAmmoTypeSize(ammotype) > 1)
					SetItemExtraData(itemid, random(GetAmmoTypeSize(ammotype) - 1) + 1);
			}
		}
	}

	#if defined itmw_OnItemCreate
		return itmw_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate itmw_OnItemCreate
#if defined itmw_OnItemCreate
	forward itmw_OnItemCreate(itemid);
#endif


/*==============================================================================

	Interaction

==============================================================================*/


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 1)
	{
		if(IsPlayerKnockedOut(playerid))
			return 1;

		if(IsPlayerInAnyVehicle(playerid))
			return 1;

		if(GetItemTypeWeapon(GetItemType(GetPlayerItem(playerid))) != -1)
			_ReloadWeapon(playerid);
	}

	if(newkeys & KEY_FIRE)
	{
		new itemid = GetPlayerItem(playerid);

		if(GetItemTypeWeaponBaseWeapon(GetItemType(itemid)) == WEAPON_ROCKETLAUNCHER)
		{
			_FireWeapon(playerid, WEAPON_ROCKETLAUNCHER);
		}
	}

	return 1;
}

public OnItemNameRender(itemid)
{
	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		if(GetItemTypeMagSize(GetItemWeaponItemAmmoItem(itemid)) > 1)
		{
			new exname[22];
			format(exname, sizeof(exname), "%d/%d", GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid));
			SetItemNameExtra(itemid, exname);
		}
	}

	return CallLocalFunction("itmw_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender itmw_OnItemNameRender
forward itmw_OnItemNameRender(itemid);


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

	new itemid = GetPlayerItem(playerid);

	return GetItemWeaponItemMagAmmo(itemid) + GetItemWeaponItemReserve(itemid);
}


// from itemtype

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



// from player

// itmw_baseWeapon
stock GetPlayerItemWeaponBaseWeapon(playerid)
{
	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
		return 0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon];
}

// itmw_calibre
stock GetPlayerItemWeaponCalibre(playerid)
{
	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
		return 0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre];
}

// itmw_muzzVelocity
stock GetPlayerItemWeaponMuzzVelocity(playerid)
{
	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
		return 0.0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0.0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_muzzVelocity];
}

// itmw_maxReserveMags
stock GetPlayerItemWeaponMaxResMags(playerid)
{
	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
		return 0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_maxReserveMags];
}

// itmw_animSet
stock GetPlayerItemWeaponAnimSet(playerid)
{
	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
		return 0;

	if(!(0 <= itmw_ItemTypeWeapon[itemtype] < itmw_Total))
		return 0;

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_animSet];
}


// Item array data interface

// WEAPON_ITEM_ARRAY_CELL_MAG
stock GetItemWeaponItemMagAmmo(itemid)
{
	d:1:HANDLER("GetItemWeaponItemMagAmmo itemid:%d", itemid);
	new ret = GetItemArrayDataAtCell(itemid, WEAPON_ITEM_ARRAY_CELL_MAG);
	return ret < 0 ? 0 : ret;
}

stock SetItemWeaponItemMagAmmo(itemid, amount)
{
	d:1:HANDLER("SetItemWeaponItemMagAmmo itemid:%d, amount:%d", itemid, amount);

	SetItemArrayDataSize(itemid, 4);
	return SetItemArrayDataAtCell(itemid, amount, WEAPON_ITEM_ARRAY_CELL_MAG);
}

// WEAPON_ITEM_ARRAY_CELL_RESERVE
stock GetItemWeaponItemReserve(itemid)
{
	d:1:HANDLER("GetItemWeaponItemReserve itemid:%d", itemid);
	new ret = GetItemArrayDataAtCell(itemid, WEAPON_ITEM_ARRAY_CELL_RESERVE);
	return ret < 0 ? 0 : ret;
}

stock SetItemWeaponItemReserve(itemid, amount)
{
	d:1:HANDLER("SetItemWeaponItemReserve itemid:%d, amount:%d", itemid, amount);

	SetItemArrayDataSize(itemid, 4);
	return SetItemArrayDataAtCell(itemid, amount, WEAPON_ITEM_ARRAY_CELL_RESERVE);
}

// WEAPON_ITEM_ARRAY_CELL_AMMOITEM
forward ItemType:GetItemWeaponItemAmmoItem(itemid);
stock ItemType:GetItemWeaponItemAmmoItem(itemid)
{
	d:1:HANDLER("ItemType:GetItemWeaponItemAmmoItem itemid:%d", itemid);
	return ItemType:GetItemArrayDataAtCell(itemid, WEAPON_ITEM_ARRAY_CELL_AMMOITEM);
}

stock SetItemWeaponItemAmmoItem(itemid, ItemType:itemtype)
{
	d:1:HANDLER("SetItemWeaponItemAmmoItem itemid:%d, itemtype:%d", itemid, _:itemtype);
	SetItemArrayDataSize(itemid, 4);

	return SetItemArrayDataAtCell(itemid, _:itemtype, WEAPON_ITEM_ARRAY_CELL_AMMOITEM);
}
