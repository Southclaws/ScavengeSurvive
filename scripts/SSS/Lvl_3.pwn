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

ACMD:setvip[3](playerid, params[])
{
	new id, toggle;

	if(sscanf(params, "dd", id, toggle))
		return Msg(playerid, YELLOW, " >  Usage: /setvip [playerid]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	if(toggle)
	{
		t:bPlayerGameSettings[id]<IsVip>;
		MsgF(playerid, YELLOW, " >  You gave VIP status to %P", id);
	}
	else
	{
		f:bPlayerGameSettings[id]<IsVip>;
		MsgF(playerid, YELLOW, " >  You removed VIP status from %P", id);
	}
	return 1;
}
ACMD:view[3](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /view [playerid]");

	if(pAdmin(id) >= pAdmin(playerid) && playerid != id)
		return 3;

	SetPlayerMarkerForPlayer(playerid, id, ColourData[id][colour_value]);

	return 1;
}
ACMD:gamename[3](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /gamename [name]");

	SetGameModeText(params);
	MsgF(playerid, YELLOW, " >  GameMode name set to "#C_BLUE"%s", params);

	return 1;
}
ACMD:hostname[3](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /hostname [name]");

	new str[74];
	format(str, sizeof(str), "hostname %s", params);
	SendRconCommand(str);

	MsgF(playerid, YELLOW, " >  Hostname set to "#C_BLUE"%s", params);

	return 1;
}
ACMD:mapname[3](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /mapname [name]");

	SetMapName(params);

	return 1;
}
ACMD:gmx[3](playerid, params[])
{
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, " ");
	MsgAll(BLUE, HORIZONTAL_RULE);
	MsgAll(YELLOW, " >  The Server Is Restarting, Please Wait...");
	MsgAll(BLUE, HORIZONTAL_RULE);

	RestartGamemode();
	return 1;
}
ACMD:loadfs[3](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "loadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Loading Filterscript: "#C_BLUE"'%s'", params);

	return 1;
}
ACMD:reloadfs[3](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "reloadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Reloading Filterscript: "#C_BLUE"'%s'", params);

	return 1;
}
ACMD:unloadfs[3](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "unloadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Unloading Filterscript: "#C_BLUE"'%s'", params);

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

	sscanf(params, "dD(0)", _:type, exdata);

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
			SetItemExtraData(itemid, WepData[_:type][MagSize]);
	}

	return 1;
}
