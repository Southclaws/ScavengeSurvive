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
	aimshout_Tick[MAX_PLAYERS];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if( (newkeys & 128) && (newkeys & 512) )
	{
		if(GetTickCountDifference(aimshout_Tick[playerid], GetTickCount()) > 750)
		{
			new string[128];

			GetPlayerAimShoutText(playerid, string);

			PlayerSendChat(playerid, string, 0.0);

			aimshout_Tick[playerid] = GetTickCount();
		}
	}

	return 1;
}

CMD:aimshout(playerid, params[])
{
	new
		string[128],
		name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[128]", string))
	{
		Msg(playerid, YELLOW, " >  Usage: /aimshout [text] - Sets a custom string you can send by pressing the AIM and LOOK BEHIND keys at the same time.");
		return 1;
	}

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	SetPlayerAimShoutText(playerid, string);
	SetAccountAimshout(name, string);

	MsgF(playerid, YELLOW, " >  AimShout set to '%s'", string);

	return 1;
}
