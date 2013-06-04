#include <YSI\y_hooks>

hook OnPlayerText(playerid, text[])
{
	new tmpMuteTime = tickcount() - ChatMuteTick[playerid];

	if(bPlayerGameSettings[playerid] & Muted)
	{
		Msg(playerid, RED, " >  You are muted");
		return 0;
	}

	if(tmpMuteTime < 30000)
	{
		Msg(playerid, RED, " >  Muted from global chat for "#C_ORANGE"30 "#C_YELLOW"seconds, Reason: "#C_BLUE"chat flooding");
		return 0;
	}

	if(tickcount() - tick_LastChatMessage[playerid] < 1000)
	{
		ChatMessageStreak[playerid]++;
		if(ChatMessageStreak[playerid] == 3)
		{
			Msg(playerid, RED, " >  Muted from global chat for "#C_ORANGE"30 "#C_YELLOW"seconds, Reason: "#C_BLUE"chat flooding");
			ChatMuteTick[playerid] = tickcount();
			return 0;
		}
	}
	else
	{
		if(ChatMessageStreak[playerid] > 0)
			ChatMessageStreak[playerid]--;
	}

	tick_LastChatMessage[playerid] = tickcount();

	if(gPlayerChatMode[playerid] == CHAT_MODE_LOCAL)
		PlayerSendChat(playerid, text, 0.0);

	if(gPlayerChatMode[playerid] == CHAT_MODE_GLOBAL)
		PlayerSendChat(playerid, text, 1.0);

	if(gPlayerChatMode[playerid] == CHAT_MODE_RADIO)
		PlayerSendChat(playerid, text, gPlayerFrequency[playerid]);

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
			if(bPlayerGameSettings[i] & GlobalQuiet)
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
			if(-0.05 < frequency - gPlayerFrequency[i] < 0.05)
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
	if(bPlayerGameSettings[playerid] & Muted)
	{
		Msg(playerid, RED, " >  You are muted");
		return 1;
	}

	if(isnull(params))
	{
		gPlayerChatMode[playerid] = CHAT_MODE_GLOBAL;
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
		gPlayerChatMode[playerid] = CHAT_MODE_LOCAL;
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
		gPlayerChatMode[playerid] = CHAT_MODE_RADIO;
		MsgF(playerid, WHITE, " >  You turned your radio on to frequency %.2f.", gPlayerFrequency[playerid]);
	}
	else
	{
		PlayerSendChat(playerid, params, gPlayerFrequency[playerid]);
	}
	return 1;
}
CMD:quiet(playerid, params[])
{
	if(bPlayerGameSettings[playerid] & GlobalQuiet)
	{
		f:bPlayerGameSettings[playerid]<GlobalQuiet>;
		Msg(playerid, WHITE, " >  You turn on your radio's global receiver, you will now see all global chat.");
	}
	else
	{
		t:bPlayerGameSettings[playerid]<GlobalQuiet>;
		Msg(playerid, WHITE, " >  You turn off your radio's global receiver, you will not see any global chat.");
	}

	return 1;
}
