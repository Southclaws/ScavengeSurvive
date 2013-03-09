#include <YSI\y_hooks>


new stock gHolsterWeaponData[MAX_PLAYERS][2];
new
	tick_LastHolstered[MAX_PLAYERS];

stock GetPlayerHolsteredWeapon(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	return gHolsterWeaponData[playerid][0];
}
stock GetPlayerHolsteredWeaponAmmo(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	return gHolsterWeaponData[playerid][1];
}
stock RemovePlayerHolsterWeapon(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	gHolsterWeaponData[playerid][0] = 0;
	gHolsterWeaponData[playerid][1] = 0;

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER);

	return 1;
}
stock RemoveHolsterWeapon(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER);
	gHolsterWeaponData[playerid][0] = 0;
	gHolsterWeaponData[playerid][1] = 0;

	return 1;
}

hook OnGameModeInit()
{
	new
		size,
		name[32];

	DefineItemType("NULL", 0, ITEM_SIZE_SMALL);

	ShiftItemTypeIndex(ItemType:1, 46);

	for(new i = 1; i < 47; i++)
	{
		GetWeaponName(i, name);

		switch(i)
		{
			case 1, 4, 16, 17, 22..24, 41, 43, 44, 45:
				size = ITEM_SIZE_SMALL;

			case 18, 10..13, 26, 28, 32, 39, 40:
				size = ITEM_SIZE_MEDIUM;

			default: size = ITEM_SIZE_LARGE;
		}

		DefineItemType(name, GetWeaponModel(i), size, .rotx = 90.0);
	}
	return 1;
}

hook OnPlayerConnect(playerid)
{
	gHolsterWeaponData[playerid][0] = 0;
	gHolsterWeaponData[playerid][1] = 0;
	return 1;
}

