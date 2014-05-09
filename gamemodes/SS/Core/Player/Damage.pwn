#include <YSI\y_hooks>


static
	dmg_LastHit[MAX_PLAYERS][MAX_PLAYER_NAME],
	dmg_LastHitId[MAX_PLAYERS],
	dmg_LastHitWeapon[MAX_PLAYERS],
	dmg_LastHitBy[MAX_PLAYERS][MAX_PLAYER_NAME],
	dmg_LastHitById[MAX_PLAYERS],
	dmg_LastHitByWeapon[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	dmg_LastHit[playerid][0] = EOS;
	dmg_LastHitId[playerid] = INVALID_PLAYER_ID;
	dmg_LastHitBy[playerid][0] = EOS;
	dmg_LastHitById[playerid] = INVALID_PLAYER_ID;

	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(playerid))
		return 0;

	if(IsPlayerOnAdminDuty(issuerid))
		return 0;

	if(!IsPlayerSpawned(issuerid))
		return 0;

	if(issuerid == INVALID_PLAYER_ID)
	{
		if(weaponid == 53)
		{
			GivePlayerHP(playerid, -(amount * 0.1));
		}
		else
		{
			switch(weaponid)
			{
				case 37:
				{
					GivePlayerHP(playerid, -amount);
				}
				default:
				{
					if(amount > 10.0 && random(100) < amount)
					{
						if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
						{
							GivePlayerHP(playerid, -(amount * 0.5));
						}
						else
						{
							GivePlayerHP(playerid, -(amount * 1.1));
							KnockOutPlayer(playerid, 5000);
						}
					}
				}
			}
		}

		return 1;
	}

	switch(weaponid)
	{
		case 31:
		{
			new model = GetVehicleModel(GetPlayerLastVehicle(playerid));

			if(model == 447 || model == 476)
				DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_BULLET, bodypart);
		}
		case 38:
		{
			if(GetVehicleModel(GetPlayerLastVehicle(playerid)) == 425)
				DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_BULLET, bodypart);
		}
		case 49:
		{
			DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_COLLISION, bodypart);
		}
		case 51:
		{
			new model = GetVehicleModel(GetPlayerLastVehicle(playerid));

			if(model == 432 || model == 520 || model == 425)
				DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_EXPLOSIVE, bodypart);
		}
	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(playerid))
		return 0;

	if(IsPlayerOnAdminDuty(damagedid))
		return 0;

	if(!IsPlayerSpawned(damagedid))
		return 0;

	DamagePlayer(playerid, damagedid, weaponid, bodypart);

	return 1;
}

