#include <YSI\y_hooks>


new
		wep_HolsterData[MAX_PLAYERS][2],
		wep_CurrentWeapon[MAX_PLAYERS],
		wep_ReserveAmmo[MAX_PLAYERS],
		tick_LastHolstered[MAX_PLAYERS],
		tick_LastReload[MAX_PLAYERS];


forward OnPlayerUseWeaponWithItem(playerid, weapon, itemid);


// Zeroing and Load


hook OnGameModeInit()
{
	new
		size,
		name[32],
		ItemType:itemtype;

	DefineItemType("NULL", 0, ITEM_SIZE_SMALL);

	ShiftItemTypeIndex(ItemType:1, 46);

	for(new i = 1; i < 46; i++)
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

		itemtype = DefineItemType(name, GetWeaponModel(i), size, .rotx = 90.0);
		DefineItemCombo(itemtype, itemtype, itemtype);
	}
	print("Loaded weapon item data");
	return 1;
}
hook OnPlayerConnect(playerid)
{
	wep_HolsterData[playerid][0] = 0;
	wep_HolsterData[playerid][1] = 0;
	return 1;
}
hook OnPlayerDeath(playerid, killerid, reason)
{
	wep_CurrentWeapon[playerid] = 0;
	wep_ReserveAmmo[playerid] = 0;
}


// Core


SetPlayerWeapon(playerid, weaponid, ammo)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(wep_CurrentWeapon[playerid] == 0)
	{
		if(ammo > GetWeaponMagSize(weaponid))
		{
			if(GetWeaponAmmoMax(weaponid) > 0)
				wep_ReserveAmmo[playerid] += ammo - GetWeaponMagSize(weaponid);

			ammo = GetWeaponMagSize(weaponid);
		}
		else
		{
		}

		UpdateWeaponUI(playerid);
	}
	else
	{
		if(weaponid != wep_CurrentWeapon[playerid])
			return 0;

		GivePlayerAmmo(playerid, ammo);
		ammo = 0;
	}

	ResetPlayerWeapons(playerid);
	wep_CurrentWeapon[playerid] = weaponid;
	return GivePlayerWeapon(playerid, weaponid, ammo);
}

GivePlayerAmmo(playerid, amount)
{
	new maxammo = GetWeaponAmmoMax(wep_CurrentWeapon[playerid]) * GetWeaponMagSize(wep_CurrentWeapon[playerid]);

	if(wep_ReserveAmmo[playerid] + amount > maxammo)
	{
		new remainder = wep_ReserveAmmo[playerid] + amount - maxammo;
		wep_ReserveAmmo[playerid] = maxammo;
		UpdateWeaponUI(playerid);
		return remainder;
	}
	else
	{
		wep_ReserveAmmo[playerid] += amount;
		UpdateWeaponUI(playerid);
		return 0;
	}
}

SetPlayerHolsterWeapon(playerid, weaponid, ammo)
{
	switch(weaponid)
	{
		case 2, 3, 5, 6, 7, 8, 15:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, GetWeaponModel(weaponid), 1, 0.123097, -0.129424, -0.139251, 0.000000, 301.455871, 0.000000, 1.000000, 1.000000, 1.000000);

		case 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, GetWeaponModel(weaponid), 8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 1.000000, 1.000000, 1.000000 ); // tec9 - small

		case 25, 27, 29, 30, 31, 33, 34:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, GetWeaponModel(weaponid), 1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 1.000000, 1.000000, 1.000000 ); // ak47 - ak

		case 35, 36:
			SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, GetWeaponModel(weaponid), 1, 0.181966, -0.238397, -0.094830, 252.791229, 353.893859, 357.529418, 1.000000, 1.000000, 1.000000 ); // rocketla - rpg

		default: return 0;
	}

	wep_HolsterData[playerid][0] = weaponid;
	wep_HolsterData[playerid][1] = ammo;

	return 1;
}

stock GetPlayerCurrentWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return wep_CurrentWeapon[playerid];
}

stock GetPlayerHolsteredWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return wep_HolsterData[playerid][0];
}

stock GetPlayerTotalAmmo(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return GetPlayerAmmo(playerid) + wep_ReserveAmmo[playerid];
}

stock GetPlayerClipAmmo(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return GetPlayerAmmo(playerid);
}

