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


#define FILTERSCRIPT

GivePlayerHP(playerid, Float:amount)
	return 0;

KnockOutPlayer(playerid, duration)
	return 0;

#include <a_samp>
#include <YSI\y_hooks>
#include <YSI\y_inline>
#include <YSI\y_timers>
#include <SIF/Core.pwn>
#include <SIF/Button.pwn>
#include "../gamemodes/ss/core/ui/keypad.pwn"


new gButton;


public OnFilterScriptInit()
{
	gButton = CreateButton(0.0, 0.0, 4.0, "Press", .labeltext = "Press", .label = true);

	return 1;
}

public OnButtonPress(playerid, buttonid)
{
	if(buttonid == gButton)
	{
		ShowInputKeypad(playerid);
	}

	return 0;
}

ShowInputKeypad(playerid)
{
	inline Response(pid, keypadid, code, match)
	{
		if(code == match)
		{
			SendClientMessage(playerid, -1, "Success!");
		}
		else
		{
			SendClientMessage(playerid, -1, "Fail!");
		}
	}
	ShowKeypad_Callback(playerid, using inline Response, 9999);
}
