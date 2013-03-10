#include <YSI\y_hooks>


new
	SetPosTick[MAX_PLAYERS],
	Float:CurPos[MAX_PLAYERS][3],
	Float:SetPos[MAX_PLAYERS][3],
	PosReportTick[MAX_PLAYERS],
	PosReportStrike[MAX_PLAYERS];


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
	GetPlayerPos(playerid, CurPos[playerid][0], CurPos[playerid][1], CurPos[playerid][2]);
}

ptask PositionCheck[1000](playerid)
{
	if(IsPlayerInAnyVehicle(playerid) || IsPlayerOnZipline(playerid))
		return;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:vx,
		Float:vy,
		Float:vz;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerVelocity(playerid, vx, vy, vz);

	if(!(-8.0 < (Distance2D(x, y, CurPos[playerid][0], CurPos[playerid][1]) - (floatsqroot((vx*vx)+(vy*vy)) * 54.0)) < 8.0))
	{
		if(tickcount() - SetPosTick[playerid] > 2000)
		{
			if(tickcount() - PosReportTick[playerid] > 10000)
			{
				new name[24];
				GetPlayerName(playerid, name, 24);

				if(PosReportStrike[playerid] == 5)
				{
					MsgAdminsF(1, 0xFFFF00FF, " >  Possible teleport hack, player: "#C_BLUE"%s", name);
					PosReportStrike[playerid] = 0;
				}
				printf("[WARN] Possible teleport hack, player: %s", name);

				PosReportStrike[playerid]++;
				PosReportTick[playerid] = tickcount();
			}
		}
		else
		{
			if(Distance(x, y, z, SetPos[playerid][0], SetPos[playerid][1], SetPos[playerid][2]) > 15.0)
			{
				new name[24];
				GetPlayerName(playerid, name, 24);

				if(PosReportStrike[playerid] == 5)
				{
					MsgAdminsF(1, 0xFFFF00FF, " >  Possible teleport hack, player: "#C_BLUE"%s", name);
					PosReportStrike[playerid] = 0;
				}
				printf("[WARN] Possible teleport hack, player: %s", name);

				PosReportStrike[playerid]++;
				PosReportTick[playerid] = tickcount();
			}
		}
	}

	CurPos[playerid][0] = x;
	CurPos[playerid][1] = y;
	CurPos[playerid][2] = z;

	return;
}
