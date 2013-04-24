static tick_AdminDuty[MAX_PLAYERS];

ACMD:duty[1](playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
	{
		Msg(playerid, YELLOW, " >  You cannot do that while spectating.");
		return 1;
	}

	if(bPlayerGameSettings[playerid] & AdminDuty)
	{
		f:bPlayerGameSettings[playerid]<AdminDuty>;

		SetPlayerPos(playerid,
			gPlayerData[playerid][ply_posX],
			gPlayerData[playerid][ply_posY],
			gPlayerData[playerid][ply_posZ]);

		RemovePlayerWeapon(playerid);
		LoadPlayerInventory(playerid);
		LoadPlayerChar(playerid);

		SetPlayerClothes(playerid, gPlayerData[playerid][ply_Skin]);

		tick_AdminDuty[playerid] = tickcount();
	}
	else
	{
		if(tickcount() - tick_AdminDuty[playerid] < 10000)
		{
			Msg(playerid, YELLOW, " >  Please don't use the duty ability that frequently.");
			return 1;
		}

		SavePlayerData(playerid);

		t:bPlayerGameSettings[playerid]<AdminDuty>;

		GetPlayerPos(playerid,
			gPlayerData[playerid][ply_posX],
			gPlayerData[playerid][ply_posY],
			gPlayerData[playerid][ply_posZ]);

		DestroyItem(GetPlayerItem(playerid));
		RemovePlayerHolsterWeapon(playerid);
		RemovePlayerWeapon(playerid);

		for(new i, j = INV_MAX_SLOTS - GetInventoryFreeSlots(playerid); i < j; i++)
		{
			DestroyItem(GetInventorySlotItem(playerid, i));
		}
		
		if(IsValidItem(GetPlayerBackpackItem(playerid)))
		{
			RemovePlayerBackpack(playerid);
		}

		if(IsValidItem(GetPlayerHat(playerid)))
		{
			RemovePlayerHat(playerid);
		}

		if(bPlayerGameSettings[playerid] & Gender)
			SetPlayerSkin(playerid, 217);

		else
			SetPlayerSkin(playerid, 211);
	}
	return 1;
}

ACMD:goto[3](playerid, params[])
{
	new targetid;

	if(!(bPlayerGameSettings[playerid] & AdminDuty))
	{
		Msg(playerid, RED, " >  You can only use that command while on admin duty.");
		return 1;
	}

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

	if(gPlayerData[targetid][ply_Admin] > 0)
	{
		Msg(playerid, RED, " >  You cannot teleport to another administrator.");
		return 1;
	}

	TeleportPlayerToPlayer(playerid, targetid);

	return 1;
}

ACMD:get[1](playerid, params[])
{
	new targetid;

	if(!(bPlayerGameSettings[playerid] & AdminDuty))
	{
		Msg(playerid, RED, " >  You can only use that command while on admin duty.");
		return 1;
	}

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

	if(gPlayerData[targetid][ply_Admin] > 0)
	{
		Msg(playerid, RED, " >  You cannot teleport another administrator.");
		return 1;
	}

	if(GetPlayerDist3D(playerid, targetid) > 40.0)
	{
		Msg(playerid, RED, " >  You cannot teleport someone that far away to your position, move closer to them.");
		return 1;
	}

	TeleportPlayerToPlayer(targetid, playerid);

	return 1;
}

ACMD:spec[2](playerid, params[])
{
	if(!(bPlayerGameSettings[playerid] & AdminDuty))
	{
		Msg(playerid, RED, " >  You can only use that command while on admin duty.");
		return 1;
	}

	if(isnull(params))
	{
		TogglePlayerSpectating(playerid, false);
		f:bPlayerGameSettings[playerid]<Spectating>;
	}
	else
	{
		new id = strval(params);

		if(IsPlayerConnected(id) && id != playerid)
		{
			TogglePlayerSpectating(playerid, true);

			if(IsPlayerInAnyVehicle(id))
				PlayerSpectateVehicle(playerid, GetPlayerVehicleID(id));

			else
				PlayerSpectatePlayer(playerid, id);

			t:bPlayerGameSettings[playerid]<Spectating>;
		}
	}

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
