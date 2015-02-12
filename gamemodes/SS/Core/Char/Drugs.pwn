#include <YSI\y_hooks>


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


static HANDLER = -1;


forward OnPlayerDrugWearOff(playerid, drugtype);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Drugs'...");

	HANDLER = debug_register_handler("drugs");
}

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


stock DefineDrugType(name[], duration)
{
	if(drug_TypeTotal == MAX_DRUG_TYPE)
	{
		printf("ERROR: Max drug types (%d) reached.", MAX_DRUG_TYPE);
		return -1;
	}

	drug_TypeData[drug_TypeTotal][drug_name][0] = EOS;
	strcat(drug_TypeData[drug_TypeTotal][drug_name], name, MAX_DRUG_NAME);
	drug_TypeData[drug_TypeTotal][drug_duration] = duration;

	return drug_TypeTotal++;
}

stock ApplyDrug(playerid, drugtype, customduration = -1)
{
	d:1:HANDLER("[ApplyDrug] playerid:%d drugtype:%d customduration:%d", playerid, drugtype, customduration);
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

	ShowActionText(playerid, sprintf("Taken %s", drug_TypeData[drugtype][drug_name]), 3000);

	return 1;
}

stock RemoveDrug(playerid, drugtype)
{
	d:1:HANDLER("[RemoveDrug] playerid:%d drugtype:%d", playerid, drugtype);
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

ptask DrugsUpdate[100](playerid)
{
	for(new i; i < drug_TypeTotal; i++)
	{
		if(drug_PlayerDrugData[playerid][i][drug_active])
		{
			if(GetTickCountDifference(GetTickCount(), drug_PlayerDrugData[playerid][i][drug_tick]) > drug_TypeData[i][drug_duration])
			{
				ShowActionText(playerid, sprintf("%s has worn off", drug_TypeData[i][drug_name]), 3000);
				RemoveDrug(playerid, i);
				CallLocalFunction("OnPlayerDrugWearOff", "dd", playerid, i);
			}
		}
	}
}

stock IsPlayerUnderDrugEffect(playerid, drugtype)
{
	d:2:HANDLER("[IsPlayerUnderDrugEffect] playerid:%d drugtype:%d", playerid, drugtype);
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!(0 <= drugtype < drug_TypeTotal))
		return 0;

	return drug_PlayerDrugData[playerid][drugtype][drug_active];
}

stock GetDrugName(drugtype, name[])
{
	d:2:HANDLER("[GetDrugName] drugtype:%d", drugtype);
	if(!(0 <= drugtype < drug_TypeTotal))
		return 0;

	name[0] = EOS;
	strcat(name, drug_TypeData[drugtype][drug_name], MAX_DRUG_NAME);

	return 1;
}

stock GetPlayerDrugsList(playerid, output[])
{
	d:2:HANDLER("[GetPlayerDrugsList] playerid:%d", playerid);
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
	d:2:HANDLER("[GetPlayerDrugsAsArray] playerid:%d", playerid);
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
			output[idx++] = drug_PlayerDrugData[playerid][i][drug_totalDuration] - GetTickCountDifference(drug_PlayerDrugData[playerid][i][drug_tick], GetTickCount());
		}
	}

	return idx;
}

stock SetPlayerDrugsFromArray(playerid, input[])
{
	d:2:HANDLER("[SetPlayerDrugsFromArray] playerid:%d", playerid);
	if(!IsPlayerConnected(playerid))
		return 0;

	if(input[0] <= 0)
	{
		printf("ERROR: Attempted to assign drug effects from malformed array, cell 0: %d", input[0]);
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


public OnPlayerSave(playerid, filename[])
{
	d:1:HANDLER("[OnPlayerSave] playerid:%d", playerid);

	new
		length,
		data[1 + (MAX_DRUG_TYPE * 2)];

	length = GetPlayerDrugsAsArray(playerid, data);

	modio_push(filename, _T<D,R,U,G>, length, data);

	#if defined drug_OnPlayerSave
		return drug_OnPlayerSave(playerid, filename);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerSave
	#undef OnPlayerSave
#else
	#define _ALS_OnPlayerSave
#endif
 
#define OnPlayerSave drug_OnPlayerSave
#if defined drug_OnPlayerSave
	forward drug_OnPlayerSave(playerid, filename[]);
#endif

public OnPlayerLoad(playerid, filename[])
{
	d:1:HANDLER("[OnPlayerLoad] playerid:%d", playerid);

	new data[1 + (MAX_DRUG_TYPE * 2)];

	modio_read(filename, _T<D,R,U,G>, sizeof(data), data);

	SetPlayerDrugsFromArray(playerid, data);

	#if defined drug_OnPlayerLoad
		return drug_OnPlayerLoad(playerid, filename);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLoad
	#undef OnPlayerLoad
#else
	#define _ALS_OnPlayerLoad
#endif
 
#define OnPlayerLoad drug_OnPlayerLoad
#if defined drug_OnPlayerLoad
	forward drug_OnPlayerLoad(playerid, filename[]);
#endif
