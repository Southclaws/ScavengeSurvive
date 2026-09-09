/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!GetPlayerSpawnedState(playerid))
		return 0;

	if(issuerid == INVALID_PLAYER_ID)
	{
		switch(weaponid)
		{
			case WEAPON_FLAMETHROWER:
			{
				GivePlayerHP(playerid, -(amount * 0.1));
			}
			case REASON_DROWN:
			{
				KnockOutPlayer(playerid, 1500 + random(1500));
			}
			case REASON_COLLISION:
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
