#include <YSI\y_hooks>


new
	Timer:WelcomeMessageTimer[MAX_PLAYERS],
	WelcomeMessageCount[MAX_PLAYERS];


hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_WelcomeMessage)
	{
		if(!(gPlayerBitData[playerid] & CanExitWelcome))
		{
			ShowWelcomeMessage(playerid, WelcomeMessageCount[playerid] + 1);
		}
	}

	return 1;
}

timer ShowWelcomeMessage[1000](playerid, count)
{
	new
		str[509],
		button[7];

	strcat(str,
		"\n\n\n"#C_WHITE"You have to fight to survive in an apocalyptic wasteland.\n\n\
		You will have a better chance in a group, but be careful who you trust.\n\n\
		Supplies can be found scattered around, weapons are rare though.\n\n");

	strcat(str,
		"Avoid attacking unarmed players, they frighten easily but will return, and in greater numbers...\n\n\n\n\n\
		"#C_TEAL"Please take some time to look at the "#C_BLUE"/rules "#C_TEAL"and "#C_BLUE"/help "#C_TEAL"before diving into the game.\n\n\n\
		Visit "#C_YELLOW"scavenge-survive.wikia.com "#C_TEAL"for more information.\n\n\n");

	if(count == 0)
	{
		button = "Accept";

		t:gPlayerBitData[playerid]<CanExitWelcome>;
	}
	else
	{
		valstr(button, count);
		count--;

		stop WelcomeMessageTimer[playerid];
		WelcomeMessageTimer[playerid] = defer ShowWelcomeMessage(playerid, count);

		f:gPlayerBitData[playerid]<CanExitWelcome>;
	}

	WelcomeMessageCount[playerid] = count;

	ShowPlayerDialog(playerid, d_WelcomeMessage, DIALOG_STYLE_MSGBOX, "Welcome to the Server", str, button, "");
}
