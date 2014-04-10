#define CHARACTER_DATA_FILE_VERSION 10
#define SAVELOAD_DEBUG 1


static
	saveload_Debug[MAX_PLAYERS] = {SAVELOAD_DEBUG, ...},
	saveload_ItemList[ITM_LST_OF_ITEMS(9)];


enum
{
	PLY_CELL_FILE_VERSION,
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
	PLY_CELL_MUTE_TIME,
	PLY_CELL_KNOCKOUT,
	PLY_CELL_BAGTYPE,
	PLY_CELL_END
}


forward OnPlayerSave(playerid, filename[]);
forward OnPlayerLoad(playerid, filename[]);


SavePlayerChar(playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	new
		filename[MAX_PLAYER_FILE],
		session,
		data[PLY_CELL_END],
		animidx = GetPlayerAnimationIndex(playerid),
		items[9],
		itemcount,
		itemlist;

	PLAYER_DAT_FILE(gPlayerName[playerid], filename);

	session = modio_getsession_write(filename);

	if(session != -1)
		modio_close_session_write(session);

/*
	Character
*/

	data[PLY_CELL_HEALTH]	= _:GetPlayerHP(playerid);
	data[PLY_CELL_ARMOUR]	= _:GetPlayerAP(playerid);
	data[PLY_CELL_FOOD]		= _:GetPlayerFP(playerid);
	data[PLY_CELL_SKIN]		= GetPlayerClothes(playerid);
	data[PLY_CELL_HAT]		= GetPlayerHat(playerid);

	if(saveload_Debug[playerid] == 1)
		printf("\t[SAVE:%p] CHR %.1f, %.1f, %.1f, %d, %d", playerid, data[PLY_CELL_HEALTH], data[PLY_CELL_ARMOUR], data[PLY_CELL_FOOD], data[PLY_CELL_SKIN], data[PLY_CELL_HAT]);

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

	if(saveload_Debug[playerid] == 2)
		printf("\t[SAVE:%p] HOLST %d (%d) (itemid: %d)", playerid, data[PLY_CELL_HOLST], data[PLY_CELL_HOLSTEX], GetPlayerHolsterItem(playerid));

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

	if(saveload_Debug[playerid] == 2)
		printf("\t[SAVE:%p] HELD %d (%d) (itemid: %d)", playerid, data[PLY_CELL_HELD], data[PLY_CELL_HELDEX], GetPlayerCurrentWeapon(playerid));

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
	data[PLY_CELL_WARNS] = GetPlayerWarnings(playerid);
	data[PLY_CELL_FREQ] = _:GetPlayerRadioFrequency(playerid);
	data[PLY_CELL_CHATMODE] = GetPlayerChatMode(playerid);
	data[PLY_CELL_INFECTED] = _:GetPlayerBitFlag(playerid, Infected);
	data[PLY_CELL_TOOLTIPS] = _:GetPlayerBitFlag(playerid, ToolTips);

	GetPlayerPos(playerid, Float:data[PLY_CELL_SPAWN_X], Float:data[PLY_CELL_SPAWN_Y], Float:data[PLY_CELL_SPAWN_Z]);
	GetPlayerFacingAngle(playerid, Float:data[PLY_CELL_SPAWN_R]);

	data[PLY_CELL_MASK] = GetPlayerMask(playerid);
	data[PLY_CELL_MUTE_TIME] = GetPlayerMuteRemainder(playerid);
	data[PLY_CELL_KNOCKOUT] = GetPlayerKnockOutRemainder(playerid);

	if(IsValidItem(GetPlayerBagItem(playerid)))
		data[PLY_CELL_BAGTYPE] = _:GetItemType(GetPlayerBagItem(playerid));

	if(saveload_Debug[playerid] == 3)
		printf("\t[SAVE:%p] BAG %d (itemid: %d)", playerid, data[PLY_CELL_BAGTYPE], GetPlayerBagItem(playerid));

	modio_push(filename, !"CHAR", PLY_CELL_END, data);

/*
	Inventory
*/

	for(new i; i < 4; i++)
	{
		items[i] = GetInventorySlotItem(playerid, i);

		if(!IsValidItem(items[i]))
			break;

		itemcount++;

		if(saveload_Debug[playerid] == 4)
			printf("\t[SAVE:%p] INV %d (itemid: %d)", playerid, _:GetItemType(items[i]), items[i]);
	}

	itemlist = CreateItemList(items, itemcount);
	GetItemList(itemlist, saveload_ItemList);

	modio_push(filename, !"INV0", GetItemListSize(itemlist), saveload_ItemList);

	DestroyItemList(itemlist);

/*
	Bag
*/

	if(IsValidItem(GetPlayerBagItem(playerid)))
	{
		new containerid = GetItemExtraData(GetPlayerBagItem(playerid));

		for(new i, j = GetContainerSize(containerid); i < j; i++)
		{
			items[i] = GetContainerSlotItem(containerid, i);

			if(!IsValidItem(items[i]))
				break;

			itemcount++;

			if(saveload_Debug[playerid] == 4)
				printf("\t[SAVE:%p] BAG %d (itemid: %d)", playerid, _:GetItemType(items[i]), items[i]);
		}

		itemlist = CreateItemList(items, itemcount);
		GetItemList(itemlist, saveload_ItemList);

		modio_push(filename, !"BAG0", GetItemListSize(itemlist), saveload_ItemList);

		DestroyItemList(itemlist);
	}

	CallLocalFunction("OnPlayerSave", "ds", playerid, filename);

	return 1;
}

