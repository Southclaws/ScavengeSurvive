#include <YSI\y_hooks>


new
	Timer:WelcomeMessageTimer[MAX_PLAYERS],
	WelcomeMessageCount[MAX_PLAYERS];


hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_WelcomeMessage)
	{
		if(!(bPlayerGameSettings[playerid] & CanExitWelcome))
		{
			ShowWelcomeMessage(playerid, WelcomeMessageCount[playerid] + 1);
		}
	}

	return 1;
}

timer ShowWelcomeMessage[1000](playerid, count)
{
	new
		str[630],
		button[7];

	format(str, 630,
		""#C_WHITE"%s\n\n\n\
		Welcome to "#C_BLUE"Scavenge and Survive!\n\n\n\
		"#C_WHITE"You have to fight to survive in an apocalyptic wasteland.\n\n\
		You will have a better chance in a group, but be careful who you trust.\n\n\
		Supplies can be found scattered around, weapons are rare though.\n\n\n\
		"#C_RED"\tNEVER ATTACK A PLAYER WITHOUT A REASON!\n\n\n\
		"#C_WHITE"Visit "#C_YELLOW"scavenge-survive.wikia.com "#C_WHITE"for information.\n\n\n\
		%s",
		HORIZONTAL_RULE,
		HORIZONTAL_RULE);

	if(count == 0)
	{
		button = "Accept";

		t:bPlayerGameSettings[playerid]<CanExitWelcome>;
	}
	else
	{
		valstr(button, count);
		count--;

		stop WelcomeMessageTimer[playerid];
		WelcomeMessageTimer[playerid] = defer ShowWelcomeMessage(playerid, count);

		f:bPlayerGameSettings[playerid]<CanExitWelcome>;
	}

	WelcomeMessageCount[playerid] = count;

	ShowPlayerDialog(playerid, d_WelcomeMessage, DIALOG_STYLE_MSGBOX, "Welcome to the Server", str, button, "");
}
