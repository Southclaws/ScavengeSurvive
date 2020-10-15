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


#include <YSI_Coding\y_hooks>


#define DIRECTORY_SAFEBOX	DIRECTORY_MAIN"safebox/"


forward OnSafeboxLoad(itemid, active, geid[], data[], length);


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

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			geid[GEID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemGEID(itemid, geid);

		RemoveSafeboxItem(itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			geid[GEID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemGEID(itemid, geid);

		SafeboxSaveCheck(playerid, itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	new itemid = GetContainerSafeboxItem(containerid);

	if(IsValidItem(itemid))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			geid[GEID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemGEID(itemid, geid);

		SafeboxSaveCheck(playerid, itemid);
		ClearAnimations(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(containerid, itemid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		new safeboxitem = GetContainerSafeboxItem(containerid);

		if(IsValidItem(safeboxitem))
			SafeboxSaveCheck(playerid, safeboxitem);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromCnt(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		new safeboxitem = GetContainerSafeboxItem(containerid);

		if(IsValidItem(safeboxitem))
			SafeboxSaveCheck(playerid, safeboxitem);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)))
		RemoveSafeboxItem(itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

SafeboxSaveCheck(playerid, itemid)
{
	new
		ret = SaveSafeboxItem(itemid),
		geid[GEID_LEN];

	GetItemGEID(itemid, geid);

	if(ret == 0)
	{
		SetItemLabel(itemid, sprintf("SAVED (itemid: %d, geid: %s)", itemid, geid), 0xFFFF00FF, 2.0);
	}
	else
	{
		SetItemLabel(itemid, sprintf("NOT SAVED (itemid: %d, geid: %s)", itemid, geid), 0xFF0000FF, 2.0);

		if(ret == 1)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Invalid item.", itemid, geid);

		if(ret == 2)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Item isn't safebox.", itemid, geid);

		if(ret == 3)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Item not in world.", itemid, geid);

		if(ret == 4)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Container empty", itemid, geid);

		if(ret == 5)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Invalid container (%d).", itemid, geid, GetItemArrayDataAtCell(itemid, 0));
	}
}

RemoveSafeboxItem(itemid)
{
	RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveSafeboxItem(itemid, bool:active = true)
{
	new geid[GEID_LEN];

	GetItemGEID(itemid, geid);

	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		err("Can't save safebox %d (%s): Item isn't a safebox, type: %d", itemid, geid, _:GetItemType(itemid));
		return 2;
	}

	new containerid = GetItemArrayDataAtCell(itemid, 0);

	if(IsContainerEmpty(containerid))
	{
		RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);
		return 4;
	}

	if(!IsValidContainer(containerid))
	{
		err("Can't save safebox %d (%s): Not valid container (%d).", itemid, geid, containerid);
		return 5;
	}

	new
		items[12],
		itemcount;

	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		items[i] = GetContainerSlotItem(containerid, i);

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

public OnSafeboxLoad(itemid, active, geid[], data[], length)
{
	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		err("Loaded item %d (%s) is not a safebox (type: %d)", itemid, geid, _:GetItemType(itemid));
		return 0;
	}

	new
		containerid = GetItemArrayDataAtCell(itemid, 0),
		subitem,
		ItemType:itemtype;

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
			Logger_S("geid", geid),
			Logger_I("itemid", itemid),
			Logger_I("containerid", containerid),
			Logger_I("active", active),
			Logger_I("items", GetStoredItemCount())
		);

		ClearSerializer();
	}

	return 1;
}
