hook OnPlayerUpdate(playerid)
{
	f:bPlayerGameSettings[playerid]<AfkCheck>;
	return 1;
}

ptask AfkCheckUpdate[3000](playerid)
{
	if(bPlayerGameSettings[playerid] & Spawned)
	{
	    new
			playerstate = GetPlayerState(playerid);

		if(bPlayerGameSettings[playerid] & AfkCheck)
		{
			if(!(bPlayerGameSettings[playerid] & IsAfk))
			{
				if(tickcount() - tick_ExitVehicle[playerid] > 2000 && ((1 <= playerstate <= 3) || playerstate == 8))
				{
					t:bPlayerGameSettings[playerid]<IsAfk>;
				}
			}
		}
	}

	if(!(bPlayerGameSettings[playerid] & AfkCheck))
	{
		if(bPlayerGameSettings[playerid] & IsAfk)
		{
			f:bPlayerGameSettings[playerid]<IsAfk>;
		}
	}

	t:bPlayerGameSettings[playerid]<AfkCheck>;
}

IsPlayerUnfocused(playerid)
{
	return bPlayerGameSettings[playerid] & IsAfk ? 1 : 0;
}
