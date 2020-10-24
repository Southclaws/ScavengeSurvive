/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <sscanf>
#include <YSI\y_ini>
#include <ZCMD>


/*==============================================================================

	Save position to a file

==============================================================================*/


CMD:sp(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return 0;

	new posname[128];

	if(sscanf(params, "s[128]", posname))
		SendClientMessage(playerid, -1, " >  Usage: /sp [position name]");

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

	new str[128];
	format(str, sizeof(str), " >  %s = %s Saved!", posname, string);
	SendClientMessage(playerid, -1, str);
 
	return 1;
}


/*==============================================================================

	Output the current animation library, name and index

==============================================================================*/


CMD:getanim(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return 0;

	new
		animlib[32],
		animname[32],
		idx = GetPlayerAnimationIndex(playerid);

	GetAnimationName(idx, animlib, 32, animname, 32);

	new str[128];
	format(str, sizeof(str), "Lib: %s Name: %s Idx: %d", animlib, animname, idx);
	SendClientMessage(playerid, -1, str);

	return 1;
}


/*==============================================================================

	Set virtual world and interior

==============================================================================*/


CMD:setvw(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return 0;

	SetPlayerVirtualWorld(playerid, strval(params));

	return 1;
}

CMD:setint(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return 0;

	SetPlayerInterior(playerid, strval(params));

	return 1;
}