stock GetPlayerReserveAmmo(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return wep_ReserveAmmo[playerid];
}

stock GetPlayerHolsteredWeaponAmmo(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return wep_HolsterData[playerid][1];
}

stock GetPlayerWeaponSwapTick(playerid)
{
	return tick_LastHolstered[playerid];
}

stock RemovePlayerWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ResetPlayerWeapons(playerid);
	wep_CurrentWeapon[playerid] = 0;
	wep_ReserveAmmo[playerid] = 0;

	return 1;
}

stock RemovePlayerHolsterWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER);
	wep_HolsterData[playerid][0] = 0;
	wep_HolsterData[playerid][1] = 0;

	return 1;
}

stock IsWeaponMelee(weaponid)
{
	switch(weaponid)
	{
		case 1..15:
			return 1;
	}
	return 0;
}

stock IsWeaponThrowable(weaponid)
{
	switch(weaponid)
	{
		case 16..18, 39:
			return 1;
	}
	return 0;
}

stock IsWeaponClipBased(weaponid)
{
	switch(weaponid)
	{
		case 22..38, 41..43:
			return 1;
	}
	return 0;
}

stock IsWeaponOneShot(weaponid)
{
	switch(weaponid)
	{
		case :
			return 1;
	}
	return 0;
}

stock GetAmmunitionRemainder(weaponid, startammo, ammunition)
{
	return startammo + ammunition - (GetWeaponAmmoMax(weaponid) * GetWeaponMagSize(weaponid));
}


// Hooks and Internal


hook OnPlayerUpdate(playerid)
{
	UpdateWeaponUI(playerid);

	if(wep_CurrentWeapon[playerid] == 0)
		return 1;

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	{
		SetPlayerArmedWeapon(playerid, wep_CurrentWeapon[playerid]);

		new
			id,
			ammo;

		GetPlayerWeaponData(playerid, GetWeaponSlot(wep_CurrentWeapon[playerid]), id, ammo);

		if(ammo == 0 && wep_CurrentWeapon[playerid] == id && id != 0)
		{
			if(ReloadWeapon(playerid) == -1)
			{
				RemovePlayerWeapon(playerid);
			}
		}
	}

	return 1;
}

ReloadWeapon(playerid)
{
	if(tickcount() - tick_LastReload[playerid] < 1000)
		return 0;

	if(!IsWeaponClipBased(wep_CurrentWeapon[playerid]))
		return -1;

	if(GetPlayerAmmo(playerid) == GetWeaponMagSize(wep_CurrentWeapon[playerid]))
		return -2;

	if(wep_CurrentWeapon[playerid] == 0)
		return -3;

	if(wep_ReserveAmmo[playerid] <= 0)
	{
		if(GetPlayerAmmo(playerid) <= 0)
		{
			GiveWorldItemToPlayer(playerid, CreateItem(ItemType:wep_CurrentWeapon[playerid]));
			ResetPlayerWeapons(playerid);
			wep_CurrentWeapon[playerid] = 0;
			wep_ReserveAmmo[playerid] = 0;
		}

		return 0;
	}

	new
		clip = GetPlayerAmmo(playerid),
		ammo;

	if(wep_ReserveAmmo[playerid] + clip > GetWeaponMagSize(wep_CurrentWeapon[playerid]))
	{
		ammo = GetWeaponMagSize(wep_CurrentWeapon[playerid]);
		wep_ReserveAmmo[playerid] -= (GetWeaponMagSize(wep_CurrentWeapon[playerid]) - clip);
	}
	else
	{
		ammo = wep_ReserveAmmo[playerid] + clip;
		wep_ReserveAmmo[playerid] = 0;
	}

	switch(wep_CurrentWeapon[playerid])
	{
		default:
			ApplyAnimation(playerid, "COLT45", "COLT45_RELOAD", 4.1, 0, 1, 1, 0, 0);
	}

	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, wep_CurrentWeapon[playerid], ammo);
	UpdateWeaponUI(playerid);

	tick_LastReload[playerid] = tickcount();

	return 1;
}

