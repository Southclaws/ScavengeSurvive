#include <YSI\y_hooks>


new
	SetPosTick[MAX_PLAYERS],
	Float:CurPos[MAX_PLAYERS][3],
	Float:SetPos[MAX_PLAYERS][3],
	PosReportTick[MAX_PLAYERS];


Detect_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	SetPlayerPos(playerid, x, y, z);

	SetPosTick[playerid] = tickcount();
	SetPos[playerid][0] = x;
	SetPos[playerid][1] = y;
	SetPos[playerid][2] = z;
}
#define SetPlayerPos Detect_SetPlayerPos


hook OnPlayerSpawn(playerid)
{
	SetPosTick[playerid] = tickcount();
	GetPlayerPos(playerid, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2]);
}

ptask PositionCheck[1000](playerid)
{
	if(IsPlayerInAnyVehicle(playerid) || IsPlayerOnZipline(playerid))
		return;

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	if(Distance2D(x, y, CurPos[playerid][0], CurPos[playerid][1]) > 20.0)
	{
		if(tickcount() - SetPosTick[playerid] > 2000)
		{
			if(tickcount() - PosReportTick[playerid] > 10000)
			{
				new name[24];
				GetPlayerName(playerid, name, 24);

				MsgAdminsF(1, 0xFFFF00FF, " >  Possible teleport hack, player: {33CCFF}%s Moved %.2fm in 1 second",
					name, Distance(x, y, z, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2]));

				printf("[WARN] Possible teleport hack, player: %.2f, %.2f, %.2f to %.2f, %.2f, %.2f (%.2fm)",
					name, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2], x, y, z,
					Distance(x, y, z, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2]));

				PosReportTick[playerid] = tickcount();
			}
		}
		else
		{
			if(tickcount() - PosReportTick[playerid] > 10000)
			{
				if(Distance(x, y, z, SetPos[playerid][0], SetPos[playerid][1], SetPos[playerid][2]) > 20.0)
				{
					new name[24];
					GetPlayerName(playerid, name, 24);

					MsgAdminsF(1, 0xFFFF00FF, " >  Possible teleport hack, player: {33CCFF}%s Moved %.2fm in 1 second",
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
