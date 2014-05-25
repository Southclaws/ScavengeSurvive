#include <YSI\y_hooks>


#define DIRECTORY_TENT		DIRECTORY_MAIN"Tents/"
#define MAX_TENT			(1024)
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
			tnt_objEndF,
			tnt_objEndB,
			tnt_objPoleF,
			tnt_objPoleB,
Float:		tnt_posX,
Float:		tnt_posY,
Float:		tnt_posZ,
Float:		tnt_rotZ
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
Iterator:	tnt_Index<MAX_TENT>,
Iterator:	tnt_ItemIndex[MAX_TENT]<MAX_TENT_ITEMS>,
			tnt_ItemTent[ITM_MAX] = {INVALID_ITEM_ID, ...},
			tnt_ItemList[ITM_LST_OF_ITEMS(MAX_TENT_ITEMS)],
			tnt_ButtonTent[BTN_MAX] = {INVALID_TENT_ID, ...},
			tnt_ItemTentTarget[ITM_MAX] = {INVALID_TENT_ID, ...};

static
			tnt_CurrentTentID[MAX_PLAYERS];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnGameModeInit()
{
	if(tnt_GEID_Index > 0)
	{
		printf("ERROR: tnt_GEID_Index has been modified prior to loading from "GEID_FILE". This variable can NOT be modified before being assigned a value from this file.");
		for(;;){}
	}

	new arr[1];

	modio_read(GEID_FILE, _T<T,E,N,T>, arr);

	tnt_GEID_Index = arr[0];
	// printf("Loaded tent GEID: %d", tnt_GEID_Index);

	#if defined SIF_USE_DEBUG_LABELS
		tnt_DebugLabelType = DefineDebugLabelType("TENT", GREEN);
	#endif

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_TENT);

	Iter_Init(tnt_ItemIndex);
}

hook OnPlayerConnect(playerid)
{
	tnt_CurrentTentID[playerid] = INVALID_TENT_ID;
}


/*==============================================================================

	Core

==============================================================================*/


stock CreateTent(Float:x, Float:y, Float:z, Float:rz)
{
	new id = Iter_Free(tnt_Index);

	tnt_Data[id][tnt_buttonId] = CreateButton(x, y, z, "Hold "KEYTEXT_INTERACT" with crowbar to dismantle", .areasize = 1.5, .label = 0);

	tnt_ButtonTent[tnt_Data[id][tnt_buttonId]] = id;

	tnt_Data[id][tnt_objSideR1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 270.0, degrees)),
		y + (0.49 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz, .streamdistance = 100.0);

	tnt_Data[id][tnt_objSideR2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 270.0, degrees)),
		y + (0.48 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz, .streamdistance = 20.0);

	tnt_Data[id][tnt_objSideL1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 90.0, degrees)),
		y + (0.49 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz, .streamdistance = 100.0);

	tnt_Data[id][tnt_objSideL2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 90.0, degrees)),
		y + (0.48 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz, .streamdistance = 20.0);

	tnt_Data[id][tnt_objEndF] = CreateDynamicObject(19475,
		x + (1.3 * floatsin(-rz, degrees)),
		y + (1.3 * floatcos(-rz, degrees)),
		z + 0.17,
		45.0, 0.0, rz + 90, .streamdistance = 5.0);

	tnt_Data[id][tnt_objEndB] = CreateDynamicObject(19475,
		x - (1.3 * floatsin(-rz, degrees)),
		y - (1.3 * floatcos(-rz, degrees)),
		z + 0.17,
		45.0, 0.0, rz + 90, .streamdistance = 5.0);

	tnt_Data[id][tnt_objPoleF] = CreateDynamicObject(19087,
		x + (1.3 * floatsin(-rz, degrees)),
		y + (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz, .streamdistance = 10.0);

	tnt_Data[id][tnt_objPoleB] = CreateDynamicObject(19087,
		x - (1.3 * floatsin(-rz, degrees)),
		y - (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz, .streamdistance = 10.0);

	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideR1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideR2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideL1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objSideL2], 0, 3095, "a51jdrx", "sam_camo", 0);

	SetDynamicObjectMaterial(tnt_Data[id][tnt_objEndF], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objEndB], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objPoleF], 0, 1270, "signs", "lamppost", 0);
	SetDynamicObjectMaterial(tnt_Data[id][tnt_objPoleB], 0, 1270, "signs", "lamppost", 0);

	tnt_Data[id][tnt_posX] = x;
	tnt_Data[id][tnt_posY] = y;
	tnt_Data[id][tnt_posZ] = z;
	tnt_Data[id][tnt_rotZ] = rz;

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

	return id;
}

