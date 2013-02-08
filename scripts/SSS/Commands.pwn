

CMD:die(playerid, params[])
{
    if(bPlayerGameSettings[playerid] & InDM)dm_SetPlayerHP(playerid, 0.0);
    else
	{
	    GivePlayerWeapon(playerid, 4, 1);
	    ApplyAnimation(playerid, "STRIP", "strip_A", 4.0, 0, 0, 0, 0, 0);
		defer Suicide(playerid);
	}
	return 1;
}
timer Suicide[1000](playerid)
{
	SetPlayerHP(playerid, 0.0);
	MsgAllF(GREEN, " >  %P"#C_GREEN" Comitted Suicide!", playerid);
}
