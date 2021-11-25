/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/whitelist - add/remove name or turn whitelist on/off\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/spec /free - spectate and freecam\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/ip - get a player's IP\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/vehicle - vehicle control (duty only)\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/move - nudge yourself\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/additem - spawn an item\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/addvehicle - spawn a vehicle\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/resetpassword - reset a password\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/setactive - (de)activate accounts\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/delete(items/tents/defences/signs) - delete things\n");
}


/*==============================================================================

	Add to/remove from/query/toggle the whitelist feature

==============================================================================*/


ACMD:whitelist[3](playerid, params[])
{
	new
		command[7],
		name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[7]S()[24]", command, name))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /whitelist [add/remove/on/off/auto/list] - the whitelist is currently %s (auto: %s)", IsWhitelistActive() ? ("on") : ("off"), IsWhitelistAuto() ? ("on") : ("off"));
		return 1;
	}

	if(!strcmp(command, "add", true))
	{
		if(isnull(name))
		{
			ChatMsg(playerid, YELLOW, " >  Usage /whitelist add [name]");
			return 1;
		}

		new result = AddNameToWhitelist(name);

		if(result == 1)
			ChatMsg(playerid, YELLOW, " >  Added "C_BLUE"%s "C_YELLOW"to whitelist.", name);

		if(result == 0)
			ChatMsg(playerid, YELLOW, " >  That name "C_ORANGE"is already "C_YELLOW"in the whitelist.");

		if(result == -1)
			ChatMsg(playerid, RED, " >  An error occurred.");
	}
	else if(!strcmp(command, "remove", true))
	{
		if(isnull(name))
		{
			ChatMsg(playerid, YELLOW, " >  Usage /whitelist remove [name]");
			return 1;
		}

		new result = RemoveNameFromWhitelist(name);

		if(result == 1)
			ChatMsg(playerid, YELLOW, " >  Removed "C_BLUE"%s "C_YELLOW"from whitelist.", name);

		if(result == 0)
			ChatMsg(playerid, YELLOW, " >  That name "C_ORANGE"is not "C_YELLOW"in the whitelist.");

		if(result == -1)
			ChatMsg(playerid, RED, " >  An error occurred.");
	}
	else if(!strcmp(command, "on", true))
	{
		ChatMsgAdmins(1, YELLOW, " >  Whitelist activated, only whitelisted players may join.");
		ToggleWhitelist(true);
	}
	else if(!strcmp(command, "off", true))
	{
		ChatMsgAdmins(1, YELLOW, " >  Whitelist deactivated, anyone may join the server.");
		ToggleWhitelist(false);
	}
	else if(!strcmp(command, "auto", true))
	{
		if(!IsWhitelistAuto())
		{
			ChatMsgAdmins(1, YELLOW, " >  Whitelist automatic toggle activated.");
			ToggleAutoWhitelist(true);

			// UpdateSetting("whitelist-auto-toggle", 0);
		}
		else
		{
			ChatMsgAdmins(1, YELLOW, " >  Whitelist automatic toggle deactivated.");
			ToggleAutoWhitelist(false);

			// UpdateSetting("whitelist-auto-toggle", 0);
		}
	}
	else if(!strcmp(command, "?", true))
	{
		if(IsNameInWhitelist(name))
			ChatMsg(playerid, YELLOW, " >  That name "C_BLUE"is "C_YELLOW"in the whitelist.");

		else
			ChatMsg(playerid, YELLOW, " >  That name "C_ORANGE"is not "C_YELLOW"in the whitelist");
	}
	else if(!strcmp(command, "list", true))
	{
		new list[(MAX_PLAYER_NAME + 1) * MAX_PLAYERS];

		foreach(new i : Player)
		{
			GetPlayerName(i, name, MAX_PLAYER_NAME);
			format(list, sizeof(list), "%s%C%s\n", list, IsPlayerInWhitelist(i) ? (GREEN) : (RED), name);
		}

		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Whitelisted players", list, "Close");
	}

	return 1;
}


