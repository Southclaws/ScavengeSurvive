new
	combatlog_LastAttacked[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...},
	combatlog_LastAttacker[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...},
	combatlog_LastItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};

public OnPlayerShootPlayer(playerid, targetid, bodypart, Float:bleedrate, Float:knockmult, bulletvelocity, distance)
{
	_CombatLogHandleDamage(playerid, targetid, GetPlayerItem(playerid));

	#if defined aclg_OnPlayerShootPlayer
		return aclg_OnPlayerShootPlayer(playerid, targetid, bodypart, bleedrate, knockmult, bulletvelocity, distance);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerShootPlayer
	#undef OnPlayerShootPlayer
#else
	#define _ALS_OnPlayerShootPlayer
#endif
 
#define OnPlayerShootPlayer aclg_OnPlayerShootPlayer
#if defined aclg_OnPlayerShootPlayer
	forward aclg_OnPlayerShootPlayer(playerid, targetid, bodypart, Float:bleedrate, Float:knockmult, bulletvelocity, distance);
#endif

public OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult)
{
	_CombatLogHandleDamage(playerid, targetid, GetPlayerItem(playerid));

	#if defined aclg_OnPlayerMeleePlayer
		return aclg_OnPlayerMeleePlayer(playerid, targetid, bleedrate, knockmult);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerMeleePlayer
	#undef OnPlayerMeleePlayer
#else
	#define _ALS_OnPlayerMeleePlayer
#endif
 
#define OnPlayerMeleePlayer aclg_OnPlayerMeleePlayer
#if defined aclg_OnPlayerMeleePlayer
	forward aclg_OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult);
#endif

public OnPlayerExplosiveDmg(playerid, Float:bleedrate, Float:knockmult)
{
	_CombatLogHandleDamage(INVALID_PLAYER_ID, playerid, INVALID_ITEM_ID);

	#if defined aclg_OnPlayerExplosiveDmg
		return aclg_OnPlayerExplosiveDmg(playerid, bleedrate, knockmult);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerExplosiveDmg
	#undef OnPlayerExplosiveDmg
#else
	#define _ALS_OnPlayerExplosiveDmg
#endif
 
#define OnPlayerExplosiveDmg aclg_OnPlayerExplosiveDmg
#if defined aclg_OnPlayerExplosiveDmg
	forward aclg_OnPlayerExplosiveDmg(playerid, Float:bleedrate, Float:knockmult);
#endif

public OnPlayerVehicleCollide(playerid, targetid, Float:bleedrate, Float:knockmult)
{
	_CombatLogHandleDamage(playerid, targetid, INVALID_ITEM_ID);

	#if defined aclg_OnPlayerVehicleCollide
		return aclg_OnPlayerVehicleCollide(playerid, targetid, bleedrate, knockmult);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerVehicleCollide
	#undef OnPlayerVehicleCollide
#else
	#define _ALS_OnPlayerVehicleCollide
#endif
 
#define OnPlayerVehicleCollide aclg_OnPlayerVehicleCollide
#if defined aclg_OnPlayerVehicleCollide
	forward aclg_OnPlayerVehicleCollide(playerid, targetid, Float:bleedrate, Float:knockmult);
#endif


_CombatLogHandleDamage(playerid, targetid, itemid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(IsPlayerConnected(playerid))
	{
		combatlog_LastAttacked[playerid] = targetid;
		combatlog_LastAttacker[targetid] = playerid;
	}
	else
	{
		combatlog_LastAttacker[targetid] = INVALID_PLAYER_ID;
	}

	combatlog_LastItem[targetid] = itemid;

	return 1;
}

hook OnPlayerSpawn(playerid)
{
	combatlog_LastAttacker[playerid] = INVALID_PLAYER_ID;
	combatlog_LastItem[playerid] = INVALID_ITEM_ID;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(combatlog_LastAttacked[playerid] != INVALID_PLAYER_ID)
	{
		combatlog_LastAttacker[combatlog_LastAttacked[playerid]] = INVALID_PLAYER_ID;
		combatlog_LastItem[combatlog_LastAttacked[playerid]] = INVALID_ITEM_ID;
		combatlog_LastAttacked[playerid] = INVALID_PLAYER_ID;
	}
}

stock IsPlayerCombatLogging(playerid, &lastattacker, &lastweapon)
{
	if(GetTickCountDifference(GetTickCount(), GetPlayerTookDamageTick(playerid)) < gCombatLogWindow * 1000 && IsPlayerConnected(combatlog_LastAttacker[playerid]) && !gServerRestarting)
	{
		lastattacker = combatlog_LastAttacker[playerid];
		lastweapon = combatlog_LastItem[playerid];

		return 1;
	}

	return 0;
}

