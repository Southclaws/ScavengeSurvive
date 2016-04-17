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


#define MAX_LOOT_INDEX			(15)
#define MAX_LOOT_INDEX_ITEMS	(256)
#define MAX_LOOT_INDEX_NAME		(5)
#define MAX_LOOT_SPAWN			(12683)
#define MAX_ITEMS_PER_SPAWN		(6)


enum E_LOOT_INDEX_ITEM_DATA
{
ItemType:	lootitem_type,
Float:		lootitem_weight,
			lootitem_limit
}

enum E_LOOT_SPAWN_DATA
{
Float:		loot_posX,
Float:		loot_posY,
Float:		loot_posZ,
			loot_world,
			loot_interior,
Float:		loot_weight,
			loot_size,
			loot_index,

			loot_items[MAX_ITEMS_PER_SPAWN],
			loot_total
}


static
			loot_IndexTotal,
			loot_IndexSize[MAX_LOOT_INDEX],
			loot_IndexItems[MAX_LOOT_INDEX][MAX_LOOT_INDEX_ITEMS][E_LOOT_INDEX_ITEM_DATA],
			loot_IndexName[MAX_LOOT_INDEX][MAX_LOOT_INDEX_NAME],

			loot_SpawnData[MAX_LOOT_SPAWN][E_LOOT_SPAWN_DATA],
			loot_SpawnTotal,

			loot_ItemTypeLimit[ITM_MAX_TYPES],
			loot_ItemLootIndex[ITM_MAX] = {-1, ...},

Float:		loot_SpawnMult = 1.0;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Loot/Spawn'...");

	GetSettingFloat("server/loot-spawn-multiplier", 1.0, loot_SpawnMult);
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineLootIndex(name[MAX_LOOT_INDEX_NAME])
{
	if(loot_IndexTotal >= MAX_LOOT_INDEX)
		printf("ERROR: Loot index limit reached at '%s'.", name);

	loot_IndexName[loot_IndexTotal] = name;

	return loot_IndexTotal++;
}

stock AddItemToLootIndex(index, ItemType:itemtype, Float:weight, perspawnlimit = 3, serverspawnlimit = 0)
{
	if(index > loot_IndexTotal)
		return 0;

	if(loot_IndexSize[index] >= MAX_LOOT_INDEX_ITEMS)
		print("ERROR: Loot index item limit reached.");

	loot_IndexItems[index][loot_IndexSize[index]][lootitem_type] = itemtype;
	loot_IndexItems[index][loot_IndexSize[index]][lootitem_weight] = weight;
	loot_IndexItems[index][loot_IndexSize[index]][lootitem_limit] = perspawnlimit;
	
	loot_ItemTypeLimit[itemtype] = serverspawnlimit;

	loot_IndexSize[index] += 1;

	return 1;
}

