#include <YSI\y_hooks>


// Directory for storing player-saved vehicles
#define DIRECTORY_VEHICLE			DIRECTORY_MAIN"Vehicle/"


static
		vehicle_ItemList[ITM_LST_OF_ITEMS(64)];


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

static
bool:	veh_PrintEach = true,
bool:	veh_PrintTotal = true;

static
		HANDLER = -1;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Vehicle/PlayerVehicle'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE);

	//GetSettingInt("player-vehicle/print-each", true, veh_PrintEach);
	//GetSettingInt("player-vehicle/print-total", true, veh_PrintTotal);

	HANDLER = debug_register_handler("vehicle/playervehicle");
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Vehicle/PlayerVehicle'...");

	LoadPlayerVehicles();
}

hook OnPlayerConnect(playerid)
{
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
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE),
		item[28],
		type;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			if(!(6 < strlen(item) < MAX_PLAYER_NAME + 4))
			{
				printf("[LoadPlayerVehicles] WARNING: File with a bad filename length: '%s' len: %d", item, strlen(item));
				continue;
			}

			if(strfind(item, ".dat", false, 3) == -1)
			{
				printf("[LoadPlayerVehicles] WARNING: File with invalid extension: '%s'", item);
				continue;
			}

			LoadPlayerVehicle(item);
		}
	}

	dir_close(direc);

	if(veh_PrintTotal)
		logf("Loaded %d Player vehicles", Iter_Count(veh_Index));

	return 1;
}


/*==============================================================================

	Load vehicle (individual)

==============================================================================*/


