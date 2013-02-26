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
		t:bPlayerGameSettings[playerid]<AdminDuty>;

		SavePlayerData(playerid);

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
		Msg(playerid, RED, " >  You cannot teleport to another administrator.");
		return 1;
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


// Hooks to disable the use of items while on duty.


public OnPlayerPickUpItem(playerid, itemid)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 1;

	return CallLocalFunction("duty_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem duty_OnPlayerPickUpItem
forward duty_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerGiveItem(playerid, targetid, itemid)
{
	if(GetPlayerSpecialAction(targetid) == SPECIAL_ACTION_CUFFED)
		return 1;

	return CallLocalFunction("duty_OnPlayerGiveItem", "ddd", playerid, targetid, itemid);
}
#if defined _ALS_OnPlayerGiveItem
	#undef OnPlayerGiveItem
#else
	#define _ALS_OnPlayerGiveItem
#endif
#define OnPlayerGiveItem duty_OnPlayerGiveItem
forward duty_OnPlayerGiveItem(playerid, targetid, itemid);

public OnPlayerTakeFromContainer(playerid, containerid, slotid)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 1;

	return CallLocalFunction("duty_OnPlayerTakeFromContainer", "ddd", playerid, containerid, slotid);
}
#if defined _ALS_OnPlayerTakeFromContainer
	#undef OnPlayerTakeFromContainer
#else
	#define _ALS_OnPlayerTakeFromContainer
#endif
#define OnPlayerTakeFromContainer duty_OnPlayerTakeFromContainer
forward duty_OnPlayerTakeFromContainer(playerid, containerid, slotid);

public OnPlayerOpenInventory(playerid)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 1;

	return CallLocalFunction("duty_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory duty_OnPlayerOpenInventory
forward duty_OnPlayerOpenInventory(playerid);

public OnPlayerOpenContainer(playerid, containerid)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 1;

	return CallLocalFunction("duty_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer duty_OnPlayerOpenContainer
forward duty_OnPlayerOpenContainer(playerid, containerid);
