/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 "Southclaws" Keene

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
	aimshout_Text[MAX_PLAYERS][128],
	aimshout_Tick[MAX_PLAYERS];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		if( (newkeys & 320) && (newkeys & 1) )
		{
			if(GetTickCountDifference(GetTickCount(), aimshout_Tick[playerid]) > 750)
			{
				new string[128];

				strcat(string, aimshout_Text[playerid], 128);
				PlayerSendChat(playerid, string, 0.0);

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
				new string[128];

				strcat(string, aimshout_Text[playerid], 128);
				PlayerSendChat(playerid, string, 0.0);

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

stock SetPlayerAimShoutText(playerid, const string[])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	aimshout_Text[playerid][0] = EOS;
	strcat(aimshout_Text[playerid], string, 128);

	return 1;
}

hook OnPlayerSave(playerid, filename[])
{
	modio_push(filename, _T<S,H,O,U>, strlen(aimshout_Text[playerid]), aimshout_Text[playerid]);
}

hook OnPlayerLoad(playerid, filename[])
{
	modio_read(filename, _T<S,H,O,U>, 128, aimshout_Text[playerid]);
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