/*==============================================================================

	Enter spectate mode on a specific player

==============================================================================*/


ACMD:spec[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)))
		return 6;

	if(isnull(params))
	{
		ExitSpectateMode(playerid);
	}
	else
	{
		new targetid = strval(params);

		if(IsPlayerConnected(targetid) && targetid != playerid)
		{
			if(GetPlayerAdminLevel(playerid) == STAFF_LEVEL_GAME_MASTER)
			{
				new name[MAX_PLAYER_NAME];

				GetPlayerName(targetid, name, MAX_PLAYER_NAME);

				if(!IsPlayerReported(name))
				{
					ChatMsg(playerid, YELLOW, " >  You can only spectate reported players.");
					return 1;
				}
			}

			EnterSpectateMode(playerid, targetid);
		}
	}

	return 1;
}

ACMD:free[2](playerid)
{
	if(!IsPlayerOnAdminDuty(playerid))
		return 6;

	if(GetPlayerSpectateType(playerid) == SPECTATE_TYPE_FREE)
		ExitFreeMode(playerid);

	else
		EnterFreeMode(playerid);

	return 1;
}

ACMD:recam[2](playerid, params[])
{
	SetCameraBehindPlayer(playerid);
	return 1;
}


/*==============================================================================

	Get IP

==============================================================================*/


ACMD:ip[3](playerid, params[])
{
	if(IsNumeric(params))
	{
		new targetid = strval(params);

		if(!IsPlayerConnected(targetid))
		{
			if(targetid > 99)
				ChatMsg(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);

			else
				return 4;
		}

		ChatMsg(playerid, YELLOW, " >  IP for %P"C_YELLOW": %s", targetid, IpIntToStr(GetPlayerIpAsInt(targetid)));
	}
	else
	{
		if(!AccountExists(params))
		{
			ChatMsg(playerid, YELLOW, " >  The account '%s' does not exist.", params);
			return 1;
		}

		new ip;

		GetAccountIP(params, ip);

		ChatMsg(playerid, YELLOW, " >  IP for "C_BLUE"%s"C_YELLOW": %s", params, IpIntToStr(ip));
	}

	return 1;
}


/*==============================================================================

	Control vehicles

==============================================================================*/


ACMD:vehicle[3](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD)
		return 6;

	new
		command[10],
		vehicleid;

	if(sscanf(params, "s[10]D(-1)", command, vehicleid))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /vehicle [get/goto/enter/owner/delete/respawn/reset/lock/unlock/removekey] [id]");
		return 1;
	}

	if(vehicleid == -1)
		vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleid))
		return 4;

	if(!strcmp(command, "get"))
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);
		PutPlayerInVehicle(playerid, vehicleid, 0);
		SetVehiclePos(vehicleid, x, y, z);
		SetPlayerPos(playerid, x, y, z + 2);
		SetCameraBehindPlayer(playerid);

		return 1;
	}

	if(!strcmp(command, "goto"))
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetVehiclePos(vehicleid, x, y, z);
		SetPlayerPos(playerid, x, y, z);

		return 1;
	}

	if(!strcmp(command, "enter"))
	{
		PutPlayerInVehicle(playerid, vehicleid, 0);

		return 1;
	}

	if(!strcmp(command, "owner"))
	{
		new owner[MAX_PLAYER_NAME];

		GetVehicleOwner(vehicleid, owner);

		ChatMsg(playerid, YELLOW, " >  Vehicle owner: '%s'", owner);

		return 1;
	}

	if(!strcmp(command, "delete"))
	{
		DestroyWorldVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d deleted", vehicleid);

		return 1;
	}

	if(!strcmp(command, "respawn"))
	{
		RespawnVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d respawned", vehicleid);

		return 1;
	}

	if(!strcmp(command, "reset"))
	{
		ResetVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d reset", vehicleid);

		return 1;
	}

	if(!strcmp(command, "lock"))
	{
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_EXTERNAL);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d locked", vehicleid);

		return 1;
	}

	if(!strcmp(command, "unlock"))
	{
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d unlocked", vehicleid);

		return 1;
	}

	if(!strcmp(command, "removekey"))
	{
		SetVehicleKey(vehicleid, 0);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d unlocked", vehicleid);

		return 1;
	}

	if(!strcmp(command, "destroy"))
	{
		SetVehicleHealth(vehicleid, 0.0);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d set on fire", vehicleid);

		return 1;
	}

	ChatMsg(playerid, YELLOW, " >  Usage: /vehicle [get/enter/owner/delete/respawn/reset/lock/unlock] [id]");

	return 1;
}


