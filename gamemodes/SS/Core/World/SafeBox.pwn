#include <YSI\y_hooks>


#define MAX_SAFEBOX			ITM_MAX
#define MAX_SAFEBOX_TYPE	(8)
#define MAX_SAFEBOX_NAME	(32)


enum E_SAFEBOX_TYPE_DATA
{
			box_name[MAX_SAFEBOX_NAME],
ItemType:	box_itemtype,
			box_size,
			box_maxMed,
			box_maxLarge,
			box_maxCarry
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
			box_ItemList[ITM_LST_OF_ITEMS(10)];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnGameModeInit()
{
	if(box_GEID_Index > 0)
	{
		printf("ERROR: box_GEID_Index has been modified prior to loading from "GEID_FILE". This variable can NOT be modified before being assigned a value from this file.");
		for(;;){}
	}

	new arr[1];

	modio_read(GEID_FILE, !"SBOX", arr);

	box_GEID_Index = arr[0];
	printf("Loaded safebox GEID: %d", box_GEID_Index);

	for(new i; i < CNT_MAX; i++)
		box_ContainerSafebox[i] = INVALID_ITEM_ID;
}

hook OnPlayerConnect(playerid)
{
	box_CurrentBoxItem[playerid] = INVALID_ITEM_ID;
}


/*==============================================================================

	Core

==============================================================================*/


DefineSafeboxType(name[MAX_SAFEBOX_NAME], ItemType:itemtype, size, max_med, max_large, max_carry)
{
	if(box_TypeTotal == MAX_SAFEBOX_TYPE)
		return -1;

	box_TypeData[box_TypeTotal][box_name]		= name;
	box_TypeData[box_TypeTotal][box_itemtype]	= itemtype;
	box_TypeData[box_TypeTotal][box_size]		= size;
	box_TypeData[box_TypeTotal][box_maxMed]		= max_med;
	box_TypeData[box_TypeTotal][box_maxLarge]	= max_large;
	box_TypeData[box_TypeTotal][box_maxCarry]	= max_carry;

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
				.virtual = 1,
				.max_med = box_TypeData[box_ItemTypeBoxType[itemtype]][box_maxMed],
				.max_large = box_TypeData[box_ItemTypeBoxType[itemtype]][box_maxLarge],
				.max_carry = box_TypeData[box_ItemTypeBoxType[itemtype]][box_maxCarry]);

			box_ContainerSafebox[containerid] = itemid;

			SetItemExtraData(itemid, containerid);
			Iter_Add(box_Index, itemid);

			if(!box_SkipGEID)
			{
				box_GEID[itemid] = box_GEID_Index;
				box_GEID_Index++;
				printf("Safebox GEID Index: %d", box_GEID_Index);
			}
		}
	}

	return CallLocalFunction("box_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate box_OnItemCreate
forward box_OnItemCreate(itemid);

public OnItemCreateInWorld(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
			SetButtonText(GetItemButtonID(itemid), "Hold "KEYTEXT_INTERACT" to pick up~n~Press "KEYTEXT_INTERACT" to open");
	}

	return CallLocalFunction("box_OnItemCreateInWorld", "d", itemid);
}
#if defined _ALS_OnItemCreateInWorld
	#undef OnItemCreateInWorld
#else
	#define _ALS_OnItemCreateInWorld
#endif
#define OnItemCreateInWorld box_OnItemCreateInWorld
forward box_OnItemCreateInWorld(itemid);

public OnItemDestroy(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			new containerid = GetItemExtraData(itemid);

			DestroyContainer(containerid);
			box_ContainerSafebox[containerid] = INVALID_ITEM_ID;

			RemoveSafeboxItem(itemid);
		}
	}

	return CallLocalFunction("box_OnItemDestroy", "d", itemid);
}
#if defined _ALS_OnItemDestroy
	#undef OnItemDestroy
#else
	#define _ALS_OnItemDestroy
#endif
#define OnItemDestroy box_OnItemDestroy
forward box_OnItemDestroy(itemid);


/*==============================================================================

	Player interaction

==============================================================================*/