LoadPlayerChar(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		data[PLY_CELL_END],
		ret,
		ItemType:itemtype,
		itemid,
		itemlist,
		length;

	PLAYER_DAT_FILE(gPlayerName[playerid], filename);

	ret = modio_read(filename, !"CHAR", data);

	if(ret == 0)
	{
		ret = FV10_LoadPlayerChar(playerid);
		ret += FV10_LoadPlayerInventory(playerid);
		return ret;
	}

	if(saveload_Debug[playerid] == 1)
		printf("\t[LOAD:%p] CHR %.1f, %.1f, %.1f, %d, %d", playerid, data[PLY_CELL_HEALTH], data[PLY_CELL_ARMOUR], data[PLY_CELL_FOOD], data[PLY_CELL_SKIN], data[PLY_CELL_HAT]);

/*
	Character
*/

	if(Float:data[PLY_CELL_HEALTH] <= 0.0)
		data[PLY_CELL_HEALTH] = _:1.0;

	SetPlayerHP(playerid, Float:data[PLY_CELL_HEALTH]);
	SetPlayerAP(playerid, Float:data[PLY_CELL_ARMOUR]);
	SetPlayerFP(playerid, Float:data[PLY_CELL_FOOD]);
	SetPlayerClothesID(playerid, data[PLY_CELL_SKIN]);
	SetPlayerClothes(playerid, data[PLY_CELL_SKIN]);
	SetPlayerHat(playerid, data[PLY_CELL_HAT]);

	if(GetPlayerAP(playerid) > 0.0)
		ToggleArmour(playerid, true);

	if(data[PLY_CELL_HOLST] != -1)
	{
		itemid = CreateItem(ItemType:data[PLY_CELL_HOLST]);
		SetItemExtraData(itemid, data[PLY_CELL_HOLSTEX]);
		SetPlayerHolsterItem(playerid, itemid);

		if(saveload_Debug[playerid] == 2)
			printf("\t[LOAD:%p] HOLST %d (%d) (itemid: %d)", playerid, data[PLY_CELL_HOLST], data[PLY_CELL_HOLSTEX], itemid);
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

		if(saveload_Debug[playerid] == 2)
			printf("\t[LOAD:%p] HELD %d (%d) (itemid: %d)", playerid, data[PLY_CELL_HELD], data[PLY_CELL_HELDEX], itemid);
	}

	SetPlayerStance(playerid, data[PLY_CELL_STANCE]);
	SetPlayerBitFlag(playerid, Bleeding, data[PLY_CELL_BLEEDING]);
	SetPlayerCuffs(playerid, data[PLY_CELL_CUFFED]);
	SetPlayerWarnings(playerid, data[PLY_CELL_WARNS]);
	SetPlayerRadioFrequency(playerid, Float:data[PLY_CELL_FREQ]);
	SetPlayerChatMode(playerid, data[PLY_CELL_CHATMODE]);
	SetPlayerBitFlag(playerid, Infected, data[PLY_CELL_INFECTED]);
	SetPlayerBitFlag(playerid, ToolTips, data[PLY_CELL_TOOLTIPS]);

	if(!IsPointInMapBounds(Float:data[PLY_CELL_SPAWN_X], Float:data[PLY_CELL_SPAWN_Y], Float:data[PLY_CELL_SPAWN_Z]))
		data[PLY_CELL_SPAWN_Z] += _:1.0;

	SetPlayerSpawnPos(playerid, Float:data[PLY_CELL_SPAWN_X], Float:data[PLY_CELL_SPAWN_Y], Float:data[PLY_CELL_SPAWN_Z]);
	SetPlayerSpawnRot(playerid, Float:data[PLY_CELL_SPAWN_R]);

	SetPlayerMask(playerid, data[PLY_CELL_MASK]);

	if(data[PLY_CELL_MUTE_TIME] > 0)
		TogglePlayerMute(playerid, true, data[PLY_CELL_MUTE_TIME]);

	if(data[PLY_CELL_KNOCKOUT] > 0)
		KnockOutPlayer(playerid, data[PLY_CELL_KNOCKOUT]);

	if(IsItemTypeBag(ItemType:data[PLY_CELL_BAGTYPE]))
	{
		itemid = CreateItem(ItemType:data[PLY_CELL_BAGTYPE], 0.0, 0.0, 0.0);
		GivePlayerBag(playerid, itemid);

		if(saveload_Debug[playerid] == 3)
			printf("\t[LOAD:%p] BAG %d (itemid: %d)", playerid, data[PLY_CELL_BAGTYPE], itemid);
	}

/*
	Inventory
*/

	length = modio_read(filename, !"INV0", saveload_ItemList);

	itemlist = ExtractItemList(saveload_ItemList, length);

	for(new i, j = GetItemListItemCount(itemlist); i < j; i++)
	{
		itemtype = GetItemListItem(itemlist, i);

		if(length == 0)
			break;

		if(itemtype == INVALID_ITEM_TYPE)
			break;

		if(itemtype == ItemType:0)
			break;

		itemid = CreateItem(itemtype);

		if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
			SetItemArrayDataFromListItem(itemid, itemlist, i);
	
		AddItemToInventory(playerid, itemid, 0);

		if(saveload_Debug[playerid] == 4)
			printf("\t[LOAD:%p] INV %d (itemid: %d)", playerid, _:itemtype, itemid);
	}

	DestroyItemList(itemlist);

/*
	Bag
*/

	length = modio_read(filename, !"BAG0", saveload_ItemList);

	itemlist = ExtractItemList(saveload_ItemList, length);

	if(IsItemTypeBag(ItemType:data[PLY_CELL_BAGTYPE]))
	{
		new containerid = GetItemExtraData(GetPlayerBagItem(playerid));

		for(new i, j = GetItemListItemCount(itemlist); i < j; i++)
		{
			itemtype = GetItemListItem(itemlist, i);
			itemid = CreateItem(itemtype);

			if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
				SetItemArrayDataFromListItem(itemid, itemlist, i);

			AddItemToContainer(containerid, itemid);

			if(saveload_Debug[playerid] == 4)
				printf("\t[LOAD:%p] BAG %d", playerid, _:itemtype);
		}
	}

	DestroyItemList(itemlist);

	CallLocalFunction("OnPlayerLoad", "ds", playerid, filename);

	return 1;
}


