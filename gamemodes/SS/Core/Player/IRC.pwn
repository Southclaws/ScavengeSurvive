#include <YSI\y_hooks>


static
	irc_Serv[32],
	irc_Port,
	irc_Chan[32],
	irc_Pass[32],
	irc_BotNick[32],
	irc_BotName[32],
	irc_BotUser[32],
	irc_BotPass[32];


static
	irc_Bot,
	irc_Group;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'IRC'...");

	GetSettingString	("irc/bot-name",	"SS-Bot",			irc_BotName);
	GetSettingString	("irc/bot-nick",	"SS-Bot",			irc_BotNick);
	GetSettingString	("irc/bot-pass",	"changeme",			irc_BotPass);
	GetSettingString	("irc/bot-user",	"SS-Bot",			irc_BotUser);
	GetSettingString	("irc/chan",		"#MyChannel",		irc_Chan);
	GetSettingString	("irc/pass",		"changeme",			irc_Pass);
	GetSettingInt		("irc/port",		6667,				irc_Port);
	GetSettingString	("irc/serv",		"irc.tl",			irc_Serv);

	irc_Bot = IRC_Connect(irc_Serv, irc_Port, irc_BotNick, irc_BotName, irc_BotUser);
	IRC_SetIntData(irc_Bot, E_IRC_CONNECT_DELAY, 20);

	irc_Group = IRC_CreateGroup();
}

hook OnGameModeExit()
{
	IRC_Quit(irc_Bot, "Gamemode Closing/Restarting");

	IRC_DestroyGroup(irc_Group);
}

hook OnPlayerConnect(playerid)
{
	// If the server is booting up after a restart, don't send connects.
	if(gServerInitialising)
		return 1;

	new
		joinMsg[128],
		name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, sizeof(name));
	format(joinMsg, sizeof(joinMsg), "[%d][%s] has joined the server.", playerid, name);
	IRC_GroupSay(irc_Group, irc_Chan, joinMsg);

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	// If the server is restarting, don't send disconnects.
	if(gServerRestarting)
		return 1;

	new
		leaveMsg[128],
		name[MAX_PLAYER_NAME],
		reasonMsg[8];

	switch(reason)
	{
		case 0: reasonMsg = "Timeout";
		case 1: reasonMsg = "Leaving";
		case 2: reasonMsg = "Kicked";
	}

	GetPlayerName(playerid, name, sizeof(name));
	format(leaveMsg, sizeof(leaveMsg), "[%d][%s] has left the server. (%s)", playerid, name, reasonMsg);
	IRC_GroupSay(irc_Group, irc_Chan, leaveMsg);

	return 1;
}