public OnPlayerPickUpItem(playerid, itemid)
{
	if(SafeBoxInteractionCheck(playerid, itemid))
		return 1;

	return CallLocalFunction("box_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem box_OnPlayerPickUpItem
forward box_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(SafeBoxInteractionCheck(playerid, withitemid))
		return 1;

	return CallLocalFunction("box_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem box_OnPlayerUseItemWithItem
forward box_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

public OnPlayerUseWeaponWithItem(playerid, weapon, itemid)
{
	if(SafeBoxInteractionCheck(playerid, itemid))
		return 1;

	return CallLocalFunction("box_OnPlayerUseWeaponWithItem", "ddd", playerid, weapon, itemid);
}
#if defined _ALS_OnPlayerUseWeaponWithItem
	#undef OnPlayerUseWeaponWithItem
#else
	#define _ALS_OnPlayerUseWeaponWithItem
#endif
#define OnPlayerUseWeaponWithItem box_OnPlayerUseWeaponWithItem
forward box_OnPlayerUseWeaponWithItem(playerid, weapon, itemid);


SafeBoxInteractionCheck(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			box_PickUpTick[playerid] = GetTickCount();
			box_CurrentBoxItem[playerid] = itemid;
			stop box_PickUpTimer[playerid];

			if(!IsValidItem(GetPlayerItem(playerid)) && GetPlayerWeapon(playerid) == 0)
				box_PickUpTimer[playerid] = defer box_PickUp(playerid, itemid);

			return 1;
		}
	}

	return 0;
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
				DisplayContainerInventory(playerid, GetItemExtraData(box_CurrentBoxItem[playerid]));
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

	PlayerPickUpItem(playerid, itemid);

	RemoveSafeboxItem(itemid);

	return;
}

public OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidItem(box_CurrentBoxItem[playerid]))
	{
		SaveSafeboxItem(box_CurrentBoxItem[playerid]);
		ClearAnimations(playerid);
		box_CurrentBoxItem[playerid] = INVALID_ITEM_ID;
	}

	return CallLocalFunction("box_OnPlayerCloseContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer box_OnPlayerCloseContainer
forward box_OnPlayerCloseContainer(playerid, containerid);


/*==============================================================================

	Save and Load All

==============================================================================*/


SaveSafeboxes(printeach = false, printtotal = false)
{
	new count;

	foreach(new i : box_Index)
	{
		if(SaveSafeboxItem(i, printeach) > 0)
			count++;
	}

	if(printtotal)
		printf("Saved %d Safeboxes\n", count);

	new arr[1];

	arr[0] = box_GEID_Index;

	modio_push(GEID_FILE, !"SBOX", 1, arr);//, true, false, false);
	printf("Storing safebox GEID: %d", box_GEID_Index);
}

LoadSafeboxes(printeach = false, printtotal = false)
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

			count += LoadSafeboxItem(filename, printeach);
		}
	}

	dir_close(direc);

	// If no safeboxes were loaded, load the old format
	// This should only ever happen once (upon transition to this new version)
	if(count == 0)
		OLD_LoadSafeboxes(printeach, printtotal);

	if(printtotal)
		printf("Loaded %d Safeboxes\n", count);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveSafeboxItem(itemid, prints = false)
{
	if(!IsValidItem(itemid))
		return 0;

	if(!IsItemInWorld(itemid))
		return 0;

	if(!IsItemTypeSafebox(GetItemType(itemid)))
		return 0;

	new
		data[4],
		containerid,
		filename[64];

	format(filename, sizeof(filename), ""DIRECTORY_SAFEBOX"box_%010d.dat", box_GEID[itemid]);

	containerid = GetItemExtraData(itemid);

	if(!IsValidContainer(containerid) || IsContainerEmpty(containerid))
	{
		fremove(filename);
		return 0;
	}

	data[0] = _:GetItemType(itemid);

	modio_push(filename, !"TYPE", 1, data, false, false, false);

	GetItemPos(itemid, Float:data[0], Float:data[1], Float:data[2]);
	GetItemRot(itemid, Float:data[3], Float:data[3], Float:data[3]);

	modio_push(filename, !"WPOS", 4, data, false, false, false);

	if(prints)
		printf("\t[SAVE] Safebox type %d at %f, %f, %f, %f", _:GetItemType(itemid), data[0], data[1], data[2], data[3]);

	new
		items[10],
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

	modio_push(filename, !"ITEM", GetItemListSize(itemlist), box_ItemList, true);

	DestroyItemList(itemlist);

	return 1;
}

LoadSafeboxItem(filename[], prints = false)
{
	new
		length,
		type[1],
		data[4],
		itemid,
		containerid;

	length = modio_read(filename, !"TYPE", type, false, false);

	if(length == 0)
		return 0;

	if(!IsItemTypeSafebox(ItemType:type[0]))
		return 0;

	modio_read(filename, !"WPOS", _:data, false, false);

	if(Float:data[0] == 0.0 && Float:data[1] == 0.0 && Float:data[2] == 0.0)
		return 0;

	box_SkipGEID = true;
	itemid = CreateItem(ItemType:type[0], Float:data[0], Float:data[1], Float:data[2], .rz = Float:data[3], .zoffset = FLOOR_OFFSET);
	box_SkipGEID = false;

	containerid = GetItemExtraData(itemid);

	sscanf(filename, "'"DIRECTORY_SAFEBOX"box_'p<.>d{s[5]}", box_GEID[itemid]);

	if(box_GEID[itemid] > box_GEID_Index)
	{
		printf("WARNING: Safebox %d GEID (%d) is greater than GEID index (%d). Updating index to avoid GEID collision.", itemid, box_GEID[itemid], box_GEID_Index);
		box_GEID_Index = box_GEID[itemid] + 1;
	}

	if(prints)
		printf("\t[LOAD] Safebox: GEID %d, type %d, at %f, %f, %f", box_GEID[itemid], type[0], data[0], data[1], data[2]);

	new
		ItemType:itemtype,
		itemlist;

	length = modio_read(filename, !"ITEM", box_ItemList, true);

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

	format(filename, sizeof(filename), ""DIRECTORY_SAFEBOX"box_%010d.dat", box_GEID[itemid]);
	fremove(filename);

	return Iter_SafeRemove(box_Index, itemid, itemid);
}


/*==============================================================================

	Legacy format (Load only)

==============================================================================*/


OLD_LoadSafeboxes(printeach = false, printtotal = false)
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

			count += OLD_LoadSafeboxItem(filename, printeach);
		}
	}

	dir_close(direc);

	SaveSafeboxes(printeach, printtotal);

	if(printtotal)
		printf("Loaded %d Safeboxes using old format\n", count);
}

OLD_LoadSafeboxItem(filename[], prints = false)
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
	containerid = GetItemExtraData(itemid);

	if(prints)
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
