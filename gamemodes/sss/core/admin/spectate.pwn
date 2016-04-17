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


#include <YSI\y_hooks>


enum
{
	SPECTATE_TYPE_NONE,
	SPECTATE_TYPE_TARGET,
	SPECTATE_TYPE_FREE
}


static
			spectate_Type[MAX_PLAYERS],
			spectate_Target[MAX_PLAYERS],
			spectate_ClickTick[MAX_PLAYERS],
Timer:		spectate_Timer[MAX_PLAYERS],
PlayerText:	spectate_Name,
PlayerText:	spectate_Info,
			spectate_CameraObject[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...},
Float:		spectate_StartPos[MAX_PLAYERS][3];


hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/admin/spectate.pwn");

	spectate_Type[playerid] = SPECTATE_TYPE_NONE;
	spectate_Target[playerid] = INVALID_PLAYER_ID;

	DestroyObject(spectate_CameraObject[playerid]);
	spectate_CameraObject[playerid] = INVALID_OBJECT_ID;
	stop spectate_Timer[playerid];

	spectate_Name						=CreatePlayerTextDraw(playerid, 320.000000, 365.000000, "[HLF]Southclaw");
	PlayerTextDrawAlignment			(playerid, spectate_Name, 2);
	PlayerTextDrawBackgroundColor	(playerid, spectate_Name, 255);
	PlayerTextDrawFont				(playerid, spectate_Name, 1);
	PlayerTextDrawLetterSize		(playerid, spectate_Name, 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid, spectate_Name, -1);
	PlayerTextDrawSetOutline		(playerid, spectate_Name, 0);
	PlayerTextDrawSetProportional	(playerid, spectate_Name, 1);
	PlayerTextDrawSetShadow			(playerid, spectate_Name, 1);
	PlayerTextDrawUseBox			(playerid, spectate_Name, 1);
	PlayerTextDrawBoxColor			(playerid, spectate_Name, 255);
	PlayerTextDrawTextSize			(playerid, spectate_Name, 100.000000, 340.000000);

	spectate_Info						=CreatePlayerTextDraw(playerid, 320.000000, 380.000000, "Is awesome");
	PlayerTextDrawAlignment			(playerid, spectate_Info, 2);
	PlayerTextDrawBackgroundColor	(playerid, spectate_Info, 255);
	PlayerTextDrawFont				(playerid, spectate_Info, 1);
	PlayerTextDrawLetterSize		(playerid, spectate_Info, 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid, spectate_Info, -1);
	PlayerTextDrawSetOutline		(playerid, spectate_Info, 0);
	PlayerTextDrawSetProportional	(playerid, spectate_Info, 1);
	PlayerTextDrawSetShadow			(playerid, spectate_Info, 1);
	PlayerTextDrawUseBox			(playerid, spectate_Info, 1);
	PlayerTextDrawBoxColor			(playerid, spectate_Info, 255);
	PlayerTextDrawTextSize			(playerid, spectate_Info, 100.000000, 340.000000);
}

hook OnPlayerDisconnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDisconnect] in /gamemodes/sss/core/admin/spectate.pwn");

	if(spectate_Type[playerid] != SPECTATE_TYPE_NONE)
		ExitSpectateMode(playerid);

	foreach(new i : Player)
	{
		if(spectate_Target[i] == playerid)
		{
			SpectateNextTarget(i);
			// or
			// EnterFreeMode(i, x, y, z);
		}
	}

	return 1;
}

EnterSpectateMode(playerid, targetid)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	if(spectate_Type[playerid] == SPECTATE_TYPE_FREE)
		ExitFreeMode(playerid);

	TogglePlayerSpectating(playerid, true);
	ToggleNameTagsForPlayer(playerid, true);

	spectate_Type[playerid] = SPECTATE_TYPE_TARGET;
	spectate_Target[playerid] = targetid;

	_RefreshSpectate(playerid);

	PlayerTextDrawShow(playerid, spectate_Name);
	PlayerTextDrawShow(playerid, spectate_Info);

	stop spectate_Timer[playerid];
	spectate_Timer[playerid] = repeat UpdateSpectateMode(playerid);

	logf("[SPECTATE] %p watches %p", playerid, targetid);

	return 1;
}

