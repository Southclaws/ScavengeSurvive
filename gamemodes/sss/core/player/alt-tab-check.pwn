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


#include <YSI\y_hooks>


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

			logf("[FOCUS] %p unfocused game", playerid);

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

			logf("[FOCUS] %p focused back to game", playerid);

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
