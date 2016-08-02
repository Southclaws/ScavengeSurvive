/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


// Chat modes
enum
{
	CHAT_MODE_LOCAL,		// 0 - Speak to players within chatbubble distance
	CHAT_MODE_GLOBAL,		// 1 - Speak to all players
	CHAT_MODE_RADIO,		// 2 - Speak to players on the same radio frequency
	CHAT_MODE_ADMIN			// 3 - Speak to admins
}


new
	chat_MessageStreak[MAX_PLAYERS],
	chat_LastMessageTick[MAX_PLAYERS];


forward OnPlayerSendChat(playerid, text[], Float:frequency);

hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/player/chat.pwn");

	chat_LastMessageTick[playerid] = 0;
	return 1;
}

hook OnPlayerText(playerid, text[])
{
	d:3:GLOBAL_DEBUG("[OnPlayerText] in /gamemodes/sss/core/player/chat.pwn");

	if(IsPlayerMuted(playerid))
	{
		if(GetPlayerMuteRemainder(playerid) == -1)
			ChatMsgLang(playerid, RED, "MUTEDPERMAN");

		else
			ChatMsgLang(playerid, RED, "MUTEDTIMERM", MsToString(GetPlayerMuteRemainder(playerid) * 1000, "%1h:%1m:%1s"));

		return 0;
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), chat_LastMessageTick[playerid]) < 1000)
		{
			chat_MessageStreak[playerid]++;
			if(chat_MessageStreak[playerid] == 3)
			{
				TogglePlayerMute(playerid, true, 30);
				ChatMsgLang(playerid, RED, "MUTEDFLOODM");
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

	if(GetPlayerChatMode(playerid) == CHAT_MODE_ADMIN)
		PlayerSendChat(playerid, text, 3.0);

	if(GetPlayerChatMode(playerid) == CHAT_MODE_RADIO)
		PlayerSendChat(playerid, text, GetPlayerRadioFrequency(playerid));

	return 0;
}

PlayerSendChat(playerid, chat[], Float:frequency)
{
	if(!IsPlayerLoggedIn(playerid))
		return 0;

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 1000)
		return 0;

	if(CallLocalFunction("OnPlayerSendChat", "dsf", playerid, chat, frequency))
		return 0;

	new
		line1[256],
		line2[128];

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

		SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
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

		SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
	}
	else if(frequency == 2.0)
	{
		logf("[CHAT] [LOCALME] [%p]: %s", playerid, chat);

		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);

		format(line1, 256, "[Local] %P %s",
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

		SetPlayerChatBubble(playerid, TagScan(chat), CHAT_LOCAL, 40.0, 10000);

		return 1;
	}
	else if(frequency == 3.0)
	{
		logf("[CHAT] [ADMIN] [%p]: %s", playerid, chat);

		format(line1, 256, "%C[Admin] (%d) %P"C_WHITE": %s",
			GetAdminRankColour(GetPlayerAdminLevel(playerid)),
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(GetPlayerAdminLevel(i) > 0)
			{
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2))
					SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}

		return 1;
	}
	else
	{
		logf("[CHAT] [RADIO] [%.2f] [%p]: %s", frequency, playerid, chat);

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

		SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
	}
}

CMD:g(playerid, params[])
{
	if(IsPlayerMuted(playerid))
	{
		if(GetPlayerMuteRemainder(playerid) == -1)
			ChatMsgLang(playerid, RED, "MUTEDPERMAN");

		else
			ChatMsgLang(playerid, RED, "MUTEDTIMERM", MsToString(GetPlayerMuteRemainder(playerid) * 1000, "%1h:%1m:%1s"));

		return 7;
	}

	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_GLOBAL);
		ChatMsgLang(playerid, WHITE, "RADIOGLOBAL");
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
		ChatMsgLang(playerid, WHITE, "RADIOLOCAL");
	}
	else
	{
		PlayerSendChat(playerid, params, 0.0);
	}

	return 7;
}

CMD:me(playerid, params[])
{
	PlayerSendChat(playerid, params, 2.0);

	return 1;
}

CMD:r(playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_RADIO);
		ChatMsgLang(playerid, WHITE, "RADIOFREQUN", GetPlayerRadioFrequency(playerid));
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
		ChatMsgLang(playerid, WHITE, "RADIOQUIET0");
	}
	else
	{
		SetPlayerBitFlag(playerid, GlobalQuiet, true);
		ChatMsgLang(playerid, WHITE, "RADIOQUIET1");
	}

	return 1;
}

ACMD:a[1](playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_ADMIN);
		ChatMsgLang(playerid, WHITE, "RADIOADMINC");
	}
	else
	{
		PlayerSendChat(playerid, params, 3.0);
	}

	return 7;
}
