/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


new
		tab_Check[MAX_PLAYERS],
bool:	tab_IsTabbed[MAX_PLAYERS],
		tab_TabOutTick[MAX_PLAYERS];


forward OnPlayerFocusChange(playerid, status);


hook OnPlayerUpdate(playerid)
{
	tab_Check[playerid] = 0;
	return 1;
}


ptask AfkCheckUpdate[100](playerid)
{
	if(!IsPlayerSpawned(playerid))
		return;

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 10000)
		return;

	new
		comparison = 500,
		Float:x,
		Float:y,
		Float:z,
		playerstate;

	playerstate = GetPlayerState(playerid);

	if(playerstate <= 1)
		GetPlayerVelocity(playerid, z, y, z);

	else if(playerstate <= 3)
		GetVehicleVelocity(GetPlayerVehicleID(playerid), x, y, z);

	if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) < 2000)
		comparison = 3000;

	else if(IsPlayerBeingHijacked(playerid))
		comparison = 3800;

	else if((x == 0.0 && y == 0.0 && z == 0.0))
		comparison = 2500;

	comparison += GetPlayerPing(playerid);

	// ShowActionText(playerid, sprintf("%d :: %s%d - %d", playerstate, (tab_Check[playerid] > comparison) ? ("~r~") : ("~w~"), tab_Check[playerid], comparison), 0);

	if(tab_Check[playerid] > comparison)
	{
		if(!tab_IsTabbed[playerid])
		{
			CallLocalFunction("OnPlayerFocusChange", "dd", playerid, 0);

			log("[FOCUS] %p unfocused game", playerid);

			if(gMaxTaboutTime == 0)
			{
				KickPlayer(playerid, "Unfocused from the game, could starve and cause bugs");
				return;
			}

			tab_TabOutTick[playerid] = GetTickCount();
			tab_IsTabbed[playerid] = true;
		}

		if(!IsPlayerOnAdminDuty(playerid))
		{
			if(GetTickCountDifference(GetTickCount(), tab_TabOutTick[playerid]) > gMaxTaboutTime * 1000)
			{
				KickPlayer(playerid, sprintf("Unfocused for over %d seconds, could starve or cause bugs", gMaxTaboutTime));
				return;
			}
		}
	}

	if(!tab_Check[playerid])
	{
		if(tab_IsTabbed[playerid])
		{
			CallLocalFunction("OnPlayerFocusChange", "dd", playerid, 1);

			log("[FOCUS] %p focused back to game", playerid);

			tab_IsTabbed[playerid] = false;
		}
	}

	tab_Check[playerid] += 100;

	return;
}

stock IsPlayerUnfocused(playerid)
{
	return tab_IsTabbed[playerid];
}