stock DestroyTent(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	new filename[64];

	format(filename, sizeof(filename), ""DIRECTORY_TENT"tent_%010d.dat", tnt_GEID[tentid]);

	if(fexist(filename))
		fremove(filename);

	DestroyButton(tnt_Data[tentid][tnt_buttonId]);
	tnt_ButtonTent[tnt_Data[tentid][tnt_buttonId]] = INVALID_TENT_ID;

	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideR1]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideR2]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideL1]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objSideL2]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objEndF]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objEndB]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objPoleF]);
	DestroyDynamicObject(tnt_Data[tentid][tnt_objPoleB]);

	tnt_Data[tentid][tnt_objSideR1] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objSideR2] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objSideL1] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objSideL2] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objEndF] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objEndB] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objPoleF] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_objPoleB] = INVALID_OBJECT_ID;
	tnt_Data[tentid][tnt_posX] = 0.0;
	tnt_Data[tentid][tnt_posY] = 0.0;
	tnt_Data[tentid][tnt_posZ] = 0.0;
	tnt_Data[tentid][tnt_rotZ] = 0.0;

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

	SaveTent(tentid);

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
	SaveTent(tentid);
	UpdateTentDebugLabel(tentid);

	tnt_ItemTent[itemid] = -1;

	return tentid;
}

public OnItemCreateInWorld(itemid)
{
	if(!tnt_Loading)
	{
		if(tnt_ItemTentTarget[itemid] != INVALID_TENT_ID)
		{
			AddItemToTentIndex(tnt_ItemTentTarget[itemid], itemid);
			tnt_ItemTentTarget[itemid] = INVALID_TENT_ID;
		}
	}

	#if defined tnt_OnItemCreateInWorld
		return tnt_OnItemCreateInWorld(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreateInWorld
	#undef OnItemCreateInWorld
#else
	#define _ALS_OnItemCreateInWorld
#endif
 
#define OnItemCreateInWorld tnt_OnItemCreateInWorld
#if defined tnt_OnItemCreateInWorld
	forward tnt_OnItemCreateInWorld(itemid);
#endif

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

	GetPlayerButtonList(playerid, list, count);

	for(new i; i < count; i++)
	{
		if(tnt_ButtonTent[list[i]] != INVALID_TENT_ID)
		{
			tnt_ItemTentTarget[itemid] = tnt_ButtonTent[list[i]];
			MsgF(playerid, YELLOW, " >  Item %d added to tent %d (GEID: %d)", itemid, tnt_ButtonTent[list[i]], tnt_GEID[tnt_ButtonTent[list[i]]]);
			break;
		}
	}

	#if defined tnt_OnPlayerDroppedItem
		return tnt_OnPlayerDroppedItem(playerid, itemid);
	#else
		return 1;
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

	return CallLocalFunction("tnt_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress tnt_OnButtonPress
forward tnt_OnButtonPress(playerid, buttonid);

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

	return CallLocalFunction("tnt2_OnHoldActionFinish", "d", playerid);
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


SaveTents(printeach = false, printtotal = false)
{
	new count;

	foreach(new i : tnt_Index)
	{
		if(SaveTent(i, printeach))
			count++;
	}

	if(printtotal)
		printf("Saved %d Tents\n", count);

	new arr[1];

	arr[0] = tnt_GEID_Index;

	modio_push(GEID_FILE, _T<T,E,N,T>, 1, arr);//, true, false, false);
	printf("Storing tent GEID: %d", tnt_GEID_Index);
}

LoadTents(printeach = false, printtotal = false)
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

			count += LoadTent(filename, printeach);
		}
	}

	tnt_Loading = false;

	dir_close(direc);

	// If no tents were loaded, load the old format
	// This should only ever happen once (upon transition to this new version)
	if(count == 0)
		OLD_LoadTents(printeach, printtotal);

	if(printtotal)
		printf("Loaded %d Tents\n", count);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveTent(tentid, prints = false)
{
	if(tnt_Loading)
		return 0;

	if(!Iter_Contains(itm_Index, tentid))
		return 0;

	if(prints)
		printf("\t[SAVE] Tent at %f, %f, %f", tnt_Data[tentid][tnt_posX], tnt_Data[tentid][tnt_posY], tnt_Data[tentid][tnt_posZ]);

	new
		filename[64],
		data[4];

	format(filename, sizeof(filename), ""DIRECTORY_TENT"tent_%010d.dat", tnt_GEID[tentid]);

	data[0] = _:tnt_Data[tentid][tnt_posX];
	data[1] = _:tnt_Data[tentid][tnt_posY];
	data[2] = _:tnt_Data[tentid][tnt_posZ];
	data[3] = _:tnt_Data[tentid][tnt_rotZ];

	modio_push(filename, _T<W,P,O,S>, 4, data, false, false, false);

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

	modio_push(filename, _T<I,T,E,M>, GetItemListSize(itemlist), tnt_ItemList, true, true, true);

	DestroyItemList(itemlist);

	return 1;
}

LoadTent(filename[], prints = false)
{
	new
		length,
		searchpos,
		tentid,
		data[4];

	length = modio_read(filename, _T<W,P,O,S>, _:data, false, false);

	if(length == 0)
		return 0;

	if(Float:data[0] == 0.0 && Float:data[1] == 0.0 && Float:data[2] == 0.0)
		return 0;

	tnt_SkipGEID = true;
	tentid = CreateTent(Float:data[0], Float:data[1], Float:data[2], Float:data[3]);
	tnt_SkipGEID = false;

	searchpos = strlen(DIRECTORY_TENT) + 6;

	sscanf(filename[searchpos], "p<.>d{s[5]}", tnt_GEID[tentid]);

	if(tnt_GEID[tentid] > tnt_GEID_Index)
	{
		printf("WARNING: Tent %d GEID (%d) is greater than GEID index (%d). Updating to %d to avoid GEID collision.", tentid, tnt_GEID[tentid], tnt_GEID_Index, tnt_GEID[tentid] + 1);
		tnt_GEID_Index = tnt_GEID[tentid] + 1;
	}

	if(prints)
		printf("\t[LOAD] Tent at %f, %f, %f", Float:data[0], Float:data[1], Float:data[2]);

	new
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		interior,
		itemid,
		itemlist;

	// final 'true' param is to force close read session
	// Because these files are read in a loop, sessions can stack up so this
	// ensures that a new session isn't registered for each tent.
	length = modio_read(filename, _T<I,T,E,M>, tnt_ItemList, true);

	itemlist = ExtractItemList(tnt_ItemList, length);

	for(new i, j = GetItemListItemCount(itemlist); i < j; i++)
	{
		itemtype = GetItemListItem(itemlist, i);
		GetItemListItemPos(itemlist, i, x, y, z);
		GetItemListItemRot(itemlist, i, r, r, r);
		interior = GetItemListItemInterior(itemlist, i);

		if(length == 0)
			break;

		if(itemtype == INVALID_ITEM_TYPE)
			break;

		if(itemtype == ItemType:0)
			break;

		itemid = CreateItem(itemtype, x, y, z, .rz = r, .interior = interior, .zoffset = FLOOR_OFFSET);

		if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
			SetItemArrayDataFromListItem(itemid, itemlist, i);

		AddItemToTentIndex(tentid, itemid);
	}

	DestroyItemList(itemlist);

	return 1;
}


/*==============================================================================

	Legacy format (Load only)

==============================================================================*/


enum
{
	TENT_CELL_ITEMTYPE,
	TENT_CELL_EXDATA,
	TENT_CELL_POSX,
	TENT_CELL_POSY,
	TENT_CELL_POSZ,
	TENT_CELL_ROTZ,
	TENT_CELL_END
}

OLD_LoadTents(printeach = false, printtotal = false)
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

			count += OLD_LoadTent(filename, printeach);
		}
	}

	tnt_Loading = false;

	dir_close(direc);

	SaveTents(printeach, printtotal);

	if(printtotal)
		printf("Loaded %d Tents using old format\n", count);
}

