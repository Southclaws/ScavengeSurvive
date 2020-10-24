/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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
