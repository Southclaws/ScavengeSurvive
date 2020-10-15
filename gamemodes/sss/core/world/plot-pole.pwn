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


#define DIRECTORY_PLOTPOLE			DIRECTORY_MAIN"plotpole/"
#define PLOTPOLE_AREA_IDENTIFIER	(2817)


#include <YSI_Coding\y_hooks>


enum e_PLOT_POLE_DATA
{
	E_PLOTPOLE_AREA,
	E_PLOTPOLE_OBJ1,
	E_PLOTPOLE_OBJ2,
	E_PLOTPOLE_OBJ3
}

forward OnPlotPoleLoad(itemid, active, geid[], data[], length);
forward OnWorldItemLoad(itemid, active, geid[], data[], length);


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

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "PlotPole"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("PlotPole"), e_PLOT_POLE_DATA);
}

hook OnItemCreateInWorld(itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		new
			data[e_PLOT_POLE_DATA],
			Float:x,
			Float:y,
			Float:z,
			Float:rz,
			areadata[2];

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rz, rz, rz);

		areadata[0] = PLOTPOLE_AREA_IDENTIFIER;
		areadata[1] = itemid;

		data[E_PLOTPOLE_AREA] = CreateDynamicSphere(x, y, z, 20.0, GetItemWorld(itemid), GetItemInterior(itemid));
		data[E_PLOTPOLE_OBJ1] = CreateDynamicObject(1719, x + (0.09200 * floatsin(-rz, degrees)), y + (0.09200 * floatcos(-rz, degrees)), z + 0.52270, 0.00000, 90.00000, rz + 90.0);
		data[E_PLOTPOLE_OBJ2] = CreateDynamicObject(19816, x - (0.08000 * floatsin(-rz, degrees)), y - (0.08000 * floatcos(-rz, degrees)), z + 0.50000, 0.00000, 0.00000, rz);
		data[E_PLOTPOLE_OBJ3] = CreateDynamicObject(19293, x, y, z + 1.3073, 0.00000, 0.00000, rz);

		Streamer_SetArrayData(STREAMER_TYPE_AREA, data[E_PLOTPOLE_AREA], E_STREAMER_EXTRA_ID, areadata);
		SetItemArrayData(itemid, data, e_PLOT_POLE_DATA);

		SaveWorldItem(itemid, DIRECTORY_PLOTPOLE, true, false);

		if(!gServerInitialising)
		{
			_plotpole_saveNearby(itemid);
		}
	}
	else if(IsItemInPlotPoleArea(itemid))
	{
		_SavePlotPoleItem(itemid);
	}

	if(gServerInitialising)
		return Y_HOOKS_CONTINUE_RETURN_0;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_plotpole_saveNearby(itemid)
{
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
		{
			defer _SaveItemFuture(subitem);
		}
	}
}

// as close to asyncio pawn will get!
timer _SaveItemFuture[random(1000)](itemid)
{
	_SavePlotPoleItem(itemid);
}

hook OnItemDestroy(itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		new data[e_PLOT_POLE_DATA];
		GetItemArrayData(itemid, data);
		DestroyDynamicArea(data[E_PLOTPOLE_AREA]);
		DestroyDynamicObject(data[E_PLOTPOLE_OBJ1]);
		DestroyDynamicObject(data[E_PLOTPOLE_OBJ2]);
		DestroyDynamicObject(data[E_PLOTPOLE_OBJ3]);
		RemoveSavedItem(itemid, DIRECTORY_PLOTPOLE);
	}
	else
	{
		RemoveSavedItem(itemid, DIRECTORY_WORLDITEM);
	}
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);

	if(data[0] != PLOTPOLE_AREA_IDENTIFIER)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(IsValidItem(data[1]))
	{
		if(GetItemType(data[1]) == item_PlotPole)
		{
			new geid[GEID_LEN];
			GetItemGEID(data[1], geid);
			ShowActionText(playerid, sprintf(ls(playerid, "PLOTPOLEENT"), geid), 5000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);

	if(data[0] != PLOTPOLE_AREA_IDENTIFIER)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(IsValidItem(data[1]))
	{
		if(GetItemType(data[1]) == item_PlotPole)
		{
			new geid[GEID_LEN];
			GetItemGEID(data[1], geid);
			ShowActionText(playerid, sprintf(ls(playerid, "PLOTPOLELEF"), geid), 5000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromWorld(itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		RemoveSavedItem(itemid, DIRECTORY_PLOTPOLE);
	}
}

hook OnItemArrayDataChanged(itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		new data[4];
		GetItemArrayData(itemid, data);
	}
	if(IsItemInPlotPoleArea(itemid))
	{
		_SavePlotPoleItem(itemid);
	}
}

_SavePlotPoleItem(itemid, playerid = INVALID_PLAYER_ID)
{
	if(_ExcludeItem(itemid))
	{
		RemoveSavedItem(itemid, DIRECTORY_WORLDITEM);
		return;
	}

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


// utils

stock IsPlayerInPlotPoleArea(playerid)
{
	if(!IsPlayerConnected(playerid))
		return false;

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	return IsPointInPlotPoleArea(x, y, z);
}

stock IsItemInPlotPoleArea(itemid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);

	return IsPointInPlotPoleArea(x, y, z);
}

stock IsPointInPlotPoleArea(Float:x, Float:y, Float:z)
{
	new
		areas[64],
		areacount,
		data[2];

	areacount = GetDynamicAreasForPoint(x, y, z, areas);

	for(new i; i < sizeof(areas) && i < areacount; ++i)
	{
		Streamer_GetArrayData(STREAMER_TYPE_AREA, areas[i], E_STREAMER_EXTRA_ID, data, 2);

		if(data[0] == PLOTPOLE_AREA_IDENTIFIER)
		{
			if(GetItemType(data[1]) == item_PlotPole)
				return true;
		}
	}

	return false;
}
