#include <YSI\y_hooks>


#define DIRECTORY_SAFEBOX	DIRECTORY_MAIN"Safebox/"
#define MAX_SAFEBOX			ITM_MAX
#define MAX_SAFEBOX_TYPE	(8)
#define MAX_SAFEBOX_NAME	(32)


enum E_SAFEBOX_TYPE_DATA
{
			box_name[MAX_SAFEBOX_NAME],
ItemType:	box_itemtype,
			box_size
}


static
			box_GEID_Index,
			box_GEID[MAX_SAFEBOX],
			box_SkipGEID,
			box_TypeData[MAX_SAFEBOX_TYPE][E_SAFEBOX_TYPE_DATA],
			box_TypeTotal,
Iterator:	box_Index<ITM_MAX>,
			box_ItemTypeBoxType[ITM_MAX_TYPES] = {-1, ...},
			box_ContainerSafebox[CNT_MAX];

static
			box_CurrentBoxItem[MAX_PLAYERS],
			box_PickUpTick[MAX_PLAYERS],
Timer:		box_PickUpTimer[MAX_PLAYERS];

static
			box_ItemList[ITM_LST_OF_ITEMS(12)];

// Settings: Prefixed camel case here and dashed in settings.json
static
bool:		box_PrintEachLoad,
bool:		box_PrintTotalLoad,
bool:		box_PrintEachSave,
bool:		box_PrintEachRuntimeSave,
bool:		box_PrintTotalSave,
bool:		box_PrintRemoves;

static HANDLER = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'SafeBox'...");

	if(box_GEID_Index > 0)
	{
		printf("ERROR: box_GEID_Index has been modified prior to loading from "GEID_FILE". This variable can NOT be modified before being assigned a value from this file.");
		for(;;){}
	}

	new arr[1];

	modio_read(GEID_FILE, _T<S,B,O,X>, arr);

	box_GEID_Index = arr[0];
	printf("Loaded safebox GEID: %d", box_GEID_Index);

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_SAFEBOX);

	for(new i; i < CNT_MAX; i++)
		box_ContainerSafebox[i] = INVALID_ITEM_ID;

	HANDLER = debug_register_handler("safebox", 0);

	GetSettingInt("safebox/print-each-load", false, box_PrintEachLoad);
	GetSettingInt("safebox/print-total-load", true, box_PrintTotalLoad);
	GetSettingInt("safebox/print-each-save", false, box_PrintEachSave);
	GetSettingInt("safebox/print-each-runtime-save", false, box_PrintEachRuntimeSave);
	GetSettingInt("safebox/print-total-save", true, box_PrintTotalSave);
	GetSettingInt("safebox/print-removes", false, box_PrintRemoves);
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'SafeBox'...");

	LoadSafeBoxes();
}

hook OnScriptExit()
{
	print("\n[OnScriptExit] Shutting down 'SafeBox'...");

	SaveSafeBoxes();
}


hook OnPlayerConnect(playerid)
{
	box_CurrentBoxItem[playerid] = INVALID_ITEM_ID;
}


/*==============================================================================

	Core

==============================================================================*/


DefineSafeboxType(name[MAX_SAFEBOX_NAME], ItemType:itemtype, size)
{
	if(box_TypeTotal == MAX_SAFEBOX_TYPE)
		return -1;

	SetItemTypeMaxArrayData(itemtype, 2);

	box_TypeData[box_TypeTotal][box_name]		= name;
	box_TypeData[box_TypeTotal][box_itemtype]	= itemtype;
	box_TypeData[box_TypeTotal][box_size]		= size;

	box_ItemTypeBoxType[itemtype] = box_TypeTotal;

	return box_TypeTotal++;
}


/*==============================================================================

	Internal

==============================================================================*/


public OnItemCreate(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			new containerid;

			containerid = CreateContainer(
				box_TypeData[box_ItemTypeBoxType[itemtype]][box_name],
				box_TypeData[box_ItemTypeBoxType[itemtype]][box_size],
				.virtual = 1);

			box_ContainerSafebox[containerid] = itemid;

			SetItemArrayDataSize(itemid, 2);
			SetItemArrayDataAtCell(itemid, containerid, 1);
			Iter_Add(box_Index, itemid);

			if(!box_SkipGEID)
			{
				box_GEID[itemid] = box_GEID_Index;
				box_GEID_Index++;
				// printf("Safebox GEID Index: %d", box_GEID_Index);
			}
		}
	}

	#if defined box_OnItemCreate
		return box_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate box_OnItemCreate
#if defined box_OnItemCreate
	forward box_OnItemCreate(itemid);
#endif