stock CreateStaticLootSpawn(Float:x, Float:y, Float:z, lootindex, Float:weight, size = -1, worldid = 0, interiorid = 0)
{
	if(loot_SpawnMult == 0.0)
		return -1;

	if(loot_SpawnTotal >= MAX_LOOT_SPAWN - 1)
	{
		print("ERROR: Loot spawn limit reached.");
		return -1;
	}

	if(size > MAX_ITEMS_PER_SPAWN)
		size = -1;

	if(size == -1)
		size = MAX_ITEMS_PER_SPAWN / 2 + random(MAX_ITEMS_PER_SPAWN / 2);

	new lootspawnid = loot_SpawnTotal;

	loot_SpawnData[lootspawnid][loot_posX] = x;
	loot_SpawnData[lootspawnid][loot_posY] = y;
	loot_SpawnData[lootspawnid][loot_posZ] = z;
	loot_SpawnData[lootspawnid][loot_world] = worldid;
	loot_SpawnData[lootspawnid][loot_interior] = interiorid;
	loot_SpawnData[lootspawnid][loot_weight] = weight;
	loot_SpawnData[lootspawnid][loot_size] = size;
	loot_SpawnData[lootspawnid][loot_index] = lootindex;

	new
		samplelist[MAX_LOOT_INDEX_ITEMS][E_LOOT_INDEX_ITEM_DATA],
		samplelistsize,
		cell,
		ItemType:itemtype,
		itemid,
		Float:rot = frandom(360.0);

	for(new i; i < loot_IndexSize[lootindex]; ++i)
	{
		samplelist[i][lootitem_type] = loot_IndexItems[lootindex][i][lootitem_type];
		samplelist[i][lootitem_limit] = loot_IndexItems[lootindex][i][lootitem_limit];
		samplelist[i][lootitem_weight] = loot_IndexItems[lootindex][i][lootitem_weight];
	}

	samplelistsize = loot_IndexSize[lootindex];

	for(new i; i < size; i++)
	{
		// Generate an item from the sample list

		if(!_loot_PickFromSampleList(samplelist, samplelistsize, cell))
			continue;

		itemtype = samplelist[cell][lootitem_type];

		// Check if the generated item is legal
		if(loot_ItemTypeLimit[itemtype] > 0 && GetItemTypeCount(itemtype) > loot_ItemTypeLimit[itemtype])
		{
			_loot_RemoveFromSampleList(samplelist, cell);
			samplelistsize--;
			continue;
		}

		if(samplelist[cell][lootitem_limit] > 0 && _loot_LootSpawnItemsOfType(lootspawnid, itemtype) > samplelist[cell][lootitem_limit])
		{
			_loot_RemoveFromSampleList(samplelist, cell);
			samplelistsize--;
			continue;
		}

		// Create the item
		itemid = GetNextItemID();

		if(!(0 <= itemid < ITM_MAX))
		{
			print("ERROR: Item limit reached while generating loot.");
			return -1;
		}

		loot_ItemLootIndex[itemid] = lootindex;

		CreateItem(itemtype,
			x + (frandom(1.0) * floatsin(((360 / size) * i) + rot, degrees)),
			y + (frandom(1.0) * floatcos(((360 / size) * i) + rot, degrees)),
			z, .zoffset = ITEM_BUTTON_OFFSET, .rz = frandom(360.0), .world = worldid, .interior = interiorid);

		loot_SpawnData[lootspawnid][loot_items][loot_SpawnData[lootspawnid][loot_total]] = itemid;
		loot_SpawnData[lootspawnid][loot_total]++;
	}

	return loot_SpawnTotal++;
}

stock CreateLootItem(lootindex, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, worldid = 0, interiorid = 0, Float:zoffset = ITEM_BUTTON_OFFSET)
{
	new cell;

	if(!_loot_PickFromSampleList(loot_IndexItems[lootindex], loot_IndexSize[lootindex], cell))
		return INVALID_ITEM_ID;

	new ItemType:itemtype = loot_IndexItems[lootindex][cell][lootitem_type];

	if(loot_ItemTypeLimit[itemtype] > 0 && GetItemTypeCount(itemtype) > loot_ItemTypeLimit[itemtype])
		return INVALID_ITEM_ID;

	new itemid = GetNextItemID();

	if(!(0 <= itemid < ITM_MAX))
		return INVALID_ITEM_ID;

	loot_ItemLootIndex[itemid] = lootindex;

	CreateItem(itemtype, x, y, z, .zoffset = zoffset, .rz = frandom(360.0), .world = worldid, .interior = interiorid);

	return itemid;
}

stock FillContainerWithLoot(containerid, slots, lootindex)
{
	//printf("[FillContainerWithLoot] containerid %d, slots %d, lootindex %d", containerid, slots, lootindex);
	new containersize = GetContainerSize(containerid);

	if(slots > containersize)
		slots = containersize;

	else if(slots <= 0)
		return 0;

	new
		samplelist[MAX_LOOT_INDEX_ITEMS][E_LOOT_INDEX_ITEM_DATA],
		samplelistsize,
		items,
		cell,
		itemid,
		ItemType:itemtype;

	for(new i; i < loot_IndexSize[lootindex]; ++i)
	{
		samplelist[i][lootitem_type] = loot_IndexItems[lootindex][i][lootitem_type];
		samplelist[i][lootitem_limit] = loot_IndexItems[lootindex][i][lootitem_limit];
		samplelist[i][lootitem_weight] = loot_IndexItems[lootindex][i][lootitem_weight];
	}

	samplelistsize = loot_IndexSize[lootindex];

	while(items < slots && samplelistsize > 0 && GetContainerFreeSlots(containerid) > 0)
	{
		// Generate an item from the sample list

		if(!_loot_PickFromSampleList(samplelist, samplelistsize, cell))
			continue;

		itemtype = samplelist[cell][lootitem_type];

		// Check if the generated item is legal
		if(loot_ItemTypeLimit[itemtype] > 0 && GetItemTypeCount(itemtype) >= loot_ItemTypeLimit[itemtype])
		{
			_loot_RemoveFromSampleList(samplelist, cell);
			samplelistsize--;
			continue;
		}

		if(samplelist[cell][lootitem_limit] > 0 && _loot_ContainerItemsOfType(containerid, itemtype) >= samplelist[cell][lootitem_limit])
		{
			_loot_RemoveFromSampleList(samplelist, cell);
			samplelistsize--;
			continue;
		}

		// Create the item
		itemid = GetNextItemID();

		if(!(0 <= itemid < ITM_MAX))
		{
			print("ERROR: Item limit reached while generating loot.");
			return -1;
		}

		loot_ItemLootIndex[itemid] = lootindex;

		// allocate the item first
		itemid = AllocNextItemID(itemtype);
		// add it to the container before creating
		AddItemToContainer(containerid, itemid);
		// now OnItemCreate will return a value for GetItemContainer :)
		CreateItem_ExplicitID(itemid);

		items++;
	}

	return 1;
}


