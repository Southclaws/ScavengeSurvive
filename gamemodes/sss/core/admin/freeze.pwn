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


#include <YSI_Coding\y_hooks>


static
bool:	frz_Frozen[MAX_PLAYERS],
Timer:	frz_DelayTimer[MAX_PLAYERS],
Timer:	frz_CheckTimer[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	frz_Frozen[playerid] = false;

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	stop frz_DelayTimer[playerid];

	return 1;
}

FreezePlayer(playerid, duration = 0, msg = 0)
{
	TogglePlayerControllable(playerid, false);
	frz_Frozen[playerid] = true;

	if(duration > 0)
	{
		stop frz_DelayTimer[playerid];
		frz_DelayTimer[playerid] = defer UnfreezePlayer_delay(playerid, duration, msg);
	}

	if(duration > 4000 || duration == 0)
	{
		stop frz_CheckTimer[playerid];

		if(GetPlayerAnimationIndex(playerid) != 1130) // if not falling
			frz_CheckTimer[playerid] = defer UnfreezePlayer_check(playerid);
	}
}

UnfreezePlayer(playerid, msg = 0)
{
	TogglePlayerControllable(playerid, true);
	frz_Frozen[playerid] = false;
	stop frz_DelayTimer[playerid];
	stop frz_CheckTimer[playerid];

	if(msg)
		ChatMsgLang(playerid, YELLOW, "FREEZEFROZE");
}

timer UnfreezePlayer_delay[time](playerid, time, msg)
{
	#pragma unused time

	UnfreezePlayer(playerid, msg);
}

timer UnfreezePlayer_check[4000](playerid)
{
	if(GetPlayerAnimationIndex(playerid) == 1130) // Player is falling
		return;

	new Float:z;

	GetPlayerCameraFrontVector(playerid, z, z, z);

	if(-0.994 >= z >= -0.997 || 0.9958 >= z >= 0.9946)
	{
		ChatMsgAdmins(2, YELLOW, " >  Possible mod user: "C_ORANGE"%p (%d)", playerid, playerid);
	}

	return;
}


stock IsPlayerFrozen(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return frz_Frozen[playerid];
}
