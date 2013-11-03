#include <YSI\y_hooks>


#define TELEPORT_DETECTION_DISTANCE		(45.0)
#define CAMERA_DISTANCE_INCAR			(150.0)
#define CAMERA_DISTANCE_INCAR_MOVING	(150.0)
#define CAMERA_DISTANCE_INCAR_CINEMATIC	(250.0)
#define CAMERA_DISTANCE_INCAR_CINEMOVE	(150.0)
#define CAMERA_DISTANCE_ONFOOT			(45.0)
#define VEHICLE_TELEPORT_DISTANCE		(15.0)


enum
{
	CAMERA_TYPE_NONE,				// 0
	CAMERA_TYPE_INCAR,				// 1
	CAMERA_TYPE_INCAR_MOVING,		// 2
	CAMERA_TYPE_INCAR_CINEMATIC,	// 3
	CAMERA_TYPE_INCAR_CINEMOVE,		// 4
	CAMERA_TYPE_ONFOOT				// 5
}


new
// Teleport
		tp_SetPosTick		[MAX_PLAYERS],
Float:	tp_CurPos			[MAX_PLAYERS][3],
Float:	tp_SetPos			[MAX_PLAYERS][3],
		tp_PosReportTick	[MAX_PLAYERS],
		tp_DetectDelay		[MAX_PLAYERS],
// Swim-fly
		sf_ReportTick		[MAX_PLAYERS],
// Height gain
		hg_ReportTick		[MAX_PLAYERS],
// Vehicle Health
		vh_ReportTick		[MAX_PLAYERS],
// Camera Distance
		cd_ReportTick		[MAX_PLAYERS],
		cd_DetectDelay		[MAX_PLAYERS];


/*==============================================================================

	Main timer

==============================================================================*/


ptask AntiCheatUpdate[1000](playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();
		return;
	}

	if(GetTickCountDifference(tickcount(), GetPlayerServerJoinTick(playerid)) < 10000)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();
		return;
	}

	if(GetTickCountDifference(tickcount(), GetPlayerSpawnTick(playerid)) < 1000)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();
		return;
	}

	if(!IsPlayerInAnyVehicle(playerid))
	{
		PositionCheck(playerid);
		SwimFlyCheck(playerid);
		VehicleTeleportCheck(playerid);

		if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
			BanPlayer(playerid, "Having a jetpack (Jetpacks aren't in this server, must be a hack)", -1);
	}
	else
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();

		VehicleHealthCheck(playerid);	
		VehicleModCheck(playerid);	
	}

	CameraDistanceCheck(playerid);

	if(GetPlayerMoney(playerid) > 0)
		BanPlayer(playerid, "Having over 0 money (Money can't be obtained in the server, must be a hack)", -1);

	return;
}

hook OnPlayerSpawn(playerid)
{
	tp_SetPosTick[playerid] = tickcount();
	tp_DetectDelay[playerid] = tickcount();
	sf_ReportTick[playerid] = tickcount();
	hg_ReportTick[playerid] = tickcount();
	vh_ReportTick[playerid] = tickcount();
	GetPlayerSpawnPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
}


/*==============================================================================

	Teleport

==============================================================================*/


HackDetect_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	tp_SetPosTick[playerid] = tickcount();
	tp_SetPos[playerid][0] = x;
	tp_SetPos[playerid][1] = y;
	tp_SetPos[playerid][2] = z;

	cd_DetectDelay[playerid] = tickcount();
}