EnterFreeMode(playerid, Float:camX = 0.0, Float:camY = 0.0, Float:camZ = 0.0)
{
	if(camX * camY * camZ == 0.0)
		GetPlayerCameraPos(playerid, camX, camY, camZ);

	spectate_Type[playerid] = SPECTATE_TYPE_FREE;
	TogglePlayerControllable(playerid, true);

	DestroyObject(spectate_CameraObject[playerid]);
	spectate_CameraObject[playerid] = CreateObject(19300, camX, camY, camZ, 0.0, 0.0, 0.0);
	TogglePlayerSpectating(playerid, false);
	TogglePlayerSpectating(playerid, true);
	AttachCameraToObject(playerid, spectate_CameraObject[playerid]);
	GetPlayerPos(playerid, spectate_StartPos[playerid][0], spectate_StartPos[playerid][1], spectate_StartPos[playerid][2]);
	spectate_Timer[playerid] = repeat UpdateSpectateMode(playerid);
}

ExitFreeMode(playerid)
{
	spectate_Type[playerid] = SPECTATE_TYPE_NONE;
	DestroyObject(spectate_CameraObject[playerid]);
	spectate_CameraObject[playerid] = INVALID_OBJECT_ID;
	TogglePlayerSpectating(playerid, false);
	SetPlayerPos(playerid, spectate_StartPos[playerid][0], spectate_StartPos[playerid][1], spectate_StartPos[playerid][2]);
	stop spectate_Timer[playerid];
}

ExitSpectateMode(playerid)
{
	if(spectate_Target[playerid] == INVALID_PLAYER_ID)
		return 0;

	if(spectate_Type[playerid] == SPECTATE_TYPE_FREE)
		ExitFreeMode(playerid);

	TogglePlayerSpectating(playerid, false);
	PlayerTextDrawHide(playerid, spectate_Name);
	PlayerTextDrawHide(playerid, spectate_Info);

	spectate_Target[playerid] = INVALID_PLAYER_ID;
	stop spectate_Timer[playerid];

	if(GetPlayerGender(playerid) == GENDER_MALE)
		SetPlayerSkin(playerid, 217);

	else
		SetPlayerSkin(playerid, 211);

	return 1;
}

SpectateNextTarget(playerid)
{
	new
		id = spectate_Target[playerid] + 1,
		iters;

	if(id == MAX_PLAYERS)
		id = 0;

	while(id < MAX_PLAYERS && iters <= MAX_PLAYERS)
	{
		iters++;

		if(!CanPlayerSpectate(playerid, id))
		{
			id++;

			if(id >= MAX_PLAYERS - 1)
				id = 0;

			continue;
		}

		break;
	}

	spectate_Target[playerid] = id;
	_RefreshSpectate(playerid);
}

SpectatePrevTarget(playerid)
{
	new
		id = spectate_Target[playerid] - 1,
		iters;

	if(id < 0)
		id = MAX_PLAYERS-1;

	while(id >= 0 && iters <= MAX_PLAYERS)
	{
		iters++;

		if(!CanPlayerSpectate(playerid, id))
		{
			id--;

			if(id < 0)
				id = MAX_PLAYERS - 1;

			continue;
		}

		break;
	}

	spectate_Target[playerid] = id;
	_RefreshSpectate(playerid);
}

_RefreshSpectate(playerid)
{
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(spectate_Target[playerid]));
	SetPlayerInterior(playerid, GetPlayerInterior(spectate_Target[playerid]));

	if(IsPlayerInAnyVehicle(spectate_Target[playerid]))
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(spectate_Target[playerid]));

	else
		PlayerSpectatePlayer(playerid, spectate_Target[playerid]);
}

