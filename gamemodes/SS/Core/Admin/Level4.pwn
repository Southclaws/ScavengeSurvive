CMD:adminlvl(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return 0;

	new level;

	if(sscanf(params, "d", level))
		return Msg(playerid, YELLOW, " >  Usage: /adminlvl [level]");

	if(!SetPlayerAdminLevel(playerid, level))
		return Msg(playerid, RED, " >  Admin level must be equal to or between 0 and 4");


	MsgF(playerid, YELLOW, " >  Admin Level Secretly Set To: %d", level);

	return 1;
}

//==============================================================================Player

ACMD:setadmin[4](playerid, params[])
{
	new
		id,
		name[24],
		level;

	if(!sscanf(params, "dd", id, level))
	{
		if(playerid == id)
			return Msg(playerid, RED, " >  You cannot set your own level");

		if(!IsPlayerConnected(id))
			return 4;

		if(!SetPlayerAdminLevel(id, level))
			return Msg(playerid, RED, " >  Admin level must be equal to or between 0 and 3");

		MsgF(playerid, YELLOW, " >  You made %P"C_YELLOW" a Level %d Admin", id, level);
		MsgF(id, YELLOW, " >  %P"C_YELLOW" Made you a Level %d Admin", playerid, level);
	}
	else if(!sscanf(params, "s[24]d", name, level))
	{
		if(!strcmp(name, gPlayerName[playerid]))
			return Msg(playerid, RED, " >  You cannot set your own level");

		UpdateAdmin(name, level);

		MsgF(playerid, YELLOW, " >  You set %s to admin level %d.", name, level);
	}
	else
	{
		Msg(playerid, YELLOW, " >  Usage: /setadmin [playerid] [level]");
		return 1;
	}

	return 1;
}

ACMD:setpinglimit[4](playerid, params[])
{
	new val = strval(params);

	if(!(100 < val < 1000))
	{
		Msg(playerid, YELLOW, " >  Ping limit must be between 100 and 1000");
		return 1;
	}

	gPingLimit = strval(params);
	MsgF(playerid, YELLOW, " >  Ping limit has been updated to %d.", gPingLimit);

	return 1;
}

ACMD:gamename[4](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /gamename [name]");

	SetGameModeText(params);
	MsgF(playerid, YELLOW, " >  GameMode name set to "C_BLUE"%s", params);

	return 1;
}

ACMD:hostname[4](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /hostname [name]");

	new str[74];
	format(str, sizeof(str), "hostname %s", params);
	SendRconCommand(str);

	MsgF(playerid, YELLOW, " >  Hostname set to "C_BLUE"%s", params);

	return 1;
}

ACMD:mapname[4](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /mapname [name]");

	new str[74];
	format(str, sizeof(str), "mapname %s", params);
	SendRconCommand(str);

	return 1;
}

ACMD:gmx[4](playerid, params[])
{
	RestartGamemode();
	return 1;
}

ACMD:loadfs[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "loadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Loading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:reloadfs[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "reloadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Reloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:unloadfs[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "unloadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Unloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

//==============================================================================Utilities

ACMD:sp[4](playerid, params[])
{
	new posname[128];

	if(!sscanf(params, "s[128]", posname))
	{
		new
			string[128],
			Float:x,
			Float:y,
			Float:z,
			Float:r,
			INI:ini = INI_Open("savedpositions.txt");

		if(IsPlayerInAnyVehicle(playerid))
		{
			new vehicleid = GetPlayerVehicleID(playerid);
			GetVehiclePos(vehicleid, x, y, z);
			GetVehicleZAngle(vehicleid, r);
		}
		else
		{
			GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, r);
		}

		format(string, 128, "%.4f, %.4f, %.4f, %.4f", x, y, z, r);

		INI_WriteString(ini, posname, string);
		INI_Close(ini);

		MsgF(playerid, ORANGE, " >  %s = %s "C_BLUE"Saved!", posname, string);
	}
	else
	{
		Msg(playerid, YELLOW, " >  Usage: /sp [position name]");
	}
 
	return 1;
}

ACMD:sound[4](playerid, params[])
{
	new
		soundid = strval(params),
		Float:x,
		Float:y,
		Float:z;

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, 20.0, x, y, z))
			PlayerPlaySound(i, soundid, x, y, z);
	}
	
	return 1;
}

