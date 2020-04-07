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


#define MAX_LOOT_INDEX			(15)
#define MAX_LOOT_INDEX_ITEMS	(256)
#define MAX_LOOT_INDEX_NAME		(32)
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
	GetSettingFloat("server/loot-spawn-multiplier", 1.0, loot_SpawnMult);
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineLootIndex(name[MAX_LOOT_INDEX_NAME])
{
	if(loot_IndexTotal >= MAX_LOOT_INDEX)
		err("Loot index limit reached at '%s'.", name);

	loot_IndexName[loot_IndexTotal] = name;

	return loot_IndexTotal++;
}

stock AddItemToLootIndex(index, ItemType:itemtype, Float:weight, perspawnlimit = 3, serverspawnlimit = 0)
{
	if(index > loot_IndexTotal)
		return 0;

	if(loot_IndexSize[index] >= MAX_LOOT_INDEX_ITEMS)
		err("Loot index item limit reached.");

	loot_IndexItems[index][loot_IndexSize[index]][lootitem_type] = itemtype;
	loot_IndexItems[index][loot_IndexSize[index]][lootitem_weight] = weight;
	loot_IndexItems[index][loot_IndexSize[index]][lootitem_limit] = perspawnlimit;
	
	loot_ItemTypeLimit[itemtype] = serverspawnlimit;

	loot_IndexSize[index] += 1;

	return 1;
}

