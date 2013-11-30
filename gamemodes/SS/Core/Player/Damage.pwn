public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(playerid))
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
			new model = GetVehicleModel(gPlayerData[issuerid][ply_CurrentVehicle]);

			if(model == 447 || model == 476)
				DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_BULLET);
		}
		case 38:
		{
			if(GetVehicleModel(gPlayerData[issuerid][ply_CurrentVehicle]) == 425)
				DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_BULLET);
		}
		case 49:
		{
			DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_COLLISION);
		}
		case 51:
		{
			new model = GetVehicleModel(gPlayerData[issuerid][ply_CurrentVehicle]);

			if(model == 432 || model == 520 || model == 425)
				DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_EXPLOSIVE);
		}
	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(playerid))
		return 0;

	GetPlayerName(playerid, gPlayerData[damagedid][ply_LastHitBy], MAX_PLAYER_NAME);
	gPlayerData[damagedid][ply_LastHitById] = playerid;

	DamagePlayer(playerid, damagedid, weaponid);

	return 1;
}

DamagePlayer(playerid, targetid, weaponid, type = 0)
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
		if(GetTickCountDifference(GetTickCount(), gPlayerData[playerid][ply_DeltDamageTick]) < 400)
			return 0;
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), gPlayerData[playerid][ply_DeltDamageTick]) < 100)
			return 0;
	}

	gPlayerData[playerid][ply_DeltDamageTick] = GetTickCount();

	new
		head,
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

		if(head)
			hploss *= 1.5;

		if(GetPlayerAP(playerid) > 0.0)
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

			SetPlayerAP(playerid, (GetPlayerAP(playerid) - (hploss / 2.0)));
		}

		if(!IsPlayerInAnyVehicle(playerid))
		{
			switch(weaponid)
			{
				case 25, 27, 30, 31, 33, 34:
					head = IsPlayerAimingAtHead(playerid, targetid);
			}
			switch(weaponid)
			{
				case 1..3, 5..7, 10..18, 39:
				{
					if(random(100) < 30)
					{
						t:gPlayerBitData[targetid]<Bleeding>;
					}
				}
				case 0, 40..46:
				{
					// Unused
				}
				default:
				{
					t:gPlayerBitData[targetid]<Bleeding>;

					if((gPlayerData[playerid][ply_HitPoints] - hploss) < 40.0)
					{
						if(random(100) < 70)
						{
							if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
								KnockOutPlayer(targetid, floatround(4000 * (40.0 - (gPlayerData[targetid][ply_HitPoints] - hploss))));
						}
					}
				}
			}
		}
	}
	else if(type == 1)
	{
		hploss = GetMeleeDamage(weaponid, GetCurrentMeleeAnim(playerid));

		if(weaponid == anim_Blunt)
		{
			if(random(100) < 40)
				KnockOutPlayer(targetid, floatround(120 * (100.0 - (gPlayerData[targetid][ply_HitPoints] - hploss))));

			if(random(100) < 30)
			{
				t:gPlayerBitData[targetid]<Bleeding>;
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
				t:gPlayerBitData[targetid]<Bleeding>;
			}
		}

	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
	{
		hploss *= 0.9;
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

		f:gPlayerBitData[targetid]<Bleeding>;
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

		f:gPlayerBitData[targetid]<Bleeding>;
	}

	GivePlayerHP(targetid, -hploss);
	ShowHitMarker(playerid, weaponid);

	return 1;
}

GivePlayerHP(playerid, Float:hp)
{
	SetPlayerHP(playerid, (gPlayerData[playerid][ply_HitPoints] + hp));
}

SetPlayerHP(playerid, Float:hp)
{
	if(hp > 100.0)
		hp = 100.0;

	gPlayerData[playerid][ply_HitPoints] = hp;
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
