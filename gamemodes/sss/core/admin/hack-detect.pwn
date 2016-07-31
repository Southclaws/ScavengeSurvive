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


#define TELEPORT_DETECTION_DISTANCE		(45.0)
#define CAMERA_DISTANCE_INCAR			(150.0)
#define CAMERA_DISTANCE_INCAR_MOVING	(150.0)
#define CAMERA_DISTANCE_INCAR_CINEMATIC	(250.0)
#define CAMERA_DISTANCE_INCAR_CINEMOVE	(150.0)
#define CAMERA_DISTANCE_ONFOOT			(45.0)
#define VEHICLE_TELEPORT_DISTANCE		(15.0)
#define	NUM_SHOT_CHECK					(10)
#define	EXCESS_AMOUNT					(7)


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
		sf_LSTrainTunnel_Area,
		sf_LVTrainTunnel_Area,
		sf_SFDryDock_Area,
// Height gain
		hg_ReportTick		[MAX_PLAYERS],
// Vehicle Health
		vh_ReportTick		[MAX_PLAYERS],
// Camera Distance
		cd_ReportTick		[MAX_PLAYERS],
		cd_DetectDelay		[MAX_PLAYERS],
// Excess Accuracy
		ea_PlayerShots		[MAX_PLAYERS],
		ea_PlayerHits		[MAX_PLAYERS],
		ea_LastShots		[MAX_PLAYERS][NUM_SHOT_CHECK],
		ea_Currshot			[MAX_PLAYERS],
		ea_TotalChecks		[MAX_PLAYERS];


hook OnGameModeInit()
{
	new Float:ls_points[8] = {
		1357.18958, -1905.22717,
		1314.53406, -1947.33569,
		665.23090, -1285.64282,
		719.66364, -1223.15979
	};

	new Float:lv_points[8] = {
		2764.71533, 2126.56323,
		2716.97314, 2081.59985,
		2569.71045, 2213.24756,
		2606.24243, 2252.94141	
	};

	new Float:sf_points[8] = {
		-1608.19177, 166.27438,
		-1578.24011, 135.71609,
		-1675.87097, 38.37003,
		-1707.14429, 66.96732
	};

	sf_LSTrainTunnel_Area = CreateDynamicPolygon(ls_points, -6.0, 0.0, 8);
	sf_LVTrainTunnel_Area = CreateDynamicPolygon(lv_points, -6.0, 0.0, 8);
	sf_SFDryDock_Area = CreateDynamicPolygon(sf_points, -14, 0.0, 8);

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		for(new j = 0; j < NUM_SHOT_CHECK; j++)
			ea_LastShots[i][j] = -1;
	}
}
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
	d:3:GLOBAL_DEBUG("[OnPlayerSpawn] in /gamemodes/sss/core/admin/hack-detect.pwn");

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
				ReportPlayer(name, reason, -1, REPORT_TYPE_TELEPORT, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), info);

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
					ReportPlayer(name, reason, -1, REPORT_TYPE_TELEPORT, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), info);

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

		if(!_hd_IsPlayerInWater(playerid))
		{
			new
				name[MAX_PLAYER_NAME],
				reason[64];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			format(reason, sizeof(reason), "Used swimming animation at %.0f, %.0f, %.0f", x, y, z);
			ReportPlayer(name, reason, -1, REPORT_TYPE_SWIMFLY, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
			BanPlayer(playerid, reason, -1, 0);

			sf_ReportTick[playerid] = GetTickCount();
		}
	}

	return 1;
}

/*
Sherman Reservior - from Hiddos' code
{-1248.0, 2536.0, -1088.0, 2824.0, 40.60000},
{-1088.0, 2544.0, -1040.0, 2800.0, 40.60000},
{-1040.0, 2544.0, -832.0, 2760.0, 40.60000},
{-1088.0, 2416.0, -832.0, 2544.0, 40.60000},
{-1040.0, 2304.0, -864.0, 2416.0, 40.60000},
{-1024.0, 2144.0, -864.0, 2304.0, 40.60000},
{-1072.0, 2152.0, -1024.0, 2264.0, 40.60000},
{-1200.0, 2114.0, -1072.0, 2242.0, 40.60000},
{-976.0, 2016.0, -848.0, 2144.0, 40.60000},
{-864.0, 2144.0, -448.0, 2272.0, 40.60000},
{-700.0, 2272.0, -484.0, 2320.0, 40.60000},
{-608.0, 2320.0, -528.0, 2352.0, 40.60000},
{-848.0, 2044.0, -816.0, 2144.0, 40.60000},
{-816.0, 2060.0, -496.0, 2144.0, 40.60000},
{-604.0, 2036.0, -484.0, 2060.0, 40.60000},
{-1328.0, 2082.0, -1200.0, 2210.0, 40.60000},
{-1400.0, 2074.0, -1328.0, 2150.0, 40.60000},
{-550.0, 2004.0, -494.0, 2036.0, 40.60000},
*/

