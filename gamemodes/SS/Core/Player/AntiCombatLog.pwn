new
	combatlog_LastAttacker[MAX_PLAYERS],
	combatlog_LastWeapon[MAX_PLAYERS];


hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	gPlayerData[damagedid][ply_TookDamageTick] = GetTickCount();
	combatlog_LastAttacker[damagedid] = playerid;
	combatlog_LastWeapon[damagedid] = weaponid;
}

IsPlayerCombatLogging(playerid, &lastattacker, &lastweapon)
{
	if(GetTickCountDifference(GetTickCount(), gPlayerData[playerid][ply_TookDamageTick]) < gCombatLogWindow * 1000 && IsPlayerConnected(combatlog_LastAttacker[playerid]) && !gServerRestarting)
	{
		lastattacker = combatlog_LastAttacker[playerid];
		lastweapon = combatlog_LastWeapon[playerid];
		return 1;
	}

	return 0;
}

