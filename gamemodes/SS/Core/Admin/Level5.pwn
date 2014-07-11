/*==============================================================================

	Lazy RCON commands

==============================================================================*/


ACMD:gamename[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /gamename [name]");

	SetGameModeText(params);
	MsgF(playerid, YELLOW, " >  GameMode name set to "C_BLUE"%s", params);

	return 1;
}

ACMD:hostname[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /hostname [name]");

	new str[74];
	format(str, sizeof(str), "hostname %s", params);
	SendRconCommand(str);

	MsgF(playerid, YELLOW, " >  Hostname set to "C_BLUE"%s", params);

	return 1;
}

ACMD:mapname[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /mapname [name]");

	new str[74];
	format(str, sizeof(str), "mapname %s", params);
	SendRconCommand(str);

	return 1;
}

ACMD:gmx[5](playerid, params[])
{
	RestartGamemode();
	return 1;
}

ACMD:loadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "loadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Loading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:reloadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "reloadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Reloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:unloadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "unloadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Unloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:hud[5](playerid, params[])
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

ACMD:nametags[5](playerid, params[])
{
	ToggleNameTagsForPlayer(playerid, !GetPlayerNameTagsToggle(playerid));
	MsgF(playerid, YELLOW, " >  Nametags toggled %s", (GetPlayerNameTagsToggle(playerid)) ? ("on") : ("off"));

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

ACMD:gotodef[4](playerid, params[])
{
	new id = strval(params);

	if(!IsValidDefence(id))
	{
		MsgF(playerid, YELLOW, " >  Invalid ID");
		return 1;
	}

	new
		Float:x,
		Float:y,
		Float:z;

	GetDefencePos(id, x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}
