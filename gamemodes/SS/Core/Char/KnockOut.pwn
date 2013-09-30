static
	knockout_Tick[MAX_PLAYERS],
	knockout_Duration[MAX_PLAYERS];


KnockOutPlayer(playerid, duration)
{
	if(gPlayerBitData[playerid] & AdminDuty)
		return 0;

	SetPlayerProgressBarValue(playerid, KnockoutBar, GetTickCountDifference(tickcount(), knockout_Tick[playerid]));
	SetPlayerProgressBarMaxValue(playerid, KnockoutBar, 1000 * (40.0 - gPlayerData[playerid][ply_HitPoints]));
	ShowPlayerProgressBar(playerid, KnockoutBar);

	knockout_Tick[playerid] = tickcount();
	knockout_Duration[playerid] = duration;
	t:gPlayerBitData[playerid]<KnockedOut>;

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

	knockout_Tick[playerid] = tickcount();
	f:gPlayerBitData[playerid]<KnockedOut>;
}

KnockOutUpdate(playerid)
{
	if(gPlayerBitData[playerid] & Dying)
	{
		f:gPlayerBitData[playerid]<KnockedOut>;
		HidePlayerProgressBar(playerid, KnockoutBar);
		return;
	}

	if(gPlayerBitData[playerid] & KnockedOut)
	{
		if(gPlayerBitData[playerid] & AdminDuty)
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
				KnockOutPlayer(playerid, knockout_Duration[playerid] - GetTickCountDifference(tickcount(), knockout_Tick[playerid]));
				return;
			}
		}

		printf("%f / %f", GetTickCountDifference(tickcount(), knockout_Tick[playerid]), knockout_Duration[playerid]);

		SetPlayerProgressBarValue(playerid, KnockoutBar, GetTickCountDifference(tickcount(), knockout_Tick[playerid]));
		SetPlayerProgressBarMaxValue(playerid, KnockoutBar, knockout_Duration[playerid]);
		UpdatePlayerProgressBar(playerid, KnockoutBar);

		if(GetTickCountDifference(tickcount(), knockout_Tick[playerid]) >= knockout_Duration[playerid])
			WakeUpPlayer(playerid);
	}
	else
	{
		HidePlayerProgressBar(playerid, KnockoutBar);

		if(gPlayerData[playerid][ply_HitPoints] < 50.0)
		{
			if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE) && !IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_PAINKILL))
			{
				if(GetTickCountDifference(tickcount(), knockout_Tick[playerid]) > 5000 * gPlayerData[playerid][ply_HitPoints])
				{
					if(gPlayerBitData[playerid] & Bleeding)
					{
						if(frandom(40.0) < (50.0 - gPlayerData[playerid][ply_HitPoints]))
							KnockOutPlayer(playerid, floatround(2000 * (50.0 - gPlayerData[playerid][ply_HitPoints]) + frandom(200 * (50.0 - gPlayerData[playerid][ply_HitPoints]))));
					}
					else
					{
						if(frandom(40.0) < (40.0 - gPlayerData[playerid][ply_HitPoints]))
							KnockOutPlayer(playerid, floatround(2000 * (40.0 - gPlayerData[playerid][ply_HitPoints]) + frandom(200 * (40.0 - gPlayerData[playerid][ply_HitPoints]))));
					}
				}
			}
		}
	}

	return;
}

stock GetPlayerKnockOutTick(playerid)
{
	return knockout_Tick[playerid];
}

stock GetPlayerKnockoutDuration(playerid)
{
	return knockout_Duration[playerid];
}

ACMD:knockout[4](playerid, params[])
{
	KnockOutPlayer(playerid, strval(params));
	return 1;
}
