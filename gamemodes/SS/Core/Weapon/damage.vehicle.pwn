#include <YSI\y_hooks>


forward Float:OnPlayerVehicleCollide(playerid, targetid, Float:bleedrate);


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
	new
		Float:velocity,
		Float:bleedrate;

	velocity = GetPlayerTotalVelocity(playerid);
	bleedrate = 0.04 * (velocity / 50.0);

	if(velocity > 55.0 && frandom(velocity) > 55.0)
		KnockOutPlayer(targetid, floatround(1000 + ((velocity / 20.0) * 1000)));

	bleedrate += Float:CallLocalFunction("OnPlayerVehicleCollide", "ddf", playerid, targetid, bleedrate);

	PlayerInflictWound(playerid, targetid, E_WOUND_MELEE, bleedrate, NO_CALIBRE, random(2) ? (BODY_PART_TORSO) : (random(2) ? (BODY_PART_RIGHT_LEG) : (BODY_PART_LEFT_LEG)));
}
