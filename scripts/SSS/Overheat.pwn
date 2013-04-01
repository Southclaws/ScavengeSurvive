#include <YSI\y_hooks>


new
Float:	TankHeat				[MAX_PLAYERS],
Timer:	TankHeatUpdateTimer		[MAX_PLAYERS];


timer TankHeatUpdate[100](playerid)
{
	if(GetVehicleModel(gPlayerVehicleID[playerid]) != 432)
		stop TankHeatUpdateTimer[playerid];

	if(TankHeat[playerid] > 30.0)
		TankHeat[playerid] = 30.0;

	if(TankHeat[playerid] > 0.0)
		TankHeat[playerid] -= 1.0;

	SetPlayerProgressBarMaxValue(playerid, TankHeatBar, 30.0);
	SetPlayerProgressBarValue(playerid, TankHeatBar, TankHeat[playerid]);
	UpdatePlayerProgressBar(playerid, TankHeatBar);
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return 1;

	if(GetVehicleModel(gPlayerVehicleID[playerid]) != 432)
		return 1;

	if(newkeys & 1 || newkeys & 4)
	{
		TankHeat[playerid] += 20.0;

		SetPlayerProgressBarMaxValue(playerid, TankHeatBar, 30.0);
		SetPlayerProgressBarValue(playerid, TankHeatBar, TankHeat[playerid]);
		UpdatePlayerProgressBar(playerid, TankHeatBar);

		if(TankHeat[playerid] >= 30.0)
		{
			GameTextForPlayer(playerid, "~n~~r~Overheating!", 3000, 5);
		}

		if(TankHeat[playerid] >= 40.0)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetVehiclePos(gPlayerVehicleID[playerid], x, y, z);
			CreateExplosion(x, y, z, 11, 5.0);
			TankHeat[playerid] = 0.0;
		}
	}

	return 1;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	stop TankHeatUpdateTimer[playerid];
	HidePlayerProgressBar(playerid, TankHeatBar);
}
