#include <a_samp>
#include <zcmd>
#include <YSI\y_timers>


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	defer delay(playerid);
}
timer delay[1000](playerid)
{
	print("HIDING");
	ShowPlayerDialog(playerid, -1, 0, " ", " ", " ", " ");
	return 1;
}
