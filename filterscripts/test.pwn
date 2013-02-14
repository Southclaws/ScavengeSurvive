#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <YSI\y_timers>


CMD:lights(playerid, params[])
{
	new l1, l2, l3, l4;
	sscanf(params, "dddd", l1, l2, l3, l4);
	UpdateVehicleDamageStatus(GetPlayerVehicleID(playerid), 0, 0, (l1 | (l2 << 1) | (l3 << 2) | (l4 << 3)), 0);
	return 1;
}

CMD:time(playerid, params[])
{
	new h, m;
	sscanf(params, "dd", h, m);
	SetPlayerTime(playerid, h, m);
	return 1;
}

CMD:w(playerid, params[])
{
	SetPlayerWeather(playerid, strval(params));

	return 1;
}

CMD:carry(playerid, params[])
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	return 1;
}

CMD:none(playerid, params[])
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	return 1;
}
