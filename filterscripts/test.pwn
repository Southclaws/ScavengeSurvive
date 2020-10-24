/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <streamer>


public OnFilterScriptInit()
{
}

CMD:mouse(playerid, params[])
{
	SelectTextDraw(playerid, -1);
	return 1;
}

CMD:sound(playerid, params[])
{
	PlayerPlaySound(playerid, strval(params), 0.0, 0.0, 0.0);
	return 1;
}

CMD:cmode(playerid, params[])
{
	new mode = GetPlayerCameraMode(playerid);

	new str[128];
	format(str, 128, "Cam mode: %d", mode);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:rt(playerid, params[])
{
	RemoveBuildingForPlayer(playerid, 713, -1679.5469, 657.7500, 17.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 731, -1653.7422, 657.9922, 9.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 733, -1664.4531, 672.0000, 13.7109, 0.25);
	RemoveBuildingForPlayer(playerid, 715, -1673.3828, 638.9531, 25.3359, 0.25);
	return 1;
}

CMD:skin(playerid, params[])
{
	SetPlayerSkin(playerid, strval(params));
	return 1;
}

CMD:carry(playerid, params[])
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	return 1;
}

CMD:car(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);
	CreateVehicle(strval(params), x, y, z, 0.0, -1, -1, 100);
	return 1;
}

CMD:wep(playerid, params[])
{
	new str[128];
	new wep = GetPlayerWeapon(playerid);

	format(str, 128, "Weapon: %d", wep);

	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:tp(playerid, params[])
{
	new id1, id2;
	sscanf(params, "dd", id1, id2);

	new
		Float:x,
		Float:y,
		Float:z,
		Float:rz;

	GetPlayerPos(id2, x, y, z);
	GetPlayerFacingAngle(id2, rz);
	SetPlayerPos(id1, x + floatsin(-rz, degrees), y + floatcos(-rz, degrees), z);

	return 1;
}

public OnPlayerText(playerid, text[])
{
	printf("%d", strlen(text));
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 0;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	return 0;
}

new distobj[MAX_PLAYERS];

CMD:mark(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	if(IsValidObject(distobj[playerid]))
		DestroyDynamicObject(distobj[playerid]);

	distobj[playerid] = CreateDynamicObject(345, x, y, z, 0, 0, 0);

	return 1;
}

CMD:distance(playerid, params[])
{
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:ox,
		Float:oy,
		Float:oz,
		Float:distsum = floatsqroot((ox-px)*(ox-px)+(oy-py)*(oy-py)+(oz-pz)*(oz-pz)),
		str[64];

	GetPlayerPos(playerid, px, py, pz);
	GetDynamicObjectPos(distobj[playerid], ox, oy, oz);

	format(str, 64, "%f", distsum);
	SendClientMessage(playerid, 0xFFFF00FF, str);

	return 1;
}

CMD:cob(playerid, params[])
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	CreateDynamicObject(strval(params), x, y, z, 0.0, 0.0, 0.0);
	return 1;
}
