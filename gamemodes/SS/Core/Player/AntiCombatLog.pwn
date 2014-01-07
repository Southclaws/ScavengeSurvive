new
	combatlog_LastAttacker[MAX_PLAYERS],
	combatlog_LastWeapon[MAX_PLAYERS];


hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	SetPlayerTookDamageTick(damagedid, GetTickCount());
	combatlog_LastAttacker[damagedid] = playerid;
	combatlog_LastWeapon[damagedid] = weaponid;
}

IsPlayerCombatLogging(playerid, &lastattacker, &lastweapon)
{
	if(GetTickCountDifference(GetTickCount(), GetPlayerTookDamageTick(playerid)) < gCombatLogWindow * 1000 && IsPlayerConnected(combatlog_LastAttacker[playerid]) && !gServerRestarting)
	{
		lastattacker = combatlog_LastAttacker[playerid];
		lastweapon = combatlog_LastWeapon[playerid];
		return 1;
	}

	return 0;
}

