#include <YSI\y_hooks>


#define MAX_WOUNDS	(64)


enum E_WND_TYPE
{
			E_WOUND_FIREARM,
			E_WOUND_MELEE,
			/*
			E_WOUND_LACERATION,
			E_WOUND_BRUISE,
			*/
			E_WOUND_BURN
}

enum E_WOUND_DATA
{
E_WND_TYPE:	wnd_type,
Float:		wnd_bleedrate,
			wnd_calibre,
			wnd_timestamp,
			wnd_bodypart,
			wnd_source[32]
}


static
			dmg_LastHit[MAX_PLAYERS][MAX_PLAYER_NAME],
			dmg_LastHitId[MAX_PLAYERS],
			dmg_LastHitItem[MAX_PLAYERS],
			dmg_LastHitBy[MAX_PLAYERS][MAX_PLAYER_NAME],
			dmg_LastHitById[MAX_PLAYERS],
			dmg_LastHitByItem[MAX_PLAYERS],
			dmg_DeltDamageTick[MAX_PLAYERS],
			dmg_TookDamageTick[MAX_PLAYERS];

static
			wnd_Data[MAX_PLAYERS][MAX_WOUNDS][E_WOUND_DATA],
Iterator:	wnd_Index[MAX_PLAYERS]<MAX_WOUNDS>;


forward Float:GetPlayerKnockoutChance(playerid);


hook OnPlayerConnect(playerid)
{
	dmg_LastHit[playerid][0] = EOS;
	dmg_LastHitId[playerid] = INVALID_PLAYER_ID;
	dmg_LastHitItem[playerid] = 0;
	dmg_LastHitBy[playerid][0] = EOS;
	dmg_LastHitById[playerid] = INVALID_PLAYER_ID;
	dmg_LastHitByItem[playerid] = 0;
	dmg_DeltDamageTick[playerid] = 0;
	dmg_TookDamageTick[playerid] = 0;

	Iter_Clear(wnd_Index[playerid]);

	return 1;
}


new FIREARM_DEBUG = -1;

hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'damage.core'...");

	Iter_Init(wnd_Index);
	FIREARM_DEBUG = debug_register_handler("weapon/damage");
}


stock PlayerInflictWound(playerid, targetid, E_WND_TYPE:type, Float:bleedrate, Float:knockmult, calibre, bodypart, source[])
{
	if(IsPlayerOnAdminDuty(playerid) || IsPlayerOnAdminDuty(targetid))
		return 0;

	new
		woundid = Iter_Free(wnd_Index[targetid]),
		woundcount,
		Float:totalbleedrate = GetPlayerBleedRate(targetid);

	if(woundid == -1)
	{
		SetPlayerHP(targetid, 0.0);
		return 0;
	}

	Iter_Add(wnd_Index[targetid], woundid);

	woundcount = Iter_Count(wnd_Index[targetid]);

	wnd_Data[targetid][woundid][wnd_type] = type;
	wnd_Data[targetid][woundid][wnd_bleedrate] = bleedrate;
	wnd_Data[targetid][woundid][wnd_calibre] = calibre;
	wnd_Data[targetid][woundid][wnd_timestamp] = gettime();
	wnd_Data[targetid][woundid][wnd_bodypart] = bodypart;
	strcpy(wnd_Data[targetid][woundid][wnd_source], source, 32);

	totalbleedrate += bleedrate;
	d:2:FIREARM_DEBUG("[PlayerInflictWound] inflicted bleedrate: %f, total bleedrate = %f", bleedrate, totalbleedrate);

	// Truncate result to 1.0
	totalbleedrate = totalbleedrate > 1.0 ? 1.0 : totalbleedrate;

	SetPlayerBleedRate(targetid, totalbleedrate);
	GivePlayerHP(targetid, -(bleedrate * 10.0));

	switch(bodypart)
	{
		case BODY_PART_TORSO: knockmult *= 1;
		case BODY_PART_GROIN: knockmult *= 1.2;
		case BODY_PART_LEFT_ARM: knockmult *= 0.9;
		case BODY_PART_RIGHT_ARM: knockmult *= 0.9;
		case BODY_PART_LEFT_LEG: knockmult *= 0.9;
		case BODY_PART_RIGHT_LEG: knockmult *= 0.9;
		case BODY_PART_HEAD: knockmult *= 2.0;
	}

	if(frandom(100.0) < knockmult * (woundcount * (totalbleedrate * 30)))
	{
		new
			Float:hp,
			knockouttime;

		hp = GetPlayerHP(targetid);
		knockouttime = floatround((woundcount * (totalbleedrate * 10) * (100.0 - hp) + (200 * (100.0 - hp))));

		if(knockouttime > 1500)
		{
			d:2:FIREARM_DEBUG("[PlayerInflictWound] Knocking out %p for %dms - %d wounds, %f health %f bleedrate", targetid, knockouttime, woundcount, hp, totalbleedrate);
			KnockOutPlayer(targetid, knockouttime);
		}
	}

	dmg_TookDamageTick[targetid] = GetTickCount();

	if(IsPlayerConnected(playerid))
	{
		dmg_DeltDamageTick[playerid] = GetTickCount();

		GetPlayerName(targetid, dmg_LastHit[playerid], MAX_PLAYER_NAME);
		dmg_LastHitId[playerid] = targetid;
		dmg_LastHitItem[playerid] = GetPlayerItem(playerid);

		GetPlayerName(playerid, dmg_LastHitBy[targetid], MAX_PLAYER_NAME);
		dmg_LastHitById[targetid] = playerid;
		dmg_LastHitByItem[targetid] = GetPlayerItem(targetid);

		logf("[WOUND] %p wounds %p. bleedrate %f knockmult %f bodypart %d source '%s'", playerid, targetid, bleedrate, knockmult, bodypart, source);
	}
	else
	{
		logf("[WOUND] %p wounded. bleedrate %f knockmult %f bodypart %d source '%s'", targetid, bleedrate, knockmult, bodypart, source);
	}

	ShowActionText(targetid, sprintf("Wounded~n~%s~n~Severity: %s", source, (knockmult * (woundcount * (totalbleedrate * 30))) < 50.0 ? ("Minor") : ("Severe")), 5000);

	return 1;
}

