/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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
	PlayerText:VersionInfo[MAX_PLAYERS] = PlayerText:INVALID_TEXT_DRAW,
	bool:ShowVersionInfo[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	ShowVersionInfo[playerid] = true;

	VersionInfo[playerid]			=CreatePlayerTextDraw(playerid, 638.000000, 2.000000, "southcla.ws");
	PlayerTextDrawAlignment			(playerid, VersionInfo[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, VersionInfo[playerid], 255);
	PlayerTextDrawFont				(playerid, VersionInfo[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, VersionInfo[playerid], 0.240000, 1.000000);
	PlayerTextDrawColor				(playerid, VersionInfo[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, VersionInfo[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, VersionInfo[playerid], 1);
}

hook OnPlayerScriptUpdate(playerid)
{
	if(!ShowVersionInfo[playerid])
		return;

	new
		tickrate = GetServerTickRate(),
		colour[4],
		string[128];

	if(tickrate < 150)
		colour = "~r~";

	/*
		Note:
		DO NOT REMOVE Southclaws' WEBSITE LINK.
		Write your own website into the settings.ini file.
	*/
	format(string, sizeof(string), "%sBuild %d - southcla.ws - %s ~n~ Tick: %d Ping: %d Pkt Loss: %.2f", colour, gBuildNumber, gWebsiteURL, tickrate, GetPlayerPing(playerid), NetStats_PacketLossPercent(playerid));

	PlayerTextDrawSetString(playerid, VersionInfo[playerid], string);
	PlayerTextDrawShow(playerid, VersionInfo[playerid]);

	return;
}

stock ToggleVersionInfo(playerid, bool:toggle)
{
	ShowVersionInfo[playerid] = toggle;

	if(toggle)
		PlayerTextDrawShow(playerid, VersionInfo[playerid]);

	else
		PlayerTextDrawHide(playerid, VersionInfo[playerid]);
}
