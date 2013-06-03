// 4 commands

new gAdminCommandList_Lvl3[] =
{
	"/up - move up (Duty only)\n\
	/ford - move forward (Duty only)\n\
	/goto - teleport to a player (Duty only)\n\
	/get - teleport a player to you (Duty only)\n"
};

ACMD:up[3](playerid, params[])
{
	if(gPlayerData[playerid][ply_Admin] == 3)
	{
		if(!(bPlayerGameSettings[playerid] & AdminDuty))
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
		if(!(bPlayerGameSettings[playerid] & AdminDuty))
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
		if(!(bPlayerGameSettings[playerid] & AdminDuty))
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
		if(!(bPlayerGameSettings[playerid] & AdminDuty))
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

	MsgF(targetid, YELLOW, " >  %P"#C_YELLOW" Has teleported to you", playerid);
	MsgF(playerid, YELLOW, " >  You have teleported to %P", targetid);
}
