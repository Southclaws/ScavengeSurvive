#include <a_samp>


static PlayerAimPunch[MAX_PLAYERS] = {0, ...};


public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(PlayerAimPunch[playerid] == 0)
		PlayerAimPunch[playerid] = 1000;

	SetPlayerDrunkLevel(playerid, PlayerAimPunch[playerid]);
	PlayerAimPunch[playerid] += 100;

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!(oldkeys & KEY_FIRE))
	{
		SetPlayerDrunkLevel(playerid, 0);
		PlayerAimPunch[playerid] = 0;
	}

	return 1;
}