DamagePlayer(playerid, targetid, weaponid, bodypart, type = 0)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(IsPlayerOnAdminDuty(targetid))
		return 0;

	if(!IsPlayerSpawned(playerid))
		return 0;

	if(!IsPlayerSpawned(targetid))
		return 0;

	if(weaponid == WEAPON_DEAGLE)
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerDeltDamageTick(playerid)) < 790)
			return 0;
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerDeltDamageTick(playerid)) < 100)
			return 0;
	}

	SetPlayerDeltDamageTick(playerid, GetTickCount());

	new
		Float:px,
		Float:py,
		Float:pz,
		Float:tx,
		Float:ty,
		Float:tz,
		Float:distance,
		Float:hploss;

	GetPlayerPos(playerid, px, py, pz);
	GetPlayerPos(targetid, tx, ty, tz);

	distance = Distance(px, py, pz, tx, ty, tz);

	if(type == 0)
	{
		hploss = GetWeaponDamageFromDistance(weaponid, distance);

		if(bodypart == 9)
			hploss *= 1.5;

		if(GetPlayerAP(targetid) > 0.0)
		{
			switch(weaponid)
			{
				case 0..7, 10..15:
					hploss *= 0.5;

				case 22..32, 38:
					hploss *= 0.4;

				case 33, 34:
					hploss *= 0.6;
			}

			SetPlayerAP(targetid, (GetPlayerAP(targetid) - (hploss / 2.0)));
		}

		if(!IsPlayerInAnyVehicle(playerid))
		{
			switch(weaponid)
			{
				case 1..3, 5..7, 10..18, 39:
				{
					if(random(100) < 30)
					{
						SetPlayerBitFlag(targetid, Bleeding, true);
					}
				}
				case 0, 40..46:
				{
					// Unused
				}
				default:
				{
					new Float:hp = GetPlayerHP(playerid);

					SetPlayerBitFlag(targetid, Bleeding, true);

					if((hp - hploss) < 40.0)
					{
						if(random(100) < 70)
						{
							if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
								KnockOutPlayer(targetid, floatround(4000 * (40.0 - (hp - hploss))));
						}
					}
				}
			}
		}
	}
	else if(type == 1)
	{
		hploss = 5.0;

		if(weaponid == anim_Blunt)
		{
			if(random(100) < 40)
				KnockOutPlayer(targetid, floatround(120 * (100.0 - (GetPlayerHP(playerid) - hploss))));

			if(random(100) < 30)
			{
				SetPlayerBitFlag(targetid, Bleeding, true);
			}
		}
		if(weaponid == anim_Stab)
		{
			if(GetItemType(GetPlayerItem(playerid)) == item_Taser)
			{
				KnockOutPlayer(targetid, 60000);
				CreateTimedDynamicObject(18724, tx, ty, tz-1.0, 0.0, 0.0, 0.0, 1000);
				hploss = 0.0;
			}
			else
			{
				SetPlayerBitFlag(targetid, Bleeding, true);
			}
		}

	}

	if(GetItemType(GetPlayerItem(targetid)) == item_Shield)
	{
		new
			Float:angleto,
			Float:targetangle;

		GetPlayerFacingAngle(targetid, targetangle);

		angleto = absoluteangle(targetangle - GetAngleToPoint(tx, ty, px, py));

		if(45.0 < angleto < 135.0)
			hploss *= 0.1;

		SetPlayerBitFlag(targetid, Bleeding, false);
	}

	if(GetItemType(GetPlayerHolsterItem(targetid)) == item_Shield)
	{
		new
			Float:angleto,
			Float:targetangle;

		GetPlayerFacingAngle(targetid, targetangle);

		angleto = absoluteangle(targetangle - GetAngleToPoint(tx, ty, px, py));

		if(155.0 < angleto < 205.0)
			hploss *= 0.1;

		SetPlayerBitFlag(targetid, Bleeding, false);
	}

	GetPlayerName(targetid, dmg_LastHit[playerid], MAX_PLAYER_NAME);
	dmg_LastHitId[playerid] = targetid;
	dmg_LastHitWeapon[playerid] = weaponid;

	GetPlayerName(playerid, dmg_LastHitBy[targetid], MAX_PLAYER_NAME);
	dmg_LastHitById[targetid] = playerid;
	dmg_LastHitByWeapon[targetid] = weaponid;

	GivePlayerHP(targetid, -hploss);
	ShowHitMarker(playerid, weaponid);

	return 1;
}

GivePlayerHP(playerid, Float:hp)
{
	SetPlayerHP(playerid, (GetPlayerHP(playerid) + hp));
}

ShowHitMarker(playerid, weapon)
{
	if(weapon == 34 || weapon == 35)
	{
		TextDrawShowForPlayer(playerid, HitMark_centre);
		defer HideHitMark(playerid, HitMark_centre);
	}
	else
	{
		TextDrawShowForPlayer(playerid, HitMark_offset);
		defer HideHitMark(playerid, HitMark_offset);
	}
}
timer HideHitMark[500](playerid, Text:hitmark)
{
	TextDrawHideForPlayer(playerid, hitmark);
}

// dmg_LastHit
stock GetLastHit(playerid, name[MAX_PLAYER_NAME])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	name[0] = EOS;
	strcat(name, dmg_LastHit[playerid]);

	return 1;
}

// dmg_LastHitId
stock GetLastHitId(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dmg_LastHitId[playerid];
}

// dmg_LastHitId
stock GetLastHitWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dmg_LastHitId[playerid];
}

// dmg_LastHitWeapon
stock GetLastHitBy(playerid, name[MAX_PLAYER_NAME])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	name[0] = EOS;
	strcat(name, dmg_LastHitWeapon[playerid]);

	return 1;
}

// dmg_LastHitById
stock GetLastHitById(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dmg_LastHitById[playerid];
}

// dmg_LastHitByWeapon
stock GetLastHitByWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return dmg_LastHitByWeapon[playerid];
}
