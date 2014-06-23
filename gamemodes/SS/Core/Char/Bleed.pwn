//new const MIN_BLEED_RATE = 0.01;
//new const MAX_BLEED_RATE = 0.4;


static
Float:	bld_BleedRate[MAX_PLAYERS];


ptask BleedUpdate[1000](playerid)
{
	if(!IsPlayerSpawned(playerid))
		return;

	if(bld_BleedRate[playerid] > 0.0)
	{
		if(random(100) < 60)
			GivePlayerHP(playerid, -bld_BleedRate[playerid]);

		if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_BLOOD))
		{
			if(frandom(4.0) < 4.0 - (bld_BleedRate[playerid] * 10.0))
				RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
		}
		else
		{
			if(frandom(4.0) < (bld_BleedRate[playerid] * 10.0))
				SetPlayerAttachedObject(playerid, ATTACHSLOT_BLOOD, 18706, 1,  0.088999, 0.020000, 0.044999,  0.088999, 0.020000, 0.044999,  1.179000, 1.510999, 0.005000);
		}
	}
	else
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_BLOOD))
			RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);

		GivePlayerHP(playerid, 0.000925925); // One third of the health bar regenerates each real-time hour
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Morphine))
	{
		SetPlayerDrunkLevel(playerid, 2200);

		if(random(100) < 80)
			GivePlayerHP(playerid, 0.05);
	}

	return;
}

stock SetPlayerBleedRate(playerid, Float:rate)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	bld_BleedRate[playerid] = rate;

	return 1;
}

forward Float:GetPlayerBleedRate(playerid);
stock Float:GetPlayerBleedRate(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return bld_BleedRate[playerid];
}

ACMD:bleed[4](playerid, params[])
{
	SetPlayerBleedRate(playerid, floatstr(params));
	return 1;
}
