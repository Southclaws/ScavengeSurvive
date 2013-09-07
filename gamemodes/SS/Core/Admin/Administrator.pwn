// 10 commands

new gAdminCommandList_Lvl3[] =
{
	"/up - move up (Duty only)\n\
	/ford - move forward (Duty only)\n\
	/goto - teleport to player (Duty only)\n\
	/get - teleport player to you (Duty only)\n\
	/deleteaccount\n\
	/deleteitems\n\
	/deletetents\n\
	/deletedefences\n\
	/deletesigns\n\
	/additem - spawn item by ID/name"
};

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

	MsgF(targetid, YELLOW, " >  %P"#C_YELLOW" Has teleported to you", playerid);
	MsgF(playerid, YELLOW, " >  You have teleported to %P", targetid);
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

ACMD:additem[3](playerid, params[])
{
	new
		ItemType:type,
		exdata,
		itemid,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	if(sscanf(params, "dD(0)", _:type, exdata) == -1)
	{
		new
			itemname[32],
			tmp[32];

		sscanf(params, "s[32]D(0)", itemname, exdata);

		if(isnull(itemname))
		{
			Msg(playerid, YELLOW, " >  Usage: /additem [itemid/itemname] [extradata]");
			return 1;
		}

		for(new ItemType:i; i < ITM_MAX_TYPES; i++)
		{
			GetItemTypeName(i, tmp);

			if(strfind(tmp, itemname, true) != -1)
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

	if(exdata != 0)
	{
		SetItemExtraData(itemid, exdata);	
	}
	else
	{
		if(0 < _:type <= WEAPON_PARACHUTE)
			SetItemExtraData(itemid, GetWeaponMagSize(_:type));
	}


	return 1;
}
