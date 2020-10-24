/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_DRUG_TYPE	(12)
#define MAX_DRUG_NAME	(32)


enum E_DRUG_TYPE_DATA
{
	drug_name[MAX_DRUG_NAME],
	drug_duration
}

enum E_PLAYER_DRUG_DATA
{
	drug_active,
	drug_tick,
	drug_totalDuration
}


static
	drug_TypeData[MAX_DRUG_TYPE][E_DRUG_TYPE_DATA],
	drug_TypeTotal,

	drug_PlayerDrugData[MAX_PLAYERS][MAX_DRUG_TYPE][E_PLAYER_DRUG_DATA];


forward OnPlayerDrugWearOff(playerid, drugtype);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerDisconnect(playerid)
{
	defer _drugs_Reset(playerid);
}

timer _drugs_Reset[100](playerid)
{
	RemoveAllDrugs(playerid);
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	RemoveAllDrugs(playerid);
}


/*==============================================================================

	Global Variables

==============================================================================*/


stock DefineDrugType(const name[], duration)
{
	if(drug_TypeTotal == MAX_DRUG_TYPE)
	{
		err("Max drug types (%d) reached.", MAX_DRUG_TYPE);
		return -1;
	}

	drug_TypeData[drug_TypeTotal][drug_name][0] = EOS;
	strcat(drug_TypeData[drug_TypeTotal][drug_name], name, MAX_DRUG_NAME);
	drug_TypeData[drug_TypeTotal][drug_duration] = duration;

	return drug_TypeTotal++;
}

stock ApplyDrug(playerid, drugtype, customduration = -1)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!(0 <= drugtype < drug_TypeTotal))
		return 0;

	if(drug_PlayerDrugData[playerid][drugtype][drug_active])
	{
		drug_PlayerDrugData[playerid][drugtype][drug_totalDuration] += customduration == -1 ? drug_TypeData[drugtype][drug_duration] : customduration;
	}
	else
	{
		drug_PlayerDrugData[playerid][drugtype][drug_active] = true;
		drug_PlayerDrugData[playerid][drugtype][drug_tick] = GetTickCount();
		drug_PlayerDrugData[playerid][drugtype][drug_totalDuration] = customduration == -1 ? drug_TypeData[drugtype][drug_duration] : customduration;
	}

	ShowActionText(playerid, sprintf(ls(playerid, "DRUGTAKEN", true), drug_TypeData[drugtype][drug_name]), 3000);

	return 1;
}

stock RemoveDrug(playerid, drugtype)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!(0 <= drugtype < drug_TypeTotal))
		return 0;

	drug_PlayerDrugData[playerid][drugtype][drug_active] = false;
	drug_PlayerDrugData[playerid][drugtype][drug_tick] = 0;
	drug_PlayerDrugData[playerid][drugtype][drug_totalDuration] = 0;

	return 1;
}

stock RemoveAllDrugs(playerid)
{
	for(new i; i < drug_TypeTotal; i++)
	{
		if(drug_PlayerDrugData[playerid][i][drug_active])
		{
			drug_PlayerDrugData[playerid][i][drug_active] = false;
			drug_PlayerDrugData[playerid][i][drug_tick] = 0;
			drug_PlayerDrugData[playerid][i][drug_totalDuration] = 0;
		}
	}
}


/*==============================================================================

	Internal

==============================================================================*/


hook OnPlayerScriptUpdate(playerid)
{
	for(new i; i < drug_TypeTotal; i++)
	{
		if(drug_PlayerDrugData[playerid][i][drug_active])
		{
			if(GetTickCountDifference(GetTickCount(), drug_PlayerDrugData[playerid][i][drug_tick]) > drug_TypeData[i][drug_duration])
			{
				ShowActionText(playerid, sprintf(ls(playerid, "DRUGWORNOFF", true), drug_TypeData[i][drug_name]), 3000);
				RemoveDrug(playerid, i);
				CallLocalFunction("OnPlayerDrugWearOff", "dd", playerid, i);
			}
		}
	}
}

stock IsPlayerUnderDrugEffect(playerid, drugtype)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!(0 <= drugtype < drug_TypeTotal))
		return 0;

	return drug_PlayerDrugData[playerid][drugtype][drug_active];
}

stock GetDrugName(drugtype, name[])
{
	if(!(0 <= drugtype < drug_TypeTotal))
		return 0;

	name[0] = EOS;
	strcat(name, drug_TypeData[drugtype][drug_name], MAX_DRUG_NAME);

	return 1;
}

stock GetPlayerDrugsList(playerid, output[])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new idx;

	for(new i; i < drug_TypeTotal; i++)
	{
		if(drug_PlayerDrugData[playerid][i][drug_active])
			output[idx++] = i;
	}

	return idx;
}

stock GetPlayerDrugsAsArray(playerid, output[])
{
/*
	max size: 1 + MAX_DRUG_TYPE * 2
	header: 1 cell
		drugblock count

	drugblock: 2 cells
		drug_type
		remainingms
*/

	new idx = 1;

	for(new i; i < drug_TypeTotal; i++)
	{
		if(drug_PlayerDrugData[playerid][i][drug_active])
		{
			output[0]++;
			output[idx++] = i;
			output[idx++] = drug_PlayerDrugData[playerid][i][drug_totalDuration] - GetTickCountDifference(GetTickCount(), drug_PlayerDrugData[playerid][i][drug_tick]);
		}
	}

	return idx;
}

stock SetPlayerDrugsFromArray(playerid, input[], length)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(input[0] == 0)
		return 0;

	if(input[0] < 0 || input[0] >= MAX_DRUG_TYPE)
	{
		err("Drug count out of bounds (%d)", input[0]);
		return 0;
	}

	if(length != 1 + (input[0] * 2))
	{
		err("(Drug count * 2) + 1 != data length (%d != %d)", 1 + (input[0] * 2), length);
		return 0;
	}

	for(new i = 1; i < input[0] * 2; i += 2)
	{
		ApplyDrug(playerid, input[i], input[i + 1]);
	}

	return 1;
}


/*==============================================================================

	Save/Load

==============================================================================*/


hook OnPlayerSave(playerid, filename[])
{
	new
		length,
		data[1 + (MAX_DRUG_TYPE * 2)];

	length = GetPlayerDrugsAsArray(playerid, data);

	modio_push(filename, _T<D,R,U,G>, length, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new
		data[1 + (MAX_DRUG_TYPE * 2)],
		length;

	length = modio_read(filename, _T<D,R,U,G>, sizeof(data), data);

	SetPlayerDrugsFromArray(playerid, data, length);
}

CMD:druginfo(playerid, params[])
{
	gBigString[playerid][0] = EOS;

	for(new i; i < drug_TypeTotal; i++)
	{
		if(drug_PlayerDrugData[playerid][i][drug_active])
		{
			format(gBigString[playerid], sizeof(gBigString[]), "%s%s:\ntick: %d\ntotdur: %d\ncalc: %d\n\n",
				gBigString[playerid],
				drug_TypeData[i][drug_name],
				drug_PlayerDrugData[playerid][i][drug_tick],
				drug_PlayerDrugData[playerid][i][drug_totalDuration],
				GetTickCountDifference(GetTickCount(), drug_PlayerDrugData[playerid][i][drug_tick]));
		}
	}

	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Drug Debug (Debrdug!?)", gBigString[playerid], "Close", "");

	return 1;
}