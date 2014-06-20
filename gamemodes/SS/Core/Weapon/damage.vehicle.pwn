#include <YSI\y_hooks>


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
	new Float:velocity = GetPlayerTotalVelocity(playerid);

	if(velocity > 55.0)
		KnockOutPlayer(targetid, floatround(1000 + ((velocity / 20.0) * 1000)));

	PlayerInflictWound(playerid, targetid, E_WOUND_MELEE, 0.3 * (velocity / 50.0), NO_CALIBRE, random(2) ? (BODY_PART_TORSO) : (random(2) ? (BODY_PART_RIGHT_LEG) : (BODY_PART_LEFT_LEG)));
}