timer UpdateSpectateMode[100](playerid)
{
	if(spectate_Type[playerid] == SPECTATE_TYPE_NONE)
	{
		stop spectate_Timer[playerid];
		return;
	}

	new targetid = spectate_Target[playerid];

	if(targetid == INVALID_PLAYER_ID)
	{

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
			Float:speed = 10.0;

		GetPlayerKeys(playerid, k, ud, lr);
		GetPlayerCameraPos(playerid, camX, camY, camZ);
		GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

		if(k & KEY_JUMP)
		{
			speed = 50.0;
		}
		if(k & KEY_WALK)
		{
			speed = 0.5;
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

		MoveObject(spectate_CameraObject[playerid], camX, camY, camZ, speed);

		if(ud == 0 && lr == 0 && !(k & KEY_SPRINT) && !(k & KEY_CROUCH))
		{
			StopObject(spectate_CameraObject[playerid]);
		}

	}
	else
	{
		new
			name[MAX_PLAYER_NAME],
			title[MAX_PLAYER_NAME + 6],
			str[256];

		if(!GetPlayerBitFlag(playerid, ShowHUD))
		{
			PlayerTextDrawHide(playerid, spectate_Info);
			return;
		}

		if(IsPlayerInAnyVehicle(targetid))
		{
			new
				invehicleas[24],
				itemid,
				itemname[ITM_MAX_NAME + ITM_MAX_TEXT],
				cameramodename[37];

			if(GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
				invehicleas = "Driver";

			else
				invehicleas = "Passenger";

			itemid = GetPlayerItem(targetid);
			if(!GetItemName(itemid, itemname))
				itemname = "None";

			GetCameraModeName(GetPlayerCameraMode(targetid), cameramodename);

			format(str, sizeof(str), "Health: %.2f Armour: %.2f Food: %.2f Int: %d VW: %d~n~\
				Knockout: %s Bleed rate: %02f Item: %s Exdata: %d~n~\
				Camera: %s Velocity: %.2f~n~\
				Vehicle %d As %s Fuel: %.2f Locked: %d",
				GetPlayerHP(targetid),
				GetPlayerAP(targetid),
				GetPlayerFP(targetid),
				GetPlayerInterior(targetid),
				GetPlayerVirtualWorld(targetid),
				IsPlayerKnockedOut(targetid) ? MsToString(GetPlayerKnockOutRemainder(targetid), "%1m:%1s") : ("No"),
				GetPlayerBleedRate(targetid),
				itemname,
				GetItemExtraData(itemid),
				cameramodename,
				GetPlayerTotalVelocity(targetid),
				GetPlayerLastVehicle(targetid),
				invehicleas,
				GetVehicleFuel(GetPlayerLastVehicle(targetid)),
				IsVehicleLocked(GetPlayerLastVehicle(targetid)));
		}
		else
		{
			new
				itemid,
				itemname[ITM_MAX_NAME + ITM_MAX_TEXT],
				holsteritemid,
				holsteritemname[32],
				cameramodename[37],
				Float:vx,
				Float:vy,
				Float:vz,
				Float:velocity;

			itemid = GetPlayerItem(targetid);
			if(!GetItemName(itemid, itemname))
				itemname = "None";

			holsteritemid = GetPlayerHolsterItem(targetid);
			if(!GetItemName(holsteritemid, holsteritemname))
				holsteritemname = "None";

			GetCameraModeName(GetPlayerCameraMode(targetid), cameramodename);
			GetPlayerVelocity(targetid, vx, vy, vz);

			velocity = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;

			format(str, sizeof(str), "Health: %.2f Armour: %.2f Food: %.2f Int: %d VW: %d~n~\
				Knockout: %s Bleed rate: %02f Camera: %s Velocity: %.2f~n~\
				Item: %s Exdata: %d Holster: %s Exdata: %d",
				GetPlayerHP(targetid),
				GetPlayerAP(targetid),
				GetPlayerFP(targetid),
				GetPlayerInterior(targetid),
				GetPlayerVirtualWorld(targetid),
				IsPlayerKnockedOut(targetid) ? MsToString(GetPlayerKnockOutRemainder(targetid), "%1m:%1s") : ("No"),
				GetPlayerBleedRate(targetid),
				cameramodename,
				velocity,
				itemname,
				GetItemExtraData(itemid),
				holsteritemname,
				GetItemExtraData(holsteritemid));
		}

		GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		format(title, sizeof(title), "%s (%d)", name, targetid);

		PlayerTextDrawSetString(playerid, spectate_Name, title);
		PlayerTextDrawSetString(playerid, spectate_Info, str);
		PlayerTextDrawShow(playerid, spectate_Info);
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/admin/spectate.pwn");

	if(spectate_Target[playerid] != INVALID_PLAYER_ID)
	{
		if(GetTickCountDifference(GetTickCount(), spectate_ClickTick[playerid]) < 1000)
			return 1;

		spectate_ClickTick[playerid] = GetTickCount();

		if(newkeys == 128)
			SpectateNextTarget(playerid);

		if(newkeys == 4)
			SpectatePrevTarget(playerid);

		if(newkeys == 512)
			EnterSpectateMode(playerid, spectate_Target[playerid]);
	}
	return 1;
}

CanPlayerSpectate(playerid, targetid)
{
	if(targetid == playerid || !IsPlayerConnected(targetid) || !(IsPlayerSpawned(targetid)) || GetPlayerState(targetid) == PLAYER_STATE_SPECTATING)
		return 0;

	if(GetPlayerAdminLevel(playerid) == 1)
	{
		new name[MAX_PLAYER_NAME];

		GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		if(!IsPlayerReported(name))
			return 0;
	}

	return 1;
}

GetPlayerSpectateTarget(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_PLAYER_ID;

	return spectate_Target[playerid];
}

stock GetPlayerSpectateType(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return spectate_Type[playerid];
}

ACMD:freezecam[2](playerid)
{
	if(!IsPlayerOnAdminDuty(playerid))
		return 6;

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

