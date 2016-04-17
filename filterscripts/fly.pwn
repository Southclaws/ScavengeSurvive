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
