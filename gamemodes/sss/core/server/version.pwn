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
	Text:VersionInfo = Text:INVALID_TEXT_DRAW;


hook OnGameModeInit()
{
	new
		string[128];

	/*
		Note:
		DO NOT REMOVE SOUTHCLAW'S WEBSITE LINK.
		Write your own website into the settings.ini file.
	*/
	format(string, sizeof(string), "Build %d - Southclaw.net - %s", gBuildNumber, gWebsiteURL);

	VersionInfo					=TextDrawCreate(638.000000, 2.000000, string);
	TextDrawAlignment			(VersionInfo, 3);
	TextDrawBackgroundColor		(VersionInfo, 255);
	TextDrawFont				(VersionInfo, 1);
	TextDrawLetterSize			(VersionInfo, 0.240000, 1.000000);
	TextDrawColor				(VersionInfo, -1);
	TextDrawSetOutline			(VersionInfo, 1);
	TextDrawSetProportional		(VersionInfo, 1);
}

hook OnPlayerConnect(playerid)
{
	TextDrawShowForPlayer(playerid, VersionInfo);

	return 1;
}

stock ToggleVersionInfo(playerid, bool:toggle)
{
	if(toggle)
		TextDrawShowForPlayer(playerid, VersionInfo);

	else
		TextDrawHideForPlayer(playerid, VersionInfo);
}
