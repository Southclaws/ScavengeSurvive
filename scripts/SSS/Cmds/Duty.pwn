ACMD:duty[1](playerid, params[])
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
	{
		f:bPlayerGameSettings[playerid]<AdminDuty>;

		LoadPlayerInventory(playerid);

		SetPlayerPos(playerid,
			gPlayerData[playerid][ply_posX],
			gPlayerData[playerid][ply_posY],
			gPlayerData[playerid][ply_posZ]);

		SetPlayerClothes(playerid, gPlayerData[playerid][ply_Skin]);
	}
	else
	{
		SavePlayerData(playerid);

		t:bPlayerGameSettings[playerid]<AdminDuty>;

		GetPlayerPos(playerid,
			gPlayerData[playerid][ply_posX],
			gPlayerData[playerid][ply_posY],
			gPlayerData[playerid][ply_posZ]);

		ResetPlayerWeapons(playerid);
		RemoveCurrentItem(playerid);
		RemovePlayerHolsterWeapon(playerid);

		for(new i; i < INV_MAX_SLOTS; i++)
		{
			if(IsValidItem(GetInventorySlotItem(playerid, 0)))
				RemoveItemFromInventory(playerid, 0);
		}

		if(IsValidItem(GetPlayerBackpackItem(playerid)))
		{
			RemovePlayerBackpack(playerid);
		}

		if(IsValidItem(GetPlayerHat(playerid)))
		{
			RemovePlayerHat(playerid);
		}

		gPlayerArmedWeapon[playerid] = 0;

		if(bPlayerGameSettings[playerid] & Gender)
			SetPlayerSkin(playerid, 217);

		else
			SetPlayerSkin(playerid, 211);
	}
	return 1;
}

ACMD:goto[1](playerid, params[])
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

	if(pAdmin(targetid) > 0)
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

	if(pAdmin(targetid) > 0)
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

ACMD:spec[3](playerid, params[])
{
	if(!(bPlayerGameSettings[playerid] & AdminDuty))
	{
		Msg(playerid, RED, " >  You can only use that command while on admin duty.");
		return 1;
	}

	if(isnull(params))
	{
		TogglePlayerSpectating(playerid, false);
	}
	else
	{
		new id = strval(params);

		if(IsPlayerConnected(id) && id != playerid)
		{
			TogglePlayerSpectating(playerid, true);
			PlayerSpectatePlayer(playerid, id);
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
