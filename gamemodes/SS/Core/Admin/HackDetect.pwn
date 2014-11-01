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


static
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
		tp_DetectDelay[playerid] = GetTickCount();
		return;
	}

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 10000)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = GetTickCount();
		return;
	}

	if(GetTickCountDifference(GetTickCount(), GetPlayerSpawnTick(playerid)) < 1000)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = GetTickCount();
		return;
	}

	if(!IsPlayerInAnyVehicle(playerid))
	{
		PositionCheck(playerid);
		SwimFlyCheck(playerid);

		if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
			BanPlayer(playerid, "Having a jetpack (Jetpacks aren't in this server, must be a hack)", -1, 0);
	}
	else
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = GetTickCount();

		VehicleHealthCheck(playerid);	
		VehicleModCheck(playerid);	
	}

	CameraDistanceCheck(playerid);

	if(GetPlayerMoney(playerid) > 0)
		BanPlayer(playerid, "Having over 0 money (Money can't be obtained in the server, must be a hack)", -1, 0);

	return;
}

hook OnPlayerSpawn(playerid)
{
	tp_SetPosTick[playerid] = GetTickCount();
	tp_DetectDelay[playerid] = GetTickCount();
	sf_ReportTick[playerid] = GetTickCount();
	hg_ReportTick[playerid] = GetTickCount();
	vh_ReportTick[playerid] = GetTickCount();
	GetPlayerSpawnPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
}


/*==============================================================================

	Teleport

==============================================================================*/


HackDetect_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	tp_SetPosTick[playerid] = GetTickCount();
	tp_SetPos[playerid][0] = x;
	tp_SetPos[playerid][1] = y;
	tp_SetPos[playerid][2] = z;

	cd_DetectDelay[playerid] = GetTickCount();

	return 1;
}


PositionCheck(playerid)
{
	if(
		IsAutoSaving() ||
		IsPlayerOnZipline(playerid) ||
		GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) < 5000 ||
		GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 20000 ||
		IsPlayerDead(playerid) ||
		IsValidVehicle(GetPlayerSurfingVehicleID(playerid)) ||
		IsValidObject(GetPlayerSurfingObjectID(playerid)))
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = GetTickCount();
		return;
	}

	if(GetTickCountDifference(GetTickCount(), tp_DetectDelay[playerid]) < 10000)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		return;
	}

	new
		Float:x,
		Float:y,
		Float:z,
		Float:distance,
		Float:velocity;

	GetPlayerPos(playerid, x, y, z);
	velocity = GetPlayerTotalVelocity(playerid);

	if(z < -50.0)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = GetTickCount();
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

	if(IsAtConnectionPos(x, y, z))
	{
		return;
	}

	if(IsAtConnectionPos(tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]))
	{
		return;
	}

	distance = Distance2D(x, y, tp_CurPos[playerid][0], tp_CurPos[playerid][1]);

	if(distance > TELEPORT_DETECTION_DISTANCE)
	{
		if(GetTickCountDifference(GetTickCount(), tp_SetPosTick[playerid]) > 5000)
		{
			if(GetTickCountDifference(GetTickCount(), tp_PosReportTick[playerid]) > 10000)
			{
				new
					name[MAX_PLAYER_NAME],
					reason[128],
					info[128];

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);

				format(reason, sizeof(reason), "Moved %.0fm @%.0f (%.0f, %.0f, %.0f > %.0f, %.0f, %.0f)", distance, velocity, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], x, y, z);
				format(info, sizeof(info), "%.1f, %.1f, %.1f", x, y, z);
				ReportPlayer(name, reason, -1, REPORT_TYPE_TELEPORT, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], info);

				SetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);

				tp_PosReportTick[playerid] = GetTickCount();
			}
		}
		else
		{
			if(GetTickCountDifference(GetTickCount(), tp_PosReportTick[playerid]) > 10000)
			{
				distance = Distance(x, y, z, tp_SetPos[playerid][0], tp_SetPos[playerid][1], tp_SetPos[playerid][2]);
				if(distance > TELEPORT_DETECTION_DISTANCE)
				{
					new
						name[MAX_PLAYER_NAME],
						reason[128],
						info[128];

					GetPlayerName(playerid, name, MAX_PLAYER_NAME);

					format(reason, sizeof(reason), "Moved %.0fm after TP @%.0f (%.0f, %.0f, %.0f > %.0f, %.0f, %.0f)", distance, velocity, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], x, y, z);
					format(info, sizeof(info), "%.1f, %.1f, %.1f", x, y, z);
					ReportPlayer(name, reason, -1, REPORT_TYPE_TELEPORT, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], info);

					SetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);

					tp_PosReportTick[playerid] = GetTickCount();
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
	if(GetTickCountDifference(GetTickCount(), sf_ReportTick[playerid]) < 10000)
		return 0;

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 10000)
		return 0;

	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		return 0;

	if(IsPlayerDead(playerid))
	{
		sf_ReportTick[playerid] = GetTickCount();
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
			BanPlayer(playerid, reason, -1, 0);

			sf_ReportTick[playerid] = GetTickCount();
		}
	}

	return 1;
}


