/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_INFO_MESSAGE			(32)
#define MAX_INFO_MESSAGE_LEN		(256)


static
		ifm_Messages[MAX_INFO_MESSAGE][MAX_INFO_MESSAGE_LEN],
		ifm_Total,
		ifm_Interval,
		ifm_Current;


hook OnScriptInit()
{
	GetSettingStringArray(
		"infomessage/messages",
		"Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.",
		MAX_INFO_MESSAGE,
		ifm_Messages,
		ifm_Total,
		MAX_INFO_MESSAGE_LEN);

	GetSettingInt("infomessage/interval", 5, ifm_Interval);

	defer InfoMessage();
}

timer InfoMessage[ifm_Interval * 60000]()
{
	if(ifm_Current >= ifm_Total)
		ifm_Current = 0;

	ChatMsgAll(YELLOW, " >  "C_BLUE"%s", ifm_Messages[ifm_Current]);

	ifm_Current++;

	defer InfoMessage();
}
