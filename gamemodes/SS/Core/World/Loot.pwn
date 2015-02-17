#include <YSI\y_hooks>


#define MAX_LOOT_INDEX			(15)
#define MAX_LOOT_INDEX_ITEMS	(256)
#define MAX_LOOT_INDEX_NAME		(5)
#define MAX_LOOT_SPAWN			(12683)
#define MAX_ITEMS_PER_SPAWN		(6)


enum E_LOOT_INDEX_ITEM_DATA
{
ItemType:	lootitem_type,
Float:		lootitem_weight
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

			loot_IsItemLoot[ITM_MAX],

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
	if(loot_IndexTotal >= MAX_LOOT_INDEX-1)
		print("ERROR: Loot index limit reached.");

	loot_IndexName[loot_IndexTotal] = name;

	return loot_IndexTotal++;
}

stock AddItemToLootIndex(index, ItemType:itemtype, Float:weight)
{
	if(index > loot_IndexTotal)
		return 0;

	if(loot_IndexSize[index] >= MAX_LOOT_INDEX_ITEMS)
		print("ERROR: Loot index item limit reached.");

	loot_IndexItems[index][loot_IndexSize[index]][lootitem_type] = itemtype;
	loot_IndexItems[index][loot_IndexSize[index]][lootitem_weight] = weight;

	loot_IndexSize[index] += 1;

	return 1;
}

stock CreateStaticLootSpawn(Float:x, Float:y, Float:z, lootindex, Float:weight = 100.0, size = -1, worldid = 0, interiorid = 0)
{
	if(loot_SpawnTotal >= MAX_LOOT_SPAWN - 1)
	{
		print("ERROR: Loot spawn limit reached.");
		return -1;
	}

	if(size > MAX_ITEMS_PER_SPAWN)
	{
		printf("ERROR: Loot spawn size (%d) out of bounds (%d).", size, MAX_ITEMS_PER_SPAWN);
		return -1;
	}

	if(size == -1)
		size = MAX_ITEMS_PER_SPAWN / 2 + random(MAX_ITEMS_PER_SPAWN / 2);

	loot_SpawnData[loot_SpawnTotal][loot_posX] = x;
	loot_SpawnData[loot_SpawnTotal][loot_posY] = y;
	loot_SpawnData[loot_SpawnTotal][loot_posZ] = z;
	loot_SpawnData[loot_SpawnTotal][loot_world] = worldid;
	loot_SpawnData[loot_SpawnTotal][loot_interior] = interiorid;
	loot_SpawnData[loot_SpawnTotal][loot_weight] = weight;
	loot_SpawnData[loot_SpawnTotal][loot_size] = size;
	loot_SpawnData[loot_SpawnTotal][loot_index] = lootindex;

	new
		ItemType:samplelist[MAX_LOOT_INDEX_ITEMS],
		samplelistsize,
		Float:rot = frandom(360.0);

	/*
		New sample list is generated each spawn. Therefore, it's more efficient
		to have larger loot spawns and less of them.
	*/

	samplelistsize = _loot_GenerateLootSampleList(lootindex, samplelist);

	for(new i; i < size; i++)
	{
		if(!(random(100) < loot_SpawnMult * weight))
			continue;

		loot_SpawnData[loot_SpawnTotal][loot_items][loot_SpawnData[loot_SpawnTotal][loot_total]] = CreateLootItem(samplelist, samplelistsize,
			x + (frandom(1.0) * floatsin(((360 / size) * i) + rot, degrees)),
			y + (frandom(1.0) * floatcos(((360 / size) * i) + rot, degrees)),
			z, worldid, interiorid, 0.7);

/*		if(IsItemTypeBag(GetItemType(loot_SpawnData[loot_SpawnTotal][loot_items][loot_SpawnData[loot_SpawnTotal][loot_total]])))
		{
			new containerid = GetItemArrayDataAtCell(loot_SpawnData[loot_SpawnTotal][loot_total], 1);
			FillContainerWithLoot(containerid, GetContainerSize(containerid) / 2, lootindex);
		}
*/
		loot_SpawnData[loot_SpawnTotal][loot_total]++;
	}

	return loot_SpawnTotal++;
}

stock CreateLootItem(ItemType:samplelist[MAX_LOOT_INDEX_ITEMS], samplelistsize, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, worldid = 0, interiorid = 0, Float:zoffset = ITEM_BUTTON_OFFSET)
{
	new
		ItemType:itemtype,
		itemid;

	if(_loot_PickFromSampleList(samplelist, samplelistsize, itemtype) == 0)
		return INVALID_ITEM_ID;

	itemid = GetNextItemID();

	if(!(0 <= itemid < ITM_MAX))
		return INVALID_ITEM_ID;

	loot_IsItemLoot[itemid] = 1;

	CreateItem(itemtype, x, y, z, .zoffset = zoffset, .rz = frandom(360.0), .world = worldid, .interior = interiorid);

	return itemid;
}

stock FillContainerWithLoot(containerid, slots, lootindex)
{
	new
		containersize = GetContainerSize(containerid);

	if(slots > containersize)
		return 0;

	new
		ItemType:samplelist[MAX_LOOT_INDEX_ITEMS],
		samplelistsize;

	samplelistsize = _loot_GenerateLootSampleList(lootindex, samplelist);

	for(new i; i < slots; i++)
		AddItemToContainer(containerid, CreateLootItem(samplelist, samplelistsize));

	return 1;
}

stock CreateLootItemFromIndex(lootindex, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, worldid = 0, interiorid = 0, Float:zoffset = ITEM_BUTTON_OFFSET)
{
	new
		ItemType:samplelist[MAX_LOOT_INDEX_ITEMS],
		samplelistsize;

	samplelistsize = _loot_GenerateLootSampleList(lootindex, samplelist);

	return CreateLootItem(samplelist, samplelistsize, x, y, z, worldid, interiorid, zoffset);
}


/*==============================================================================

	Internal

==============================================================================*/


stock _loot_GenerateLootSampleList(index, ItemType:list[MAX_LOOT_INDEX_ITEMS])
{
	new idx;

	for(new i; i < loot_IndexSize[index] && idx < MAX_LOOT_INDEX_ITEMS; i++)
	{
		if(frandom(100.0) < loot_IndexItems[index][i][lootitem_weight])
			list[idx++] = loot_IndexItems[index][i][lootitem_type];
	}

	return idx;
}

stock _loot_PickFromSampleList(ItemType:list[MAX_LOOT_INDEX_ITEMS], listsize, &ItemType:itemtype)
{
//	if(index > loot_IndexTotal)
//	{
//		printf("[_loot_PickFromSampleList] ERROR: index (%d) exceeds loot index upper bound of %d.", index, loot_IndexTotal);
//		return 0;		
//	}
//
//	if(loot_IndexSize[index] == 0)
//	{
//		printf("[_loot_PickFromSampleList] ERROR: Specified index (%d) is empty.", index);
//		return 0;
//	}

	new cell = random(listsize);

	if(cell > MAX_LOOT_INDEX_ITEMS)
		return 0;

	itemtype = list[cell];

//	if(!IsValidItemType(itemtype))
//	{
//		printf("ERROR: Invalid item type in loot table %d: ID: %d", index, _:itemtype);
//		return 0;		
//	}

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsItemLoot(itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	return loot_IsItemLoot[itemid];
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