ACMD:anim[4](playerid, params[])
{
	new
		lib[20],
		anim[30],
		loop,
		Float:speed;

	if(sscanf(params, "s[20]s[30]D(0)F(4.0)", lib, anim, loop, speed))
	{
		Msg(playerid, YELLOW, "Usage: /anim LIB ANIM LOOP SPEED");
		return 1;
	}
	
	ApplyAnimation(playerid, lib, anim, speed, loop, 1, 1, 0, 0, 1);

	return 1;
}

ACMD:gotopos[4](playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	if(sscanf(params, "fff", x, y, z) && sscanf(params, "p<,>fff", x, y, z))
		return Msg(playerid, YELLOW, "Usage: /gotopos x, y, z (With or without commas)");

	MsgF(playerid, YELLOW, " >  Teleported to %f, %f, %f", x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}

ACMD:getanim[4](playerid, params[])
{
	new
		animlib[32],
		animname[32],
		idx = GetPlayerAnimationIndex(playerid);

	GetAnimationName(idx, animlib, 32, animname, 32);
	MsgF(playerid, YELLOW, "Lib: %s Name: %s Idx: %d", animlib, animname, idx);

	return 1;
}

ACMD:visob[4](playerid, params[])
{
	MsgF(playerid, YELLOW, "Current Visible Objects: %d", Streamer_CountVisibleItems(playerid, STREAMER_TYPE_OBJECT));
	return 1;
}

ACMD:ActionText[4](playerid, params[])
{
	ShowActionText(playerid, "This is a message~n~This is a new line~n~~g~h~r~e~b~l~y~l~p~o ~g~w~r~o~y~r~b~l~p~d~y~!", 3000);
	return 1;
}

ACMD:decam[4](playerid, params[])
{
	new Float:cx, Float:cy, Float:cz, Float:px, Float:py, Float:pz;
	GetPlayerCameraPos(playerid, cx, cy, cz);
	GetPlayerPos(playerid, px, py, pz);
	SetPlayerCameraPos(playerid, cx, cy, cz);
	SetPlayerCameraLookAt(playerid, px, py, pz);
	return 1;
}

ACMD:recam[1](playerid, params[])
{
	SetCameraBehindPlayer(playerid);
	return 1;
}

ACMD:cob[4](playerid, params[])
{
	new o;
	if(!sscanf(params,"d",o))
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		CreateObject(o, x, y, z, 0, 0, 0);
	}
	return 1;
}

//==============================================================================World Movement Commands

ACMD:setvw[4](playerid, params[])
{
	SetPlayerVirtualWorld(playerid, strval(params));
	return 1;
}

ACMD:setint[4](playerid, params[])
{
	SetPlayerInterior(playerid, strval(params));
	return 1;
}

ACMD:hud[4](playerid, params[])
{
	if(GetPlayerBitFlag(playerid, ShowHUD))
	{
		PlayerTextDrawHide(playerid, HungerBarBackground[playerid]);
		PlayerTextDrawHide(playerid, HungerBarForeground[playerid]);
		TextDrawHideForPlayer(playerid, Branding);
		HideWatch(playerid);
		SetPlayerBitFlag(playerid, ShowHUD, false);
	}
	else
	{
		PlayerTextDrawShow(playerid, HungerBarBackground[playerid]);
		PlayerTextDrawShow(playerid, HungerBarForeground[playerid]);
		TextDrawShowForPlayer(playerid, Branding);
		ShowWatch(playerid);
		SetPlayerBitFlag(playerid, ShowHUD, true);
	}
}

