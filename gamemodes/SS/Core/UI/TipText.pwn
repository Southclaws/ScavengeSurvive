#include <YSI\y_hooks>


static
PlayerText:	HelpTipText[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

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

hook OnPlayerConnect(playerid)
{
	HelpTipText[playerid]			=CreatePlayerTextDraw(playerid, 150.000000, 350.000000, "Tip: You can access the trunks of cars by pressing F at the back");
	PlayerTextDrawBackgroundColor	(playerid, HelpTipText[playerid], 255);
	PlayerTextDrawFont				(playerid, HelpTipText[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, HelpTipText[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, HelpTipText[playerid], 16711935);
	PlayerTextDrawSetOutline		(playerid, HelpTipText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, HelpTipText[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, HelpTipText[playerid], 0);
	PlayerTextDrawUseBox			(playerid, HelpTipText[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, HelpTipText[playerid], 0);
	PlayerTextDrawTextSize			(playerid, HelpTipText[playerid], 520.000000, 0.000000);
}
