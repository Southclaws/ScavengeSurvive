/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


static
	combatlog_LastAttacked[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...},
	combatlog_LastAttacker[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...},
	combatlog_LastItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


hook OnPlayerShootPlayer(playerid, targetid, bodypart, Float:bleedrate, Float:knockmult, Float:bulletvelocity, Float:distance)
{
	dbg("global", CORE, "[OnPlayerShootPlayer] in /gamemodes/sss/core/weapon/anti-combat-log.pwn");

	_CombatLogHandleDamage(playerid, targetid, GetPlayerItem(playerid));

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult)
{
	dbg("global", CORE, "[OnPlayerMeleePlayer] in /gamemodes/sss/core/weapon/anti-combat-log.pwn");

	_CombatLogHandleDamage(playerid, targetid, GetPlayerItem(playerid));

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerExplosiveDmg(playerid, Float:bleedrate, Float:knockmult)
{
	dbg("global", CORE, "[OnPlayerExplosiveDmg] in /gamemodes/sss/core/weapon/anti-combat-log.pwn");

	_CombatLogHandleDamage(INVALID_PLAYER_ID, playerid, INVALID_ITEM_ID);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerVehicleCollide(playerid, targetid, Float:bleedrate, Float:knockmult)
{
	dbg("global", CORE, "[OnPlayerVehicleCollide] in /gamemodes/sss/core/weapon/anti-combat-log.pwn");

	_CombatLogHandleDamage(playerid, targetid, INVALID_ITEM_ID);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

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
	dbg("global", CORE, "[OnPlayerSpawn] in /gamemodes/sss/core/weapon/anti-combat-log.pwn");

	combatlog_LastAttacker[playerid] = INVALID_PLAYER_ID;
	combatlog_LastItem[playerid] = INVALID_ITEM_ID;
}

hook OnPlayerDisconnect(playerid, reason)
{
	dbg("global", CORE, "[OnPlayerDisconnect] in /gamemodes/sss/core/weapon/anti-combat-log.pwn");

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
