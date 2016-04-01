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


#define DIRECTORY_TENT		DIRECTORY_MAIN"Tents/"
#define MAX_TENT			(2048)
#define MAX_TENT_ITEMS		(8)
#define INVALID_TENT_ID		(-1)


enum E_TENT_DATA
{
			tnt_buttonId,
			tnt_areaId,
			tnt_objSideR1,
			tnt_objSideR2,
			tnt_objSideL1,
			tnt_objSideL2,
			tnt_objPoleF,
			tnt_objPoleB,
Float:		tnt_posX,
Float:		tnt_posY,
Float:		tnt_posZ,
Float:		tnt_rotZ,
			tnt_world,
			tnt_interior
}

new
			tnt_GEID_Index,
			tnt_GEID[MAX_TENT],
			tnt_SkipGEID,
			tnt_Loading,
#if defined SIF_USE_DEBUG_LABELS
			tnt_DebugLabelType,
			tnt_DebugLabelID[MAX_TENT],
#endif
			tnt_Data[MAX_TENT][E_TENT_DATA],
			tnt_Items[MAX_TENT][MAX_TENT_ITEMS],
   Iterator:tnt_Index<MAX_TENT>,
   Iterator:tnt_ItemIndex[MAX_TENT]<MAX_TENT_ITEMS>,
			tnt_ItemTent[ITM_MAX] = {INVALID_ITEM_ID, ...},
			tnt_ItemList[ITM_LST_OF_ITEMS(MAX_TENT_ITEMS)],
			tnt_ButtonTent[BTN_MAX] = {INVALID_TENT_ID, ...};

static
			tnt_CurrentTentID[MAX_PLAYERS];

// Settings: Prefixed camel case here and dashed in settings.json
static
bool:		tnt_PrintEachLoad,
bool:		tnt_PrintTotalLoad,
bool:		tnt_PrintEachSave,
bool:		tnt_PrintTotalSave,
bool:		tnt_PrintRemoves;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Tent'...");

	if(tnt_GEID_Index > 0)
	{
		printf("ERROR: tnt_GEID_Index has been modified prior to loading tents.");
		for(;;){}
	}

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_TENT);

	Iter_Init(tnt_ItemIndex);

	GetSettingInt("tent/print-each-load", false, tnt_PrintEachLoad);
	GetSettingInt("tent/print-total-load", true, tnt_PrintTotalLoad);
	GetSettingInt("tent/print-each-save", false, tnt_PrintEachSave);
	GetSettingInt("tent/print-total-save", true, tnt_PrintTotalSave);
	GetSettingInt("tent/print-removes", false, tnt_PrintRemoves);
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Tent'...");

	LoadTents();
}

hook OnPlayerConnect(playerid)
{
	tnt_CurrentTentID[playerid] = INVALID_TENT_ID;
}


/*==============================================================================

	Core

==============================================================================*/


