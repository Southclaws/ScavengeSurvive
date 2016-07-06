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

<<<<<<< 8c7f95b04d2048ecfd872b688f8c6d513fdd2441
	if(id == ITER_NONE)
	{
		print("ERROR: [CreateTent] id == ITER_NONE");
		return -1;
	}

	tnt_Data[id][tnt_buttonId] = CreateButton(x, y, z, "Hold "KEYTEXT_INTERACT" with crowbar to dismantle", worldid, interiorid, .areasize = 1.5, .label = 0);
=======
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
>>>>>>> removed io systems from public repository

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

<<<<<<< 8c7f95b04d2048ecfd872b688f8c6d513fdd2441
	Internal

==============================================================================*/


AddItemToTentIndex(tentid, itemid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	if(!IsValidItem(itemid))
		return 0;

	if(!IsItemInWorld(itemid))
		return 0;

	if(IsItemTypeSafebox(GetItemType(itemid)))
		return 0;

	if(tnt_ItemTent[itemid] != -1)
		Iter_Remove(tnt_ItemIndex[tnt_ItemTent[itemid]], itemid);

	new cell = Iter_Free(tnt_ItemIndex[tentid]);

	if(cell == ITER_NONE)
		return 0;

	tnt_Items[tentid][cell] = itemid;
	tnt_ItemTent[itemid] = tentid;

	Iter_Add(tnt_ItemIndex[tentid], cell);

	if(!tnt_Loading)
		SaveTent(tentid, 1);

	UpdateTentDebugLabel(tentid);

	return 1;
}

RemoveItemFromTentIndex(itemid)
{
	if(!IsValidItem(itemid))
		return INVALID_TENT_ID;

	if(tnt_ItemTent[itemid] == -1)
		return INVALID_TENT_ID;

	new
		cell,
		tentid;

	foreach(new i : tnt_ItemIndex[tnt_ItemTent[itemid]])
	{
		if(tnt_Items[tnt_ItemTent[itemid]][i] == itemid)
		{
			cell = i;
			break;
		}
	}

	tentid = tnt_ItemTent[itemid];

	Iter_Remove(tnt_ItemIndex[tentid], cell);
	SaveTent(tentid, 1);
	UpdateTentDebugLabel(tentid);

	tnt_ItemTent[itemid] = -1;

	return tentid;
}

/*
hook OnItemRemoveFromWorld(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemRemoveFromWorld] in /gamemodes/sss/core/world/tent.pwn");

	RemoveItemFromTentIndex(itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}
*/
#define cc.r );
hook OnItemDestroy(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemDestroy] in /gamemodes/sss/core/world/tent.pwn");

	RemoveItemFromTentIndex(itemid);
}

hook OnPlayerPickedUpItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerPickedUpItem] in /gamemodes/sss/core/world/tent.pwn");

	new ret = RemoveItemFromTentIndex(itemid);

	if(ret != INVALID_TENT_ID)
		ChatMsgLang(playerid, YELLOW, "TENTITEMREM", itemid, ret, tnt_GEID[ret]);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDroppedItem] in /gamemodes/sss/core/world/tent.pwn");

	new
		list[BTN_MAX_INRANGE],
		count;

	GetPlayerButtonList(playerid, list, count, true);

	for(new i; i < count; i++)
	{
		if(tnt_ButtonTent[list[i]] != INVALID_TENT_ID)
		{
			_DropItemInTent(playerid, itemid, tnt_ButtonTent[list[i]]);
			break;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_DropItemInTent(playerid, itemid, tentid)
{
	if(AddItemToTentIndex(tentid, itemid))
	{
		ChatMsgLang(playerid, YELLOW, "TENTITEMADD", itemid, tentid, tnt_GEID[tentid]);
	}

	return 1;
}

hook OnItemArrayDataChanged(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemArrayDataChanged] in /gamemodes/sss/core/world/tent.pwn");

	if(tnt_ItemTent[itemid] != INVALID_TENT_ID)
	{
		SaveTent(tnt_ItemTent[itemid], 1);
	}
}

UpdateTentDebugLabel(tentid)
{
	new
		string[64],
		tmp[12];

	format(string, sizeof(string), "GEID: %d ITEMCOUNT: %d\n", tnt_GEID[tentid], Iter_Count(tnt_ItemIndex[tentid]));

	foreach(new i : tnt_ItemIndex[tentid])
	{
		valstr(tmp, tnt_Items[tentid][i]);
		strcat(string, tmp);
		strcat(string, ", ");
	}

	#if defined SIF_USE_DEBUG_LABELS
		UpdateDebugLabelString(tnt_DebugLabelID[tentid], string);
	#endif
}


/*==============================================================================

	Player interaction
=======
	Internal functions and hooks
>>>>>>> removed io systems from public repository

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
<<<<<<< 8c7f95b04d2048ecfd872b688f8c6d513fdd2441
	}

	tnt_SkipGEID = true;
	tentid = CreateTent(Float:data[0], Float:data[1], Float:data[2], Float:data[3], data[4], data[5]);
	tnt_SkipGEID = false;

	searchpos = strlen(DIRECTORY_TENT) + 6;

	sscanf(filename[searchpos], "p<.>d{s[5]}", tnt_GEID[tentid]);

	if(tnt_GEID[tentid] > tnt_GEID_Index)
	{
		tnt_GEID_Index = tnt_GEID[tentid] + 1;
	}

	if(tnt_PrintEachLoad)
		printf("\t[LOAD] Tent (GEID: %d tentid: %d) at %f, %f, %f", tnt_GEID[tentid], tentid, Float:data[0], Float:data[1], Float:data[2]);

	new
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		interior,
		world,
		itemid,
		itemlist,
		cell;

	// final 'true' param is to force close read session
	// Because these files are read in a loop, sessions can stack up so this
	// ensures that a new session isn't registered for each tent.
	length = modio_read(filename, _T<I,T,E,M>, sizeof(tnt_ItemList), tnt_ItemList, .forceclose = true);

	itemlist = ExtractItemList(tnt_ItemList, length);

	for(new i, j = GetItemListItemCount(itemlist); i < j; i++)
	{
		itemtype = GetItemListItem(itemlist, i);
		GetItemListItemPos(itemlist, i, x, y, z);
		GetItemListItemRot(itemlist, i, r, r, r);
		world = GetItemListItemWorld(itemlist, i);
		interior = GetItemListItemInterior(itemlist, i);

		if(length == 0)
			break;

		if(itemtype == INVALID_ITEM_TYPE)
			break;

		if(itemtype == ItemType:0)
			break;

		itemid = AllocNextItemID(itemtype);

		SetItemNoResetArrayData(itemid, true);

		if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
			SetItemArrayDataFromListItem(itemid, itemlist, i);

		if(tnt_ItemTent[itemid] != -1)
			Iter_Remove(tnt_ItemIndex[tnt_ItemTent[itemid]], itemid);

		cell = Iter_Free(tnt_ItemIndex[tentid]);

		if(cell == ITER_NONE)
			return 0;
=======
>>>>>>> removed io systems from public repository

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
