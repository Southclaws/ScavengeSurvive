#include <YSI\y_hooks>


static HANDLER;

hook OnGameModeInit()
{
	HANDLER = debug_register_handler("weapon/interact", 4);
}

public OnPlayerGetItem(playerid, itemid)
{
	UpdatePlayerWeaponItem(playerid);

	#if defined itmw_OnPlayerGetItem
		return itmw_OnPlayerGetItem(playerid, itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerGetItem
	#undef OnPlayerGetItem
#else
	#define _ALS_OnPlayerGetItem
#endif
 
#define OnPlayerGetItem itmw_OnPlayerGetItem
#if defined itmw_OnPlayerGetItem
	forward itmw_OnPlayerGetItem(playerid, itemid);
#endif

public OnPlayerGivenItem(playerid, targetid, itemid)
{
	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		RemovePlayerWeapon(playerid);
		UpdatePlayerWeaponItem(targetid);
	}

	return CallLocalFunction("itmw_OnPlayerGivenItem", "ddd", playerid, targetid, itemid);
}
#if defined _ALS_OnPlayerGivenItem
	#undef OnPlayerGivenItem
#else
	#define _ALS_OnPlayerGivenItem
#endif
#define OnPlayerGivenItem itmw_OnPlayerGivenItem
forward itmw_OnPlayerGivenItem(playerid, targetid, itemid);

public OnPlayerDroppedItem(playerid, itemid)
{
	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		RemovePlayerWeapon(playerid);
	}

	#if defined itmw_OnPlayerDroppedItem
		return itmw_OnPlayerDroppedItem(playerid, itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
 
#define OnPlayerDroppedItem itmw_OnPlayerDroppedItem
#if defined itmw_OnPlayerDroppedItem
	forward itmw_OnPlayerDroppedItem(playerid, itemid);
#endif

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	_PickUpAmmoTransferCheck(playerid, itemid, withitemid);

	return CallLocalFunction("itmw_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem itmw_OnPlayerUseItemWithItem
forward itmw_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

_PickUpAmmoTransferCheck(playerid, helditemid, ammoitemid)
{
	new
		ItemType:helditemtype,
		ItemType:ammoitemtype,
		heldtypeid;

	// Item being held and used with world item
	helditemtype = GetItemType(helditemid);
	// Item in the world
	ammoitemtype = GetItemType(ammoitemid);
	// Weapon type of held item
	heldtypeid = GetItemTypeWeapon(helditemtype);

	if(heldtypeid != -1) // Player is holding a weapon
	{
		new ammotypeid = GetItemTypeWeapon(ammoitemtype);

		if(ammotypeid != -1) // Transfer ammo from weapon to held weapon
		{
			new heldcalibre = GetItemWeaponCalibre(heldtypeid);

			if(heldcalibre == NO_CALIBRE)
				return 1;

			if(heldcalibre != GetItemWeaponCalibre(ammotypeid))
			{
				ShowActionText(playerid, "Wrong calibre for weapon", 3000);
				return 1;
			}

			new
				magammo,
				reserveammo,
				remainder;

			magammo = GetItemWeaponItemMagAmmo(ammoitemid);
			reserveammo = GetItemWeaponItemReserve(ammoitemid);

			if(reserveammo + magammo > 0)
			{
				SetItemWeaponItemAmmoItem(helditemid, GetItemWeaponItemAmmoItem(ammoitemid));
				remainder = GivePlayerAmmo(playerid, reserveammo + magammo);

				SetItemWeaponItemMagAmmo(ammoitemid, 0);
				SetItemWeaponItemReserve(ammoitemid, remainder);

				ShowActionText(playerid, sprintf("Transferred %d rounds from weapon to weapon", (reserveammo + magammo) - remainder), 3000);
			}

			return 1;
		}

		ammotypeid = GetItemTypeAmmoType(ammoitemtype);

		if(ammotypeid != -1) // Transfer ammo from ammo item to held weapon
		{
			new heldcalibre = GetItemWeaponCalibre(heldtypeid);

			if(heldcalibre == NO_CALIBRE)
				return 1;

			if(heldcalibre != GetAmmoTypeCalibre(ammotypeid))
			{
				ShowActionText(playerid, "Wrong calibre for weapon", 3000);
				return 1;
			}

			new
				ammo,
				remainder;

			ammo = GetItemExtraData(ammoitemid);

			if(ammo > 0)
			{
				SetItemWeaponItemAmmoItem(helditemid, ammoitemtype);
				remainder = GivePlayerAmmo(playerid, ammo);

				SetItemExtraData(ammoitemid, remainder);

				ShowActionText(playerid, sprintf("Transferred %d rounds from ammo tin to weapon", ammo - remainder), 3000);
			}

			return 1;
		}
	}

	heldtypeid = GetItemTypeAmmoType(helditemtype);

	if(heldtypeid != -1) // Player is holding an ammo item
	{
		new ammotypeid = GetItemTypeWeapon(ammoitemtype);

		d:1:HANDLER("[_PickUpAmmoTransferCheck] Weapon check: ammotypeid: %d", ammotypeid);

		if(ammotypeid != -1) // Transfer ammo from weapon to held ammo item
		{
			new heldcalibre = GetAmmoTypeCalibre(heldtypeid);

			d:1:HANDLER("[_PickUpAmmoTransferCheck]: Holding ammo item, calibre: %d", heldcalibre);

			if(heldcalibre == NO_CALIBRE)
				return 1;

			d:1:HANDLER("[_PickUpAmmoTransferCheck]: Ammo calibre: %d", GetItemWeaponCalibre(ammotypeid));

			if(heldcalibre != GetItemWeaponCalibre(ammotypeid))
			{
				ShowActionText(playerid, "Wrong calibre in weapon", 3000);
				return 1;
			}

			new
				existing = GetItemExtraData(helditemid),
				amount = GetItemWeaponItemMagAmmo(ammoitemid) + GetItemWeaponItemReserve(ammoitemid);

			SetItemExtraData(helditemid, existing + amount);
			SetItemWeaponItemMagAmmo(ammoitemid, 0);
			SetItemWeaponItemReserve(ammoitemid, 0);

			ShowActionText(playerid, sprintf("Transferred %d rounds from weapon to ammo tin", amount), 3000);

			return 1;
		}

		ammotypeid = GetItemTypeAmmoType(ammoitemtype);

		d:1:HANDLER("[_PickUpAmmoTransferCheck] Ammo tin check: ammotypeid: %d", ammotypeid);

		if(ammotypeid != -1) // Transfer ammo from ammo item to held ammo item
		{
			new heldcalibre = GetAmmoTypeCalibre(heldtypeid);

			d:1:HANDLER("[_PickUpAmmoTransferCheck]: Holding ammo item, calibre: %d", heldcalibre);

			if(heldcalibre == NO_CALIBRE)
				return 1;

			d:1:HANDLER("[_PickUpAmmoTransferCheck]: Ammo calibre: %d", GetAmmoTypeCalibre(ammotypeid));

			if(heldcalibre != GetAmmoTypeCalibre(ammotypeid))
			{
				ShowActionText(playerid, "Wrong calibre in ammo tin", 3000);
				return 1;
			}

			new
				existing = GetItemExtraData(helditemid),
				amount = GetItemExtraData(ammoitemid);

			SetItemExtraData(helditemid, existing + amount);
			SetItemExtraData(ammoitemid, 0);

			ShowActionText(playerid, sprintf("Transferred %d rounds from ammo tin to ammo tin", amount), 3000);

			return 1;
		}
	}

	return 1;
}
