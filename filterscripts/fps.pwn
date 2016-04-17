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
#include <YSI\y_timers>


enum
{
	CAMERA_MODE_STAND,
	CAMERA_MODE_CROUCH,
	CAMERA_MODE_CROUCH_MOVE
}


new
		fps_ObjectID[MAX_PLAYERS],
		fps_Active[MAX_PLAYERS],
Timer:	fps_Timer[MAX_PLAYERS],
		fps_CameraMode[MAX_PLAYERS];

CMD:fps(playerid)
{
	if(fps_Active[playerid])
	{
		DestroyObject(fps_ObjectID[playerid]);
		SetCameraBehindPlayer(playerid);
		fps_Active[playerid] = false;
		stop fps_Timer[playerid];

		SendClientMessage(playerid, -1, " >  FPS Mode Off");
	}
	else
	{
		fps_ObjectID[playerid] = CreateObject(19300, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
		SetCameraMode(playerid, CAMERA_MODE_STAND);
		fps_Active[playerid] = true;
		fps_Timer[playerid] = repeat CrouchCheck(playerid);

		SendClientMessage(playerid, -1, " >  FPS Mode On");
	}

	return 1;
}

Float:GetPlayerSpeed(playerid)
{
	new
		Float:vx,
		Float:vy,
		Float:vz;

	GetPlayerVelocity(playerid, vx, vy, vz);

	return floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) );
}

timer CrouchCheck[50](playerid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DUCK || GetPlayerAnimationIndex(playerid) == 164)
	{
		if(GetPlayerSpeed(playerid) > 0.0)
		{
			SetCameraMode(playerid, CAMERA_MODE_CROUCH_MOVE);
		}
		else
		{
			SetCameraMode(playerid, CAMERA_MODE_CROUCH);
		}
	}
	else
	{
		SetCameraMode(playerid, CAMERA_MODE_STAND);
	}
}

SetCameraMode(playerid, mode)
{
	if(fps_CameraMode[playerid] == mode)
		return 0;

	fps_CameraMode[playerid] = mode;

	switch(mode)
	{
		case CAMERA_MODE_STAND:
			AttachObjectToPlayer(fps_ObjectID[playerid], playerid, 0.0, 0.18, 0.85, 0.0, 0.0, 0.0);

		case CAMERA_MODE_CROUCH:
			AttachObjectToPlayer(fps_ObjectID[playerid], playerid, 0.1, 0.25, 0.2, 0.0, 0.0, 0.0);

		case CAMERA_MODE_CROUCH_MOVE:
			AttachObjectToPlayer(fps_ObjectID[playerid], playerid, 0.1, 0.3, 0.3, 0.0, 0.0, 0.0);
	}
	
	AttachCameraToObject(playerid, fps_ObjectID[playerid]);

	return 1;
}
