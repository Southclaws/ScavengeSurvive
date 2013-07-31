new
	combatlog_LastAttacker[MAX_PLAYERS],
	combatlog_LastWeapon[MAX_PLAYERS];


hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	tick_LastDamaged[damagedid] = tickcount();
	combatlog_LastAttacker[damagedid] = playerid;
	combatlog_LastWeapon[damagedid] = weaponid;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(tickcount() - tick_LastDamaged[playerid] < gCombatLogWindow * 1000 && IsPlayerConnected(combatlog_LastAttacker[playerid]))
	{
		OnPlayerDeath(playerid, combatlog_LastAttacker[playerid], combatlog_LastWeapon[playerid]);
	}
}
