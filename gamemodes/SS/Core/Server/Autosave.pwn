#include <YSI\y_hooks>


#define MAX_SAVES_PER_BLOCK_PLAYERS (1)
#define SAVE_BLOCK_INTERVAL	(50)


static
		autosave_Block[ITM_MAX],
		autosave_Max,
bool:	autosave_Active,
bool:	autosave_Toggle,
		autosave_Interval;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Autosave'...");

	GetSettingInt("autosave/autosave-toggle", 1, autosave_Toggle);
	GetSettingInt("autosave/autosave-interval", 60000, autosave_Interval);

	defer AutoSave();
}

timer AutoSave[autosave_Interval]()
{
	if(!autosave_Toggle)
		return;

	if(Iter_Count(Player) == 0)
	{
		defer AutoSave();
		return;
	}

	if(gServerUptime > gServerMaxUptime - 20)
		return;

	AutoSave_Player();

	return;
}

AutoSave_Player()
{
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
		defer AutoSave();

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
