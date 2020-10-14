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


// Directory for storing player-saved vehicles
#define DIRECTORY_VEHICLE			DIRECTORY_MAIN"vehicle/"


enum
{
		VEH_CELL_TYPE,		// 00
		VEH_CELL_HEALTH,	// 01
		VEH_CELL_FUEL,		// 02
		VEH_CELL_POSX,		// 03
		VEH_CELL_POSY,		// 04
		VEH_CELL_POSZ,		// 05
		VEH_CELL_ROTZ,		// 06
		VEH_CELL_COL1,		// 07
		VEH_CELL_COL2,		// 08
		VEH_CELL_PANELS,	// 09
		VEH_CELL_DOORS,		// 10
		VEH_CELL_LIGHTS,	// 11
		VEH_CELL_TIRES,		// 12
		VEH_CELL_ARMOUR,	// 13
		VEH_CELL_KEY,		// 14
		VEH_CELL_LOCKED,	// 15
		VEH_CELL_END
}


static
		pveh_Owner[MAX_VEHICLES][MAX_PLAYER_NAME],
		pveh_OwnerPlayer[MAX_VEHICLES] = {INVALID_PLAYER_ID, ...},
		pveh_PlayerVehicle[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};

static
		pveh_SaveAnyVehicle[MAX_PLAYERS] = {1, ...};


forward OnVehicleSave(vehicleid);


hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE);
}

hook OnGameModeInit()
{
	LoadPlayerVehicles();
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/vehicle/player-vehicle.pwn");

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	foreach(new i : veh_Index)
	{
		if(isnull(pveh_Owner[i]))
			continue;

		if(!strcmp(pveh_Owner[i], name, true))
		{
			pveh_PlayerVehicle[playerid] = i;
			pveh_OwnerPlayer[i] = playerid;
			return 1;
		}
	}

	pveh_PlayerVehicle[playerid] = INVALID_VEHICLE_ID;
	pveh_SaveAnyVehicle[playerid] = 1;

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	dbg("global", CORE, "[OnPlayerDisconnect] in /gamemodes/sss/core/vehicle/player-vehicle.pwn");

	if(IsValidVehicle(pveh_PlayerVehicle[playerid]))
	{
		pveh_OwnerPlayer[pveh_PlayerVehicle[playerid]] = INVALID_PLAYER_ID;
		pveh_PlayerVehicle[playerid] = INVALID_VEHICLE_ID;
	}
}


/*==============================================================================

	Loading

==============================================================================*/


LoadPlayerVehicles()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE);

	new
		path[128] = DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE,
		Directory:direc,
		entry[128],
		ENTRY_TYPE:type,
		trimlength = strlen("./scriptfiles/");

	direc = OpenDir(path);
	if(direc == Directory:-1)
	{
		err("failed to open vehicles directory '%s': %d", path, _:direc);
		return 1;
	}

	while(DirNext(direc, type, entry))
	{
		if(type == E_REGULAR)
		{
			if(strfind(entry, ".dat", false, 3) == -1)
			{
				err("File with invalid extension: '%s'", entry);
				continue;
			}

			LoadPlayerVehicle(entry[trimlength]);
		}
	}

	CloseDir(direc);

	Logger_Log("loaded player vehicles", Logger_I("count", Iter_Count(veh_Index)));

	return 1;
}


/*==============================================================================

	Load vehicle (individual)

==============================================================================*/


