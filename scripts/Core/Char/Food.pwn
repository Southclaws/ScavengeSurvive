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
		gPlayerData[playerid][ply_FoodPoints] -= IDLE_FOOD_RATE;
	}

	if(animidx == 43) // Sitting
	{
		gPlayerData[playerid][ply_FoodPoints] -= IDLE_FOOD_RATE * 0.2;
	}
	else if(animidx == 1159) // Crouching
	{
		gPlayerData[playerid][ply_FoodPoints] -= IDLE_FOOD_RATE * 1.1;
	}
	else if(animidx == 1195) // Jumping
	{
		gPlayerData[playerid][ply_FoodPoints] -= IDLE_FOOD_RATE * 3.2;	
	}
	else if(animidx == 1231) // Running
	{
		if(k & KEY_WALK) // Walking
		{
			gPlayerData[playerid][ply_FoodPoints] -= IDLE_FOOD_RATE * 1.2;
		}
		else if(k & KEY_SPRINT) // Sprinting
		{
			gPlayerData[playerid][ply_FoodPoints] -= IDLE_FOOD_RATE * 2.2;
		}
		else if(k & KEY_JUMP) // Jump
		{
			gPlayerData[playerid][ply_FoodPoints] -= IDLE_FOOD_RATE * 3.2;
		}
		else
		{
			gPlayerData[playerid][ply_FoodPoints] -= IDLE_FOOD_RATE * 2.0;
		}
	}
	else
	{
		gPlayerData[playerid][ply_FoodPoints] -= IDLE_FOOD_RATE;
	}

	if(gPlayerData[playerid][ply_FoodPoints] > 100.0)
		gPlayerData[playerid][ply_FoodPoints] = 100.0;

	if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE) && !IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
	{
		if(gPlayerData[playerid][ply_FoodPoints] < 30.0)
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
				SetPlayerDrunkLevel(playerid, 2000 + floatround((31.0 - gPlayerData[playerid][ply_FoodPoints]) * 300.0));
			}
		}
		else
		{
			if(!(bPlayerGameSettings[playerid] & Infected))
				SetPlayerDrunkLevel(playerid, 0);
		}
	}

	if(gPlayerData[playerid][ply_FoodPoints] < 20.0)
		gPlayerData[playerid][ply_HitPoints] -= (20.0 - gPlayerData[playerid][ply_FoodPoints]) / 10.0;

	if(gPlayerData[playerid][ply_FoodPoints] < 0.0)
		gPlayerData[playerid][ply_FoodPoints] = 0.0;

	if(bPlayerGameSettings[playerid] & ShowHUD)
	{
		PlayerTextDrawLetterSize(playerid, HungerBarForeground, 0.500000, -(gPlayerData[playerid][ply_FoodPoints] / 10.0));
		PlayerTextDrawShow(playerid, HungerBarBackground);
		PlayerTextDrawShow(playerid, HungerBarForeground);
	}

	return;
}
