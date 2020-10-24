/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


enum
{
	INFECT_TYPE_FOOD,
	INFECT_TYPE_WOUND
}


static
	infect_InfectionIntensity[MAX_PLAYERS][2],
	infect_LastShake[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	infect_InfectionIntensity[playerid][0] = 0;
	infect_InfectionIntensity[playerid][1] = 0;
	infect_LastShake[playerid] = 0;

	return 1;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	infect_InfectionIntensity[playerid][0] = 0;
	infect_InfectionIntensity[playerid][1] = 0;
	infect_LastShake[playerid] = 0;
}

hook OnPlayerScriptUpdate(playerid)
{
	if(infect_InfectionIntensity[playerid][INFECT_TYPE_FOOD] == 0 && infect_InfectionIntensity[playerid][INFECT_TYPE_WOUND] == 0)
		return;

	if(IsPlayerUnderDrugEffect(playerid, drug_Morphine))
		return;

	if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
		return;

	if(IsPlayerUnderDrugEffect(playerid, drug_Air))
		return;

	if(GetPlayerDrunkLevel(playerid) == 0)
	{
		if(GetTickCountDifference(GetTickCount(), infect_LastShake[playerid]) > 500 * GetPlayerHP(playerid))
		{
			infect_LastShake[playerid] = GetTickCount();
			SetPlayerDrunkLevel(playerid, 5000);
		}
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), infect_LastShake[playerid]) > 100 * (120 - GetPlayerHP(playerid)) || 1 < GetPlayerDrunkLevel(playerid) < 2000)
		{
			infect_LastShake[playerid] = GetTickCount();
			SetPlayerDrunkLevel(playerid, 0);
		}
	}

	return;
}

stock GetPlayerInfectionIntensity(playerid, type)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return infect_InfectionIntensity[playerid][type];
}

stock SetPlayerInfectionIntensity(playerid, type, amount)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	infect_InfectionIntensity[playerid][type] = amount;

	return 1;
}

hook OnPlayerSave(playerid, filename[])
{
	modio_push(filename, _T<I,N,F,C>, 2, infect_InfectionIntensity[playerid]);
}

hook OnPlayerLoad(playerid, filename[])
{
	modio_read(filename, _T<I,N,F,C>, 2, infect_InfectionIntensity[playerid]);
}
