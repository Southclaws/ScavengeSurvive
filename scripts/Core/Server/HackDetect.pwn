#include <YSI\y_hooks>


#define TELEPORT_DETECTION_DISTANCE		(45.0)
#define CAMERA_DISTANCE_INCAR			(85.0)
#define CAMERA_DISTANCE_INCAR_CINEMATIC	(210.0)
#define CAMERA_DISTANCE_INCAR_MOVING	(85.0)
#define CAMERA_DISTANCE_ONFOOT			(25.0)


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
	if(tickcount() - GetPlayerServerJoinTick(playerid) < 10000)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();
		return;
	}

	if(tickcount() - GetPlayerSpawnTick(playerid) < 1000)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();
		return;
	}

	if(!IsPlayerInAnyVehicle(playerid))
	{
		PositionCheck(playerid);
		WeaponCheck(playerid);
		SwimFlyCheck(playerid);

		if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
			BanPlayer(playerid, "Having a jetpack (Jetpacks aren't in this server, must have been hacked)", -1);
	}
	else
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();

		VehicleHealthCheck(playerid);	
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


Detect_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	tp_SetPosTick[playerid] = tickcount();
	tp_SetPos[playerid][0] = x;
	tp_SetPos[playerid][1] = y;
	tp_SetPos[playerid][2] = z;

	cd_DetectDelay[playerid] = tickcount();

	return SetPlayerPos(playerid, x, y, z);
}
#define SetPlayerPos Detect_SetPlayerPos

