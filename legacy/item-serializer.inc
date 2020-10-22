// built-in include guard removal
// just in case the user has a local dependency with the same file name
#if defined _inc_item_serializer
    #undef _inc_item_serializer
#endif
// custom include-guard to ensure we don't duplicate
#if defined _item_serializer_included
    #endinput
#endif
#define _item_serializer_included

#include <a_samp>
#include <uuid>
#include <item>

#include <YSI_Coding\y_hooks>


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


#if !defined ITEM_SERIALIZER_MAX_ITEMS
	#define ITEM_SERIALIZER_MAX_ITEMS	(256)
#endif

#define ITEM_SERIALIZER_RAW_SIZE		(2 + (ITEM_SERIALIZER_MAX_ITEMS * (11 + UUID_LEN + ITM_ARR_MAX_ARRAY_DATA)))


// Functions


forward SerialiseItems(const Item:items[], maxitems = sizeof(items));
/*
# Description:
-
*/

forward DeserialiseItems(list[], length = sizeof(list), store = true);
/*
# Description:
-
*/

forward ClearSerializer();
/*
# Description:
-
*/

forward GetSerialisedSize();
/*
# Description:
-
*/

forward GetStoredItemCount();
/*
# Description:
-
*/

forward ItemType:GetStoredItemType(index);
/*
# Description:
-
*/

forward GetStoredItemPos(index, &Float:x, &Float:y, &Float:z);
/*
# Description:
-
*/

forward GetStoredItemRot(index, &Float:x, &Float:y, &Float:z);
/*
# Description:
-
*/

forward GetStoredItemWorld(index);
/*
# Description:
-
*/

forward GetStoredItemInterior(index);
/*
# Description:
-
*/

forward GetStoredItemArrayData(index, output[]);
/*
# Description:
-
*/

forward GetStoredItemArrayDataSize(index);
/*
# Description:
-
*/

forward Item:CreateItemFromStored(index);
/*
# Description:
-
*/

forward Error:SetItemArrayDataFromStored(Item:itemid, index);
/*
# Description:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


static
			// Locks the item data to block interspersing read/write ops.
bool:		itm_list_Lock,

			// Contains a simple list of item types for lookups.
			itm_list_Items[ITEM_SERIALIZER_MAX_ITEMS],

			// World position
Float:		itm_list_WorldX[ITEM_SERIALIZER_MAX_ITEMS],
Float:		itm_list_WorldY[ITEM_SERIALIZER_MAX_ITEMS],
Float:		itm_list_WorldZ[ITEM_SERIALIZER_MAX_ITEMS],

			// Rotation
Float:		itm_list_RotationX[ITEM_SERIALIZER_MAX_ITEMS],
Float:		itm_list_RotationY[ITEM_SERIALIZER_MAX_ITEMS],
Float:		itm_list_RotationZ[ITEM_SERIALIZER_MAX_ITEMS],

			// World and Interior
			itm_list_VirtualWorld[ITEM_SERIALIZER_MAX_ITEMS],
			itm_list_Interior[ITEM_SERIALIZER_MAX_ITEMS],

			// Hit points
			itm_list_Hitpoints[ITEM_SERIALIZER_MAX_ITEMS],

			// UUID
			itm_list_UUID[ITEM_SERIALIZER_MAX_ITEMS][UUID_LEN],

			// Contains the item extra data for returning.
			itm_list_Array[ITEM_SERIALIZER_MAX_ITEMS][ITM_ARR_MAX_ARRAY_DATA],

			// Contains the item data array size
			itm_list_ArraySize[ITEM_SERIALIZER_MAX_ITEMS],

			// Contains the number of items in the list
			itm_list_Count,

			/*
				This is the "raw list" which follows this structure:
				The first two cells are the data size in cells and item count.
				Each block starts with the block size followed by the item data.
				The block size will be: 11 + GEID_LEN (14) + array data size

				data size in cells
				number of items
				item blocks
				[
					block size
					item type
					world x
					world y
					world z
					rotation x
					rotation y
					rotation z
					virtual world
					interior
					hitpoints
					geid[GEID_LEN]
					array data[...]
				]
				...
			*/

			// Size of the raw list
			itm_arr_Size;

			// Raw list is global for easy access.
new			itm_arr_Serialized[ITEM_SERIALIZER_RAW_SIZE];


/*==============================================================================

	Core Functions

==============================================================================*/


