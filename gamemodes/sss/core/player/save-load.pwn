/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 "Southclaws" Keene

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


#define DIRECTORY_PLAYER			DIRECTORY_MAIN"player/"
#define PLAYER_DATA_FILE			DIRECTORY_PLAYER"%s.dat"
#define PLAYER_DAT_FILE(%0,%1)		format(%1, MAX_PLAYER_FILE, PLAYER_DATA_FILE, %0)
#define CHARACTER_DATA_FILE_VERSION	(10)
#define MAX_BAG_CONTAINER_SIZE		(14)


static saveload_Loaded[MAX_PLAYERS];


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
	PLY_CELL_UNUSED,
	PLY_CELL_TOOLTIPS,
	PLY_CELL_SPAWN_X,
	PLY_CELL_SPAWN_Y,
	PLY_CELL_SPAWN_Z,
	PLY_CELL_SPAWN_R,
	PLY_CELL_MASK,
	PLY_CELL_MUTE_TIME,
	PLY_CELL_KNOCKOUT,
	PLY_CELL_BAGTYPE,
	PLY_CELL_WORLD,
	PLY_CELL_INTERIOR,
	PLY_CELL_END
}


forward OnPlayerSave(playerid, filename[]);
forward OnPlayerLoad(playerid, filename[]);


hook OnGameModeInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER);
}

hook OnPlayerConnect(playerid)
{
	saveload_Loaded[playerid] = false;
}

SavePlayerChar(playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	new
		name[MAX_PLAYER_NAME],
		filename[MAX_PLAYER_FILE],
		session,
		data[ITM_ARR_MAX_ARRAY_DATA + 2],
		animidx = GetPlayerAnimationIndex(playerid),
		Item:itemid,
		Item:items[MAX_BAG_CONTAINER_SIZE],
		itemcount;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	PLAYER_DAT_FILE(name, filename);

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
	data[PLY_CELL_HAT]		= _:GetItemType(GetPlayerHatItem(playerid));

	Logger_Dbg("save-load", "saving character",
		Logger_I("playerid", playerid),
		Logger_F("health", data[PLY_CELL_HEALTH]),
		Logger_F("armour", data[PLY_CELL_ARMOUR]),
		Logger_F("food", data[PLY_CELL_FOOD]),
		Logger_I("skin", data[PLY_CELL_SKIN]),
		Logger_I("hat", data[PLY_CELL_HAT])
	);

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

	GetPlayerBleedRate(playerid, Float:data[PLY_CELL_BLEEDING]);
	data[PLY_CELL_CUFFED] = (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED);
	data[PLY_CELL_WARNS] = GetPlayerWarnings(playerid);
	data[PLY_CELL_FREQ] = _:GetPlayerRadioFrequency(playerid);
	data[PLY_CELL_CHATMODE] = GetPlayerChatMode(playerid);
	data[PLY_CELL_TOOLTIPS] = IsPlayerToolTipsOn(playerid);

	GetPlayerPos(playerid, Float:data[PLY_CELL_SPAWN_X], Float:data[PLY_CELL_SPAWN_Y], Float:data[PLY_CELL_SPAWN_Z]);
	GetPlayerFacingAngle(playerid, Float:data[PLY_CELL_SPAWN_R]);

	data[PLY_CELL_MASK] = _:GetItemType(GetPlayerMaskItem(playerid));
	data[PLY_CELL_MUTE_TIME] = GetPlayerMuteRemainder(playerid);
	data[PLY_CELL_KNOCKOUT] = GetPlayerKnockOutRemainder(playerid);

	if(IsValidItem(GetPlayerBagItem(playerid)))
	{
		data[PLY_CELL_BAGTYPE] = _:GetItemType(GetPlayerBagItem(playerid));

		Logger_Dbg("save-load", "with bag",
			Logger_I("playerid", playerid),
			Logger_I("type", data[PLY_CELL_BAGTYPE])
		);
	}


	data[PLY_CELL_WORLD] = GetPlayerVirtualWorld(playerid);
	data[PLY_CELL_INTERIOR] = GetPlayerInterior(playerid);

	modio_push(filename, _T<C,H,A,R>, PLY_CELL_END, data);

/*
	Held item
*/

	itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid))
	{
		data[0] = _:GetItemType(itemid);
		GetItemArrayDataSize(itemid, data[1]);
		GetItemArrayData(itemid, data[2]);
		modio_push(filename, _T<H,E,L,D>, 2 + data[1], data);

		Logger_Dbg("save-load", "saving held item",
			Logger_I("playerid", playerid),
			Logger_I("type", data[0])
		);
	}
	else
	{
		data[0] = -1;
		modio_push(filename, _T<H,E,L,D>, 1, data);
	}

/*
	Holstered item
*/

	itemid = GetPlayerHolsterItem(playerid);

	if(IsValidItem(itemid))
	{
		data[0] = _:GetItemType(itemid);
		GetItemArrayDataSize(itemid, data[1]);
		GetItemArrayData(itemid, data[2]);
		modio_push(filename, _T<H,O,L,S>, 2 + data[1], data);

		Logger_Dbg("save-load", "saving holstered item",
			Logger_I("playerid", playerid),
			Logger_I("type", data[0])
		);
	}
	else
	{
		data[0] = -1;
		modio_push(filename, _T<H,O,L,S>, 1, data);
	}

