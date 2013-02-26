CMD:die(playerid, params[])
{
	GivePlayerWeapon(playerid, 4, 1);
	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0);
	defer Suicide(playerid);

	return 1;
}
timer Suicide[1000](playerid)
{
	SetPlayerHP(playerid, 0.0);
}

CMD:idea(playerid, params[])
{
	new idea[128];
	if(sscanf(params, "s[128]", idea))
	{
		Msg(playerid, YELLOW, "Usage: /idea [idea]");
		return 1;
	}

	new
		File:tmpfile,
		str[128+MAX_PLAYER_NAME+5];

	format(str, sizeof(str), "%p : %s\r\n", playerid, idea);

	if(!fexist("ideas.txt"))
		tmpfile = fopen("ideas.txt", io_write);

	else
		tmpfile = fopen("ideas.txt", io_append);

	fwrite(tmpfile, str);
	fclose(tmpfile);

	Msg(playerid, YELLOW, " >  Your idea has been submitted, thank you!");

	return 1;
}

CMD:bug(playerid, params[])
{
	new bug[128];
	if(sscanf(params, "s[128]", bug))
	{
		Msg(playerid, YELLOW, "Usage: /bug [bug]");
		return 1;
	}

	new
		File:tmpfile,
		str[128+MAX_PLAYER_NAME+5];
	
	format(str, sizeof(str), "%p : %s\r\n", playerid, bug);

	if(!fexist("bugs.txt"))
		tmpfile = fopen("bugs.txt", io_write);

	else
		tmpfile = fopen("bugs.txt", io_append);

	fwrite(tmpfile, str);
	fclose(tmpfile);
	
	Msg(playerid, YELLOW, " >  Your bug report has been submitted! "#C_BLUE"Southclaw "#C_YELLOW"will fix this when he can.");

	return 1;
}

ACMD:hud[3](playerid, params[])
{
	if(bPlayerGameSettings[playerid] & ShowHUD)
	{
		PlayerTextDrawHide(playerid, HungerBarBackground);
		PlayerTextDrawHide(playerid, HungerBarForeground);
		TextDrawHideForPlayer(playerid, ClockText);
		TextDrawHideForPlayer(playerid, MapCover1);
		TextDrawHideForPlayer(playerid, MapCover2);
		f:bPlayerGameSettings[playerid]<ShowHUD>;
	}
	else
	{
		PlayerTextDrawShow(playerid, HungerBarBackground);
		PlayerTextDrawShow(playerid, HungerBarForeground);
		TextDrawShowForPlayer(playerid, ClockText);
		TextDrawShowForPlayer(playerid, MapCover1);
		TextDrawShowForPlayer(playerid, MapCover2);
		t:bPlayerGameSettings[playerid]<ShowHUD>;
	}
}