PositionCheck(playerid)
{
	if(
		IsAutoSaving() ||
		IsPlayerOnZipline(playerid) ||
		GetTickCountDifference(tickcount(), GetPlayerVehicleExitTick(playerid)) < 5000 ||
		GetTickCountDifference(tickcount(), GetPlayerServerJoinTick(playerid)) < 20000 ||
		IsPlayerDead(playerid) ||
		IsValidVehicleID(GetPlayerSurfingVehicleID(playerid)) ||
		IsValidObject(GetPlayerSurfingObjectID(playerid)))
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();
		return;
	}

	if(GetTickCountDifference(tickcount(), tp_DetectDelay[playerid]) < 10000)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		return;
	}

	new
		Float:x,
		Float:y,
		Float:z,
		Float:distance;

	GetPlayerPos(playerid, x, y, z);

	if(z < -50.0)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();
		return;
	}

	if(IsAtDefaultPos(x, y, z))
	{
		return;
	}

	if(IsAtDefaultPos(tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]))
	{
		return;
	}

	distance = Distance2D(x, y, tp_CurPos[playerid][0], tp_CurPos[playerid][1]);

	if(distance > TELEPORT_DETECTION_DISTANCE)
	{
		if(GetTickCountDifference(tickcount(), tp_SetPosTick[playerid]) > 5000)
		{
			if(GetTickCountDifference(tickcount(), tp_PosReportTick[playerid]) > 10000)
			{
				new
					name[MAX_PLAYER_NAME],
					reason[128],
					info[128];

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);

				format(reason, sizeof(reason), "Moved %.0fm (%.0f, %.0f, %.0f > %.0f, %.0f, %.0f)", distance, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], x, y, z);
				format(info, sizeof(info), "%.1f, %.1f, %.1f", x, y, z);
				ReportPlayer(name, reason, -1, REPORT_TYPE_TELEPORT, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], info);

				SetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);

				tp_PosReportTick[playerid] = tickcount();
			}
		}
		else
		{
			if(GetTickCountDifference(tickcount(), tp_PosReportTick[playerid]) > 10000)
			{
				distance = Distance(x, y, z, tp_SetPos[playerid][0], tp_SetPos[playerid][1], tp_SetPos[playerid][2]);
				if(distance > TELEPORT_DETECTION_DISTANCE)
				{
					new
						name[MAX_PLAYER_NAME],
						reason[128],
						info[128];

					GetPlayerName(playerid, name, MAX_PLAYER_NAME);

					format(reason, sizeof(reason), "Moved %.0fm after TP (%.0f, %.0f, %.0f > %.0f, %.0f, %.0f)", distance, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], x, y, z);
					format(info, sizeof(info), "%.1f, %.1f, %.1f", x, y, z);
					ReportPlayer(name, reason, -1, REPORT_TYPE_TELEPORT, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], info);

					SetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);

					tp_PosReportTick[playerid] = tickcount();
				}
			}
		}
	}

	tp_CurPos[playerid][0] = x;
	tp_CurPos[playerid][1] = y;
	tp_CurPos[playerid][2] = z;

	return;
}


/*==============================================================================

	Swim-fly

==============================================================================*/


SwimFlyCheck(playerid)
{
	if(GetTickCountDifference(tickcount(), sf_ReportTick[playerid]) < 10000)
		return 0;

	if(GetTickCountDifference(tickcount(), GetPlayerServerJoinTick(playerid)) < 10000)
		return 0;

	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		return 0;

	if(IsPlayerDead(playerid))
	{
		sf_ReportTick[playerid] = tickcount();
		return 0;
	}

	new
		animlib[32],
		animname[32];

	GetAnimationName(GetPlayerAnimationIndex(playerid), animlib, sizeof(animlib), animname, sizeof(animname));

	if(isnull(animlib))
		return 0;
	
	if(!strcmp(animlib, "SWIM"))
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);

		if(x == 0.0 && y == 0.0 && z == 0.0)
			return 0;

		if(-5.0 < (x - DEFAULT_POS_X) < 5.0 && -5.0 < (y - DEFAULT_POS_Y) < 5.0 && -5.0 < (z - DEFAULT_POS_Z) < 5.0)
			return 0;

		if(!IsPlayerInWater(playerid))
		{
			new
				name[MAX_PLAYER_NAME],
				reason[64];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			format(reason, sizeof(reason), "Used swimming animation at %.0f, %.0f, %.0f", x, y, z);
			ReportPlayer(name, reason, -1, REPORT_TYPE_SWIMFLY, x, y, z, "");
			BanPlayer(playerid, reason, -1);

			sf_ReportTick[playerid] = tickcount();
		}
	}

	return 1;
}


/*==============================================================================

	Vehicle Health

==============================================================================*/


VehicleHealthCheck(playerid)
{
	new Float:hp;

	GetVehicleHealth(GetPlayerVehicleID(playerid), hp);

	if(hp > 990.0)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			name[MAX_PLAYER_NAME],
			reason[64];

		GetPlayerPos(playerid, x, y, z);
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		format(reason, sizeof(reason), "Vehicle health of %.2f (impossible via server)", hp);
		ReportPlayer(name, reason, -1, REPORT_TYPE_VHEALTH, x, y, z, "");
		BanPlayer(playerid, reason, -1);

		defer vh_ResetVehiclePosition(GetPlayerVehicleID(playerid));

		vh_ReportTick[playerid] = tickcount();
	}

	return 1;
}

timer vh_ResetVehiclePosition[1000](vehicleid)
{
	SetVehicleHealth(vehicleid, 300.0);
}


/*==============================================================================

	Camera Distance

==============================================================================*/


