new
	ammo_ContainerOption[MAX_PLAYERS];


public OnItemCreated(itemid)
{
	if(GetItemType(itemid) == item_AmmoTin)
	{
		defer ConvertOldAmmoTin(itemid);
		return 1;
	}

	if(GetItemType(itemid) == item_Ammo9mm)
		SetItemExtraData(itemid, random(60));

	if(GetItemType(itemid) == item_Ammo50)
		SetItemExtraData(itemid, random(20));

	if(GetItemType(itemid) == item_AmmoBuck)
		SetItemExtraData(itemid, random(50));

	if(GetItemType(itemid) == item_Ammo556)
		SetItemExtraData(itemid, random(200));

	if(GetItemType(itemid) == item_Ammo338)
		SetItemExtraData(itemid, random(10));

	if(GetItemType(itemid) == item_AmmoRocket)
		SetItemExtraData(itemid, random(2));

	return CallLocalFunction("ammo_OnItemCreated", "d", itemid);
}
#if defined _ALS_OnItemCreated
	#undef OnItemCreated
#else
	#define _ALS_OnItemCreated
#endif
#define OnItemCreated ammo_OnItemCreated
forward ammo_OnItemCreated(itemid);

timer ConvertOldAmmoTin[5](itemid)
{
	new
		type = (GetItemExtraData(itemid) >> 8) & 0xFF,
		amount = GetItemExtraData(itemid) & 0xFF,
		ItemType:itemtype;

	if(!(0 < type <= AMMO_TYPE_ROCKET))
	{
		DestroyItem(itemid);
	}

	switch(type)
	{
		case AMMO_TYPE_9MM:
			itemtype = item_Ammo9mm;

		case AMMO_TYPE_50:
			itemtype = item_Ammo50;

		case AMMO_TYPE_BUCK:
			itemtype = item_AmmoBuck;

		case AMMO_TYPE_556:
			itemtype = item_Ammo556;

		case AMMO_TYPE_308:
			itemtype = item_Ammo338;

		case AMMO_TYPE_ROCKET:
			itemtype = item_AmmoRocket;
	}

	if(itemtype > ItemType:0)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:rx,
			Float:ry,
			Float:rz;

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rx, ry, rz);

		DestroyItem(itemid);
		itemid = CreateItem(itemtype, x, y, z, rx, ry, rz, .zoffset = FLOOR_OFFSET);
		SetItemExtraData(itemid, amount);
	}
}

