#include <YSI\y_hooks>


hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(weaponid == 51)
	{
		_DoExplosiveDamage(issuerid, playerid, amount);
	}

	return 1;
}

_DoExplosiveDamage(playerid, targetid, Float:multiplier)
{
	if(multiplier > 10.0)
		KnockOutPlayer(targetid, floatround(1000 + (multiplier * 100)));

	PlayerInflictWound(playerid, targetid, E_WOUND_BURN, 0.5 * (multiplier / 80.0), NO_CALIBRE, random(2) ? (BODY_PART_TORSO) : (random(2) ? (BODY_PART_RIGHT_LEG) : (BODY_PART_LEFT_LEG)));
}
