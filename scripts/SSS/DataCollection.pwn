#include <YSI\y_hooks>


UpdateStatistic(key[], amount)
{
	if(!fexist("Stats.txt"))
		file_Create("Stats.txt");

	file_Open("Stats.txt");
	file_SetVal(key, file_GetVal(key) + amount);
	file_Save("Stats.txt");
	file_Close();
}


hook OnPlayerDeath(playerid, killerid, reason)
{
	switch(GetPlayerWeapon(playerid))
	{
		case 43..46, 0:
		{
			UpdateStatistic("UnarmedKills", 1);
		}
		default:
		{
			UpdateStatistic("ArmedKills", 1);
		}
	}
}