ACMD:vowner[4](playerid, params[])
{
	new
		vehicleid = GetPlayerVehicleID(playerid),
		owner[MAX_PLAYER_NAME];

	if(!IsValidVehicleID(vehicleid))
	{
		Msg(playerid, RED, " >  You are not in a vehicle.");
		return 1;
	}

	GetVehicleOwner(vehicleid, owner);

	MsgF(playerid, YELLOW, " >  Vehicle owner: '%s'", owner);

	return 1;
}

ACMD:vdelete[4](playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicleID(vehicleid))
		vehicleid = strval(params);

	if(!IsValidVehicleID(vehicleid))
	{
		Msg(playerid, RED, " >  You are not in a vehicle.");
		return 1;
	}

	RemoveVehicleFileByID(vehicleid);
	DestroyVehicle(vehicleid, 0);

	return 1;
}

ACMD:vrespawn[4](playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicleID(vehicleid))
	{
		Msg(playerid, RED, " >  You are not in a vehicle.");
		return 1;
	}

	RespawnVehicle(vehicleid);

	return 1;
}

ACMD:vreset[4](playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicleID(vehicleid))
	{
		Msg(playerid, RED, " >  You are not in a vehicle.");
		return 1;
	}

	ResetVehicle(vehicleid);

	return 1;
}

ACMD:weather[4](playerid, params[])
{
	if(strlen(params) > 2)
	{
		for(new i; i < sizeof(WeatherData); i++)
		{
			if(strfind(WeatherData[i][weather_name], params, true) != -1)
			{
				foreach(new j : Player)
				{
					SetPlayerWeather(j, i);
				}

				gWeatherID = i;
				MsgAdminsF(GetPlayerAdminLevel(playerid), YELLOW, " >  Weather set to "C_BLUE"%s", WeatherData[i]);

				return 1;
			}
		}
		Msg(playerid, RED, " >  Invalid weather!");
	}

	return 1;
}

ACMD:ann[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /ann [Message]");

	GameTextForAll(params, 5000, 5);

	return 1;
}

ACMD:additem[4](playerid, params[])
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

ACMD:createvehicle[4](playerid, params[])
{
	new
		model,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		vehicleid;

	model = strval(params);

	if(!(400 <= model < 612))
		return 1;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	vehicleid = CreateNewVehicle(model, x, y, z, r);
	SetVehicleFuel(vehicleid, 100000.0);
	SetVehicleHealth(vehicleid, 990.0);

	return 1;
}

ACMD:pos[4](playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	MsgF(playerid, YELLOW, " >  Position: "C_BLUE"%.2f, %.2f, %.2f", x, y, z);

	return 1;
}

ACMD:dropall[4](playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	DropItems(playerid, x, y, z, r);

	return 1;
}

ACMD:vlock[4](playerid, params[])
{
	new
		vehicleid,
		status;

	if(sscanf(params, "dd", vehicleid, status))
	{
		Msg(playerid, YELLOW, " >  Usage: /vlock [vehicleid] [lock status: 0/1]");
		return 1;
	}

	if(!IsValidVehicleID(vehicleid))
	{
		Msg(playerid, YELLOW, " >  Invalid vehicle ID");
		return 1;
	}

	SetVehicleExternalLock(vehicleid, status);

	return 1;
}

CMD:sifdebug(playerid, params[])
{
	new level = strval(params);

	if(!(0 <= level <= 10))
	{
		Msg(playerid, -1, "Invalid level");
		return 1;
	}

	sif_debug_plevel(playerid, level);

	MsgF(playerid, -1, "SIF debug level: %d", level);

	return 1;
}

ACMD:sifgdebug[4](playerid, params[])
{
	new level = strval(params);

	if(!(0 <= level <= 10))
	{
		Msg(playerid, -1, "Invalid level");
		return 1;
	}

	sif_debug_level(playerid, level);

	MsgF(playerid, -1, "Global SIF debug level: %d", level);

	return 1;
}
