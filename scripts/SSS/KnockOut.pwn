KnockOutPlayer(playerid)
{
	SetPlayerProgressBarValue(playerid, KnockoutBar, tickcount() - gPlayerKnockOutTick[playerid]);
	SetPlayerProgressBarMaxValue(playerid, KnockoutBar, 1000 * (40.0 - gPlayerHP[playerid]));
	ShowPlayerProgressBar(playerid, KnockoutBar);

	if(IsPlayerInAnyVehicle(playerid))
		ApplyAnimation(playerid, "PED", "CAR_DEAD_LHS", 4.0, 0, 1, 1, 1, 0, 1);

	else
		ApplyAnimation(playerid, "PED", "KO_SHOT_STOM", 4.0, 0, 1, 1, 1, 0, 1);

	gPlayerKnockOutTick[playerid] = tickcount();
	t:bPlayerGameSettings[playerid]<KnockedOut>;
}

WakeUpPlayer(playerid)
{
	HidePlayerProgressBar(playerid, KnockoutBar);

	if(IsPlayerInAnyVehicle(playerid))
		ClearAnimations(playerid);

	else
		ApplyAnimation(playerid, "PED", "GETUP_FRONT", 4.0, 0, 1, 1, 0, 0);

	gPlayerKnockOutTick[playerid] = tickcount();
	f:bPlayerGameSettings[playerid]<KnockedOut>;
}
