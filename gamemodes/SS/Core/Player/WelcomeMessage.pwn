#include <YSI\y_hooks>


static
Timer:	WelcomeMessageTimer[MAX_PLAYERS],
		WelcomeMessageCount[MAX_PLAYERS],
		CanLeaveWelcomeMessage[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	CanLeaveWelcomeMessage[playerid] = true;

	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_WelcomeMessage)
	{
		if(!CanLeaveWelcomeMessage[playerid])
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
		"\n\n\n"C_WHITE"You have to fight to survive in an apocalyptic wasteland.\n\n\
		You will have a better chance in a group, but be careful who you trust.\n\n\
		Supplies can be found scattered around, weapons are rare though.\n\n");

	strcat(str,
		"Avoid attacking unarmed players, they frighten easily but will return, and in greater numbers...\n\n\n\n\n\
		"C_TEAL"Please take some time to look at the "C_BLUE"/rules "C_TEAL"and "C_BLUE"/help "C_TEAL"before diving into the game.\n\n\n\
		Visit "C_YELLOW"scavenge-survive.wikia.com "C_TEAL"for more information.\n\n\n");

	if(count == 0)
	{
		button = "Accept";

		CanLeaveWelcomeMessage[playerid] = true;
	}
	else
	{
		valstr(button, count);
		count--;

		stop WelcomeMessageTimer[playerid];
		WelcomeMessageTimer[playerid] = defer ShowWelcomeMessage(playerid, count);

		CanLeaveWelcomeMessage[playerid] = false;
	}

	WelcomeMessageCount[playerid] = count;

	ShowPlayerDialog(playerid, d_WelcomeMessage, DIALOG_STYLE_MSGBOX, "Welcome to the Server", str, button, "");
}

stock CanPlayerLeaveWelcomeMessage(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return CanLeaveWelcomeMessage[playerid];
}
