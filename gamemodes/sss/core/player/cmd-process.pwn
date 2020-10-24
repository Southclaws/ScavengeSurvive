/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


public OnPlayerCommandText(playerid, cmdtext[])
{
	new
		cmd[30],
		params[127],
		cmdfunction[64],
		result = 1;

	sscanf(cmdtext, "s[30]s[127]", cmd, params);

	for (new i, j = strlen(cmd); i < j; i++)
		cmd[i] = tolower(cmd[i]);

	format(cmdfunction, 64, "cmd_%s", cmd[1]); // Format the standard command function name

	if(funcidx(cmdfunction) == -1) // If it doesn't exist, all hope is not lost! It might be defined as an admin command which has the admin level after the command name
	{
		new
			iLvl = GetPlayerAdminLevel(playerid), // The player's admin level
			iLoop = 5; // The highest admin level

		while(iLoop > 0) // Loop backwards through admin levels, from 5 to 1
		{
			format(cmdfunction, 64, "acmd_%s_%d", cmd[1], iLoop); // format the function to include the admin variable

			if(funcidx(cmdfunction) != -1)
				break; // if this function exists, break the loop, at this point iLoop can never be worth 0

			iLoop--; // otherwise just advance to the next iteration, iLoop can become 0 here and thus break the loop at the next iteration
		}

		// If iLoop was 0 after the loop that means it above completed it's last itteration and never found an existing function

		if(iLoop == 0)
			result = 0;

		// If the players level was below where the loop found the existing function,
		// that means the number in the function is higher than the player id
		// Give a 'not high enough admin level' error

		if(iLvl < iLoop)
			result = 5;
	}
	if(result == 1)
	{
		if(isnull(params))result = CallLocalFunction(cmdfunction, "is", playerid, "\1");
		else result = CallLocalFunction(cmdfunction, "is", playerid, params);
	}

/*
	Return values for commands.

	Instead of writing these messages on the commands themselves, I can just
	write them here and return different values on the commands.
*/

	// Only log successful commands
	// If a command returns 7, don't log it.

	if(0 < result < 7)
		log("[COMMAND] [%p]: %s", playerid, cmdtext);

	if		(result == 0) ChatMsgLang(playerid, ORANGE, "CMDERROR0");
	else if	(result == 1) return 1; // valid command, do nothing.
	else if	(result == 2) ChatMsgLang(playerid, ORANGE, "CMDERROR1");
	else if	(result == 3) ChatMsgLang(playerid, RED, "CMDERROR2");
	else if	(result == 4) ChatMsgLang(playerid, RED, "CMDERROR3");
	else if	(result == 5) ChatMsgLang(playerid, RED, "CMDERROR4");
	else if	(result == 6) ChatMsgLang(playerid, RED, "CMDERROR5");

	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	if(!success)
	{
		new ipstring[16];

		log("[RCON] Failed login by %s password: %s", ip, password);

		foreach(new i : Player)
		{
			GetPlayerIp(i, ipstring, sizeof(ipstring));

			if(!strcmp(ip, ipstring, true))
				ChatMsgAdmins(1, YELLOW, " >  Failed login by %p password: %s", i, password);
		}
	}
	return 1;
}
