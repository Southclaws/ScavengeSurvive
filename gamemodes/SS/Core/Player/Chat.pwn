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
