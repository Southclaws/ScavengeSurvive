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


hook OnPlayerGetItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerGetItem] in /gamemodes/sss/core/weapon/interact.pwn");

	UpdatePlayerWeaponItem(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGivenItem(playerid, targetid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerGivenItem] in /gamemodes/sss/core/weapon/interact.pwn");

	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		RemovePlayerWeapon(playerid);
		UpdatePlayerWeaponItem(targetid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDroppedItem] in /gamemodes/sss/core/weapon/interact.pwn");

	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		RemovePlayerWeapon(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItemWithItem] in /gamemodes/sss/core/weapon/interact.pwn");

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	_PickUpAmmoTransferCheck(playerid, itemid, withitemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

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
				ShowActionText(playerid, ls(playerid, "AMWRONGCALI"), 3000);
				return 1;
			}

			new ItemType:loadedammoitemtype = GetItemWeaponItemAmmoItem(helditemid);

			if(GetItemTypeAmmoType(loadedammoitemtype) != -1)
			{
				if(loadedammoitemtype != GetItemWeaponItemAmmoItem(ammoitemid))
				{
					ShowActionText(playerid, ls(playerid, "AMDIFFATYPE"), 5000);
					return 1;
				}
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			defer _TransferWeaponToWeapon(playerid, ammoitemid, helditemid);

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
				ShowActionText(playerid, ls(playerid, "AMWRONGCALI"), 3000);
				return 1;
			}

			new ItemType:loadedammoitemtype = GetItemWeaponItemAmmoItem(helditemid);

			if(GetItemTypeAmmoType(loadedammoitemtype) != -1)
			{
				if(loadedammoitemtype != ammoitemtype)
				{
					ShowActionText(playerid, ls(playerid, "AMDIFFATYPE"), 5000);
					return 1;
				}
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			defer _TransferTinToWeapon(playerid, ammoitemid, helditemid);

			return 1;
		}
	}

	heldtypeid = GetItemTypeAmmoType(helditemtype);

	if(heldtypeid != -1) // Player is holding an ammo item
	{
		new ammotypeid = GetItemTypeWeapon(ammoitemtype);

		if(ammotypeid != -1) // Transfer ammo from weapon to held ammo item
		{
			new heldcalibre = GetAmmoTypeCalibre(heldtypeid);

			if(heldcalibre == NO_CALIBRE)
				return 1;

			if(heldcalibre != GetItemWeaponCalibre(ammotypeid))
			{
				ShowActionText(playerid, ls(playerid, "AMWRONGCALI"), 3000);
				return 1;
			}

			new ItemType:loadedammoitemtype = GetItemWeaponItemAmmoItem(ammoitemid);

			if(GetItemTypeAmmoType(loadedammoitemtype) != -1)
			{
				if(loadedammoitemtype != helditemtype)
				{
					ShowActionText(playerid, ls(playerid, "AMDIFFATYPE"), 5000);
					return 1;
				}
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			defer _TransferWeaponToTin(playerid, ammoitemid, helditemid);

			return 1;
		}

		ammotypeid = GetItemTypeAmmoType(ammoitemtype);

		if(ammotypeid != -1) // Transfer ammo from ammo item to held ammo item
		{
			/*if(GetItemExtraData(helditemid) == 0)
			{
				new heldcalibre = GetAmmoTypeCalibre(heldtypeid);

				if(heldcalibre == NO_CALIBRE)
					return 1;

				if(heldcalibre != GetAmmoTypeCalibre(ammotypeid))
				{
					ShowActionText(playerid, "Wrong calibre in ammo tin", 3000);
					return 1;
				}
			}*/

			if(ammoitemtype != helditemtype)
			{
				ShowActionText(playerid, ls(playerid, "AMMIXINTINS"), 5000);
				return 1;
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			defer _TransferTinToTin(playerid, ammoitemid, helditemid);

			return 1;
		}
	}

	return 1;
}


// Transfer ammo from weapon to held weapon
timer _TransferWeaponToWeapon[400](playerid, srcitem, tgtitem)
{
	new
		magammo,
		reserveammo,
		remainder;

	magammo = GetItemWeaponItemMagAmmo(srcitem);
	reserveammo = GetItemWeaponItemReserve(srcitem);

	if(reserveammo + magammo > 0)
	{
		SetItemWeaponItemAmmoItem(tgtitem, GetItemWeaponItemAmmoItem(srcitem));
		remainder = GivePlayerAmmo(playerid, reserveammo + magammo);

		SetItemWeaponItemMagAmmo(srcitem, 0);
		SetItemWeaponItemReserve(srcitem, remainder);

		ShowActionText(playerid, sprintf(ls(playerid, "AMTRANSFERW"), (reserveammo + magammo) - remainder), 3000);
	}

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}

// Transfer ammo from ammo item to held weapon
// Damn y_timers and it's length restrictions!
timer _TransferTinToWeapon[400](playerid, srcitem, tgtitem)
{
	new
		ammo,
		remainder;

	ammo = GetItemExtraData(srcitem);

	if(ammo > 0)
	{
		SetItemWeaponItemAmmoItem(tgtitem, GetItemType(srcitem));
		remainder = GivePlayerAmmo(playerid, ammo);

		SetItemExtraData(srcitem, remainder);

		ShowActionText(playerid, sprintf(ls(playerid, "AMTRANSTTOW"), ammo - remainder), 3000);
	}

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}

// Transfer ammo from weapon to held ammo item
timer _TransferWeaponToTin[400](playerid, srcitem, tgtitem)
{
	new
		existing = GetItemExtraData(tgtitem),
		amount = GetItemWeaponItemMagAmmo(srcitem) + GetItemWeaponItemReserve(srcitem);

	SetItemExtraData(tgtitem, existing + amount);
	SetItemWeaponItemMagAmmo(srcitem, 0);
	SetItemWeaponItemReserve(srcitem, 0);

	ShowActionText(playerid, sprintf(ls(playerid, "AMTRANSWTOT"), amount), 3000);

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}

// Transfer ammo from ammo item to held ammo item
timer _TransferTinToTin[400](playerid, srcitem, tgtitem)
{
	new
		existing = GetItemExtraData(tgtitem),
		amount = GetItemExtraData(srcitem);

	SetItemExtraData(tgtitem, existing + amount);
	SetItemExtraData(srcitem, 0);

	ShowActionText(playerid, sprintf(ls(playerid, "AMTRANSTTOT"), amount), 3000);

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}
