/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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