stock CreateTent(Float:x, Float:y, Float:z, Float:rz, worldid, interiorid)
{
	new id = Iter_Free(tnt_Index);

	tnt_Data[id][tnt_buttonId] = CreateButton(x, y, z, "Hold "KEYTEXT_INTERACT" with crowbar to dismantle", worldid, interiorid, .areasize = 1.5, .label = 0);

	tnt_ButtonTent[tnt_Data[id][tnt_buttonId]] = id;

	tnt_Data[id][tnt_objSideR1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 270.0, degrees)),
		y + (0.49 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz, worldid, interiorid, .streamdistance = 100.0);

	tnt_Data[id][tnt_objSideR2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 270.0, degrees)),
		y + (0.48 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz, worldid, interiorid, .streamdistance = 20.0);

	tnt_Data[id][tnt_objSideL1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 90.0, degrees)),
		y + (0.49 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz, worldid, interiorid, .streamdistance = 100.0);

	tnt_Data[id][tnt_objSideL2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 90.0, degrees)),
		y + (0.48 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz, worldid, interiorid, .streamdistance = 20.0);

	tnt_Data[id][tnt_objPoleF] = CreateDynamicObject(19087,
		x + (1.3 * floatsin(-rz, degrees)),
		y + (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz, worldid, interiorid, .streamdistance = 10.0);

	tnt_Data[id][tnt_objPoleB] = CreateDynamicObject(19087,
		x - (1.3 * floatsin(-rz, degrees)),
		y - (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz, worldid, interiorid, .streamdistance = 10.0);

	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideR1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideR2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideL1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideL2], 0, 3095, "a51jdrx", "sam_camo", 0);

	SetDynamicObjectMaterial(tnt_Data[id][tnt_objPoleF], 0, 1270, "signs", "lamppost", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objPoleB], 0, 1270, "signs", "lamppost", 0);

	tnt_Data[id][tnt_posX] = x;
	tnt_Data[id][tnt_posY] = y;
	tnt_Data[id][tnt_posZ] = z;
	tnt_Data[id][tnt_rotZ] = rz;
	tnt_Data[id][tnt_world] = worldid;
	tnt_Data[id][tnt_interior] = interiorid;

	Iter_Add(tnt_Index, id);

	if(!tnt_SkipGEID)
	{
		tnt_GEID[id] = tnt_GEID_Index;
		tnt_GEID_Index++;
		// printf("Tent GEID Index: %d", tnt_GEID_Index);
	}

	#if defined SIF_USE_DEBUG_LABELS
		tnt_DebugLabelID[id] = CreateDebugLabel(tnt_DebugLabelType, id, x, y, z);
	#endif

	UpdateTentDebugLabel(id);

	if(!tnt_Loading)
		SaveTent(id, 1);

	return id;
}

stock DestroyTent(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	SaveTent(tentid, 0);

	DestroyButton(tnt_Data[tentid][tnt_buttonId]);
	tnt_ButtonTent[tnt_Data[tentid][tnt_buttonId]] = INVALID_TENT_ID;

	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideR1]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideR2]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideL1]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideL2]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objPoleF]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objPoleB]);

	tnt_Data[tentid][tnt_objSideR1] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objSideR2] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objSideL1] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objSideL2] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objPoleF] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objPoleB] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_posX] = 0.0;
	tnt_Data[tentid][tnt_posY] = 0.0;
	tnt_Data[tentid][tnt_posZ] = 0.0;
	tnt_Data[tentid][tnt_rotZ] = 0.0;
	tnt_Data[tentid][tnt_world] = 0;
	tnt_Data[tentid][tnt_interior] = 0;

	Iter_Clear(tnt_ItemIndex[tentid]);

	Iter_SafeRemove(tnt_Index, tentid, tentid);

	#if defined SIF_USE_DEBUG_LABELS
		DestroyDebugLabel(tnt_DebugLabelID[tentid]);
	#endif

	return tentid;
}