/*==============================================================================

	Vehicle Health

==============================================================================*/


VehicleHealthCheck(playerid)
{
	new Float:vehiclehp;

	GetVehicleHealth(GetPlayerVehicleID(playerid), vehiclehp);

	if(vehiclehp > 990.0 && GetPlayerVehicleSeat(playerid) == 0) // Only check the driver - Checking passengers causes a false ban
	{
		new
			Float:x,
			Float:y,
			Float:z,
			name[MAX_PLAYER_NAME],
			reason[64];

		GetPlayerPos(playerid, x, y, z);
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		format(reason, sizeof(reason), "Vehicle health of %.2f (impossible via server)", vehiclehp);
		ReportPlayer(name, reason, -1, REPORT_TYPE_VHEALTH, x, y, z, "");
		BanPlayer(playerid, reason, -1, 0);

		defer vh_ResetVehiclePosition(GetPlayerVehicleID(playerid));

		vh_ReportTick[playerid] = GetTickCount();
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
		IsValidVehicle(GetPlayerSurfingVehicleID(playerid)) ||
		IsValidObject(GetPlayerSurfingObjectID(playerid)))
	{
		cd_DetectDelay[playerid] = GetTickCount();
		return;
	}

	if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) < 5000)
	{
		return;
	}

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 20000)
	{
		return;
	}

	if(GetTickCountDifference(GetTickCount(), cd_DetectDelay[playerid]) < 5000)
	{
		return;
	}

	if(GetTickCountDifference(GetTickCount(), cd_ReportTick[playerid]) < 3000)
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

			format(reason, sizeof(reason), " >  %s(%d) camera distance %.0f (incar, %d, %d at %.0f, %.0f, %.0f)", name, playerid, distance, type, cameramode, cx, cy, cz);
			format(info, sizeof(info), "%.1f, %.1f, %.1f, %.1f, %.1f, %.1f", cx, cy, cz, vx, vy, vz);
			//ReportPlayer(name, reason, -1, REPORT_TYPE_CAMDIST, px, py, pz, info);
			MsgAdmins(3, YELLOW, reason);

			cd_ReportTick[playerid] = GetTickCount();
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

			cd_ReportTick[playerid] = GetTickCount();
		}
	}

	return;
}


/*==============================================================================

	Vehicle Teleport

==============================================================================*/


static
		vt_MovedFar[MAX_VEHICLES],
		vt_MovedFarTick[MAX_VEHICLES],
		vt_MovedFarPlayer[MAX_VEHICLES];