CameraDistanceCheck(playerid)
{
	if(
		IsAutoSaving() ||
		IsPlayerDead(playerid) ||
		IsPlayerUnfocused(playerid) ||
		IsPlayerOnZipline(playerid) ||
		IsValidVehicleID(GetPlayerSurfingVehicleID(playerid)) ||
		IsValidObject(GetPlayerSurfingObjectID(playerid)))
	{
		cd_DetectDelay[playerid] = tickcount();
		return;
	}

	if(GetTickCountDifference(tickcount(), GetPlayerVehicleExitTick(playerid)) < 5000)
	{
		return;
	}

	if(GetTickCountDifference(tickcount(), GetPlayerServerJoinTick(playerid)) < 20000)
	{
		return;
	}

	if(GetTickCountDifference(tickcount(), cd_DetectDelay[playerid]) < 5000)
	{
		return;
	}

	if(GetTickCountDifference(tickcount(), cd_ReportTick[playerid]) < 3000)
	{
		return;
	}

	new
		Float:vx,
		Float:vy,
		Float:vz;

	if(IsPlayerInAnyVehicle(playerid))
	{
		GetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, vz);

		if(vz < -1.0)
			return;
	}
	else
	{
		GetPlayerVelocity(playerid, vx, vy, vz);

		if(vz < -1.0)
			return;
	}

	new
		Float:cx,
		Float:cy,
		Float:cz,
		Float:px,
		Float:py,
		Float:pz,
		Float:cx_vec,
		Float:cy_vec,
		Float:cz_vec,
		Float:distance,
		Float:cmp,
		type;

	GetPlayerCameraPos(playerid, cx, cy, cz);
	GetPlayerCameraFrontVector(playerid, cx_vec, cy_vec, cz_vec);

	if(IsAtDefaultPos(cx, cy, cz))
		return;

	if(IsPlayerInAnyVehicle(playerid))
	{
		new cameramode = GetPlayerCameraMode(playerid);

		GetVehiclePos(GetPlayerVehicleID(playerid), px, py, pz);

		distance = Distance(px, py, pz, cx, cy, cz);

		if(cameramode == 56)
		{
			type = CAMERA_TYPE_INCAR_CINEMATIC;
			cmp = CAMERA_DISTANCE_INCAR_CINEMATIC;
		}
		else if(cameramode == 57)
		{
			type = CAMERA_TYPE_INCAR_CINEMATIC;
			cmp = CAMERA_DISTANCE_INCAR_CINEMATIC;
		}
		else if(cameramode == 15)
		{
			type = CAMERA_TYPE_INCAR_CINEMOVE;
			cmp = CAMERA_DISTANCE_INCAR_CINEMOVE;
		}
		else
		{
			if(vx + vy > 0.0)
			{
				type = CAMERA_TYPE_INCAR_MOVING;
				cmp = CAMERA_DISTANCE_INCAR_MOVING;
			}
			else
			{
				type = CAMERA_TYPE_INCAR;
				cmp = CAMERA_DISTANCE_INCAR;
			}
		}

		if(distance > cmp)
		{
			new
				name[MAX_PLAYER_NAME],
				reason[128],
				info[128];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			format(reason, sizeof(reason), "Camera distance from player %.0f (incar, %d, %d at %.0f, %.0f, %.0f)", distance, type, cameramode, cx, cy, cz);
			format(info, sizeof(info), "%.1f, %.1f, %.1f, %.1f, %.1f, %.1f", cx, cy, cz, vx, vy, vz);
			//ReportPlayer(name, reason, -1, REPORT_TYPE_CAMDIST, px, py, pz, info);
			MsgAdmins(3, YELLOW, reason);

			cd_ReportTick[playerid] = tickcount();
		}
	}
	else
	{
		new cameramode = GetPlayerCameraMode(playerid);

		GetPlayerPos(playerid, px, py, pz);

		if(IsAtDefaultPos(px, py, pz))
			return;

		if(px == 1133.0 && py == -2038.0)
			return;

		if(px == 0.0 && py == 0.0 && pz == 0.0)
			return;

		if(-5.0 < (cx - 1093.0) < 5.0 && -5.0 < (cy - -2036.0) < 5.0 && -5.0 < (cz - 90.0) < 5.0)
			return;

		if(cx == 0.0 && cy == 0.0 && cz == 0.0)
			return;

		if(pz < -50.0 || cz < 50.0)
			return;

		type = CAMERA_TYPE_ONFOOT;
		distance = Distance(px, py, pz, cx, cy, cz);

		if(distance > CAMERA_DISTANCE_ONFOOT)
		{
			new
				name[MAX_PLAYER_NAME],
				reason[128],
				info[128];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			format(reason, sizeof(reason), "Camera distance from player %.0f (onfoot, %d, %d at %.0f, %.0f, %.0f)", distance, type, cameramode, cx, cy, cz);
			format(info, sizeof(info), "%.1f, %.1f, %.1f, %.1f, %.1f, %.1f", cx, cy, cz, cx_vec, cy_vec, cz_vec);
			ReportPlayer(name, reason, -1, REPORT_TYPE_CAMDIST, px, py, pz, info);

			cd_ReportTick[playerid] = tickcount();
		}
	}

	return;
}


