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


AutosaveSafeboxes()
{
	new idx;

	foreach(new i : box_Index)
	{
		if(!IsItemInWorld(i))
			continue;

		if(!IsValidContainer(GetItemExtraData(i)))
			continue;

		if(IsContainerEmpty(GetItemExtraData(i)))
			continue;

		autosave_Block[idx] = i;
		idx++;
	}
	autosave_Max = idx;

	defer Safebox_BlockSave(0);
}

timer Safebox_BlockSave[SAVE_BLOCK_INTERVAL](index)
{
	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	new i;

	for(i = index; i < index + MAX_SAVES_PER_BLOCK; i++)
	{
		if(i >= autosave_Max)
			return;

		SaveSafeboxItem(autosave_Block[i], false);
	}

	defer Safebox_BlockSave(i);

	return;
}


AutosaveDefenses()
{
	new idx;

	foreach(new i : def_Index)
	{
		autosave_Block[idx] = i;
		idx++;
	}
	autosave_Max = idx;

	defer Defense_BlockSave(0);
}

timer Defense_BlockSave[SAVE_BLOCK_INTERVAL](index)
{
	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	new i;

	for(i = index; i < index + MAX_SAVES_PER_BLOCK; i++)
	{
		if(i == autosave_Max)
			return;

		SaveDefenseItem(autosave_Block[i]);
	}

	defer Defense_BlockSave(i);

	return;
}


AutosaveVehicles()
{
	new idx;

	foreach(new i : gVehicleIndex)
	{
		if(!isnull(gVehicleOwner[i]))
		{
			autosave_Block[idx] = i;
			idx++;
		}
	}
	autosave_Max = idx;

	defer Vehicle_BlockSave(0);
}

timer Vehicle_BlockSave[SAVE_BLOCK_INTERVAL](index)
{
	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	new i;

	for(i = index; i < index + MAX_SAVES_PER_BLOCK; i++)
	{
		if(i == autosave_Max)
			return;

		SavePlayerVehicle(autosave_Block[i], gVehicleOwner[autosave_Block[i]], false);
	}

	defer Vehicle_BlockSave(i);

	return;
}

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
