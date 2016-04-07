/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


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
