/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_BLOOD_OBJECTS 15


static
Float:	bld_BleedRate[MAX_PLAYERS],
bool:	Bleeding[MAX_PLAYERS],
		BloodObjectIndex[MAX_PLAYERS],
		BloodObjects[MAX_PLAYERS][MAX_BLOOD_OBJECTS];


hook OnPlayerScriptUpdate(playerid)
{
	if(!IsPlayerSpawned(playerid))
	{
		RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
		return;
	}

	if(IsPlayerOnAdminDuty(playerid))
	{
		RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);		
		return;
	}

	if(IsNaN(bld_BleedRate[playerid]) || bld_BleedRate[playerid] < 0.0)
		bld_BleedRate[playerid] = 0.0;

	if(bld_BleedRate[playerid] > 0.0)
	{
		new
			Float:hp = GetPlayerHP(playerid),
			Float:slowrate;
		
		GetPlayerBleedSlowRate(hp, bld_BleedRate[playerid], GetPlayerWounds(playerid), slowrate);

		if(frandom(1.0) < 0.7)
		{
			SetPlayerHP(playerid, hp - bld_BleedRate[playerid]);

			if(GetPlayerHP(playerid) < 0.1)
				SetPlayerHP(playerid, 0.0);
		}

		/*
			Slow bleeding based on health and wound count. Less wounds means
			faster degradation of bleed rate. As blood rate drops, the bleed
			rate will slow down faster (pseudo blood pressure). Results in a
			bleed-out that slows down faster over time (only subtly). No wounds
			will automatically stop the bleed rate due to the nature of the
			formula (however this is still intentional).
		*/
		if(random(100) < 50)
			bld_BleedRate[playerid] -= slowrate;

		if(debug_conditional(\"gamemodes/sss/core/char/bleed.pwn\", 1))
			ShowActionText(playerid, sprintf("HP: %f Bleed-rate: %f~n~Wounds %d Bleed slow-rate: %f", hp, bld_BleedRate[playerid], GetPlayerWounds(playerid)));

		if(!IsPlayerInAnyVehicle(playerid))
		{
			if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_BLOOD))
			{
				if(frandom(0.1) < 0.1 - bld_BleedRate[playerid])
				{
					RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
					Bleeding[playerid] = false;
				}
			}
			else
			{
				if(frandom(0.1) < bld_BleedRate[playerid])
				{
					SetPlayerAttachedObject(playerid, ATTACHSLOT_BLOOD, /*18706*/ 18706, 1,  0.088999, 0.020000, 0.044999,  0.088999, 0.020000, 0.044999,  1.179000, 1.510999, 0.005000);
					Bleeding[playerid] = true;
				}
			}
		}
		else
		{
			RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
		}
	}
	else
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_BLOOD))
			RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);

		new intensity = GetPlayerInfectionIntensity(playerid, 1);

		GivePlayerHP(playerid, 0.001925925 * GetPlayerFP(playerid) * (intensity ? 0.5 : 1.0));

		if(bld_BleedRate[playerid] < 0.0)
			bld_BleedRate[playerid] = 0.0;
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Morphine))
	{
		SetPlayerDrunkLevel(playerid, 2200);

		if(random(100) < 80)
			GivePlayerHP(playerid, 0.5);
	}

	if(Bleeding[playerid])
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:r,
			worldid = GetPlayerVirtualWorld(playerid),
			interiorid = GetPlayerInterior(playerid),
			idx = BloodObjectIndex[playerid];

		idx++;
		if(idx == MAX_BLOOD_OBJECTS)
			idx = 0;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, r);

		x += 0.1 * (3 - random(6));
		y += 0.1 * (3 - random(6));
		r += 0.1 * random(3600);

		DestroyDynamicObject(BloodObjects[playerid][idx]);
		BloodObjects[playerid][idx] = CreateDynamicObject(19836, x, y, z - 0.9, 0.0, 0.0, r, worldid, interiorid);

		BloodObjectIndex[playerid] = idx;
	}

	return;
}

stock SetPlayerBleedRate(playerid, Float:rate)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	bld_BleedRate[playerid] = rate;

	return 1;
}

stock GetPlayerBleedRate(playerid, &Float:bleedrate)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	bleedrate = bld_BleedRate[playerid];
	return 1;
}

stock GetPlayerBleedSlowRate(Float:hp, Float:bleedrate, wounds, &Float:rate) {
	rate = (((((100.0 - hp) / 360.0) * bleedrate) / wounds) / 100.0);
}
