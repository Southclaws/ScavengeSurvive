#include <YSI\y_hooks>


forward Float:OnPlayerExplosiveDmg(playerid, Float:bleedrate);


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
	new Float:bleedrate = 0.5 * (multiplier / 80.0);

	if(multiplier > 10.0)
		KnockOutPlayer(targetid, floatround(1000 + (multiplier * 100)));

	bleedrate += Float:CallLocalFunction("OnPlayerExplosiveDmg", "df", targetid, bleedrate);

	PlayerInflictWound(playerid, targetid, E_WOUND_BURN, bleedrate, NO_CALIBRE, random(2) ? (BODY_PART_TORSO) : (random(2) ? (BODY_PART_RIGHT_LEG) : (BODY_PART_LEFT_LEG)));
}
