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
		case 22..38, 41..43:
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

stock IsWeaponMelee(itemid)
{
	return IsBaseWeaponMelee(GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(itemid))));
}

stock IsWeaponThrowable(itemid)
{
	return IsBaseWeaponThrowable(GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(itemid))));
}

stock IsWeaponClipBased(itemid)
{
	return IsBaseWeaponClipBased(GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(itemid))));
}

stock IsWeaponNoAmmo(itemid)
{
	return IsBaseWeaponNoAmmo(GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(itemid))));
}

stock IsWeaponDriveby(itemid)
{
	return IsBaseWeaponDriveby(GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(itemid))));
}
