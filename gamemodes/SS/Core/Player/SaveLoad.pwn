//#define SAVELOAD_DEBUG


enum
{
	PLY_CELL_HEALTH,
	PLY_CELL_ARMOUR,
	PLY_CELL_FOOD,
	PLY_CELL_SKIN,
	PLY_CELL_HAT,
	PLY_CELL_HOLST,
	PLY_CELL_HOLSTEX,
	PLY_CELL_HELD,
	PLY_CELL_HELDEX,
	PLY_CELL_STANCE,
	PLY_CELL_BLEEDING,
	PLY_CELL_CUFFED,
	PLY_CELL_WARNS,
	PLY_CELL_FREQ,
	PLY_CELL_CHATMODE,
	PLY_CELL_INFECTED,
	PLY_CELL_TOOLTIPS,
	PLY_CELL_SPAWN_X,
	PLY_CELL_SPAWN_Y,
	PLY_CELL_SPAWN_Z,
	PLY_CELL_SPAWN_R,
	PLY_CELL_MASK,
	PLY_CELL_END
}

enum
{
	INV_CELL_ITEMS[4 * 2],
	INV_CELL_BAGTYPE,
	INV_CELL_BAGITEMS[9 * 2],
	INV_CELL_END
}

SavePlayerChar(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		data[PLY_CELL_END],
		animidx = GetPlayerAnimationIndex(playerid);

	GetFile(gPlayerName[playerid], filename);

	data[PLY_CELL_HEALTH]	= _:gPlayerData[playerid][ply_HitPoints];
	data[PLY_CELL_ARMOUR]	= _:gPlayerData[playerid][ply_ArmourPoints];
	data[PLY_CELL_FOOD]		= _:gPlayerData[playerid][ply_FoodPoints];
	data[PLY_CELL_SKIN]		= GetPlayerClothes(playerid);
	data[PLY_CELL_HAT]		= GetPlayerHat(playerid);

	if(IsValidItem(GetPlayerHolsterItem(playerid)))
	{
		data[PLY_CELL_HOLST] = _:GetItemType(GetPlayerHolsterItem(playerid));
		data[PLY_CELL_HOLSTEX] = GetItemExtraData(GetPlayerHolsterItem(playerid));
	}
	else
	{
		data[PLY_CELL_HOLST] = _:INVALID_ITEM_TYPE;
		data[PLY_CELL_HOLSTEX] = 0;
	}

	if(IsValidItem(GetPlayerItem(playerid)))
	{
		data[PLY_CELL_HELD] = _:GetItemType(GetPlayerItem(playerid));
		data[PLY_CELL_HELDEX] = GetItemExtraData(GetPlayerItem(playerid));
	}
	else if(GetPlayerCurrentWeapon(playerid) > 0)
	{
		data[PLY_CELL_HELD] = GetPlayerCurrentWeapon(playerid);
		data[PLY_CELL_HELDEX] = GetPlayerTotalAmmo(playerid);
	}
	else
	{
		data[PLY_CELL_HELD] = _:INVALID_ITEM_TYPE;
		data[PLY_CELL_HELDEX] = 0;
	}

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DUCK)
	{
		data[PLY_CELL_STANCE] = 1;
	}
	else if(animidx == 43)
	{
		data[PLY_CELL_STANCE] = 2;
	}
	else if(animidx == 1381)
	{
		data[PLY_CELL_STANCE] = 3;
	}

	data[PLY_CELL_BLEEDING] = IsPlayerBleeding(playerid);

	data[PLY_CELL_CUFFED] = (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED);

	data[PLY_CELL_WARNS] = gPlayerData[playerid][ply_Warnings];

	data[PLY_CELL_FREQ] = _:gPlayerData[playerid][ply_RadioFrequency];

	data[PLY_CELL_CHATMODE] = gPlayerData[playerid][ply_ChatMode];

	data[PLY_CELL_INFECTED] = _:(gPlayerBitData[playerid] & Infected);

	data[PLY_CELL_TOOLTIPS] = _:(gPlayerBitData[playerid] & ToolTips);

	data[PLY_CELL_SPAWN_X] = _:gPlayerData[playerid][ply_SpawnPosX];
	data[PLY_CELL_SPAWN_Y] = _:gPlayerData[playerid][ply_SpawnPosY];
	data[PLY_CELL_SPAWN_Z] = _:gPlayerData[playerid][ply_SpawnPosZ];
	data[PLY_CELL_SPAWN_R] = _:gPlayerData[playerid][ply_SpawnRotZ];

	data[PLY_CELL_MASK] = GetPlayerMask(playerid);

	file = fopen(filename, io_write);
	fblockwrite(file, data, sizeof(data));
	fclose(file);
}
SavePlayerInventory(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		data[INV_CELL_END];

	GetInvFile(gPlayerName[playerid], filename);

	for(new i = INV_CELL_ITEMS, j; j < 4; i += 2, j++)
	{
		data[i] = _:GetItemType(GetInventorySlotItem(playerid, j));
		data[i + 1] = GetItemExtraData(GetInventorySlotItem(playerid, j));
	}

	if(IsValidItem(GetPlayerBagItem(playerid)))
	{
		new containerid = GetItemExtraData(GetPlayerBagItem(playerid));

		data[INV_CELL_BAGTYPE] = _:GetItemType(GetPlayerBagItem(playerid));

		for(new i = INV_CELL_BAGITEMS, j; j < GetContainerSize(containerid); i += 2, j++)
		{
			data[i] = _:GetItemType(GetContainerSlotItem(containerid, j));
			data[i + 1] = GetItemExtraData(GetContainerSlotItem(containerid, j));
		}
	}

	file = fopen(filename, io_write);
	fblockwrite(file, data, sizeof(data));
	fclose(file);

	#if defined SAVELOAD_DEBUG
	printf("\t[SAVE] %s - %d, %d, %d, %d", gPlayerName[playerid], data[0], data[2], data[4], data[6]);
	#endif
}