LoadPlayerVehicle(const filepath[])
{
	new
		filename[32],
		data[VEH_CELL_END],
		length,
		geid[GEID_LEN];

	PathBase(filepath, filename);
	if(!(6 < strlen(filename) < MAX_PLAYER_NAME + 4))
	{
		err("File with a bad filename length: '%s' len: %d", filename, strlen(filename));
		return 0;
	}

	length = modio_read(filepath, _T<A,C,T,V>, 1, data, false, false);

	if(length < 0)
	{
		err("modio error %d in '%s'.", length, filename);
		modio_finalise_read(modio_getsession_read(filepath));
		return 0;
	}

	if(length == 1)
	{
		if(data[0] == 0)
		{
			dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "Vehicle set to inactive (file: %s)", filename);
			modio_finalise_read(modio_getsession_read(filepath));
			return 0;
		}
	}

	length = modio_read(filepath, _T<D,A,T,A>, sizeof(data), data, false, false);

	if(length == 0)
	{
		modio_finalise_read(modio_getsession_read(filepath));
		err("modio_read returned length of 0.");
		return 0;
	}

	if(!IsValidVehicleType(data[VEH_CELL_TYPE]))
	{
		err("Removing vehicle file '%s' invalid vehicle type '%d'.", filename, data[VEH_CELL_TYPE]);
		fremove(filepath);
		modio_finalise_read(modio_getsession_read(filepath));
		return 0;
	}

	new vehiclename[MAX_VEHICLE_TYPE_NAME];
	GetVehicleTypeName(data[VEH_CELL_TYPE], vehiclename);

	if(Float:data[VEH_CELL_HEALTH] < 255.5)
	{
		err("Removing vehicle file: '%s' (%s) due to low health.", filename, vehiclename);
		fremove(filepath);
		modio_finalise_read(modio_getsession_read(filepath));
		return 0;
	}

	new category = GetVehicleTypeCategory(data[VEH_CELL_TYPE]);

	if(category != VEHICLE_CATEGORY_BOAT)
	{
		if(!IsPointInMapBounds(Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]))
		{
			if(category == VEHICLE_CATEGORY_HELICOPTER || category == VEHICLE_CATEGORY_PLANE)
			{
				data[VEH_CELL_POSZ] = _:(Float:data[VEH_CELL_POSZ] + 10.0);
			}
			else
			{
				err("Removing vehicle file: %s (%s) because it's out of the map bounds.", filename, vehiclename);
				fremove(filepath);
				modio_finalise_read(modio_getsession_read(filepath));
				return 0;
			}
		}
	}

	modio_read(filepath, _T<G,E,I,D>, sizeof(geid), geid, false, false);

	new
		vehicleid,
		owner[MAX_PLAYER_NAME];

	strmid(owner, filename, 0, strlen(filename) - 4);

	vehicleid = CreateWorldVehicle(
		data[VEH_CELL_TYPE],
		Float:data[VEH_CELL_POSX],
		Float:data[VEH_CELL_POSY],
		Float:data[VEH_CELL_POSZ],
		Float:data[VEH_CELL_ROTZ],
		data[VEH_CELL_COL1],
		data[VEH_CELL_COL2],
		_,
		geid);

	if(!IsValidVehicle(vehicleid))
	{
		err("Created vehicle returned invalid ID (%d)", vehicleid);
		modio_finalise_read(modio_getsession_read(filepath));
		return 0;
	}

	SetVehicleSpawnPoint(vehicleid,
		Float:data[VEH_CELL_POSX],
		Float:data[VEH_CELL_POSY],
		Float:data[VEH_CELL_POSZ],
		Float:data[VEH_CELL_ROTZ]);

	_SetVehicleOwner(vehicleid, owner);

	Iter_Add(veh_Index, vehicleid);

	if(Float:data[VEH_CELL_HEALTH] > 990.0)
		data[VEH_CELL_HEALTH] = _:990.0;

	SetVehicleHP(vehicleid, Float:data[VEH_CELL_HEALTH]);
	SetVehicleFuel(vehicleid, Float:data[VEH_CELL_FUEL]);
	SetVehicleDamageData(vehicleid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
	SetVehicleColours(vehicleid, data[VEH_CELL_COL1], data[VEH_CELL_COL2]);
	SetVehicleKey(vehicleid, data[VEH_CELL_KEY]);

	SetVehicleExternalLock(vehicleid, E_LOCK_STATE:data[VEH_CELL_LOCKED]);

	new
		containerid,
		trunksize;

	trunksize = GetVehicleTypeTrunkSize(data[VEH_CELL_TYPE]);

	length = modio_read(filepath, _T<T,D,A,T>, sizeof(data), data, false, false);

	if(length > 0)
	{
		new
			trailerid,
			trailertrunksize,
			trailername[MAX_VEHICLE_TYPE_NAME],
			trailergeid[GEID_LEN];

		GetVehicleTypeName(data[VEH_CELL_TYPE], trailername);

		modio_read(filepath, _T<T,G,E,I>, sizeof(trailergeid), trailergeid, false, false);

		trailerid = CreateWorldVehicle(
			data[VEH_CELL_TYPE],
			Float:data[VEH_CELL_POSX],
			Float:data[VEH_CELL_POSY],
			Float:data[VEH_CELL_POSZ],
			Float:data[VEH_CELL_ROTZ],
			data[VEH_CELL_COL1],
			data[VEH_CELL_COL2],
			_,
			trailergeid);

		trailertrunksize = GetVehicleTypeTrunkSize(data[VEH_CELL_TYPE]);

		SetVehicleTrailer(vehicleid, trailerid);

		SetVehicleSpawnPoint(trailerid,
			Float:data[VEH_CELL_POSX],
			Float:data[VEH_CELL_POSY],
			Float:data[VEH_CELL_POSZ],
			Float:data[VEH_CELL_ROTZ]);

		Iter_Add(veh_Index, trailerid);

		SetVehicleHealth(trailerid, Float:data[VEH_CELL_HEALTH]);
		SetVehicleFuel(trailerid, Float:data[VEH_CELL_FUEL]);
		SetVehicleDamageData(trailerid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
		SetVehicleKey(trailerid, data[VEH_CELL_KEY]);

		SetVehicleExternalLock(trailerid, E_LOCK_STATE:data[VEH_CELL_LOCKED]);

		new itemcount;

		if(trailertrunksize > 0)
		{
			new
				ItemType:itemtype,
				itemid;

			length = modio_read(filepath, _T<T,T,R,N>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized, false, false);
		
			if(!DeserialiseItems(itm_arr_Serialized, length, false))
			{
				itemcount = GetStoredItemCount();

				containerid = GetVehicleContainer(trailerid);

				for(new i; i < itemcount; i++)
				{
					itemtype = GetStoredItemType(i);

					if(itemtype == INVALID_ITEM_TYPE)
						break;

					if(itemtype == ItemType:0)
						break;

					itemid = CreateItem(itemtype);

					if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
						SetItemArrayDataFromStored(itemid, i);

					AddItemToContainer(containerid, itemid);
				}

				ClearSerializer();
			}
		}

		Logger_Log("loaded player trailer",
			Logger_S("geid", trailergeid),
			Logger_I("id", trailerid),
			Logger_I("locked", data[VEH_CELL_LOCKED]),
			Logger_I("items", itemcount),
			Logger_S("type", trailername),
			Logger_S("owner", owner),
			Logger_F("x", data[VEH_CELL_POSX]),
			Logger_F("y", data[VEH_CELL_POSY]),
			Logger_F("z", data[VEH_CELL_POSZ]),
			Logger_F("r", data[VEH_CELL_ROTZ])
		);
	}

	new itemcount;

	if(trunksize > 0)
	{
		dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[LoadPlayerVehicle] trunk size: %d", trunksize);

		new
			ItemType:itemtype,
			itemid;

		length = modio_read(filepath, _T<T,R,N,K>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized, true);

		if(!DeserialiseItems(itm_arr_Serialized, length, false))
		{
			itemcount = GetStoredItemCount();

			containerid = GetVehicleContainer(vehicleid);

			dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[LoadPlayerVehicle] modio read length:%d items:%d", length, itemcount);

			for(new i; i < itemcount; i++)
			{
				itemtype = GetStoredItemType(i);

				dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 2, "[LoadPlayerVehicle] item %d/%d type:%d", i, itemcount, _:itemtype);

				if(itemtype == INVALID_ITEM_TYPE)
					break;

				if(itemtype == ItemType:0)
					break;

				itemid = CreateItem(itemtype);
				dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 2, "[LoadPlayerVehicle] created item:%d container:%d", itemid, containerid);

				if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
					SetItemArrayDataFromStored(itemid, i);

				AddItemToContainer(containerid, itemid);
			}

			ClearSerializer();
		}
	}

	Logger_Log("loaded player vehicle",
		Logger_S("geid", geid),
		Logger_I("id", vehicleid),
		Logger_I("locked", data[VEH_CELL_LOCKED]),
		Logger_I("items", itemcount),
		Logger_S("type", vehiclename),
		Logger_S("owner", owner),
		Logger_F("x", data[VEH_CELL_POSX]),
		Logger_F("y", data[VEH_CELL_POSY]),
		Logger_F("z", data[VEH_CELL_POSZ]),
		Logger_F("r", data[VEH_CELL_ROTZ])
	);

	return 1;
}


