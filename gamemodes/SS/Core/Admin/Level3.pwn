// 6 commands

new gAdminCommandList_Lvl3[] =
{
	"/whitelist - add/remove name or turn whitelist on/off\n\
	/up - move up (Duty only)\n\
	/ford - move forward (Duty only)\n\
	/goto - teleport to player (Duty only)\n\
	/get - teleport player to you (Duty only)\n\
	/resetpassword\n"
};

ACMD:whitelist[3](playerid, params[])
{
	new
		command[7],
		name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[7]S()[24]", command, name))
	{
		MsgF(playerid, YELLOW, " >  Usage: /whitelist [add/remove/on/off] [name] - the whitelist is currently %s", gWhitelist ? ("on") : ("off"));
		return 1;
	}

	if(!strcmp(command, "add", true) && !isnull(name))
	{
		new result = AddNameToWhitelist(name);

		if(result == 1)
			MsgF(playerid, YELLOW, " >  Added "C_BLUE"%s "C_YELLOW"to whitelist.", name);

		if(result == 0)
			Msg(playerid, YELLOW, " >  That name "C_ORANGE"is already "C_YELLOW"in the whitelist.");

		if(result == -1)
			Msg(playerid, RED, " >  An error occurred.");
	}
	else if(!strcmp(command, "remove", true) && !isnull(name))
	{
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
		gWhitelist = true;
	}
	else if(!strcmp(command, "off", true))
	{
		MsgAdmins(1, YELLOW, " >  Whitelist deactivated, anyone may join the server.");
		gWhitelist = false;
	}
	else if(!strcmp(command, "?", true))
	{
		if(IsNameInWhitelist(name))
			Msg(playerid, YELLOW, " >  That name "C_BLUE"is "C_YELLOW"in the whitelist.");

		else
			Msg(playerid, YELLOW, " >  That name "C_ORANGE"is not "C_YELLOW"in the whitelist");
	}

	return 1;
}

ACMD:up[3](playerid, params[])
{
	if(gPlayerData[playerid][ply_Admin] == 3)
	{
		if(!(gPlayerBitData[playerid] & AdminDuty))
			return 6;
	}

	new
		Float:distance = float(strval(params)),
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(playerid, x, y, z + distance);

	return 1;
}

ACMD:ford[3](playerid, params[])
{
	if(gPlayerData[playerid][ply_Admin] == 3)
	{
		if(!(gPlayerBitData[playerid] & AdminDuty))
			return 6;
	}

	new
		Float:distance = float(strval(params)),
		Float:x,
		Float:y,
		Float:z,
		Float:a;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	SetPlayerPos(playerid,
		x + (distance * floatsin(-a, degrees)),
		y + (distance * floatcos(-a, degrees)),
		z);

	return 1;
}

