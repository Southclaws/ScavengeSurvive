/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


/*==============================================================================

	Lazy RCON commands

==============================================================================*/


ACMD:gamename[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid,YELLOW," >  Usage: /gamename [name]");

	SetGameModeText(params);
	ChatMsg(playerid, YELLOW, " >  GameMode name set to "C_BLUE"%s", params);

	return 1;
}

ACMD:hostname[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid,YELLOW," >  Usage: /hostname [name]");

	new str[74];
	format(str, sizeof(str), "hostname %s", params);
	SendRconCommand(str);

	ChatMsg(playerid, YELLOW, " >  Hostname set to "C_BLUE"%s", params);

	return 1;
}

ACMD:mapname[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid,YELLOW," >  Usage: /mapname [name]");

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
		return ChatMsg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "loadfs %s", params);
	SendRconCommand(str);
	ChatMsg(playerid, YELLOW, " >  Loading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:reloadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "reloadfs %s", params);
	SendRconCommand(str);
	ChatMsg(playerid, YELLOW, " >  Reloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:unloadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "unloadfs %s", params);
	SendRconCommand(str);
	ChatMsg(playerid, YELLOW, " >  Unloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}


/*==============================================================================

	Testing stuff

==============================================================================*/


ACMD:hud[5](playerid, params[])
{
	if(IsPlayerHudOn(playerid))
	{
		TogglePlayerHungerBar(playerid, false);
		ToggleVersionInfo(playerid, false);
		HideWatch(playerid);
		TogglePlayerHUD(playerid, false);
	}
	else
	{
		TogglePlayerHungerBar(playerid, true);
		ToggleVersionInfo(playerid, true);
		ShowWatch(playerid);
		TogglePlayerHUD(playerid, true);
	}
}

ACMD:nametags[5](playerid, params[])
{
	ToggleNameTagsForPlayer(playerid, !GetPlayerNameTagsToggle(playerid));
	ChatMsg(playerid, YELLOW, " >  Nametags toggled %s", (GetPlayerNameTagsToggle(playerid)) ? ("on") : ("off"));

	return 1;
}

ACMD:gotoitem[4](playerid, params[])
{
	new
		Item:itemid = Item:strval(params),
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}

ACMD:addloot[5](playerid, params[])
{
	new
		lootindexname[MAX_LOOT_INDEX_NAME],
		lootindex,
		size;

	if(sscanf(params, "s[32]d", lootindexname, size))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /addloot [indexname] [size]");
		return 1;
	}

	lootindex = GetLootIndexFromName(lootindexname);

	if(lootindex == -1)
	{
		ChatMsg(playerid, RED, " >  Loot index name invalid!");
		return 1;
	}

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	CreateLootItem(lootindex, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
	//CreateStaticLootSpawn(x, y, z - 0.8568, lootindex, 100, size, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));

	return 1;
}

ACMD:setitemhp[5](playerid, params[])
{
	new
		Item:itemid,
		hitpoints;

	if(sscanf(params, "dd", _:itemid, hitpoints))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /setitemhp [itemid] [hitpoints]");
		return 1;
	}

	SetItemHitPoints(itemid, hitpoints);

	return 1;
}


/*==============================================================================

	Dev-"cheats"

==============================================================================*/


ACMD:vw[5](playerid, params[])
{
	if(isnull(params))
		ChatMsg(playerid, YELLOW, "Current VW: %d", GetPlayerVirtualWorld(playerid));

	else
		SetPlayerVirtualWorld(playerid, strval(params));

	return 1;
}

ACMD:iw[5](playerid, params[])
{
	if(isnull(params))
		ChatMsg(playerid, YELLOW, "Current INT: %d", GetPlayerInterior(playerid));

	else
		SetPlayerInterior(playerid, strval(params));

	return 1;
}

ACMD:health[5](playerid, params[])
{
	new Float:value;

	if(sscanf(params, "f", value))
	{
		ChatMsg(playerid, YELLOW, "Current health %f", GetPlayerHP(playerid));
		return 1;
	}

	SetPlayerHP(playerid, value);
	ChatMsg(playerid, YELLOW, "Set health to %f", value);

	return 1;
}

ACMD:food[5](playerid, params[])
{
	new Float:value;

	if(sscanf(params, "f", value))
	{
		ChatMsg(playerid, YELLOW, "Current food %f", GetPlayerFP(playerid));
		return 1;
	}

	SetPlayerFP(playerid, value);
	ChatMsg(playerid, YELLOW, "Set food to %f", value);

	return 1;
}

ACMD:bleed[5](playerid, params[])
{
	new Float:value;

	if(sscanf(params, "f", value))
	{
		GetPlayerBleedRate(playerid, value);
		ChatMsg(playerid, YELLOW, "Current bleed rate %f", value);
		return 1;
	}

	SetPlayerBleedRate(playerid, value);
	ChatMsg(playerid, YELLOW, "Set bleed rate to %f", value);

	return 1;
}

ACMD:knockout[5](playerid, params[])
{
	KnockOutPlayer(playerid, strval(params));
	ChatMsg(playerid, YELLOW, "Set knockout time to %d", strval(params));
	return 1;
}

ACMD:showdamage[5](playerid, params[])
{
	new Float:bleedrate;
	GetPlayerBleedRate(playerid, bleedrate);
	ShowActionText(playerid, sprintf("bleedrate: %f~n~wounds: %d", bleedrate, GetPlayerWounds(playerid)), 5000);
	return 1;
}

ACMD:removewounds[5](playerid, params[])
{
	RemovePlayerWounds(playerid, strval(params));
	ChatMsg(playerid, YELLOW, "Removed %d wounds.", strval(params));
	return 1;
}

ACMD:wc[5](playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	WeaponsCacheDrop(x, y, z - 0.8);
	SetPlayerPos(playerid, x, y, z + 1.0);

	return 1;
}

static cloneid[MAX_PLAYERS] = {INVALID_ACTOR_ID, ...};

ACMD:clone[5](playerid, params[])
{
	if(cloneid[playerid] == INVALID_ACTOR_ID)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		cloneid[playerid] = CreateActor(GetPlayerSkin(playerid), x, y, z, a);
	}
	else
	{
		DestroyActor(cloneid[playerid]);
		cloneid[playerid] = INVALID_ACTOR_ID;
	}

	return 1;
}

ACMD:setskill[5](playerid, params[])
{
	new
		skill[32],
		Float:amount;

	sscanf(params, "s[32]f", skill, amount);

	PlayerGainSkillExperience(playerid, skill, amount);

	return 1;
}