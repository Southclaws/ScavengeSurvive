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
		if(GetTickCountDifference(GetTickCount(), infect_LastShake[playerid]) > 500 * GetPlayerHP(playerid))
		{
			infect_LastShake[playerid] = GetTickCount();
			SetPlayerDrunkLevel(playerid, 5000);
		}
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), infect_LastShake[playerid]) > 100 * (120 - GetPlayerHP(playerid)) || 1 < GetPlayerDrunkLevel(playerid) < 2000)
		{
			infect_LastShake[playerid] = GetTickCount();
			SetPlayerDrunkLevel(playerid, 0);
		}
	}

	return;
}
