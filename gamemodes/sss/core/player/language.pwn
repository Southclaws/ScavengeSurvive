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


static
	lang_PlayerLanguage[MAX_PLAYERS];


#define ls(%0,%1) GetLanguageString(GetPlayerLanguage(%0), %1)

stock GetPlayerLanguage(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return lang_PlayerLanguage[playerid];
}

ShowLanguageMenu(playerid)
{
	new
		languages[MAX_LANGUAGE][MAX_LANGUAGE_NAME],
		langlist[MAX_LANGUAGE * (MAX_LANGUAGE_NAME + 1)],
		langcount;

	langcount = GetLanguageList(languages);

	for(new i; i < langcount; i++)
	{
		format(langlist, sizeof(langlist), "%s%s\n", langlist, languages[i]);
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			lang_PlayerLanguage[playerid] = listitem;
			ChatMsgLang(playerid, YELLOW, "LANGCHANGE");
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Choose language:", langlist, "Select", "Cancel");
}

hook OnPlayerSave(playerid, filename[])
{
	dbg("global", CORE, "[OnPlayerSave] in /gamemodes/sss/core/player/language.pwn");

	new data[1];
	data[0] = lang_PlayerLanguage[playerid];

	modio_push(filename, _T<L,A,N,G>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	dbg("global", CORE, "[OnPlayerLoad] in /gamemodes/sss/core/player/language.pwn");

	new data[1];

	modio_read(filename, _T<L,A,N,G>, 1, data);

	lang_PlayerLanguage[playerid] = data[0];
}

CMD:language(playerid, params[])
{
	ShowLanguageMenu(playerid);
	return 1;
}
