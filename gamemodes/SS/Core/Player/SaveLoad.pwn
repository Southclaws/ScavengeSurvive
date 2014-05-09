#include <YSI\y_hooks>


#define DIRECTORY_PLAYER			DIRECTORY_MAIN"Player/"
#define PLAYER_DATA_FILE			DIRECTORY_PLAYER"%s.dat"
#define PLAYER_DAT_FILE(%0,%1)		format(%1, MAX_PLAYER_FILE, PLAYER_DATA_FILE, %0)
#define CHARACTER_DATA_FILE_VERSION	(10)
#define SAVELOAD_DEBUG				(1)


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


hook OnGameModeInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER);
}

SavePlayerChar(playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	new
		filename[MAX_PLAYER_FILE],
		session,
		data[PLY_CELL_END],
		animidx = GetPlayerAnimationIndex(playerid),
		itemid,
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
	data[PLY_CELL_HOLST]	= -1; // depreciated
	data[PLY_CELL_HELD]		= -1; // depreciated

	if(saveload_Debug[playerid] >= 1)
		printf("[SAVE:%p] CHR %.1f, %.1f, %.1f, %d, %d", playerid, data[PLY_CELL_HEALTH], data[PLY_CELL_ARMOUR], data[PLY_CELL_FOOD], data[PLY_CELL_SKIN], data[PLY_CELL_HAT]);

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

	if(saveload_Debug[playerid] >= 3)
		printf("[SAVE:%p] BAG %d (itemid: %d)", playerid, data[PLY_CELL_BAGTYPE], GetPlayerBagItem(playerid));

	modio_push(filename, !"CHAR", PLY_CELL_END, data);

/*
	Held item
*/

	itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid))
	{
		data[0] = _:GetItemType(itemid);
		data[1] = GetItemArrayDataSize(itemid);
		printf("item array data size: %d", data[1]);
		GetItemArrayData(itemid, data[2]);
		modio_push(filename, !"HELD", 2 + data[1], data);

		for(new i; i < 2 + data[1]; i++)
			printf("  HELD AD %d: %d", i, data[i]);

		if(saveload_Debug[playerid] >= 2)
			printf("[SAVE:%p] HELD %d (%d adc) (itemid: %d)", playerid, data[0], data[1], itemid);
	}
	else
	{
		data[0] = -1;
		modio_push(filename, !"HELD", 1, data);
	}

/*
	Holstered item
*/

	itemid = GetPlayerHolsterItem(playerid);

	if(IsValidItem(itemid))
	{
		data[0] = _:GetItemType(itemid);
		data[1] = GetItemArrayDataSize(itemid);
		GetItemArrayData(itemid, data[2]);
		modio_push(filename, !"HOLS", 2 + data[1], data);

		for(new i; i < 2 + data[1]; i++)
			printf("  HOLS AD %d: %d", i, data[i]);

		if(saveload_Debug[playerid] >= 2)
			printf("[SAVE:%p] HOLS %d (%d adc) (itemid: %d)", playerid, data[0], data[1], itemid);
	}
	else
	{
		data[0] = -1;
		modio_push(filename, !"HOLS", 1, data);
	}

/*
	Inventory
*/

	for(new i; i < 4; i++)
	{
		items[i] = GetInventorySlotItem(playerid, i);

		if(!IsValidItem(items[i]))
			break;

		itemcount++;

		if(saveload_Debug[playerid] >= 4)
			printf("[SAVE:%p] - Inv item %d: (%d type: %d)", playerid, i, items[i], _:GetItemType(items[i]));
	}

	itemlist = CreateItemList(items, itemcount);
	GetItemList(itemlist, saveload_ItemList);

	if(saveload_Debug[playerid] >= 4)
		printf("[SAVE:%p] Inv items: %d (itemlist: %d, size: %d)", playerid, itemcount, GetItemListItemCount(itemlist), GetItemListSize(itemlist));

	modio_push(filename, !"INV0", GetItemListSize(itemlist), saveload_ItemList);

	DestroyItemList(itemlist);

