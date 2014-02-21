#include <a_samp>
#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <SIF/SIF>
#include <streamer>
#include <zcmd>
#include <VehicleMatrix>
#include <Line>
#include <Zipline>


public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(!IsPlayerStreamedIn(playerid, hitid) || !IsPlayerStreamedIn(hitid, playerid))
		return 0;

	new
		Float:x,
		Float:y,
		Float:z;

	if(hittype == BULLET_HIT_TYPE_NONE)
	{
		x = fX;
		y = fY;
		z = fZ;
	}

	if(hittype == BULLET_HIT_TYPE_PLAYER)
	{
		// TODO
	}

	if(hittype == BULLET_HIT_TYPE_VEHICLE)
	{

	}

	if(hittype == BULLET_HIT_TYPE_OBJECT)
	{

	}

	if(hittype == BULLET_HIT_TYPE_PLAYER_OBJECT)
	{

	}

	CreateDynamicObject(327, x, y, z, 0.0, 0.0, 0.0);

	return 1;
}


public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{

}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{

}
