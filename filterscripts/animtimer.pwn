/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaws" Keene

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


#define FILTERSCRIPT
#include <a_samp>
#include <SIF\Core.pwn>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

new
	curAnim,
	animTick;

public OnPlayerUpdate(playerid)
{
	new
		idx = GetPlayerAnimationIndex(playerid),
		animlib[32],
		animname[32],
		str[78];

	GetAnimationName(idx, animlib, 32, animname, 32);
	format(str, 78, "AnimIDX:%d~n~AnimName:%s~n~AnimLib:%s", idx, animname, animlib);
	ShowActionText(playerid, str, 0);

	if(idx != curAnim)
	{
		format(str, 128, "AnimTime: %d", GetTickCount() - animTick);
		SendClientMessage(playerid, -1, str);

		animTick = GetTickCount();

		curAnim = idx;
	}

	return 1;
}
