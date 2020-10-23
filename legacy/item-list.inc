/*==============================================================================

# Southclaws's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

Generates arrays of items that include extra-data arrays from ItemArrayData.
Useful for storing BLOBs of items that include their array data too for
"compressing" and writing to files.

An "itemlist" object is a creatable/destroyable entity that contains the list of
items and their array data in separate arrays for fast lookup as well as the
full raw data string for returning. When an itemlist is destroyed, it's handle
becomes free for use by CreateItemList again.

An itemlist can be created from two sources: a list of item IDs or a raw item
list (one that was output from GetItemList).

A basic example of using this script would be:

- Create an item list of a player's inventory items when they quit.
- Get the raw list and store it to an array.
- Store the array in a binary file (using modio or fblockwrite).
- Load the array next time the player logs in.
- Use ExtractItemList on the loaded data to extract items.
- Loop through the items and create them with their array data.
- Add the items to the player's inventory.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_ITEMLIST_INCLUDED
	#endinput
#endif

#if !defined _SIF_DEBUG_INCLUDED
	#include "debug.inc"
#endif

#if !defined _SIF_CORE_INCLUDED
	#include "core.inc"
#endif

#define _SIF_ITEMLIST_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


#if !defined ITM_LST_MAX_LIST
	#define ITM_LST_MAX_LIST		(32)
#endif

#if !defined ITM_LST_MAX_LIST_ITEMS
	#define ITM_LST_MAX_LIST_ITEMS	(256)
#endif

#define ITM_LST_MAX_LIST_SIZE	(1 + (ITM_LST_MAX_LIST_ITEMS * (10 + ITM_ARR_MAX_ARRAY_DATA)))

#define ITM_LST_OF_ITEMS(%0)	(1 + (%0 * (10 + ITM_ARR_MAX_ARRAY_DATA)))


// Functions


forward CreateItemList(items[], maxitems = sizeof(items));
/*
# Description:
-
*/

forward ExtractItemList(list[], length = sizeof(list));
/*
# Description:
-
*/

forward DestroyItemList(itemlist);
/*
# Description:
-
*/

forward GetItemList(itemlist, output[]);
/*
# Description:
-
*/

forward GetItemListSize(itemlist);
/*
# Description:
-
*/

forward GetItemListElement(itemlist, index);
/*
# Description:
-
*/

forward GetItemListItemCount(itemlist);
/*
# Description:
-
*/

forward ItemType:GetItemListItem(itemlist, index);
/*
# Description:
-
*/

forward GetItemListItemPos(itemlist, index, &Float:x, &Float:y, &Float:z);
/*
# Description:
-
*/

forward GetItemListItemRot(itemlist, index, &Float:x, &Float:y, &Float:z);
/*
# Description:
-
*/

forward GetItemListItemWorld(itemlist, index);
/*
# Description:
-
*/

forward GetItemListItemInterior(itemlist, index);
/*
# Description:
-
*/

forward GetItemListItemArrayData(itemlist, index, output[]);
/*
# Description:
-
*/

forward GetItemListItemArrayDataSize(itemlist, index);
/*
# Description:
-
*/

forward CreateItemFromListItem(itemlist, index);
/*
# Description:
-
*/

