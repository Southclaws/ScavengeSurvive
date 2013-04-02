#include <YSI\y_hooks>


#define DETECTION_DISTANCE (40.0)


ptask AntiCheatUpdate[1000](playerid)
{
	PositionCheck(playerid);
	WeaponCheck(playerid);
}


// Anti-teleport


new
		SetPosTick		[MAX_PLAYERS],
Float:	CurPos			[MAX_PLAYERS][3],
Float:	SetPos			[MAX_PLAYERS][3],
		PosReportTick	[MAX_PLAYERS],
		DetectDelay		[MAX_PLAYERS];


Defect_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	SetPlayerPos(playerid, x, y, z);

	SetPosTick[playerid] = tickcount();
	SetPos[playerid][0] = x;
	SetPos[playerid][1] = y;
	SetPos[playerid][2] = z;
}
#define SetPlayerPos Defect_SetPlayerPos


hook OnPlayerSpawn(playerid)
{
	SetPosTick[playerid] = tickcount();
	DetectDelay[playerid] = tickcount();
	GetPlayerPos(playerid, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2]);
}

PositionCheck(playerid)
{
	if(
		IsPlayerInAnyVehicle(playerid) ||
		IsPlayerOnZipline(playerid) ||
		tickcount() - GetPlayerVehicleExitTick(playerid) < 5000 ||
		tickcount() - GetPlayerServerJoinTick(playerid) < 10000 ||
		IsPlayerDead(playerid) ||
		IsPlayerOnAdminDuty(playerid) ||
		IsValidVehicle(GetPlayerSurfingVehicleID(playerid)))
	{
		GetPlayerPos(playerid, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2]);
		DetectDelay[playerid] = tickcount();
		return;
	}

	if(tickcount() - DetectDelay[playerid] < 10000)
	{
		GetPlayerPos(playerid, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2]);
		return;
	}

	new
		Float:x,
		Float:y,
		Float:z,
		Float:distance;

	GetPlayerPos(playerid, x, y, z);
	distance = Distance2D(x, y, CurPos[playerid][0], CurPos[playerid][1]);

	if(distance > DETECTION_DISTANCE)
	{
		if(tickcount() - SetPosTick[playerid] > 5000)
		{
			if(tickcount() - PosReportTick[playerid] > 10000)
			{
				new
					name[24],
					reason[32];

				GetPlayerName(playerid, name, 24);
				format(reason, sizeof(reason), "Moved %.2fm in 1 second", distance);
				ReportPlayer(name, reason, -1);

				PosReportTick[playerid] = tickcount();
			}
		}
		else
		{
			if(tickcount() - PosReportTick[playerid] > 10000)
			{
				distance = Distance(x, y, z, SetPos[playerid][0], SetPos[playerid][1], SetPos[playerid][2]);
				if(distance > DETECTION_DISTANCE)
				{
					new
						name[24],
						reason[32];

					GetPlayerName(playerid, name, 24);
					format(reason, sizeof(reason), "Moved %.2fm in 1 second", distance);
					ReportPlayer(name, reason, -1);

					PosReportTick[playerid] = tickcount();
				}
			}
		}
	}

	CurPos[playerid][0] = x;
	CurPos[playerid][1] = y;
	CurPos[playerid][2] = z;

	return;
}


// Anti-weapon spawn


#define WEAPON_OFFENSE_MAX (3)


new
	WeaponOffenseStrike[MAX_PLAYERS];

WeaponCheck(playerid)
{
	new weaponid = GetPlayerWeapon(playerid);

	if(weaponid != 0)
	{
		if(weaponid != GetPlayerCurrentWeapon(playerid))
		{
			WeaponOffenseStrike[playerid]++;

			if(WeaponOffenseStrike[playerid] == WEAPON_OFFENSE_MAX)
			{
				new
					name[24],
					weaponname1[32],
					weaponname2[32],
					reason[128];

				GetPlayerName(playerid, name, 24);
				GetWeaponName(weaponid, weaponname1, 32);
				GetWeaponName(GetPlayerCurrentWeapon(playerid), weaponname2, 32);

				format(reason, sizeof(reason), " >  '%s' Used '%s' when should have '%s'.", name, weaponname1, weaponname2);

				//ReportPlayer(name, reason, -1);
				MsgAdmins(3, 0xFFFF00FF, reason);

				WeaponOffenseStrike[playerid] = 0;
			}
		}
	}
}
