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


#define MAX_IED_PROXIMITY	(1024)


enum E_IED_PROX_DATA
{
			iedpx_areaId,
			iedpx_itemId
}


new
			iedpx_Data[MAX_IED_PROXIMITY][E_IED_PROX_DATA],
   Iterator:iedpx_Index<MAX_IED_PROXIMITY>;


/*==============================================================================

	Core

==============================================================================*/


timer CreateIedMineProx[5000](itemid)
{
	if(IsItemInWorld(itemid) != 1)
		return -1;

	new
		id,
		Float:x,
		Float:y,
		Float:z;

	id = Iter_Free(iedpx_Index);
	GetItemPos(itemid, x, y, z);

	iedpx_Data[id][iedpx_areaId] = CreateDynamicSphere(x, y, z, 5.0);
	iedpx_Data[id][iedpx_itemId] = itemid;

	Iter_Add(iedpx_Index, id);

	return id;
}

timer ExplodeIedProxMineDelay[1000](id)
{
	if(!Iter_Contains(iedpx_Index, id))
		return;

	SetItemToExplode(iedpx_Data[id][iedpx_itemId], 11, 8.0, EXPLOSION_PRESET_STRUCTURAL, 1);
	DestroyDynamicArea(iedpx_Data[id][iedpx_areaId]);

	Iter_Remove(iedpx_Index, id);

	return;
}

hook OnPlayerUseItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItem] in /gamemodes/sss/core/item/iedproxmine.pwn");

	if(GetItemType(itemid) == item_IedProxMine)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDroppedItem] in /gamemodes/sss/core/item/iedproxmine.pwn");

	if(GetItemType(itemid) == item_IedProxMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			defer CreateIedMineProx(itemid);
			ChatMsgLang(playerid, YELLOW, "PROXMIARMED");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerEnterDynArea] in /gamemodes/sss/core/item/iedproxmine.pwn");

	foreach(new i : iedpx_Index)
	{
		if(areaid == iedpx_Data[i][iedpx_areaId])
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(iedpx_Data[i][iedpx_itemId], x, y, z);

			PlaySoundForAll(6400, x, y, z);
			defer ExplodeIedProxMineDelay(i);
		}
	}
}
