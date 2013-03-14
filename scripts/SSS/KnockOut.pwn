static
	knockout_Tick[MAX_PLAYERS],
	knockout_Duration[MAX_PLAYERS];


KnockOutPlayer(playerid, duration)
{
	SetPlayerProgressBarValue(playerid, KnockoutBar, tickcount() - knockout_Tick[playerid]);
	SetPlayerProgressBarMaxValue(playerid, KnockoutBar, 1000 * (40.0 - gPlayerHP[playerid]));
	ShowPlayerProgressBar(playerid, KnockoutBar);

	if(IsPlayerInAnyVehicle(playerid))
		ApplyAnimation(playerid, "PED", "CAR_DEAD_LHS", 4.0, 0, 1, 1, 1, 0, 1);

	else
		ApplyAnimation(playerid, "PED", "KO_SHOT_STOM", 4.0, 0, 1, 1, 1, 0, 1);

	knockout_Tick[playerid] = tickcount();
	knockout_Duration[playerid] = duration;
	t:bPlayerGameSettings[playerid]<KnockedOut>;
}

WakeUpPlayer(playerid)
{
	HidePlayerProgressBar(playerid, KnockoutBar);

	if(IsPlayerInAnyVehicle(playerid))
		ClearAnimations(playerid);

	else
		ApplyAnimation(playerid, "PED", "GETUP_FRONT", 4.0, 0, 1, 1, 0, 0);

	knockout_Tick[playerid] = tickcount();
	f:bPlayerGameSettings[playerid]<KnockedOut>;
}

GetPlayerKnockOutTick(playerid)
{
	return knockout_Tick[playerid];
}

GetPlayerKnockoutDuration(playerid)
{
	return knockout_Duration[playerid];
}

