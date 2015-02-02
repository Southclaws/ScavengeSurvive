//new const MIN_BLEED_RATE = 0.01;
//new const MAX_BLEED_RATE = 0.4;


static
Float:	bld_BleedRate[MAX_PLAYERS];


static
		HANDLER = -1;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Bleed'...");

	HANDLER = debug_register_handler("bleed");
}


ptask BleedUpdate[100](playerid)
{
	if(!IsPlayerSpawned(playerid))
	{
		RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
		return;
	}

	if(IsPlayerOnAdminDuty(playerid))
	{
		RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);		
		return;
	}

	if(IsNaN(bld_BleedRate[playerid]) || bld_BleedRate[playerid] < 0.0)
		bld_BleedRate[playerid] = 0.0;

	if(bld_BleedRate[playerid] > 0.0)
	{
		new
			Float:hp = GetPlayerHP(playerid),
			Float:slowrate = (((((100.0 - hp) / 360.0) * bld_BleedRate[playerid]) / GetPlayerWounds(playerid)) / 100.0);

		if(frandom(1.0) < 0.7)
		{
			SetPlayerHP(playerid, hp - bld_BleedRate[playerid]);

			if(GetPlayerHP(playerid) < 0.1)
				SetPlayerHP(playerid, 0.0);
		}

		/*
			Slow bleeding based on health and wound count. Less wounds means
			faster degradation of bleed rate. As blood rate drops, the bleed
			rate will slow down faster (pseudo blood pressure). Results in a
			bleed-out that slows down faster over time (only subtly). No wounds
			will automatically stop the bleed rate due to the nature of the
			formula (however this is still intentional).
		*/
		if(random(100) < 50)
			bld_BleedRate[playerid] -= slowrate;

		if(debug_conditional(HANDLER, 1))
			ShowActionText(playerid, sprintf("HP: %f Bleed-rate: %f~n~Wounds %d Bleed slow-rate: %f", hp, bld_BleedRate[playerid], GetPlayerWounds(playerid)));

		if(!IsPlayerInAnyVehicle(playerid))
		{
			if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_BLOOD))
			{
				if(frandom(0.1) < 0.1 - bld_BleedRate[playerid])
					RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
			}
			else
			{
				if(frandom(0.1) < bld_BleedRate[playerid])
					SetPlayerAttachedObject(playerid, ATTACHSLOT_BLOOD, 18706, 1,  0.088999, 0.020000, 0.044999,  0.088999, 0.020000, 0.044999,  1.179000, 1.510999, 0.005000);
			}
		}
		else
		{
			RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
		}
	}
	else
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_BLOOD))
			RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);

		new intensity = GetPlayerInfectionIntensity(playerid, 1);

		GivePlayerHP(playerid, 0.0001925925 * GetPlayerFP(playerid) * (intensity ? 0.5 : 1.0));

		if(bld_BleedRate[playerid] < 0.0)
			bld_BleedRate[playerid] = 0.0;
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
	if(!IsValidPlayerID(playerid))
		return 0.0;

	return bld_BleedRate[playerid];
}
