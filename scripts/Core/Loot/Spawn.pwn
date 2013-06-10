#define MAX_LOOT_INDEX			(11)
#define MAX_LOOT_INDEX_ITEMS	(256)


enum E_LOOT_INDEX_ITEM_DATA
{
ItemType:	loot_itemType,
			loot_exData,
Float:		loot_spawnChance
}

new
			loot_IndexUpper,
			loot_IndexSize[MAX_LOOT_INDEX],
			loot_IndexItems[MAX_LOOT_INDEX][MAX_LOOT_INDEX_ITEMS][E_LOOT_INDEX_ITEM_DATA];


DefineLootIndex(indexvalue)
{
	if(loot_IndexUpper >= MAX_LOOT_INDEX-1)
		print("ERROR: Loot index limit reached.");

	if(indexvalue != loot_IndexUpper)
		print("ERROR: Loot indexes must increment by 1.");

	loot_IndexUpper++;
}

AddItemToLootIndex(index, ItemType:itemtype, Float:spawnchance, exdata = -1)
{
	if(index > loot_IndexUpper)
		return 0;

	if(loot_IndexSize[index] >= MAX_LOOT_INDEX_ITEMS)
		print("ERROR: Loot index item limit reached.");

	loot_IndexItems[index][loot_IndexSize[index]][loot_itemType] = itemtype;
	loot_IndexItems[index][loot_IndexSize[index]][loot_exData] = exdata;
	loot_IndexItems[index][loot_IndexSize[index]][loot_spawnChance] = spawnchance;

	loot_IndexSize[index] += 1;

	return 1;
}

GenerateLoot(index, &ItemType:itemtype, &exdata)
{
	if(index > loot_IndexUpper)
	{
		print("ERROR: GenerateLoot: parameter 'index' exceeds loot index upper bound.");
		return 0;		
	}

	if(loot_IndexSize[index] == 0)
	{
		print("ERROR: Specified index is empty.");
		return 0;
	}

	new
		idx,
		list[MAX_LOOT_INDEX_ITEMS],
		cell,
		lootid;

	generate_retry:

	for(new i; i < loot_IndexSize[index] && idx < MAX_LOOT_INDEX_ITEMS; i++)
	{
		if(frandom(1.0) < loot_IndexItems[index][i][loot_spawnChance])
			list[idx++] = i;
	}

	cell = random(idx);

	if(cell > MAX_LOOT_INDEX_ITEMS)
		goto generate_retry;

	lootid = list[cell];

	itemtype = loot_IndexItems[index][lootid][loot_itemType];
	exdata = loot_IndexItems[index][lootid][loot_exData];

	if(!IsValidItemType(itemtype))
	{
		printf("ERROR: Invalid item type in loot table %d: ID: %d", index, _:itemtype);
		return 0;		
	}

	return 1;
}

CreateLootItem(lootindex, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, Float:zoffset = 0.7, ItemType:exception = INVALID_ITEM_TYPE)
{
	new
		ItemType:itemtype,
		itemid,
		exdata;

	if(GenerateLoot(lootindex, itemtype, exdata) == 0)
		return INVALID_ITEM_ID;

	if(itemtype == exception)
		return INVALID_ITEM_ID;

	itemid = CreateItem(itemtype, x, y, z, .zoffset = zoffset, .rz = frandom(360.0));

	if(1 <= _:itemtype <= 46)
	{
		if(22 <= _:itemtype <= 38)
			SetItemExtraData(itemid, random(GetWeaponMagSize(_:itemtype)));

		else
			SetItemExtraData(itemid, 1);
	}
	
	if(exdata != -1)
		SetItemExtraData(itemid, exdata);

	if(itemtype == item_Satchel || itemtype == item_Backpack)
	{
		FillContainerWithLoot(GetItemExtraData(itemid), random(3), lootindex);
	}

	return itemid;
}

CreateLootSpawn(Float:x, Float:y, Float:z, size, spawnchance, lootindex)
{
	new
		ItemType:itemtype,
		itemid,
		Float:rot = frandom(360.0);

	for(new i; i < size; i++)
	{
		if(!(random(100) < spawnchance))
			continue;

		itemid = CreateLootItem(lootindex,
			x + (frandom(1.0) * floatsin(((360 / size) * i) + rot, degrees)),
			y + (frandom(1.0) * floatcos(((360 / size) * i) + rot, degrees)),
			z, 0.7, itemtype);

		itemtype = GetItemType(itemid);
	}
}

FillContainerWithLoot(containerid, slots, lootindex)
{
	new
		containersize = GetContainerSize(containerid);

	if(slots > containersize)
		return 0;

	for(new i; i < slots; i++)
	{
		AddItemToContainer(containerid, CreateLootItem(lootindex));
	}

	return 1;
}
