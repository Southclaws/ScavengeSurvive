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
			wnd_bodypart
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


new FIREARM_DEBUG;

hook OnGameModeInit()
{
	Iter_Init(wnd_Index);
	FIREARM_DEBUG = debug_register_handler("weapon/damage");
}


stock PlayerInflictWound(playerid, targetid, E_WND_TYPE:type, Float:bleedrate, calibre, bodypart)
{
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

	// Max bleed rate is 1.0, don't allow higher values
	bleedrate = bleedrate > 10.0 ? 10.0 : bleedrate;

	totalbleedrate += bleedrate;
	d:2:FIREARM_DEBUG("[PlayerInflictWound] totalbleedrate = %f", totalbleedrate);

	// Truncate result to 10.0
	totalbleedrate = totalbleedrate > 10.0 ? 10.0 : totalbleedrate;

	SetPlayerBleedRate(targetid, totalbleedrate);

	if(woundcount > 1)
	{
		if(frandom(100.0) < (woundcount * (totalbleedrate * 20)))
		{
			new
				Float:hp,
				knockouttime;

			hp = GetPlayerHP(targetid);
			knockouttime = floatround((woundcount * (totalbleedrate * 10) * (100.0 - hp) + (200 * (100.0 - hp))));

			if(knockouttime > 1500)
			{
				d:2:FIREARM_DEBUG("[PlayerInflictWound] Knocking out %p for %dms - %d wounds, %f health %f bleedrate", playerid, knockouttime, woundcount, hp, totalbleedrate);
				KnockOutPlayer(targetid, knockouttime);
			}
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
	}

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

	new idx = 1;

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

	new id;

	for(new i = 1; i < input[0] * 5;)
	{
		id = Iter_Free(wnd_Index[playerid]);

		wnd_Data[playerid][id][wnd_type] = E_WND_TYPE:input[i++];
		wnd_Data[playerid][id][wnd_bleedrate] = Float:input[i++];
		wnd_Data[playerid][id][wnd_calibre] = input[i++];
		wnd_Data[playerid][id][wnd_timestamp] = input[i++];
		wnd_Data[playerid][id][wnd_bodypart] = input[i++];

		Iter_Add(wnd_Index[playerid], id);
	}

	return 1;
}


public OnPlayerSave(playerid, filename[])
{
	new
		length,
		data[1 + (MAX_WOUNDS * 4)];

	length = GetPlayerWoundDataAsArray(playerid, data);

	modio_push(filename, _T<W,N,D,S>, length, data);

	#if defined dmg_OnPlayerSave
		return dmg_OnPlayerSave(playerid, filename[]);
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
	new data[1 + (MAX_WOUNDS * 4)];

	modio_read(filename, _T<W,N,D,S>, data);

	SetPlayerWoundDataFromArray(playerid, data);

	#if defined dmg_OnPlayerLoad
		return dmg_OnPlayerLoad(playerid, filename[]);
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


ACMD:showdamage[4](playerid, params[])
{
	ShowActionText(playerid, sprintf("bleedrate: %f~n~wounds: %d", GetPlayerBleedRate(playerid), Iter_Count(wnd_Index[playerid])), 5000);
	return 1;
}
ACMD:removewounds[4](playerid, params[])
{
	RemovePlayerWounds(playerid, strval(params));
	MsgF(playerid, YELLOW, "Removed %d wounds.", strval(params));
	return 1;
}
ACMD:setbleed[4](playerid, params[])
{
	SetPlayerBleedRate(playerid, floatstr(params));
	MsgF(playerid, YELLOW, "Set bleed rate to %f", floatstr(params));
	return 1;
}
