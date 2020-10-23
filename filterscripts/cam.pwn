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

#undef MAX_PLAYERS
#define MAX_PLAYERS (32)

#include <zcmd>
#include <YSI\y_timers>


static
Float:	cam_SpeedHigh	[MAX_PLAYERS] = {50.0, ...},
Float:	cam_SpeedNorm	[MAX_PLAYERS] = {10.0, ...},
Float:	cam_SpeedLow	[MAX_PLAYERS] = {0.5, ...},
		cam_Active		[MAX_PLAYERS],
		cam_Obj			[MAX_PLAYERS],
Float:	cam_StartPos	[MAX_PLAYERS][3],
Timer:	cam_UpdateTimer	[MAX_PLAYERS];

CMD:cam(playerid)
{
	if(!cam_Active[playerid])
	{
		GetPlayerPos(playerid, cam_StartPos[playerid][0], cam_StartPos[playerid][1], cam_StartPos[playerid][2]);
		EnterFreeCam(playerid);
	}
	else
	{
		ExitFreeCam(playerid);
		SetPlayerPos(playerid, cam_StartPos[playerid][0], cam_StartPos[playerid][1], cam_StartPos[playerid][2]);
	}
	return 1;
}

CMD:freezecam(playerid)
{
	new
		Float:camX,
		Float:camY,
		Float:camZ,
		Float:vecX,
		Float:vecY,
		Float:vecZ;

	GetPlayerCameraPos(playerid, camX, camY, camZ);
	GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

	SetPlayerCameraPos(playerid, camX, camY, camZ);
	SetPlayerCameraLookAt(playerid, camX+vecX, camY+vecY, camZ+vecZ);
	
	return 1;
}

EnterFreeCam(playerid)
{
	new
	    Float:camX,
	    Float:camY,
	    Float:camZ;

	GetPlayerCameraPos(playerid, camX, camY, camZ);

    cam_Active[playerid] = true;
	TogglePlayerControllable(playerid, true);

	cam_Obj[playerid] = CreateObject(19300, camX, camY, camZ, 0.0, 0.0, 0.0);
	TogglePlayerSpectating(playerid, true);
	AttachCameraToObject(playerid, cam_Obj[playerid]);

	cam_UpdateTimer[playerid] = repeat CameraUpdate(playerid);
}

ExitFreeCam(playerid)
{
    cam_Active[playerid] = false;
	DestroyObject(cam_Obj[playerid]);
	TogglePlayerSpectating(playerid, false);

	stop cam_UpdateTimer[playerid];
}


timer CameraUpdate[50](playerid)
{
	if(!cam_Active[playerid])
		return 1;

	new
		k,
		ud,
		lr,
		Float:camX,
		Float:camY,
		Float:camZ,
		Float:vecX,
		Float:vecY,
		Float:vecZ,
		Float:speed = cam_SpeedNorm[playerid];

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerCameraPos(playerid, camX, camY, camZ);
	GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

	if(k & KEY_JUMP)
	{
	    speed = cam_SpeedHigh[playerid];
	}
	if(k & KEY_WALK)
	{
	    speed = cam_SpeedLow[playerid];
	}

	if(ud == KEY_UP)
	{
		camX += vecX * 100;
		camY += vecY * 100;
		camZ += vecZ * 100;
	}
	if(ud == KEY_DOWN)
	{
		camX -= vecX * 100;
		camY -= vecY * 100;
		camZ -= vecZ * 100;
	}
	if(lr == KEY_RIGHT)
	{
		new Float:rotation = -(atan2(vecY, vecX) - 90.0);

		camX += (100 * floatsin(rotation + 90.0, degrees));
		camY += (100 * floatcos(rotation + 90.0, degrees));
	}
	if(lr == KEY_LEFT)
	{
		new Float:rotation = -(atan2(vecY, vecX) - 90.0);

		camX += (100 * floatsin(rotation - 90.0, degrees));
		camY += (100 * floatcos(rotation - 90.0, degrees));
	}
	if(k & KEY_SPRINT)
	{
		camZ += 100.0;
	}
	if(k & KEY_CROUCH)
	{
		camZ -= 100.0;
	}

	MoveObject(cam_Obj[playerid], camX, camY, camZ, speed);

	if(ud == 0 && lr == 0 && !(k & KEY_SPRINT) && !(k & KEY_CROUCH))
	{
		StopObject(cam_Obj[playerid]);
	}

	return 1;
}
