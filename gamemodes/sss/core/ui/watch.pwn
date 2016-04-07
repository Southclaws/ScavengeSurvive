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


#include <YSI_4\y_hooks>


static
PlayerText:	WatchBackground[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	WatchTime[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	WatchBear[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	WatchFreq[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
bool:		watch_Show[MAX_PLAYERS];


ShowWatch(playerid)
{
	PlayerTextDrawShow(playerid, WatchBackground[playerid]);
	PlayerTextDrawShow(playerid, WatchTime[playerid]);
	PlayerTextDrawShow(playerid, WatchBear[playerid]);
	PlayerTextDrawShow(playerid, WatchFreq[playerid]);

	watch_Show[playerid] = true;
}

HideWatch(playerid)
{
	PlayerTextDrawHide(playerid, WatchBackground[playerid]);
	PlayerTextDrawHide(playerid, WatchTime[playerid]);
	PlayerTextDrawHide(playerid, WatchBear[playerid]);
	PlayerTextDrawHide(playerid, WatchFreq[playerid]);

	watch_Show[playerid] = false;
}

ptask UpdateWatch[1000](playerid)
{
	if(!watch_Show[playerid])
		return;

	new
		str[12],
		hour,
		minute,
		Float:angle,
		lastattacker,
		lastweapon;

	gettime(hour, minute);

	if(IsPlayerInAnyVehicle(playerid))
		GetVehicleZAngle(GetPlayerLastVehicle(playerid), angle);

	else
		GetPlayerFacingAngle(playerid, angle);

	format(str, 6, "%02d:%02d", hour, minute);
	PlayerTextDrawSetString(playerid, WatchTime[playerid], str);

	format(str, 12, "%.0f DEG", 360 - angle);
	PlayerTextDrawSetString(playerid, WatchBear[playerid], str);

	format(str, 7, "%.2f", GetPlayerRadioFrequency(playerid));
	PlayerTextDrawSetString(playerid, WatchFreq[playerid], str);

	if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon))
	{
		if(IsPlayerConnected(lastattacker))
		{
			PlayerTextDrawColor(playerid, WatchTime[playerid], RED);
			PlayerTextDrawColor(playerid, WatchBear[playerid], RED);
			PlayerTextDrawColor(playerid, WatchFreq[playerid], RED);
		}
	}
	else
	{
		PlayerTextDrawColor(playerid, WatchTime[playerid], WHITE);
		PlayerTextDrawColor(playerid, WatchBear[playerid], WHITE);
		PlayerTextDrawColor(playerid, WatchFreq[playerid], WHITE);
	}

	PlayerTextDrawShow(playerid, WatchTime[playerid]);
	PlayerTextDrawShow(playerid, WatchBear[playerid]);
	PlayerTextDrawShow(playerid, WatchFreq[playerid]);

	return;
}

hook OnPlayerConnect(playerid)
{
	WatchBackground[playerid]		=CreatePlayerTextDraw(playerid, 33.000000, 338.000000, "LD_POOL:ball");
	PlayerTextDrawBackgroundColor	(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchBackground[playerid], 4);
	PlayerTextDrawLetterSize		(playerid, WatchBackground[playerid], 0.500000, 0.000000);
	PlayerTextDrawColor				(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, WatchBackground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawUseBox			(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawTextSize			(playerid, WatchBackground[playerid], 108.000000, 89.000000);

	WatchTime[playerid]				=CreatePlayerTextDraw(playerid, 87.000000, 372.000000, "69:69");
	PlayerTextDrawAlignment			(playerid, WatchTime[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchTime[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchTime[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, WatchTime[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, WatchTime[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, WatchTime[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WatchTime[playerid], 1);

	WatchBear[playerid]				=CreatePlayerTextDraw(playerid, 87.000000, 358.000000, "45 Deg");
	PlayerTextDrawAlignment			(playerid, WatchBear[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchBear[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchBear[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, WatchBear[playerid], 0.300000, 1.500000);
	PlayerTextDrawColor				(playerid, WatchBear[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, WatchBear[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WatchBear[playerid], 1);

	WatchFreq[playerid]				=CreatePlayerTextDraw(playerid, 87.000000, 391.000000, "88.8");
	PlayerTextDrawAlignment			(playerid, WatchFreq[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchFreq[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchFreq[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, WatchFreq[playerid], 0.300000, 1.500000);
	PlayerTextDrawColor				(playerid, WatchFreq[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, WatchFreq[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WatchFreq[playerid], 1);
}
