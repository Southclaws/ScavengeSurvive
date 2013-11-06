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


new
			box_TypeData[MAX_SAFEBOX_TYPE][E_SAFEBOX_TYPE_DATA],
			box_TypeTotal,
Iterator:	box_Index<ITM_MAX>,
			box_ContainerSafebox[CNT_MAX];

new
			box_CurrentBox[MAX_PLAYERS],
			box_PickUpTick[MAX_PLAYERS],
Timer:		box_PickUpTimer[MAX_PLAYERS];


hook OnGameModeInit()
{
	for(new i; i < CNT_MAX; i++)
		box_ContainerSafebox[i] = INVALID_ITEM_ID;
}

hook OnPlayerConnect(playerid)
{
	box_CurrentBox[playerid] = INVALID_ITEM_ID;
}

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

	return box_TypeTotal++;
}

public OnItemCreate(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	for(new i; i < box_TypeTotal; i++)
	{
		if(itemtype == box_TypeData[i][box_itemtype])
		{
			new containerid;

			containerid = CreateContainer(
				box_TypeData[i][box_name],
				box_TypeData[i][box_size],
				.virtual = 1,
				.max_med = box_TypeData[i][box_maxMed],
				.max_large = box_TypeData[i][box_maxLarge],
				.max_carry = box_TypeData[i][box_maxCarry]);

			box_ContainerSafebox[containerid] = itemid;

			SetItemExtraData(itemid, containerid);
			Iter_Add(box_Index, itemid);
			break;
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

	for(new i; i < box_TypeTotal; i++)
	{
		if(itemtype == box_TypeData[i][box_itemtype])
			SetButtonText(GetItemButtonID(itemid), "Hold "#KEYTEXT_INTERACT" to pick up~n~Press "#KEYTEXT_INTERACT" to open");
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

	for(new i; i < box_TypeTotal; i++)
	{
		if(itemtype == box_TypeData[i][box_itemtype])
		{
			new
				Float:x,
				Float:y,
				Float:z,
				Float:r,
				filename[60],
				containerid;

			GetItemPos(itemid, x, y, z);
			GetItemRot(itemid, r, r, r);
			containerid = GetItemExtraData(itemid);

			if(IsValidContainer(containerid))
				box_ContainerSafebox[containerid] = INVALID_ITEM_ID;

			format(filename, sizeof(filename), ""DIRECTORY_SAFEBOX"%d_%d_%d_%d", x, y, z, r);
			fremove(filename);

			Iter_SafeRemove(box_Index, itemid, itemid);
			DestroyContainer(containerid);

			break;
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



// Interaction



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

	for(new i; i < box_TypeTotal; i++)
	{
		if(itemtype == box_TypeData[i][box_itemtype])
		{
			box_PickUpTick[playerid] = tickcount();
			box_CurrentBox[playerid] = itemid;
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
		if(GetTickCountDifference(tickcount(), box_PickUpTick[playerid]) < 200)
		{
			if(IsValidItem(box_CurrentBox[playerid]))
			{
				DisplayContainerInventory(playerid, GetItemExtraData(box_CurrentBox[playerid]));
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

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		filename[60];

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, r, r, r);

	format(filename, sizeof(filename), ""DIRECTORY_SAFEBOX"%d_%d_%d_%d", x, y, z, r);
	fremove(filename);

	return;
}

public OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidItem(box_CurrentBox[playerid]))
	{
		ClearAnimations(playerid);
		box_CurrentBox[playerid] = INVALID_ITEM_ID;
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



// Save and Load



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
}

LoadSafeboxes(printeach = false, printtotal = false)
{
	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_SAFEBOX),
		item[46],
		type,
		File:file,
		filedir[64],
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		containerid, 
		count;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			new
				data[1 + (CNT_MAX_SLOTS * 2)],
				itemid;

			filedir = DIRECTORY_SAFEBOX;
			strcat(filedir, item);
			file = fopen(filedir, io_read);

			if(file)
			{
				sscanf(item, "p<_>dddd", _:x, _:y, _:z, _:r);

				if(x == 0.0 && y == 0.0 && z == 0.0)
				{
					fremove(filedir);
					continue;
				}

				fblockread(file, data, sizeof(data));
				fclose(file);

				if(!IsItemTypeSafebox(ItemType:data[0]))
				{
					fremove(filedir);
					continue;
				}

				itemid = CreateItem(ItemType:data[0], x, y, z, .rz = r, .zoffset = FLOOR_OFFSET);
				containerid = GetItemExtraData(itemid);

				if(printeach)
					printf("\t[LOAD] Safebox type %d at %f, %f, %f", data[0], x, y, z);

				for(new i = 1, j; j < CNT_MAX_SLOTS; i += 2, j++)
				{
					if(!IsValidItemType(ItemType:data[i]) || data[i] == 0)
						continue;

					itemid = CreateItem(ItemType:data[i], 0.0, 0.0, 0.0);

					if(!IsItemTypeExtraDataDependent(ItemType:data[i]))
						SetItemExtraData(itemid, data[i + 1]);

					AddItemToContainer(containerid, itemid);
				}

				count++;
			}
		}
	}

	dir_close(direc);

	if(printtotal)
		printf("Loaded %d Safeboxes\n", count);
}

SaveSafeboxItem(itemid, prints = false)
{
	if(!IsItemInWorld(itemid))
		return -1;

	if(!IsItemTypeSafebox(GetItemType(itemid)))
		return -1;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		containerid,
		filename[64],
		File:file,
		data[1 + (CNT_MAX_SLOTS * 2)];

	containerid = GetItemExtraData(itemid);

	if(!IsValidContainer(containerid))
		return -1;

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, r, r, r);

	if(x == 0.0 && y == 0.0 && z == 0.0 || r == 0.0)
	{
		return -2;
	}

	format(filename, sizeof(filename), ""DIRECTORY_SAFEBOX"%d_%d_%d_%d", x, y, z, r);

	if(IsContainerEmpty(containerid))
	{
		fremove(filename);
		return -1;
	}

	file = fopen(filename, io_write);

	if(file)
	{
		if(prints)
			printf("\t[SAVE] Safebox type %d at %f, %f, %f, %f", _:GetItemType(itemid), x, y, z, r);

		data[0] = _:GetItemType(itemid);

		for(new i = 1, j; j < CNT_MAX_SLOTS; i += 2, j++)
		{
			data[i] = _:GetItemType(GetContainerSlotItem(containerid, j));
			data[i + 1] = GetItemExtraData(GetContainerSlotItem(containerid, j));

			if(data[i] == 0)
				return 0;
		}
		fblockwrite(file, data, sizeof(data));
		fclose(file);

		return itemid;
	}
	else
	{
		printf("ERROR: Saving safebox, filename: '%s'", filename);
		return -1;
	}
}



// Interface



stock IsItemTypeSafebox(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	for(new i; i < box_TypeTotal; i++)
	{
		if(itemtype == box_TypeData[i][box_itemtype])
		{
			return 1;
		}
	}
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
