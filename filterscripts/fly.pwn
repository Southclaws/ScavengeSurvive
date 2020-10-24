/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <zcmd>

#define VELOCITY_MULT	(3.0)
#define VELOCITY_NORM	(1.0)
#define HEIGHT_GAIN		(0.5)

new
	fly[MAX_PLAYERS],
	usefly[MAX_PLAYERS];

CMD:fly(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	{
		SendClientMessage(playerid, -1, "Admin only command");
		return 1;
	}

	usefly[playerid] = !usefly[playerid];

	if(usefly[playerid])
		SendClientMessage(playerid, -1, "Press ~k~~PED_JUMPING~ and ~k~~VEHICLE_ENTER_EXIT~ together to fly");
 
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerAdmin(playerid))
	{
		if(newkeys & KEY_JUMP && newkeys & 16 && usefly[playerid])
		{
			if(fly[playerid])
			{
				fly[playerid] = false;
				ClearAnimations(playerid);
			}
			else
			{
				fly[playerid] = true;
				ClearAnimations(playerid);
				ApplyAnimation(playerid, "PARACHUTE", "FALL_SKYDIVE", 4.0, 1, 0, 0, 0, 0, 1);
			}
		}
	}
}

public OnPlayerUpdate(playerid)
{
	if(!fly[playerid])
		return 1;

	if(!IsPlayerAdmin(playerid))
	{
		fly[playerid] = false;
		return 1;
	}


	new
		k, ud, lr,
		Float:hMult = 0.01,
		Float:angle,
		Float:forwd;

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerFacingAngle(playerid, angle);

	if(ud == KEY_UP)        forwd	= VELOCITY_NORM;
	else if(ud == KEY_DOWN) forwd	=-VELOCITY_NORM;
	
	if(k & KEY_JUMP)forwd *= VELOCITY_MULT;
	if(k & KEY_SPRINT)hMult = HEIGHT_GAIN * 10;
	if(k & KEY_SPRINT && k & KEY_JUMP) hMult = HEIGHT_GAIN * 10;
	if(k & KEY_CROUCH)hMult =-HEIGHT_GAIN;


	if(k & KEY_FIRE)
	{
		if(lr == KEY_LEFT)		forwd = VELOCITY_NORM, angle	+= 90.0;
		else if(lr == KEY_RIGHT)forwd = VELOCITY_NORM, angle	-= 90.0;
	}
	else
	{
		if(lr == KEY_LEFT)		angle	+= 6.0;
		else if(lr == KEY_RIGHT)angle	-= 6.0;
		SetPlayerFacingAngle(playerid, angle);
	}
	SetPlayerHealth(playerid, 1000.0);
	SetPlayerVelocity(playerid, forwd*floatsin(-angle, degrees), forwd*floatcos(-angle, degrees), hMult);
	SetPlayerHealth(playerid, 1000.0);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	fly[playerid] = false;
}

public OnPlayerConnect(playerid)
{
	fly[playerid] = false;
}