/*==============================================================================

	Legacy format (Load only)

==============================================================================*/


enum
{
	INV_CELL_ITEMS[4 * 3],
	INV_CELL_BAGITEMS[9 * 3],
	INV_CELL_END
}


FV10_LoadPlayerChar(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		data[PLY_CELL_END],
		itemid;

	PLAYER_DAT_FILE(gPlayerName[playerid], filename);

	file = fopen(filename, io_read);

	if(!file)
	{
		printf("ERROR: [LoadPlayerChar] Opening file '%s'.", filename);
		return 0;
	}

	fblockread(file, data, sizeof(data));
	fclose(file);

	if(data[PLY_CELL_FILE_VERSION] != CHARACTER_DATA_FILE_VERSION)
	{
		printf("ERROR: [LoadPlayerChar] Opening file '%s'. Incompatible file version %d (Current: %d)", filename, data[PLY_CELL_FILE_VERSION], CHARACTER_DATA_FILE_VERSION);
		return 0;
	}

	if(saveload_Debug[playerid] == 1)
		printf("\t[LOAD:%p] CHR %.1f, %.1f, %.1f, %d, %d", playerid, data[PLY_CELL_HEALTH], data[PLY_CELL_ARMOUR], data[PLY_CELL_FOOD], data[PLY_CELL_SKIN], data[PLY_CELL_HAT]);

	if(Float:data[PLY_CELL_HEALTH] <= 0.0)
		data[PLY_CELL_HEALTH] = _:1.0;

	SetPlayerHP(playerid, Float:data[PLY_CELL_HEALTH]);
	SetPlayerAP(playerid, Float:data[PLY_CELL_ARMOUR]);
	SetPlayerFP(playerid, Float:data[PLY_CELL_FOOD]);
	SetPlayerClothesID(playerid, data[PLY_CELL_SKIN]);
	SetPlayerClothes(playerid, data[PLY_CELL_SKIN]);
	SetPlayerHat(playerid, data[PLY_CELL_HAT]);

	if(GetPlayerAP(playerid) > 0.0)
		ToggleArmour(playerid, true);

	if(data[PLY_CELL_HOLST] != -1)
	{
		itemid = CreateItem(ItemType:data[PLY_CELL_HOLST]);
		SetItemExtraData(itemid, data[PLY_CELL_HOLSTEX]);
		SetPlayerHolsterItem(playerid, itemid);

		if(saveload_Debug[playerid] == 2)
			printf("\t[LOAD:%p] HOLST %d (%d) (itemid: %d)", playerid, data[PLY_CELL_HOLST], data[PLY_CELL_HOLSTEX], itemid);
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

		if(saveload_Debug[playerid] == 2)
			printf("\t[LOAD:%p] HELD %d (%d) (itemid: %d)", playerid, data[PLY_CELL_HELD], data[PLY_CELL_HELDEX], itemid);
	}

	SetPlayerStance(playerid, data[PLY_CELL_STANCE]);
	SetPlayerBitFlag(playerid, Bleeding, data[PLY_CELL_BLEEDING]);
	SetPlayerCuffs(playerid, data[PLY_CELL_CUFFED]);
	SetPlayerWarnings(playerid, data[PLY_CELL_WARNS]);
	SetPlayerRadioFrequency(playerid, Float:data[PLY_CELL_FREQ]);
	SetPlayerChatMode(playerid, data[PLY_CELL_CHATMODE]);
	SetPlayerBitFlag(playerid, Infected, data[PLY_CELL_INFECTED]);
	SetPlayerBitFlag(playerid, ToolTips, data[PLY_CELL_TOOLTIPS]);

	if(!IsPointInMapBounds(Float:data[PLY_CELL_SPAWN_X], Float:data[PLY_CELL_SPAWN_Y], Float:data[PLY_CELL_SPAWN_Z]))
		data[PLY_CELL_SPAWN_Z] += _:1.0;

	SetPlayerSpawnPos(playerid, Float:data[PLY_CELL_SPAWN_X], Float:data[PLY_CELL_SPAWN_Y], Float:data[PLY_CELL_SPAWN_Z]);
	SetPlayerSpawnRot(playerid, Float:data[PLY_CELL_SPAWN_R]);

	SetPlayerMask(playerid, data[PLY_CELL_MASK]);

	if(data[PLY_CELL_MUTE_TIME] > 0)
		TogglePlayerMute(playerid, true, data[PLY_CELL_MUTE_TIME]);

	if(data[PLY_CELL_KNOCKOUT] > 0)
		KnockOutPlayer(playerid, data[PLY_CELL_KNOCKOUT]);

	if(IsItemTypeBag(ItemType:data[PLY_CELL_BAGTYPE]))
	{
		itemid = CreateItem(ItemType:data[PLY_CELL_BAGTYPE], 0.0, 0.0, 0.0);
		GivePlayerBag(playerid, itemid);

		if(saveload_Debug[playerid] == 3)
			printf("\t[LOAD:%p] BAG %d (itemid: %d)", playerid, data[PLY_CELL_BAGTYPE], itemid);
	}

	return 1;
}