/*==============================================================================

	Write vehicle data to file

==============================================================================*/


_SaveVehicle(vehicleid)
{
	if(strlen(pveh_Owner[vehicleid]) < 3)
	{
		err("Attempted to save vehicle %d with bad owner string '%s'", vehicleid, pveh_Owner[vehicleid]);
		return 0;
	}

	if(CallLocalFunction("OnVehicleSave", "d", vehicleid))
	{
		dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_SaveVehicle] OnVehicleSave returned non-zero");
		return 0;
	}

	new
		filename[MAX_PLAYER_NAME + 22],
		session,
		vehiclename[MAX_VEHICLE_TYPE_NAME],
		active[1],
		data[VEH_CELL_END],
		geid[GEID_LEN];

	format(filename, sizeof(filename), DIRECTORY_VEHICLE"%s.dat", pveh_Owner[vehicleid]);

	session = modio_getsession_write(filename);

	if(session != -1)
		modio_close_session_write(session);

	active[0] = !IsVehicleDead(vehicleid);
	modio_push(filename, _T<A,C,T,V>, 1, active);

	GetVehicleTypeName(GetVehicleType(vehicleid), vehiclename);

	data[VEH_CELL_TYPE] = GetVehicleType(vehicleid);

	GetVehicleHealth(vehicleid, Float:data[1]);

	data[VEH_CELL_FUEL] = _:GetVehicleFuel(vehicleid);
	GetVehiclePos(vehicleid, Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);
	GetVehicleZAngle(vehicleid, Float:data[VEH_CELL_ROTZ]);
	GetVehicleColours(vehicleid, data[VEH_CELL_COL1], data[VEH_CELL_COL2]);
	GetVehicleDamageStatus(vehicleid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
	data[VEH_CELL_KEY] = GetVehicleKey(vehicleid);

	if(!IsVehicleOccupied(vehicleid))
		data[VEH_CELL_LOCKED] = _:GetVehicleLockState(vehicleid);

	modio_push(filename, _T<D,A,T,A>, VEH_CELL_END, data);

	geid = GetVehicleGEID(vehicleid);
	modio_push(filename, _T<G,E,I,D>, GEID_LEN, geid);

	// Now do trailers with the same modio parameters

	new trailerid = GetVehicleTrailerID(vehicleid);

	if(IsValidVehicle(trailerid))
	{
		new
			containerid = GetVehicleContainer(trailerid),
			trailergeid[GEID_LEN];

		data[VEH_CELL_TYPE] = GetVehicleType(trailerid);
		GetVehicleHealth(trailerid, Float:data[VEH_CELL_HEALTH]);
		data[VEH_CELL_FUEL] = _:0.0;
		GetVehiclePos(trailerid, Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);
		GetVehicleZAngle(trailerid, Float:data[VEH_CELL_ROTZ]);
		GetVehicleColours(trailerid, data[VEH_CELL_COL1], data[VEH_CELL_COL2]);
		GetVehicleDamageStatus(trailerid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
		data[VEH_CELL_KEY] = GetVehicleKey(trailerid);
		data[VEH_CELL_LOCKED] = _:GetVehicleLockState(trailerid);

		// TDAT = Trailer Data
		modio_push(filename, _T<T,D,A,T>, VEH_CELL_END, data);

		// TGEI = Trailer GEID
		trailergeid = GetVehicleGEID(trailerid);
		modio_push(filename, _T<T,G,E,I>, GEID_LEN, trailergeid);

		new itemcount;

		if(IsValidContainer(containerid))
		{
			new items[64];

			for(new i, j = GetContainerSize(containerid); i < j; i++)
			{
				items[i] = GetContainerSlotItem(containerid, i);

				if(!IsValidItem(items[i]))
					break;

				itemcount++;
			}

			if(!SerialiseItems(items, itemcount))
			{
				// TTRN = Trailer Trunk
				modio_push(filename, _T<T,T,R,N>, GetSerialisedSize(), itm_arr_Serialized);
				ClearSerializer();
			}
		}

		GetVehicleTypeName(GetVehicleType(trailerid), vehiclename);
		
		Logger_Log("saved player trailer",
			Logger_S("geid", trailergeid),
			Logger_I("id", trailerid),
			Logger_I("locked", _:GetVehicleLockState(trailerid)),
			Logger_I("items", itemcount),
			Logger_S("type", vehiclename),
			Logger_S("owner", pveh_Owner[trailerid]),
			Logger_F("x", data[VEH_CELL_POSX]),
			Logger_F("y", data[VEH_CELL_POSY]),
			Logger_F("z", data[VEH_CELL_POSZ]),
			Logger_F("r", data[VEH_CELL_ROTZ])
		);
	}

	new containerid = GetVehicleContainer(vehicleid);

	if(!IsValidContainer(containerid))
	{
		modio_close_session_write(modio_getsession_write(filename));
		return 1;
	}

	new
		items[64],
		itemcount;

	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		items[i] = GetContainerSlotItem(containerid, i);

		if(!IsValidItem(items[i]))
			break;

		itemcount++;
	}

	if(!SerialiseItems(items, itemcount))
	{
		modio_push(filename, _T<T,R,N,K>, GetSerialisedSize(), itm_arr_Serialized);
		ClearSerializer();
	}

	if(active[0])
	{
		Logger_Log("saved player vehicle",
			Logger_S("geid", geid),
			Logger_I("id", vehicleid),
			Logger_I("locked", _:GetVehicleLockState(vehicleid)),
			Logger_I("items", itemcount),
			Logger_S("type", vehiclename),
			Logger_S("owner", pveh_Owner[vehicleid]),
			Logger_F("x", data[VEH_CELL_POSX]),
			Logger_F("y", data[VEH_CELL_POSY]),
			Logger_F("z", data[VEH_CELL_POSZ]),
			Logger_F("r", data[VEH_CELL_ROTZ])
		);
	}
	else
	{
		Logger_Log("removed player vehicle",
			Logger_S("geid", geid),
			Logger_I("id", vehicleid),
			Logger_I("locked", _:GetVehicleLockState(vehicleid)),
			Logger_I("items", itemcount),
			Logger_S("type", vehiclename),
			Logger_S("owner", pveh_Owner[vehicleid]),
			Logger_F("x", data[VEH_CELL_POSX]),
			Logger_F("y", data[VEH_CELL_POSY]),
			Logger_F("z", data[VEH_CELL_POSZ]),
			Logger_F("r", data[VEH_CELL_ROTZ])
		);
	}

	return 1;
}