UpdateWeaponUI(playerid)
{
	if(IsWeaponClipBased(wep_CurrentWeapon[playerid]))
	{
		if(GetPlayerAmmo(playerid) > GetWeaponMagSize(wep_CurrentWeapon[playerid]))
			SetPlayerAmmo(playerid, wep_CurrentWeapon[playerid], GetWeaponMagSize(wep_CurrentWeapon[playerid]));

		new str[8];

		if(GetWeaponAmmoMax(wep_CurrentWeapon[playerid]) > 0)
			format(str, 8, "%d/%d", GetPlayerAmmo(playerid), wep_ReserveAmmo[playerid]);

		else
			format(str, 8, "%d", GetPlayerAmmo(playerid));

		PlayerTextDrawSetString(playerid, WeaponAmmo, str);
		PlayerTextDrawShow(playerid, WeaponAmmo);
	}
	else
	{
		PlayerTextDrawHide(playerid, WeaponAmmo);
	}
}

ConvertPlayerItemToWeapon(playerid)
{
	new
		itemid,
		ItemType:itemtype,
		ammo;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);
	ammo = GetItemExtraData(itemid);

	if(!(1 <= _:itemtype <= 46))
		return 0;

	if(ammo <= 0)
		return 0;

	DestroyItem(itemid);
	SetPlayerWeapon(playerid, _:itemtype, ammo);

	return 1;
}

ConvertPlayerWeaponToItem(playerid)
{
	new
		weaponid,
		ammo,
		itemid;

	weaponid = wep_CurrentWeapon[playerid];
	ammo = GetPlayerAmmo(playerid) + wep_ReserveAmmo[playerid];

	if(weaponid == 0)
		return 0;

	RemovePlayerWeapon(playerid);

	itemid = CreateItem(ItemType:weaponid);
	GiveWorldItemToPlayer(playerid, itemid);
	SetItemExtraData(itemid, ammo);

	return 1;
}

