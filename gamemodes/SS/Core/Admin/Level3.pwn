#include <YSI\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(ADMIN_LEVEL_ADMIN, "/whitelist - add/remove name or turn whitelist on/off\n");
	RegisterAdminCommand(ADMIN_LEVEL_ADMIN, "/ip - get a player's IP\n");
	RegisterAdminCommand(ADMIN_LEVEL_ADMIN, "/vehicle - vehicle control (duty only)\n");
	RegisterAdminCommand(ADMIN_LEVEL_ADMIN, "/move - nudge yourself\n");
	RegisterAdminCommand(ADMIN_LEVEL_ADMIN, "/additem - spawn an item\n");
	RegisterAdminCommand(ADMIN_LEVEL_ADMIN, "/addvehicle - spawn a vehicle\n");
	RegisterAdminCommand(ADMIN_LEVEL_ADMIN, "/resetpassword - reset a password\n");
	RegisterAdminCommand(ADMIN_LEVEL_ADMIN, "/setactive - (de)activate accounts\n");
	RegisterAdminCommand(ADMIN_LEVEL_ADMIN, "/delete(items/tents/defences/signs) - delete things\n");
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
		MsgF(playerid, YELLOW, " >  Usage: /whitelist [add/remove/on/off/auto/list] - the whitelist is currently %s (auto: %s)", IsWhitelistActive() ? ("on") : ("off"), IsWhitelistAuto() ? ("on") : ("off"));
		return 1;
	}

	if(!strcmp(command, "add", true))
	{
		if(isnull(name))
		{
			Msg(playerid, YELLOW, " >  Usage /whitelist add [name]");
			return 1;
		}

		new result = AddNameToWhitelist(name);

		if(result == 1)
			MsgF(playerid, YELLOW, " >  Added "C_BLUE"%s "C_YELLOW"to whitelist.", name);

		if(result == 0)
			Msg(playerid, YELLOW, " >  That name "C_ORANGE"is already "C_YELLOW"in the whitelist.");

		if(result == -1)
			Msg(playerid, RED, " >  An error occurred.");
	}
	else if(!strcmp(command, "remove", true))
	{
		if(isnull(name))
		{
			Msg(playerid, YELLOW, " >  Usage /whitelist remove [name]");
			return 1;
		}

		new result = RemoveNameFromWhitelist(name);

		if(result == 1)
			MsgF(playerid, YELLOW, " >  Removed "C_BLUE"%s "C_YELLOW"from whitelist.", name);

		if(result == 0)
			Msg(playerid, YELLOW, " >  That name "C_ORANGE"is not "C_YELLOW"in the whitelist.");

		if(result == -1)
			Msg(playerid, RED, " >  An error occurred.");
	}
	else if(!strcmp(command, "on", true))
	{
		MsgAdmins(1, YELLOW, " >  Whitelist activated, only whitelisted players may join.");
		ToggleWhitelist(true);
	}
	else if(!strcmp(command, "off", true))
	{
		MsgAdmins(1, YELLOW, " >  Whitelist deactivated, anyone may join the server.");
		ToggleWhitelist(false);
	}
	else if(!strcmp(command, "auto", true))
	{
		if(!IsWhitelistAuto())
		{
			MsgAdmins(1, YELLOW, " >  Whitelist automatic toggle activated.");
			ToggleAutoWhitelist(true);

			// UpdateSetting("whitelist-auto-toggle", 0);
		}
		else
		{
			MsgAdmins(1, YELLOW, " >  Whitelist automatic toggle deactivated.");
			ToggleAutoWhitelist(false);

			// UpdateSetting("whitelist-auto-toggle", 0);
		}
	}
	else if(!strcmp(command, "?", true))
	{
		if(IsNameInWhitelist(name))
			Msg(playerid, YELLOW, " >  That name "C_BLUE"is "C_YELLOW"in the whitelist.");

		else
			Msg(playerid, YELLOW, " >  That name "C_ORANGE"is not "C_YELLOW"in the whitelist");
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

	Get IP

==============================================================================*/


ACMD:ip[3](playerid, params[])
{
	if(isnumeric(params))
	{
		new targetid = strval(params);

		if(!IsPlayerConnected(targetid))
		{
			if(targetid > 99)
				MsgF(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);

			else
				return 4;
		}

		MsgF(playerid, YELLOW, " >  IP for %P"C_YELLOW": %s", targetid, IpIntToStr(GetPlayerIpAsInt(targetid)));
	}
	else
	{
		if(!AccountExists(params))
		{
			MsgF(playerid, YELLOW, " >  The account '%s' does not exist.", params);
			return 1;
		}

		new ip;

		GetAccountIP(params, ip);

		MsgF(playerid, YELLOW, " >  IP for "C_BLUE"%s"C_YELLOW": %s", params, IpIntToStr(ip));
	}

	return 1;
}


/*==============================================================================

	Control vehicles

==============================================================================*/


ACMD:vehicle[3](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_LEAD)
		return 6;

	new
		command[8],
		vehicleid;

	if(sscanf(params, "s[8]D(-1)", command, vehicleid))
	{
		Msg(playerid, YELLOW, " >  Usage: /vehicle [get/goto/enter/owner/delete/respawn/reset/lock/unlock] [id]");
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

		GetVehiclePos(playerid, x, y, z);
		SetPlayerPos(vehicleid, x, y, z);

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

		MsgF(playerid, YELLOW, " >  Vehicle owner: '%s'", owner);

		return 1;
	}

	if(!strcmp(command, "delete"))
	{
		RemoveVehicleFileByID(vehicleid);
		DestroyVehicle(vehicleid, 0);

		MsgF(playerid, YELLOW, " >  Vehicle %d deleted", vehicleid);

		return 1;
	}

	if(!strcmp(command, "respawn"))
	{
		RespawnVehicle(vehicleid);

		MsgF(playerid, YELLOW, " >  Vehicle %d respawned", vehicleid);

		return 1;
	}

	if(!strcmp(command, "reset"))
	{
		ResetVehicle(vehicleid);

		MsgF(playerid, YELLOW, " >  Vehicle %d reset", vehicleid);

		return 1;
	}

	if(!strcmp(command, "lock"))
	{
		SetVehicleExternalLock(vehicleid, 1);

		MsgF(playerid, YELLOW, " >  Vehicle %d locked", vehicleid);

		return 1;
	}

	if(!strcmp(command, "unlock"))
	{
		SetVehicleExternalLock(vehicleid, 0);

		MsgF(playerid, YELLOW, " >  Vehicle %d unlocked", vehicleid);

		return 1;
	}

	if(!strcmp(command, "removekey"))
	{
		SetVehicleKey(vehicleid, 0);

		MsgF(playerid, YELLOW, " >  Vehicle %d unlocked", vehicleid);

		return 1;
	}

	Msg(playerid, YELLOW, " >  Usage: /vehicle [get/enter/owner/delete/respawn/reset/lock/unlock] [id]");

	return 1;
}