FV10_LoadPlayerInventory(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		data[INV_CELL_END],
		itemid,
		containerid;

	PLAYER_INV_FILE(gPlayerName[playerid], filename);

	file = fopen(filename, io_read);

	if(!file)
	{
		printf("ERROR: [LoadPlayerInventory] Opening file '%s'.", filename);
		return 0;
	}

	fblockread(file, data, sizeof(data));
	fclose(file);

	for(new i; i < INV_MAX_SLOTS * 3; i += 3)
	{
		if(!IsValidItemType(ItemType:data[i]) || data[i] == 0)
			break;

		itemid = CreateItem(ItemType:data[i], 0.0, 0.0, 0.0);

		if(!IsItemTypeSafebox(ItemType:data[i]) && !IsItemTypeBag(ItemType:data[i]))
			SetItemExtraData(itemid, data[i + 2]);
	
		AddItemToInventory(playerid, itemid, 0);

		if(saveload_Debug[playerid] == 4)
			printf("\t[LOAD:%p] INV %d, %d, %d", playerid, data[i], data[i + 1], data[i + 2]);
	}

	containerid = GetItemExtraData(GetPlayerBagItem(playerid));

	if(IsValidContainer(containerid))
	{
		for(new i = INV_CELL_BAGITEMS; i < INV_CELL_BAGITEMS + (GetContainerSize(containerid) * 3); i += 3)
		{
			if(data[i] == _:INVALID_ITEM_TYPE)
				continue;

			if(data[i] == 0)
				continue;

			itemid = CreateItem(ItemType:data[i], 0.0, 0.0, 0.0);

			if(!IsItemTypeSafebox(ItemType:data[i]) && !IsItemTypeBag(ItemType:data[i]))
				SetItemExtraData(itemid, data[i + 2]);

			AddItemToContainer(containerid, itemid);

			if(saveload_Debug[playerid] == 4)
				printf("\t[LOAD:%p] BAG %d, %d, %d", playerid, data[i], data[i + 1], data[i + 2]);
		}
	}

	return 1;
}