LoadPlayerVehicle(filename[])
{
	new
		filepath[64],
		data[VEH_CELL_END],
		length;

	filepath = DIRECTORY_VEHICLE;
	strcat(filepath, filename);

	length = modio_read(filepath, _T<A,C,T,V>, 1, data, false, false);

	if(length == 1)
	{
		if(data[0] == 0)
		{
			d:1:HANDLER("[LoadPlayerVehicle] ERROR: Vehicle set to inactive (file: %s)", filename);
			return 0;
		}
	}

	length = modio_read(filepath, _T<D,A,T,A>, sizeof(data), data, false, false);

	if(length == 0)
		return 0;

	if(!IsValidVehicleType(data[VEH_CELL_TYPE]))
	{
		logf("ERROR: Removing vehicle file '%s' invalid vehicle type '%d'.", filename, data[VEH_CELL_TYPE]);
		fremove(filepath);
		return 0;
	}

	new vehiclename[MAX_VEHICLE_TYPE_NAME];
	GetVehicleTypeName(data[VEH_CELL_TYPE], vehiclename);

	if(Float:data[VEH_CELL_HEALTH] < 255.5)
	{
		logf("ERROR: Removing vehicle file: '%s' (%s) due to low health.", filename, vehiclename);
		fremove(filepath);
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
				logf("ERROR: Removing vehicle file: %s (%s) because it's out of the map bounds.", filename, vehiclename);
				fremove(filepath);

				return 0;
			}
		}
	}

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
		data[VEH_CELL_COL2]);

	if(!IsValidVehicle(vehicleid))
		return 0;

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

	SetVehicleExternalLock(vehicleid, data[VEH_CELL_LOCKED]);

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
			trailername[MAX_VEHICLE_TYPE_NAME];

		GetVehicleTypeName(data[VEH_CELL_TYPE], trailername);

		trailerid = CreateWorldVehicle(
			data[VEH_CELL_TYPE],
			Float:data[VEH_CELL_POSX],
			Float:data[VEH_CELL_POSY],
			Float:data[VEH_CELL_POSZ],
			Float:data[VEH_CELL_ROTZ],
			data[VEH_CELL_COL1],
			data[VEH_CELL_COL2]);

		trailertrunksize = GetVehicleTypeTrunkSize(data[VEH_CELL_TYPE]);

		SetVehicleTrailer(vehicleid, trailerid);

		SetVehicleSpawnPoint(trailerid,
			Float:data[VEH_CELL_POSX],
			Float:data[VEH_CELL_POSY],
			Float:data[VEH_CELL_POSZ],
			Float:data[VEH_CELL_ROTZ]);

		Iter_Add(veh_Index, trailerid);

		SetVehicleHealth(vehicleid, Float:data[VEH_CELL_HEALTH]);
		SetVehicleFuel(vehicleid, Float:data[VEH_CELL_FUEL]);
		SetVehicleDamageData(vehicleid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
		SetVehicleKey(vehicleid, data[VEH_CELL_KEY]);

		new itemcount;

		if(trailertrunksize > 0)
		{
			new
				ItemType:itemtype,
				itemid,
				itemlist;

			length = modio_read(filepath, _T<T,T,R,N>, sizeof(vehicle_ItemList), vehicle_ItemList, false, false);
		
			itemlist = ExtractItemList(vehicle_ItemList, length);
			itemcount = GetItemListItemCount(itemlist);

			containerid = GetVehicleContainer(trailerid);

			for(new i; i < itemcount; i++)
			{
				itemtype = GetItemListItem(itemlist, i);

				if(itemtype == INVALID_ITEM_TYPE)
					break;

				if(itemtype == ItemType:0)
					break;

				itemid = CreateItem(itemtype);

				if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
					SetItemArrayDataFromListItem(itemid, itemlist, i);

				AddItemToContainer(containerid, itemid);
			}

			DestroyItemList(itemlist);
		}

		if(veh_PrintEach)
			logf("\t[LOAD] Trailer %d (%s) %d items: %s for %s at %.2f, %.2f, %.2f", trailerid, data[VEH_CELL_LOCKED] ? ("L") : ("U"), itemcount, trailername, owner, data[VEH_CELL_POSX], data[VEH_CELL_POSY], data[VEH_CELL_POSZ], data[VEH_CELL_ROTZ]);
	}

	new itemcount;

	if(trunksize > 0)
	{
		d:1:HANDLER("[LoadPlayerVehicle] trunk size: %d", trunksize);

		new
			ItemType:itemtype,
			itemid,
			itemlist;

		length = modio_read(filepath, _T<T,R,N,K>, sizeof(vehicle_ItemList), vehicle_ItemList, true);

		itemlist = ExtractItemList(vehicle_ItemList, length);
		itemcount = GetItemListItemCount(itemlist);

		containerid = GetVehicleContainer(vehicleid);

		d:1:HANDLER("[LoadPlayerVehicle] modio read length:%d itemlist:%d length:%d", length, itemlist, itemcount);

		for(new i; i < itemcount; i++)
		{
			itemtype = GetItemListItem(itemlist, i);

			d:2:HANDLER("[LoadPlayerVehicle] item %d/%d type:%d", i, itemcount, _:itemtype);

			if(itemtype == INVALID_ITEM_TYPE)
				break;

			if(itemtype == ItemType:0)
				break;

			itemid = CreateItem(itemtype);
			d:2:HANDLER("[LoadPlayerVehicle] created item:%d container:%d", itemid, containerid);

			if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
				SetItemArrayDataFromListItem(itemid, itemlist, i);

			AddItemToContainer(containerid, itemid);
		}

		DestroyItemList(itemlist);
	}

	if(veh_PrintEach)
		logf("\t[LOAD] Vehicle %d (%s) %d items: %s for %s at %.2f, %.2f, %.2f", vehicleid, data[VEH_CELL_LOCKED] ? ("L") : ("U"), itemcount, vehiclename, owner, data[VEH_CELL_POSX], data[VEH_CELL_POSY], data[VEH_CELL_POSZ], data[VEH_CELL_ROTZ]);

	return 1;
}


/*==============================================================================

	Write vehicle data to file

==============================================================================*/