public OnPlayerPickUpItem(playerid, itemid)
{
	new ItemType:type = GetItemType(itemid);

	if(0 < _:type < WEAPON_PARACHUTE)
	{
		if(wep_CurrentWeapon[playerid] == 0)
		{
			if(GetItemExtraData(itemid) > 0)
			{
				PlayerPickUpWeapon(playerid, itemid);
				return 1;
			}
		}
		else if(IsWeaponClipBased(wep_CurrentWeapon[playerid]))
		{
			if(wep_CurrentWeapon[playerid] != _:type)
			{
				return 1;
			}
			else
			{
				if(GetItemExtraData(itemid) == 0)
					return 1;

				PlayerPickUpWeapon(playerid, itemid);
				return 1;
			}
		}
		else
		{
			return 1;
		}
	}
	else
	{
		if(GetPlayerWeapon(playerid) != 0)
		{
			CallLocalFunction("OnPlayerUseWeaponWithItem", "ddd", playerid, GetPlayerWeapon(playerid), itemid);

			return 1;
		}
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

public OnPlayerGivenItem(playerid, targetid, itemid)
{
	if(wep_CurrentWeapon[targetid] != 0)
		return 1;

	new ItemType:type = GetItemType(itemid);

	if(0 < _:type < WEAPON_PARACHUTE)
	{
		new ammo = GetItemExtraData(itemid);

		if(ammo > 0)
		{
			SetPlayerWeapon(targetid, _:type, ammo);
			DestroyItem(itemid);
			wep_CurrentWeapon[targetid] = _:type;
			return 1;
		}
		else if(GetWeaponSlot(_:type) == 0)
		{
			SetPlayerWeapon(playerid, _:type, 1);
			DestroyItem(itemid);
			wep_CurrentWeapon[playerid] = _:type;
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

public OnPlayerRemoveFromInventory(playerid, slotid)
{
	new
		itemid,
		ItemType:itemtype;

	itemid = GetInventorySlotItem(playerid, slotid);
	itemtype = GetItemType(itemid);

	if(0 < _:itemtype < WEAPON_PARACHUTE)
	{
		SetPlayerWeapon(playerid, _:itemtype, GetItemExtraData(itemid));
		DestroyItem(itemid);
	}

	return CallLocalFunction("wep_OnPlayerRemoveFromInv", "dd", playerid, slotid);
}
#if defined _ALS_OnPlayerRemoveFromInv
	#undef OnPlayerRemoveFromInventory
#else
	#define _ALS_OnPlayerRemoveFromInv
#endif
#define OnPlayerRemoveFromInventory wep_OnPlayerRemoveFromInv
forward OnPlayerRemoveFromInventory(playerid, slotid);

public OnItemRemoveFromContainer(containerid, slotid, playerid)
{
	new
		itemid,
		ItemType:itemtype;

	itemid = GetContainerSlotItem(containerid, slotid);
	itemtype = GetItemType(itemid);

	if(0 < _:itemtype < WEAPON_PARACHUTE)
	{
		SetPlayerWeapon(playerid, _:itemtype, GetItemExtraData(itemid));
		DestroyItem(itemid);
	}

	return CallLocalFunction("wep_OnItemRemoveFromContainer", "ddd", containerid, slotid, playerid);
}
#if defined _ALS_OnItemRemoveFromContainer
	#undef OnItemRemoveFromContainer
#else
	#define _ALS_OnItemRemoveFromContainer
#endif
#define OnItemRemoveFromContainer wep_OnItemRemoveFromContainer
forward wep_OnItemRemoveFromContainer(containerid, slotid, playerid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(GetPlayerItem(playerid) != INVALID_ITEM_ID)
		return 1;

	if(newkeys & 1)
	{
		ReloadWeapon(playerid);
	}

	if(newkeys & KEY_NO && !(newkeys & 128))
	{
		if(IsPlayerIdle(playerid) && wep_CurrentWeapon[playerid] != 0)
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

					if(!IsPlayerIdle(i))
						continue;

					if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[i] & AdminDuty || bPlayerGameSettings[i] & KnockedOut || GetPlayerAnimationIndex(i) == 1381)
						continue;

					PlayerGiveWeapon(playerid, i);
					return 1;
				}
			}

			PlayerDropWeapon(playerid);
		}
	}
	if(newkeys & KEY_YES)
	{
		if(tickcount() - tick_LastHolstered[playerid] < 1000)
			return 1;

		if(IsValidItem(GetPlayerItem(playerid)))
			return 1;

		if(0 < wep_CurrentWeapon[playerid] < WEAPON_PARACHUTE)
		{
			new ammo = GetPlayerAmmo(playerid) + wep_ReserveAmmo[playerid];

			switch(wep_CurrentWeapon[playerid])
			{
				case 2, 3, 5, 6, 7, 8, 15, 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45:
				{
					SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLD, GetWeaponModel(wep_CurrentWeapon[playerid]), 6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
					ApplyAnimation(playerid, "PED", "PHONE_IN", 1.7, 0, 0, 0, 0, 700);
					defer HolsterWeaponDelay(playerid, wep_CurrentWeapon[playerid], ammo, 300);
					tick_LastHolstered[playerid] = tickcount();
				}
				case 25, 27, 29, 30, 31, 33, 34, 35, 36:
				{
					SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLD, GetWeaponModel(wep_CurrentWeapon[playerid]), 6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
					ApplyAnimation(playerid, "GOGGLES", "GOGGLES_PUT_ON", 1.7, 0, 0, 0, 0, 0);
					defer HolsterWeaponDelay(playerid, wep_CurrentWeapon[playerid], ammo, 800);
					tick_LastHolstered[playerid] = tickcount();
				}
				default:
				{
					ShowMsgBox(playerid, "Weapon too big", 3000, 120);
					return 0;
				}
			}
		}
		else if(wep_CurrentWeapon[playerid] == 0)
		{
			if(wep_CurrentWeapon[playerid] == 0)
			{
				if(wep_HolsterData[playerid][0] != 0)
				{
					switch(wep_HolsterData[playerid][0])
					{
						case 2, 3, 5, 6, 7, 8, 15, 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45:
						{
							ApplyAnimation(playerid, "PED", "PHONE_IN", 1.7, 0, 0, 0, 0, 700);
							defer UnholsterWeaponDelay(playerid, 300);
							tick_LastHolstered[playerid] = tickcount();
						}
						case 25, 27, 29, 30, 31, 33, 34, 35, 36:
						{
							ApplyAnimation(playerid, "GOGGLES", "GOGGLES_PUT_ON", 1.7, 0, 0, 0, 0, 0);
							defer UnholsterWeaponDelay(playerid, 800);
							tick_LastHolstered[playerid] = tickcount();
						}
					}
				}
			}
		}
	}
	return 1;
}

timer HolsterWeaponDelay[time](playerid, weaponid, ammo, time)
{
	#pragma unused time
	HolsterWeapon(playerid, weaponid, ammo);
}

timer UnholsterWeaponDelay[time](playerid, time)
{
	#pragma unused time
	UnholsterWeapon(playerid);
}


HolsterWeapon(playerid, weaponid, ammo)
{
	if(wep_CurrentWeapon[playerid] == 0)
		return 1;

	new
		curweap = wep_HolsterData[playerid][0],
		curammo = wep_HolsterData[playerid][1];

	SetPlayerHolsterWeapon(playerid, weaponid, ammo);
	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLD);
	ClearAnimations(playerid);
	RemovePlayerWeapon(playerid);

	if(curweap == 0)
	{
		ShowMsgBox(playerid, "Weapon Holstered", 3000, 120);
	}
	else
	{
		SetPlayerWeapon(playerid, curweap, curammo);
		ShowMsgBox(playerid, "Weapon Swapped", 3000, 110);
	}

	return 1;
}

