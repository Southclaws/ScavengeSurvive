#include <YSI\y_hooks>


#define HEAT_MAX (40.0)


new
Float:	Overheat				[MAX_PLAYERS],
Timer:	OverheatUpdateTimer		[MAX_PLAYERS];


timer OverheatUpdate[100](playerid)
{
	new
		vehicleid,
		model,
		k, ud, lr;

	vehicleid = GetPlayerVehicleID(playerid);
	model = GetVehicleModel(vehicleid);
	GetPlayerKeys(playerid, k, ud, lr);

	if(model != 432 && model != 425 && model != 520)
		stop OverheatUpdateTimer[playerid];

	if(model == 425)
	{
		if(k & 1)
		{
			if(GetVehicleEngine(vehicleid))
				Overheat[playerid] += 1.0;
		}
		else
		{
			if(Overheat[playerid] > 0.0)
				Overheat[playerid] -= 1.0;
		}
	}
	else
	{
		if(Overheat[playerid] > 0.0)
			Overheat[playerid] -= 1.0;
	}

	if(Overheat[playerid] > HEAT_MAX * 0.8)
	{
		GameTextForPlayer(playerid, "~n~~r~Overheating!", 3000, 5);
	}

	if(Overheat[playerid] > HEAT_MAX)
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetVehiclePos(vehicleid, x, y, z);
		CreateExplosion(x, y, z, 11, 5.0);
		Overheat[playerid] = 0.0;
	}

	SetPlayerProgressBarMaxValue(playerid, OverheatBar, HEAT_MAX);
	SetPlayerProgressBarValue(playerid, OverheatBar, Overheat[playerid]);
	UpdatePlayerProgressBar(playerid, OverheatBar);
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return 1;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(!GetVehicleEngine(vehicleid))
		return 1;		

	new model = GetVehicleModel(vehicleid);

	if(model != 432 && model != 425 && model != 520)
		return 1;

	if(newkeys & 4)
	{
		Overheat[playerid] += 20.0;
	}

	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new model = GetVehicleModel(GetPlayerVehicleID(playerid));

		if(model == 432 || model == 425 || model == 520)
		{
			OverheatUpdateTimer[playerid] = repeat OverheatUpdate(playerid);
			ShowPlayerProgressBar(playerid, OverheatBar);
		}
	}
	if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
		stop OverheatUpdateTimer[playerid];
		HidePlayerProgressBar(playerid, OverheatBar);
	}
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	stop OverheatUpdateTimer[playerid];
	HidePlayerProgressBar(playerid, OverheatBar);
}
