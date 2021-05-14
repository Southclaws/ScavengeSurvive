/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define IDLE_FOOD_RATE (0.004)


static PlayerBar:HungerBar[MAX_PLAYERS];


hook OnPlayerScriptUpdate(playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return;

	if(!IsPlayerSpawned(playerid))
		return;

	new
		intensity = GetPlayerInfectionIntensity(playerid, 0),
		E_MOVEMENT_TYPE:movementstate,
		Float:food = GetPlayerFP(playerid);

	if(food > 100.0)
		food = 100.0;

	if(intensity)
	{
		food -= IDLE_FOOD_RATE;
	}

	GetPlayerMovementState(playerid, movementstate);

	switch(movementstate)
	{
		case E_MOVEMENT_TYPE_UNKNOWN:	food -= IDLE_FOOD_RATE;
		case E_MOVEMENT_TYPE_IDLE:		food -= IDLE_FOOD_RATE;
		case E_MOVEMENT_TYPE_SITTING:	food -= IDLE_FOOD_RATE * 0.2;
		case E_MOVEMENT_TYPE_CROUCHING:	food -= IDLE_FOOD_RATE * 1.1;
		case E_MOVEMENT_TYPE_JUMPING:	food -= IDLE_FOOD_RATE * 3.2;
		case E_MOVEMENT_TYPE_WALKING:	food -= IDLE_FOOD_RATE * 1.2;
		case E_MOVEMENT_TYPE_RUNNING:	food -= IDLE_FOOD_RATE * 1.8;
		case E_MOVEMENT_TYPE_STOPPING:	food -= IDLE_FOOD_RATE;
		case E_MOVEMENT_TYPE_SPRINTING:	food -= IDLE_FOOD_RATE * 2.2;
		case E_MOVEMENT_TYPE_CLIMBING:	food -= IDLE_FOOD_RATE * 3.5;
		case E_MOVEMENT_TYPE_FALLING:	food -= IDLE_FOOD_RATE;
		case E_MOVEMENT_TYPE_LANDING:	food -= IDLE_FOOD_RATE * 2.0;
		case E_MOVEMENT_TYPE_SWIMMING:	food -= IDLE_FOOD_RATE * 4.0;
		case E_MOVEMENT_TYPE_DIVING:	food -= IDLE_FOOD_RATE * 2.2;
	}

	if(!IsPlayerUnderDrugEffect(playerid, drug_Morphine) && !IsPlayerUnderDrugEffect(playerid, drug_Air))
	{
		if(food < 30.0)
		{
			if(!IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
			{
				if(intensity == 0)
					SetPlayerDrunkLevel(playerid, 0);
			}
			else
			{
				SetPlayerDrunkLevel(playerid, 2000 + floatround((31.0 - food) * 300.0));
			}
		}
		else
		{
			if(intensity == 0)
				SetPlayerDrunkLevel(playerid, 0);
		}
	}

	if(food < 20.0)
		SetPlayerHP(playerid, GetPlayerHP(playerid) - (20.0 - food) / 30.0);

	if(food < 0.0)
		food = 0.0;

	if(IsPlayerHudOn(playerid))
	{
		SetPlayerProgressBarValue(playerid, HungerBar[playerid], food);
		ShowPlayerProgressBar(playerid, HungerBar[playerid]);
	}

	SetPlayerFP(playerid, food);

	return;
}

stock TogglePlayerHungerBar(playerid, bool:toggle)
{
	if(toggle)
		ShowPlayerProgressBar(playerid, HungerBar[playerid]);
	else
		HidePlayerProgressBar(playerid, HungerBar[playerid]);
}


hook OnPlayerSpawnChar(playerid)
{
	UpdateFoodBarWithScaleProfile(playerid);
}

hook OnPlayerConnect(playerid)
{
	HungerBar[playerid] = INVALID_PLAYER_BAR_ID;
	UpdateFoodBarWithScaleProfile(playerid);
}

UpdateFoodBarWithScaleProfile(playerid)
{
	new e_UI_SCALE_PROFILES:profile = GetPlayerUIScaleProfile(playerid);

	DestroyPlayerProgressBar(playerid, HungerBar[playerid]);
	HungerBar[playerid] = CreatePlayerProgressBar(playerid,
		548.000000 + (profile == e_UI_SCALE_WIDESCREENFIX ? 35.0 : 0.0),
		36.000000,
		62.000000 * (profile == e_UI_SCALE_WIDESCREENFIX ? 0.66 : 1.0),
		3.200000,
		536354815,
		100.0000,
		0);
}
