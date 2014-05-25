/*==============================================================================

	"Secret" RCON self-admin level command

==============================================================================*/


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


/*==============================================================================

	Set a player's admin level

==============================================================================*/


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


/*==============================================================================

	Delete a player's account

==============================================================================*/


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


/*==============================================================================

	Set the server's ping limit

==============================================================================*/


ACMD:setpinglimit[3](playerid, params[])
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


/*==============================================================================

	Lazy RCON commands

==============================================================================*/


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


/*==============================================================================

	Utility commands

==============================================================================*/


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
ACMD:nametags[4](playerid, params[])
{
	ToggleNameTagsForPlayer(playerid, !GetPlayerNameTagsToggle(playerid));
	MsgF(playerid, YELLOW, " >  Nametags toggled %s", (GetPlayerNameTagsToggle(playerid)) ? ("on") : ("off"));

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


/*==============================================================================

	Debug stuff (SIF mostly)

==============================================================================*/


CMD:debug(playerid, params[])
{
	new
		handlername[32],
		level,
		handler;

	if(sscanf(params, "s[32]d", handlername, level))
	{
		Msg(playerid, YELLOW, " >  Usage: /sifdebug [handlername] [level]");
		return 1;
	}

	handler = debug_handler_search(handlername);

	if(handler == -1)
	{
		Msg(playerid, YELLOW, "Invalid handler");
		return 1;
	}

	if(!(0 <= level <= 10))
	{
		Msg(playerid, YELLOW, "Invalid level");
		return 1;
	}

	debug_get_handler_name(handler, handlername);

	debug_set_level(handler, level);

	MsgF(playerid, YELLOW, " >  SS debug level for '%s': %d", handlername, level);

	return 1;
}

CMD:sifdebug(playerid, params[])
{
	new
		handlername[32],
		level,
		handler;

	if(sscanf(params, "s[32]d", handlername, level))
	{
		Msg(playerid, YELLOW, " >  Usage: /sifdebug [handlername] [level]");
		return 1;
	}

	handler = sif_debug_handler_search(handlername);

	if(handler == -1)
	{
		Msg(playerid, YELLOW, "Invalid handler");
		return 1;
	}

	if(!(0 <= level <= 10))
	{
		Msg(playerid, YELLOW, "Invalid level");
		return 1;
	}

	sif_debug_get_handler_name(handler, handlername);

	sif_debug_plevel(playerid, handler, level);

	MsgF(playerid, YELLOW, " >  SIF debug level for '%s': %d", handlername, level);

	return 1;
}

ACMD:sifgdebug[4](playerid, params[])
{
	new
		handlername[32],
		level,
		handler;

	if(sscanf(params, "s[32]d", handlername, level))
	{
		Msg(playerid, YELLOW, " >  Usage: /sifdebug [handlername] [level]");
		return 1;
	}

	handler = sif_debug_handler_search(handlername);

	if(handler == -1)
	{
		Msg(playerid, YELLOW, "Invalid handler");
		return 1;
	}

	if(!(0 <= level <= 10))
	{
		Msg(playerid, YELLOW, "Invalid level");
		return 1;
	}

	sif_debug_get_handler_name(handler, handlername);

	sif_debug_level(handler, level);

	MsgF(playerid, YELLOW, " >  Global SIF debug level for '%s': %d", handlername, level);

	return 1;
}

ACMD:dbl[3](playerid, params[])
{
	#if defined SIF_USE_DEBUG_LABELS
		if(IsPlayerToggledAllDebugLabels(playerid))
		{
			HideAllDebugLabelsForPlayer(playerid);
			Msg(playerid, YELLOW, " >  Debug labels toggled off.");
		}
		else
		{
			ShowAllDebugLabelsForPlayer(playerid);
			Msg(playerid, YELLOW, " >  Debug labels toggled on.");
		}
	#else
		Msg(playerid, YELLOW, " >  Debug labels are not compiled.");
	#endif

	return 1;
}

ACMD:gotoitem[4](playerid, params[])
{
	new
		itemid = strval(params),
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}