/*==============================================================================

	Internal functions and hooks

==============================================================================*/


hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	dbg("global", CORE, "[OnPlayerStateChange] in /gamemodes/sss/core/vehicle/player-vehicle.pwn");

	if(newstate == PLAYER_STATE_DRIVER)
	{
		if(pveh_SaveAnyVehicle[playerid])
			_PlayerUpdateVehicle(playerid, GetPlayerVehicleID(playerid));

		else
			_SaveIfOwnedBy(GetPlayerVehicleID(playerid), playerid);

	}
	if(oldstate == PLAYER_STATE_DRIVER)
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleEnterTick(playerid)) > 1000)
		{
			if(pveh_SaveAnyVehicle[playerid])
				_PlayerUpdateVehicle(playerid, GetPlayerLastVehicle(playerid));

			else
				_SaveIfOwnedBy(GetPlayerLastVehicle(playerid), playerid);
		}
	}

	return 1;
}

_SaveIfOwnedBy(vehicleid, playerid)
{
	new vehiclename[MAX_VEHICLE_TYPE_NAME];
	GetVehicleTypeName(GetVehicleType(vehicleid), vehiclename);

	if(pveh_PlayerVehicle[playerid] != vehicleid)
	{
		new ownedvehiclename[MAX_VEHICLE_TYPE_NAME];
		GetVehicleTypeName(GetVehicleType(pveh_PlayerVehicle[playerid]), ownedvehiclename);

		ChatMsgLang(playerid, YELLOW, "VEHNOTYOURS", vehiclename, ownedvehiclename);
		return 0;
	}

	ShowActionText(playerid, sprintf(ls(playerid, "VEHICLSAVED"), vehiclename), 5000);

	_SaveVehicle(vehicleid);

	return 1;
}

