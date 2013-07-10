#define IDLE_FOOD_RATE (0.004)


ptask FoodUpdate[1000](playerid)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return;

	new
		animidx = GetPlayerAnimationIndex(playerid),
		k,
		ud,
		lr;

	GetPlayerKeys(playerid, k, ud, lr);

	if(bPlayerGameSettings[playerid] & Infected)
	{
		gPlayerFP[playerid] -= IDLE_FOOD_RATE;
	}

	if(animidx == 43) // Sitting
	{
		gPlayerFP[playerid] -= IDLE_FOOD_RATE * 0.2;
	}
	else if(animidx == 1159) // Crouching
	{
		gPlayerFP[playerid] -= IDLE_FOOD_RATE * 1.1;
	}
	else if(animidx == 1195) // Jumping
	{
		gPlayerFP[playerid] -= IDLE_FOOD_RATE * 3.2;	
	}
	else if(animidx == 1231) // Running
	{
		if(k & KEY_WALK) // Walking
		{
			gPlayerFP[playerid] -= IDLE_FOOD_RATE * 1.2;
		}
		else if(k & KEY_SPRINT) // Sprinting
		{
			gPlayerFP[playerid] -= IDLE_FOOD_RATE * 2.2;
		}
		else if(k & KEY_JUMP) // Jump
		{
			gPlayerFP[playerid] -= IDLE_FOOD_RATE * 3.2;
		}
		else
		{
			gPlayerFP[playerid] -= IDLE_FOOD_RATE * 2.0;
		}
	}
	else
	{
		gPlayerFP[playerid] -= IDLE_FOOD_RATE;
	}

	if(gPlayerFP[playerid] > 100.0)
		gPlayerFP[playerid] = 100.0;

	if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE) && !IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
	{
		if(gPlayerFP[playerid] < 30.0)
		{
			if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
			{
				if(!(bPlayerGameSettings[playerid] & Infected))
					SetPlayerDrunkLevel(playerid, 0);

				if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_ADRENALINE) > 300000)
					RemoveDrug(playerid, DRUG_TYPE_ADRENALINE);
			}
			else
			{
				SetPlayerDrunkLevel(playerid, 2000 + floatround((31.0 - gPlayerFP[playerid]) * 300.0));
			}
		}
		else
		{
			if(!(bPlayerGameSettings[playerid] & Infected))
				SetPlayerDrunkLevel(playerid, 0);
		}
	}

	if(gPlayerFP[playerid] < 20.0)
		gPlayerHP[playerid] -= (20.0 - gPlayerFP[playerid]) / 10.0;

	if(gPlayerFP[playerid] < 0.0)
		gPlayerFP[playerid] = 0.0;

	if(bPlayerGameSettings[playerid] & ShowHUD)
	{
		PlayerTextDrawLetterSize(playerid, HungerBarForeground, 0.500000, -(gPlayerFP[playerid] / 10.0));
		PlayerTextDrawShow(playerid, HungerBarBackground);
		PlayerTextDrawShow(playerid, HungerBarForeground);
	}

	return;
}
