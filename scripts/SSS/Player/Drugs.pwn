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
