#include <YSI\y_hooks>


#define MAX_SAVES_PER_BLOCK_PLAYERS (1)
#define MAX_SAVES_PER_BLOCK_VEHICLE (8)
#define SAVE_BLOCK_INTERVAL	(50)

static
		autosave_Block[ITM_MAX],
		autosave_Max,
bool:	autosave_Active,

bool:	autosave_Toggle = true,
bool:	autosave_Debug,
		autosave_TickTotal,
		autosave_Tick;


timer AutoSave[60000]()
{
	if(!autosave_Toggle)
		return;

	if(autosave_Debug)
		autosave_TickTotal = GetTickCount();

	if(Iter_Count(Player) == 0)
	{
		defer AutoSave();
		return;
	}

	if(gServerUptime > gServerMaxUptime - 20)
		return;

	if(autosave_Debug)
		print("AUTOSAVE STARTING");

	AutoSave_Player();

	return;
}

Autosave_End()
{
	defer AutoSave();

	if(autosave_Debug)
	{
		printf("Vehicle tick: %d", GetTickCountDifference(GetTickCount(), autosave_Tick));
		printf("AUTOSAVE COMPLETE time: %d", GetTickCountDifference(GetTickCount(), autosave_TickTotal));
	}
}


/*==============================================================================

	Player

==============================================================================*/


AutoSave_Player()
{
	if(autosave_Debug)
	{
		print("AutoSave_Player");
		autosave_Tick = GetTickCount();
	}

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
	if(autosave_Debug)
		autosave_Tick = GetTickCount();

	autosave_Active = true;

	if(gServerUptime > gServerMaxUptime - 20)
		return;

	new i;

	for(i = index; i < index + MAX_SAVES_PER_BLOCK_PLAYERS && i < autosave_Max; i++)
	{
		SavePlayerData(autosave_Block[i]);
	}

	if(i < autosave_Max)
		defer Player_BlockSave(i);

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
	if(autosave_Debug)
	{
		printf("Player tick: %d", GetTickCountDifference(GetTickCount(), autosave_Tick));
		print("AutoSave_Vehicles");
		autosave_Tick = GetTickCount();
	}

	new
		idx,
		owner[MAX_PLAYER_NAME];

	foreach(new i : veh_Index)
	{
		GetVehicleOwner(i, owner);

		if(strlen(owner) >= 3 && IsValidVehicle(i))
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

	if(gServerUptime > gServerMaxUptime - 20)
		return;

	new i;

	for(i = index; i < index + MAX_SAVES_PER_BLOCK_VEHICLE && i < autosave_Max; i++)
	{
		UpdateVehicleFile(autosave_Block[i], false);
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

ACMD:autosavedebug[4](playerid, params[])
{
	autosave_Debug = !autosave_Debug;
	MsgF(playerid, YELLOW, " >  Autosave debug: %d", autosave_Debug);

	return 1;
}

ACMD:autosavetoggle[4](playerid, params[])
{
	if(autosave_Toggle)
	{
		autosave_Toggle = false;
	}
	else
	{
		autosave_Toggle = true;
		defer AutoSave();
	}

	MsgF(playerid, YELLOW, " >  Autosave toggle: %d", autosave_Toggle);

	return 1;
}
