#include <YSI\y_hooks>


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Admin/Level4'...");

	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/restart - restart the server\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/setadmin - set a player's staff level\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/setpinglimit - set ping limit\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/weather - set weather\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/debug - activate a debug handler\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/sifdebug - activate SIF debug\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/sifgdebug - activate SIF global debug\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/dbl - toggle debug labels\n");
}


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

	"Secret" RCON self-admin level command

==============================================================================*/


ACMD:restart[4](playerid, params[])
{
	new duration;

	if(sscanf(params, "d", duration))
	{
		Msg(playerid, YELLOW, " >  Usage: /restart [seconds] - Always give players 5 or 10 minutes to prepare.");
		return 1;
	}

	MsgF(playerid, YELLOW, " >  Restarting the server in "C_BLUE"%02d:%02d"C_YELLOW".", duration / 60, duration % 60);
	SetRestart(duration);

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

	Utility commands

==============================================================================*/



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