/*==============================================================================

	Clear inventory data

==============================================================================*/


ClearPlayerInventoryFile(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		data[PLY_CELL_END];

	PLAYER_DAT_FILE(gPlayerName[playerid], filename);

	file = fopen(filename, io_write);

	if(!file)
	{
		printf("ERROR: [ClearPlayerInventoryFile] Opening file '%s'.", filename);
		return 0;
	}

	fblockwrite(file, data, 1);
	fclose(file);

	PLAYER_INV_FILE(gPlayerName[playerid], filename);

	file = fopen(filename, io_write);

	if(!file)
	{
		printf("ERROR: [ClearPlayerInventoryFile] Opening file '%s'.", filename);
		return 0;
	}

	fblockwrite(file, data, 1);
	fclose(file);

	return 1;
}


/*==============================================================================

	Gamemode exit fix for modio

==============================================================================*/


hook OnGameModeExit()
{
	new
		name[MAX_PLAYER_NAME],
		filename[64],
		session;

	printf("Closing open modio sessions for player data.");

	foreach(new i : Player)
	{
		GetPlayerName(i, name, MAX_PLAYER_NAME);
		PLAYER_DAT_FILE(name, filename);

		session = modio_getsession_write(filename);

		printf("- Closing file '%s' for playerid: %d (session: %d)", filename, i, session);

		if(session != -1)
			modio_finalise_write(session, true);
	}
}


/*==============================================================================

	IO debug mode setting

==============================================================================*/


ACMD:iodebug[4](playerid, params[])
{
	new
		targetid,
		level;

	if(sscanf(params, "ud", targetid, level))
	{
		Msg(playerid, YELLOW, " >  Usage: /iodebug [player name or ID] [debug level 0-4]");
		return 1;
	}

	saveload_Debug[targetid] = level;

	MsgF(playerid, YELLOW, " >  Saveload debug set to %d for %p.", level, targetid);

	return 1;
}