_SaveVehicle(vehicleid, active = true)
{
	if(isnull(pveh_Owner[vehicleid]))
	{
		printf("ERROR: Attempted to save vehicle %d with null owner string.", vehicleid);
		return 0;
	}

	new
		filename[MAX_PLAYER_NAME + 22],
		session,
		vehiclename[MAX_VEHICLE_TYPE_NAME],
		data[VEH_CELL_END];

	format(filename, sizeof(filename), DIRECTORY_VEHICLE"%s.dat", pveh_Owner[vehicleid]);

	session = modio_getsession_write(filename);

	if(session != -1)
		modio_close_session_write(session);

	data[0] = active;
	modio_push(filename, _T<A,C,T,V>, 1, data);

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
		data[VEH_CELL_LOCKED] = IsVehicleLocked(vehicleid);

	modio_push(filename, _T<D,A,T,A>, VEH_CELL_END, data);

	// Now do trailers with the same modio parameters

	new trailerid = GetVehicleTrailerID(vehicleid);

	if(IsValidVehicle(trailerid))
	{
		new containerid = GetVehicleContainer(trailerid);

		data[VEH_CELL_TYPE] = GetVehicleType(trailerid);
		GetVehicleHealth(trailerid, Float:data[VEH_CELL_HEALTH]);
		data[VEH_CELL_FUEL] = _:0.0;
		GetVehiclePos(trailerid, Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);
		GetVehicleZAngle(trailerid, Float:data[VEH_CELL_ROTZ]);
		GetVehicleColours(vehicleid, data[VEH_CELL_COL1], data[VEH_CELL_COL2]);
		GetVehicleDamageStatus(trailerid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
		data[VEH_CELL_KEY] = GetVehicleKey(vehicleid);
		data[VEH_CELL_LOCKED] = IsVehicleLocked(trailerid);

		// TDAT = Trailer Data
		modio_push(filename, _T<T,D,A,T>, VEH_CELL_END, data);

		new itemcount;

		if(IsValidContainer(containerid))
		{
			new
				items[64],
				itemlist;

			for(new i, j = GetContainerSize(containerid); i < j; i++)
			{
				items[i] = GetContainerSlotItem(containerid, i);

				if(!IsValidItem(items[i]))
					break;

				itemcount++;
			}

			itemlist = CreateItemList(items, itemcount);
			GetItemList(itemlist, vehicle_ItemList);

			// TTRN = Trailer Trunk
			modio_push(filename, _T<T,T,R,N>, GetItemListSize(itemlist), vehicle_ItemList);

			DestroyItemList(itemlist);
		}

		GetVehicleTypeName(GetVehicleType(trailerid), vehiclename);

		if(veh_PrintEach)
		{
			logf("[SAVE] Trailer %d (%s) %d items: %s for %s at %.2f, %.2f, %.2f",
				trailerid,
				IsVehicleLocked(trailerid) ? ("L") : ("U"),
				itemcount,
				vehiclename,
				pveh_Owner[vehicleid],
				Float:data[VEH_CELL_POSX],
				Float:data[VEH_CELL_POSY],
				Float:data[VEH_CELL_POSZ]);
		}
	}

	new containerid = GetVehicleContainer(vehicleid);

	if(!IsValidContainer(containerid))
	{
		modio_close_session_write(modio_getsession_write(filename));
		return 1;
	}

	new
		items[64],
		itemcount,
		itemlist;

	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		items[i] = GetContainerSlotItem(containerid, i);

		if(!IsValidItem(items[i]))
			break;

		itemcount++;
	}

	itemlist = CreateItemList(items, itemcount);
	GetItemList(itemlist, vehicle_ItemList);

	modio_push(filename, _T<T,R,N,K>, GetItemListSize(itemlist), vehicle_ItemList);

	DestroyItemList(itemlist);

	if(active)
	{
		if(veh_PrintEach)
		{
			logf("[SAVE] Vehicle %d (%s) %d items: %s for %s at %.2f, %.2f, %.2f",
				vehicleid,
				IsVehicleLocked(vehicleid) ? ("L") : ("U"),
				itemcount,
				vehiclename,
				pveh_Owner[vehicleid],
				Float:data[VEH_CELL_POSX],
				Float:data[VEH_CELL_POSY],
				Float:data[VEH_CELL_POSZ]);
		}
	}
	else
	{
		if(veh_PrintEach)
			logf("[DELT] Removing player vehicle %d, owner: %s", vehicleid, pveh_Owner[vehicleid]);
	}

	return 1;
}


/*==============================================================================

	Internal functions and hooks

==============================================================================*/


hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
		if(pveh_SaveAnyVehicle[playerid])
			_PlayerUpdateVehicle(playerid, GetPlayerVehicleID(playerid));

		else
			_SaveIfOwnedBy(GetPlayerVehicleID(playerid), playerid);

	}
	if(oldstate == PLAYER_STATE_DRIVER)
	{
		if(GetTickCountDifference(GetPlayerVehicleEnterTick(playerid), GetTickCount()) > 1000)
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

		MsgF(playerid, YELLOW, " >  This "C_BLUE"%s"C_YELLOW" is not yours, you own a "C_BLUE"%s"C_YELLOW". To save any vehicle, type: /vsave", vehiclename, ownedvehiclename);
		return 0;
	}

	MsgF(playerid, YELLOW, " >  Vehicle "C_BLUE"%s"C_YELLOW" saved!", vehiclename);

	_SaveVehicle(vehicleid);

	return 1;
}

