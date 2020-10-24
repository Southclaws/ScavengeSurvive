/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


stock IsBaseWeaponMelee(weaponid)
{
	switch(weaponid)
	{
		case 1..15:
			return 1;
	}
	return 0;
}

stock IsBaseWeaponThrowable(weaponid)
{
	switch(weaponid)
	{
		case 16..18, 39:
			return 1;
	}
	return 0;
}

stock IsBaseWeaponClipBased(weaponid)
{
	switch(weaponid)
	{
		case 22..38, 43:
			return 1;
	}
	return 0;
}

stock IsBaseWeaponNoAmmo(weaponid)
{
	switch(weaponid)
	{
		case 1..18, 39, 40, 44..45:
			return 1;
	}
	return 0;
}

stock IsBaseWeaponDriveby(weaponid)
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

stock IsWeaponMelee(Item:itemid)
{
	return IsBaseWeaponMelee(GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(itemid))));
}

stock IsWeaponThrowable(Item:itemid)
{
	return IsBaseWeaponThrowable(GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(itemid))));
}

stock IsWeaponClipBased(Item:itemid)
{
	return IsBaseWeaponClipBased(GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(itemid))));
}

stock IsWeaponNoAmmo(Item:itemid)
{
	return IsBaseWeaponNoAmmo(GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(itemid))));
}

stock IsWeaponDriveby(Item:itemid)
{
	return IsBaseWeaponDriveby(GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(itemid))));
}