public OnPlayerPickUpItem(playerid, itemid)
{
	new ItemType:type = GetItemType(itemid);

	if(0 < _:type <= WEAPON_PARACHUTE)
	{
		new weaponid = GetPlayerWeapon(playerid);
		if(weaponid != 0)
		{
			if(weaponid != _:type)
			{
				return 1;
			}
		}
	}
	else
	{
		if(GetPlayerWeapon(playerid) != 0)
			return 1;
	}
	return CallLocalFunction("wep_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem wep_OnPlayerPickUpItem
forward wep_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerPickedUpItem(playerid, itemid)
{
	new ItemType:type = GetItemType(itemid);
	if(0 < _:type <= WEAPON_PARACHUTE)
	{
		new weaponid = GetPlayerWeapon(playerid);
		if(weaponid == 0 || weaponid == _:type)
		{
			new ammo = GetItemExtraData(itemid);

			if(ammo > 0)
			{
				GivePlayerWeapon(playerid, _:type, ammo);
				DestroyItem(itemid);
				gPlayerArmedWeapon[playerid] = _:type;
			}
			else if(GetWeaponSlot(_:type) == 0)
			{
				GivePlayerWeapon(playerid, _:type, 1);
				DestroyItem(itemid);
				gPlayerArmedWeapon[playerid] = _:type;
			}
			else return 0;

		}
		else return 1;
	}
	return CallLocalFunction("wep_OnPlayerPickedUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickedUpItem
	#undef OnPlayerPickedUpItem
#else
	#define _ALS_OnPlayerPickedUpItem
#endif
#define OnPlayerPickedUpItem wep_OnPlayerPickedUpItem
forward wep_OnPlayerPickedUpItem(playerid, itemid);

public OnPlayerGivenItem(playerid, targetid, itemid)
{
	new ItemType:type = GetItemType(itemid);
	if(0 < _:type <= WEAPON_PARACHUTE)
	{
		new ammo = GetItemExtraData(itemid);

		if(ammo > 0)
		{
			GivePlayerWeapon(targetid, _:type, ammo);
			DestroyItem(itemid);
			gPlayerArmedWeapon[targetid] = _:type;
			return 1;
		}
		else if(GetWeaponSlot(_:type) == 0)
		{
			GivePlayerWeapon(playerid, _:type, 1);
			DestroyItem(itemid);
			gPlayerArmedWeapon[playerid] = _:type;
		}
		else return 0;
	}
	return CallLocalFunction("wep_OnPlayerGivenItem", "ddd", playerid, targetid, itemid);
}
#if defined _ALS_OnPlayerGivenItem
	#undef OnPlayerGivenItem
#else
	#define _ALS_OnPlayerGivenItem
#endif
#define OnPlayerGivenItem wep_OnPlayerGivenItem
forward wep_OnPlayerGivenItem(playerid, targetid, itemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(GetPlayerItem(playerid) != INVALID_ITEM_ID)
		return 1;

	if(newkeys & KEY_NO && !(newkeys & 128))
	{
		foreach(new i : Player)
		{
			if(i == playerid)
				continue;

			if(IsPlayerInDynamicArea(playerid, gPlayerArea[i]))
			{
				if(tickcount() - tick_LastHolstered[i] < 1000)
					continue;

				if(GetPlayerWeapon(i) != 0)
					continue;

				if(GetPlayerItem(playerid) != INVALID_ITEM_ID || GetPlayerItem(i) != INVALID_ITEM_ID)
					continue;

				if(!IsPlayerIdle(playerid) || !IsPlayerIdle(i))
					continue;

				PlayerGiveWeapon(playerid, i);
				return 1;
			}
		}

		if(IsPlayerIdle(playerid) && gPlayerArmedWeapon[playerid] != 0)
			PlayerDropWeapon(playerid);
	}
	if(newkeys & KEY_YES)
	{
		if(tickcount() - tick_LastHolstered[playerid] < 1000)
			return 1;

		new ItemType:type = ItemType:gPlayerArmedWeapon[playerid];

		if(0 < _:type <= WEAPON_PARACHUTE)
		{
			new ammo = GetPlayerAmmo(playerid);

			if(GetItemTypeSize(type) == ITEM_SIZE_SMALL)
			{
				if(IsPlayerInventoryFull(playerid))
				{
					ShowMsgBox(playerid, "Inventory full", 3000, 100);
					goto holster_wep;
				}
				else
				{
					new itemid = CreateItem(ItemType:type, 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));

					SetItemExtraData(itemid, ammo);
					AddItemToInventory(playerid, itemid);
					RemovePlayerWeapon(playerid, _:type);
					gPlayerArmedWeapon[playerid] = 0;

					ShowMsgBox(playerid, "Item added to inventory", 3000, 150);
				}
			}
			else
			{
				holster_wep:

				switch(type)
				{
					case 2, 3, 5, 6, 7, 8, 15, 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45:
					{
						SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLD, GetWeaponModel(_:type), 6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
						ApplyAnimation(playerid, "PED", "PHONE_IN", 1.7, 0, 0, 0, 0, 700);
						defer HolsterWeapon(playerid, _:type, ammo, 300);
						tick_LastHolstered[playerid] = tickcount();
					}
					case 25, 27, 29, 30, 31, 33, 34, 35, 36:
					{
						SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLD, GetWeaponModel(_:type), 6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
						ApplyAnimation(playerid, "GOGGLES", "GOGGLES_PUT_ON", 1.7, 0, 0, 0, 0, 0);
						defer HolsterWeapon(playerid, _:type, ammo, 800);
						tick_LastHolstered[playerid] = tickcount();
					}
					default:
					{
						ShowMsgBox(playerid, "That item is too big", 3000, 120);
						return 0;
					}
				}
			}
		}
		if(_:type == 0 && GetPlayerItem(playerid) == INVALID_ITEM_ID && gPlayerArmedWeapon[playerid] == 0)
		{
			if(gHolsterWeaponData[playerid][0] != 0)
			{
				switch(gHolsterWeaponData[playerid][0])
				{
					case 2, 3, 5, 6, 7, 8, 15, 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45:
					{
						ApplyAnimation(playerid, "PED", "PHONE_IN", 1.7, 0, 0, 0, 0, 700);
						defer UnholsterWeapon(playerid, 300);
						tick_LastHolstered[playerid] = tickcount();
					}
					case 25, 27, 29, 30, 31, 33, 34, 35, 36:
					{
						ApplyAnimation(playerid, "GOGGLES", "GOGGLES_PUT_ON", 1.7, 0, 0, 0, 0, 0);
						defer UnholsterWeapon(playerid, 800);
						tick_LastHolstered[playerid] = tickcount();
					}
				}
			}
		}
	}
	return 1;
}

timer HolsterWeapon[time](playerid, type, ammo, time)
{
	#pragma unused time
	switch(type)
	{
		case 2, 3, 5, 6, 7, 8, 15:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, GetWeaponModel(type), 1, 0.123097, -0.129424, -0.139251, 0.000000, 301.455871, 0.000000, 1.000000, 1.000000, 1.000000);

		case 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, GetWeaponModel(type), 8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 1.000000, 1.000000, 1.000000 ); // tec9 - small

		case 25, 27, 29, 30, 31, 33, 34:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, GetWeaponModel(type), 1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 1.000000, 1.000000, 1.000000 ); // ak47 - ak

		case 35, 36:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, GetWeaponModel(type), 1, 0.181966, -0.238397, -0.094830, 252.791229, 353.893859, 357.529418, 1.000000, 1.000000, 1.000000 ); // rocketla - rpg

		default: return 0;
	}

	RemovePlayerWeapon(playerid, type);
	if(gHolsterWeaponData[playerid][0] == 0)
	{
		ShowMsgBox(playerid, "Weapon Holstered", 3000, 120);
		gPlayerArmedWeapon[playerid] = 0;
	}
	else
	{
		GivePlayerWeapon(playerid, gHolsterWeaponData[playerid][0], gHolsterWeaponData[playerid][1]);
		ShowMsgBox(playerid, "Weapon Swapped", 3000, 110);
		gPlayerArmedWeapon[playerid] = gHolsterWeaponData[playerid][0];
	}

	gHolsterWeaponData[playerid][0] = type;
	gHolsterWeaponData[playerid][1] = ammo;

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLD);
	ClearAnimations(playerid);

	return 1;
}
timer UnholsterWeapon[time](playerid, time)
{
	#pragma unused time

	GivePlayerWeapon(playerid, gHolsterWeaponData[playerid][0], gHolsterWeaponData[playerid][1]);
	gPlayerArmedWeapon[playerid] = gHolsterWeaponData[playerid][0];

	gHolsterWeaponData[playerid][0] = 0;
	gHolsterWeaponData[playerid][1] = 0;

	ShowMsgBox(playerid, "Weapon Equipped", 3000, 110);
	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER);

	return 1;
}