_PlayerUpdateVehicle(playerid, vehicleid)
{
	d:1:HANDLER("[_PlayerUpdateVehicle] %d %d", playerid, vehicleid);
	if(IsPlayerOnAdminDuty(playerid))
		return;

	new vehiclename[MAX_VEHICLE_TYPE_NAME];
	GetVehicleTypeName(GetVehicleType(vehicleid), vehiclename);

	_UpdatePlayerVehicle(playerid, vehicleid);

	MsgF(playerid, YELLOW, " >  Vehicle "C_BLUE"%s"C_YELLOW" saved!", vehiclename);

	return;
}

public OnVehicleDestroyed(vehicleid)
{
	_RemoveVehicleFile(vehicleid);

	#if defined pveh_OnVehicleDestroyed
		return pveh_OnVehicleDestroyed(vehicleid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnVehicleDestroyed
	#undef OnVehicleDestroyed
#else
	#define _ALS_OnVehicleDestroyed
#endif
 
#define OnVehicleDestroyed pveh_OnVehicleDestroyed
#if defined pveh_OnVehicleDestroyed
	forward pveh_OnVehicleDestroyed(vehicleid);
#endif

_SetVehicleOwner(vehicleid, name[MAX_PLAYER_NAME], playerid = INVALID_PLAYER_ID)
{
	d:1:HANDLER("[_SetVehicleOwner] %d '%s' %d", vehicleid, name, playerid);

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
	d:1:HANDLER("[_RemoveVehicleOwner] %d", vehicleid);

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
	d:1:HANDLER("[_UpdatePlayerVehicle] %d %d", playerid, vehicleid);

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
		d:1:HANDLER("[_UpdatePlayerVehicle] Vehicle %d owner is null", vehicleid);

		if(IsValidVehicle(pveh_PlayerVehicle[playerid]))
		{
			d:1:HANDLER("[_UpdatePlayerVehicle] Player vehicle is %d, removing", pveh_PlayerVehicle[playerid]);
			_RemoveVehicleOwner(pveh_PlayerVehicle[playerid]);
		}

		_SetVehicleOwner(vehicleid, name, playerid);
		_SaveVehicle(vehicleid);
	}
	else
	{
		// Vehicle has an owner
		d:1:HANDLER("[_UpdatePlayerVehicle] Vehicle %d owner is not null: '%s'", vehicleid, pveh_Owner[vehicleid]);
		if(pveh_PlayerVehicle[playerid] == vehicleid)
		{
			// Vehicle's owner is the player, do nothing but save it
			d:1:HANDLER("[_UpdatePlayerVehicle] This vehicle belongs to the player in context");
			_SaveVehicle(vehicleid);
		}
		else
		{
			// Vehicle's owner is not the player, check if the player already
			// owns a vehicle
			d:1:HANDLER("[_UpdatePlayerVehicle] This vehicle does not belong to the player in context, swapping");

			if(pveh_PlayerVehicle[playerid] != INVALID_VEHICLE_ID)
			{
				// Player owns a vehicle
				d:1:HANDLER("[_UpdatePlayerVehicle] Player in context already owns a vehicle (%d) swapping owners", pveh_PlayerVehicle[playerid]);

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
				d:1:HANDLER("[_UpdatePlayerVehicle] Player in context does not own a vehicle, saving this one");
				_RemoveVehicleFile(vehicleid);
				_SetVehicleOwner(vehicleid, name, playerid);
				_SaveVehicle(vehicleid);
			}
		}
	}

	return 1;
}

_RemoveVehicleFile(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	if(isnull(pveh_Owner[vehicleid]))
		return 1;

	return _SaveVehicle(vehicleid, false);
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

stock RemoveVehicleFile(vehicleid)
{
	return _RemoveVehicleFile(vehicleid);
}

CMD:vsave(playerid, params[])
{
	if(!isnull(params) && !strcmp(params, "on"))
	{
		pveh_SaveAnyVehicle[playerid] = 1;
		Msg(playerid, YELLOW, " >  Vehicle save mode set to 'All vehicles'. When you enter ANY vehicle, it will be saved for you.");
		return 1;
	}

	if(!isnull(params) && !strcmp(params, "off"))
	{
		pveh_SaveAnyVehicle[playerid] = 0;
		Msg(playerid, YELLOW, " >  Vehicle save mode set to: 'Own vehicle'. Only your own vehicle will be saved when you drive it. If you enter another vehicle as a driver, it won't overwrite your current vehicle.");
		return 1;
	}

	Msg(playerid, YELLOW, " >  Usage: /vsave [on / off] - Save vehicles when exited or entered. When 'off', you will only be able to save your own exiting vehicle.");

	return 1;
}
