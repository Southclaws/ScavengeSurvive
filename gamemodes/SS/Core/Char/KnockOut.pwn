#include <YSI\y_hooks>


static
	knockout_KnockedOut[MAX_PLAYERS],
	knockout_Tick[MAX_PLAYERS],
	knockout_Duration[MAX_PLAYERS];


KnockOutPlayer(playerid, duration)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	SetPlayerProgressBarValue(playerid, KnockoutBar, GetTickCountDifference(GetTickCount(), knockout_Tick[playerid]));
	SetPlayerProgressBarMaxValue(playerid, KnockoutBar, 1000 * (40.0 - GetPlayerHP(playerid)));
	ShowPlayerProgressBar(playerid, KnockoutBar);

	knockout_Tick[playerid] = GetTickCount();
	knockout_Duration[playerid] = duration;
	knockout_KnockedOut[playerid] = true;

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			SetVehicleEngine(vehicleid, 0);

		switch(GetVehicleType(GetVehicleModel(vehicleid)))
		{
			case VTYPE_MOTORBIKE, VTYPE_QUAD, VTYPE_BICYCLE:
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
	else
	{
		ApplyAnimation(playerid, "PED", "KO_SHOT_STOM", 4.0, 0, 1, 1, 1, 0, 1);
	}

	return 1;
}

WakeUpPlayer(playerid)
{
	HidePlayerProgressBar(playerid, KnockoutBar);

	ApplyAnimation(playerid, "PED", "GETUP_FRONT", 4.0, 0, 1, 1, 0, 0);

	knockout_Tick[playerid] = GetTickCount();
	knockout_KnockedOut[playerid] = false;
}

KnockOutUpdate(playerid)
{
	if(IsPlayerDead(playerid) || GetTickCountDifference(GetPlayerSpawnTick(playerid), GetTickCount()) < 1000 || !IsPlayerSpawned(playerid))
	{
		knockout_KnockedOut[playerid] = false;
		HidePlayerProgressBar(playerid, KnockoutBar);
		return;
	}

	if(knockout_KnockedOut[playerid])
	{
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
				KnockOutPlayer(playerid, knockout_Duration[playerid] - GetTickCountDifference(GetTickCount(), knockout_Tick[playerid]));
				return;
			}
		}

		SetPlayerProgressBarValue(playerid, KnockoutBar, GetTickCountDifference(GetTickCount(), knockout_Tick[playerid]));
		SetPlayerProgressBarMaxValue(playerid, KnockoutBar, knockout_Duration[playerid]);
		UpdatePlayerProgressBar(playerid, KnockoutBar);

		if(GetTickCountDifference(GetTickCount(), knockout_Tick[playerid]) >= knockout_Duration[playerid])
			WakeUpPlayer(playerid);
	}
	else
	{
		new Float:hp = GetPlayerHP(playerid);

		HidePlayerProgressBar(playerid, KnockoutBar);

		if(hp < 50.0)
		{
			if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE) && !IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_PAINKILL))
			{
				if(GetTickCountDifference(GetTickCount(), knockout_Tick[playerid]) > 5000 * hp)
				{
					if(IsPlayerBleeding(playerid))
					{
						if(frandom(40.0) < (50.0 - hp))
							KnockOutPlayer(playerid, floatround(2000 * (50.0 - hp) + frandom(200 * (50.0 - hp))));
					}
					else
					{
						if(frandom(40.0) < (40.0 - hp))
							KnockOutPlayer(playerid, floatround(2000 * (40.0 - hp) + frandom(200 * (40.0 - hp))));
					}
				}
			}
		}
	}

	return;
}

hook OnPlayerDisconnect(playerid)
{
	if(gServerRestarting)
		return 1;

	if(knockout_KnockedOut[playerid])
	{
		print("waking");
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
