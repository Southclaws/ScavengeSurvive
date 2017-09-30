/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


#include <YSI\y_va>


static formatBuffer[244];


/*==============================================================================

	Main Chat Functions

==============================================================================*/


stock ChatMsg(playerid, colour, fmat[], {Float,_}:...)
{
	format(formatBuffer, sizeof(formatBuffer), fmat, ___(3));
	ChatMsgFlat(playerid, colour, formatBuffer);

	return 1;
}

stock ChatMsgAll(colour, fmat[], {Float,_}:...)
{
	format(formatBuffer, sizeof(formatBuffer), fmat, ___(2));
	ChatMsgAllFlat(colour, formatBuffer);

	return 1;
}

stock ChatMsgLang(playerid, colour, key[], {Float,_}:...)
{
	format(formatBuffer, sizeof(formatBuffer), GetLanguageString(GetPlayerLanguage(playerid), key), ___(3));
	ChatMsgFlat(playerid, colour, formatBuffer);

	return 1;
}

stock ChatMsgAdmins(level, colour, fmat[], {Float,_}:...)
{
	format(formatBuffer, sizeof(formatBuffer), fmat, ___(3));
	ChatMsgAdminsFlat(level, colour, formatBuffer);

	return 1;
}


/*==============================================================================

	"Flat" Message with no formatting, never actually needs to be used in-code.

==============================================================================*/


stock ChatMsgFlat(playerid, colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c > 0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;
		
		SendClientMessage(playerid, colour, string);
		SendClientMessage(playerid, colour, string2);
	}
	else
	{
		SendClientMessage(playerid, colour, string);
	}
	
	return 1;
}

stock ChatMsgAllFlat(colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;

		SendClientMessageToAll(colour, string);
		SendClientMessageToAll(colour, string2);
	}
	else
	{
		SendClientMessageToAll(colour, string);
	}

	return 1;
}

stock ChatMsgLangFlat(playerid, colour, key[])
{
	ChatMsgFlat(playerid, colour, GetLanguageString(GetPlayerLanguage(playerid), key));

	return 1;
}
