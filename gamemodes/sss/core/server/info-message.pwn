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


#include <YSI\y_hooks>


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
