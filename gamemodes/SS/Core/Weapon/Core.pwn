#include <YSI\y_hooks>


#define MAX_ITEM_WEAPON	(64)
static HANDLER = -1;


enum E_ITEM_WEAPON_DATA
{
ItemType:	itmw_itemType,
			itmw_baseWeapon,
			itmw_calibre,
Float:		itmw_muzzVelocity,
			itmw_magSize,
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
			itmw_ItemTypeWeapon[ITM_MAX_TYPES] = {-1, ...};

static
			tick_LastReload[MAX_PLAYERS],
			tick_GetWeaponTick[MAX_PLAYERS],
Timer:		itmw_RepeatingFireTimer[MAX_PLAYERS],
			itmw_DropItemID[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
Timer:		itmw_DropTimer[MAX_PLAYERS];

/*==============================================================================

	Core

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Weapon/Core'...");

	HANDLER = debug_register_handler("weapon/core");
}

hook OnPlayerConnect(playerid)
{
	itmw_DropItemID[playerid] = INVALID_ITEM_ID;
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineItemTypeWeapon(ItemType:itemtype, baseweapon, calibre, Float:muzzvelocity, magsize, maxreservemags, animset = -1)
{
	itmw_Data[itmw_Total][itmw_itemType] = itemtype;
	itmw_Data[itmw_Total][itmw_baseWeapon] = baseweapon;
	itmw_Data[itmw_Total][itmw_calibre] = calibre;
	itmw_Data[itmw_Total][itmw_muzzVelocity] = muzzvelocity;
	itmw_Data[itmw_Total][itmw_magSize] = magsize;
	itmw_Data[itmw_Total][itmw_maxReserveMags] = maxreservemags;
	itmw_Data[itmw_Total][itmw_animSet] = animset;

	itmw_ItemTypeWeapon[itemtype] = itmw_Total;

	return itmw_Total++;
}

stock GivePlayerAmmo(playerid, amount)
{
	d:1:HANDLER("[GivePlayerAmmo] player %d amount %d", playerid, amount);
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
	reserveammo = GetItemWeaponItemReserve(itemid);
	magsize = GetItemTypeWeaponMagSize(itemtype);
	maxammo = itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_maxReserveMags] * magsize;

	d:1:HANDLER("[AddAmmoToWeapon] item ammo item: %d mag size: %d", _:ammoitem, magsize);

	if(maxammo == 0)
	{
		d:1:HANDLER("[AddAmmoToWeapon] Adding %d ammo to item %d: ammoitem type: %d magsize: %d reserve: %d", amount, itemid, _:ammoitem, magsize, reserveammo);

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
	d:1:HANDLER("[UpdatePlayerWeaponItem]");
	if(!IsPlayerConnected(playerid))
		return 0;

	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(!IsValidItem(itemid))
	{
		d:1:HANDLER("[UpdatePlayerWeaponItem] ERROR: Invalid item ID %d", itemid);
		return 0;
	}

	if(itmw_ItemTypeWeapon[itemtype] == -1)
	{
		d:1:HANDLER("[UpdatePlayerWeaponItem] ERROR: Item type is not a weapon %d", itmw_ItemTypeWeapon[itemtype]);
		return 0;
	}

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] == NO_CALIBRE)
	{
		GivePlayerWeapon(playerid, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon], 1);
		return 1;
	}

	// Get the item type used as ammo for this weapon item
	new ItemType:ammoitem = GetItemWeaponItemAmmoItem(itemid);

	// If it's not a valid ammo type, the gun has no ammo loaded.
	if(GetItemTypeAmmoType(ammoitem) == -1)
	{
		ResetPlayerWeapons(playerid);
		_UpdateWeaponUI(playerid);
		ShowActionText(playerid, "There is no ammo loaded in this weapon", 3000);
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
		d:1:HANDLER("ERROR: Item weapon %d uses ammo item %d which has a max ammo of %d.", _:itemtype, _:ammoitem, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_magSize]);
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
		GivePlayerWeapon(playerid, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon],
			(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon] == WEAPON_FLAMETHROWER) ? (GetItemWeaponItemMagAmmo(itemid) * 2) : (GetItemWeaponItemMagAmmo(itemid)));
	}

	_UpdateWeaponUI(playerid);

	tick_GetWeaponTick[playerid] = GetTickCount();

	return 1;
}

stock RemovePlayerWeapon(playerid)
{
	d:1:HANDLER("[RemovePlayerWeapon]");
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

	new magammo = GetItemWeaponItemMagAmmo(itemid);

	if(magammo <= 0)
		return;

	SetPlayerArmedWeapon(playerid, itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon]);

	return;
}

timer _RepeatingFire[100](playerid)
{
	new
		itemid,
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

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_baseWeapon] == WEAPON_FLAMETHROWER)
	{
		if(GetTickCountDifference(GetTickCount(), tick_LastReload[playerid]) < 1300)
			return;

		new k, ud, lr;

		GetPlayerKeys(playerid, k, ud, lr);

		if(k & KEY_FIRE)
		{
			SetItemWeaponItemMagAmmo(itemid, magammo - 5);

			if(magammo == 0)
				_ReloadWeapon(playerid);

			_UpdateWeaponUI(playerid);
		}
		else
		{
			stop itmw_RepeatingFireTimer[playerid];
		}
	}

	return;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	d:1:HANDLER("[OnPlayerWeaponShot] %p fired weapon %d", playerid, weaponid);
	if(!_FireWeapon(playerid, weaponid, hittype, hitid, fX, fY, fZ))
		return 0;

	d:1:HANDLER("[OnPlayerWeaponShot END]");

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
	d:2:HANDLER("[_FireWeapon] %p fired weapon %d", playerid, weaponid);
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
	d:1:HANDLER("[_ReloadWeapon]");
	if(GetTickCountDifference(GetTickCount(), tick_LastReload[playerid]) < 1000)
		return 0;

	new
		itemid,
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
		d:1:HANDLER("no reserve ammo left to reload with");

		if(magammo == 0)
		{
			SetItemWeaponItemAmmoItem(itemid, INVALID_ITEM_TYPE);
			ResetPlayerWeapons(playerid);
		}

		return 0;
	}

	if(magammo == magsize)
	{
		d:1:HANDLER("Mag ammo is the same as mag size");
		return 0;
	}

	if(magsize <= 0)
		return 0;

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
				new
					calibre = itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre],
					ItemType:ammotypelist[4],
					ammotypes;

				ammotypes = GetAmmoItemTypesOfCalibre(calibre, ammotypelist);

				if(ammotypes > 0)
				{
					SetItemWeaponItemMagAmmo(itemid, random(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_magSize]));
					SetItemWeaponItemAmmoItem(itemid, ammotypelist[random(ammotypes)]);
				}
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

		if(GetItemTypeWeaponBaseWeapon(GetItemType(itemid)) == WEAPON_FLAMETHROWER)
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
		d:1:HANDLER("[OnPlayerKeyStateChange] dropping item %d magammo %d reserve %d", itmw_DropItemID[playerid], GetItemWeaponItemMagAmmo(itmw_DropItemID[playerid]), GetItemWeaponItemReserve(itmw_DropItemID[playerid]));
		if(IsValidItem(itmw_DropItemID[playerid]))
		{
			d:1:HANDLER("[OnPlayerKeyStateChange] dropping item %d magammo %d reserve %d", itmw_DropItemID[playerid], GetItemWeaponItemMagAmmo(itmw_DropItemID[playerid]), GetItemWeaponItemReserve(itmw_DropItemID[playerid]));
			stop itmw_DropTimer[playerid];
			PlayerDropItem(playerid);
			itmw_DropItemID[playerid] = INVALID_ITEM_ID;
		}
	}

	return 1;
}

public OnPlayerDropItem(playerid, itemid)
{
	if(_unload_DropHandler(playerid, itemid))
		return 1;

	#if defined itmw_OnPlayerDropItem
		return itmw_OnPlayerDropItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
 
#define OnPlayerDropItem itmw_OnPlayerDropItem
#if defined itmw_OnPlayerDropItem
	forward itmw_OnPlayerDropItem(playerid, itemid);
#endif

_unload_DropHandler(playerid, itemid)
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

	d:1:HANDLER("[OnPlayerDropItem] dropping item %d magammo %d reserve %d", itemid, GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid));
	itmw_DropItemID[playerid] = itemid;
	itmw_DropTimer[playerid] = defer _UnloadWeapon(playerid, itemid);

	return 1;
}

timer _UnloadWeapon[300](playerid, itemid)
{
	d:1:HANDLER("[_UnloadWeapon] unloading item %d magammo %d reserve %d", itemid, GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid));
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
		ammoitemid;

	ammoitemtype = GetItemWeaponItemAmmoItem(itemid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	d:1:HANDLER("[_UnloadWeapon] ammo item type %d amount: %d", _:ammoitemtype, GetItemWeaponItemMagAmmo(itemid) + GetItemWeaponItemReserve(itemid));

	ammoitemid = CreateItem(ammoitemtype,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)),
		z - FLOOR_OFFSET,
		_, _, _, FLOOR_OFFSET);

	SetItemExtraData(ammoitemid, GetItemWeaponItemMagAmmo(itemid) + GetItemWeaponItemReserve(itemid));

	SetItemWeaponItemMagAmmo(itemid, 0);
	SetItemWeaponItemReserve(itemid, 0);
	SetItemWeaponItemAmmoItem(itemid, INVALID_ITEM_TYPE);
	UpdatePlayerWeaponItem(playerid);
	itmw_DropItemID[playerid] = INVALID_ITEM_ID;

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
	ShowActionText(playerid, "Unloaded weapon", 3000);

	return;
}

public OnItemNameRender(itemid, ItemType:itemtype)
{
	weapon_NameRenderHandler(itemid, itemtype);

	#if defined itmw_OnItemNameRender
		return itmw_OnItemNameRender(itemid, itemtype);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender itmw_OnItemNameRender
#if defined itmw_OnItemNameRender
	forward itmw_OnItemNameRender(itemid, ItemType:itemtype);
#endif

weapon_NameRenderHandler(itemid, ItemType:itemtype)
{
	new itemweaponid = GetItemTypeWeapon(itemtype);

	if(itemweaponid == -1)
		return 0;

	if(itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_calibre] == NO_CALIBRE)
		return 0;

	new
		ammotype = GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemid)),
		calibrename[MAX_AMMO_CALIBRE_NAME],
		ammoname[MAX_AMMO_CALIBRE_NAME],
		exname[ITM_MAX_TEXT];

	GetCalibreName(itmw_Data[itemweaponid][itmw_calibre], calibrename);

	if(ammotype == -1)
		ammoname = "Unloaded";

	else
		GetAmmoTypeName(ammotype, ammoname);

	format(exname, sizeof(exname), "%d/%d, %s, %s", GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid), calibrename, ammoname);

	SetItemNameExtra(itemid, exname);

	return 1;
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

// itmw_magSize
stock GetPlayerItemWeaponMagSize(playerid)
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

	return itmw_Data[itmw_ItemTypeWeapon[itemtype]][itmw_magSize];
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
	d:1:HANDLER("GetItemWeaponItemAmmoItem itemid:%d", itemid);
	return ItemType:GetItemArrayDataAtCell(itemid, WEAPON_ITEM_ARRAY_CELL_AMMOITEM);
}

stock SetItemWeaponItemAmmoItem(itemid, ItemType:itemtype)
{
	d:1:HANDLER("SetItemWeaponItemAmmoItem itemid:%d, itemtype:%d", itemid, _:itemtype);
	SetItemArrayDataSize(itemid, 4);

	return SetItemArrayDataAtCell(itemid, _:itemtype, WEAPON_ITEM_ARRAY_CELL_AMMOITEM);
}