public OnItemCreateInWorld(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
			SetButtonText(GetItemButtonID(itemid), "Hold "KEYTEXT_INTERACT" to pick up~n~Press "KEYTEXT_INTERACT" to open");
	}

	#if defined box_OnItemCreateInWorld
		return box_OnItemCreateInWorld(itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemCreateInWorld
	#undef OnItemCreateInWorld
#else
	#define _ALS_OnItemCreateInWorld
#endif
#define OnItemCreateInWorld box_OnItemCreateInWorld
#if defined box_OnItemCreateInWorld
	forward box_OnItemCreateInWorld(itemid);
#endif

public OnItemDestroy(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			new containerid = GetItemArrayDataAtCell(itemid, 1);

			DestroyContainer(containerid);
			box_ContainerSafebox[containerid] = INVALID_ITEM_ID;

			RemoveSafeboxItem(itemid);
		}
	}

	#if defined box_OnItemDestroy
		return box_OnItemDestroy(itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemDestroy
	#undef OnItemDestroy
#else
	#define _ALS_OnItemDestroy
#endif
#define OnItemDestroy box_OnItemDestroy
#if defined box_OnItemDestroy
	forward box_OnItemDestroy(itemid);
#endif


/*==============================================================================

	Player interaction

==============================================================================*/


public OnPlayerPickUpItem(playerid, itemid)
{
	if(SafeBoxInteractionCheck(playerid, itemid))
		return 1;

	#if defined box_OnPlayerPickUpItem
		return box_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem box_OnPlayerPickUpItem
#if defined box_OnPlayerPickUpItem
	forward box_OnPlayerPickUpItem(playerid, itemid);
#endif

public OnPlayerDroppedItem(playerid, itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)))
	{
		if(!IsContainerEmpty(GetItemArrayDataAtCell(itemid, 1)))
		{
			d:1:HANDLER("Player %d dropping and saving container %d (item %d)", playerid, GetItemArrayDataAtCell(itemid, 1), itemid);
			SaveSafeboxItem(itemid, box_PrintEachRuntimeSave);
		}
	}

	#if defined box_OnPlayerDroppedItem
		return box_OnPlayerDroppedItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
#define OnPlayerDroppedItem box_OnPlayerDroppedItem
#if defined box_OnPlayerDroppedItem
	forward box_OnPlayerDroppedItem(playerid, itemid);
#endif

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(SafeBoxInteractionCheck(playerid, withitemid))
		return 1;

	#if defined box_OnPlayerUseItemWithItem
		return box_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem box_OnPlayerUseItemWithItem
#if defined box_OnPlayerUseItemWithItem
	forward box_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif


SafeBoxInteractionCheck(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
		return 0;

	if(box_ItemTypeBoxType[itemtype] == -1)
		return 0;

	if(itemtype != box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		return 0;

	box_PickUpTick[playerid] = GetTickCount();
	box_CurrentBoxItem[playerid] = itemid;
	stop box_PickUpTimer[playerid];

	if(!IsValidItem(GetPlayerItem(playerid)) && GetPlayerWeapon(playerid) == 0)
		box_PickUpTimer[playerid] = defer box_PickUp(playerid, itemid);

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
		return 1;

	if(oldkeys & 16)
	{
		if(GetTickCountDifference(GetTickCount(), box_PickUpTick[playerid]) < 200)
		{
			if(IsValidItem(box_CurrentBoxItem[playerid]))
			{
				DisplayContainerInventory(playerid, GetItemArrayDataAtCell(box_CurrentBoxItem[playerid], 1));
				ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);
				stop box_PickUpTimer[playerid];
				box_PickUpTick[playerid] = 0;
			}
		}
	}

	return 1;
}

timer box_PickUp[250](playerid, itemid)
{
	if(IsValidItem(GetPlayerItem(playerid)) || GetPlayerWeapon(playerid) != 0)
		return;

	if(!IsItemInWorld(itemid))
		return;

	d:1:HANDLER("[box_PickUp] Player %d picked up container %d GEID: %d", playerid, itemid, box_GEID[itemid]);

	PlayerPickUpItem(playerid, itemid);

	RemoveSafeboxItem(itemid);

	return;
}

public OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidItem(box_CurrentBoxItem[playerid]))
	{
		d:1:HANDLER("Player %d closing and saving container %d (%d)", playerid, containerid, box_CurrentBoxItem[playerid]);
		SaveSafeboxItem(box_CurrentBoxItem[playerid], box_PrintEachRuntimeSave);
		ClearAnimations(playerid);
		box_CurrentBoxItem[playerid] = INVALID_ITEM_ID;
	}

	#if defined box_OnPlayerCloseContainer
		return box_OnPlayerCloseContainer(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer box_OnPlayerCloseContainer
#if defined box_OnPlayerCloseContainer
	forward box_OnPlayerCloseContainer(playerid, containerid);
#endif


/*==============================================================================

	Save and Load All

==============================================================================*/


LoadSafeBoxes()
{
	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_SAFEBOX),
		item[46],
		type,
		filename[64],
		count;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			filename = DIRECTORY_SAFEBOX;
			strcat(filename, item);

			count += LoadSafeboxItem(filename);
		}
	}

	dir_close(direc);

	// If no safeboxes were loaded, load the old format
	// This should only ever happen once (upon transition to this new version)
	if(count == 0)
		OLD_LoadSafeboxes();

	if(box_PrintTotalLoad)
		printf("Loaded %d Safeboxes", count);
}

SaveSafeBoxes()
{
	new count;

	foreach(new i : box_Index)
	{
		if(SaveSafeboxItem(i, box_PrintEachSave) > 0)
			count++;
	}

	if(box_PrintTotalSave)
		printf("Saved %d Safeboxes", count);

	new arr[1];

	arr[0] = box_GEID_Index;

	modio_push(GEID_FILE, _T<S,B,O,X>, 1, arr);//, true, false, false);
	printf("Storing safebox GEID: %d", box_GEID_Index);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveSafeboxItem(itemid, printeach)
{
	if(!IsValidItem(itemid))
	{
		printf("ERROR: Can't save safebox %d GEID: %d: Not valid item.", itemid, box_GEID[itemid]);
		return 0;
	}

	if(!IsItemInWorld(itemid))
	{
		printf("ERROR: Can't save safebox %d GEID: %d: Item not in world.", itemid, box_GEID[itemid]);
		return 0;
	}

	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		printf("ERROR: Can't save safebox %d GEID: %d: Item isn't a safebox.", itemid, box_GEID[itemid]);
		return 0;
	}

	new
		data[6],
		containerid,
		filename[64];

	format(filename, sizeof(filename), ""DIRECTORY_SAFEBOX"box_%010d.dat", box_GEID[itemid]);

	containerid = GetItemArrayDataAtCell(itemid, 1);

	if(IsContainerEmpty(containerid))
	{
		fremove(filename);
		return 0;
	}

	if(!IsValidContainer(containerid))
	{
		printf("ERROR: Can't save safebox %d GEID: %d: Not valid container (%d).", itemid, box_GEID[itemid], containerid);
		fremove(filename);
		return 0;
	}

	data[0] = _:GetItemType(itemid);

	modio_push(filename, _T<T,Y,P,E>, 1, data, false, false, false);

	GetItemPos(itemid, Float:data[0], Float:data[1], Float:data[2]);
	GetItemRot(itemid, Float:data[3], Float:data[3], Float:data[3]);
	data[4] = GetItemWorld(itemid);
	data[5] = GetItemInterior(itemid);

	modio_push(filename, _T<W,P,O,S>, 6, data, false, false, false);

	if(printeach)
		printf("\t[SAVE] Safebox type %d at %f, %f, %f, %f", _:GetItemType(itemid), data[0], data[1], data[2], data[3]);

	new
		items[12],
		itemcount,
		itemlist;

	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		items[i] = GetContainerSlotItem(containerid, i);

		if(!IsValidItem(items[i]))
			break;

		itemcount++;
	}

	itemlist = CreateItemList(items, itemcount);
	GetItemList(itemlist, box_ItemList);

	modio_push(filename, _T<I,T,E,M>, GetItemListSize(itemlist), box_ItemList, true);

	DestroyItemList(itemlist);

	return 1;
}

