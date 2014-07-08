#include <YSI\y_hooks>


static
		knockout_KnockedOut[MAX_PLAYERS],
		knockout_Tick[MAX_PLAYERS],
		knockout_Duration[MAX_PLAYERS],
Timer:	knockout_Timer[MAX_PLAYERS];


stock KnockOutPlayer(playerid, duration)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	ShowPlayerProgressBar(playerid, KnockoutBar);

	if(knockout_KnockedOut[playerid])
	{
		knockout_Duration[playerid] += duration;
	}
	else
	{
		knockout_Tick[playerid] = GetTickCount();
		knockout_Duration[playerid] = duration;
		knockout_KnockedOut[playerid] = true;

		foreach(new i : veh_Index)
			SetVehicleParamsForPlayer(i, playerid, 0, 1);

		_PlayKnockOutAnimation(playerid);

		stop knockout_Timer[playerid];
		knockout_Timer[playerid] = repeat KnockOutUpdate(playerid);
	}


	return 1;
}

stock WakeUpPlayer(playerid)
{
	stop knockout_Timer[playerid];

	foreach(new i : veh_Index)
		SetVehicleParamsForPlayer(i, playerid, 0, IsVehicleLocked(i));

	HidePlayerProgressBar(playerid, KnockoutBar);
	ApplyAnimation(playerid, "PED", "GETUP_FRONT", 4.0, 0, 1, 1, 0, 0);

	knockout_Tick[playerid] = GetTickCount();
	knockout_KnockedOut[playerid] = false;
}

timer KnockOutUpdate[100](playerid)
{
	if(!knockout_KnockedOut[playerid])
		WakeUpPlayer(playerid);

	if(IsPlayerDead(playerid) || GetTickCountDifference(GetPlayerSpawnTick(playerid), GetTickCount()) < 1000 || !IsPlayerSpawned(playerid))
	{
		knockout_KnockedOut[playerid] = false;
		HidePlayerProgressBar(playerid, KnockoutBar);
		return;
	}

	if(IsPlayerOnAdminDuty(playerid))
		WakeUpPlayer(playerid);

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		SetVehicleEngine(GetPlayerVehicleID(playerid), 0);	
	}
	else
	{
		new animidx = GetPlayerAnimationIndex(playerid);

		if(animidx != 1207 && animidx != 1018 && animidx != 1001)
		{
			_PlayKnockOutAnimation(playerid);
			return;
		}
	}

	SetPlayerProgressBarValue(playerid, KnockoutBar, GetTickCountDifference(GetTickCount(), knockout_Tick[playerid]));
	SetPlayerProgressBarMaxValue(playerid, KnockoutBar, knockout_Duration[playerid]);
	UpdatePlayerProgressBar(playerid, KnockoutBar);

	if(GetTickCountDifference(GetTickCount(), knockout_Tick[playerid]) >= knockout_Duration[playerid])
		WakeUpPlayer(playerid);

	return;
}

_PlayKnockOutAnimation(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		ApplyAnimation(playerid, "PED", "KO_SHOT_STOM", 4.0, 0, 1, 1, 1, 0, 1);
	}
	else
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			SetVehicleEngine(vehicleid, 0);

		switch(GetVehicleTypeCategory(GetVehicleType(vehicleid)))
		{
			case VEHICLE_CATEGORY_MOTORBIKE, VEHICLE_CATEGORY_PUSHBIKE:
			{
				new
					Float:x,
					Float:y,
					Float:z;

				GetVehiclePos(vehicleid, x, y, z);
				RemovePlayerFromVehicle(playerid);
				SetPlayerPos(playerid, x, y, z);
				ApplyAnimation(playerid, "PED", "BIKE_fall_off", 4.0, 0, 1, 1, 0, 0, 1);
			}

			default:
			{
				ApplyAnimation(playerid, "PED", "CAR_DEAD_LHS", 4.0, 0, 1, 1, 1, 0, 1);
			}
		}
	}
}

hook OnPlayerDisconnect(playerid)
{
	if(gServerRestarting)
		return 1;

	if(knockout_KnockedOut[playerid])
	{
		WakeUpPlayer(playerid);
	}

	return 1;
}

hook OnPlayerSpawn(playerid)
{
	knockout_KnockedOut[playerid] = false;
}

stock GetPlayerKnockOutTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return knockout_Tick[playerid];
}

stock GetPlayerKnockoutDuration(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return knockout_Duration[playerid];
}

stock GetPlayerKnockOutRemainder(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!knockout_KnockedOut[playerid])
		return 0;

	return GetTickCountDifference((knockout_Tick[playerid] + knockout_Duration[playerid]), GetTickCount());
}

stock IsPlayerKnockedOut(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return knockout_KnockedOut[playerid];
}

ACMD:knockout[4](playerid, params[])
{
	KnockOutPlayer(playerid, strval(params));
	return 1;
}
