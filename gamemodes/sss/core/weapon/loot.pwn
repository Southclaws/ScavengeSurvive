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


#include <YSI\y_hooks>


hook OnItemCreate(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemCreate] in /gamemodes/sss/core/weapon/core.pwn");

	new lootindex = GetItemLootIndex(itemid);

	if(lootindex != -1)
	{
		new ItemType:itemtype = GetItemType(itemid);

		if(GetItemTypeWeapon(itemtype) != -1)
		{
			new calibre = GetItemTypeWeaponCalibre(itemtype);
			if(calibre != NO_CALIBRE)
			{
				new
					ItemType:ammotypelist[4],
					ammotypes;

				ammotypes = GetAmmoItemTypesOfCalibre(calibre, ammotypelist);

				if(ammotypes > 0)
				{
					new magsize = GetItemTypeWeaponMagSize(itemtype);

					if(lootindex == loot_Civilian || lootindex == loot_CarCivilian || lootindex == loot_Survivor)
					{
						SetItemWeaponItemMagAmmo(itemid, random(magsize));
						SetItemWeaponItemAmmoItem(itemid, ammotypelist[random(ammotypes)]);
					}
					else if(lootindex == loot_Police || lootindex == loot_Military || lootindex == loot_CarPolice || lootindex == loot_CarMilitary || lootindex == loot_LowWepCrate || lootindex == loot_MilWepCrate)
					{
						switch(random(100))
						{
							case 00..29: // spawn empty
							{
								SetItemWeaponItemMagAmmo(itemid, 0);
								SetItemWeaponItemAmmoItem(itemid, INVALID_ITEM_TYPE);
							}

							case 30..49: // spawn with random ammo
							{
								SetItemWeaponItemMagAmmo(itemid, random(magsize + 1) - 1);
								SetItemWeaponItemAmmoItem(itemid, ammotypelist[random(ammotypes)]);
							}

							case 50..99: // spawn full
							{
								SetItemWeaponItemMagAmmo(itemid, magsize);
								SetItemWeaponItemAmmoItem(itemid, ammotypelist[random(ammotypes)]);
							}
						}
					}
				}
			}
		}
	}
}
