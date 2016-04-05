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


#include <YSI_4\y_hooks>


#define MAX_TNT_PROXIMITY	(1024)


enum E_TNT_PROX_DATA
{
			tntpx_areaId,
			tntpx_itemId
}


new
			tntpx_Data[MAX_TNT_PROXIMITY][E_TNT_PROX_DATA],
   Iterator:tntpx_Index<MAX_TNT_PROXIMITY>;


/*==============================================================================

	Core

==============================================================================*/


timer CreateTntMineProx[5000](itemid)
{
	if(IsItemInWorld(itemid) != 1)
		return -1;

	new
		id,
		Float:x,
		Float:y,
		Float:z;

	id = Iter_Free(tntpx_Index);
	GetItemPos(itemid, x, y, z);

	tntpx_Data[id][tntpx_areaId] = CreateDynamicSphere(x, y, z, 5.0);
	tntpx_Data[id][tntpx_itemId] = itemid;

	Iter_Add(tntpx_Index, id);

	return id;
}

timer ExplodeTntProxMineDelay[1000](id)
{
	if(!Iter_Contains(tntpx_Index, id))
		return;

	SetItemToExplode(tntpx_Data[id][tntpx_itemId], 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);
	DestroyDynamicArea(tntpx_Data[id][tntpx_areaId]);

	Iter_Remove(tntpx_Index, id);

	return;
}

hook OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntProxMine)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntProxMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			defer CreateTntMineProx(itemid);
			Msg(playerid, YELLOW, " >  Proximity Mine Primed");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	foreach(new i : tntpx_Index)
	{
		if(areaid == tntpx_Data[i][tntpx_areaId])
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(tntpx_Data[i][tntpx_itemId], x, y, z);

			PlaySoundForAll(6400, x, y, z);
			defer ExplodeTntProxMineDelay(i);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