new Float:water_places[25][5] =
{
	{-2048.0, -962.0, -2004.0, -758.0, 30.40000},
	{-2522.0, -310.0, -2382.0, -234.0, 35.38200},
	{-2778.0, -522.0, -2662.0, -414.0, 2.79256},
	{-664.0, -1924.0, -464.0, -1864.0, 5.27000},
	{-848.0, -2082.0, -664.0, -1866.0, 5.27000},
	{1084.0, -684.0, 1104.0, -660.0, 112.00000},
	{1202.0, -2414.0, 1278.0, -2334.0, 8.86445},
	{1270.0, -812.0, 1290.0, -800.0, 86.67300},
	{1744.0, 2780.0, 1792.0, 2868.0, 8.47297},
	{178.0, -1244.0, 206.0, -1216.0, 77.05340},
	{1836.0, 1468.0, 1888.0, 1568.0, 8.59839},
	{1888.0, 1468.0, 2036.0, 1700.0, 8.59839},
	{1928.0, -1222.0, 2012.0, -1178.0, 18.00000},
	{2058.0, 1868.0, 2110.0, 1964.0, 9.62916},
	{2090.0, 1670.0, 2146.0, 1694.0, 9.61171},
	{2108.0, 1084.0, 2180.0, 1172.0, 7.56284},
	{2110.0, 1234.0, 2178.0, 1330.0, 7.83275},
	{214.0, -1208.0, 246.0, -1180.0, 74.00000},
	{218.0, -1180.0, 238.0, -1172.0, 74.00000},
	{2248.0, -1182.0, 2260.0, -1170.0, 23.33740},
	{2292.0, -1432.0, 2328.0, -1400.0, 22.16500},
	{2506.0, 1546.0, 2554.0, 1586.0, 8.96708},
	{2564.0, 2370.0, 2604.0, 2398.0, 16.40000},
	{502.0, -1114.0, 522.0, -1098.0, 78.42310},
	{890.0, -1106.0, 902.0, -1098.0, 22.41000}
};

stock _hd_IsPlayerInWater(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	// Sherman Dam Reservoir
	if(z < 44.0)
	{
		if(Distance(x, y, z, -965.0, 2438.0, 42.0) <= 700.0)
			return 1;
	}

	// Is the player at sea level? (1.9m takes into account wave height)
	if(z < 1.9)
	{
		// If out of map bounds, must be in water.
		if(!IsPointInMapBounds(x, y, z))
			return 1;

		// Check if the player is in any areas of the map below sea level that
		// aren't under water:

		// Hunter quarry
		if(Distance(x, y, z, 618.4129, 863.3164, 1.0839) < 200.0)
			return 0;

		// SFPD
		if(Distance(x, y, z, -1597.1052, 703.2137, -5.9072) < 80.0)
			return 0;

		// LV PD
		if(2215.38916 < x < 2320.28271 && 2422.94531 < y < 2504.66431)
			return 0; 

		// LS train tunnel
		if(IsPlayerInDynamicArea(playerid, sf_LSTrainTunnel_Area))
			return 0;

		// LV train tunnel
		if(IsPlayerInDynamicArea(playerid, sf_LVTrainTunnel_Area))
			return 0;

		// SF Dry Dock
		if(IsPlayerInDynamicArea(playerid, sf_SFDryDock_Area))
			return 0;

		return 1;
	}

	// Finally, loop water areas
	for(new i; i < sizeof(water_places); i++)
	{
		if(z <= water_places[i][4])
		{
			if( (water_places[i][0] <= x <= water_places[i][2]) && (water_places[i][1] <= y <= water_places[i][3]) )
				return 1;
		}
	}

	return 0;
}


/*==============================================================================

	Vehicle Health

==============================================================================*/