LoadPlayerChar(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		data[PLY_CELL_END],
		itemid;

	GetFile(gPlayerName[playerid], filename);

	file = fopen(filename, io_read);

	if(!file)
		return 0;

	fblockread(file, data, sizeof(data));
	fclose(file);

	if(Float:data[0] <= 0.0)
		data[0] = _:1.0;

	gPlayerData[playerid][ply_HitPoints]	= Float:data[PLY_CELL_HEALTH];
	gPlayerData[playerid][ply_ArmourPoints]	= Float:data[PLY_CELL_ARMOUR];
	gPlayerData[playerid][ply_FoodPoints]	= Float:data[PLY_CELL_FOOD];
	gPlayerData[playerid][ply_Clothes]		= data[PLY_CELL_SKIN];
	SetPlayerClothes(playerid, data[PLY_CELL_SKIN]);
	SetPlayerHat(playerid, data[PLY_CELL_HAT]);

	if(gPlayerData[playerid][ply_ArmourPoints] > 0.0)
		ToggleArmour(playerid, true);

	if(data[PLY_CELL_HOLST] != -1)
	{
		itemid = CreateItem(ItemType:data[PLY_CELL_HOLST]);
		SetItemExtraData(itemid, data[PLY_CELL_HOLSTEX]);
		SetPlayerHolsterItem(playerid, itemid);
	}

	if(data[PLY_CELL_HELD] != -1)
	{
		if(0 < data[PLY_CELL_HELD] < WEAPON_PARACHUTE)
		{
			SetPlayerWeapon(playerid, data[PLY_CELL_HELD], data[PLY_CELL_HELDEX]);
		}
		else
		{
			itemid = CreateItem(ItemType:data[PLY_CELL_HELD]);

			if(!IsItemTypeSafebox(ItemType:data[PLY_CELL_HELD]) && !IsItemTypeBag(ItemType:data[PLY_CELL_HELD]))
				SetItemExtraData(itemid, data[PLY_CELL_HELDEX]);

			GiveWorldItemToPlayer(playerid, itemid, false);
		}
	}

	gPlayerData[playerid][ply_stance] = data[PLY_CELL_STANCE];

	if(data[PLY_CELL_BLEEDING])
		t:gPlayerBitData[playerid]<Bleeding>;

	else
		f:gPlayerBitData[playerid]<Bleeding>;

	if(data[PLY_CELL_CUFFED])
		SetPlayerCuffs(playerid, true);

	else
		SetPlayerCuffs(playerid, false);

	gPlayerData[playerid][ply_Warnings] = data[PLY_CELL_WARNS];

	gPlayerData[playerid][ply_RadioFrequency] = Float:data[PLY_CELL_FREQ];

	gPlayerData[playerid][ply_ChatMode] = data[PLY_CELL_CHATMODE];

	if(data[PLY_CELL_INFECTED])
		t:gPlayerBitData[playerid]<Infected>;

	else
		f:gPlayerBitData[playerid]<Infected>;

	if(data[PLY_CELL_TOOLTIPS])
		t:gPlayerBitData[playerid]<ToolTips>;

	else
		f:gPlayerBitData[playerid]<ToolTips>;

	gPlayerData[playerid][ply_SpawnPosX] = Float:data[PLY_CELL_SPAWN_X];
	gPlayerData[playerid][ply_SpawnPosY] = Float:data[PLY_CELL_SPAWN_Y];
	gPlayerData[playerid][ply_SpawnPosZ] = Float:data[PLY_CELL_SPAWN_Z];
	gPlayerData[playerid][ply_SpawnRotZ] = Float:data[PLY_CELL_SPAWN_R];

	SetPlayerMask(playerid, data[PLY_CELL_MASK]);

	return 1;
}