public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
	if(GetTickCountDifference(GetTickCount(), vt_MovedFarTick[vehicleid]) < 5000)
		return 1;

	if(GetTickCountDifference(GetTickCount(), GetPlayerSpawnTick(playerid)) < 15000)
		return 1;

	if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) < 5000)
		return 1;

	if(GetTickCountDifference(GetTickCount(), GetVehicleLastUseTick(vehicleid)) < 1000)
		return 1;

	if(IsVehicleOccupied(vehicleid))
		return 1;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:distance;

	GetVehiclePos(vehicleid, x, y, z);

	distance = Distance(x, y, z, new_x, new_y, new_z);

	if(IsNaN(distance))
	{
		RespawnVehicle(vehicleid);
		return 1;
	}

	if(VEHICLE_TELEPORT_DISTANCE < distance < 500.0)
	{
		new Float:distancetoplayer = 10000.0;

		vt_MovedFarPlayer[vehicleid] = GetClosestPlayerFromPoint(x, y, z, distancetoplayer);

		if(distancetoplayer < 10.0)
		{
			vt_MovedFar[vehicleid] = true;
			vt_MovedFarTick[vehicleid] = GetTickCount();

			foreach(new i : veh_Index)
			{
				if(GetVehicleTrailer(i) == vehicleid)
					return 1;
			}

			new
				name[MAX_PLAYER_NAME],
				vehicletype,
				vehiclename[MAX_VEHICLE_TYPE_NAME],
				owner[MAX_PLAYER_NAME],
				reason[128],
				info[128];

			GetPlayerName(vt_MovedFarPlayer[vehicleid], name, MAX_PLAYER_NAME);
			vehicletype = GetVehicleType(vehicleid);
			GetVehicleTypeName(vehicletype, vehiclename);
			GetVehicleOwner(vehicleid, owner);

			if(isnull(owner))
				format(reason, sizeof(reason), "Teleported a %s %.0fm", vehiclename, distance);

			else
				format(reason, sizeof(reason), "Teleported a %s (%s's) %.0fm", vehiclename, owner, distance);

			format(info, sizeof(info), "%f, %f, %f", new_x, new_y, new_z);
			ReportPlayer(name, reason, -1, REPORT_TYPE_CARTELE, x, y, z, info);

			// RespawnVehicle(vehicleid);
			return 0;
		}
	}

	return 1;
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
		BanPlayer(playerid, "Detected Nitro vehicle component.", -1, 0);
		RemoveVehicleComponent(vehicleid, CARMODTYPE_NITRO);
	}

	component = GetVehicleComponentInSlot(vehicleid, CARMODTYPE_HYDRAULICS);

	if(component == 1087)
	{
		BanPlayer(playerid, "Detected Hydraulics vehicle component.", -1, 0);
		RemoveVehicleComponent(vehicleid, CARMODTYPE_HYDRAULICS);
	}
}


/*==============================================================================

	Entering locked vehicles

==============================================================================*/


hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		if(IsVehicleLocked(vehicleid) && GetTickCountDifference(GetTickCount(), GetVehicleLockTick(vehicleid)) > 3500)
		{
			new
				name[MAX_PLAYER_NAME],
				Float:px,
				Float:py,
				Float:pz;

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			GetPlayerPos(playerid, px, py, pz);

			ReportPlayer(name, sprintf("Entered locked vehicle (%d) as driver", vehicleid), -1, REPORT_TYPE_LOCKEDCAR, px, py, pz, "");
			RemovePlayerFromVehicle(playerid);
			SetPlayerPos(playerid, px, py, pz);

			defer CheckIsPlayerStillInVehicle(playerid, vehicleid);

			return -1;
		}
	}

	if(newstate == PLAYER_STATE_PASSENGER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		if(IsVehicleLocked(vehicleid) && GetTickCountDifference(GetTickCount(), GetVehicleLockTick(vehicleid)) > 3500)
		{
			new
				name[MAX_PLAYER_NAME],
				Float:x,
				Float:y,
				Float:z;

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			GetPlayerPos(playerid, x, y, z);

			ReportPlayer(name, sprintf("Entered locked vehicle (%d) as passenger", vehicleid), -1, REPORT_TYPE_LOCKEDCAR, x, y, z, "");
			RemovePlayerFromVehicle(playerid);
			SetPlayerPos(playerid, x, y, z);

			defer CheckIsPlayerStillInVehicle(playerid, vehicleid);

			return -1;
		}
	}

	return 1;
}