VehicleHealthCheck(playerid)
{
	new
		Float:vehiclehp,
		vehicleid = GetPlayerVehicleID(playerid);

	GetVehicleHealth(vehicleid, vehiclehp);

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
		ReportPlayer(name, reason, -1, REPORT_TYPE_VHEALTH, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
		BanPlayer(playerid, reason, -1, 0);

		defer vh_ResetVehiclePosition(vehicleid);

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
			//ReportPlayer(name, reason, -1, REPORT_TYPE_CAMDIST, px, py, pz, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), info);
			ChatMsgAdmins(3, YELLOW, reason);

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
			ReportPlayer(name, reason, -1, REPORT_TYPE_CAMDIST, px, py, pz, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), info);
			TimeoutPlayer(playerid, reason);

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
			ReportPlayer(name, reason, -1, REPORT_TYPE_CARTELE, x, y, z, GetPlayerVirtualWorld(vt_MovedFarPlayer[vehicleid]), GetPlayerInterior(vt_MovedFarPlayer[vehicleid]), info);
			TimeoutPlayer(vt_MovedFarPlayer[vehicleid], reason);

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
	d:3:GLOBAL_DEBUG("[OnPlayerStateChange] in /gamemodes/sss/core/admin/hack-detect.pwn");

	if(newstate == PLAYER_STATE_DRIVER)
	{
		new
			vehicleid,
			E_LOCK_STATE:lockstate;

		vehicleid = GetPlayerVehicleID(playerid);
		lockstate = GetVehicleLockState(vehicleid);

		if(lockstate != E_LOCK_STATE_OPEN && GetTickCountDifference(GetTickCount(), GetVehicleLockTick(vehicleid)) > 3500)
		{
			new
				name[MAX_PLAYER_NAME],
				Float:px,
				Float:py,
				Float:pz;

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			GetPlayerPos(playerid, px, py, pz);

			ReportPlayer(name, sprintf("Entered locked vehicle (%d) as driver", vehicleid), -1, REPORT_TYPE_LOCKEDCAR, px, py, pz, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
			TimeoutPlayer(playerid, sprintf("Entered locked vehicle (%d) as driver", vehicleid));
			RemovePlayerFromVehicle(playerid);
			SetPlayerPos(playerid, px, py, pz);

			defer StillInVeh(playerid, vehicleid, _:lockstate);

			return -1;
		}
	}

	if(newstate == PLAYER_STATE_PASSENGER)
	{
		new
			vehicleid,
			E_LOCK_STATE:lockstate;

		vehicleid = GetPlayerVehicleID(playerid);
		lockstate = GetVehicleLockState(vehicleid);

		if(lockstate != E_LOCK_STATE_OPEN && GetTickCountDifference(GetTickCount(), GetVehicleLockTick(vehicleid)) > 3500)
		{
			new
				name[MAX_PLAYER_NAME],
				Float:x,
				Float:y,
				Float:z;

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			GetPlayerPos(playerid, x, y, z);

			ReportPlayer(name, sprintf("Entered locked vehicle (%d) as passenger", vehicleid), -1, REPORT_TYPE_LOCKEDCAR, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
			TimeoutPlayer(playerid, sprintf("Entered locked vehicle (%d) as passenger", vehicleid));
			RemovePlayerFromVehicle(playerid);
			SetPlayerPos(playerid, x, y, z);

			defer StillInVeh(playerid, vehicleid, _:lockstate);

			return -1;
		}
	}

	return 1;
}

timer StillInVeh[1000](playerid, vehicleid, ls)
{
	if(!IsPlayerConnected(playerid))
		return;

	if(IsPlayerInVehicle(playerid, vehicleid))
		TimeoutPlayer(playerid, "Staying in a locked vehicle");

	SetVehicleExternalLock(vehicleid, E_LOCK_STATE:ls);
}


/*==============================================================================

	Infinite Ammo and Shooting Animations

==============================================================================*/


static
	ammo_LastShot[MAX_PLAYERS],
	ammo_ShotCounter[MAX_PLAYERS];

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	d:3:GLOBAL_DEBUG("[OnPlayerWeaponShot] in /gamemodes/sss/core/admin/hack-detect.pwn");

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

			ReportPlayer(name, sprintf("fired %d bullets from a %w without reloading", ammo_ShotCounter[playerid], weaponid), -1, REPORT_TYPE_AMMO, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
			TimeoutPlayer(playerid, sprintf("fired %d bullets from a %w without reloading", ammo_ShotCounter[playerid], weaponid));
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

				ReportPlayer(name, "Used animation 222 while shooting weapon 27", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 222 while shooting weapon 27");

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

				ReportPlayer(name, "Used animation 1454 while shooting weapon 23", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 1454 while shooting weapon 23");

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

				ReportPlayer(name, "Used animation 1450 while shooting weapon 25", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 1450 while shooting weapon 25");

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

				ReportPlayer(name, "Used animation 1645 while shooting weapon 29", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 1645 while shooting weapon 29");

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

				ReportPlayer(name, "Used animation 1367 while shooting weapon 30/31/33", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 1367 while shooting weapon 30/31/33");

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

				ReportPlayer(name, "Used animation 1333 while shooting weapon 24", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 1333 while shooting weapon 24");

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

				ReportPlayer(name, sprintf("Shot invalid weapon ID (%d)", weaponid), -1, REPORT_TYPE_BAD_SHOT_WEAP, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				Kick(playerid);

				return 0;
			}
		}
	}

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

			ReportPlayer(name, "Bad bullet hit offset, attempted crash", -1, REPORT_TYPE_BADHITOFFSET, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
			TimeoutPlayer(playerid, "Bad bullet hit offset, attempted crash");

			return 0;
		}


/*==============================================================================

	Excess accuracy checks

==============================================================================*/


		if(GetPlayerTargetPlayer(playerid) != INVALID_PLAYER_ID)
		{
			if(!IsPlayerNPC(hitid))
			{
				// Check if player shot is standing still
				new
					Float:vx,
					Float:vy,
					Float:vz;

				GetPlayerVelocity(hitid, vx, vy, vz);

				if(vx != 0.0 || vy != 0.0 || vz != 0.0)
				{
					ea_PlayerShots[playerid]++;
					ea_PlayerHits[playerid]++;
					ea_LastShots[playerid][ea_Currshot[playerid]] = 1;

					new total = CheckLastShots(playerid);

					if(total > 0)
					{
						ea_TotalChecks[playerid]++;
						AccuracyWarning(playerid, total);
					}

					ea_Currshot[playerid]++;

					if(ea_Currshot[playerid] == NUM_SHOT_CHECK)
					{
						ea_Currshot[playerid] = 0;

						for(new i = 0; i < NUM_SHOT_CHECK; i++)
							ea_LastShots[playerid][i] = -1;
					}
				}
			}
		}
		else
		{
			ea_PlayerShots[playerid]++;
			ea_LastShots[playerid][ea_Currshot[playerid]] = 0;

			new total = CheckLastShots(playerid);

			if(total > 0)
			{
				ea_TotalChecks[playerid]++;
				AccuracyWarning(playerid, total);
			}

			ea_Currshot[playerid]++;

			if(ea_Currshot[playerid] == NUM_SHOT_CHECK)
			{
				ea_Currshot[playerid] = 0;

				for(new i = 0; i < NUM_SHOT_CHECK; i++)
					ea_LastShots[playerid][i] = -1;
			}
		}
	}

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	ea_PlayerShots[playerid] = 0;
	ea_PlayerHits[playerid] = 0;
	ea_Currshot[playerid] = 0;
	ea_TotalChecks[playerid] = 0;

	for(new i = 0; i < NUM_SHOT_CHECK; i++)
		ea_LastShots[playerid][i] = -1;

	return 1;
}

stock GetPlayerShotStats(playerid, &shots, &hits, &Float:accuracy)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	shots = ea_PlayerShots[playerid];
	hits = ea_PlayerHits[playerid];
	accuracy = floatdiv(float(ea_PlayerHits[playerid]), float(ea_PlayerShots[playerid]));

	return 1;
}

stock CheckLastShots(playerid)
{
	new count;

	for(new i = 0; i < NUM_SHOT_CHECK; i++)
	{
		if(ea_LastShots[playerid][i] == -1)
			return 0;

		if(ea_LastShots[playerid][i])
			count++;
	}

	if(count >= EXCESS_AMOUNT)
		return count;

	return 0;
}

AccuracyWarning(playerid, total)
{
	new
		shots,
		hits,
		Float:accuracy;

	GetPlayerShotStats(playerid, shots, hits, accuracy);

	ChatMsgAdmins(2, YELLOW,
		"Accuracy Warning: %P (%d) Shots: %d Hits: %d Accuracy: %.2f (%d/10) Checks: %d",
		playerid, playerid, shots, hits, accuracy, total, ea_TotalChecks[playerid]);
}