stock SerialiseItems(const Item:items[], maxitems = sizeof(items))
{
	if(itm_list_Lock)
	{
		printf("[SerialiseItems] ERROR: serialiser is locked, DeserialiseItems operation not finished with ClearSerializer");
		return 1;
	}

	itm_arr_Size = 0;
	itm_list_Count = 0;

	itm_arr_Serialized[itm_arr_Size++] = 0;
	itm_arr_Serialized[itm_arr_Size++] = maxitems;

	for(new i; i < maxitems; i++)
	{
		itm_list_Items[i] = _:GetItemType(items[i]);
		GetItemPos(items[i], itm_list_WorldX[i], itm_list_WorldY[i], itm_list_WorldZ[i]);
		GetItemRot(items[i], itm_list_RotationX[i], itm_list_RotationY[i], itm_list_RotationZ[i]);
		GetItemWorld(items[i], itm_list_VirtualWorld[i]);
		GetItemInterior(items[i], itm_list_Interior[i]);
		GetItemArrayDataSize(items[i], itm_list_ArraySize[i]);
		GetItemArrayData(items[i], itm_list_Array[i]);
		GetItemUUID(items[i], itm_list_UUID[i]);

		itm_arr_Serialized[itm_arr_Size++] = 11 + UUID_LEN + itm_list_ArraySize[i];
		itm_arr_Serialized[itm_arr_Size++] = itm_list_Items[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_WorldX[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_WorldY[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_WorldZ[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_RotationX[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_RotationY[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_RotationZ[i];
		itm_arr_Serialized[itm_arr_Size++] = itm_list_VirtualWorld[i];
		itm_arr_Serialized[itm_arr_Size++] = itm_list_Interior[i];
		itm_arr_Serialized[itm_arr_Size++] = itm_list_Hitpoints[i];

		memcpy(itm_arr_Serialized, itm_list_UUID[i], itm_arr_Size * 4, UUID_LEN * 4);
		itm_arr_Size += UUID_LEN;

		if(itm_list_ArraySize[i] > 0)
		{
			memcpy(itm_arr_Serialized, itm_list_Array[i], itm_arr_Size * 4, itm_list_ArraySize[i] * 4);
			itm_arr_Size += itm_list_ArraySize[i];
		}


		itm_list_Count++;
	}

	if(itm_list_Count != maxitems)
	{
		printf("[SerialiseItems] ERROR: itm_list_Count != maxitems (%d != %d)", itm_list_Count, maxitems);
		return 1;
	}

	itm_arr_Serialized[0] = itm_arr_Size;


	return 0;
}

stock DeserialiseItems(list[], length = sizeof(list), store = true)
{
	if(itm_list_Lock)
	{
		printf("[SerialiseItems] ERROR: serialiser is locked, DeserialiseItems operation not finished with ClearSerializer");
		return 1;
	}

	itm_list_Lock = true;

	if(store)
		memcpy(itm_arr_Serialized, list, 0, length * 4);

	new expected_item_count = list[1];

	itm_arr_Size = 2;
	itm_list_Count = 0;

	if(length != list[0])
	{
		printf("[DeserialiseItems] ERROR: size in first cell (%d) does not match size passed in (%d)", list[0], length);
		return 1;
	}


	while(itm_list_Count < expected_item_count)
	{
		itm_list_ArraySize[itm_list_Count]		= list[itm_arr_Size++] - (11 + UUID_LEN);
		itm_list_Items[itm_list_Count]			= list[itm_arr_Size++];
		itm_list_WorldX[itm_list_Count]			= Float:list[itm_arr_Size++];
		itm_list_WorldY[itm_list_Count]			= Float:list[itm_arr_Size++];
		itm_list_WorldZ[itm_list_Count]			= Float:list[itm_arr_Size++];
		itm_list_RotationX[itm_list_Count]		= Float:list[itm_arr_Size++];
		itm_list_RotationY[itm_list_Count]		= Float:list[itm_arr_Size++];
		itm_list_RotationZ[itm_list_Count]		= Float:list[itm_arr_Size++];
		itm_list_VirtualWorld[itm_list_Count]	= list[itm_arr_Size++];
		itm_list_Interior[itm_list_Count]		= list[itm_arr_Size++];
		itm_list_Hitpoints[itm_list_Count]		= list[itm_arr_Size++];

		memcpy(itm_list_UUID[itm_list_Count], list[itm_arr_Size], 0, UUID_LEN * 4, UUID_LEN * 4);
		itm_arr_Size += UUID_LEN;

		if(itm_list_ArraySize[itm_list_Count] > 0)
		{
			memcpy(itm_list_Array[itm_list_Count], list[itm_arr_Size], 0, itm_list_ArraySize[itm_list_Count] * 4);
			itm_arr_Size += itm_list_ArraySize[itm_list_Count];
		}

		itm_list_Count++;
	}

	if(itm_arr_Size != list[0])
	{
		printf("[DeserialiseItems] ERROR: itm_arr_Size != list[0] (%d != %d)", itm_arr_Size, list[0]);
		return 1;
	}

	return 0;
}

stock ClearSerializer()
{
	itm_list_Count = 0;
	itm_list_Lock = false;
}

stock GetSerialisedSize()
{
	return itm_arr_Size;
}

stock GetStoredItemCount()
{
	return itm_list_Count;
}

stock ItemType:GetStoredItemType(index)
{
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemType] ERROR: index (%d) out of bounds 0..%d", index, itm_list_Count);
		return INVALID_ITEM_TYPE;
	}

	return ItemType:itm_list_Items[index];
}

stock GetStoredItemPos(index, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemPos] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	x = itm_list_WorldX[index];
	y = itm_list_WorldY[index];
	z = itm_list_WorldZ[index];

	return 1;
}

stock GetStoredItemRot(index, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemRot] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	x = itm_list_RotationX[index];
	y = itm_list_RotationY[index];
	z = itm_list_RotationZ[index];

	return 1;
}

stock GetStoredItemWorld(index)
{
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemWorld] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	return itm_list_VirtualWorld[index];
}

stock GetStoredItemInterior(index)
{
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemInterior] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	return itm_list_Interior[index];
}

stock GetStoredItemArrayData(index, output[])
{
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemArrayData] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	memcpy(output, itm_list_Array[index], 0, itm_list_ArraySize[index] * 4, itm_arr_Size);

	return itm_list_ArraySize[index];
}

stock GetStoredItemArrayDataSize(index)
{
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemArrayDataSize] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	return itm_list_ArraySize[index];
}

stock Item:CreateItemFromStored(index)
{
	if(!(0 <= index < itm_list_Count))
	{
		printf("[CreateItemFromStored] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	new Item:itemid = CreateItem(itm_list_Items[index]);
	SetItemArrayData(itemid, itm_list_Array[index], itm_list_ArraySize[index]);

	return itemid;
}

stock Error:SetItemArrayDataFromStored(Item:itemid, index)
{
	return SetItemArrayData(itemid, itm_list_Array[index], itm_list_ArraySize[index]);
}
