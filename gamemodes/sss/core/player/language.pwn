/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


static
	lang_PlayerLanguage[MAX_PLAYERS];


#define ls(%0,%1,%2) GetLanguageString(GetPlayerLanguage(%0), %1, %2)

hook OnPlayerConnect(playerid)
{
	lang_PlayerLanguage[playerid] = 0;
	return Y_HOOKS_CONTINUE_RETURN_1;
}

stock GetPlayerLanguage(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return lang_PlayerLanguage[playerid];
}

stock SetPlayerLanguage(playerid, languageid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	lang_PlayerLanguage[playerid] = languageid;
	return 1;
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

			new lang_name[MAX_LANGUAGE_NAME];
			
			GetLanguageName(listitem, lang_name);

			ChatMsgLang(playerid, BLUE, "LANGCHANGE", lang_name);

			if(!IsPlayerRegistered(playerid)) {
				DisplayRegisterPrompt(playerid);
			} else {
				new name[MAX_PLAYER_NAME];
				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				SetAccountLanguage(name, listitem);
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Choose language:", langlist, "Select", "Cancel");
}

hook OnPlayerRegister(playerid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	SetAccountLanguage(name, lang_PlayerLanguage[playerid]);
}

hook OnPlayerSave(playerid, filename[])
{
	new data[1];
	data[0] = lang_PlayerLanguage[playerid];

	modio_push(filename, _T<L,A,N,G>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[1];

	modio_read(filename, _T<L,A,N,G>, 1, data);

	lang_PlayerLanguage[playerid] = data[0];
}

CMD:language(playerid, params[])
{
	ShowLanguageMenu(playerid);
	return 1;
}
