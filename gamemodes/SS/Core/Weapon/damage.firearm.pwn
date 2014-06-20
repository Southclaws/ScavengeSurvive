#include <YSI\y_hooks>


forward Float:OnPlayerShootPlayer(playerid, targetid, bodypart, Float:bleedrate, bulletvelocity, distance);


hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	if(IsPlayerOnAdminDuty(damagedid))
		return 0;

	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(damagedid))
		return 0;

	if(!IsPlayerSpawned(playerid))
		return 0;

	_HandleFirearmDamage(playerid, damagedid, bodypart);

	return 1;
}

_HandleFirearmDamage(playerid, targetid, bodypart)
{
	new
		itemid,
		ItemType:itemtype,
		weapontype,
		baseweapon;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);
	weapontype = GetItemTypeWeapon(itemtype);
	baseweapon = GetItemWeaponBaseWeapon(weapontype);

	if(!IsBaseWeaponClipBased(baseweapon))
		return 0;

	if(GetItemWeaponBaseWeapon(weapontype) == WEAPON_DEAGLE)
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerDeltDamageTick(playerid)) < 790)
			return 0;
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerDeltDamageTick(playerid)) < 100)
			return 0;
	}

	return _DoFirearmDamage(playerid, targetid, itemtype, bodypart);
}

_DoFirearmDamage(playerid, targetid, ItemType:itemtype, bodypart)
{
	d:1:FIREARM_DEBUG("[_DoFirearmDamage] playerid: %d targetid: %d itemtype: %d bodypart: %d ", playerid, targetid, _:itemtype, bodypart);

	new
		calibre,
		Float:bleedrate,
		Float:bulletvelocity,
		Float:distance,
		Float:velocitydegredationrate;

	calibre = GetItemTypeWeaponCalibre(itemtype);
	bleedrate = GetCalibreBleedRate(calibre);
	bulletvelocity = GetItemTypeWeaponMuzzVelocity(itemtype);
	distance = GetDistanceBetweenPlayers(playerid, targetid);

	d:2:FIREARM_DEBUG("[_DoFirearmDamage] bleedrate: %.4f muzzlevel: %.4f distance: %.4f", bleedrate, bulletvelocity, distance);

	// Turns the muzzle velocity (initial velocity) into a factor that affects
	// the bullet velocity depending on the distance it has travelled.
	// To put it simply, if the weapon has a high muzzle velocity, the round
	// isn't affected by the distance as much as a weapon with a low muzzle
	// velocity.
	velocitydegredationrate = 1.0 - (bulletvelocity / 1000);
	d:2:FIREARM_DEBUG("[_DoFirearmDamage] velocitydegredationrate: %.4f", velocitydegredationrate);

	// Now a graph function, the distance is the 'x' and the degradation rate is
	// the power. This gives a curved line which gradually lowers the velocity
	// as the distance increases.
	bulletvelocity -= floatpower(distance, velocitydegredationrate);
	d:2:FIREARM_DEBUG("[_DoFirearmDamage] bulletvelocity: %.4f", bulletvelocity);

	// Now to combine the bullet velocity with the initial bleed rate of the
	// bullet calibre which results in the final bleed rate for the player.
	bleedrate = (bleedrate * (bulletvelocity / 1000.0));
	d:2:FIREARM_DEBUG("[_DoFirearmDamage] bleedrate: %.4f", bleedrate);

	bleedrate += Float:CallLocalFunction("OnPlayerShootPlayer", "dddfdd", playerid, targetid, bodypart, bleedrate, bulletvelocity, distance);
	d:2:FIREARM_DEBUG("[_DoFirearmDamage] bleedrate: %.4f (after callback)", bleedrate);

	PlayerInflictWound(playerid, targetid, E_WOUND_FIREARM, bleedrate, calibre, bodypart);
	ShowHitMarker(playerid, GetItemTypeWeaponBaseWeapon(itemtype));

	return 1;
}


/*

To implement:

knockouts:

	new Float:hp = GetPlayerHP(playerid);

	SetPlayerBleedRate(targetid, 0.01);

	if((hp - hploss) < 40.0)
	{
		if(random(100) < 70)
		{
			if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
				KnockOutPlayer(targetid, floatround(4000 * (40.0 - (hp - hploss))));
		}
	}

*/
