/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_WOUNDS			(32)
#define MAX_WOUND_SRCLEN	(10)


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
			wnd_source[MAX_WOUND_SRCLEN]
}


static
			dmg_LastHit[MAX_PLAYERS][MAX_PLAYER_NAME],
			dmg_LastHitId[MAX_PLAYERS],
			Item:dmg_LastHitItem[MAX_PLAYERS],
			dmg_LastHitBy[MAX_PLAYERS][MAX_PLAYER_NAME],
			dmg_LastHitById[MAX_PLAYERS],
			Item:dmg_LastHitByItem[MAX_PLAYERS],
			dmg_DeltDamageTick[MAX_PLAYERS],
			dmg_TookDamageTick[MAX_PLAYERS];

static
			wnd_Data[MAX_PLAYERS][MAX_WOUNDS][E_WOUND_DATA],
   Iterator:wnd_Index[MAX_PLAYERS]<MAX_WOUNDS>;


forward Float:GetPlayerKnockoutChance(playerid, Float:knockmult);


hook OnPlayerConnect(playerid)
{
	dmg_LastHit[playerid][0] = EOS;
	dmg_LastHitId[playerid] = INVALID_PLAYER_ID;
	dmg_LastHitItem[playerid] = INVALID_ITEM_ID;
	dmg_LastHitBy[playerid][0] = EOS;
	dmg_LastHitById[playerid] = INVALID_PLAYER_ID;
	dmg_LastHitByItem[playerid] = INVALID_ITEM_ID;
	dmg_DeltDamageTick[playerid] = 0;
	dmg_TookDamageTick[playerid] = 0;

	Iter_Clear(wnd_Index[playerid]);

	return 1;
}


hook OnScriptInit()
{
	Iter_Init(wnd_Index);
}


stock PlayerInflictWound(playerid, targetid, E_WND_TYPE:type, Float:bleedrate, Float:knockmult, calibre, bodypart, const source[])
{
	if(IsPlayerOnAdminDuty(playerid) || IsPlayerOnAdminDuty(targetid))
		return 0;

	if(IsPlayerKnockedOut(playerid))
	{
		Logger_Log("knocked out player tried to wound player",
			Logger_P(playerid),
			Logger_P(targetid));
		return 0;
	}

	new
		woundid = Iter_Free(wnd_Index[targetid]),
		woundcount,
		Float:totalbleedrate;
	GetPlayerBleedRate(targetid, totalbleedrate);

	if(woundid == ITER_NONE)
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
	strcpy(wnd_Data[targetid][woundid][wnd_source], source, MAX_WOUND_SRCLEN);

	totalbleedrate += bleedrate;

	// Truncate result to 1.0
	totalbleedrate = totalbleedrate > 1.0 ? 1.0 : totalbleedrate;

	SetPlayerBleedRate(targetid, totalbleedrate);
	GivePlayerHP(targetid, -(bleedrate * 100.0));

	switch(bodypart)
	{
		case BODY_PART_TORSO:		knockmult *= 1.0;
		case BODY_PART_GROIN:		knockmult *= 1.2;
		case BODY_PART_LEFT_ARM:	knockmult *= 0.9;
		case BODY_PART_RIGHT_ARM:	knockmult *= 0.9;
		case BODY_PART_LEFT_LEG:	knockmult *= 0.8;
		case BODY_PART_RIGHT_LEG:	knockmult *= 0.8;
		case BODY_PART_HEAD:		knockmult *= 9.9;
	}

	if(frandom(100.0) < knockmult * (((woundcount + 1) * 0.2) * ((totalbleedrate * 50) + 1)))
	{
		new
			Float:hp,
			knockouttime;

		hp = GetPlayerHP(targetid);
		knockouttime = floatround((knockmult * 0.2) * ((woundcount + 1) * ((totalbleedrate * 10) + 1) * (110.0 - hp) + (200 * (110.0 - hp))));

		if(knockouttime > 1500)
		{
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

		Logger_Log("player wounded player",
			Logger_S("player", dmg_LastHitBy[targetid]),
			Logger_S("target", dmg_LastHit[playerid]),
			Logger_F("bleedrate", bleedrate),
			Logger_F("knockmult", knockmult),
			Logger_I("bodypart", bodypart),
			Logger_S("source", source));
	}
	else
	{
		Logger_Log("player wounded self",
			Logger_P(targetid),
			Logger_F("bleedrate", bleedrate),
			Logger_F("knockmult", knockmult),
			Logger_I("bodypart", bodypart),
			Logger_S("source", source));
	}

	ShowActionText(targetid, sprintf(ls(targetid, "WOUNDEDMSSG", true), source, (knockmult * (((woundcount + 1) * 0.2) * ((totalbleedrate * 50) + 1)) < 50.0 ? ("Minor") : ("Severe"))), 5000);

	return 1;
}

hook OnDeath(playerid, killerid, reason)
{
	Iter_Clear(wnd_Index[playerid]);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock Float:GetPlayerKnockoutChance(playerid, Float:knockmult)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;
	
	new Float:bleedrate;
	GetPlayerBleedRate(playerid, bleedrate);

	return knockmult * (((Iter_Count(wnd_Index[playerid]) + 1) * 0.2) * ((bleedrate * 50) + 1));
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

// dmg_LastHitBy
stock GetLastHitBy(playerid, name[MAX_PLAYER_NAME])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	name[0] = EOS;
	strcat(name, dmg_LastHitBy[playerid]);

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
stock Item:GetLastHitByWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_ITEM_ID;

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
			case BODY_PART_TORSO:		output[0] += 1;
			case BODY_PART_GROIN:		output[1] += 1;
			case BODY_PART_LEFT_ARM:	output[2] += 1;
			case BODY_PART_RIGHT_ARM:	output[3] += 1;
			case BODY_PART_LEFT_LEG:	output[4] += 1;
			case BODY_PART_RIGHT_LEG:	output[5] += 1;
			case BODY_PART_HEAD:		output[6] += 1;
			default:					output[0] += 1;
		}
	}

	return 1;
}