LoadPlayerInventory(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		data[INV_CELL_END],
		itemid,
		containerid;

	GetInvFile(gPlayerName[playerid], filename);

	file = fopen(filename, io_read);

	if(!file)
		return 0;

	fblockread(file, data, sizeof(data));
	fclose(file);

	for(new i; i < INV_MAX_SLOTS * 2; i += 2)
	{
		if(!IsValidItemType(ItemType:data[i]) || data[i] == 0)
			break;

		itemid = CreateItem(ItemType:data[i], 0.0, 0.0, 0.0);

		if(!IsItemTypeSafebox(ItemType:data[i]) && !IsItemTypeBag(ItemType:data[i]))
			SetItemExtraData(itemid, data[i + 1]);
	
		AddItemToInventory(playerid, itemid, 0);
	}

	if(!IsItemTypeBag(ItemType:data[INV_CELL_BAGTYPE]))
		return 1;

	itemid = CreateItem(ItemType:data[INV_CELL_BAGTYPE], 0.0, 0.0, 0.0);
	containerid = GetItemExtraData(itemid);
	GivePlayerBag(playerid, itemid);

	for(new i = INV_CELL_BAGITEMS; i < INV_CELL_BAGITEMS + (GetContainerSize(containerid) * 2); i += 2)
	{
		if(data[i] == _:INVALID_ITEM_TYPE)
			continue;

		if(data[i] == 0)
			continue;

		itemid = CreateItem(ItemType:data[i], 0.0, 0.0, 0.0);

		if(!IsItemTypeSafebox(ItemType:data[i]) && !IsItemTypeBag(ItemType:data[i]))
			SetItemExtraData(itemid, data[i + 1]);

		AddItemToContainer(containerid, itemid);
	}

	#if defined SAVELOAD_DEBUG
	printf("\t[LOAD] %s - %d, %d, %d, %d", gPlayerName[playerid], data[0], data[2], data[4], data[6]);
	#endif

	return 1;
}


ClearPlayerInventoryFile(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		data[PLY_CELL_END];

	GetFile(gPlayerName[playerid], filename);

	file = fopen(filename, io_write);
	fblockwrite(file, data, 1);
	fclose(file);

	GetInvFile(gPlayerName[playerid], filename);

	file = fopen(filename, io_write);
	fblockwrite(file, data, 1);
	fclose(file);
}
