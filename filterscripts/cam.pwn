#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#include <zcmd>


#define CAM_HI_SPEED	(30.0)
#define CAM_SPEED		(10.0)
#define CAM_LO_SPEED	(0.5)


stock Float:absoluteangle(Float:angle)
{
	while(angle < 0.0)angle += 360.0;
	while(angle > 360.0)angle -= 360.0;
	return angle;
}

stock Float:GetAngleToPoint(Float:fPointX, Float:fPointY, Float:fDestX, Float:fDestY)
{
	return absoluteangle(-(90-(atan2((fDestY - fPointY), (fDestX - fPointX)))));
}


new
	cam_Active[MAX_PLAYERS],
	cam_Obj[MAX_PLAYERS],
	Float:cam_StartPos[MAX_PLAYERS][3],
	cam_UpdateTimer[MAX_PLAYERS];

CMD:freecam(playerid)
{
	if(!cam_Active[playerid])
	{
		GetPlayerPos(playerid, cam_StartPos[playerid][0], cam_StartPos[playerid][1], cam_StartPos[playerid][2]);
		EnterFreeCam(playerid);
	}
	else
	{
		SetPlayerPos(playerid, cam_StartPos[playerid][0], cam_StartPos[playerid][1], cam_StartPos[playerid][2]);
		ExitFreeCam(playerid);
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
	SetCameraBehindPlayer(playerid);
//	ApplyAnimation(playerid, "carry", "crry_prtial", 0.0, 0, 1, 1, 1, 0);

	cam_Obj[playerid] = CreateObject(19300, camX, camY, camZ, 0.0, 0.0, 0.0);
	AttachCameraToObject(playerid, cam_Obj[playerid]);

	cam_UpdateTimer[playerid] = repeat CameraUpdate(playerid);
}

ExitFreeCam(playerid)
{
    cam_Active[playerid] = false;
	DestroyObject(cam_Obj[playerid]);
	SetCameraBehindPlayer(playerid);

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
		Float:speed = CAM_SPEED;

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerCameraPos(playerid, camX, camY, camZ);
	GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

	if(k & KEY_JUMP)
	{
	    speed = CAM_HI_SPEED;
	}
	if(k & KEY_WALK)
	{
	    speed = CAM_LO_SPEED;
	}

	if(ud == KEY_UP)
	{
		MoveObject(cam_Obj[playerid], camX + (vecX * 100), camY + (vecY * 100), camZ + (vecZ * 100), speed);
	}
	if(ud == KEY_DOWN)
	{
		MoveObject(cam_Obj[playerid], camX - (vecX * 100), camY - (vecY * 100), camZ - (vecZ * 100), speed);
	}
	if(lr == KEY_RIGHT)
	{
		new rotation = -(atan2(vecY, vecX) - 90.0);
		MoveObject(cam_Obj[playerid], camX + (100 * floatsin(rotation + 90.0, degrees)), camY + (100 * floatcos(rotation + 90.0, degrees)), camZ, speed);
	}
	if(lr == KEY_LEFT)
	{
		new rotation = -(atan2(vecY, vecX) - 90.0);
		MoveObject(cam_Obj[playerid], camX + (100 * floatsin(rotation - 90.0, degrees)), camY + (100 * floatcos(rotation - 90.0, degrees)), camZ, speed);
	}
	if(k & KEY_SPRINT)
	{
		MoveObject(cam_Obj[playerid], camX, camY, camZ + 100.0, speed);
	}
	if(k & KEY_CROUCH)
	{
		MoveObject(cam_Obj[playerid], camX, camY, camZ - 100.0, speed);
	}

	if(ud == 0 && lr == 0)
	{
		StopObject(cam_Obj[playerid]);
	}

	return 1;
}