_PlayerUpdateVehicle(playerid, vehicleid)
{
	dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_PlayerUpdateVehicle] %d %d (%s)", playerid, vehicleid, GetVehicleGEID(vehicleid));
	if(IsPlayerOnAdminDuty(playerid))
		return;

	new vehiclename[MAX_VEHICLE_TYPE_NAME];
	GetVehicleTypeName(GetVehicleType(vehicleid), vehiclename);

	_UpdatePlayerVehicle(playerid, vehicleid);

	ShowActionText(playerid, sprintf(ls(playerid, "VEHICLSAVED"), vehiclename), 5000);

	return;
}

hook OnVehicleDestroyed(vehicleid)
{
	dbg("global", CORE, "[OnVehicleDestroyed] in /gamemodes/sss/core/vehicle/player-vehicle.pwn");

	_SaveVehicle(vehicleid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_SetVehicleOwner(vehicleid, name[MAX_PLAYER_NAME], playerid = INVALID_PLAYER_ID)
{
	dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_SetVehicleOwner] %d (%s) '%s' %d", vehicleid, GetVehicleGEID(vehicleid), name, playerid);

	if(!IsValidVehicle(vehicleid))
		return 0;

	if(isnull(name))
		return 0;

	if(IsPlayerConnected(playerid))
	{
		pveh_PlayerVehicle[playerid] = vehicleid;
		pveh_OwnerPlayer[vehicleid] = playerid;
	}
	else
	{
		pveh_OwnerPlayer[vehicleid] = INVALID_PLAYER_ID;
	}

	pveh_Owner[vehicleid][0] = EOS;
	strcat(pveh_Owner[vehicleid], name, MAX_PLAYER_NAME);

	return 1;
}

_RemoveVehicleOwner(vehicleid)
{
	dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_RemoveVehicleOwner] %d (%s)", vehicleid, GetVehicleGEID(vehicleid));

	if(!IsValidVehicle(vehicleid))
		return 0;

	pveh_Owner[vehicleid][0] = EOS;
	pveh_OwnerPlayer[vehicleid] = INVALID_PLAYER_ID;

	return 1;
}