timer CheckIsPlayerStillInVehicle[1000](playerid, vehicleid)
{
	if(!IsPlayerConnected(playerid))
		return;

	if(IsPlayerInVehicle(playerid, vehicleid))
		BanPlayer(playerid, "Staying in a locked vehicle", -1, 0);

	SetVehicleExternalLock(vehicleid, 1);
}


/*==============================================================================

	Infinite Ammo and Shooting Animations

==============================================================================*/


static
	ammo_LastShot[MAX_PLAYERS],
	ammo_ShotCounter[MAX_PLAYERS];

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	// by IstuntmanI, thanks!
	if(hittype == BULLET_HIT_TYPE_PLAYER)
	{
		if(!(-20.0 <= fX <= 20.0) || !(-20.0 <= fY <= 20.0) || !(-20.0 <= fZ <= 20.0))
		{
			new
				name[MAX_PLAYER_NAME],
				Float:x,
				Float:y,
				Float:z;

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			GetPlayerPos(playerid, x, y, z);

			ReportPlayer(name, "Bad bullet hit offset, attempted crash", -1, REPORT_TYPE_BADHITOFFSET, x, y, z, "");

			return 0;
		}
	}

	if(GetTickCountDifference(ammo_LastShot[playerid], GetTickCount()) < GetWeaponShotInterval(weaponid) + 10)
	{
		ammo_ShotCounter[playerid]++;

		if(ammo_ShotCounter[playerid] > GetWeaponMagSize(weaponid))
		{
			new
				name[MAX_PLAYER_NAME],
				Float:x,
				Float:y,
				Float:z;

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			GetPlayerPos(playerid, x, y, z);

			ReportPlayer(name, sprintf("fired %d bullets from a %w without reloading", ammo_ShotCounter[playerid], weaponid), -1, REPORT_TYPE_AMMO, x, y, z, "");
		}
	}
	else
	{
		ammo_ShotCounter[playerid] = 1;
	}

	ammo_LastShot[playerid] = GetTickCount();

	switch(weaponid)
	{
		case 27:
		{
			if(GetPlayerAnimationIndex(playerid) == 222)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 222 while shooting weapon 27", -1, REPORT_TYPE_SHOTANIM, x, y, z, "");

				return 0;
			}
		}
		case 23:
		{
			if(GetPlayerAnimationIndex(playerid) == 1454)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 1454 while shooting weapon 23", -1, REPORT_TYPE_SHOTANIM, x, y, z, "");

				return 0;
			}
		}
		case 25:
		{
			if(GetPlayerAnimationIndex(playerid) == 1450)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 1450 while shooting weapon 25", -1, REPORT_TYPE_SHOTANIM, x, y, z, "");

				return 0;
			}
		}
		case 29:
		{
			if(GetPlayerAnimationIndex(playerid) == 1645)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 1645 while shooting weapon 29", -1, REPORT_TYPE_SHOTANIM, x, y, z, "");

				return 0;
			}
		}
		case 30, 31, 33:
		{
			if(GetPlayerAnimationIndex(playerid) == 1367)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 1367 while shooting weapon 30/31/33", -1, REPORT_TYPE_SHOTANIM, x, y, z, "");

				return 0;
			}
		}
		case 24:
		{
			if(GetPlayerAnimationIndex(playerid) == 1333)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 1333 while shooting weapon 24", -1, REPORT_TYPE_SHOTANIM, x, y, z, "");

				return 0;
			}
		}

		case 22, 26, 28, 32, 34, 38:
		{
			// Do nothing
		}

		default:
		{
			if(hittype == BULLET_HIT_TYPE_PLAYER)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, sprintf("Shot invalid weapon ID (%d)", weaponid), -1, REPORT_TYPE_BAD_SHOT_WEAP, x, y, z, "");
				Kick(playerid);

				return 0;
			}
		}
	}

	#if defined ac_OnPlayerWeaponShot
		return ac_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerWeaponShot
	#undef OnPlayerWeaponShot
#else
	#define _ALS_OnPlayerWeaponShot
#endif
 
#define OnPlayerWeaponShot ac_OnPlayerWeaponShot
#if defined ac_OnPlayerWeaponShot
	forward ac_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
#endif
