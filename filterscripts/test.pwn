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
