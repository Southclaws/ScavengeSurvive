new
	infect_LastShake[MAX_PLAYERS];


PlayerInfectionUpdate(playerid)
{
	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE))
		return;

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
		return;

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
		return;

	if(GetPlayerDrunkLevel(playerid) == 0)
	{
		if(tickcount() - infect_LastShake[playerid] > 500 * gPlayerData[playerid][ply_HitPoints])
		{
			infect_LastShake[playerid] = tickcount();
			SetPlayerDrunkLevel(playerid, 5000);
		}
	}
	else
	{
		if(tickcount() - infect_LastShake[playerid] > 100 * (120 - gPlayerData[playerid][ply_HitPoints]) || 1 < GetPlayerDrunkLevel(playerid) < 2000)
		{
			infect_LastShake[playerid] = tickcount();
			SetPlayerDrunkLevel(playerid, 0);
		}
	}

	return;
}
