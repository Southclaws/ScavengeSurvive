hook OnPlayerUpdate(playerid)
{
	f:gPlayerBitData[playerid]<AfkCheck>;
	return 1;
}

ptask AfkCheckUpdate[3000](playerid)
{
	if(gPlayerBitData[playerid] & Spawned)
	{
	    new
			playerstate = GetPlayerState(playerid);

		if(gPlayerBitData[playerid] & AfkCheck)
		{
			if(!(gPlayerBitData[playerid] & IsAfk))
			{
				if(tickcount() - GetPlayerVehicleExitTick(playerid) > 2000 && ((1 <= playerstate <= 3) || playerstate == 8))
				{
					t:gPlayerBitData[playerid]<IsAfk>;
				}
			}
		}
	}

	if(!(gPlayerBitData[playerid] & AfkCheck))
	{
		if(gPlayerBitData[playerid] & IsAfk)
		{
			f:gPlayerBitData[playerid]<IsAfk>;
		}
	}

	t:gPlayerBitData[playerid]<AfkCheck>;
}

IsPlayerUnfocused(playerid)
{
	return gPlayerBitData[playerid] & IsAfk ? 1 : 0;
}