/*
	Inventory
*/

	for(new i; i < MAX_INVENTORY_SLOTS; i++)
	{
		GetInventorySlotItem(playerid, i, items[i]);

		if(!IsValidItem(items[i]))
			break;

		itemcount++;

		Logger_Dbg("save-load", "saving held item",
			Logger_I("playerid", playerid),
			Logger_I("type", _:GetItemType(items[i]))
		);
	}

	new ret = SerialiseItems(items, itemcount);
	if(!ret)
	{
		modio_push(filename, _T<I,N,V,0>, GetSerialisedSize(), itm_arr_Serialized);
		ClearSerializer();
	}
	else
	{
		Logger_Err("failed to serialise items",
			Logger_I("playerid", playerid),
			Logger_I("code", ret));
	}

/*
	Bag
*/

	itemcount = 0;

	if(IsValidItem(GetPlayerBagItem(playerid)))
	{
		new Container:containerid = GetBagItemContainerID(GetPlayerBagItem(playerid));
		new size;
		GetContainerSize(containerid, size);

		for(new i; i < size && i < MAX_BAG_CONTAINER_SIZE; i++)
		{
			GetContainerSlotItem(containerid, i, items[i]);

			if(!IsValidItem(items[i]))
				break;

			itemcount++;

			Logger_Dbg("save-load", "saving held item",
				Logger_I("playerid", playerid),
				Logger_I("type", _:GetItemType(items[i]))
			);
		}

		ret = SerialiseItems(items, itemcount);
		if(!ret)
		{
			modio_push(filename, _T<B,A,G,0>, GetSerialisedSize(), itm_arr_Serialized);
			ClearSerializer();
		}
		else
		{
			Logger_Err("failed to serialise items",
				Logger_I("playerid", playerid),
				Logger_I("code", ret));
		}
	}

	CallLocalFunction("OnPlayerSave", "ds", playerid, filename);

	return 1;
}