/*
	Makes playerid the owner of vehicleid
	If playerid owned a vehicle beforehand, it is removed
	If vehicleid already has an owner, it is assigned to playerid's old vehicle
	Saves changes made to any vehicles in context
*/
_UpdatePlayerVehicle(playerid, vehicleid)
{
	dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_UpdatePlayerVehicle] %d %d (%s)", playerid, vehicleid, GetVehicleGEID(vehicleid));

	if(!IsPlayerConnected(playerid))
		return 0;

	if(!IsValidVehicle(vehicleid))
		return 0;

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	if(isnull(pveh_Owner[vehicleid]))
	{
		// Vehicle has no owner, assign player as owner
		// Set owner of player's old vehicle to null
		dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_UpdatePlayerVehicle] Vehicle owner is null");

		if(IsValidVehicle(pveh_PlayerVehicle[playerid]))
		{
			dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_UpdatePlayerVehicle] Player vehicle is %s (%d), removing", GetVehicleGEID(pveh_PlayerVehicle[playerid]), pveh_PlayerVehicle[playerid]);
			_RemoveVehicleOwner(pveh_PlayerVehicle[playerid]);
		}

		_SetVehicleOwner(vehicleid, name, playerid);
		_SaveVehicle(vehicleid);
	}
	else
	{
		// Vehicle has an owner
		dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_UpdatePlayerVehicle] Vehicle owner is not null: '%s'", pveh_Owner[vehicleid]);
		if(pveh_PlayerVehicle[playerid] == vehicleid)
		{
			// Vehicle's owner is the player, do nothing but save it
			dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_UpdatePlayerVehicle] This vehicle belongs to the player in context");
			_SaveVehicle(vehicleid);
		}
		else
		{
			// Vehicle's owner is not the player, check if the player already
			// owns a vehicle
			dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_UpdatePlayerVehicle] This vehicle does not belong to the player in context, swapping");

			if(pveh_PlayerVehicle[playerid] != INVALID_VEHICLE_ID)
			{
				// Player owns a vehicle
				dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_UpdatePlayerVehicle] Player in context already owns vehicle %s (%d) swapping owners", GetVehicleGEID(pveh_PlayerVehicle[playerid]), pveh_PlayerVehicle[playerid]);

				// pveh_PlayerVehicle[playerid] = player's previous vehicle
				// vehicleid = new vehicle

				new
					oldvehicleid,
					oldownername[MAX_PLAYER_NAME],
					oldplayerid = INVALID_PLAYER_ID;

				oldvehicleid = pveh_PlayerVehicle[playerid];
				strcat(oldownername, pveh_Owner[vehicleid]);
				oldplayerid = pveh_OwnerPlayer[vehicleid];

				_SetVehicleOwner(vehicleid, name, playerid);
				_SetVehicleOwner(oldvehicleid, oldownername, oldplayerid);
				_SaveVehicle(vehicleid);
				_SaveVehicle(oldvehicleid);
			}
			else
			{
				// Player does not own a vehicle
				// Remove the original owner's name from it
				// Assign the player as the new owner and save the vehicle
				dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[_UpdatePlayerVehicle] Player in context does not own a vehicle, saving this one");
				_SaveVehicle(vehicleid);
				_SetVehicleOwner(vehicleid, name, playerid);
				_SaveVehicle(vehicleid);
			}
		}
	}

	return 1;
}