public OnDeath(playerid, killerid, reason)
{
	Iter_Clear(wnd_Index[playerid]);

	#if defined dmg_OnDeath
		return dmg_OnDeath(playerid, killerid, reason);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnDeath
	#undef OnDeath
#else
	#define _ALS_OnDeath
#endif
 
#define OnDeath dmg_OnDeath
#if defined dmg_OnDeath
	forward dmg_OnDeath(playerid, killerid, reason);
#endif

stock Float:GetPlayerKnockoutChance(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return (Iter_Count(wnd_Index[playerid]) * (GetPlayerBleedRate(playerid) * 30));
}

// dmg_LastHit
stock GetLastHit(playerid, name[MAX_PLAYER_NAME])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	name[0] = EOS;
	strcat(name, dmg_LastHit[playerid]);

	return 1;
}

// dmg_LastHitId
stock GetLastHitId(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dmg_LastHitId[playerid];
}

// dmg_LastHitId
stock GetLastHitWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dmg_LastHitId[playerid];
}

// dmg_LastHitItem
stock GetLastHitBy(playerid, name[MAX_PLAYER_NAME])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	name[0] = EOS;
	strcat(name, dmg_LastHitItem[playerid]);

	return 1;
}

// dmg_LastHitById
stock GetLastHitById(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dmg_LastHitById[playerid];
}

// dmg_LastHitByItem
stock GetLastHitByWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dmg_LastHitByItem[playerid];
}

// dmg_DeltDamageTick
stock GetPlayerDeltDamageTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dmg_DeltDamageTick[playerid];
}

// dmg_TookDamageTick
stock GetPlayerTookDamageTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dmg_TookDamageTick[playerid];
}

// wnd_
stock RemovePlayerWounds(playerid, amount = 1)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(Iter_Count(wnd_Index[playerid]) == 0)
		return 0;

	new idx;

	foreach(new i : wnd_Index[playerid])
	{
		if(idx == amount)
			break;

		new next;

		Iter_SafeRemove(wnd_Index[playerid], i, next);

		i = next;
		idx++;
	}

	return 1;
}

stock GetPlayerWounds(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return Iter_Count(wnd_Index[playerid]);
}

stock GetPlayerWoundsPerBodypart(playerid, output[7])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	foreach(new i : wnd_Index[playerid])
	{
		switch(wnd_Data[playerid][i][wnd_bodypart])
		{
			case BODY_PART_TORSO:		output[0]++;
			case BODY_PART_GROIN:		output[1]++;
			case BODY_PART_LEFT_ARM:	output[2]++;
			case BODY_PART_RIGHT_ARM:	output[3]++;
			case BODY_PART_LEFT_LEG:	output[4]++;
			case BODY_PART_RIGHT_LEG:	output[5]++;
			case BODY_PART_HEAD:		output[6]++;
			default:					output[0]++;
		}
	}

	return 1;
}

