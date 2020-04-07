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


#include <YSI_Coding\y_hooks>


hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	dbg("global", CORE, "[OnPlayerTakeDamage] in /gamemodes/sss/core/weapon/damage-world.pwn");

	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(playerid))
		return 0;

	if(issuerid == INVALID_PLAYER_ID)
	{
		switch(weaponid)
		{
			case 37:
			{
				GivePlayerHP(playerid, -(amount * 0.1));
			}
			case 53:
			{
				KnockOutPlayer(playerid, 1500 + random(1500));
			}
			case 54:
			{
				if(amount > 10.0)
				{
					_DoFallDamage(playerid, amount * 2.5);
				}
			}
		}
	}

	return 1;
}


_DoFallDamage(playerid, Float:multiplier)
{
	if(frandom(100.0) < multiplier)
		PlayerInflictWound(INVALID_PLAYER_ID, playerid, E_WOUND_MELEE, (multiplier > 1.0) ? multiplier * 0.00024 : 0.0, multiplier * 0.9, -1, random(2) ? BODY_PART_LEFT_LEG : BODY_PART_RIGHT_LEG, "Fall");
}
