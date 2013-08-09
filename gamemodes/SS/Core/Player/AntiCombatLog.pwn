new
	combatlog_LastAttacker[MAX_PLAYERS],
	combatlog_LastWeapon[MAX_PLAYERS];


hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	gPlayerData[damagedid][ply_TookDamageTick] = tickcount();
	combatlog_LastAttacker[damagedid] = playerid;
	combatlog_LastWeapon[damagedid] = weaponid;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(tickcount() - gPlayerData[playerid][ply_TookDamageTick] < gCombatLogWindow * 1000 && IsPlayerConnected(combatlog_LastAttacker[playerid]))
	{
		OnPlayerDeath(playerid, combatlog_LastAttacker[playerid], combatlog_LastWeapon[playerid]);
	}
}
