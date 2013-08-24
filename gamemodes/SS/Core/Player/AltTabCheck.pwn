#include <YSI\y_hooks>


new
bool:	tab_Check[MAX_PLAYERS],
bool:	tab_IsTabbed[MAX_PLAYERS],
		tab_TabOutTick[MAX_PLAYERS];


hook OnPlayerUpdate(playerid)
{
	tab_Check[playerid] = false;
	return 1;
}


ptask AfkCheckUpdate[3000](playerid)
{
	if(!IsPlayerSpawned(playerid))
		return;

	if(tickcount() - GetPlayerServerJoinTick(playerid) < 10000)
		return;

	if(tab_Check[playerid])
	{
		if(!tab_IsTabbed[playerid])
		{
			new playerstate = GetPlayerState(playerid);

			if(tickcount() - GetPlayerVehicleExitTick(playerid) > 2000 && ((1 <= playerstate <= 3) || playerstate == 8))
			{
				if(gMaxTaboutTime == 0)
				{
					KickPlayer(playerid, sprintf("Unfocused from the game. Kicked to prevent starving and save server resources", gMaxTaboutTime));
					return;
				}

				tab_TabOutTick[playerid] = tickcount();
				tab_IsTabbed[playerid] = true;
			}
		}

		if(!IsPlayerOnAdminDuty(playerid))
		{
			if(tickcount() - tab_TabOutTick[playerid] > gMaxTaboutTime * 1000)
			{
				KickPlayer(playerid, sprintf("Unfocused for over %d seconds. Kicked to prevent starving and save server resources", gMaxTaboutTime));
				return;
			}
		}
	}

	if(!tab_Check[playerid])
	{
		if(tab_IsTabbed[playerid])
		{
			tab_IsTabbed[playerid] = false;
		}
	}

	tab_Check[playerid] = true;

	return;
}

IsPlayerUnfocused(playerid)
{
	return tab_IsTabbed[playerid];
}