stock GetPlayerWoundDataAsArray(playerid, output[])
{
	if(!IsPlayerConnected(playerid))
		return 0;

/*
	if(sizeof(output) != 1 + (MAX_WOUNDS * 5))
	{
		printf("ERROR: Output array for GetPlayerWoundDataAsArray must be exactly %d cells in size", 1 + (MAX_WOUNDS * 5));
		return 0;
	}
*/

/*
	max size: 1 + MAX_WOUNDS * 5
	header: 1 cell
		woundblcok count

	woundblock: 5 cells
		wnd_type
		wnd_bleedrate
		wnd_calibre
		wnd_timestamp
*/

	new
		idx = 1,
		sourcelen;

	output[0] = Iter_Count(wnd_Index[playerid]);

	if(output[0] == 0)
		return 0;

	foreach(new i : wnd_Index[playerid])
	{
		output[idx++] = _:wnd_Data[playerid][i][wnd_type];
		output[idx++] = _:wnd_Data[playerid][i][wnd_bleedrate];
		output[idx++] = wnd_Data[playerid][i][wnd_calibre];
		output[idx++] = wnd_Data[playerid][i][wnd_timestamp];
		output[idx++] = wnd_Data[playerid][i][wnd_bodypart];
		sourcelen = strlen(wnd_Data[playerid][i][wnd_source]);
		output[idx++] = sourcelen;
		//memcpy(output[idx++], wnd_Data[playerid][i][wnd_source], 0, 32 * 4, 32);
		// alternative version, memcpy seems to be causing stack issues:
		for(new j; j < sourcelen; j++)
			output[idx++] = wnd_Data[playerid][i][wnd_source][j];

		output[idx++] = EOS;
	}

	return idx;
}

stock SetPlayerWoundDataFromArray(playerid, input[])
{
	if(!IsPlayerConnected(playerid))
		return 0;

/*
	if(sizeof(output) != 1 + (MAX_WOUNDS * 5))
	{
		printf("ERROR: Input array for SetPlayerWoundDataFromArray must be exactly %d cells in size", 1 + (MAX_WOUNDS * 5));
		return 0;
	}
*/

	if(input[0] <= 0)
		return 0;

	new
		id,
		sourcelen;

	for(new i = 1, j; j < input[0];)
	{
		id = Iter_Free(wnd_Index[playerid]);

		if(id == -1)
		{
			printf("ERROR: [SetPlayerWoundDataFromArray] Ran out of wound slots on wound %d cell: %d", (i - 1) / _:E_WOUND_DATA, i);
			break;
		}

		wnd_Data[playerid][id][wnd_type] = E_WND_TYPE:input[i++];
		wnd_Data[playerid][id][wnd_bleedrate] = Float:input[i++];
		wnd_Data[playerid][id][wnd_calibre] = input[i++];
		wnd_Data[playerid][id][wnd_timestamp] = input[i++];
		wnd_Data[playerid][id][wnd_bodypart] = input[i++];
		sourcelen = input[i++]; // source string length

		// memcpy(wnd_Data[playerid][id][wnd_source], input[i], 0, 32 * 4); // no i++
		// i += sourcelen; // jump over the string
		// alternative version, memcpy seems to be causing stack issues:
		for(new k; k < sourcelen; k++)
			wnd_Data[playerid][id][wnd_source][k] = input[i++];

		wnd_Data[playerid][id][wnd_source][sourcelen] = EOS;

		Iter_Add(wnd_Index[playerid], id);

		j++;
	}

	return 1;
}


public OnPlayerSave(playerid, filename[])
{
	new
		length,
		data[1 + (MAX_WOUNDS * _:E_WOUND_DATA)];

	length = GetPlayerWoundDataAsArray(playerid, data);

	modio_push(filename, _T<W,N,D,S>, length, data);

	#if defined dmg_OnPlayerSave
		return dmg_OnPlayerSave(playerid, filename);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerSave
	#undef OnPlayerSave
#else
	#define _ALS_OnPlayerSave
#endif
 
#define OnPlayerSave dmg_OnPlayerSave
#if defined dmg_OnPlayerSave
	forward dmg_OnPlayerSave(playerid, filename[]);
#endif

public OnPlayerLoad(playerid, filename[])
{
	new data[1 + (MAX_WOUNDS * _:E_WOUND_DATA)];

	modio_read(filename, _T<W,N,D,S>, data);

	Iter_Clear(wnd_Index[playerid]);
	SetPlayerWoundDataFromArray(playerid, data);

	#if defined dmg_OnPlayerLoad
		return dmg_OnPlayerLoad(playerid, filename);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLoad
	#undef OnPlayerLoad
#else
	#define _ALS_OnPlayerLoad
#endif
 
#define OnPlayerLoad dmg_OnPlayerLoad
#if defined dmg_OnPlayerLoad
	forward dmg_OnPlayerLoad(playerid, filename[]);
#endif
