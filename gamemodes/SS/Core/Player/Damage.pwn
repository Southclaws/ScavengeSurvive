#include <YSI\y_hooks>


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
			default:
			{
				if(amount > 6.0 || amount > 70.0)
				{
					KnockOutPlayer(playerid, floatround(amount * (IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE) ? 52 : 64)));
				}
			}
		}

		return 1;
	}

	switch(weaponid)
	{
		case 31:
		{
			new model = GetVehicleModel(GetPlayerVehicleID(playerid));

			if(model == 447 || model == 476)
				_DoFirearmDamage(issuerid, playerid, item_VehicleWeapon, bodypart);
		}
		case 38:
		{
			if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 425)
				_DoFirearmDamage(issuerid, playerid, item_VehicleWeapon, bodypart);
		}
	}

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

