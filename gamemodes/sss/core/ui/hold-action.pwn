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


new
PlayerBar:	ActionBar = INVALID_PLAYER_BAR_ID,
			HoldActionLimit[MAX_PLAYERS],
			HoldActionProgress[MAX_PLAYERS],
Timer:		HoldActionTimer[MAX_PLAYERS],
			HoldActionState[MAX_PLAYERS];


forward OnHoldActionUpdate(playerid, progress);
forward OnHoldActionFinish(playerid);


hook OnPlayerConnect(playerid)
{
	ActionBar = CreatePlayerProgressBar(playerid, 291.0, 345.0, 57.50, 5.19, GREY, 100.0);
}

hook OnPlayerDisconnect(playerid, reason)
{
	DestroyPlayerProgressBar(playerid, ActionBar);
}


StartHoldAction(playerid, duration, startvalue = 0)
{
	if(HoldActionState[playerid] == 1)
		return 0;

	stop HoldActionTimer[playerid];
	HoldActionTimer[playerid] = repeat HoldActionUpdate(playerid);

	HoldActionLimit[playerid] = duration;
	HoldActionProgress[playerid] = startvalue;
	HoldActionState[playerid] = 1;

	SetPlayerProgressBarMaxValue(playerid, ActionBar, HoldActionLimit[playerid]);
	SetPlayerProgressBarValue(playerid, ActionBar, HoldActionProgress[playerid]);
	ShowPlayerProgressBar(playerid, ActionBar);

	return 1;
}

StopHoldAction(playerid)
{
	if(HoldActionState[playerid] == 0)
		return 0;

	stop HoldActionTimer[playerid];
	HoldActionLimit[playerid] = 0;
	HoldActionProgress[playerid] = 0;
	HoldActionState[playerid] = 0;

	HidePlayerProgressBar(playerid, ActionBar);

	return 1;
}

timer HoldActionUpdate[100](playerid)
{
	if(HoldActionProgress[playerid] >= HoldActionLimit[playerid])
	{
		StopHoldAction(playerid);
		CallLocalFunction("OnHoldActionFinish", "d", playerid);
		return;
	}

	SetPlayerProgressBarMaxValue(playerid, ActionBar, HoldActionLimit[playerid]);
	SetPlayerProgressBarValue(playerid, ActionBar, HoldActionProgress[playerid]);
	ShowPlayerProgressBar(playerid, ActionBar);

	CallLocalFunction("OnHoldActionUpdate", "dd", playerid, HoldActionProgress[playerid]);

	HoldActionProgress[playerid] += 100;

	return;
}