/*==============================================================================

	Internal

==============================================================================*/


_loot_PickFromSampleList(list[MAX_LOOT_INDEX_ITEMS][E_LOOT_INDEX_ITEM_DATA], listsize, &cell)
{
	new Float:value;

// Another selection method that will *always* return an item:
// Might be used in the future if the calling code is optimised.
//	do
//	{
//		cell = random(listsize);
//		value = frandom(100.0);
//		printf("[_loot_PickFromSampleList] Checking cell %d: type: %d weight: %f", cell, list[cell][lootitem_type], list[cell][lootitem_weight]);
//	}
//	while(value > list[cell][lootitem_weight]);
// However this one has a chance of not returning an item:

	cell = random(listsize);
	value = frandom(100.0);

	if(value > (list[cell][lootitem_weight] * loot_SpawnMult))
		return 0;

	if(!IsValidItemType(list[cell][lootitem_type]))
		return 0;

	return 1;
}

_loot_RemoveFromSampleList(list[MAX_LOOT_INDEX_ITEMS][E_LOOT_INDEX_ITEM_DATA], cell)
{
	for(new i = cell; i < MAX_LOOT_INDEX_ITEMS - 1; i++)
		list[i] = list[i+1];
}

_loot_LootSpawnItemsOfType(lootspawnid, ItemType:itemtype)
{
	new count;

	for(new i; i < loot_SpawnData[lootspawnid][loot_total]; i++)
	{
		if(GetItemType(loot_SpawnData[lootspawnid][loot_items][i]) == itemtype)
			count++;
	}
	//printf("[_loot_LootSpawnItemsOfType] loot spawn %d contains %d of %d", lootspawnid, count, _:itemtype);
	return count;
}

_loot_ContainerItemsOfType(containerid, ItemType:itemtype)
{
	new count;

	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		if(GetItemType(GetContainerSlotItem(containerid, i)) == itemtype)
			count++;
	}
	//printf("[_loot_ContainerItemsOfType] container %d contains %d of %d", containerid, count, _:itemtype);
	return count;
}

hook OnItemDestroy(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemDestroy] in /gamemodes/sss/core/world/loot.pwn");

	loot_ItemLootIndex[itemid] = -1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetItemLootIndex(itemid)
{
	if(!IsValidItem(itemid))
		return -1;

	return loot_ItemLootIndex[itemid];
}

// loot_posX
// loot_posY
// loot_posZ
stock GetLootSpawnPos(lootspawn, &Float:x, &Float:y, &Float:z)
{
	x = loot_SpawnData[lootspawn][loot_posX];
	y = loot_SpawnData[lootspawn][loot_posY];
	z = loot_SpawnData[lootspawn][loot_posZ];

	return 1;
}

// loot_world
stock GetLootSpawnWorld(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_world];
}

// loot_interior
stock GetLootSpawnInterior(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_interior];
}

// loot_weight
stock GetLootSpawnWeight(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_weight];
}

// loot_size
stock GetLootSpawnSize(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_size];
}

// loot_index
stock GetLootSpawnIndex(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_index];
}

// loot_items
stock GetLootSpawnItems(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_items];
}

// loot_total
stock GetLootSpawnTotalItems(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_total];
}

