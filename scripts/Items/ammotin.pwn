new
	ammo_ContainerOption[MAX_PLAYERS];


stock SetAmmoTinType(itemid, type)
{
	if(!IsValidItem(itemid))
		return 0;

	new
		data,
		amount;

	data = GetItemExtraData(itemid);
	amount = data & 0xFF;

	SetItemExtraData(itemid, type << 8 | amount);

	return 1;
}
stock SetAmmoTinAmount(itemid, amount)
{
	if(!IsValidItem(itemid))
		return 0;

	new
		data,
		type;

	data = GetItemExtraData(itemid);
	type = (data >> 8) & 0xFF;

	SetItemExtraData(itemid, type << 8 | amount);

	return 1;
}

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_AmmoTin)
	{
		// First 8 bits represent the type last 8 bits represent the amount
		new
			weaponid,
			type,
			amount;

		weaponid = 22 + random(17);
		type = GetWeaponAmmoType(weaponid);
		amount = random((random(1) + 1) * GetWeaponMagSize(weaponid));

		SetItemExtraData(itemid, type << 8 | amount);
	}

	return CallLocalFunction("ammo_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate ammo_OnItemCreate
forward ammo_OnItemCreate(itemid);


public OnPlayerViewContainerOpt(playerid, containerid)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_AmmoTin)
	{
		ammo_ContainerOption[playerid] = AddContainerOption(playerid, "Load into equipped weapon");
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
	if(GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) == item_AmmoTin)
	{
		if(option == ammo_ContainerOption[playerid])
		{
			new
				slot,
				itemid;

			slot = GetPlayerContainerSlot(playerid);
			itemid = GetContainerSlotItem(containerid, slot);

			if(GetItemType(itemid) == item_AmmoTin)
			{
				if(option == ammo_ContainerOption[playerid])
				{
					new
						data,
						type,
						amount,
						weaponid,
						remainder;

					data = GetItemExtraData(itemid);
					type = (data >> 8) & 0xFF;
					amount = data & 0xFF;
					weaponid = GetPlayerCurrentWeapon(playerid);

					if(weaponid > 0)
					{
						if(GetWeaponAmmoType(weaponid) != type)
						{
							DisplayContainerInventory(playerid, containerid);
							return 1;
						}

						remainder = GivePlayerAmmo(playerid, amount);

						data = type << 8 | remainder;
						SetItemExtraData(itemid, data);
					}
					else
					{
						weaponid = _:GetItemType(GetPlayerItem(playerid));

						if(IsWeaponClipBased(weaponid))
						{
							remainder = GetAmmunitionRemainder(weaponid, 0, amount);
							SetItemExtraData(GetPlayerItem(playerid), amount - remainder);
							ConvertPlayerItemToWeapon(playerid);

							data = type << 8 | remainder;
							SetItemExtraData(itemid, data);
						}
					}
				}
			}
			DisplayContainerInventory(playerid, containerid);
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

public OnItemNameRender(itemid)
{
	if(GetItemType(itemid) == item_AmmoTin)
	{
		new
			type = (GetItemExtraData(itemid) >> 8) & 0xFF,
			amount = GetItemExtraData(itemid) & 0xFF,
			name[9],
			str[16];

		if(amount <= 0 || type > AMMO_TYPE_5MM)
		{
			str = "Empty";
		}
		else
		{
			GetAmmoTypeName(type, name);
			format(str, 16, "%s, %d", name, amount);
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
