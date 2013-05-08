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
	PLY_CELL_END
}

enum
{
	INV_CELL_ITEMS[8],
	INV_CELL_BAGTYPE,
	INV_CELL_BAGITEMS[16],
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

	data[PLY_CELL_HEALTH]	= _:gPlayerHP[playerid];
	data[PLY_CELL_ARMOUR]	= _:gPlayerAP[playerid];
	data[PLY_CELL_FOOD]		= _:gPlayerFP[playerid];
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

	data[PLY_CELL_BLEEDING] = (bPlayerGameSettings[playerid] & Bleeding);

	data[PLY_CELL_CUFFED] = (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED);

	data[PLY_CELL_WARNS] = gPlayerWarnings[playerid];

	data[PLY_CELL_FREQ] = _:gPlayerFrequency[playerid];

	data[PLY_CELL_CHATMODE] = Bit2_Get(gPlayerChatMode, playerid);

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

	if(IsValidItem(GetPlayerBackpackItem(playerid)))
	{
		new containerid = GetItemExtraData(GetPlayerBackpackItem(playerid));

		data[INV_CELL_BAGTYPE] = _:GetItemType(GetPlayerBackpackItem(playerid));

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
	printf("[SAVE] %s - %d, %d, %d, %d", gPlayerName[playerid], data[0], data[2], data[4], data[6]);
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
	fblockread(file, data, sizeof(data));
	fclose(file);

	if(Float:data[0] <= 0.0)
		data[0] = _:1.0;

	gPlayerHP[playerid] = Float:data[PLY_CELL_HEALTH];
	gPlayerAP[playerid] = Float:data[PLY_CELL_ARMOUR];
	gPlayerFP[playerid] = Float:data[PLY_CELL_FOOD];
	gPlayerData[playerid][ply_Skin] = data[PLY_CELL_SKIN];
	SetPlayerClothes(playerid, data[PLY_CELL_SKIN]);
	SetPlayerHat(playerid, data[PLY_CELL_HAT]);

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
	{
		t:bPlayerGameSettings[playerid]<Bleeding>;
	}

	if(data[PLY_CELL_CUFFED])
	{
		SetPlayerCuffs(playerid, true);
	}

	gPlayerWarnings[playerid] = data[PLY_CELL_WARNS];

	gPlayerFrequency[playerid] = Float:data[PLY_CELL_FREQ];

	Bit2_Set(gPlayerChatMode, playerid, data[PLY_CELL_CHATMODE]);
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
	fblockread(file, data, sizeof(data));
	fclose(file);

	for(new i; i < INV_MAX_SLOTS * 2; i += 2)
	{
		if(!IsValidItemType(ItemType:data[i]) || data[i] == 0)
			break;

		itemid = CreateItem(ItemType:data[i], 0.0, 0.0, 0.0);

		if(!IsItemTypeSafebox(ItemType:data[i]) && !IsItemTypeBag(ItemType:data[i]))
			SetItemExtraData(itemid, data[i + 1]);
	
		AddItemToInventory(playerid, itemid);
	}

	if(!IsItemTypeBag(ItemType:data[INV_CELL_BAGTYPE]))
		return 0;

	itemid = CreateItem(ItemType:data[INV_CELL_BAGTYPE], 0.0, 0.0, 0.0);
	containerid = GetItemExtraData(itemid);
	GivePlayerBackpack(playerid, itemid);

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
	printf("[LOAD] %s - %d, %d, %d, %d", gPlayerName[playerid], data[0], data[2], data[4], data[6]);
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
}


enum
{
	OLD_HEALTH,								// 0
	OLD_ARMOUR,								// 1
	OLD_FOOD,								// 2
	OLD_SKIN,								// 3
	OLD_HAT,								// 4
	OLD_HOLST,								// 5
	OLD_HOLSTEX,							// 6
	OLD_HELD,								// 7
	OLD_HELDEX,								// 8
	OLD_INVENTORY,							// 9
	OLD_BAGTYPE = OLD_INVENTORY + 8,		// 17
	OLD_BAG,								// 18
	OLD_END = OLD_BAG + 16					// 34
}

#endinput
/*
#include <YSI\y_hooks>
hook OnGameModeInit()
{
	defer UpdateAccounts();
}
timer UpdateAccounts[1000]()
{
	new
		name[24],
		DBResult:result,
		numrows;

	result = db_query(gAccounts, "SELECT * FROM `Player`");
	numrows = db_num_rows(result);


	for(new i; i < numrows; i++)
	{
		db_get_field(result, 0, name, 24);
		db_next_row(result);

		ConvertUserFile(name);
	}

	db_free_result(result);
}

ConvertUserFile(name[])
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		data[OLD_END],
		data1[PLY_CELL_END],
		data2[INV_CELL_END];

	format(filename, MAX_PLAYER_FILE, "SSS/Player/%s.inv", name);

	if(!fexist(filename))
		return 0;

	file = fopen(filename, io_read);
	fblockread(file, data, sizeof(data));
	fclose(file);
	fremove(filename);

	data1[PLY_CELL_HEALTH]	= data[OLD_HEALTH];
	data1[PLY_CELL_ARMOUR]	= data[OLD_ARMOUR];
	data1[PLY_CELL_FOOD]	= data[OLD_FOOD];
	data1[PLY_CELL_SKIN]	= data[OLD_SKIN];
	data1[PLY_CELL_HAT]		= data[OLD_HAT];
	data1[PLY_CELL_HOLST]	= data[OLD_HOLST];
	data1[PLY_CELL_HOLSTEX]	= data[OLD_HOLSTEX];
	data1[PLY_CELL_HELD]	= data[OLD_HELD];
	data1[PLY_CELL_HELDEX]	= data[OLD_HELDEX];

	format(filename, MAX_PLAYER_FILE, PLAYER_DATA_FILE, name);
	file = fopen(filename, io_write);
	fblockwrite(file, data1, sizeof(data1));
	fclose(file);

	for(new i; i < 8; i += 2)
	{
		data2[i] = data[i + OLD_INVENTORY];
		data2[i + 1] = data[i + OLD_INVENTORY + 1];
	}

	data2[INV_CELL_BAGTYPE] = data[OLD_BAGTYPE];

	for(new i; i < 16; i += 2)
	{
		data2[INV_CELL_BAGITEMS + i] = data[i + OLD_BAG];
		data2[INV_CELL_BAGITEMS + i + 1] = data[i + OLD_BAG + 1];
	}

	format(filename, MAX_PLAYER_FILE, PLAYER_ITEM_FILE, name);
	file = fopen(filename, io_write);
	fblockwrite(file, data2, sizeof(data2));
	fclose(file);

	return 1;
}
*/