LoadPlayerChar(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		filename[MAX_PLAYER_FILE],
		data[ITM_ARR_MAX_ARRAY_DATA + 2],
		ItemType:itemtype,
		Item:itemid,
		length;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	PLAYER_DAT_FILE(name, filename);

	length = modio_read(filename, _T<C,H,A,R>, sizeof(data), data);
	if(length < 0)
	{
		Logger_Err("modio read failed _T<C,H,A,R>",
			Logger_I("error", length));
		return 0;
	}

	Logger_Dbg("save-load", "loading character",
		Logger_I("playerid", playerid),
		Logger_F("health", data[PLY_CELL_HEALTH]),
		Logger_F("armour", data[PLY_CELL_ARMOUR]),
		Logger_F("food", data[PLY_CELL_FOOD]),
		Logger_I("skin", data[PLY_CELL_SKIN]),
		Logger_I("hat", data[PLY_CELL_HAT])
	);

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

	if(IsValidItemType(ItemType:data[PLY_CELL_HAT]))
		SetPlayerHatItem(playerid, CreateItem(ItemType:data[PLY_CELL_HAT]));

	if(GetPlayerAP(playerid) > 0.0)
		CreatePlayerArmour(playerid);

	if(data[PLY_CELL_BLEEDING] == 1)
		data[PLY_CELL_BLEEDING] = _:Float:0.01;

	if(Float:data[PLY_CELL_BLEEDING] > 1.0)
		data[PLY_CELL_BLEEDING] = _:(Float:data[PLY_CELL_BLEEDING] / 10.0);

	SetPlayerStance(playerid, data[PLY_CELL_STANCE]);
	SetPlayerBleedRate(playerid, Float:data[PLY_CELL_BLEEDING]);
	SetPlayerCuffs(playerid, data[PLY_CELL_CUFFED]);
	SetPlayerWarnings(playerid, data[PLY_CELL_WARNS]);
	SetPlayerRadioFrequency(playerid, Float:data[PLY_CELL_FREQ]);
	SetPlayerChatMode(playerid, data[PLY_CELL_CHATMODE]);
	SetPlayerToolTips(playerid, bool:data[PLY_CELL_TOOLTIPS]);
	SetPlayerSpawnPos(playerid, Float:data[PLY_CELL_SPAWN_X], Float:data[PLY_CELL_SPAWN_Y], Float:data[PLY_CELL_SPAWN_Z]);
	SetPlayerSpawnRot(playerid, Float:data[PLY_CELL_SPAWN_R]);

	if(IsValidItemType(ItemType:data[PLY_CELL_MASK]))
		SetPlayerMaskItem(playerid, CreateItem(ItemType:data[PLY_CELL_MASK]));

	if(data[PLY_CELL_MUTE_TIME] != 0)
		TogglePlayerMute(playerid, true, data[PLY_CELL_MUTE_TIME]);

	else
		TogglePlayerMute(playerid, false);

	if(data[PLY_CELL_KNOCKOUT] > 0)
		KnockOutPlayer(playerid, data[PLY_CELL_KNOCKOUT]);

	if(IsItemTypeBag(ItemType:data[PLY_CELL_BAGTYPE]))
	{
		itemid = CreateItem(ItemType:data[PLY_CELL_BAGTYPE], 0.0, 0.0, 0.0);
		GivePlayerBag(playerid, itemid);

		Logger_Dbg("save-load", "loading bag",
			Logger_I("playerid", playerid),
			Logger_I("type", data[PLY_CELL_BAGTYPE])
		);
	}

	SetPlayerVirtualWorld(playerid, data[PLY_CELL_WORLD]);
	SetPlayerInterior(playerid, data[PLY_CELL_INTERIOR]);

/*
	Held item
*/

	data[0] = -1;

	length = modio_read(filename, _T<H,E,L,D>, sizeof(data), data);
	if(length < 0)
	{
		Logger_Err("modio read failed _T<H,E,L,D>",
			Logger_I("error", length));
	}
	else if(IsValidItemType(ItemType:data[0]) && length > 0)
	{
		itemid = AllocNextItemID(ItemType:data[0]);
		SetItemNoResetArrayData(itemid, true);
		SetItemArrayData(itemid, data[2], data[1]);
		CreateItem_ExplicitID(itemid);
		GiveWorldItemToPlayer(playerid, itemid);

		Logger_Dbg("save-load", "loading held item",
			Logger_I("playerid", playerid),
			Logger_I("type", data[0])
		);
	}

/*
	Holstered item
*/

	data[0] = -1;

	length = modio_read(filename, _T<H,O,L,S>, sizeof(data), data);
	if(length < 0)
	{
		Logger_Err("modio read failed _T<H,O,L,S>",
			Logger_I("error", length));
	}
	else if(IsValidItemType(ItemType:data[0]) && length > 0)
	{
		itemid = AllocNextItemID(ItemType:data[0]);
		SetItemNoResetArrayData(itemid, true);
		SetItemArrayData(itemid, data[2], data[1]);
		CreateItem_ExplicitID(itemid);
		SetPlayerHolsterItem(playerid, itemid);

		Logger_Dbg("save-load", "loading holstered item",
			Logger_I("playerid", playerid),
			Logger_I("type", data[0])
		);
	}

/*
	Inventory
*/

	length = modio_read(filename, _T<I,N,V,0>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized);
	if(length < 0)
	{
		Logger_Err("modio read failed _T<I,N,V,0>",
			Logger_I("error", length));
	}
	else if(!DeserialiseItems(itm_arr_Serialized, length, false))
	{
		for(new i, j = GetStoredItemCount(); i < j; i++)
		{
			itemtype = GetStoredItemType(i);

			if(length == 0)
				break;

			if(itemtype == INVALID_ITEM_TYPE)
				break;

			if(itemtype == ItemType:0)
				break;

			itemid = CreateItem(itemtype, .virtual = 1);

			if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
				SetItemArrayDataFromStored(itemid, i);
		
			AddItemToInventory(playerid, itemid, 0);

			Logger_Dbg("save-load", "inventory item",
				Logger_I("playerid", playerid),
				Logger_I("slot", i),
				Logger_I("type", _:itemtype));
		}
		ClearSerializer();
	}

/*
	Bag
*/

	if(IsItemTypeBag(ItemType:data[PLY_CELL_BAGTYPE]))
	{
		length = modio_read(filename, _T<B,A,G,0>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized);
		if(length < 0)
		{
			Logger_Err("modio read failed _T<B,A,G,0>",
				Logger_I("error", length));
		}
		else if(!DeserialiseItems(itm_arr_Serialized, length, false))
		{
			new Container:containerid = GetBagItemContainerID(GetPlayerBagItem(playerid));

			for(new i, j = GetStoredItemCount(); i < j; i++)
			{
				itemtype = GetStoredItemType(i);
				itemid = CreateItem(itemtype, .virtual = 1);

				if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
					SetItemArrayDataFromStored(itemid, i);

				AddItemToContainer(containerid, itemid);

				Logger_Dbg("save-load", "bag item",
					Logger_I("playerid", playerid),
					Logger_I("slot", i),
					Logger_I("type", _:itemtype));
			}
			ClearSerializer();
		}
	}

	CallLocalFunction("OnPlayerLoad", "ds", playerid, filename);

	saveload_Loaded[playerid] = true;

	return 1;
}


/*==============================================================================

	Gamemode exit fix for modio

==============================================================================*/


CloseSaveSessions()
{
	log("[OnScriptExit] Shutting down 'SaveLoad'...");

	new
		name[MAX_PLAYER_NAME],
		filename[64],
		session;

	log("Closing open modio sessions for player data.");

	foreach(new i : Player)
	{
		GetPlayerName(i, name, MAX_PLAYER_NAME);
		PLAYER_DAT_FILE(name, filename);

		session = modio_getsession_write(filename);

		log("- Closing file '%s' for playerid: %d (session: %d)", filename, i, session);

		if(session != -1)
			modio_finalise_write(session, true);
	}
}

stock IsPlayerDataLoaded(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return saveload_Loaded[playerid];
}