stock CreateStaticLootSpawn(Float:x, Float:y, Float:z, lootindex, Float:weight, size = -1, worldid = 0, interiorid = 0)
{
	if(loot_SpawnTotal >= MAX_LOOT_SPAWN - 1)
	{
		err("Loot spawn limit reached.");
		return -1;
	}

	if(!(0 <= lootindex < loot_IndexTotal))
	{
		err("Loot index (%d) is invalid.", lootindex);
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
		ItemType:samplelist[MAX_LOOT_INDEX_ITEMS],
		samplelistsize,
		ItemType:itemtype,
		itemid,
		Float:rot = frandom(360.0);

	samplelistsize = _loot_GenerateSampleList(samplelist, lootindex);

	if(samplelistsize == 0)
		return -1;

	// log("[CreateStaticLootSpawn] index %d size %d: %s", lootindex, samplelistsize, atosr(_:samplelist, samplelistsize));

	for(new i; i < size; i++)
	{
		if(frandom(100.0) > weight * loot_SpawnMult)
			continue;

		// Generate an item from the sample list
		if(!_loot_PickFromSampleList(samplelist, samplelistsize, itemtype))
			continue;

		if(itemtype == item_NULL)
		{
			err("Chosen cell contained itemtype 0, index %d size %d: %s", lootindex, samplelistsize, atosr(_:samplelist, samplelistsize));
			continue;
		}

		// Check if the generated item is legal
		if(loot_ItemTypeLimit[itemtype] > 0 && GetItemTypeCount(itemtype) > loot_ItemTypeLimit[itemtype])
			continue;

		// Create the item
		itemid = GetNextItemID();

		if(!(0 <= itemid < ITM_MAX))
		{
			err("Item limit reached while generating loot.");
			return -1;
		}

		loot_ItemLootIndex[itemid] = lootindex;

		CreateItem(itemtype,
			x + (frandom(1.0) * floatsin(((360 / size) * i) + rot, degrees)),
			y + (frandom(1.0) * floatcos(((360 / size) * i) + rot, degrees)),
			z, .rz = frandom(360.0), .world = worldid, .interior = interiorid);

		loot_SpawnData[lootspawnid][loot_items][loot_SpawnData[lootspawnid][loot_total]] = itemid;
		loot_SpawnData[lootspawnid][loot_total]++;
	}

	return loot_SpawnTotal++;
}

stock CreateLootItem(lootindex, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, worldid = 0, interiorid = 0)
{
	if(!(0 <= lootindex < loot_IndexTotal))
	{
		err("Loot index (%d) is invalid.", lootindex);
		return -1;
	}

	new
		ItemType:samplelist[MAX_LOOT_INDEX_ITEMS],
		samplelistsize,
		ItemType:itemtype;

	samplelistsize = _loot_GenerateSampleList(samplelist, lootindex);

	if(samplelistsize == 0)
		return -1;

	// Generate an item from the sample list
	if(!_loot_PickFromSampleList(samplelist, samplelistsize, itemtype))
		return INVALID_ITEM_ID;

	if(itemtype == item_NULL)
	{
		err("Chosen cell contained itemtype 0, index %d size %d: %s", lootindex, samplelistsize, atosr(_:samplelist, samplelistsize));
		return INVALID_ITEM_ID;
	}

	if(loot_ItemTypeLimit[itemtype] > 0 && GetItemTypeCount(itemtype) > loot_ItemTypeLimit[itemtype])
		return INVALID_ITEM_ID;

	new itemid = GetNextItemID();

	if(!(0 <= itemid < ITM_MAX))
		return INVALID_ITEM_ID;

	loot_ItemLootIndex[itemid] = lootindex;

	CreateItem(itemtype, x, y, z, .rz = frandom(360.0), .world = worldid, .interior = interiorid);

	return itemid;
}

stock FillContainerWithLoot(containerid, slots, lootindex)
{
	if(!(0 <= lootindex < loot_IndexTotal))
	{
		err("Loot index (%d) is invalid.", lootindex);
		return -1;
	}

	// log("[FillContainerWithLoot] containerid %d, slots %d, lootindex %d", containerid, slots, lootindex);
	new containersize = GetContainerSize(containerid);

	if(slots > containersize)
		slots = containersize;

	else if(slots <= 0)
		return 0;

	new
		ItemType:samplelist[MAX_LOOT_INDEX_ITEMS],
		samplelistsize,
		items,
		itemid,
		ItemType:itemtype;

	samplelistsize = _loot_GenerateSampleList(samplelist, lootindex);

	if(samplelistsize == 0)
		return 0;

	while(items < slots && samplelistsize > 0 && GetContainerFreeSlots(containerid) > 0)
	{
		// Generate an item from the sample list

		if(!_loot_PickFromSampleList(samplelist, samplelistsize, itemtype))
			continue;

		if(itemtype == item_NULL)
		{
			err("Chosen cell contained itemtype 0, index %d size %d: %s", lootindex, samplelistsize, atosr(_:samplelist, samplelistsize));
			continue;
		}

		// Check if the generated item is legal
		if(loot_ItemTypeLimit[itemtype] > 0 && GetItemTypeCount(itemtype) >= loot_ItemTypeLimit[itemtype])
		{
			continue;
		}

		// Create the item
		itemid = GetNextItemID();

		if(!(0 <= itemid < ITM_MAX))
		{
			err("Item limit reached while generating loot.");
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


_loot_GenerateSampleList(ItemType:list[MAX_LOOT_INDEX_ITEMS], lootindex)
{
	new size;

	for(new i; i < loot_IndexSize[lootindex]; ++i)
	{
		if(frandom(100.0) > loot_IndexItems[lootindex][i][lootitem_weight])
			continue;

		if(loot_IndexItems[lootindex][i][lootitem_type] == item_NULL)
		{
			// log("[_loot_GenerateSampleList] Prevented entering NULL ITEM into samplelist");
			continue;
		}

		list[size++] = loot_IndexItems[lootindex][i][lootitem_type];
	}

	// log("[_loot_GenerateSampleList] Generated: %s", atosr(_:list, size));

	return size;
}

_loot_PickFromSampleList(ItemType:list[MAX_LOOT_INDEX_ITEMS], &listsize, &ItemType:itemtype)
{
	if(listsize <= 0)
		return -1;

	new cell = random(listsize);
	itemtype = list[cell];

	for(new i = cell; i < listsize - 1; i++)
		list[i] = list[i+1];

	listsize -= 1;

	return 1;
}

/*
_loot_LootSpawnItemsOfType(lootspawnid, ItemType:itemtype)
{
	new count;

	for(new i; i < loot_SpawnData[lootspawnid][loot_total]; i++)
	{
		if(GetItemType(loot_SpawnData[lootspawnid][loot_items][i]) == itemtype)
			count++;
	}
	// log("[_loot_LootSpawnItemsOfType] loot spawn %d contains %d of %d", lootspawnid, count, _:itemtype);
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
	// log("[_loot_ContainerItemsOfType] container %d contains %d of %d", containerid, count, _:itemtype);
	return count;
}
*/
hook OnItemDestroy(itemid)
{
	dbg("global", CORE, "[OnItemDestroy] in /gamemodes/sss/core/world/loot.pwn");

	loot_ItemLootIndex[itemid] = -1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsValidLootIndex(index)
{
	return (0 <= index < loot_IndexTotal);
}

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

stock GetLootIndexFromName(name[])
{
	for(new i; i < loot_IndexTotal; i++)
	{
		if(!strcmp(name, loot_IndexName[i], true))
			return i;
	}

	err("specified index name is invalid ('%s')", name);
	PrintAmxBacktrace();

	return -1;
}
