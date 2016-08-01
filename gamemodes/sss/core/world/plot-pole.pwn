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


#define PLOTPOLE_AREA_IDENTIFIER	(2817)


#include <YSI\y_hooks>


enum e_PLOT_POLE_DATA
{
	E_PLOTPOLE_AREA,
	E_PLOTPOLE_OBJ1,
	E_PLOTPOLE_OBJ2,
	E_PLOTPOLE_OBJ3
}

static
	CurrentPlotPoleItem[MAX_PLAYERS] = {INVALID_ITEM_ID};


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "PlotPole"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("PlotPole"), e_PLOT_POLE_DATA);
}

hook OnPlayerConnect(playerid)
{
	StopRemovingPlotpole(playerid);
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
	}
}

hook OnItemDestroy(itemid)
{
	if(GetItemType(itemid) == item_PlotPole)
	{
		new data[e_PLOT_POLE_DATA];
		GetItemArrayData(itemid, data);
		printf("[OnItemDestroy] Destroying plotpole item %d data: %s", itemid, atosr(data));
		DestroyDynamicArea(data[E_PLOTPOLE_AREA]);
		DestroyDynamicObject(data[E_PLOTPOLE_OBJ1]);
		DestroyDynamicObject(data[E_PLOTPOLE_OBJ2]);
		DestroyDynamicObject(data[E_PLOTPOLE_OBJ3]);
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

// Removal

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(withitemid) == item_PlotPole)
	{
		if(GetItemType(itemid) == item_Crowbar)
		{
			StartRemovingPlotpole(playerid, withitemid);
		}
	}
}

StartRemovingPlotpole(playerid, itemid)
{
	StartHoldAction(playerid, 15000);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, ls(playerid, "TENTREMOVE"));
	CurrentPlotPoleItem[playerid] = itemid;
}

StopRemovingPlotpole(playerid)
{
	if(CurrentPlotPoleItem[playerid] == INVALID_ITEM_ID)
		return;

	StopHoldAction(playerid);
	ClearAnimations(playerid);
	HideActionText(playerid);
	CurrentPlotPoleItem[playerid] = INVALID_ITEM_ID;

	return;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		if(CurrentPlotPoleItem[playerid] != INVALID_ITEM_ID)
		{
			if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
			{
				StopRemovingPlotpole(playerid);
			}
		}
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	if(CurrentPlotPoleItem[playerid] != INVALID_ITEM_ID)
	{
		if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(CurrentPlotPoleItem[playerid], x, y, z);

			new data[e_PLOT_POLE_DATA];
			GetItemArrayData(CurrentPlotPoleItem[playerid], data);
			printf("[OnHoldActionFinish] Destroying plotpole item %d data: %s", CurrentPlotPoleItem[playerid], atosr(data));
			DestroyItem(CurrentPlotPoleItem[playerid]);
			StopRemovingPlotpole(playerid);

			CreateItem(item_Canister, x + 0.5, y, z, .rz = frandom(360.0));
			CreateItem(item_RadioPole, x - 0.5, y, z, .rz = frandom(360.0));
			CreateItem(item_Fluctuator, x, y + 0.5, z, .rz = frandom(360.0));
			CreateItem(item_PowerSupply, x, y - 0.5, z, .rz = frandom(360.0));
		}
	}
}

// Enter/leave messages

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
			ShowActionText(playerid, sprintf("Entered Zone for Plot Pole %s", geid), 5000);
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
			ShowActionText(playerid, sprintf("Left Zone for Plot Pole %s", geid), 5000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

// utils

stock IsPlayerInPlotPoleArea(playerid)
{
	if(!IsPlayerConnected(playerid))
		return false;

	// Todo: implement Streamer_GetPlayerAreas + loop
	return false;
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
