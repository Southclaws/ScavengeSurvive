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


hook OnScriptInit()
{
	SetItemTypeMaxArrayData(item_Campfire, 1);
}

hook OnItemCreateInWorld(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemCreateInWorld] in /gamemodes/sss/core/item/campfire.pwn");

	if(GetItemType(itemid) == item_Campfire)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:rz;

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rz, rz, rz);
		SetItemExtraData(itemid, CreateCampfire(x, y, z, rz, GetItemWorld(itemid), GetItemInterior(itemid)));
	}
}

hook OnPlayerPickedUpItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerPickedUpItem] in /gamemodes/sss/core/item/campfire.pwn");

	if(GetItemType(itemid) == item_Campfire)
	{
		DestroyCampfire(GetItemExtraData(itemid));
		defer AttachWoodLogs(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGivenItem(playerid, targetid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerGivenItem] in /gamemodes/sss/core/item/campfire.pwn");

	if(GetItemType(itemid) == item_Campfire)
	{
		defer AttachWoodLogs(targetid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer AttachWoodLogs[0](playerid)
{
	SetPlayerAttachedObject(playerid, ITM_ATTACH_INDEX, 1463, 6, 0.023999, 0.027236, -0.204656, 251.243942, 356.352508, 73.549652, 0.384758, 0.200000, 0.200000);		
}

hook OnPlayerConstructed(playerid, consset)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConstructed] in /gamemodes/sss/core/item/campfire.pwn");

	if(consset <= 3)
	{
		new
			items[MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data],
			count,
			Float:x,
			Float:y,
			Float:z,
			Float:tx,
			Float:ty,
			Float:tz,
			i;

		GetPlayerConstructionItems(playerid, items, count);

		DestroyItem(GetPlayerItem(playerid));

		for( ; i < count && items[i][cft_selectedItemID] != INVALID_ITEM_ID; i++)
		{
			GetItemPos(items[i][cft_selectedItemID], x, y, z);

			if(x * y * z != 0.0)
			{
				tx += x;
				ty += y;
				tz += z;
			}

			DestroyItem(items[i][cft_selectedItemID]);
		}

		tx /= float(i);
		ty /= float(i);
		tz /= float(i);

		CreateItem(item_Campfire, tx, ty, tz, .zoffset = FLOOR_OFFSET, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
