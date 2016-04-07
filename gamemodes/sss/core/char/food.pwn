/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI_4\y_hooks>


#define IDLE_FOOD_RATE (0.004)


new // TODO: replace this with a PlayerProgressBar
PlayerText:	HungerBarBackground[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	HungerBarForeground[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};


ptask FoodUpdate[1000](playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return;

	if(!IsPlayerSpawned(playerid))
		return;

	new
		intensity = GetPlayerInfectionIntensity(playerid, 0),
		animidx = GetPlayerAnimationIndex(playerid),
		k,
		ud,
		lr,
		Float:food;

	GetPlayerKeys(playerid, k, ud, lr);
	food = GetPlayerFP(playerid);

	if(intensity)
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

	if(GetPlayerBitFlag(playerid, ShowHUD))
	{
		PlayerTextDrawLetterSize(playerid, HungerBarForeground[playerid], 0.500000, -(food / 10.0));
		PlayerTextDrawShow(playerid, HungerBarBackground[playerid]);
		PlayerTextDrawShow(playerid, HungerBarForeground[playerid]);
	}

	SetPlayerFP(playerid, food);

	return;
}


hook OnPlayerConnect(playerid)
{
	HungerBarBackground[playerid]	=CreatePlayerTextDraw(playerid, 612.000000, 101.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, HungerBarBackground[playerid], 255);
	PlayerTextDrawFont				(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, HungerBarBackground[playerid], 0.500000, -10.200000);
	PlayerTextDrawColor				(playerid, HungerBarBackground[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, HungerBarBackground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawUseBox			(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, HungerBarBackground[playerid], 255);
	PlayerTextDrawTextSize			(playerid, HungerBarBackground[playerid], 618.000000, 10.000000);

	HungerBarForeground[playerid]	=CreatePlayerTextDraw(playerid, 613.000000, 100.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, HungerBarForeground[playerid], 255);
	PlayerTextDrawFont				(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, HungerBarForeground[playerid], 0.500000, -10.000000);
	PlayerTextDrawColor				(playerid, HungerBarForeground[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, HungerBarForeground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawUseBox			(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, HungerBarForeground[playerid], -2130771840);
	PlayerTextDrawTextSize			(playerid, HungerBarForeground[playerid], 617.000000, 10.000000);
}