/*==============================================================================

	Vehicle Teleport

==============================================================================*/


new
Float:	vt_Position[MAX_SPAWNED_VEHICLES][3],
		vt_MovedFar[MAX_SPAWNED_VEHICLES],
		vt_MovedFarTick[MAX_SPAWNED_VEHICLES],
		vt_MovedFarPlayer[MAX_SPAWNED_VEHICLES];


hook OnVehicleSpawn(vehicleid)
{
	GetVehiclePos(vehicleid, vt_Position[vehicleid][0], vt_Position[vehicleid][1], vt_Position[vehicleid][2]);
}

VehicleTeleportCheck(playerid)
{
	foreach(new i : veh_Index)
	{
		if(!IsVehicleOccupied(i) && IsValidVehicleID(i))
			VehicleDistanceCheck(playerid, i);
	}
}

VehicleDistanceCheck(playerid, vehicleid)
{
	if(GetTickCountDifference(tickcount(), vt_MovedFarTick[vehicleid]) < 5000)
	{
		vt_ResetVehiclePosition(vehicleid);
		return 1;
	}

	if(GetTickCountDifference(tickcount(), GetPlayerSpawnTick(playerid)) < 15000)
	{
		vt_ResetVehiclePosition(vehicleid);
		return 1;
	}

	if(GetTickCountDifference(tickcount(), GetPlayerVehicleExitTick(playerid)) < 5000)
	{
		vt_ResetVehiclePosition(vehicleid);
		return 1;
	}

	new
		Float:x,
		Float:y,
		Float:z,
		Float:distance;

	GetVehiclePos(vehicleid, x, y, z);

	distance = Distance(x, y, z, vt_Position[vehicleid][0], vt_Position[vehicleid][1], vt_Position[vehicleid][2]);

	if(VEHICLE_TELEPORT_DISTANCE < distance < 500.0)
	{
		new Float:distancetoplayer = 10000.0;

		vt_MovedFarPlayer[vehicleid] = GetClosestPlayerFromPoint(x, y, z, distancetoplayer);

		if(distancetoplayer < 10.0)
		{
			vt_MovedFar[vehicleid] = true;
			vt_MovedFarTick[vehicleid] = tickcount();

			foreach(new i : veh_Index)
			{
				if(GetVehicleTrailer(i) == vehicleid)
				{
					vt_ResetVehiclePosition(vehicleid);
					return 1;
				}
			}

			new
				name[MAX_PLAYER_NAME],
				model,
				vehiclename[MAX_VEHICLE_NAME],
				owner[MAX_PLAYER_NAME],
				reason[128],
				info[128];

			GetPlayerName(vt_MovedFarPlayer[vehicleid], name, MAX_PLAYER_NAME);
			model = GetVehicleModel(vehicleid);
			GetVehicleName(model, vehiclename);
			GetVehicleOwner(vehicleid, owner);

			if(isnull(owner))
				format(reason, sizeof(reason), "Teleported a %s %.0fm", vehiclename, distance);

			else
				format(reason, sizeof(reason), "Teleported a %s (%s's) %.0fm", vehiclename, owner, distance);

			format(info, sizeof(info), "%f, %f, %f", vt_Position[vehicleid][0], vt_Position[vehicleid][1], vt_Position[vehicleid][2]);
			ReportPlayer(name, reason, -1, REPORT_TYPE_CARTELE, x, y, z, info);

			RespawnVehicle(vehicleid);
		}
	}

	vt_ResetVehiclePosition(vehicleid);

	return 1;
}

vt_ResetVehiclePosition(vehicleid)
{
	GetVehiclePos(vehicleid, vt_Position[vehicleid][0], vt_Position[vehicleid][1], vt_Position[vehicleid][2]);
}


/*==============================================================================

	Vehicle Mods

==============================================================================*/


VehicleModCheck(playerid)
{
	new
		vehicleid,
		component;

	vehicleid = GetPlayerVehicleID(playerid);

	component = GetVehicleComponentInSlot(vehicleid, CARMODTYPE_NITRO);

	if(component == 1008 || component == 1009 || component == 1010)
	{
		BanPlayer(playerid, "Detected Nitro vehicle component.", -1);
	}

	component = GetVehicleComponentInSlot(vehicleid, CARMODTYPE_HYDRAULICS);

	if(component == 1087)
	{
		BanPlayer(playerid, "Detected Hydraulics vehicle component.", -1);
	}
}


/*==============================================================================

	Interface

==============================================================================*/


IsAtDefaultPos(Float:x, Float:y, Float:z)
{
	if(-5.0 < (x - DEFAULT_POS_X) < 5.0 && -5.0 < (y - DEFAULT_POS_Y) < 5.0 && -5.0 < (z - DEFAULT_POS_Z) < 5.0)
		return 1;

	return 0;
}