ACMD:goto[3](playerid, params[])
{
	if(gPlayerData[playerid][ply_Admin] == 3)
	{
		if(!(gPlayerBitData[playerid] & AdminDuty))
			return 6;
	}

	new targetid;

	if(sscanf(params, "d", targetid))
	{
		Msg(playerid, YELLOW, " >  Usage: /goto [playerid]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
	{
		Msg(playerid, RED, " >  Invalid ID");
		return 1;
	}

	TeleportPlayerToPlayer(playerid, targetid);

	return 1;
}

ACMD:get[3](playerid, params[])
{
	if(gPlayerData[playerid][ply_Admin] == 3)
	{
		if(!(gPlayerBitData[playerid] & AdminDuty))
			return 6;
	}

	new targetid;

	if(sscanf(params, "d", targetid))
	{
		Msg(playerid, YELLOW, " >  Usage: /get [playerid]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
	{
		Msg(playerid, RED, " >  Invalid ID");
		return 1;
	}

	if(gPlayerData[playerid][ply_Admin] == 1)
	{
		if(GetPlayerDist3D(playerid, targetid) > 50.0)
		{
			Msg(playerid, RED, " >  You cannot teleport someone that far away from you, move closer to them.");
			return 1;
		}
	}

	TeleportPlayerToPlayer(targetid, playerid);

	return 1;
}

TeleportPlayerToPlayer(playerid, targetid)
{
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:ang,
		Float:vx,
		Float:vy,
		Float:vz,
		interior = GetPlayerInterior(targetid);

	if(IsPlayerInAnyVehicle(targetid))
	{
		new vehicleid = GetPlayerVehicleID(targetid);

		GetVehiclePos(vehicleid, px, py, pz);
		GetVehicleZAngle(vehicleid, ang);
		GetVehicleVelocity(vehicleid, vx, vy, vz);
		pz += 2.0;
	}
	else
	{
		GetPlayerPos(targetid, px, py, pz);
		GetPlayerFacingAngle(targetid, ang);
		GetPlayerVelocity(targetid, vx, vy, vz);
		px -= floatsin(-ang, degrees);
		py -= floatcos(-ang, degrees);
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		SetVehiclePos(vehicleid, px, py, pz);
		SetVehicleZAngle(vehicleid, ang);
		SetVehicleVelocity(vehicleid, vx, vy, vz);
		LinkVehicleToInterior(vehicleid, interior);
	}
	else
	{
		SetPlayerPos(playerid, px, py, pz);
		SetPlayerFacingAngle(playerid, ang);
		SetPlayerVelocity(playerid, vx, vy, vz);
		SetPlayerInterior(playerid, interior);
	}

	MsgF(targetid, YELLOW, " >  %P"C_YELLOW" Has teleported to you", playerid);
	MsgF(playerid, YELLOW, " >  You have teleported to %P", targetid);
}

ACMD:resetpassword[3](playerid, params[])
{
	if(isnull(params))
	{
		Msg(playerid, YELLOW, " >  Usage: /resetpassword [account user-name]");
		return 1;
	}

	new buffer[129];

	WP_Hash(buffer, MAX_PASSWORD_LEN, "password");

	stmt_bind_value(gStmt_AccountSetPassword, 0, DB::TYPE_STRING, buffer, MAX_PASSWORD_LEN);
	stmt_bind_value(gStmt_AccountSetPassword, 1, DB::TYPE_STRING, params, MAX_PLAYER_NAME);
	
	if(stmt_execute(gStmt_AccountSetPassword))
		MsgF(playerid, YELLOW, " >  Password for '%s' reset.", params);

	else
		Msg(playerid, RED, " >  An error occurred.");

	return 1;
}

ACMD:deleteaccount[3](playerid, params[])
{
	if(isnull(params))
	{
		Msg(playerid, YELLOW, " >  Usage: /deleteaccount [account user-name]");
		return 1;
	}

	new ret = DeleteAccount(params);

	if(ret)
		Msg(playerid, YELLOW, " >  Account deleted.");

	else
		Msg(playerid, YELLOW, " >  That account does not exist.");

	return 1;	
}

ACMD:deleteitems[3](playerid, params[])
{
	if(gPlayerData[playerid][ply_Admin] == 3)
	{
		if(!(gPlayerBitData[playerid] & AdminDuty))
			return 6;
	}

	new Float:range;

	sscanf(params, "f", range);

	if(range == 0.0)
	{
		Msg(playerid, YELLOW, " >  Usage: /deleteitems [range]");
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

	foreach(new i : itm_Index)
	{
		GetItemPos(i, ix, iy, iz);

		if(Distance(px, py, pz, ix, iy, iz) < range)
		{
			i = DestroyItem(i);
		}
	}

	return 1;
}

ACMD:deletetents[3](playerid, params[])
{
	if(gPlayerData[playerid][ply_Admin] == 3)
	{
		if(!(gPlayerBitData[playerid] & AdminDuty))
			return 6;
	}

	new Float:range;

	sscanf(params, "f", range);

	if(range == 0.0)
	{
		Msg(playerid, YELLOW, " >  Usage: /deletetents [range]");
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

	foreach(new i : tnt_Index)
	{
		GetTentPos(i, ix, iy, iz);

		if(Distance(px, py, pz, ix, iy, iz) < range)
		{
			i = DestroyTent(i);
		}
	}

	return 1;
}

ACMD:deletedefences[3](playerid, params[])
{
	if(gPlayerData[playerid][ply_Admin] == 3)
	{
		if(!(gPlayerBitData[playerid] & AdminDuty))
			return 6;
	}

	new Float:range;

	sscanf(params, "f", range);

	if(range == 0.0)
	{
		Msg(playerid, YELLOW, " >  Usage: /deletedefences [range]");
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

	foreach(new i : def_Index)
	{
		GetDefencePos(i, ix, iy, iz);

		if(Distance(px, py, pz, ix, iy, iz) < range)
		{
			i = DestroyDefence(i);
		}
	}

	return 1;
}
ACMD:deletesigns[3](playerid, params[])
{
	if(gPlayerData[playerid][ply_Admin] == 3)
	{
		if(!(gPlayerBitData[playerid] & AdminDuty))
			return 6;
	}

	new Float:range;

	sscanf(params, "f", range);

	if(range == 0.0)
	{
		Msg(playerid, YELLOW, " >  Usage: /deletedefences [range]");
		return 1;
	}

	if(range > 100.0)
	{
		Msg(playerid, YELLOW, " >  Range limit: 100 metres");
		return 1;
	}

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	DestroySignsInRangeOfPoint(x, y, z, range);

	return 1;
}
