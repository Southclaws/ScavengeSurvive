#define IDLE_FOOD_RATE (0.004)


ptask FoodUpdate[1000](playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return;

	new
		animidx = GetPlayerAnimationIndex(playerid),
		k,
		ud,
		lr,
		Float:food;

	GetPlayerKeys(playerid, k, ud, lr);
	food = GetPlayerFP(playerid);

	if(IsPlayerInfected(playerid))
	{
		food -= IDLE_FOOD_RATE;
	}

	if(animidx == 43) // Sitting
	{
		food -= IDLE_FOOD_RATE * 0.2;
	}
	else if(animidx == 1159) // Crouching
	{
		food -= IDLE_FOOD_RATE * 1.1;
	}
	else if(animidx == 1195) // Jumping
	{
		food -= IDLE_FOOD_RATE * 3.2;	
	}
	else if(animidx == 1231) // Running
	{
		if(k & KEY_WALK) // Walking
		{
			food -= IDLE_FOOD_RATE * 1.2;
		}
		else if(k & KEY_SPRINT) // Sprinting
		{
			food -= IDLE_FOOD_RATE * 2.2;
		}
		else if(k & KEY_JUMP) // Jump
		{
			food -= IDLE_FOOD_RATE * 3.2;
		}
		else
		{
			food -= IDLE_FOOD_RATE * 2.0;
		}
	}
	else
	{
		food -= IDLE_FOOD_RATE;
	}

	if(food > 100.0)
		food = 100.0;

	if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE) && !IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
	{
		if(food < 30.0)
		{
			if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
			{
				if(!IsPlayerInfected(playerid))
					SetPlayerDrunkLevel(playerid, 0);
			}
			else
			{
				SetPlayerDrunkLevel(playerid, 2000 + floatround((31.0 - food) * 300.0));
			}
		}
		else
		{
			if(!IsPlayerInfected(playerid))
				SetPlayerDrunkLevel(playerid, 0);
		}
	}

	if(food < 20.0)
		SetPlayerHP(playerid, GetPlayerHP(playerid) - (20.0 - food) / 10.0);

	if(food < 0.0)
		food = 0.0;

	if(GetPlayerBitFlag(playerid, ShowHUD))
	{
		PlayerTextDrawLetterSize(playerid, HungerBarForeground[playerid], 0.500000, -(food / 10.0));
		PlayerTextDrawShow(playerid, HungerBarBackground[playerid]);
		PlayerTextDrawShow(playerid, HungerBarForeground[playerid]);
	}

	SetPlayerFP(playerid, food);

	return;
}