forward SetItemArrayDataFromListItem(itemid, itemlist, index);
/*
# Description:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


static
			// Contains a simple list of item types for lookups.
			itm_lst_Items[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS],

			// World position
Float:		itm_lst_WorldX[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS],
Float:		itm_lst_WorldY[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS],
Float:		itm_lst_WorldZ[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS],

				// Rotation
Float:		itm_lst_RotationX[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS],
Float:		itm_lst_RotationY[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS],
Float:		itm_lst_RotationZ[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS],

			// World and Interior
			itm_lst_VirtualWorld[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS],
			itm_lst_Interior[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS],

			// Contains the item extra data for returning.
			itm_lst_Array[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS][ITM_ARR_MAX_ARRAY_DATA],

			// Contains the item data array size
			itm_lst_ArraySize[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_ITEMS],

			// Contains the number of items in the list
			itm_lst_Count[ITM_LST_MAX_LIST],

			/*
				This is the "raw list" which follows this structure:
				First cell in the list is the item count.
				Each item block starts with the itemtype then array data size.

				number of items
				item blocks
				[
					item type
					world x
					world y
					world z
					rotation x
					rotation y
					rotation z
					virtual world
					interior
					array data size
					array data[...]
				]
				...
			*/
			itm_lst_List[ITM_LST_MAX_LIST][ITM_LST_MAX_LIST_SIZE],

			// Size of the raw list
			itm_lst_Size[ITM_LST_MAX_LIST],

			// For create/destroy functionality
   Iterator:itm_lst_Index<ITM_LST_MAX_LIST>;


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateItemList(items[], maxitems = sizeof(items))
{
	new id = Iter_Free(itm_lst_Index);

	if(id == -1)
		return -1;

	itm_lst_Size[id] = 0;
	itm_lst_List[id][itm_lst_Size[id]++] = maxitems;

	for(new i; i < maxitems; i++)
	{
		itm_lst_Items[id][i] = _:GetItemType(items[i]);
		GetItemPos(items[i], itm_lst_WorldX[id][i], itm_lst_WorldY[id][i], itm_lst_WorldZ[id][i]);
		GetItemRot(items[i], itm_lst_RotationX[id][i], itm_lst_RotationY[id][i], itm_lst_RotationZ[id][i]);
		itm_lst_VirtualWorld[id][i] = GetItemWorld(items[i]);
		itm_lst_Interior[id][i] = GetItemInterior(items[i]);
		itm_lst_ArraySize[id][i] = GetItemArrayDataSize(items[i]);
		GetItemArrayData(items[i], itm_lst_Array[id][i]);

		itm_lst_List[id][itm_lst_Size[id]++] = itm_lst_Items[id][i];

		itm_lst_List[id][itm_lst_Size[id]++] = _:itm_lst_WorldX[id][i];
		itm_lst_List[id][itm_lst_Size[id]++] = _:itm_lst_WorldY[id][i];
		itm_lst_List[id][itm_lst_Size[id]++] = _:itm_lst_WorldZ[id][i];

		itm_lst_List[id][itm_lst_Size[id]++] = _:itm_lst_RotationX[id][i];
		itm_lst_List[id][itm_lst_Size[id]++] = _:itm_lst_RotationY[id][i];
		itm_lst_List[id][itm_lst_Size[id]++] = _:itm_lst_RotationZ[id][i];

		itm_lst_List[id][itm_lst_Size[id]++] = itm_lst_VirtualWorld[id][i];
		itm_lst_List[id][itm_lst_Size[id]++] = itm_lst_Interior[id][i];

		itm_lst_List[id][itm_lst_Size[id]++] = itm_lst_ArraySize[id][i];

		if(itm_lst_ArraySize[id][i] > 0)
		{
			memcpy(itm_lst_List[id], itm_lst_Array[id][i], itm_lst_Size[id] * 4, itm_lst_ArraySize[id][i] * 4);
			itm_lst_Size[id] += itm_lst_ArraySize[id][i];
		}
/*
		printf(" loop %d, id: %d, itm_lst_Count: %d, itemtype: %d, arrsize: %d, arr[0]: %d",
			itm_lst_Size[id],
			id,
			itm_lst_Count[id],
			itm_lst_Items[id][itm_lst_Count[id]],
			itm_lst_ArraySize[id][itm_lst_Count[id]],
			itm_lst_Array[id][itm_lst_Count[id]][0]);
*/
		itm_lst_Count[id]++;
	}

	Iter_Add(itm_lst_Index, id);

	return id;
}