UnholsterWeapon(playerid)
{
	SetPlayerWeapon(playerid, wep_HolsterData[playerid][0], wep_HolsterData[playerid][1]);
	wep_CurrentWeapon[playerid] = wep_HolsterData[playerid][0];

	wep_HolsterData[playerid][0] = 0;
	wep_HolsterData[playerid][1] = 0;

	ShowMsgBox(playerid, "Weapon Equipped", 3000, 110);
	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER);

	return 1;
}

PlayerPickUpWeapon(playerid, itemid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:ix,
		Float:iy,
		Float:iz;

	GetPlayerPos(playerid, x, y, z);
	GetItemPos(itemid, ix, iy, iz);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(x, y, ix, iy));

	if((z - iz) < 0.3)
	{
		ApplyAnimation(playerid, "CASINO", "SLOT_PLYR", 4.0, 0, 0, 0, 0, 0);
		defer PickUpWeaponDelay(playerid, itemid, 1);
	}
	else
	{
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 0, 0, 0, 0, 450);
		defer PickUpWeaponDelay(playerid, itemid, 0);
	}
}
timer PickUpWeaponDelay[400](playerid, itemid, animtype)
{
	if(animtype == 0)
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);

	new ItemType:type = GetItemType(itemid);

	if(0 < _:type < WEAPON_PARACHUTE)
	{
		if(wep_CurrentWeapon[playerid] == 0)
		{
			new ammo;

			if(IsWeaponClipBased(_:type))
				ammo = GetItemExtraData(itemid);

			else
				ammo = 1;

			if(ammo > 0)
			{
				SetPlayerWeapon(playerid, _:type, ammo);
				DestroyItem(itemid);
				wep_CurrentWeapon[playerid] = _:type;
			}
		}
		else if(wep_CurrentWeapon[playerid] == _:type)
		{
			new ammo = GetItemExtraData(itemid);

			if(ammo > 0)
			{
				new remainder = GivePlayerAmmo(playerid, ammo);

				if(remainder == 0)
				{
					DestroyItem(itemid);
				}
				else
				{
					SetItemExtraData(itemid, remainder);
				}
			}
		}
	}
}

PlayerDropWeapon(playerid)
{
	ConvertPlayerWeaponToItem(playerid);
	PlayerDropItem(playerid);
}

PlayerGiveWeapon(playerid, targetid)
{
	if(wep_CurrentWeapon[playerid] > 0)
	{
		ConvertPlayerItemToWeapon(playerid);
		PlayerGiveItem(playerid, targetid, 1);
		wep_CurrentWeapon[targetid] = wep_CurrentWeapon[playerid];
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

public OnItemNameRender(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(0 <= _:itemtype < WEAPON_PARACHUTE)
	{
		if(GetWeaponMagSize(_:itemtype) > 1)
		{
			new exname[5];
			valstr(exname, GetItemExtraData(itemid));
			SetItemNameExtra(itemid, exname);
		}
	}

	return CallLocalFunction("wep_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender wep_OnItemNameRender
forward wep_OnItemNameRender(itemid);

stock IsWeaponDriveby(weaponid)
{
	switch(weaponid)
	{
		case 28, 29, 32:
		{
			return 1;
		}
	}
	return 0;
}
