#include <YSI\y_hooks>


#define MAX_SAVES_PER_BLOCK_PLAYERS (1)
#define MAX_SAVES_PER_BLOCK_SAFEBOX (8)
#define MAX_SAVES_PER_BLOCK_VEHICLE (8)
#define SAVE_BLOCK_INTERVAL	(50)
//#define AUTOSAVE_DEBUG

new
#if defined AUTOSAVE_DEBUG
		autosave_TickTotal,
		autosave_Tick,
#endif
		autosave_Block[ITM_MAX],
		autosave_Max,
bool:	autosave_Active;


timer AutoSave[60000]()
{
	#if defined AUTOSAVE_DEBUG
	autosave_TickTotal = tickcount();
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
	printf("Vehicle tick: %d", tickcount() - autosave_Tick);
	printf("AUTOSAVE COMPLETE time: %d", tickcount() - autosave_TickTotal);
	#endif
}


/*==============================================================================

	Player

==============================================================================*/


AutoSave_Player()
{
	#if defined AUTOSAVE_DEBUG
	print("AutoSave_Player");
	autosave_Tick = tickcount();
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
	#if defined AUTOSAVE_DEBUG
	autosave_Tick = tickcount();
	#endif

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
	printf("Player tick: %d", tickcount() - autosave_Tick);
	print("AutoSave_Safebox");
	autosave_Tick = tickcount();
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
	printf("Safebox tick: %d", tickcount() - autosave_Tick);
	print("AutoSave_Vehicles");
	autosave_Tick = tickcount();
	#endif

	new
		idx,
		owner[MAX_PLAYER_NAME];

	foreach(new i : veh_Index)
	{
		GetVehicleOwner(i, owner);

		if(strlen(owner) >= 3 && IsValidVehicleID(i))
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

	new
		i,
		owner[MAX_PLAYER_NAME];

	for(i = index; i < index + MAX_SAVES_PER_BLOCK_VEHICLE && i < autosave_Max; i++)
	{
		GetVehicleOwner(autosave_Block[i], owner);
		SavePlayerVehicle(autosave_Block[i], owner);
	}

	if(i < autosave_Max)
		defer Vehicle_BlockSave(i);

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


ACMD:autosave[3](playerid, params[])
{
	AutoSave();
	return 1;
}