stock ExtractItemList(list[], length = sizeof(list))
{
	new id = Iter_Free(itm_lst_Index);

	if(id == -1)
		return -1;

	memcpy(itm_lst_List[id], list, 0, length * 4);
	itm_lst_Size[id] = 1;

	while(itm_lst_Count[id] < list[0])
	{
		itm_lst_Items[id][itm_lst_Count[id]] = list[itm_lst_Size[id]++];

		itm_lst_WorldX[id][itm_lst_Count[id]]		= Float:list[itm_lst_Size[id]++];
		itm_lst_WorldY[id][itm_lst_Count[id]]		= Float:list[itm_lst_Size[id]++];
		itm_lst_WorldZ[id][itm_lst_Count[id]]		= Float:list[itm_lst_Size[id]++];

		itm_lst_RotationX[id][itm_lst_Count[id]]	= Float:list[itm_lst_Size[id]++];
		itm_lst_RotationY[id][itm_lst_Count[id]]	= Float:list[itm_lst_Size[id]++];
		itm_lst_RotationZ[id][itm_lst_Count[id]]	= Float:list[itm_lst_Size[id]++];

		itm_lst_VirtualWorld[id][itm_lst_Count[id]]	= list[itm_lst_Size[id]++];
		itm_lst_Interior[id][itm_lst_Count[id]]		= list[itm_lst_Size[id]++];

		itm_lst_ArraySize[id][itm_lst_Count[id]]	= list[itm_lst_Size[id]++];

		if(itm_lst_ArraySize[id][itm_lst_Count[id]] > 0)
		{
			memcpy(itm_lst_Array[id][itm_lst_Count[id]], list[itm_lst_Size[id]], 0, itm_lst_ArraySize[id][itm_lst_Count[id]] * 4);
			itm_lst_Size[id] += itm_lst_ArraySize[id][itm_lst_Count[id]];
		}
/*
		printf(" loop %d / %d, id: %d, itm_lst_Count: %d, itemtype: %d, arrsize: %d, arr[0]: %d, list[%d]: %d",
			itm_lst_Size[id],
			length,
			id,
			itm_lst_Count[id],
			itm_lst_Items[id][itm_lst_Count[id]],
			itm_lst_ArraySize[id][itm_lst_Count[id]],
			itm_lst_Array[id][itm_lst_Count[id]][0],
			itm_lst_Size[id],
			list[itm_lst_Size[id]]);
*/
		itm_lst_Count[id]++;
	}

	Iter_Add(itm_lst_Index, id);

	return id;
}

stock DestroyItemList(itemlist)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	itm_lst_Count[itemlist] = 0;
	itm_lst_Size[itemlist] = 0;

	Iter_Remove(itm_lst_Index, itemlist);

	return 1;
}

stock GetItemList(itemlist, output[])
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	memcpy(output, itm_lst_List[itemlist], 0, itm_lst_Size[itemlist] * 4, itm_lst_Size[itemlist]);
	
	return itm_lst_Size[itemlist];
}

stock GetItemListSize(itemlist)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	return itm_lst_Size[itemlist];
}

stock GetItemListElement(itemlist, index)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	return itm_lst_List[itemlist][index];
}

stock GetItemListItemCount(itemlist)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	return itm_lst_Count[itemlist];
}

stock ItemType:GetItemListItem(itemlist, index)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return INVALID_ITEM_TYPE;

	return ItemType:itm_lst_Items[itemlist][index];
}

stock GetItemListItemPos(itemlist, index, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	x = itm_lst_WorldX[itemlist][index];
	y = itm_lst_WorldY[itemlist][index];
	z = itm_lst_WorldZ[itemlist][index];

	return 1;
}

stock GetItemListItemRot(itemlist, index, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	x = itm_lst_RotationX[itemlist][index];
	y = itm_lst_RotationY[itemlist][index];
	z = itm_lst_RotationZ[itemlist][index];

	return 1;
}

stock GetItemListItemWorld(itemlist, index)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	return itm_lst_VirtualWorld[itemlist][index];
}

stock GetItemListItemInterior(itemlist, index)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	return itm_lst_Interior[itemlist][index];
}

stock GetItemListItemArrayData(itemlist, index, output[])
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	memcpy(output, itm_lst_Array[itemlist][index], 0, itm_lst_ArraySize[itemlist][index] * 4, itm_lst_Size[itemlist]);

	return itm_lst_ArraySize[itemlist][index];
}

stock GetItemListItemArrayDataSize(itemlist, index)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	return itm_lst_ArraySize[itemlist][index];
}

stock CreateItemFromListItem(itemlist, index)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return -2;

	new itemid;

	itemid = CreateItem(itm_lst_Items[itemlist][index]);
	SetItemArrayData(itemid, itm_lst_Array[itemlist][index], itm_lst_ArraySize[itemlist][index]);

	return itemid;
}

stock SetItemArrayDataFromListItem(itemid, itemlist, index)
{
	if(!Iter_Contains(itm_lst_Index, itemlist))
		return 0;

	if(!IsValidItem(itemid))
		return -1;

	SetItemArrayData(itemid, itm_lst_Array[itemlist][index], itm_lst_ArraySize[itemlist][index]);

	return itm_lst_ArraySize[itemlist][index];
}
