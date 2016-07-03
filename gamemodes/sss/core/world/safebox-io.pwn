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


#define DIRECTORY_SAFEBOX	DIRECTORY_MAIN"safebox/"


static box_ItemList[ITM_LST_OF_ITEMS(12)];

forward OnSafeboxLoad(itemid, active, geid[], data[], length);

static HANDLER = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'safebox-io'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_SAFEBOX);

	HANDLER = debug_register_handler("safebox-io");
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'safebox-io'...");

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
		d:1:HANDLER("[OnPlayerPickUpItem] Player %p picked up safebox item %d (%s) at %f %f %f", playerid, itemid, geid, x, y, z);

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
		d:1:HANDLER("[OnPlayerDroppedItem] Player %p dropped safebox item %d (%s) at %f %f %f", playerid, itemid, geid, x, y, z);

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
		d:1:HANDLER("[OnPlayerCloseContainer] Player %p closed safebox item %d (%s) at %f %f %f", playerid, itemid, geid, x, y, z);

		SafeboxSaveCheck(playerid, itemid);
		ClearAnimations(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemDestroy] in /gamemodes/sss/core/world/safebox.pwn");

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
	SaveSafeboxItem(itemid, false);
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
		printf("[SaveSafeboxItem] ERROR: Can't save safebox %d (%s): Item isn't a safebox, type: %d", itemid, geid, _:GetItemType(itemid));
		return 2;
	}

	new containerid = GetItemArrayDataAtCell(itemid, 0);

	if(IsContainerEmpty(containerid))
	{
		d:1:HANDLER("[SaveSafeboxItem] Not saving safebox %d (%s): Container is empty", geid, itemid);
		RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);
		return 4;
	}

	if(!IsValidContainer(containerid))
	{
		printf("[SaveSafeboxItem] ERROR: Can't save safebox %d (%s): Not valid container (%d).", itemid, geid, containerid);
		return 5;
	}

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

	SaveWorldItem(itemid, DIRECTORY_SAFEBOX, active, false, box_ItemList, GetItemListSize(itemlist));

	DestroyItemList(itemlist);

	return 0;
}

public OnSafeboxLoad(itemid, active, geid[], data[], length)
{
	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		printf("[OnSafeboxLoad] ERROR: Loaded item %d (%s) is not a safebox (type: %d)", itemid, geid, _:GetItemType(itemid));
		return 0;
	}

	new
		containerid = GetItemArrayDataAtCell(itemid, 0),
		subitem,
		ItemType:itemtype,
		itemlist;

	itemlist = ExtractItemList(data, length);

	for(new i, j = GetItemListItemCount(itemlist); i < j; i++)
	{
		itemtype = GetItemListItem(itemlist, i);

		if(length == 0)
			break;

		if(itemtype == INVALID_ITEM_TYPE)
			break;

		if(itemtype == ItemType:0)
			break;

		subitem = CreateItem(itemtype);

		if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
			SetItemArrayDataFromListItem(subitem, itemlist, i);

		AddItemToContainer(containerid, subitem);
	}

	DestroyItemList(itemlist);

	return 1;
}
