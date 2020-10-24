/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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

forward OnPlotPoleLoad(itemid, active, uuid[], data[], length);
forward OnWorldItemLoad(itemid, active, uuid[], data[], length);


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

hook OnItemCreateInWorld(Item:itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		new
			data[e_PLOT_POLE_DATA],
			Float:x,
			Float:y,
			Float:z,
			Float:rz,
			world,
			interior,
			areadata[2];

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rz, rz, rz);
		GetItemWorld(itemid, world);
		GetItemInterior(itemid, interior);

		areadata[0] = PLOTPOLE_AREA_IDENTIFIER;
		areadata[1] = _:itemid;

		data[E_PLOTPOLE_AREA] = CreateDynamicSphere(x, y, z, 20.0, world, interior);
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

_plotpole_saveNearby(Item:itemid)
{
	new
		data[2],
		Float:x,
		Float:y,
		Float:z,
		items[128],
		count,
		Item:subitem;

	GetItemPos(itemid, x, y, z);
	count = Streamer_GetNearbyItems(x, y, z, STREAMER_TYPE_AREA, items, .range = 20.0);

	for(new i; i < count; ++i)
	{
		Streamer_GetArrayData(STREAMER_TYPE_AREA, items[i], E_STREAMER_EXTRA_ID, data);

		if(data[0] != BTN_STREAMER_AREA_IDENTIFIER)
			continue;

		subitem = GetItemFromButtonID(Button:data[1]);

		if(IsValidItem(subitem))
		{
			defer _SaveItemFuture(_:subitem);
		}
	}
}

// as close to asyncio pawn will get!
timer _SaveItemFuture[random(1000)](itemid)
{
	_SavePlotPoleItem(Item:itemid);
}

hook OnItemDestroy(Item:itemid)
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

hook OnPlayerPickUpItem(playerid, Item:itemid)
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

	if(IsValidItem(Item:data[1]))
	{
		if(GetItemType(Item:data[1]) == item_PlotPole)
		{
			new uuid[UUID_LEN];
			GetItemUUID(Item:data[1], uuid);
			ShowActionText(playerid, sprintf(ls(playerid, "PLOTPOLEENT"), uuid), 5000);
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

	if(IsValidItem(Item:data[1]))
	{
		if(GetItemType(Item:data[1]) == item_PlotPole)
		{
			new uuid[UUID_LEN];
			GetItemUUID(Item:data[1], uuid);
			ShowActionText(playerid, sprintf(ls(playerid, "PLOTPOLELEF"), uuid), 5000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromWorld(Item:itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		RemoveSavedItem(itemid, DIRECTORY_PLOTPOLE);
	}
}

hook OnItemArrayDataChanged(Item:itemid)
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

_SavePlotPoleItem(Item:itemid, playerid = INVALID_PLAYER_ID)
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

_ExcludeItem(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_PlotPole)
		return true;

	if(IsItemTypeSafebox(itemtype))
		return true;

	new active;
	GetItemArrayDataAtCell(itemid, active, def_active);
	if(IsItemTypeDefence(itemtype) && active)
		return true;

	new tentid;
	GetItemExtraData(itemid, tentid);
	if(itemtype == item_TentPack && IsValidTent(tentid))
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

stock IsItemInPlotPoleArea(Item:itemid)
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
			if(GetItemType(Item:data[1]) == item_PlotPole)
				return true;
		}
	}

	return false;
}
