new
	gToolTipText[MAX_PLAYERS][512];


// Help Tips (bottom of screen)


ShowHelpTip(playerid, text[], time = 0)
{
	PlayerTextDrawSetString(playerid, HelpTipText[playerid], text);
	PlayerTextDrawShow(playerid, HelpTipText[playerid]);

	if(time > 0)
		defer HideHelpTip_Delay(playerid, time);
}

timer HideHelpTip_Delay[time](playerid, time)
{
	HideHelpTip(playerid);
	#pragma unused time
}

HideHelpTip(playerid)
{
	PlayerTextDrawHide(playerid, HelpTipText[playerid]);
}


// Tool Tips (top right)


ClearToolTipText(playerid)
{
	gToolTipText[playerid][0] = EOS;
}

AddToolTipText(playerid, key[], use[])
{
	new tmp[128];
	format(tmp, sizeof(tmp), "~y~%s ~w~%s~n~", key, use);
	strcat(gToolTipText[playerid], tmp);
}

ShowPlayerToolTip(playerid)
{
	PlayerTextDrawSetString(playerid, ToolTip[playerid], gToolTipText[playerid]);
	PlayerTextDrawShow(playerid, ToolTip[playerid]);
}

HidePlayerToolTip(playerid)
{
	PlayerTextDrawHide(playerid, ToolTip[playerid]);
}
