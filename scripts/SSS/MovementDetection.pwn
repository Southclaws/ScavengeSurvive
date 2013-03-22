#include <YSI\y_hooks>


new
	SetPosTick[MAX_PLAYERS],
	Float:CurPos[MAX_PLAYERS][3],
	Float:SetPos[MAX_PLAYERS][3],
	PosReportTick[MAX_PLAYERS],
	DetectDelay[MAX_PLAYERS];


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

ptask PositionCheck[1000](playerid)
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

	if(distance > 25.0)
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
				if(Distance(x, y, z, SetPos[playerid][0], SetPos[playerid][1], SetPos[playerid][2]) > 25.0)
				{
					new name[24];
					GetPlayerName(playerid, name, 24);

					MsgAdminsF(3, 0xFFFF00FF, " >  Possible teleport hack, player: {33CCFF}%s Moved %.2fm in 1 second",
						name, Distance(x, y, z, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2]));

					printf("[WARN] Possible teleport hack, player: %.2f, %.2f, %.2f to %.2f, %.2f, %.2f (%.2fm)",
						name, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2], x, y, z,
						Distance(x, y, z, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2]));

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
