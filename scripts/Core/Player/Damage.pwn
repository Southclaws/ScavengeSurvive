public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
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
			new model = GetVehicleModel(gPlayerVehicleID[issuerid]);

			if(model == 447 || model == 476)
				DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_BULLET);
		}
		case 38:
		{
			if(GetVehicleModel(gPlayerVehicleID[issuerid]) == 425)
				DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_BULLET);
		}
		case 49:
		{
			DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_COLLISION);
		}
		case 51:
		{
			new model = GetVehicleModel(gPlayerVehicleID[issuerid]);

			if(model == 432 || model == 520 || model == 425)
				DamagePlayer(issuerid, playerid, WEAPON_VEHICLE_EXPLOSIVE);
		}
	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 0;

	gLastHitBy[damagedid] = gPlayerName[playerid];
	DamagePlayer(playerid, damagedid, weaponid);
	return 1;
}

DamagePlayer(playerid, targetid, weaponid, type = 0)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 0;

	if(weaponid == WEAPON_DEAGLE)
	{
		if(tickcount() - tick_WeaponHit[playerid] < 400)
			return 0;
	}
	else
	{
		if(tickcount() - tick_WeaponHit[playerid] < 100)
			return 0;
	}

	tick_WeaponHit[playerid] = tickcount();

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

		if(gPlayerAP[targetid] > 0.0)
		{
			switch(weaponid)
			{
				case 0..7, 10..15:
					hploss *= 0.6;

				case 22..32, 38:
					hploss *= 0.5;

				case 33, 34:
					hploss *= 0.8;
			}

			gPlayerAP[targetid] -= (hploss / 2.0);
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
						t:bPlayerGameSettings[targetid]<Bleeding>;
					}
				}
				case 0, 40..46:
				{
					// Unused
				}
				default:
				{
					t:bPlayerGameSettings[targetid]<Bleeding>;

					if((gPlayerHP[playerid] - hploss) < 40.0)
					{
						if(random(100) < 70)
						{
							if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
								KnockOutPlayer(targetid, floatround(4000 * (40.0 - (gPlayerHP[targetid] - hploss))));
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
				KnockOutPlayer(targetid, floatround(120 * (100.0 - (gPlayerHP[targetid] - hploss))));

			if(random(100) < 30)
			{
				t:bPlayerGameSettings[targetid]<Bleeding>;
			}
		}
		if(weaponid == anim_Stab)
		{
			t:bPlayerGameSettings[targetid]<Bleeding>;
		}

		if(GetItemType(GetPlayerItem(playerid)) == item_Taser)
		{
			KnockOutPlayer(targetid, 60000);
			CreateTimedDynamicObject(18724, tx, ty, tz-1.0, 0.0, 0.0, 0.0, 1000);
			hploss = 0.0;
			f:bPlayerGameSettings[targetid]<Bleeding>;
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

		angleto = absoluteangle(targetangle - GetAngleToPoint(px, py, tx, ty));

		if(225.0 < angleto < 315.0)
			hploss *= 0.2;

		f:bPlayerGameSettings[targetid]<Bleeding>;
	}

	GivePlayerHP(targetid, -hploss);
	ShowHitMarker(playerid, weaponid);

	return 1;
}

GivePlayerHP(playerid, Float:hp)
{
	SetPlayerHP(playerid, (gPlayerHP[playerid] + hp));
}

SetPlayerHP(playerid, Float:hp)
{
	if(hp > 100.0)
		hp = 100.0;

	gPlayerHP[playerid] = hp;
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
