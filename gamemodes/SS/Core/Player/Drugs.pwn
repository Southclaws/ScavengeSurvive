#define MAX_DRUG_TYPE (7)

//#define 




new
	drug_PlayerDrugUseTick[MAX_PLAYERS][MAX_DRUG_TYPE],
	drug_bPlayerDrugEffects[MAX_PLAYERS];


ApplyDrug(playerid, drugtype)
{
	drug_PlayerDrugUseTick[playerid][drugtype] = tickcount();
	t:drug_bPlayerDrugEffects[playerid]<(1 << drugtype)>;
}

RemoveDrug(playerid, drugtype)
{
	drug_PlayerDrugUseTick[playerid][drugtype] = 0;
	f:drug_bPlayerDrugEffects[playerid]<(1 << drugtype)>;
}


DrugsUpdate(playerid)
{
	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ANTIBIOTIC))
	{
		if(GetTickCountDifference(tickcount(), GetPlayerDrugUseTick(playerid, DRUG_TYPE_ANTIBIOTIC)) > 300000)
			RemoveDrug(playerid, DRUG_TYPE_ANTIBIOTIC);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_PAINKILL))
	{
		if(GetTickCountDifference(tickcount(), drug_PlayerDrugUseTick[playerid][DRUG_TYPE_PAINKILL]) > 300000)
			RemoveDrug(playerid, DRUG_TYPE_PAINKILL);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_LSD))
	{
		if(GetTickCountDifference(tickcount(), drug_PlayerDrugUseTick[playerid][DRUG_TYPE_LSD]) > 300000)
			RemoveDrug(playerid, DRUG_TYPE_LSD);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
	{
		if(GetTickCountDifference(tickcount(), drug_PlayerDrugUseTick[playerid][DRUG_TYPE_AIR]) > 300000)
			RemoveDrug(playerid, DRUG_TYPE_AIR);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE))
	{
		if(GetTickCountDifference(tickcount(), drug_PlayerDrugUseTick[playerid][DRUG_TYPE_MORPHINE]) > 300000)
			RemoveDrug(playerid, DRUG_TYPE_MORPHINE);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
	{
		if(GetTickCountDifference(tickcount(), drug_PlayerDrugUseTick[playerid][DRUG_TYPE_ADRENALINE]) > 300000)
			RemoveDrug(playerid, DRUG_TYPE_ADRENALINE);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_HEROINE))
	{
		if(GetTickCountDifference(tickcount(), drug_PlayerDrugUseTick[playerid][DRUG_TYPE_HEROINE]) > 300000)
			RemoveDrug(playerid, DRUG_TYPE_HEROINE);
	}
}


GetPlayerDrugUseTick(playerid, drugtype)
{
	return drug_PlayerDrugUseTick[playerid][drugtype];
}

IsPlayerUnderDrugEffect(playerid, drugtype)
{
	if(drug_bPlayerDrugEffects[playerid] & (1 << drugtype))
		return 1;

	return 0;
}

RemoveAllDrugs(playerid)
{
	drug_bPlayerDrugEffects[playerid] = 0;
}
