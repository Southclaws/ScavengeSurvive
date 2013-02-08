#include <YSI\y_hooks>


#define MAX_SAFEBOX			ITM_MAX
#define MAX_SAFEBOX_TYPE	(8)
#define MAX_SAFEBOX_NAME	(32)
#define SAFEBOX_FOLDER		"SSS/Safebox/"
#define SAFEBOX_DIRECTORY	"./scriptfiles/SSS/Safebox/"


enum E_SAFEBOX_TYPE_DATA
{
			box_name[MAX_SAFEBOX_NAME],
ItemType:	box_itemtype,
			box_size
}


new
			box_TypeData[MAX_SAFEBOX_TYPE][E_SAFEBOX_TYPE_DATA],
			box_TypeTotal,
Iterator:	box_Index<MAX_SAFEBOX>;

new
			box_CurrentBox[MAX_PLAYERS],
			box_PickUpTick[MAX_SAFEBOX],
Timer:		box_PickUpTimer[MAX_PLAYERS];


DefineSafeboxType(name[MAX_SAFEBOX_NAME], ItemType:itemtype, size)
{
	if(box_TypeTotal == MAX_SAFEBOX_TYPE-1)
		return -1;

	box_TypeData[box_TypeTotal][box_name] = name;
	box_TypeData[box_TypeTotal][box_itemtype] = itemtype;
	box_TypeData[box_TypeTotal][box_size] = size;

	return box_TypeTotal++;
}

SaveAllSafeboxes()
{
	foreach(new i : box_Index)
	{
		if(!IsContainerEmpty(GetItemExtraData(i)) && IsItemInWorld(i))
			SaveSafeboxItem(i);
	}
}

LoadSafeboxes()
{
	new
		dir:direc = dir_open(SAFEBOX_DIRECTORY),
		item[46],
		type,
		File:file,
		filedir[64],
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		containerid;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			new
				data[1 + (CNT_MAX_SLOTS * 2)],
				itemid;

			filedir = SAFEBOX_FOLDER;
			strcat(filedir, item);
			file = fopen(filedir, io_read);

			if(file)
			{
				fblockread(file, data, sizeof(data));
				fclose(file);

				sscanf(item, "p<_>dddd", _:x, _:y, _:z, _:r);

				if(data[0] < 98)
				{
					data[0] = _:box_TypeData[data[0]][box_itemtype];
				}

				itemid = CreateItem(ItemType:data[0], x, y, z, .rz = r, .zoffset = FLOOR_OFFSET);
				containerid = GetItemExtraData(itemid);

				printf("[LOAD] Savebox type %d at %f, %f, %f", data[0], x, y, z);

				for(new i = 1, j; j < CNT_MAX_SLOTS; i += 2, j++)
				{
					if(IsValidItemType(ItemType:data[i]))
					{
						itemid = CreateItem(ItemType:data[i], 0.0, 0.0, 0.0);

						if(!IsItemTypeSafebox(ItemType:data[i]) && !IsItemTypeBag(ItemType:data[i]))
							SetItemExtraData(itemid, data[i + 1]);

						AddItemToContainer(containerid, itemid);
					}
				}
			}
		}
	}

	dir_close(direc);
}

SaveSafeboxItem(itemid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		containerid,
		filename[64],
		File:file,
		data[1 + (CNT_MAX_SLOTS * 2)];

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, r, r, r);

	if(x == 0.0 && y == 0.0 && z == 0.0)
		return print("ERROR: Safebox save at null coordinates");

	containerid = GetItemExtraData(itemid);

	format(filename, sizeof(filename), ""#SAFEBOX_FOLDER"%d_%d_%d_%d", x, y, z, r);
	file = fopen(filename, io_write);

	if(file)
	{
		printf("[SAVE] Safebox type %d at %f, %f, %f, %f", _:GetItemType(itemid), x, y, z, r);

		data[0] = _:GetItemType(itemid);

		for(new i = 1, j; j < CNT_MAX_SLOTS; i += 2, j++)
		{
			data[i] = _:GetItemType(GetContainerSlotItem(containerid, j));
			data[i + 1] = GetItemExtraData(GetContainerSlotItem(containerid, j));
		}
		fblockwrite(file, data, sizeof(data));
	}
	else
	{
		printf("ERROR: Saving safebox, filename: '%s'", filename);
	}

	fclose(file);

	return 1;
}

public OnItemCreate(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);
	for(new i; i < box_TypeTotal; i++)
	{
		if(itemtype == box_TypeData[i][box_itemtype])
		{
			new containerid = CreateContainer(box_TypeData[i][box_name], box_TypeData[i][box_size], .virtual = 1);
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

public OnItemDestroy(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);
	for(new i; i < box_TypeTotal; i++)
	{
		if(itemtype == box_TypeData[i][box_itemtype])
		{
			new containerid = GetItemExtraData(itemid);
			for(new j; j < GetContainerSize(containerid); j++)
			{
				DestroyItem(GetContainerSlotItem(containerid, j));
			}
			DestroyContainer(containerid);
			Iter_Remove(box_Index, itemid);
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

public OnPlayerPickUpItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	for(new i; i < box_TypeTotal; i++)
	{
		if(itemtype == box_TypeData[i][box_itemtype])
		{
			return 1;
		}
	}

	return CallLocalFunction("box_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem box_OnPlayerPickUpItem
forward box_OnPlayerPickUpItem(playerid, itemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16)
	{
		foreach(new i : box_Index)
		{
			if(GetPlayerButtonID(playerid) == GetItemButtonID(i))
			{
				box_CurrentBox[playerid] = i;
				box_PickUpTick[playerid] = tickcount();
				stop box_PickUpTimer[playerid];

				if(!IsValidItem(GetPlayerItem(playerid)) && GetPlayerWeapon(playerid) == 0)
					box_PickUpTimer[playerid] = defer box_PickUp(playerid, i);
			}
		}
	}
	if(oldkeys & 16)
	{
		if(tickcount() - box_PickUpTick[playerid] < 200)
		{
			if(IsValidItem(box_CurrentBox[playerid]))
			{
				DisplayContainerInventory(playerid, GetItemExtraData(box_CurrentBox[playerid]));
				stop box_PickUpTimer[playerid];
				box_CurrentBox[playerid] = INVALID_ITEM_ID;
				box_PickUpTick[playerid] = 0;
			}
		}
	}
}

IsItemTypeSafebox(ItemType:itemtype)
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

timer box_PickUp[250](playerid, itemid)
{
	if(IsValidItem(GetPlayerItem(playerid)) || GetPlayerWeapon(playerid) != 0)
		return;

	PlayerPickUpItem(playerid, itemid, 0);

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		filename[60];

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, r, r, r);

	format(filename, sizeof(filename), ""#SAFEBOX_FOLDER"%d_%d_%d_%d", x, y, z, r);
	fremove(filename);

	return;
}