public OnPlayerViewContainerOpt(playerid, containerid)
{
	if(IsWeaponClipBased(_:GetItemType(GetPlayerItem(playerid))) || IsWeaponClipBased(GetPlayerCurrentWeapon(playerid)))
	{
		new
			itemid,
			weaponid,
			helditem;

		itemid = GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid));
		weaponid = GetPlayerCurrentWeapon(playerid);
		helditem = GetPlayerItem(playerid);

		if(GetItemType(itemid) == GetWeaponAmmoTypeItem(weaponid))
			ammo_ContainerOption[playerid] = AddContainerOption(playerid, "Transfer ammo to gun");

		else if(GetItemType(helditem) == GetWeaponAmmoTypeItem(_:GetItemType(itemid)))
			ammo_ContainerOption[playerid] = AddContainerOption(playerid, "Transfer Ammo to ammo tin");

		else if(GetWeaponAmmoType(_:GetItemType(itemid)) == GetWeaponAmmoType(weaponid))
			ammo_ContainerOption[playerid] = AddContainerOption(playerid, "Transfer Ammo to gun");

		else if(GetItemType(helditem) == GetItemType(itemid))
			ammo_ContainerOption[playerid] = AddContainerOption(playerid, "Transfer Ammo to ammo tin");
	}

	return CallLocalFunction("ammo_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt ammo_OnPlayerViewContainerOpt
forward ammo_OnPlayerViewContainerOpt(playerid, containerid);


public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	if(IsWeaponClipBased(_:GetItemType(GetPlayerItem(playerid))) || IsWeaponClipBased(GetPlayerCurrentWeapon(playerid)))
	{
		if(option == ammo_ContainerOption[playerid])
		{
			new
				itemid,
				weaponid,
				helditem;

			itemid = GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid));
			weaponid = GetPlayerCurrentWeapon(playerid);
			helditem = GetPlayerItem(playerid);

			if(GetItemType(itemid) == GetWeaponAmmoTypeItem(weaponid))
				ShowPlayerDialog(playerid, d_TransferAmmoToGun, DIALOG_STYLE_INPUT, "Transfer Ammo to gun", "Enter the amount of ammo to transfer", "Accept", "Cancel");

			else if(GetItemType(helditem) == GetWeaponAmmoTypeItem(_:GetItemType(itemid)))
				ShowPlayerDialog(playerid, d_TransferAmmoToBox, DIALOG_STYLE_INPUT, "Transfer Ammo to ammo tin", "Enter the amount of ammo to transfer", "Accept", "Cancel");

			else if(GetWeaponAmmoType(_:GetItemType(itemid)) == GetWeaponAmmoType(weaponid))
				ShowPlayerDialog(playerid, d_TransferAmmoToGun, DIALOG_STYLE_INPUT, "Transfer Ammo to gun", "Enter the amount of ammo to transfer", "Accept", "Cancel");

			else if(GetItemType(helditem) == GetItemType(itemid))
				ShowPlayerDialog(playerid, d_TransferAmmoToBox, DIALOG_STYLE_INPUT, "Transfer Ammo to ammo tin", "Enter the amount of ammo to transfer", "Accept", "Cancel");
		}
	}

	return CallLocalFunction("ammo_OnPlayerSelectContainerOpt", "ddd", playerid, containerid, option);
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt ammo_OnPlayerSelectContainerOpt
forward ammo_OnPlayerSelectContainerOpt(playerid, containerid, option);

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_TransferAmmoToGun)
	{
		new containerid = GetPlayerCurrentContainer(playerid);

		if(response)
		{
			new amount = strval(inputtext);

			if(amount > 0)
			{
				new
					slot,
					itemid,
					weaponid,
					remainder;

				slot = GetPlayerContainerSlot(playerid);
				itemid = GetContainerSlotItem(containerid, slot);
				weaponid = GetPlayerCurrentWeapon(playerid);

				if(amount > GetItemExtraData(itemid))
				{
					DisplayContainerInventory(playerid, containerid);
					return 1;
				}

				if(weaponid > 0)
				{
					if(GetWeaponAmmoTypeItem(weaponid) != GetItemType(itemid) && GetWeaponAmmoType(_:GetItemType(itemid)) != GetWeaponAmmoType(weaponid))
					{
						DisplayContainerInventory(playerid, containerid);
						return 1;
					}

					remainder = GivePlayerAmmo(playerid, amount);
					SetItemExtraData(itemid, remainder + GetItemExtraData(itemid) - amount);
				}
				else
				{
					weaponid = _:GetItemType(GetPlayerItem(playerid));

					if(GetWeaponAmmoTypeItem(weaponid) != GetItemType(itemid) && GetWeaponAmmoType(_:GetItemType(itemid)) != GetWeaponAmmoType(weaponid))
					{
						DisplayContainerInventory(playerid, containerid);
						return 1;
					}

					if(IsWeaponClipBased(weaponid))
					{
						remainder = GetAmmunitionRemainder(weaponid, 0, amount);
						SetItemExtraData(GetPlayerItem(playerid), amount - remainder);
						ConvertPlayerItemToWeapon(playerid);
						SetItemExtraData(itemid, remainder + GetItemExtraData(itemid) - amount);
					}
				}
				DisplayContainerInventory(playerid, containerid);
			}
		}
	}
	if(dialogid == d_TransferAmmoToBox)
	{
		new containerid = GetPlayerCurrentContainer(playerid);

		if(response)
		{
			new amount = strval(inputtext);

			if(amount > 0)
			{
				new
					slot,
					itemid,
					total,
					helditem;

				slot = GetPlayerContainerSlot(playerid);
				itemid = GetContainerSlotItem(containerid, slot);
				total = GetItemExtraData(itemid);

				if(amount > total)
				{
					DisplayContainerInventory(playerid, containerid);
					return 1;
				}

				helditem = GetPlayerItem(playerid);

				if(GetItemType(helditem) == GetWeaponAmmoTypeItem(_:GetItemType(itemid)) || GetWeaponAmmoType(_:GetItemType(helditem)) == GetWeaponAmmoType(_:GetItemType(itemid)))
				{
					SetItemExtraData(helditem, GetItemExtraData(helditem) + amount);
					SetItemExtraData(itemid, total - amount);
				}
			}
		}

		DisplayContainerInventory(playerid, containerid);
	}
	return 1;
}

public OnItemNameRender(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Ammo9mm || itemtype == item_Ammo50 || itemtype == item_AmmoBuck ||
		itemtype == item_Ammo556 || itemtype == item_Ammo338 || itemtype == item_AmmoRocket)
	{
		new
			amount = GetItemExtraData(itemid),
			str[11];

		if(amount <= 0)
		{
			str = "Empty";
		}
		else
		{
			valstr(str, amount);
		}

		SetItemNameExtra(itemid, str);
	}

	return CallLocalFunction("ammo_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender ammo_OnItemNameRender
forward ammo_OnItemNameRender(itemid);