hook OnPlayerSave(playerid, filename[])
{
	dbg("global", CORE, "[OnPlayerSave] in /gamemodes/sss/core/vehicle/player-vehicle.pwn");

	new data[1];
	data[0] = pveh_SaveAnyVehicle[playerid];

	modio_push(filename, _T<P,V,E,H>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	dbg("global", CORE, "[OnPlayerLoad] in /gamemodes/sss/core/vehicle/player-vehicle.pwn");

	new data[1];

	modio_read(filename, _T<P,V,E,H>, 1, data);

	pveh_SaveAnyVehicle[playerid] = data[0];
}


/*==============================================================================

	Interface

==============================================================================*/


stock SaveVehicle(vehicleid)
{
	_SaveVehicle(vehicleid);

	return 1;
}

stock UpdatePlayerVehicle(playerid, vehicleid)
{
	_UpdatePlayerVehicle(playerid, vehicleid);

	return 1;
}

stock GetVehicleOwner(vehicleid, name[MAX_PLAYER_NAME])
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	name = pveh_Owner[vehicleid];

	return 1;
}

stock SetVehicleOwner(vehicleid, name[MAX_PLAYER_NAME], playerid = INVALID_PLAYER_ID)
{
	return _SetVehicleOwner(vehicleid, name, playerid);
}

CMD:vsave(playerid, params[])
{
	if(!isnull(params) && !strcmp(params, "on"))
	{
		pveh_SaveAnyVehicle[playerid] = 1;
		ChatMsgLang(playerid, YELLOW, "VEHMODEALLV");
		return 1;
	}

	if(!isnull(params) && !strcmp(params, "off"))
	{
		pveh_SaveAnyVehicle[playerid] = 0;
		ChatMsgLang(playerid, YELLOW, "VEHMODEOWNV");
		return 1;
	}

	ChatMsgLang(playerid, YELLOW, "VEHMODEHELP");

	return 1;
}

CMD:veh(playerid, params[])
{
	new ownedvehiclename[MAX_VEHICLE_TYPE_NAME];
	GetVehicleTypeName(GetVehicleType(pveh_PlayerVehicle[playerid]), ownedvehiclename);
	ChatMsg(playerid, YELLOW, " >  Vehicle: %s", ownedvehiclename);
	return 1;
}