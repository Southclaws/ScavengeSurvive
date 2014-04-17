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
