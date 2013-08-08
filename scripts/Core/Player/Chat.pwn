#include <YSI\y_hooks>


new
	chat_MessageStreak	[MAX_PLAYERS],
	chat_MuteTick		[MAX_PLAYERS];


hook OnPlayerText(playerid, text[])
{
	new tmpMuteTime = tickcount() - chat_MuteTick[playerid];

	if(gPlayerBitData[playerid] & Muted)
	{
		Msg(playerid, RED, " >  You are muted");
		return 0;
	}

	if(tmpMuteTime < 30000)
	{
		Msg(playerid, RED, " >  Muted from global chat for "#C_ORANGE"30 "#C_YELLOW"seconds, Reason: "#C_BLUE"chat flooding");
		return 0;
	}

	if(tickcount() - gPlayerData[playerid][ply_LastChatMessageTick] < 1000)
	{
		chat_MessageStreak[playerid]++;
		if(chat_MessageStreak[playerid] == 3)
		{
			Msg(playerid, RED, " >  Muted from global chat for "#C_ORANGE"30 "#C_YELLOW"seconds, Reason: "#C_BLUE"chat flooding");
			chat_MuteTick[playerid] = tickcount();
			return 0;
		}
	}
	else
	{
		if(chat_MessageStreak[playerid] > 0)
			chat_MessageStreak[playerid]--;
	}

	gPlayerData[playerid][ply_LastChatMessageTick] = tickcount();

	if(gPlayerData[playerid][ply_ChatMode] == CHAT_MODE_LOCAL)
		PlayerSendChat(playerid, text, 0.0);

	if(gPlayerData[playerid][ply_ChatMode] == CHAT_MODE_GLOBAL)
		PlayerSendChat(playerid, text, 1.0);

	if(gPlayerData[playerid][ply_ChatMode] == CHAT_MODE_RADIO)
		PlayerSendChat(playerid, text, gPlayerData[playerid][ply_RadioFrequency]);

	if(gPlayerData[playerid][ply_ChatMode] == CHAT_MODE_ADMIN)
	{
		foreach(new i : Player)
		{
			if(gPlayerData[i][ply_Admin] > 0)
				MsgF(i, WHITE, "%C(A) %P"#C_WHITE": %s", AdminColours[gPlayerData[playerid][ply_Admin]], playerid, TagScan(text));
		}
	}

	return 0;
}
PlayerSendChat(playerid, textInput[], Float:frequency)
{
	new
		text[256],
		text2[128],
		sendsecondline;

	if(frequency == 0.0)
	{
		format(text, 256, "[Local] (%d) %P"#C_WHITE": %s",
			playerid,
			playerid,
			TagScan(textInput));
	}
	else if(frequency == 1.0)
	{
		format(text, 256, "[Global] (%d) %P"#C_WHITE": %s",
			playerid,
			playerid,
			TagScan(textInput));
	}
	else
	{
		format(text, 256, "[%.2f] (%d) %P"#C_WHITE": %s",
			frequency,
			playerid,
			playerid,
			TagScan(textInput));
	}

	SetPlayerChatBubble(playerid, TagScan(textInput), WHITE, 40.0, 10000);

	if(strlen(text) > 127)
	{
		sendsecondline = 1;

		new
			splitpos;

		for(new c = 128; c > 0; c--)
		{
			if(text[c] == ' ' || text[c] ==  ',' || text[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(text2, text[splitpos]);
		text[splitpos] = 0;
	}

	if(frequency == 0.0)
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);

		foreach(new i : Player)
		{
			if(IsPlayerInRangeOfPoint(i, 40.0, x, y, z))
			{
				SendClientMessage(i, WHITE, text);

				if(sendsecondline)
					SendClientMessage(i, WHITE, text2);
			}
		}
	}
	else if(frequency == 1.0)
	{
		foreach(new i : Player)
		{
			if(gPlayerBitData[i] & GlobalQuiet)
				continue;

			SendClientMessage(i, WHITE, text);

			if(sendsecondline)
				SendClientMessage(i, WHITE, text2);
		}
	}
	else
	{
		foreach(new i : Player)
		{
			if(-0.05 < frequency - gPlayerData[i][ply_RadioFrequency] < 0.05)
			{
				SendClientMessage(i, WHITE, text);

				if(sendsecondline)
					SendClientMessage(i, WHITE, text2);
			}
		}
	}

	return 1;
}

CMD:g(playerid, params[])
{
	if(gPlayerBitData[playerid] & Muted)
	{
		Msg(playerid, RED, " >  You are muted");
		return 1;
	}

	if(isnull(params))
	{
		gPlayerData[playerid][ply_ChatMode] = CHAT_MODE_GLOBAL;
		Msg(playerid, WHITE, " >  You turn your radio on to the global frequency.");
	}
	else
	{
		PlayerSendChat(playerid, params, 1.0);
	}

	return 1;
}
CMD:l(playerid, params[])
{
	if(isnull(params))
	{
		gPlayerData[playerid][ply_ChatMode] = CHAT_MODE_LOCAL;
		Msg(playerid, WHITE, " >  You turned your radio off, chat is not broadcasted.");
	}
	else
	{
		PlayerSendChat(playerid, params, 0.0);
	}

	return 1;
}
CMD:r(playerid, params[])
{
	if(isnull(params))
	{
		gPlayerData[playerid][ply_ChatMode] = CHAT_MODE_RADIO;
		MsgF(playerid, WHITE, " >  You turned your radio on to frequency %.2f.", gPlayerData[playerid][ply_RadioFrequency]);
	}
	else
	{
		PlayerSendChat(playerid, params, gPlayerData[playerid][ply_RadioFrequency]);
	}

	return 1;
}
CMD:quiet(playerid, params[])
{
	if(gPlayerBitData[playerid] & GlobalQuiet)
	{
		f:gPlayerBitData[playerid]<GlobalQuiet>;
		Msg(playerid, WHITE, " >  You turn on your radio's global receiver, you will now see all global chat.");
	}
	else
	{
		t:gPlayerBitData[playerid]<GlobalQuiet>;
		Msg(playerid, WHITE, " >  You turn off your radio's global receiver, you will not see any global chat.");
	}

	return 1;
}
ACMD:a[1](playerid, params[])
{
	if(isnull(params))
	{
		gPlayerData[playerid][ply_ChatMode] = CHAT_MODE_ADMIN;
		Msg(playerid, WHITE, " >  Admin chat activated.");
	}
	else
	{
		foreach(new i : Player)
		{
			if(gPlayerData[i][ply_Admin] > 0)
				MsgF(i, WHITE, "%C(A) %P"#C_WHITE": %s", AdminColours[gPlayerData[playerid][ply_Admin]], playerid, TagScan(params));
		}
	}

	return 1;
}

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
			format(cmdfunction, 64, "cmd_%s_%d", cmd[1], iLoop); // format the function to include the admin variable

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

	if		(result == 0) Msg(playerid, ORANGE, " >  That is not a recognized command. Check the "#C_BLUE"/help "#C_ORANGE"dialog.");
	else if	(result == 1) return 1; // valid command, do nothing.
	else if	(result == 2) Msg(playerid, ORANGE, " >  You cannot use that command right now.");
	else if	(result == 3) Msg(playerid, RED, " >  You cannot use that command on that player right now.");
	else if	(result == 4) Msg(playerid, RED, " >  Invalid ID");
	else if	(result == 5) Msg(playerid, RED, " >  You have insufficient authority to use that command.");
	else if	(result == 6) Msg(playerid, RED, " >  You can only use that command while on "#C_BLUE"administrator duty"#C_RED".");

	return 1;
}
