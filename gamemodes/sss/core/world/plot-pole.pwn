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


enum e_PLOT_POLE_DATA
{
	E_PLOTPOLE_AREA,
	E_PLOTPOLE_OBJ1,
	E_PLOTPOLE_OBJ2,
	E_PLOTPOLE_OBJ3
}

static InPlotPoleArea[MAX_PLAYERS];


hook OnScriptInit()
{
	SetItemTypeMaxArrayData(item_PlotPole, 2);
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
			Float:rz;

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rz, rz, rz);

		Streamer_SetFloatData(STREAMER_TYPE_AREA, GetButtonArea(GetItemButtonID(itemid)), E_STREAMER_SIZE, 20.0);
		// data[E_PLOTPOLE_AREA] = CreateDynamicSphere(x, y, z, 20.0, GetItemWorld(itemid), GetItemInterior(itemid));
		data[E_PLOTPOLE_OBJ1] = CreateDynamicObject(1719, x + (0.09200 * floatsin(-rz, degrees)), y + (0.09200 * floatcos(-rz, degrees)), z + 0.52270, 0.00000, 90.00000, rz + 90.0);
		data[E_PLOTPOLE_OBJ2] = CreateDynamicObject(19816, x - (0.08000 * floatsin(-rz, degrees)), y - (0.08000 * floatcos(-rz, degrees)), z + 0.50000, 0.00000, 0.00000, rz);
		data[E_PLOTPOLE_OBJ3] = CreateDynamicObject(19293, x, y, z + 1.3073, 0.00000, 0.00000, rz);
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

hook OnPlayerEnterButtonArea(playerid, buttonid)
{
	new itemid = GetItemFromButtonID(buttonid);

	if(IsValidItem(itemid))
	{
		if(GetItemType(itemid) == item_PlotPole)
		{
			new geid[GEID_LEN];
			GetItemGEID(itemid, geid);
			ShowActionText(playerid, sprintf("Entered Zone for Plot Pole %s", geid), 5000);

			InPlotPoleArea[playerid] = true;
		}
	}
}

hook OnPlayerLeaveButtonArea(playerid, buttonid)
{
	new itemid = GetItemFromButtonID(buttonid);

	if(IsValidItem(itemid))
	{
		if(GetItemType(itemid) == item_PlotPole)
		{
			new geid[GEID_LEN];
			GetItemGEID(itemid, geid);
			ShowActionText(playerid, sprintf("Left Zone for Plot Pole %s", geid), 5000);

			InPlotPoleArea[playerid] = false;
		}
	}
}

stock IsPlayerInPlotPoleArea(playerid)
{
	if(!IsPlayerConnected(playerid))
		return false;

	return InPlotPoleArea[playerid];
}
