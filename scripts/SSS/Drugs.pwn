#define MAX_DRUG_TYPE (7)


new
		gPlayerDrugUseTick[MAX_PLAYERS][MAX_DRUG_TYPE],
		bPlayerDrugEffects[MAX_PLAYERS];


ApplyDrug(playerid, drugtype)
{
	gPlayerDrugUseTick[playerid][drugtype] = tickcount();
	t:bPlayerDrugEffects[playerid]<(1 << drugtype)>;
}

RemoveDrug(playerid, drugtype)
{
	gPlayerDrugUseTick[playerid][drugtype] = 0;
	f:bPlayerDrugEffects[playerid]<(1 << drugtype)>;
}

GetPlayerDrugUseTick(playerid, drugtype)
{
	return gPlayerDrugUseTick[playerid][drugtype];
}

IsPlayerUnderDrugEffect(playerid, drugtype)
{
	if(bPlayerDrugEffects[playerid] & (1 << drugtype))
		return 1;

	return 0;
}
