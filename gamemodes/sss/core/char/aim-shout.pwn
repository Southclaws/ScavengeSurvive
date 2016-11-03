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
	aimshout_Text[MAX_PLAYERS][128],
	aimshout_Tick[MAX_PLAYERS];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/char/aim-shout.pwn");

	if(IsPlayerInAnyVehicle(playerid))
	{
		if( (newkeys & 320) && (newkeys & 1) )
		{
			if(GetTickCountDifference(GetTickCount(), aimshout_Tick[playerid]) > 750)
			{
				PlayerSendChat(playerid, aimshout_Text[playerid], 0.0);

				aimshout_Tick[playerid] = GetTickCount();
			}
		}
	}
	else
	{
		if( (newkeys & 128) && (newkeys & 512) )
		{
			if(GetTickCountDifference(GetTickCount(), aimshout_Tick[playerid]) > 750)
			{
				PlayerSendChat(playerid, aimshout_Text[playerid], 0.0);

				aimshout_Tick[playerid] = GetTickCount();
			}
		}
	}

	return 1;
}

stock GetPlayerAimShoutText(playerid, string[])
{
	if(!IsValidPlayerID(playerid))
		return 0;

	string[0] = EOS;
	strcat(string, aimshout_Text[playerid], 128);

	return 1;
}

stock SetPlayerAimShoutText(playerid, string[])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	strcat(aimshout_Text[playerid], string, 128);
	SetAccountAimshout(name, string);

	return 1;
}

CMD:aimshout(playerid, params[])
{
	new string[128];

	if(sscanf(params, "s[128]", string))
	{
		ChatMsgLang(playerid, YELLOW, "AIMSHOUTHLP");
		return 1;
	}

	SetPlayerAimShoutText(playerid, string);
	ChatMsgLang(playerid, YELLOW, "AIMSHOUTSET", string);

	return 1;
}
