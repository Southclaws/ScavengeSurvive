new
	combatlog_LastAttacker[MAX_PLAYERS],
	combatlog_LastWeapon[MAX_PLAYERS];


hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(playerid))
		return 0;

	if(IsPlayerOnAdminDuty(damagedid))
		return 0;

	if(!IsPlayerSpawned(damagedid))
		return 0;

	SetPlayerTookDamageTick(damagedid, GetTickCount());
	combatlog_LastAttacker[damagedid] = playerid;
	combatlog_LastWeapon[damagedid] = weaponid;

	return 1;
}

hook OnPlayerSpawn(playerid)
{
	combatlog_LastAttacker[playerid] = -1;
	combatlog_LastWeapon[playerid] = -1;
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

