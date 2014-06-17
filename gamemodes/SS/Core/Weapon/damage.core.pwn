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
			wnd_calibre
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
			wnd_Data[MAX_PLAYERS][E_WOUND_DATA],
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


stock PlayerInflictWound(playerid, targetid, E_WND_TYPE:type, Float:bleedrate, calibre)
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

	wnd_Data[targetid][wnd_type] = type;
	wnd_Data[targetid][wnd_bleedrate] = bleedrate;
	wnd_Data[targetid][wnd_calibre] = calibre;

	// Max bleed rate is 1.0, don't allow higher values
	bleedrate = bleedrate > 10.0 ? 10.0 : bleedrate;

	// If player isn't already bleeding
	if(totalbleedrate == 0.0)
	{
		d:2:FIREARM_DEBUG("[PlayerInflictWound] totalbleedrate = bleedrate");
		totalbleedrate = bleedrate;
	}
	else
	{
		// If the total bleed rate is higher than the input
		if(totalbleedrate > bleedrate)
		{
			d:2:FIREARM_DEBUG("[PlayerInflictWound] totalbleedrate += bleedrate * totalbleedrate : %f + %f", totalbleedrate, bleedrate * totalbleedrate);
			// Make the desired a bit smaller
			totalbleedrate += bleedrate * totalbleedrate;
		}
		else
		{
			d:2:FIREARM_DEBUG("[PlayerInflictWound] totalbleedrate += bleedrate");
			// Otherwise, just add the bleed rate
			totalbleedrate += bleedrate;
		}
	}

	// Truncate result to 10.0
	totalbleedrate = totalbleedrate > 10.0 ? 10.0 : totalbleedrate;

	SetPlayerBleedRate(targetid, totalbleedrate);

	if(woundcount > 1)
	{
		if(frandom(100.0) < woundcount * (totalbleedrate * 10))
		{
			new
				Float:hp,
				knockouttime;

			hp = GetPlayerHP(targetid);
			knockouttime = floatround((woundcount * (totalbleedrate * 10) * (100.0 - hp) + (200 * (100.0 - hp))));

			if(knockouttime > 1500)
			{
				// MsgF(targetid, -1, "[WOUND_KO] Knocking out for %dms - %d wounds, %f health %f bleedrate", knockouttime, woundcount, hp, totalbleedrate);
				KnockOutPlayer(targetid, knockouttime);
			}
		}
	}

	if(IsPlayerConnected(playerid))
	{
		GetPlayerName(targetid, dmg_LastHit[playerid], MAX_PLAYER_NAME);
		dmg_LastHitId[playerid] = targetid;
		dmg_LastHitItem[playerid] = GetPlayerItem(playerid);

		GetPlayerName(playerid, dmg_LastHitBy[targetid], MAX_PLAYER_NAME);
		dmg_LastHitById[targetid] = playerid;
		dmg_LastHitByItem[targetid] = GetPlayerItem(targetid);
	}

	return 1;
}

static showbleedrate[MAX_PLAYERS];
CMD:showdamage(playerid, params[])
{
	showbleedrate[playerid] = !showbleedrate[playerid];
	HideActionText(playerid);
	return 1;
}

hook OnPlayerUpdate(playerid)
{
	if(showbleedrate[playerid])
	{
		ShowActionText(playerid, sprintf("playerid: %d~n~bleedrate: %f~n~wounds: %d", playerid, GetPlayerBleedRate(playerid), Iter_Count(wnd_Index[playerid])));
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