/*
	Bag
*/

	itemcount = 0;

	if(IsValidItem(GetPlayerBagItem(playerid)))
	{
		new containerid = GetItemExtraData(GetPlayerBagItem(playerid));

		for(new i, j = GetContainerSize(containerid); i < j; i++)
		{
			items[i] = GetContainerSlotItem(containerid, i);

			if(!IsValidItem(items[i]))
				break;

			itemcount++;

			if(saveload_Debug[playerid] >= 4)
				printf("[SAVE:%p] - Bag item %d (%d type: %d)", playerid, i, items[i], _:GetItemType(items[i]));
		}

		itemlist = CreateItemList(items, itemcount);
		GetItemList(itemlist, saveload_ItemList);

		if(saveload_Debug[playerid] >= 4)
			printf("[SAVE:%p] Bag items: %d (itemlist: %d, size: %d)", playerid, itemcount, GetItemListItemCount(itemlist), GetItemListSize(itemlist));

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
		ItemType:itemtype,
		itemid,
		itemlist,
		length;

	PLAYER_DAT_FILE(gPlayerName[playerid], filename);

	length = modio_read(filename, !"CHAR", data);

	if(length == 0)
	{
		length = FV10_LoadPlayerChar(playerid);
		length += FV10_LoadPlayerInventory(playerid);
		return length;
	}

	if(saveload_Debug[playerid] >= 1)
		printf("[LOAD:%p] CHR %.1f, %.1f, %.1f, %d, %d", playerid, data[PLY_CELL_HEALTH], data[PLY_CELL_ARMOUR], data[PLY_CELL_FOOD], data[PLY_CELL_SKIN], data[PLY_CELL_HAT]);

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

/*
	Legacy code for old held/holstered item format. Depreciated because it only
	stores 1 cell of data (extradata) with items. These items are now stored in
	separate modio tags so the full array data is stored with them.
*/

	if(data[PLY_CELL_HELD] > 0)
	{
		itemid = CreateItem(ItemType:data[PLY_CELL_HELD]);

		if(!IsItemTypeExtraDataDependent(ItemType:data[PLY_CELL_HELD]))
			SetItemExtraData(itemid, data[PLY_CELL_HELDEX]);

		if(0 < data[PLY_CELL_HELD] < WEAPON_PARACHUTE)
		{
			new ItemType:ammotype[1];

			// Get the first ammo item type for this weapon's calibre.
			GetAmmoItemTypesOfCalibre(GetItemTypeWeaponCalibre(ItemType:data[PLY_CELL_HELD]), ammotype, 1);

			if(IsValidItemType(ammotype[0]))
			{
				SetItemWeaponItemAmmoItem(itemid, ammotype[0]);
				SetItemWeaponItemMagAmmo(itemid, 0);
				SetItemWeaponItemReserve(itemid, 0);
				AddAmmoToWeapon(itemid, data[PLY_CELL_HELDEX]);
			}
		}

		GiveWorldItemToPlayer(playerid, itemid);

		if(saveload_Debug[playerid] >= 2)
			printf("[LOAD:%p] OLD HELD %d (%d) (itemid: %d)", playerid, data[PLY_CELL_HELD], data[PLY_CELL_HELDEX], itemid);
	}

	if(data[PLY_CELL_HOLST] > 0)
	{
		itemid = CreateItem(ItemType:data[PLY_CELL_HOLST]);

		if(!IsItemTypeExtraDataDependent(ItemType:data[PLY_CELL_HOLST]))
			SetItemExtraData(itemid, data[PLY_CELL_HOLSTEX]);

		if(0 < data[PLY_CELL_HOLST] < WEAPON_PARACHUTE)
		{
			new ItemType:ammotype[1];

			GetAmmoItemTypesOfCalibre(GetItemTypeWeaponCalibre(ItemType:data[PLY_CELL_HOLST]), ammotype, 1);

			if(IsValidItemType(ammotype[0]))
			{
				SetItemWeaponItemAmmoItem(itemid, ammotype[0]);
				SetItemWeaponItemMagAmmo(itemid, 0);
				SetItemWeaponItemReserve(itemid, 0);
				AddAmmoToWeapon(itemid, data[PLY_CELL_HOLSTEX]);
			}
		}

		SetPlayerHolsterItem(playerid, itemid);

		if(saveload_Debug[playerid] >= 2)
			printf("[LOAD:%p] OLD HOLS %d (%d) (itemid: %d)", playerid, data[PLY_CELL_HOLST], data[PLY_CELL_HOLSTEX], itemid);
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

		if(saveload_Debug[playerid] >= 3)
			printf("[LOAD:%p] BAG %d (itemid: %d)", playerid, data[PLY_CELL_BAGTYPE], itemid);
	}

/*
	Held item
*/

	length = modio_read(filename, !"HELD", data);

	if(IsValidItemType(ItemType:data[0]) && length > 0)
	{
		itemid = CreateItem(ItemType:data[0]);
		SetItemArrayData(itemid, data[2], data[1]);
		GiveWorldItemToPlayer(playerid, itemid);

		if(saveload_Debug[playerid] >= 2)
			printf("[LOAD:%p] HELD %d (%d adc) (itemid: %d)", playerid, data[0], data[1], itemid);
	}

/*
	Holstered item
*/

	data[0] = -1;

	length = modio_read(filename, !"HOLS", data);

	if(IsValidItemType(ItemType:data[0]) && length > 0)
	{
		itemid = CreateItem(ItemType:data[0]);
		SetItemArrayData(itemid, data[2], data[1]);
		SetPlayerHolsterItem(playerid, itemid);

		if(saveload_Debug[playerid] >= 2)
			printf("[LOAD:%p] HOLS %d (%d adc) (itemid: %d)", playerid, data[0], data[1], itemid);
	}

/*
	Inventory
*/

	length = modio_read(filename, !"INV0", saveload_ItemList);

	itemlist = ExtractItemList(saveload_ItemList, length);

	if(saveload_Debug[playerid] >= 4)
		printf("[LOAD:%p] Inv items: %d", playerid, GetItemListItemCount(itemlist));

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

		if(saveload_Debug[playerid] >= 4)
			printf("[LOAD:%p] - Inv item %d: %d", playerid, i, _:itemtype);
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

		if(saveload_Debug[playerid] >= 4)
			printf("[LOAD:%p] Bag items: %d (itemlist size: %d)", playerid, GetItemListItemCount(itemlist), GetItemListSize(itemlist));

		for(new i, j = GetItemListItemCount(itemlist); i < j; i++)
		{
			itemtype = GetItemListItem(itemlist, i);
			itemid = CreateItem(itemtype);

			if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
				SetItemArrayDataFromListItem(itemid, itemlist, i);

			AddItemToContainer(containerid, itemid);

			if(saveload_Debug[playerid] >= 4)
				printf("[LOAD:%p] - Bag item %d: (%d type: %d)", playerid, i, itemid, _:itemtype);
		}
	}

	DestroyItemList(itemlist);

	CallLocalFunction("OnPlayerLoad", "ds", playerid, filename);

	return 1;
}