PlayerDropWeapon(playerid)
{
	new ItemType:type = ItemType:GetPlayerWeapon(playerid);

	if(0 < _:type <= WEAPON_PARACHUTE)
	{
		new
			ammo = GetPlayerAmmo(playerid),
			itemid = CreateItem(ItemType:type, 0.0, 0.0, 0.0,
				.world = GetPlayerVirtualWorld(playerid),
				.interior = GetPlayerInterior(playerid));

		RemovePlayerWeapon(playerid, _:type);
		gPlayerArmedWeapon[playerid] = 0;

		if(GiveWorldItemToPlayer(playerid, itemid, .call = 0))
		{
			PlayerDropItem(playerid);

			switch(GetWeaponSlot(_:type))
			{
				case 0, 1, 10, 11, 12: ammo = 1;
			}
		}
		SetItemExtraData(itemid, ammo);
		return itemid;
	}
	return INVALID_ITEM_ID;
}

PlayerGiveWeapon(playerid, targetid)
{
	new ItemType:type = ItemType:GetPlayerWeapon(playerid);

	if(0 < _:type <= WEAPON_PARACHUTE)
	{
		new
			ammo = GetPlayerAmmo(playerid),
			itemid = CreateItem(ItemType:type, 0.0, 0.0, 0.0,
				.world = GetPlayerVirtualWorld(playerid),
				.interior = GetPlayerInterior(playerid));

		RemovePlayerWeapon(playerid, _:type);
		gPlayerArmedWeapon[playerid] = 0;
		SetItemExtraData(itemid, ammo);
		GiveWorldItemToPlayer(playerid, itemid, .call = 0);
		PlayerGiveItem(playerid, targetid, 1);
		gPlayerArmedWeapon[targetid] = _:type;
	}
}

IsPlayerIdle(playerid)
{
	new animidx = GetPlayerAnimationIndex(playerid);
	switch(animidx)
	{
		case 320, 1164, 1183, 1188, 1189:return 1;
		default: return 0;
	}
	return 0;
}