/*==============================================================================

	Spawn a new item into the game world

==============================================================================*/


ACMD:move[3](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	new
		direction[10],
		Float:amount;

	if(!sscanf(params, "s[10]F(2.0)", direction, amount))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, r);

		if(direction[0] == 'f') // forwards
			x += amount * floatsin(-r, degrees), y += amount * floatcos(-r, degrees);

		if(direction[0] == 'b') // backwards
			x -= amount * floatsin(-r, degrees), y -= amount * floatcos(-r, degrees);

		if(direction[0] == 'u') // up
			z += amount;

		if(direction[0] == 'd') // down
			z -= amount;

		SetPlayerPos(playerid, x, y, z);

		return 1;
	}

	ChatMsg(playerid, YELLOW, " >  Usage: /move [f/b/u/d] [optional:distance]");

	return 1;
}


/*==============================================================================

	Spawn a new item into the game world

==============================================================================*/


ACMD:additem[3](playerid, params[])
{
	new
		query[32],
		specifiers[32],
		data[64];

	if(sscanf(params, "s[32]S()[32]S()[64]", query, specifiers, data))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /additem [itemid/itemname] [extradata format specifiers] [extradata array, comma separated]");
		ChatMsg(playerid, YELLOW, " >  Example: `/additem gascan df 1, 4.5` create a petrol can with an integer and a float in extradata.");
		return 1;
	}

	// if the "query" is not an integer type, search for the name
	new ItemType:type = INVALID_ITEM_TYPE;
	if(sscanf(query, "d", _:type))
	{
		new itemname[MAX_ITEM_NAME];
		for(new ItemType:i; i < MAX_ITEM_TYPE; i++)
		{
			GetItemTypeUniqueName(i, itemname);

			if(strfind(itemname, query, true) != -1)
			{
				type = i;
				break;
			}
		}

		if(type == INVALID_ITEM_TYPE)
		{
			for(new ItemType:i; i < MAX_ITEM_TYPE; i++)
			{
				GetItemTypeName(i, itemname);

				if(strfind(itemname, query, true) != -1)
				{
					type = i;
					break;
				}
			}
		}
		if(type == INVALID_ITEM_TYPE)
		{
			ChatMsg(playerid, RED, " >  Invalid item type from string: '%s'", query);
			return 1;
		}
	}
	if(type == INVALID_ITEM_TYPE)
	{
		ChatMsg(playerid, RED, " >  Invalid item type from integer: '%d'", _:type);
		return 1;
	}

	new
		exdata[32],
		exdatalen = strlen(specifiers);
	if(exdatalen > 0)
	{
		// generate a sscanf enum specifier format
		new sscanf_format[32];
		format(sscanf_format, sizeof sscanf_format, "p<,>e<%s>", specifiers);

		// parse the extra data using the generated sscanf format string
		if(strlen(data) && sscanf(data, sscanf_format, exdata))
		{
			ChatMsg(playerid, YELLOW, " >  Format of exdata did not match specifier: '%s'", sscanf_format);
			return 1;
		}
	}

	// create the item and hydrate its extradata array.
	new
		typemaxsize,
		Item:itemid,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetItemTypeArrayDataSize(type, typemaxsize);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	itemid = CreateItem(type,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)),
		z - ITEM_FLOOR_OFFSET, .rz = r);

	if(exdatalen > 0)
	{
		SetItemArrayData(itemid, exdata, typemaxsize);
	}

	if(GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD)
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, response, listitem

			new itemname[MAX_ITEM_NAME];
			GetItemTypeName(type, itemname);
			log("[ADDITEM] %p added item %s (d:%d) reason: %s", pid, itemname, _:type, inputtext);
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Justification", "Type a reason for adding this item:", "Enter", "");
	}

	return 1;
}


