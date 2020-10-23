/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 "Southclaws" Keene

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


#include <YSI_Coding\y_hooks>


#define DIRECTORY_SAFEBOX	DIRECTORY_MAIN"safebox/"


forward OnSafeboxLoad(Item:itemid, active, uuid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_SAFEBOX);
}

hook OnGameModeInit()
{
	LoadItems(DIRECTORY_SAFEBOX, "OnSafeboxLoad");
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			uuid[UUID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemUUID(itemid, uuid);

		RemoveSafeboxItem(itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDroppedItem(playerid, Item:itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			uuid[UUID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemUUID(itemid, uuid);

		SafeboxSaveCheck(playerid, itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	new Item:itemid = GetContainerSafeboxItem(containerid);

	if(IsValidItem(itemid))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			uuid[UUID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemUUID(itemid, uuid);

		SafeboxSaveCheck(playerid, itemid);
		ClearAnimations(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(Container:containerid, Item:itemid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		new Item:safeboxitem = GetContainerSafeboxItem(containerid);

		if(IsValidItem(safeboxitem))
			SafeboxSaveCheck(playerid, safeboxitem);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromCnt(Container:containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		new Item:safeboxitem = GetContainerSafeboxItem(containerid);

		if(IsValidItem(safeboxitem))
			SafeboxSaveCheck(playerid, safeboxitem);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(Item:itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)))
		RemoveSafeboxItem(itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

SafeboxSaveCheck(playerid, Item:itemid)
{
	new
		ret = SaveSafeboxItem(itemid),
		uuid[UUID_LEN];

	GetItemUUID(itemid, uuid);

	if(ret == 0)
	{
		SetItemLabel(itemid, sprintf("SAVED (itemid: %d, uuid: %s)", _:itemid, uuid), 0xFFFF00FF, 2.0);
	}
	else
	{
		SetItemLabel(itemid, sprintf("NOT SAVED (itemid: %d, uuid: %s)", _:itemid, uuid), 0xFF0000FF, 2.0);

		if(ret == 1)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Invalid item.", _:itemid, uuid);

		if(ret == 2)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Item isn't safebox.", _:itemid, uuid);

		if(ret == 3)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Item not in world.", _:itemid, uuid);

		if(ret == 4)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Container empty", _:itemid, uuid);

		if(ret == 5)
		{
			new containerid;
			GetItemArrayDataAtCell(itemid, containerid, 0);
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Invalid container (%d).", _:itemid, uuid, containerid);
		}
	}
}

RemoveSafeboxItem(Item:itemid)
{
	RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveSafeboxItem(Item:itemid, bool:active = true)
{
	new uuid[UUID_LEN];

	GetItemUUID(itemid, uuid);

	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		err("Can't save safebox %d (%s): Item isn't a safebox, type: %d", _:itemid, uuid, _:GetItemType(itemid));
		return 2;
	}

	new Container:containerid;
	GetItemArrayDataAtCell(itemid, _:containerid, 0);

	if(IsContainerEmpty(containerid))
	{
		RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);
		return 4;
	}

	if(!IsValidContainer(containerid))
	{
		err("Can't save safebox %d (%s): Not valid container (%d).", _:itemid, uuid, _:containerid);
		return 5;
	}

	new
		Item:items[12],
		itemcount,
		size;

	GetContainerSize(containerid, size);

	for(new i; i < size; i++)
	{
		GetContainerSlotItem(containerid, i, items[i]);

		if(!IsValidItem(items[i]))
			break;

		itemcount++;
	}

	if(!SerialiseItems(items, itemcount))
	{
		SaveWorldItem(itemid, DIRECTORY_SAFEBOX, active, false, itm_arr_Serialized, GetSerialisedSize());
	}

	return 0;
}

public OnSafeboxLoad(Item:itemid, active, uuid[], data[], length)
{
	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		err("Loaded item %d (%s) is not a safebox (type: %d)", _:itemid, uuid, _:GetItemType(itemid));
		return 0;
	}

	new
		Container:containerid,
		Item:subitem,
		ItemType:itemtype;

	GetItemArrayDataAtCell(itemid, _:containerid, 0);

	if(!DeserialiseItems(data, length))
	{
		for(new i, j = GetStoredItemCount(); i < j; i++)
		{
			itemtype = GetStoredItemType(i);

			if(length == 0)
				break;

			if(itemtype == INVALID_ITEM_TYPE)
				break;

			if(itemtype == ItemType:0)
				break;

			subitem = CreateItem(itemtype);

			if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
				SetItemArrayDataFromStored(subitem, i);

			AddItemToContainer(containerid, subitem);
		}

		Logger_Log("safebox loaded",
			Logger_S("uuid", uuid),
			Logger_I("itemid", _:itemid),
			Logger_I("containerid", _:containerid),
			Logger_I("active", active),
			Logger_I("items", GetStoredItemCount())
		);

		ClearSerializer();
	}

	return 1;
}
