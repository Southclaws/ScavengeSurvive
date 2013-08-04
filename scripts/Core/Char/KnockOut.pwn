static
	knockout_Tick[MAX_PLAYERS],
	knockout_Duration[MAX_PLAYERS];


KnockOutPlayer(playerid, duration)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 0;

	SetPlayerProgressBarValue(playerid, KnockoutBar, tickcount() - knockout_Tick[playerid]);
	SetPlayerProgressBarMaxValue(playerid, KnockoutBar, 1000 * (40.0 - gPlayerData[playerid][ply_HitPoints]));
	ShowPlayerProgressBar(playerid, KnockoutBar);

	knockout_Tick[playerid] = tickcount();
	knockout_Duration[playerid] = duration;
	t:bPlayerGameSettings[playerid]<KnockedOut>;

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
	f:bPlayerGameSettings[playerid]<KnockedOut>;
}

KnockOutUpdate(playerid)
{
	if(bPlayerGameSettings[playerid] & Dying)
	{
		f:bPlayerGameSettings[playerid]<KnockedOut>;
		HidePlayerProgressBar(playerid, KnockoutBar);
		return;
	}

	if(bPlayerGameSettings[playerid] & KnockedOut)
	{
		if(bPlayerGameSettings[playerid] & AdminDuty)
			WakeUpPlayer(playerid);

		new animidx = GetPlayerAnimationIndex(playerid);

		if(animidx != 1207 && animidx != 1018 && animidx != 1001)
			KnockOutPlayer(playerid, GetPlayerKnockoutDuration(playerid) - (tickcount() - GetPlayerKnockOutTick(playerid)));

		SetPlayerProgressBarValue(playerid, KnockoutBar, tickcount() - GetPlayerKnockOutTick(playerid));
		SetPlayerProgressBarMaxValue(playerid, KnockoutBar, GetPlayerKnockoutDuration(playerid));
		UpdatePlayerProgressBar(playerid, KnockoutBar);

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			SetVehicleEngine(GetPlayerVehicleID(playerid), 0);

		if(tickcount() - GetPlayerKnockOutTick(playerid) >= GetPlayerKnockoutDuration(playerid))
		{
			WakeUpPlayer(playerid);
		}
	}
	else
	{
		HidePlayerProgressBar(playerid, KnockoutBar);

		if(gPlayerData[playerid][ply_HitPoints] < 50.0)
		{
			if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE) && !IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_PAINKILL))
			{
				if(tickcount() - GetPlayerKnockOutTick(playerid) > 5000 * gPlayerData[playerid][ply_HitPoints])
				{
					if(bPlayerGameSettings[playerid] & Bleeding)
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

GetPlayerKnockOutTick(playerid)
{
	return knockout_Tick[playerid];
}

GetPlayerKnockoutDuration(playerid)
{
	return knockout_Duration[playerid];
}

ACMD:knockout[4](playerid, params[])
{
	KnockOutPlayer(playerid, strval(params));
	return 1;
}
