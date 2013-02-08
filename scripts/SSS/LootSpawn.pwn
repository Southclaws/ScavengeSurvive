#define MAX_LOOT_INDEX			(11)
#define MAX_LOOT_INDEX_ITEMS	(128)


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

ItemType:GenerateLoot(index, &exdata)
{
	if(index > loot_IndexUpper)
		return INVALID_ITEM_TYPE;		

	new
		idx,
		list[MAX_LOOT_INDEX_ITEMS],
		ItemType:itemtype,
		lootid;

	for(new i; i < loot_IndexSize[index]; i++)
	{
		if(frandom(1.0) < loot_IndexItems[index][i][loot_spawnChance])
			list[idx++] = i;
	}

	lootid = list[random(idx)];

	itemtype = loot_IndexItems[index][lootid][loot_itemType];
	exdata = loot_IndexItems[index][lootid][loot_exData];

	if(!IsValidItemType(itemtype))
	{
		printf("ERROR: Invalid item type in loot table %d: ID: %d", index, _:itemtype);
		return INVALID_ITEM_TYPE;		
	}

	return itemtype;
}


CreateLootSpawn(Float:x, Float:y, Float:z, size, spawnchance, lootindex)
{
	new ItemType:itemtype;

	for(new i; i < size; i++)
	{
		if(!(random(100) < spawnchance))
			continue;

		new
			ItemType:tmpitem,
			itemid,
			exdata;

		tmpitem = GenerateLoot(lootindex, exdata);

		if(tmpitem == itemtype)
			continue;

		itemtype = tmpitem;

		itemid = CreateItem(tmpitem,
			x + floatsin((360/size) * i, degrees),
			y + floatcos((360/size) * i, degrees),
			z, .zoffset = 0.7);

		if(0 < _:tmpitem <= WEAPON_PARACHUTE)
			SetItemExtraData(itemid, (WepData[_:tmpitem][MagSize] * (random(3))) + random(WepData[_:tmpitem][MagSize]-1) + 1);
		
		if(exdata != -1)
			SetItemExtraData(itemid, exdata);

		if(tmpitem == item_Satchel || tmpitem == item_Backpack)
		{
			tmpitem = GenerateLoot(lootindex, exdata);
			itemid = CreateItem(tmpitem, 0.0, 0.0, 0.0);

			if(0 < _:tmpitem <= WEAPON_PARACHUTE)
			{
				SetItemExtraData(itemid, (WepData[_:tmpitem][MagSize] * (random(3))) + random(WepData[_:tmpitem][MagSize]));
			}
			else if(!IsItemTypeSafebox(tmpitem) && !IsItemTypeBag(tmpitem))
			{
				SetItemExtraData(itemid, exdata);
			}

			AddItemToContainer(GetItemExtraData(itemid), itemid);
		}
	}
}