PositionCheck(playerid)
{
	if(
		IsAutoSaving() ||
		IsPlayerOnZipline(playerid) ||
		tickcount() - GetPlayerVehicleExitTick(playerid) < 5000 ||
		tickcount() - GetPlayerServerJoinTick(playerid) < 20000 ||
		IsPlayerDead(playerid) ||
		IsPlayerOnAdminDuty(playerid) ||
		IsValidVehicle(GetPlayerSurfingVehicleID(playerid)) ||
		IsValidObject(GetPlayerSurfingObjectID(playerid)))
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();
		return;
	}

	if(tickcount() - tp_DetectDelay[playerid] < 10000)
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

	distance = Distance2D(x, y, tp_CurPos[playerid][0], tp_CurPos[playerid][1]);

	if(distance > TELEPORT_DETECTION_DISTANCE)
	{
		if(tickcount() - tp_SetPosTick[playerid] > 5000)
		{
			if(tickcount() - tp_PosReportTick[playerid] > 10000)
			{
				new
					name[24],
					reason[128];

				GetPlayerName(playerid, name, 24);
				format(reason, sizeof(reason), "Moved %.2fm (%.0f, %.0f, %.0f > %.0f, %.0f, %.0f)", distance, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], x, y, z);
				ReportPlayer(name, reason, -1, REPORT_TYPE_TELEPORT, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
				SetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);

				tp_PosReportTick[playerid] = tickcount();
			}
		}
		else
		{
			if(tickcount() - tp_PosReportTick[playerid] > 10000)
			{
				distance = Distance(x, y, z, tp_SetPos[playerid][0], tp_SetPos[playerid][1], tp_SetPos[playerid][2]);
				if(distance > TELEPORT_DETECTION_DISTANCE)
				{
					new
						name[24],
						reason[128];

					GetPlayerName(playerid, name, 24);
					format(reason, sizeof(reason), "Moved %.2fm after TP (%.0f, %.0f, %.0f > %.0f, %.0f, %.0f)", distance, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2], x, y, z);
					ReportPlayer(name, reason, -1, REPORT_TYPE_TELEPORT, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
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

	Weapons

==============================================================================*/


WeaponCheck(playerid)
{
	if(tickcount() - GetPlayerWeaponSwapTick(playerid) < 1000)
		return;

	if(IsPlayerDead(playerid))
		return;

	new
		actualweapon = GetPlayerWeapon(playerid),
		weapon = GetPlayerCurrentWeapon(playerid);

	if(actualweapon > 0)
	{
		if(actualweapon != weapon)
		{
			new
				name[24],
				weaponname1[32],
				weaponname2[32],
				reason[128];

			GetPlayerName(playerid, name, 24);
			GetItemTypeName(ItemType:actualweapon, weaponname1);
			GetItemTypeName(ItemType:weapon, weaponname2);

			format(reason, sizeof(reason), " >  '%s' Used {33CCFF}%d (%s) {FFFF00}when should have {33CCFF}%d (%s){FFFF00}. (TEST REPORT)", name, actualweapon, weaponname1, weapon, weaponname2);

			//ReportPlayer(name, reason, -1, REPORT_TYPE_WEAPONS);
			MsgAdmins(3, 0xFFFF00FF, reason);
		}
	}

	return;
}


/*==============================================================================

	Swim-fly

==============================================================================*/


SwimFlyCheck(playerid)
{
	if(tickcount() - sf_ReportTick[playerid] < 10000)
		return 0;

	if(tickcount() - GetPlayerServerJoinTick(playerid) < 10000)
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
				name[24],
				reason[64];

			GetPlayerName(playerid, name, 24);
			format(reason, sizeof(reason), "Used swimming animation at %.0f, %.0f, %.0f", x, y, z);
			ReportPlayer(name, reason, -1, REPORT_TYPE_SWIMFLY);

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
			name[24],
			reason[64];

		GetPlayerPos(playerid, x, y, z);
		GetPlayerName(playerid, name, 24);
		format(reason, sizeof(reason), "Vehicle health of %.2f, (above server limit of 990)", hp);
		ReportPlayer(name, reason, -1, REPORT_TYPE_VHEALTH, x, y, z);

		SetVehicleHealth(GetPlayerVehicleID(playerid), 990.0);

		vh_ReportTick[playerid] = tickcount();
	}

	return 1;
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
		IsPlayerOnAdminDuty(playerid) ||
		IsPlayerOnZipline(playerid) ||
		IsValidVehicle(GetPlayerSurfingVehicleID(playerid)) ||
		IsValidObject(GetPlayerSurfingObjectID(playerid)))
	{
		cd_DetectDelay[playerid] = tickcount();
		return;
	}

	if(tickcount() - GetPlayerVehicleExitTick(playerid) < 5000)
	{
		return;
	}

	if(tickcount() - GetPlayerServerJoinTick(playerid) < 20000)
	{
		return;
	}

	if(tickcount() - cd_DetectDelay[playerid] < 5000)
	{
		return;
	}

	if(tickcount() - cd_ReportTick[playerid] < 3000)
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
		Float:distance,
		Float:cmp;

	GetPlayerCameraPos(playerid, cx, cy, cz);

	if(IsPlayerInAnyVehicle(playerid))
	{
		new cameramode = GetPlayerCameraMode(playerid);
		GetVehiclePos(GetPlayerVehicleID(playerid), px, py, pz);

		distance = Distance(px, py, pz, cx, cy, cz);

		if(cameramode == 56)
		{
			cmp = CAMERA_DISTANCE_INCAR_CINEMATIC;
		}
		else if(cameramode == 57)
		{
			cmp = CAMERA_DISTANCE_INCAR_CINEMATIC;
		}
		else if(cameramode == 15)
		{
			cmp = CAMERA_DISTANCE_INCAR_MOVING;
		}
		else
		{
			cmp = CAMERA_DISTANCE_INCAR;
		}

		if(distance > cmp)
		{
			new
				name[24],
				reason[128];

			GetPlayerName(playerid, name, 24);
			format(reason, 128, "Camera distance from player %.1f (at %.0f, %.0f, %.0f)", distance, cx, cy, cz);
			ReportPlayer(name, reason, -1, REPORT_TYPE_CAMDIST, px, py, pz);
			cd_ReportTick[playerid] = tickcount();
		}
	}
	else
	{
		GetPlayerPos(playerid, px, py, pz);

		distance = Distance(px, py, pz, cx, cy, cz);

		if(distance > CAMERA_DISTANCE_ONFOOT)
		{
			new
				name[24],
				reason[128];

			GetPlayerName(playerid, name, 24);
			format(reason, 128, "Camera distance from player %.1f (at %.0f, %.0f, %.0f)", distance, cx, cy, cz);
			ReportPlayer(name, reason, -1, REPORT_TYPE_CAMDIST, px, py, pz);
			cd_ReportTick[playerid] = tickcount();
		}
	}
}
