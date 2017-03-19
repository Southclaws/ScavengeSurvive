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


#include <YSI\y_hooks>


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

		ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Whitelisted players", list, "Close", "");
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
	if(isnumeric(params))
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
		ItemType:type = INVALID_ITEM_TYPE,
		itemname[ITM_MAX_NAME],
		exdata[8];

	if(sscanf(params, "p<,>dA<d>(-2147483648)[8]", _:type, exdata) != 0)
	{
		new tmp[ITM_MAX_NAME];

		if(sscanf(params, "p<,>s[32]A<d>(-2147483648)[8]", tmp, exdata))
		{
			ChatMsg(playerid, YELLOW, " >  Usage: /additem [itemid/itemname], [optional:extradata array, comma separated]");
			return 1;
		}

		for(new ItemType:i; i < ITM_MAX_TYPES; i++)
		{
			GetItemTypeUniqueName(i, itemname);

			if(strfind(itemname, tmp, true) != -1)
			{
				type = i;
				break;
			}
		}

		if(type == INVALID_ITEM_TYPE)
		{
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

		if(type == INVALID_ITEM_TYPE)
		{
			ChatMsg(playerid, RED, " >  No items found matching: '%s'.", tmp);
			return 1;
		}
	}

	if(type == INVALID_ITEM_TYPE)
	{
		ChatMsg(playerid, RED, " >  Invalid item type: %d", _:type);
		return 1;
	}

	new
		exdatasize,
		typemaxsize = GetItemTypeArrayDataSize(type),
		itemid,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	for(new i; i < 8; ++i)
	{
		if(exdata[i] != cellmin)
			++exdatasize;
	}

	if(exdatasize > typemaxsize)
		exdatasize = typemaxsize;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	itemid = CreateItem(type,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)),
		z - FLOOR_OFFSET, .rz = r);

	if(exdatasize > 0)
		SetItemArrayData(itemid, exdata, exdatasize);

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
		ChatMsg(playerid, YELLOW, " >  Invalid vehicle type.");
		return 1;
	}

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	vehicleid = CreateLootVehicle(type, x, y, z, r);
	SetVehicleFuel(vehicleid, 100000.0);
	SetVehicleHealth(vehicleid, 990.0);

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
		foreach(new i : itm_Index)
		{
			if(GetItemTypeDefenceType(GetItemType(i)) == INVALID_DEFENCE_TYPE)
				continue;

			GetItemPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = DestroyItem(i);
		}

		return 1;
	}

	ChatMsg(playerid, YELLOW, " >  Usage: /delete [items/tents/defences/signs] [optional:range(1.5)]");

	return 1;
}