/*==============================================================================

	Spawn a new vehicle into the game world

==============================================================================*/


ACMD:addvehicle[3](playerid, params[])
{
	new
		type,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		vehicleid;

	if(IsNumeric(params))
		type = strval(params);

	else
		type = GetVehicleTypeFromName(params, true, true);

	if(!IsValidVehicleType(type))
	{
		ChatMsg(playerid, YELLOW, " >  Invalid vehicle type.");
		return 1;
	}

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	vehicleid = CreateLootVehicle(type, x, y, z, r);
	SetVehicleFuel(vehicleid, 100000.0);
	SetVehicleHealth(vehicleid, 990.0);

	if(GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD)
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, response, listitem

			log("[ADDVEHICLE] %p added vehicle %d reason: %s", pid, type, inputtext);
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Justification", "Type a reason for adding this vehicle:", "Enter", "");
	}

	return 1;
}


/*==============================================================================

	Reset a player's password

==============================================================================*/


ACMD:resetpassword[3](playerid, params[])
{
	if(isnull(params))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /resetpassword [account user-name]");
		return 1;
	}

	new buffer[129];

	WP_Hash(buffer, MAX_PASSWORD_LEN, "password");

	if(SetAccountPassword(params, buffer))
		ChatMsg(playerid, YELLOW, " >  Password for '%s' reset.", params);

	else
		ChatMsg(playerid, RED, " >  An error occurred.");

	return 1;
}


ACMD:setactive[3](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		active;

	if(sscanf(params, "s[24]d", name, active))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /setactive [name] [1/0]");
		return 1;
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, RED, " >  That account doesn't exist.");
		return 1;
	}

	SetAccountActiveState(name, active);

	ChatMsg(playerid, YELLOW, " >  %s "C_BLUE"'%s' "C_YELLOW"account.", active ? ("Activated") : ("Deactivated"), name);

	return 1;
}

/*==============================================================================

	Delete a bunch of a specific type of entity within a radius

==============================================================================*/


ACMD:delete[3](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) == STAFF_LEVEL_ADMINISTRATOR)
		return 6;

	new
		type[16],
		Float:range;

	if(sscanf(params, "s[16]F(1.5)", type, range))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /delete [items/tents/defences/signs] [optional:range(1.5)]");
		return 1;
	}

	if(range > 100.0)
	{
		ChatMsg(playerid, YELLOW, " >  Range limit: 100 metres");
		return 1;
	}

	new
		Float:px,
		Float:py,
		Float:pz,
		Float:ix,
		Float:iy,
		Float:iz;

	GetPlayerPos(playerid, px, py, pz);

	if(!strcmp(type, "item", true, 4))
	{
		foreach(new i : itm_Index)
		{
			GetItemPos(Item:i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = _:DestroyItem(Item:i);
		}

		return 1;
	}
	else if(!strcmp(type, "tent", true, 4))
	{
		foreach(new i : tnt_Index)
		{
			GetTentPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = DestroyTent(i);
		}

		return 1;
	}
	else if(!strcmp(type, "defence", true, 7))
	{
		foreach(new i : itm_Index)
		{
			if(GetItemTypeDefenceType(GetItemType(Item:i)) == INVALID_DEFENCE_TYPE)
				continue;

			GetItemPos(Item:i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = _:DestroyItem(Item:i);
		}

		return 1;
	}

	ChatMsg(playerid, YELLOW, " >  Usage: /delete [items/tents/defences/signs] [optional:range(1.5)]");

	return 1;
}
