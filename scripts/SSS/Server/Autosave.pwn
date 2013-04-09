#include <YSI\y_hooks>


#define MAX_SAVES_PER_BLOCK (10)
#define SAVE_BLOCK_INTERVAL	(800)


new
		autosave_Block[ITM_MAX],
		autosave_Max,
bool:	autosave_Active;


task AutoSave[60000]()
{
	autosave_Active = true;

	if(Iter_Count(Player) == 0)
		return;

	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	foreach(new i : Player)
	{
		SavePlayerData(i);
	}

	defer AutoSave_Safeboxes();

	autosave_Active = false;
}

timer AutoSave_Safeboxes[3000]()
{
	autosave_Active = true;

	AutosaveSafeboxes();
	defer AutoSave_Vehicles();

	autosave_Active = false;
}

timer AutoSave_Vehicles[3000]()
{
	autosave_Active = true;

	AutosaveVehicles();
	defer AutoSave_Defenses();

	autosave_Active = false;
}

timer AutoSave_Defenses[3000]()
{
	autosave_Active = true;

	AutosaveDefenses();

	autosave_Active = false;
}

stock IsAutoSaving()
{
	return autosave_Active;
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
