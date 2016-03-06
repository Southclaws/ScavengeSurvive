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


//ptask PlayerInfectionUpdate[1000](playerid)
stock PlayerInfectionUpdate(playerid)
{
	if(infect_InfectionIntensity[playerid][INFECT_TYPE_FOOD] == 0 || infect_InfectionIntensity[playerid][INFECT_TYPE_WOUND] == 0)
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

public OnPlayerSave(playerid, filename[])
{
	modio_push(filename, _T<I,N,F,C>, 2, infect_InfectionIntensity[playerid]);

	#if defined infect_OnPlayerSave
		return infect_OnPlayerSave(playerid, filename);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerSave
	#undef OnPlayerSave
#else
	#define _ALS_OnPlayerSave
#endif
 
#define OnPlayerSave infect_OnPlayerSave
#if defined infect_OnPlayerSave
	forward infect_OnPlayerSave(playerid, filename[]);
#endif

public OnPlayerLoad(playerid, filename[])
{
	modio_read(filename, _T<I,N,F,C>, 2, infect_InfectionIntensity[playerid]);

	#if defined infect_OnPlayerLoad
		return infect_OnPlayerLoad(playerid, filename);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLoad
	#undef OnPlayerLoad
#else
	#define _ALS_OnPlayerLoad
#endif
 
#define OnPlayerLoad infect_OnPlayerLoad
#if defined infect_OnPlayerLoad
	forward infect_OnPlayerLoad(playerid, filename[]);
#endif