/*==============================================================================

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

	if(cell == -1)
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
public OnItemRemoveFromWorld(itemid)
{
	RemoveItemFromTentIndex(itemid);

	#if defined tnt_OnItemRemoveFromWorld
		return tnt_OnItemRemoveFromWorld(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemRemoveFromWorld
	#undef OnItemRemoveFromWorld
#else
	#define _ALS_OnItemRemoveFromWorld
#endif
 
#define OnItemRemoveFromWorld tnt_OnItemRemoveFromWorld
#if defined tnt_OnItemRemoveFromWorld
	forward tnt_OnItemRemoveFromWorld(itemid);
#endif
*/
#define cc.r );
public OnItemDestroy(itemid)
{
	RemoveItemFromTentIndex(itemid);

	#if defined tnt_OnItemDestroy
		return tnt_OnItemDestroy(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemDestroy
	#undef OnItemDestroy
#else
	#define _ALS_OnItemDestroy
#endif
 
#define OnItemDestroy tnt_OnItemDestroy
#if defined tnt_OnItemDestroy
	forward tnt_OnItemDestroy(itemid);
#endif

public OnPlayerPickedUpItem(playerid, itemid)
{
	new ret = RemoveItemFromTentIndex(itemid);

	if(ret != INVALID_TENT_ID)
		MsgF(playerid, YELLOW, "Removed item %d from tent %d (GEID: %d)", itemid, ret, tnt_GEID[ret]);

	#if defined tnt_OnPlayerPickedUpItem
		return tnt_OnPlayerPickedUpItem(playerid, itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerPickedUpItem
	#undef OnPlayerPickedUpItem
#else
	#define _ALS_OnPlayerPickedUpItem
#endif
 
#define OnPlayerPickedUpItem tnt_OnPlayerPickedUpItem
#if defined tnt_OnPlayerPickedUpItem
	forward tnt_OnPlayerPickedUpItem(playerid, itemid);
#endif

public OnPlayerDroppedItem(playerid, itemid)
{
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

	#if defined tnt_OnPlayerDroppedItem
		return tnt_OnPlayerDroppedItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
 
#define OnPlayerDroppedItem tnt_OnPlayerDroppedItem
#if defined tnt_OnPlayerDroppedItem
	forward tnt_OnPlayerDroppedItem(playerid, itemid);
#endif

_DropItemInTent(playerid, itemid, tentid)
{
	if(AddItemToTentIndex(tentid, itemid))
	{
		MsgF(playerid, YELLOW, " >  Item %d added to tent %d (GEID: %d)", itemid, tentid, tnt_GEID[tentid]);
	}

	return 1;
}

public OnItemArrayDataChanged(itemid)
{
	if(tnt_ItemTent[itemid] != INVALID_TENT_ID)
	{
		SaveTent(tnt_ItemTent[itemid], 1);
	}

	#if defined tnt_OnItemArrayDataChanged
		return tnt_OnItemArrayDataChanged(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemArrayDataChanged
	#undef OnItemArrayDataChanged
#else
	#define _ALS_OnItemArrayDataChanged
#endif

#define OnItemArrayDataChanged tnt_OnItemArrayDataChanged
#if defined tnt_OnItemArrayDataChanged
	forward tnt_OnItemArrayDataChanged(itemid);
#endif

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

==============================================================================*/


public OnButtonPress(playerid, buttonid)
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
				ShowActionText(playerid, "Removing Tent");

				return 1;
			}
		}
	}

	#if defined tnt_OnButtonPress
		return tnt_OnButtonPress(playerid, buttonid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress tnt_OnButtonPress
#if defined tnt_OnButtonPress
	forward tnt_OnButtonPress(playerid, buttonid);
#endif

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

public OnHoldActionFinish(playerid)
{
	if(tnt_CurrentTentID[playerid] != INVALID_TENT_ID)
	{
		if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
		{
			CreateItem(item_TentPack,
				tnt_Data[tnt_CurrentTentID[playerid]][tnt_posX],
				tnt_Data[tnt_CurrentTentID[playerid]][tnt_posY],
				tnt_Data[tnt_CurrentTentID[playerid]][tnt_posZ] - 0.4,
				.rz = tnt_Data[tnt_CurrentTentID[playerid]][tnt_posX],
				.zoffset = FLOOR_OFFSET);

			DestroyTent(tnt_CurrentTentID[playerid]);
			ClearAnimations(playerid);
			HideActionText(playerid);

			tnt_CurrentTentID[playerid] = INVALID_TENT_ID;
		}
	}

	#if defined tnt2_OnHoldActionFinish
		return tnt2_OnHoldActionFinish(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish tnt2_OnHoldActionFinish
forward tnt2_OnHoldActionFinish(playerid);


/*==============================================================================

	Save and Load All

==============================================================================*/


LoadTents()
{
	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_TENT),
		item[46],
		type,
		filename[64],
		count;

	tnt_Loading = true;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			filename = DIRECTORY_TENT;
			strcat(filename, item);

			count += LoadTent(filename);
		}
	}

	tnt_Loading = false;

	dir_close(direc);

	if(tnt_PrintTotalLoad)
		printf("Loaded %d Tents", count);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveTent(tentid, active)
{
	if(!Iter_Contains(tnt_Index, tentid))
	{
		printf("ERROR: Attempted to save tent ID %d active: %d that was not found in index.", tentid, active);
		return 0;
	}

	if(active)
	{
		if(tnt_PrintEachSave)
			printf("\t[SAVE] Tent (GEID: %d tentid: %d) at %f, %f, %f", tnt_GEID[tentid], tentid, tnt_Data[tentid][tnt_posX], tnt_Data[tentid][tnt_posY], tnt_Data[tentid][tnt_posZ]);
	}
	else
	{
		if(tnt_PrintEachSave)
			printf("\t[DELT] Tent (GEID: %d tentid: %d) at %f, %f, %f", tnt_GEID[tentid], tentid, tnt_Data[tentid][tnt_posX], tnt_Data[tentid][tnt_posY], tnt_Data[tentid][tnt_posZ]);
	}

	new
		filename[64],
		head[1],
		data[6];

	format(filename, sizeof(filename), ""DIRECTORY_TENT"tent_%010d.dat", tnt_GEID[tentid]);

	head[0] = active;

	modio_push(filename, _T<H,E,A,D>, 1, head);

	data[0] = _:tnt_Data[tentid][tnt_posX];
	data[1] = _:tnt_Data[tentid][tnt_posY];
	data[2] = _:tnt_Data[tentid][tnt_posZ];
	data[3] = _:tnt_Data[tentid][tnt_rotZ];
	data[4] = tnt_Data[tentid][tnt_world];
	data[5] = tnt_Data[tentid][tnt_interior];

	modio_push(filename, _T<W,P,O,S>, 6, data);

	new
		items[10],
		itemcount,
		itemlist;

	foreach(new i : tnt_ItemIndex[tentid])
	{
		items[itemcount++] = tnt_Items[tentid][i];
	}

	itemlist = CreateItemList(items, itemcount);
	GetItemList(itemlist, tnt_ItemList);

	modio_push(filename, _T<I,T,E,M>, GetItemListSize(itemlist), tnt_ItemList);

	DestroyItemList(itemlist);

	return 1;
}

LoadTent(filename[])
{
	new
		length,
		rewrite,
		searchpos,
		tentid,
		head[1],
		data[6];

	length = modio_read(filename, _T<H,E,A,D>, 1, head, .autoclose = false);

	if(length < 0)
	{
		printf("[LoadTent] ERROR: modio error %d in '%s'.", length, filename);
		modio_finalise_read(modio_getsession_read(filename));
		return 0;
	}

	if(length > 0)
	{
		if(head[0] == 0)
		{
			modio_finalise_read(modio_getsession_read(filename));
			return 0;
		}
	}
	else
	{
		printf("[LoadTent] WARNING: Tent '%s' does not have HEAD file tag, force saving.", filename);
		rewrite = 1;
	}

	length = modio_read(filename, _T<W,P,O,S>, sizeof(data), _:data, .autoclose = false);

	if(length == 0)
	{
		print("[LoadTent] ERROR: modio_read returned length of 0.");
		modio_finalise_read(modio_getsession_read(filename));
		return 0;
	}

	if(Float:data[0] == 0.0 && Float:data[1] == 0.0 && Float:data[2] == 0.0)
	{
		print("[LoadTent] ERROR: null position.");
		modio_finalise_read(modio_getsession_read(filename));
		return 0;
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

		if(cell == -1)
			return 0;

		tnt_Items[tentid][cell] = itemid;
		tnt_ItemTent[itemid] = tentid;

		Iter_Add(tnt_ItemIndex[tentid], cell);

		if(!tnt_Loading)
			SaveTent(tentid, 1);

		UpdateTentDebugLabel(tentid);

		CreateItem_ExplicitID(itemid, x, y, z, .rz = r, .world = world, .interior = interior, .zoffset = FLOOR_OFFSET);
	}

	DestroyItemList(itemlist);

	if(rewrite)
	{
		print("FORCE SAVING TENT");
		new ret = SaveTent(tentid, 1);
		printf("SaveTent ret %d", ret);
	}

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetTentPos(tentid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	x = tnt_Data[tentid][tnt_posX];
	y = tnt_Data[tentid][tnt_posY];
	z = tnt_Data[tentid][tnt_posZ];

	return 1;
}
