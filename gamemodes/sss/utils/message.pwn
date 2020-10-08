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


#include <YSI_Coding\y_va>

static stock gs_Buffer[256];


/*==============================================================================

	Main Chat Functions

==============================================================================*/


stock ChatMsg(playerid, colour, const fmat[], va_args<>)
{
	formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<3>);
	ChatMsgFlat(playerid, colour, gs_Buffer);

	return 1;
}

stock ChatMsgAll(colour, const fmat[], va_args<>)
{
	formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<2>);
	ChatMsgAllFlat(colour, gs_Buffer);

	return 1;
}

stock ChatMsgLang(playerid, colour, const key[], va_args<>)
{
	formatex(gs_Buffer, sizeof(gs_Buffer), GetLanguageString(GetPlayerLanguage(playerid), key), va_start<3>);
	ChatMsgFlat(playerid, colour, gs_Buffer);

	return 1;
}

stock ChatMsgAdmins(level, colour, const fmat[], va_args<>)
{
	formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<3>);
	ChatMsgAdminsFlat(level, colour, gs_Buffer);

	return 1;
}


/*==============================================================================

	"Flat" Message with no formatting, never actually needs to be used in-code.

==============================================================================*/


stock ChatMsgFlat(playerid, colour, const message[])
{
	if(strlen(message) > 127)
	{
		new
			string1[128],
			string2[128],
			splitpos;

		for(new c = 128; c > 0; c--)
		{
			if(message[c] == ' ' || message[c] ==  ',' || message[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string1, message, splitpos);
		strcat(string2, message[splitpos]);

		SendClientMessage(playerid, colour, string1);
		SendClientMessage(playerid, colour, string2);
	}
	else
	{
		SendClientMessage(playerid, colour, message);
	}
	
	return 1;
}

stock ChatMsgAllFlat(colour, const message[])
{
	if(strlen(message) > 127)
	{
		new
			string1[128],
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--)
		{
			if(message[c] == ' ' || message[c] ==  ',' || message[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string1, message, splitpos);
		strcat(string2, message[splitpos]);

		SendClientMessageToAll(colour, string1);
		SendClientMessageToAll(colour, string2);
	}
	else
	{
		SendClientMessageToAll(colour, message);
	}

	return 1;
}

stock ChatMsgLangFlat(playerid, colour, const key[])
{
	ChatMsgFlat(playerid, colour, GetLanguageString(GetPlayerLanguage(playerid), key));

	return 1;
}
