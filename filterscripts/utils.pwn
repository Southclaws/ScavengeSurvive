/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaws" Keene

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