OLD_LoadTent(filename[], prints = false)
{
	if(!fexist(filename))
		return 0;

	new
		File:file,
		data[MAX_TENT_ITEMS * TENT_CELL_END],
		tentid,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		idx,
		itemid;

	file = fopen(filename, io_read);

	if(!file)
		return 0;

	fblockread(file, data, MAX_TENT_ITEMS * TENT_CELL_END);

	sscanf(filename, "'"DIRECTORY_TENT"'p<_>dddd", _:x, _:y, _:z, _:r);

	if(prints)
		printf("\t[LOAD] [OLD] Tent at %f, %f, %f", x, y, z);

	tentid = CreateTent(Float:x, Float:y, Float:z, Float:r);

	while(idx < sizeof(data))
	{
		if(!IsValidItemType(ItemType:data[idx + TENT_CELL_ITEMTYPE]))
			break;

		itemid = CreateItem(ItemType:data[idx + TENT_CELL_ITEMTYPE],
			Float:data[idx + TENT_CELL_POSX],
			Float:data[idx + TENT_CELL_POSY],
			Float:data[idx + TENT_CELL_POSZ],
			.rz = Float:data[idx + TENT_CELL_ROTZ],
			.zoffset = FLOOR_OFFSET);

		if(!IsItemTypeExtraDataDependent(ItemType:data[idx + TENT_CELL_ITEMTYPE]))
			SetItemExtraData(itemid, data[idx + TENT_CELL_EXDATA]);

		AddItemToTentIndex(tentid, itemid);

		idx += TENT_CELL_END;
	}

	fclose(file);
	fremove(filename);

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
