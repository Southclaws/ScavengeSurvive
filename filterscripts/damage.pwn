#include <a_samp>



public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	new str[128];
	format(str, 128, "Amount: %f weaponid: %d bodypard: %d", amount, weaponid, bodypart);
	SendClientMessage(playerid, -1, str);
	return 1;
}
