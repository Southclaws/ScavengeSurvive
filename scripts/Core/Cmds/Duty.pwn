static tick_AdminDuty[MAX_PLAYERS];

ACMD:duty[1](playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
	{
		Msg(playerid, YELLOW, " >  You cannot do that while spectating.");
		return 1;
	}

	if(bPlayerGameSettings[playerid] & AdminDuty)
	{
		f:bPlayerGameSettings[playerid]<AdminDuty>;

		SetPlayerPos(playerid,
			gPlayerData[playerid][ply_posX],
			gPlayerData[playerid][ply_posY],
			gPlayerData[playerid][ply_posZ]);

		RemovePlayerWeapon(playerid);
		LoadPlayerInventory(playerid);
		LoadPlayerChar(playerid);

		SetPlayerClothes(playerid, gPlayerData[playerid][ply_Skin]);

		tick_AdminDuty[playerid] = tickcount();
	}
	else
	{
		if(tickcount() - tick_AdminDuty[playerid] < 10000)
		{
			Msg(playerid, YELLOW, " >  Please don't use the duty ability that frequently.");
			return 1;
		}

		GetPlayerPos(playerid,
			gPlayerData[playerid][ply_posX],
			gPlayerData[playerid][ply_posY],
			gPlayerData[playerid][ply_posZ]);

		Logout(playerid);

		t:bPlayerGameSettings[playerid]<AdminDuty>;

		if(bPlayerGameSettings[playerid] & Gender)
			SetPlayerSkin(playerid, 217);

		else
			SetPlayerSkin(playerid, 211);
	}
	return 1;
}

ACMD:spec[1](playerid, params[])
{
	if(!(bPlayerGameSettings[playerid] & AdminDuty))
		return 6;

	if(isnull(params))
	{
		ExitSpectateMode(playerid);
	}
	else
	{
		new targetid = strval(params);

		if(IsPlayerConnected(targetid) && targetid != playerid)
		{
			if(gPlayerData[playerid][ply_Admin] == 1)
			{
				if(!IsPlayerReported(gPlayerName[targetid]))
				{
					Msg(playerid, YELLOW, " >  You can only spectate reported players.");
					return 1;
				}
			}

			EnterSpectateMode(playerid, targetid);
		}
	}

	return 1;
}