/*==============================================================================

	Legacy format (Load only)

==============================================================================*/


#define PLAYER_INV_FILE(%0,%1)	format(%1, MAX_PLAYER_FILE, "SSS/Inventory/%s.dat", %0)

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

	if(saveload_Debug[playerid] >= 1)
		printf("[LOAD:%p] CHR %.1f, %.1f, %.1f, %d, %d", playerid, data[PLY_CELL_HEALTH], data[PLY_CELL_ARMOUR], data[PLY_CELL_FOOD], data[PLY_CELL_SKIN], data[PLY_CELL_HAT]);

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

		if(saveload_Debug[playerid] >= 2)
			printf("[LOAD:%p] HOLST %d (%d) (itemid: %d)", playerid, data[PLY_CELL_HOLST], data[PLY_CELL_HOLSTEX], itemid);
	}

	if(data[PLY_CELL_HELD] != -1)
	{
		if(0 < data[PLY_CELL_HELD] < WEAPON_PARACHUTE)
		{
			// SetPlayerWeapon(playerid, data[PLY_CELL_HELD], data[PLY_CELL_HELDEX]);
		}
		else
		{
			itemid = CreateItem(ItemType:data[PLY_CELL_HELD]);

			if(!IsItemTypeSafebox(ItemType:data[PLY_CELL_HELD]) && !IsItemTypeBag(ItemType:data[PLY_CELL_HELD]))
				SetItemExtraData(itemid, data[PLY_CELL_HELDEX]);

			GiveWorldItemToPlayer(playerid, itemid, false);
		}

		if(saveload_Debug[playerid] >= 2)
			printf("[LOAD:%p] HELD %d (%d) (itemid: %d)", playerid, data[PLY_CELL_HELD], data[PLY_CELL_HELDEX], itemid);
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

		if(saveload_Debug[playerid] >= 3)
			printf("[LOAD:%p] BAG %d (itemid: %d)", playerid, data[PLY_CELL_BAGTYPE], itemid);
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

		if(saveload_Debug[playerid] >= 4)
			printf("[LOAD:%p] INV %d, %d, %d", playerid, data[i], data[i + 1], data[i + 2]);
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

			if(saveload_Debug[playerid] >= 4)
				printf("[LOAD:%p] BAG %d, %d, %d", playerid, data[i], data[i + 1], data[i + 2]);
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