public OnPlayerSendChat(playerid, text[], Float:frequency)
{
	if(frequency == 1.0)
	{
		new
			name[MAX_PLAYER_NAME],
			ircMsg[256];

		GetPlayerName(playerid, name, sizeof(name));
		format(ircMsg, sizeof(ircMsg), "[%02d][%s]: %s", playerid, name, text);
		IRC_GroupSay(irc_Group, irc_Chan, ircMsg);		
	}

	#if defined irc_OnPlayerSendChat
		return irc_OnPlayerSendChat(playerid, text, frequency);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerSendChat
	#undef OnPlayerSendChat
#else
	#define _ALS_OnPlayerSendChat
#endif
 
#define OnPlayerSendChat irc_OnPlayerSendChat
#if defined irc_OnPlayerSendChat
	forward irc_OnPlayerSendChat(playerid, text[], Float:frequency);
#endif

public IRC_OnUserSay(botid, recipient[], user[], host[], message[])
{
	if(!strcmp(recipient, "#ScavengeSurviveChat", true))
	{
		logf("[CHAT] [IRC] [%s]: %s", user, message);

		new
			line1[256],
			line2[128];

		format(line1, 256, "[IRC] "C_AQUA"%s"C_WHITE": %s", user, TagScan(message));

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

	#if defined irc_IRC_OnUserSay
		return irc_IRC_OnUserSay(botid, recipient[], user[], host[], message[]);
	#else
		return 1;
	#endif
}
#if defined _ALS_IRC_OnUserSay
	#undef IRC_OnUserSay
#else
	#define _ALS_IRC_OnUserSay
#endif
 
#define IRC_OnUserSay irc_IRC_OnUserSay
#if defined irc_IRC_OnUserSay
	forward irc_IRC_OnUserSay(botid, recipient[], user[], host[], message[]);
#endif


public IRC_OnConnect(botid, ip[], port)
{
	printf("[IRC] IRC_OnConnect: Bot ID %d connected to %s:%d", botid, ip, port);

	IRC_SendRaw(botid, sprintf("ns identify %s", irc_BotPass));
	IRC_JoinChannel(botid, irc_Chan);
	IRC_AddToGroup(irc_Group, botid);

	return 1;
}

public IRC_OnDisconnect(botid, ip[], port, reason[])
{
	printf("[IRC] IRC_OnDisconnect: Bot ID %d disconnected from %s:%d (%s)", botid, ip, port, reason);
	// Remove the bot from the group
	IRC_RemoveFromGroup(irc_Group, botid);
	return 1;
}

public IRC_OnJoinChannel(botid, channel[])
{
	// printf("[IRC] IRC_OnJoinChannel: Bot ID %d joined channel %s", botid, channel);
	return 1;
}

public IRC_OnLeaveChannel(botid, channel[], message[])
{
	// printf("[IRC] IRC_OnLeaveChannel: Bot ID %d left channel %s (%s)", botid, channel, message);
	return 1;
}



public IRC_OnKickedFromChannel(botid, channel[], oppeduser[], oppedhost[], message[])
{
	printf("[IRC] IRC_OnKickedFromChannel: Bot ID %d kicked by %s (%s) from channel %s (%s)", botid, oppeduser, oppedhost, channel, message);
	IRC_JoinChannel(botid, channel);
	return 1;
}

public IRC_OnUserDisconnect(botid, user[], host[], message[])
{
	printf("[IRC] IRC_OnUserDisconnect (Bot ID %d): User %s (%s) disconnected (%s)", botid, user, host, message);
	return 1;
}

public IRC_OnUserJoinChannel(botid, channel[], user[], host[])
{
	printf("[IRC] IRC_OnUserJoinChannel (Bot ID %d): User %s (%s) joined channel %s", botid, user, host, channel);
	return 1;
}

public IRC_OnUserLeaveChannel(botid, channel[], user[], host[], message[])
{
	printf("[IRC] IRC_OnUserLeaveChannel (Bot ID %d): User %s (%s) left channel %s (%s)", botid, user, host, channel, message);
	return 1;
}

public IRC_OnUserKickedFromChannel(botid, channel[], kickeduser[], oppeduser[], oppedhost[], message[])
{
	printf("[IRC] IRC_OnUserKickedFromChannel (Bot ID %d): User %s kicked by %s (%s) from channel %s (%s)", botid, kickeduser, oppeduser, oppedhost, channel, message);
}

public IRC_OnUserNickChange(botid, oldnick[], newnick[], host[])
{
	printf("[IRC] IRC_OnUserNickChange (Bot ID %d): User %s (%s) changed his/her nick to %s", botid, oldnick, host, newnick);
	return 1;
}

public IRC_OnUserSetChannelMode(botid, channel[], user[], host[], mode[])
{
	printf("[IRC] IRC_OnUserSetChannelMode (Bot ID %d): User %s (%s) on %s set mode: %s", botid, user, host, channel, mode);
	return 1;
}

public IRC_OnUserSetChannelTopic(botid, channel[], user[], host[], topic[])
{
	printf("[IRC] IRC_OnUserSetChannelTopic (Bot ID %d): User %s (%s) on %s set topic: %s", botid, user, host, channel, topic);
	return 1;
}
