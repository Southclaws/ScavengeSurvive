new
	ammo_ContainerOption[MAX_PLAYERS];


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
		amount = random(GetWeaponAmmoMax(weaponid) * GetWeaponMagSize(weaponid));

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
				remainder;

			data = GetItemExtraData(itemid);
			type = (data >> 8) & 0xFF;
			amount = data & 0xFF;

			if(GetWeaponAmmoType(GetPlayerCurrentWeapon(playerid)) != type)
			{
				DisplayContainerInventory(playerid, containerid);
				return 1;
			}

			remainder = GivePlayerAmmo(playerid, amount);

			if(remainder > 0)
			{
				data = type << 8 | remainder;
				SetItemExtraData(itemid, data);
			}
			else
			{
				DestroyItem(itemid);
			}
		}
	}
	DisplayContainerInventory(playerid, containerid);

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

		if(amount == 0)
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
