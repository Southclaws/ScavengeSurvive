/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


hook OnPlayerGetItem(playerid, Item:itemid)
{
	UpdatePlayerWeaponItem(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGivenItem(playerid, targetid, Item:itemid)
{
	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		RemovePlayerWeapon(playerid);
		UpdatePlayerWeaponItem(targetid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, Item:itemid)
{
	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		RemovePlayerWeapon(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	_PickUpAmmoTransferCheck(playerid, itemid, withitemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_PickUpAmmoTransferCheck(playerid, Item:helditemid, Item:ammoitemid)
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

			if(GetItemWeaponFlags(heldtypeid) & WEAPON_FLAG_LIQUID_AMMO)
				return 1;

			if(heldcalibre != GetItemWeaponCalibre(ammotypeid))
			{
				ShowActionText(playerid, ls(playerid, "AMWRONGCALI", true), 3000);
				return 1;
			}

			new ItemType:loadedammoitemtype = GetItemWeaponItemAmmoItem(helditemid);

			if(GetItemTypeAmmoType(loadedammoitemtype) != -1)
			{
				if(loadedammoitemtype != GetItemWeaponItemAmmoItem(ammoitemid))
				{
					ShowActionText(playerid, ls(playerid, "AMDIFFATYPE", true), 5000);
					return 1;
				}
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			defer _TransferWeaponToWeapon(playerid, _:ammoitemid, _:helditemid);

			return 1;
		}

		ammotypeid = GetItemTypeAmmoType(ammoitemtype);

		if(ammotypeid != -1 && !IsAmmoTypeNoTransfer(ammotypeid)) // Transfer ammo from ammo item to held weapon
		{
			new heldcalibre = GetItemWeaponCalibre(heldtypeid);

			if(heldcalibre == NO_CALIBRE)
				return 1;

			if(GetItemWeaponFlags(heldtypeid) & WEAPON_FLAG_LIQUID_AMMO)
			{
				// heldcalibre represents a liquidtype

				if(GetItemTypeLiquidContainerType(GetItemType(ammoitemid)) == -1)
					return 1;

				new
					Float:canfuel,
					Float:transfer;

				canfuel = GetLiquidItemLiquidAmount(ammoitemid);

				if(canfuel <= 0.0)
				{
					ShowActionText(playerid, ls(playerid, "EMPTY", true), 3000);
					return 1;
				}

				transfer = (canfuel - 1.0 < 0.0) ? canfuel : 1.0;
				SetLiquidItemLiquidAmount(ammoitemid, canfuel - transfer);
				SetItemWeaponItemMagAmmo(helditemid, GetItemWeaponItemMagAmmo(helditemid) + floatround(transfer) * 100);
				SetItemWeaponItemAmmoItem(helditemid, item_GasCan);
				UpdatePlayerWeaponItem(playerid);
				// todo: remove dependency on itemtypes for liquid based weaps

				return 1;
			}

			if(heldcalibre != GetAmmoTypeCalibre(ammotypeid))
			{
				ShowActionText(playerid, ls(playerid, "AMWRONGCALI", true), 3000);
				return 1;
			}

			new ItemType:loadedammoitemtype = GetItemWeaponItemAmmoItem(helditemid);

			if(GetItemTypeAmmoType(loadedammoitemtype) != -1)
			{
				if(loadedammoitemtype != ammoitemtype)
				{
					ShowActionText(playerid, ls(playerid, "AMDIFFATYPE", true), 5000);
					return 1;
				}
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			defer _TransferTinToWeapon(playerid, _:ammoitemid, _:helditemid);

			return 1;
		}
	}

	heldtypeid = GetItemTypeAmmoType(helditemtype);

	if(heldtypeid != -1 && !IsAmmoTypeNoTransfer(heldtypeid)) // Player is holding an ammo item
	{
		new ammotypeid = GetItemTypeWeapon(ammoitemtype);

		if(ammotypeid != -1) // Transfer ammo from weapon to held ammo item
		{
			new heldcalibre = GetAmmoTypeCalibre(heldtypeid);

			if(heldcalibre == NO_CALIBRE)
				return 1;

			if(GetItemWeaponFlags(ammotypeid) & WEAPON_FLAG_LIQUID_AMMO)
				return 1;

			if(heldcalibre != GetItemWeaponCalibre(ammotypeid))
			{
				ShowActionText(playerid, ls(playerid, "AMWRONGCALI", true), 3000);
				return 1;
			}

			new ItemType:loadedammoitemtype = GetItemWeaponItemAmmoItem(ammoitemid);

			if(GetItemTypeAmmoType(loadedammoitemtype) != -1)
			{
				if(loadedammoitemtype != helditemtype)
				{
					ShowActionText(playerid, ls(playerid, "AMDIFFATYPE", true), 5000);
					return 1;
				}
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			defer _TransferWeaponToTin(playerid, _:ammoitemid, _:helditemid);

			return 1;
		}

		ammotypeid = GetItemTypeAmmoType(ammoitemtype);

		if(ammotypeid != -1 && !IsAmmoTypeNoTransfer(ammotypeid)) // Transfer ammo from ammo item to held ammo item
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
				ShowActionText(playerid, ls(playerid, "AMMIXINTINS", true), 5000);
				return 1;
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			defer _TransferTinToTin(playerid, _:ammoitemid, _:helditemid);

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

	magammo = GetItemWeaponItemMagAmmo(Item:srcitem);
	reserveammo = GetItemWeaponItemReserve(Item:srcitem);

	if(reserveammo + magammo > 0)
	{
		SetItemWeaponItemAmmoItem(Item:tgtitem, GetItemWeaponItemAmmoItem(Item:srcitem));
		remainder = GivePlayerAmmo(playerid, reserveammo + magammo);

		SetItemWeaponItemMagAmmo(Item:srcitem, 0);
		SetItemWeaponItemReserve(Item:srcitem, remainder);

		ShowActionText(playerid, sprintf(ls(playerid, "AMTRANSWTOW", true), (reserveammo + magammo) - remainder), 3000);
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

	GetItemExtraData(Item:srcitem, ammo);

	if(ammo > 0)
	{
		SetItemWeaponItemAmmoItem(Item:tgtitem, GetItemType(Item:srcitem));
		remainder = GivePlayerAmmo(playerid, ammo);

		if(remainder)
			SetItemExtraData(Item:srcitem, remainder);
		else
			DestroyItem(Item:srcitem);

		ShowActionText(playerid, sprintf(ls(playerid, "AMTRANSTTOW", true), ammo - remainder), 3000);
	}

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}

// Transfer ammo from weapon to held ammo item
timer _TransferWeaponToTin[400](playerid, srcitem, tgtitem)
{
	new
		existing,
		amount = GetItemWeaponItemMagAmmo(Item:srcitem) + GetItemWeaponItemReserve(Item:srcitem);

	GetItemExtraData(Item:tgtitem, existing);

	SetItemExtraData(Item:tgtitem, existing + amount);
	SetItemWeaponItemMagAmmo(Item:srcitem, 0);
	SetItemWeaponItemReserve(Item:srcitem, 0);

	ShowActionText(playerid, sprintf(ls(playerid, "AMTRANSWTOT", true), amount), 3000);

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}

// Transfer ammo from ammo item to held ammo item
timer _TransferTinToTin[400](playerid, srcitem, tgtitem)
{
	new
		existing,
		amount;

	GetItemExtraData(Item:tgtitem, existing);
	GetItemExtraData(Item:srcitem, amount);

	SetItemExtraData(Item:tgtitem, existing + amount);
	SetItemExtraData(Item:srcitem, 0);

	ShowActionText(playerid, sprintf(ls(playerid, "AMTRANSTTOT", true), amount), 3000);

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}


/*==============================================================================

	Transfer ammo in inventories

==============================================================================*/


static
	trans_ContainerOptionID[MAX_PLAYERS] = {-1, ...},
	Item:trans_SelectedItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


hook OnPlayerViewCntOpt(playerid, Container:containerid)
{
	new
		Item:itemid,
		ItemType:itemtype,
		slot;

	GetPlayerContainerSlot(playerid, slot);
	GetContainerSlotItem(containerid, slot, itemid);
	itemtype = GetItemType(itemid);

	if((GetItemTypeWeapon(itemtype) != -1 && GetItemTypeWeaponCalibre(itemtype) != -1) || GetItemTypeAmmoType(itemtype) != -1)
	{
		if(IsValidItem(trans_SelectedItem[playerid]) && trans_SelectedItem[playerid] != itemid)
		{
			trans_ContainerOptionID[playerid] = AddContainerOption(playerid, "Transfer Ammo Here");
		}
		else
		{
			trans_ContainerOptionID[playerid] = AddContainerOption(playerid, "Transfer Ammo...");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectCntOpt(playerid, Container:containerid, option)
{
	if(option == trans_ContainerOptionID[playerid])
	{
		new Item:itemid;
		new slot;
		GetPlayerContainerSlot(playerid, slot);
		GetContainerSlotItem(containerid, slot, itemid);
		if(IsValidItem(trans_SelectedItem[playerid]) && trans_SelectedItem[playerid] != itemid)
		{
			DisplayTransferAmmoDialog(playerid, containerid);
		}
		else
		{
			GetPlayerContainerSlot(playerid, slot);
			GetContainerSlotItem(containerid, slot, trans_SelectedItem[playerid]);
			DisplayContainerInventory(playerid, containerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

DisplayTransferAmmoDialog(playerid, Container:containerid, msg[] = "")
{
	new
		slot,
		Item:sourceitemid,
		ItemType:sourceitemtype,
		sourceitemname[MAX_ITEM_NAME],
		Item:targetitemid,
		ItemType:targetitemtype,
		targetitemname[MAX_ITEM_NAME];

	GetPlayerContainerSlot(playerid, slot);
	sourceitemid = trans_SelectedItem[playerid];
	sourceitemtype = GetItemType(sourceitemid);
	GetItemTypeName(sourceitemtype, sourceitemname);
	GetContainerSlotItem(containerid, slot, targetitemid);
	targetitemtype = GetItemType(targetitemid);
	GetItemTypeName(targetitemtype, targetitemname);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			new amount = strval(inputtext);

			if(GetItemTypeWeapon(sourceitemtype) != -1)
			{
				if(GetItemTypeWeapon(targetitemtype) != -1)
				{
					// weapon to weapon
					new
						sourceitemammo = GetItemWeaponItemReserve(sourceitemid),
						targetitemammo = GetItemWeaponItemReserve(targetitemid);

					if(0 < amount <= sourceitemammo)
					{
						SetItemWeaponItemReserve(sourceitemid, sourceitemammo - amount);
						SetItemWeaponItemReserve(targetitemid, targetitemammo + amount);
						SetItemWeaponItemAmmoItem(targetitemid, sourceitemtype);
					}
					else
					{
						DisplayTransferAmmoDialog(playerid, containerid, sprintf("%s only contains %d ammo", sourceitemname, sourceitemammo));
					}

				}
				else if(GetItemTypeAmmoType(targetitemtype) != -1)
				{
					// weapon to ammo
					new
						sourceitemammo = GetItemWeaponItemReserve(sourceitemid),
						targetitemammo;

					GetItemArrayDataAtCell(targetitemid, targetitemammo, 0);

					if(0 < amount <= sourceitemammo)
					{
						SetItemWeaponItemReserve(sourceitemid, sourceitemammo - amount);
						SetItemArrayDataAtCell(targetitemid, targetitemammo + amount, 0);
					}
					else
					{
						DisplayTransferAmmoDialog(playerid, containerid, sprintf("%s only contains %d ammo", sourceitemname, sourceitemammo));
					}
				}
			}
			else if(GetItemTypeAmmoType(sourceitemtype) != -1)
			{
				if(GetItemTypeWeapon(targetitemtype) != -1)
				{
					// ammo to weapon
					new
						sourceitemammo,
						targetitemammo = GetItemWeaponItemReserve(targetitemid);

					GetItemArrayDataAtCell(sourceitemid, sourceitemammo, 0);

					if(0 < amount <= sourceitemammo)
					{
						SetItemArrayDataAtCell(sourceitemid, sourceitemammo - amount, 0);
						SetItemWeaponItemReserve(targetitemid, targetitemammo + amount);
						SetItemWeaponItemAmmoItem(targetitemid, sourceitemtype);
					}
					else
					{
						DisplayTransferAmmoDialog(playerid, containerid, sprintf("%s only contains %d ammo", sourceitemname, sourceitemammo));
					}
				}
				else if(GetItemTypeAmmoType(targetitemtype) != -1)
				{
					// ammo to ammo
					new
						sourceitemammo,
						targetitemammo;

					GetItemArrayDataAtCell(sourceitemid, sourceitemammo, 0);
					GetItemArrayDataAtCell(targetitemid, targetitemammo, 0);

					if(0 < amount <= sourceitemammo)
					{
						SetItemArrayDataAtCell(sourceitemid, sourceitemammo - amount, 0);
						SetItemArrayDataAtCell(targetitemid, targetitemammo + amount, 0);
					}
					else
					{
						DisplayTransferAmmoDialog(playerid, containerid, sprintf("%s only contains %d ammo", sourceitemname, sourceitemammo));
					}
				}
			}
		}

		trans_ContainerOptionID[playerid] = -1;
		trans_SelectedItem[playerid] = INVALID_ITEM_ID;
		DisplayContainerInventory(playerid, containerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Transfer Ammo", sprintf("Enter amount of ammo to transfer from %s to %s\n\n%s", sourceitemname, targetitemname, msg), "Accept", "Cancel");
}
