#include <YSI\y_hooks>


new
	chat_MessageStreak[MAX_PLAYERS],
	chat_LastMessageTick[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	chat_LastMessageTick[playerid] = 0;
	return 1;
}

hook OnPlayerText(playerid, text[])
{
	if(IsPlayerMuted(playerid))
	{
		if(GetPlayerMuteRemainder(playerid) == -1)
			Msg(playerid, RED, " >  You are muted permanently.");

		else
			MsgF(playerid, RED, " >  You are muted. Time remaining: %s", MsToString(GetPlayerMuteRemainder(playerid), "%1h:%1m:%1s"));

		return 0;
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), chat_LastMessageTick[playerid]) < 1000)
		{
			chat_MessageStreak[playerid]++;
			if(chat_MessageStreak[playerid] == 3)
			{
				TogglePlayerMute(playerid, true, 30000);
				Msg(playerid, RED, " >  Muted from global chat for "C_ORANGE"30 "C_RED"seconds for chat flooding");
				return 0;
			}
		}
		else
		{
			if(chat_MessageStreak[playerid] > 0)
				chat_MessageStreak[playerid]--;
		}
	}

	chat_LastMessageTick[playerid] = GetTickCount();

	if(GetPlayerChatMode(playerid) == CHAT_MODE_LOCAL)
		PlayerSendChat(playerid, text, 0.0);

	if(GetPlayerChatMode(playerid) == CHAT_MODE_GLOBAL)
		PlayerSendChat(playerid, text, 1.0);

	if(GetPlayerChatMode(playerid) == CHAT_MODE_RADIO)
		PlayerSendChat(playerid, text, GetPlayerRadioFrequency(playerid));

	if(GetPlayerChatMode(playerid) == CHAT_MODE_ADMIN)
	{
		logf("[CHAT] [ADMIN] [%p]: %s", playerid, text);

		foreach(new i : Player)
		{
			if(GetPlayerAdminLevel(i) > 0)
				MsgF(i, WHITE, "%C[Admin] (%d) %P"C_WHITE": %s", GetAdminRankColour(GetPlayerAdminLevel(playerid)), playerid, playerid, TagScan(text));
		}
	}

	return 0;
}

PlayerSendChat(playerid, chat[], Float:frequency)
{
	if(GetTickCountDifference(GetPlayerServerJoinTick(playerid), GetTickCount()) < 1000)
		return 0;

	new
		line1[256],
		line2[128];

	SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

	if(frequency == 0.0)
	{
		logf("[CHAT] [LOCAL] [%p]: %s", playerid, chat);

		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);

		format(line1, 256, "[Local] (%d) %P"C_WHITE": %s",
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(IsPlayerInRangeOfPoint(i, 40.0, x, y, z))
			{
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2))
					SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}
	}
	else if(frequency == 1.0)
	{
		logf("[CHAT] [GLOBAL] [%p]: %s", playerid, chat);

		format(line1, 256, "[Global] (%d) %P"C_WHITE": %s",
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(GetPlayerBitFlag(i, GlobalQuiet))
				continue;

			SendClientMessage(i, WHITE, line1);

			if(!isnull(line2))
				SendClientMessage(i, WHITE, line2);
		}
	}
	else
	{
		logf("[CHAT] [RADIO] [%p]: %s", playerid, chat);

		format(line1, 256, "[%.2f] (%d) %P"C_WHITE": %s",
			frequency,
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(-0.05 < frequency - GetPlayerRadioFrequency(i) < 0.05)
			{
				SendClientMessage(i, CHAT_RADIO, line1);

				if(!isnull(line2))
					SendClientMessage(i, CHAT_RADIO, line2);
			}
		}
	}

	return 1;
}

CMD:g(playerid, params[])
{
	if(IsPlayerMuted(playerid))
	{
		if(GetPlayerMuteRemainder(playerid) == -1)
			Msg(playerid, RED, " >  You are muted permanently.");

		else
			MsgF(playerid, RED, " >  You are muted. Time remaining: %s", MsToString(GetPlayerMuteRemainder(playerid), "%1h:%1m:%1s"));

		return 7;
	}

	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_GLOBAL);
		Msg(playerid, WHITE, " >  You turn your radio on to the global frequency.");
	}
	else
	{
		PlayerSendChat(playerid, params, 1.0);
	}

	return 7;
}

CMD:l(playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_LOCAL);
		Msg(playerid, WHITE, " >  You turned your radio off, chat is not broadcasted.");
	}
	else
	{
		PlayerSendChat(playerid, params, 0.0);
	}

	return 7;
}

CMD:r(playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_RADIO);
		MsgF(playerid, WHITE, " >  You turned your radio on to frequency %.2f.", GetPlayerRadioFrequency(playerid));
	}
	else
	{
		PlayerSendChat(playerid, params, GetPlayerRadioFrequency(playerid));
	}

	return 7;
}

CMD:quiet(playerid, params[])
{
	if(GetPlayerBitFlag(playerid, GlobalQuiet))
	{
		SetPlayerBitFlag(playerid, GlobalQuiet, false);
		Msg(playerid, WHITE, " >  You turn on your radio's global receiver, you will now see all global chat.");
	}
	else
	{
		SetPlayerBitFlag(playerid, GlobalQuiet, true);
		Msg(playerid, WHITE, " >  You turn off your radio's global receiver, you will not see any global chat.");
	}

	return 1;
}

ACMD:a[1](playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_ADMIN);
		Msg(playerid, WHITE, " >  Admin chat activated.");
	}
	else
	{
		logf("[CHAT] [ADMIN] [%p]: %s", playerid, params);

		foreach(new i : Player)
		{
			if(GetPlayerAdminLevel(i) > 0)
				MsgF(i, WHITE, "%C(A) %P"C_WHITE": %s", GetAdminRankColour(GetPlayerAdminLevel(playerid)), playerid, TagScan(params));
		}
	}

	return 7;
}
