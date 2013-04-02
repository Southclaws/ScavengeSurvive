#include <YSI\y_hooks>


#define MAX_SAVES_PER_BLOCK (10)
#define SAVE_BLOCK_INTERVAL	(800)


new
	autosave_Block[ITM_MAX],
	autosave_Max;


task AutoSave[60000]()
{
	if(Iter_Count(Player) == 0)
		return;

	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	foreach(new i : Player)
	{
		SavePlayerData(i, false);
	}

	defer AutoSave_Safeboxes();
}

timer AutoSave_Safeboxes[3000]()
{
	AutosaveSafeboxes();
	defer AutoSave_Vehicles();
}

timer AutoSave_Vehicles[3000]()
{
	AutosaveVehicles();
	defer AutoSave_Defenses();
}

timer AutoSave_Defenses[3000]()
{
	AutosaveDefenses();
}


/*
#endinput

hook OnGameModeInit()
{
	defer savetest();
}

timer savetest[1000]()
{
	foreach(new i : Player)
	{
		SavePlayerData(i, false);
	}

	defer AutoSave_Safeboxes();
}

*/
