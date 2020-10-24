/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
Float:	dmg_VehicleVelocityKnockMult,
Float:	dmg_VehicleVelocityBleedMult,
		// Always for targetid
Float:	dmg_ReturnBleedrate[MAX_PLAYERS],
Float:	dmg_ReturnKnockMult[MAX_PLAYERS];


forward OnPlayerVehicleCollide(playerid, targetid, Float:bleedrate, Float:knockmult);


hook OnScriptInit()
{
	GetSettingFloat("vehicle.damage/knock-mult", 1.0, dmg_VehicleVelocityKnockMult);
	GetSettingFloat("vehicle.damage/bleed-mult", 1.0, dmg_VehicleVelocityBleedMult);
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(weaponid == 49)
	{
		_DoVehicleCollisionDamage(issuerid, playerid);
	}

	return 1;
}

_DoVehicleCollisionDamage(playerid, targetid)
{
	if(IsPlayerOnAdminDuty(playerid) || IsPlayerOnAdminDuty(targetid))
		return 0;

	new
		Float:velocity,
		Float:bleedrate,
		Float:knockmult = 1.0;

	velocity = GetPlayerTotalVelocity(playerid);
	bleedrate = (0.04 * (velocity * 0.02)) * dmg_VehicleVelocityBleedMult;

	if(velocity > 55.0 && frandom(velocity) > 55.0)
		KnockOutPlayer(targetid, floatround((1000 + ((velocity * 0.05) * 1000)) * dmg_VehicleVelocityKnockMult));

	dmg_ReturnBleedrate[targetid] = bleedrate;
	dmg_ReturnKnockMult[targetid] = knockmult;

	if(CallLocalFunction("OnPlayerVehicleCollide", "ddff", playerid, targetid, bleedrate, knockmult))
		return 0;

	if(dmg_ReturnBleedrate[targetid] != bleedrate)
		bleedrate = dmg_ReturnBleedrate[targetid];

	if(dmg_ReturnKnockMult[targetid] != knockmult)
		knockmult = dmg_ReturnKnockMult[targetid];

	PlayerInflictWound(playerid, targetid, E_WOUND_MELEE, bleedrate, 0, NO_CALIBRE, random(2) ? (BODY_PART_TORSO) : (random(2) ? (BODY_PART_RIGHT_LEG) : (BODY_PART_LEFT_LEG)), "Collision");

	return 1;
}

stock DMG_VEHICLE_SetBleedRate(targetid, Float:bleedrate)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnBleedrate[targetid] = bleedrate;

	return 1;
}

stock DMG_VEHICLE_SetKnockMult(targetid, Float:knockmult)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnKnockMult[targetid] = knockmult;

	return 1;
}
