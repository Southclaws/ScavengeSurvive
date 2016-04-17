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


hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItemWithItem] in /gamemodes/sss/core/item/molotov.pwn");

	if(GetItemType(itemid) == item_GasCan && GetItemType(withitemid) == item_MolotovEmpty)
	{
		if(GetItemExtraData(itemid) > 0)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				Float:rz;

			GetItemPos(withitemid, x, y, z);
			GetItemRot(withitemid, rz, rz, rz);

			DestroyItem(withitemid);
			CreateItem(ItemType:18, x, y, z, .rz = rz, .zoffset = FLOOR_OFFSET);

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
			ShowActionText(playerid, ls(playerid, "MOLOPOURBOT"), 3000);
			SetItemExtraData(itemid, GetItemExtraData(itemid) - 1);
		}
		else
		{
			ShowActionText(playerid, ls(playerid, "PETROLEMPTY"), 3000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
