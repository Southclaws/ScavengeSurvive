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


#define MAX_TENT			(2048)
#define MAX_TENT_ITEMS		(16)
#define INVALID_TENT_ID		(-1)


enum E_TENT_DATA
{
			tnt_itemId,
			tnt_buttonId,
			tnt_containerId
}

enum E_TENT_OBJECT_DATA
{
			tnt_objSideR1,
			tnt_objSideR2,
			tnt_objSideL1,
			tnt_objSideL2,
			tnt_objPoleF,
			tnt_objPoleB
}

static
			tnt_Data[MAX_TENT][E_TENT_DATA],
			tnt_ObjData[MAX_TENT][E_TENT_OBJECT_DATA],
			tnt_ButtonTent[BTN_MAX] = {INVALID_TENT_ID, ...},
			tnt_CurrentTentID[MAX_PLAYERS];

new
   Iterator:tnt_Index<MAX_TENT>;


forward OnTentCreate(tentid);
forward OnTentDestroy(tentid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	tnt_CurrentTentID[playerid] = INVALID_TENT_ID;
}


/*==============================================================================

	Core

==============================================================================*/


stock CreateTentFromItem(itemid)
{
	new id = Iter_Free(tnt_Index);

	if(id == -1)
	{
		print("ERROR: MAX_TENT limit reached.");
		return -1;
	}

	new
		Float:x,
		Float:y,
		Float:z,
		Float:rz,
		worldid = GetItemWorld(itemid),
		interiorid = GetItemInterior(itemid);

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rz, rz, rz);

	tnt_Data[id][tnt_itemId] = itemid;
	tnt_Data[id][tnt_buttonId] = CreateButton(x, y, z, "Hold "KEYTEXT_INTERACT" with crowbar to dismantle", worldid, interiorid, .areasize = 1.5, .label = 0);
	tnt_Data[id][tnt_containerId] = CreateContainer("Tent", MAX_TENT_ITEMS, tnt_Data[id][tnt_buttonId]);
	tnt_ButtonTent[tnt_Data[id][tnt_buttonId]] = id;

	tnt_ObjData[id][tnt_objSideR1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 270.0, degrees)),
		y + (0.49 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz, worldid, interiorid, .streamdistance = 100.0);

	tnt_ObjData[id][tnt_objSideR2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 270.0, degrees)),
		y + (0.48 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz, worldid, interiorid, .streamdistance = 20.0);

	tnt_ObjData[id][tnt_objSideL1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 90.0, degrees)),
		y + (0.49 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz, worldid, interiorid, .streamdistance = 100.0);

	tnt_ObjData[id][tnt_objSideL2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 90.0, degrees)),
		y + (0.48 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz, worldid, interiorid, .streamdistance = 20.0);

	tnt_ObjData[id][tnt_objPoleF] = CreateDynamicObject(19087,
		x + (1.3 * floatsin(-rz, degrees)),
		y + (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz, worldid, interiorid, .streamdistance = 10.0);

	tnt_ObjData[id][tnt_objPoleB] = CreateDynamicObject(19087,
		x - (1.3 * floatsin(-rz, degrees)),
		y - (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz, worldid, interiorid, .streamdistance = 10.0);

	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideR1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideR2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideL1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideL2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objPoleF], 0, 1270, "signs", "lamppost", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objPoleB], 0, 1270, "signs", "lamppost", 0);

	Iter_Add(tnt_Index, id);

	CallLocalFunction("OnTentCreate", "d", id);

	return id;
}

stock DestroyTent(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	CallLocalFunction("OnTentDestroy", "d", tentid);

	DestroyButton(tnt_Data[tentid][tnt_buttonId]);
	DestroyContainer(tnt_Data[tentid][tnt_containerId]);
	tnt_ButtonTent[tnt_Data[tentid][tnt_buttonId]] = INVALID_TENT_ID;

	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideR1]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideR2]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideL1]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideL2]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objPoleF]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objPoleB]);
	tnt_ObjData[tentid][tnt_objSideR1] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objSideR2] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objSideL1] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objSideL2] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objPoleF] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objPoleB] = INVALID_OBJECT_ID;

	Iter_SafeRemove(tnt_Index, tentid, tentid);

	return tentid;
}


/*==============================================================================

	Internal functions and hooks

==============================================================================*/


hook OnButtonPress(playerid, buttonid)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
	{
		foreach(new i : tnt_Index)
		{
			if(buttonid == tnt_Data[i][tnt_buttonId])
			{
				tnt_CurrentTentID[playerid] = i;
				StartHoldAction(playerid, 15000);
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
				ShowActionText(playerid, ls(playerid, "TENTREMOVE"));

				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		if(tnt_CurrentTentID[playerid] != INVALID_TENT_ID)
		{
			StopHoldAction(playerid);
			ClearAnimations(playerid);
			HideActionText(playerid);
			tnt_CurrentTentID[playerid] = INVALID_TENT_ID;
		}
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	if(tnt_CurrentTentID[playerid] != INVALID_TENT_ID)
	{
		if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
		{
			DestroyTent(tnt_CurrentTentID[playerid]);
			ClearAnimations(playerid);
			HideActionText(playerid);

			tnt_CurrentTentID[playerid] = INVALID_TENT_ID;
		}
	}
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsValidTent(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return 1;
}

// tnt_itemId
stock GetTentItem(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return tnt_Data[tentid][tnt_itemId];
}

// tnt_buttonId
stock GetTentButton(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return tnt_Data[tentid][tnt_buttonId];
}

// tnt_containerId
stock GetTentContainer(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return tnt_Data[tentid][tnt_containerId];
}

// tnt_posX
// tnt_posY
// tnt_posZ
stock GetTentPos(tentid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	x = tnt_Data[tentid][tnt_posX];
	y = tnt_Data[tentid][tnt_posY];
	z = tnt_Data[tentid][tnt_posZ];

	return 1;
}

// tnt_rotZ
stock GetTentRot(tentid, &Float:r)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return tnt_Data[tentid][tnt_rotZ];
}

// tnt_interior
stock GetTentInterior(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return tnt_Data[tentid][tnt_interior];
}

// tnt_world
stock GetTentWorld(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return tnt_Data[tentid][tnt_world];
}
