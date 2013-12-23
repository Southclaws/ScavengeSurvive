public OnPlayerCommandText(playerid, cmdtext[])
{
	new
		cmd[30],
		params[127],
		cmdfunction[64],
		result = 1;

	printf("[comm] [%p]: %s", playerid, cmdtext);

	sscanf(cmdtext, "s[30]s[127]", cmd, params);

	for (new i, j = strlen(cmd); i < j; i++)
		cmd[i] = tolower(cmd[i]);

	format(cmdfunction, 64, "cmd_%s", cmd[1]); // Format the standard command function name

	if(funcidx(cmdfunction) == -1) // If it doesn't exist, all hope is not lost! It might be defined as an admin command which has the admin level after the command name
	{
		new
			iLvl = gPlayerData[playerid][ply_Admin], // The player's admin level
			iLoop = 4; // The highest admin level

		while(iLoop > 0) // Loop backwards through admin levels, from 4 to 1
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
		logf("[COMMAND] [%p]: %s", playerid, cmdtext);

	if		(result == 0) Msg(playerid, ORANGE, " >  That is not a recognized command. Check the "C_BLUE"/help "C_ORANGE"dialog.");
	else if	(result == 1) return 1; // valid command, do nothing.
	else if	(result == 2) Msg(playerid, ORANGE, " >  You cannot use that command right now.");
	else if	(result == 3) Msg(playerid, RED, " >  You cannot use that command on that player right now.");
	else if	(result == 4) Msg(playerid, RED, " >  Invalid ID");
	else if	(result == 5) Msg(playerid, RED, " >  You have insufficient authority to use that command.");
	else if	(result == 6) Msg(playerid, RED, " >  You can only use that command while on "C_BLUE"administrator duty"C_RED".");

	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	if(!success)
	{
		new ipstring[16];

		printf("[RCON] Failed login by %s password: %s", ip, password);

		foreach(new i : Player)
		{
			GetPlayerIp(i, ipstring, sizeof(ipstring));

			if(!strcmp(ip, ipstring, true))
				MsgAdminsF(1, YELLOW, " >  Failed login by %p password: %s", i, password);
		}
	}
	return 1;
}