stock GetPlayerWoundDataAsArray(playerid, output[])
{
	if(!IsPlayerConnected(playerid))
		return 0;

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
		sourcelen = strlen(wnd_Data[playerid][i][wnd_source]) + 1; // + \0
		output[idx++] = sourcelen;

		if(sourcelen > MAX_WOUND_SRCLEN)
		{
			err("Wound %d sourcelen:%d > %d dump: t:%d b:%f c:%d d:%d p:%d", i, sourcelen, MAX_WOUND_SRCLEN, _:wnd_Data[playerid][i][wnd_type], _:wnd_Data[playerid][i][wnd_bleedrate], wnd_Data[playerid][i][wnd_calibre], wnd_Data[playerid][i][wnd_timestamp], wnd_Data[playerid][i][wnd_bodypart]);
			sourcelen = MAX_WOUND_SRCLEN;
		}
		else if(sourcelen == 0)
		{
			err("Wound %d sourcelen:%d <= 0 dump: t:%d b:%f c:%d d:%d p:%d", i, sourcelen, _:wnd_Data[playerid][i][wnd_type], _:wnd_Data[playerid][i][wnd_bleedrate], wnd_Data[playerid][i][wnd_calibre], wnd_Data[playerid][i][wnd_timestamp], wnd_Data[playerid][i][wnd_bodypart]);
		}

		//memcpy(output[idx++], wnd_Data[playerid][i][wnd_source], 0, 32 * 4, 32);
		// alternative version, memcpy seems to be causing stack issues:
		for(new j; j < sourcelen; j++)
			output[idx++] = wnd_Data[playerid][i][wnd_source][j];
	}

	return idx;
}

stock SetPlayerWoundDataFromArray(playerid, input[])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(input[0] == 0)
		return 0;

	if(!(0 < input[0] < MAX_WOUNDS))
	{
		err("Wound count (%d) is invalid.", input[0]);
		return 0;
	}

	new
		idx = 1,
		woundid,
		sourcelen;

	for(new i; i < input[0]; i++)
	{
		woundid = Iter_Free(wnd_Index[playerid]);

		if(woundid == ITER_NONE)
		{
			err("Ran out of wound slots on wound %d cell: %d", (idx - 1) / _:E_WOUND_DATA, idx);
			break;
		}

		wnd_Data[playerid][woundid][wnd_type] = E_WND_TYPE:input[idx++];
		wnd_Data[playerid][woundid][wnd_bleedrate] = Float:input[idx++];
		wnd_Data[playerid][woundid][wnd_calibre] = input[idx++];
		wnd_Data[playerid][woundid][wnd_timestamp] = input[idx++];
		wnd_Data[playerid][woundid][wnd_bodypart] = input[idx++];
		sourcelen = input[idx++]; // source string length

		if(sourcelen > MAX_WOUND_SRCLEN)
		{
			err("sourcelen:%d > %d, truncating.", sourcelen, MAX_WOUND_SRCLEN);
			sourcelen = MAX_WOUND_SRCLEN;
		}
		else if(sourcelen == 0)
		{
			err("sourcelen:%d <= 0, truncating.", sourcelen);
		}

		// memcpy(wnd_Data[playerid][woundid][wnd_source], input[idx], 0, 32 * 4); // no idx++
		// idx += sourcelen; // jump over the string
		for(new k; k < sourcelen; k++)
			wnd_Data[playerid][woundid][wnd_source][k] = input[idx++];

		Iter_Add(wnd_Index[playerid], woundid);
	}

	return 1;
}


hook OnPlayerSave(playerid, filename[])
{
	new
		length,
		data[1 + (MAX_WOUNDS * _:E_WOUND_DATA)];

	length = GetPlayerWoundDataAsArray(playerid, data);

	modio_push(filename, _T<W,N,D,S>, length, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[1 + (MAX_WOUNDS * _:E_WOUND_DATA)];

	modio_read(filename, _T<W,N,D,S>, sizeof(data), data);

	Iter_Clear(wnd_Index[playerid]);
	SetPlayerWoundDataFromArray(playerid, data);
}