/*==============================================================================

	Spawn a new item into the game world

==============================================================================*/


ACMD:move[3](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_DEV)
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

	Msg(playerid, YELLOW, " >  Usage: /move [f/b/u/d] [optional:distance]");

	return 1;
}


/*==============================================================================

	Spawn a new item into the game world

==============================================================================*/


ACMD:additem[3](playerid, params[])
{
	new
		ItemType:type,
		itemname[ITM_MAX_NAME],
		exdata,
		itemid,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	if(sscanf(params, "dD(0)", _:type, exdata) == -1)
	{
		new tmp[ITM_MAX_NAME];

		if(sscanf(params, "p<,>s[32]D(0)", tmp, exdata))
		{
			Msg(playerid, YELLOW, " >  Usage: /additem [itemid/itemname], [optional:extradata]");
			return 1;
		}

		for(new ItemType:i; i < ITM_MAX_TYPES; i++)
		{
			GetItemTypeName(i, itemname);

			if(strfind(itemname, tmp, true) != -1)
			{
				type = i;
				break;
			}
		}
	}

	if(type == ItemType:0)
	{
		Msg(playerid, RED, " >  Cannot create item type 0");
		return 1;
	}

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	itemid = CreateItem(type,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)),
		z - 0.8568, .rz = r, .zoffset = 0.7);

	SetItemExtraData(itemid, exdata);	

	if(GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_LEAD)
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, response, listitem

			logf("[ADDITEM] %p added item %s (d:%d) reason: %s", pid, itemname, _:type, inputtext);
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

	if(isnumeric(params))
		type = strval(params);

	else
		type = GetVehicleTypeFromName(params, true, true);

	if(!IsValidVehicleType(type))
	{
		Msg(playerid, YELLOW, " >  Invalid vehicle type.");
		return 1;
	}

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	vehicleid = CreateNewVehicle(type, x, y, z, r);
	SetVehicleFuel(vehicleid, 100000.0);
	SetVehicleHealth(vehicleid, 990.0);

	if(GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_LEAD)
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, response, listitem

			logf("[ADDVEHICLE] %p added vehicle %d reason: %s", pid, type, inputtext);
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
		Msg(playerid, YELLOW, " >  Usage: /resetpassword [account user-name]");
		return 1;
	}

	new buffer[129];

	WP_Hash(buffer, MAX_PASSWORD_LEN, "password");

	if(SetAccountPassword(params, buffer))
		MsgF(playerid, YELLOW, " >  Password for '%s' reset.", params);

	else
		Msg(playerid, RED, " >  An error occurred.");

	return 1;
}


ACMD:setactive[3](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		active;

	if(sscanf(params, "s[24]d", name, active))
	{
		MsgF(playerid, YELLOW, " >  Usage: /setactive [name] [1/0]");
		return 1;
	}

	if(!AccountExists(name))
	{
		Msg(playerid, RED, " >  That account doesn't exist.");
		return 1;
	}

	SetAccountActiveState(name, active);

	MsgF(playerid, YELLOW, " >  %s "C_BLUE"'%s' "C_YELLOW"account.", active ? ("Activated") : ("Deactivated"), name);

	return 1;
}

/*==============================================================================

	Delete a bunch of a specific type of entity within a radius

==============================================================================*/


ACMD:delete[3](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) == ADMIN_LEVEL_ADMIN)
		return 6;

	new
		type[16],
		Float:range;

	if(sscanf(params, "s[16]F(1.5)", type, range))
	{
		Msg(playerid, YELLOW, " >  Usage: /delete [items/tents/defences/signs] [optional:range(1.5)]");
		return 1;
	}

	if(range > 100.0)
	{
		Msg(playerid, YELLOW, " >  Range limit: 100 metres");
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
			GetItemPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = DestroyItem(i);
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
		foreach(new i : def_Index)
		{
			GetDefencePos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = DestroyDefence(i);
		}

		return 1;
	}
	else if(!strcmp(type, "sign", true, 4))
	{
		foreach(new i : sgn_Index)
		{
			GetSignPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
			{
				i = DestroySign(i);
			}
		}

		return 1;
	}

	Msg(playerid, YELLOW, " >  Usage: /delete [items/tents/defences/signs] [optional:range(1.5)]");

	return 1;
}
