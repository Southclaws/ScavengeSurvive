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


#include <YSI_Coding\y_hooks>


#define DIRECTORY_PLOTPOLE	DIRECTORY_MAIN"plotpole/"
#define DIRECTORY_WORLDITEM	DIRECTORY_MAIN"worlditem/"


forward OnPlotPoleLoad(itemid, active, geid[], data[], length);
forward OnWorldItemLoad(itemid, active, geid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_PLOTPOLE);
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_WORLDITEM);
}

hook OnGameModeInit()
{
	LoadItems(DIRECTORY_PLOTPOLE, "OnPlotPoleLoad");
	LoadItems(DIRECTORY_WORLDITEM, "OnWorldItemLoad");
}

hook OnItemCreateInWorld(itemid)
{
	if(gServerInitialising)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetItemType(itemid) == item_PlotPole)
	{
		dbg("gamemodes/sss/extensions/plot-pole-io.pwn", 1, "[OnItemCreateInWorld] Saving Plot Pole item %d", itemid);
		SaveWorldItem(itemid, DIRECTORY_PLOTPOLE, true, false);

		new
			data[2],
			Float:x,
			Float:y,
			Float:z,
			items[128],
			count,
			subitem;

		GetItemPos(itemid, x, y, z);
		count = Streamer_GetNearbyItems(x, y, z, STREAMER_TYPE_AREA, items, .range = 20.0);

		for(new i; i < count; ++i)
		{
			Streamer_GetArrayData(STREAMER_TYPE_AREA, items[i], E_STREAMER_EXTRA_ID, data);

			if(data[0] != BTN_STREAMER_AREA_IDENTIFIER)
				continue;

			subitem = GetItemFromButtonID(data[1]);

			if(IsValidItem(subitem))
				defer _SaveItemFuture(subitem);
		}
	}
	else if(IsItemInPlotPoleArea(itemid))
	{
		_SavePlotPoleItem(itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

// as close to asyncio pawn will get!
timer _SaveItemFuture[random(1000)](itemid)
{
	_SavePlotPoleItem(itemid);
}

hook OnItemRemoveFromWorld(itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		dbg("gamemodes/sss/extensions/plot-pole-io.pwn", 1, "[OnItemRemoveFromWorld] Removing Plot Pole item %d", itemid);
		RemoveSavedItem(itemid, DIRECTORY_PLOTPOLE);
	}
	else
	{
		RemoveSavedItem(itemid, DIRECTORY_WORLDITEM);
	}
}

hook OnItemDestroy(itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		dbg("gamemodes/sss/extensions/plot-pole-io.pwn", 1, "[OnItemDestroy] Removing Plot Pole item %d", itemid);
		RemoveSavedItem(itemid, DIRECTORY_PLOTPOLE);
	}
	else
	{
		RemoveSavedItem(itemid, DIRECTORY_WORLDITEM);
	}
}

hook OnItemArrayDataChanged(itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		new data[4];
		GetItemArrayData(itemid, data);
		dbg("gamemodes/sss/extensions/plot-pole-io.pwn", 1, "[OnItemArrayDataChanged] poltpole array data: %s", atosr(data));

	}
	if(IsItemInPlotPoleArea(itemid))
	{
		dbg("gamemodes/sss/extensions/plot-pole-io.pwn", 1, "[OnItemArrayDataChanged] Item is in plot pole area.");
		_SavePlotPoleItem(itemid);
	}
}

_SavePlotPoleItem(itemid, playerid = INVALID_PLAYER_ID)
{
	dbg("gamemodes/sss/extensions/plot-pole-io.pwn", 1, "[_SavePlotPoleItem] Saving item %d for player %d", itemid, playerid);
	if(_ExcludeItem(itemid))
	{
		dbg("gamemodes/sss/extensions/plot-pole-io.pwn", 2, "[_SavePlotPoleItem] Item is excluded, removing");
		RemoveSavedItem(itemid, DIRECTORY_WORLDITEM);
		return;
	}

	dbg("gamemodes/sss/extensions/plot-pole-io.pwn", 2, "[_SavePlotPoleItem] Item is not excluded");
	SaveWorldItem(itemid, DIRECTORY_WORLDITEM, true);

	if(IsPlayerConnected(playerid))
		ShowActionText(playerid, ls(playerid, "PLOTPOLESAV"), 6000);

	return;
}

_ExcludeItem(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_PlotPole)
		return true;

	if(IsItemTypeSafebox(itemtype))
		return true;

	if(IsItemTypeDefence(itemtype) && GetItemArrayDataAtCell(itemid, def_active))
		return true;

	if(itemtype == item_TentPack && IsValidTent(GetItemExtraData(itemid)))
		return true;

	return false;
}