LoadSafeboxItem(filename[])
{
	new
		length,
		type[1],
		data[6],
		itemid,
		containerid;

	length = modio_read(filename, _T<T,Y,P,E>, type, false, false);

	if(length == 0)
		return 0;

	if(!IsItemTypeSafebox(ItemType:type[0]))
		return 0;

	modio_read(filename, _T<W,P,O,S>, _:data, false, false);

	if(Float:data[0] == 0.0 && Float:data[1] == 0.0 && Float:data[2] == 0.0)
		return 0;

	box_SkipGEID = true;
	itemid = CreateItem(ItemType:type[0], Float:data[0], Float:data[1], Float:data[2], .rz = Float:data[3], .world = data[4], .interior = data[5], .zoffset = FLOOR_OFFSET);
	box_SkipGEID = false;

	containerid = GetItemArrayDataAtCell(itemid, 1);

	sscanf(filename, "'"DIRECTORY_SAFEBOX"box_'p<.>d{s[5]}", box_GEID[itemid]);

	if(box_GEID[itemid] > box_GEID_Index)
	{
		printf("WARNING: Safebox %d GEID (%d) is greater than GEID index (%d). Updating index to avoid GEID collision.", itemid, box_GEID[itemid], box_GEID_Index);
		box_GEID_Index = box_GEID[itemid] + 1;
	}

	if(box_PrintEachLoad)
		printf("\t[LOAD] Safebox: GEID %d, type %d, at %f, %f, %f", box_GEID[itemid], type[0], data[0], data[1], data[2]);

	new
		ItemType:itemtype,
		itemlist;

	length = modio_read(filename, _T<I,T,E,M>, box_ItemList, true);

	itemlist = ExtractItemList(box_ItemList, length);

	for(new i, j = GetItemListItemCount(itemlist); i < j; i++)
	{
		itemtype = GetItemListItem(itemlist, i);

		if(length == 0)
			break;

		if(itemtype == INVALID_ITEM_TYPE)
			break;

		if(itemtype == ItemType:0)
			break;

		itemid = CreateItem(itemtype);

		if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
			SetItemArrayDataFromListItem(itemid, itemlist, i);

		AddItemToContainer(containerid, itemid);
	}

	DestroyItemList(itemlist);

	return 1;
}

RemoveSafeboxItem(itemid)
{
	new filename[64];

	// TODO: Set box as "inactive" but don't remove it.
	format(filename, sizeof(filename), ""DIRECTORY_SAFEBOX"box_%010d.dat", box_GEID[itemid]);
	fremove(filename);

	if(box_PrintRemoves)
		printf("\t[DELT] Safebox: GEID %d", box_GEID[itemid]);

	return Iter_SafeRemove(box_Index, itemid, itemid);
}


/*==============================================================================

	Legacy format (Load only)

==============================================================================*/


OLD_LoadSafeboxes()
{
	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_SAFEBOX),
		item[46],
		type,
		filename[64],
		count;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			filename = DIRECTORY_SAFEBOX;
			strcat(filename, item);

			count += OLD_LoadSafeboxItem(filename);
		}
	}

	dir_close(direc);

	SaveSafeBoxes();

	if(box_PrintTotalLoad)
		printf("Loaded %d Safeboxes using old format", count);
}

OLD_LoadSafeboxItem(filename[])
{
	new
		File:file,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		containerid,
		data[1 + (CNT_MAX_SLOTS * 2)],
		itemid;

	file = fopen(filename, io_read);

	if(!file)
	{
		printf("ERROR: Safebox (OLD) '%s' unable to open file.", filename);
		return 0;
	}

	sscanf(filename, "'"DIRECTORY_SAFEBOX"'p<_>dddd", _:x, _:y, _:z, _:r);

	if(x == 0.0 && y == 0.0 && z == 0.0)
	{
		printf("ERROR: Safebox (OLD) '%s' position at null point.", filename);
		fremove(filename);
		return 0;
	}

	fblockread(file, data, sizeof(data));
	fclose(file);

	if(!IsItemTypeSafebox(ItemType:data[0]))
	{
		printf("ERROR: Safebox (OLD) '%s' type (%d) not valid safebox type.", filename, data[0]);
		fremove(filename);
		return 0;
	}

	itemid = CreateItem(ItemType:data[0], x, y, z, .rz = r, .zoffset = FLOOR_OFFSET);
	containerid = GetItemArrayDataAtCell(itemid, 1);

	if(box_PrintEachLoad)
		printf("\t[LOAD] [OLD] Safebox type %d at %f, %f, %f", data[0], x, y, z);

	for(new i = 1, j; j < CNT_MAX_SLOTS; i += 2, j++)
	{
		if(!IsValidItemType(ItemType:data[i]) || data[i] == 0)
			break;

		itemid = CreateItem(ItemType:data[i], 0.0, 0.0, 0.0);

		if(!IsItemTypeExtraDataDependent(ItemType:data[i]))
			SetItemExtraData(itemid, data[i + 1]);

		AddItemToContainer(containerid, itemid);
	}

	fremove(filename);

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsItemTypeSafebox(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(box_ItemTypeBoxType[itemtype] != -1)
		return 1;

	return 0;
}

stock GetContainerSafeboxItem(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_ITEM_ID;

	return box_ContainerSafebox[containerid];
}

stock IsItemTypeExtraDataDependent(ItemType:itemtype)
{
	if(IsItemTypeBag(itemtype))
		return 1;

	if(IsItemTypeSafebox(itemtype))
		return 1;

	if(itemtype == item_Campfire)
		return 1;

	return 0;
}
