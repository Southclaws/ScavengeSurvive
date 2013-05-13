#define COMBAT_LOG_WINDOW (3000)


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
	if(tickcount() - tick_LastDamaged[playerid] < COMBAT_LOG_WINDOW && IsPlayerConnected(combatlog_LastAttacker[playerid]))
	{
		OnPlayerDeath(playerid, combatlog_LastAttacker[playerid], combatlog_LastWeapon[playerid]);
	}
}
