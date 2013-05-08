#include <YSI\y_hooks>


#define MAX_SAVES_PER_BLOCK_PLAYERS (8)
#define MAX_SAVES_PER_BLOCK_SAFEBOX (32)
#define MAX_SAVES_PER_BLOCK_VEHICLE (16)
#define MAX_SAVES_PER_BLOCK_DEFENSE (32)
#define SAVE_BLOCK_INTERVAL	(50)
//#define AUTOSAVE_DEBUG

new
#if defined AUTOSAVE_DEBUG
		autosave_Tick,
#endif
		autosave_Block[ITM_MAX],
		autosave_Max,
bool:	autosave_Active;


timer AutoSave[60000]()
{
	#if defined AUTOSAVE_DEBUG
	autosave_Tick = tickcount();
	#endif

	if(Iter_Count(Player) == 0)
	{
		defer AutoSave();
		return;
	}

	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	#if defined AUTOSAVE_DEBUG
	print("AUTOSAVE STARTING");
	#endif

	AutoSave_Player();
}

Autosave_End()
{
	defer AutoSave();

	#if defined AUTOSAVE_DEBUG
	printf("AUTOSAVE COMPLETE time: %d", tickcount() - autosave_Tick);
	#endif
}


/*==============================================================================

	Player

==============================================================================*/


AutoSave_Player()
{
	#if defined AUTOSAVE_DEBUG
	print("AutoSave_Player");
	#endif

	new idx;

	foreach(new i : Player)
	{
		autosave_Block[idx] = i;
		idx++;
	}
	autosave_Max = idx;

	defer Player_BlockSave(0);
}

timer Player_BlockSave[SAVE_BLOCK_INTERVAL](index)
{
	autosave_Active = true;

	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	new i;

	for(i = index; i < index + MAX_SAVES_PER_BLOCK_PLAYERS && i < autosave_Max; i++)
	{
		SavePlayerData(autosave_Block[i]);
	}

	if(i < autosave_Max)
		defer Player_BlockSave(i);

	else
		AutoSave_Safebox();

	autosave_Active = false;

	return;
}


/*==============================================================================

	Safebox

==============================================================================*/


timer AutoSave_Safebox[3000]()
{
	#if defined AUTOSAVE_DEBUG
	print("AutoSave_Safebox");
	#endif

	new idx;

	foreach(new i : box_Index)
	{
		if(!IsItemInWorld(i))
			continue;

		if(!IsValidContainer(GetItemExtraData(i)))
			continue;

		if(IsContainerEmpty(GetItemExtraData(i)))
			continue;

		if(!IsItemTypeSafebox(GetItemType(i)))
			continue;

		autosave_Block[idx] = i;
		idx++;
	}
	autosave_Max = idx;

	defer Safebox_BlockSave(0);
}
timer Safebox_BlockSave[SAVE_BLOCK_INTERVAL](index)
{
	autosave_Active = true;

	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	new i;

	for(i = index; i < index + MAX_SAVES_PER_BLOCK_SAFEBOX && i < autosave_Max; i++)
	{
		SaveSafeboxItem(autosave_Block[i], false);
	}

	if(i < autosave_Max)
		defer Safebox_BlockSave(i);

	else
		AutoSave_Vehicles();

	autosave_Active = false;

	return;
}


/*==============================================================================

	Vehicles

==============================================================================*/


timer AutoSave_Vehicles[3000]()
{
	#if defined AUTOSAVE_DEBUG
	print("AutoSave_Vehicles");
	#endif

	new idx;

	foreach(new i : gVehicleIndex)
	{
		if(strlen(gVehicleOwner[i]) >= 3 && IsValidVehicle(i))
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
	autosave_Active = true;

	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	new i;

	for(i = index; i < index + MAX_SAVES_PER_BLOCK_VEHICLE && i < autosave_Max; i++)
	{
		SavePlayerVehicle(autosave_Block[i], gVehicleOwner[autosave_Block[i]], false);
	}

	if(i < autosave_Max)
		defer Vehicle_BlockSave(i);

	else
		Autosave_Defense();

	autosave_Active = false;

	return;
}


/*==============================================================================

	Defense

==============================================================================*/


timer Autosave_Defense[3000]()
{
	#if defined AUTOSAVE_DEBUG
	print("Autosave_Defense");
	#endif

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
	autosave_Active = true;

	if(gServerUptime > MAX_SERVER_UPTIME - 20)
		return;

	new i;

	for(i = index; i < index + MAX_SAVES_PER_BLOCK_DEFENSE && i < autosave_Max; i++)
	{
		SaveDefenseItem(autosave_Block[i]);
	}

	if(i < autosave_Max)
		defer Defense_BlockSave(i);

	else
		Autosave_End();

	autosave_Active = false;

	return;
}



/*==============================================================================

	Interface

==============================================================================*/


stock IsAutoSaving()
{
	return autosave_Active;
}
