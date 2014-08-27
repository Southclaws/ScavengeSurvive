// Check if the IRC include is present, if not then there's no point including.
#if !defined CHANNEL_PREFIX
	#endinput
#endif


#define BOT_1_NICKNAME "SS-Echo-A"
#define BOT_1_REALNAME "SS-Echo-A"
#define BOT_1_USERNAME "SS-Echo-A"

#define BOT_2_NICKNAME "SS-Echo-B"
#define BOT_2_REALNAME "SS-Echo-B"
#define BOT_2_USERNAME "SS-Echo-B"

#define MAX_BOTS		(2)
#define PLUGIN_VERSION	"1.4.3"


new
	gIrcServ[32]	= "irc.tl",
	gIrcPort		= 6667,
	gIrcChan[32]	= "#ScavengeSurvive",
	gIrcBotPass[32]	= "sanandrocalypse",
	gIrcBotMail[32]	= "SouthclawJK@gmail.com";


new
	gBots[MAX_BOTS],
	gIrcGroup;


hook OnGameModeInit()
{
	print("[OnGameModeInit] Initialising 'IRC'...");

	gBots[0] = IRC_Connect(gIrcServ, gIrcPort, BOT_1_NICKNAME, BOT_1_REALNAME, BOT_1_USERNAME);
	IRC_SetIntData(gBots[0], E_IRC_CONNECT_DELAY, 20);

	gBots[1] = IRC_Connect(gIrcServ, gIrcPort, BOT_2_NICKNAME, BOT_2_REALNAME, BOT_2_USERNAME);
	IRC_SetIntData(gBots[1], E_IRC_CONNECT_DELAY, 30);

	gIrcGroup = IRC_CreateGroup();
}

hook OnGameModeExit()
{
	IRC_Quit(gBots[0], "Gamemode Closing/Restarting");
	IRC_Quit(gBots[1], "Gamemode Closing/Restarting");

	IRC_DestroyGroup(gIrcGroup);
}

hook OnPlayerConnect(playerid)
{
	new
		joinMsg[128],
		name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, sizeof(name));
	format(joinMsg, sizeof(joinMsg), "> [%d] %s has joined the server.", playerid, name);
	IRC_GroupSay(gIrcGroup, gIrcChan, joinMsg);

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
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
	format(leaveMsg, sizeof(leaveMsg), "> [%d] %s has left the server. (%s)", playerid, name, reasonMsg);
	IRC_GroupSay(gIrcGroup, gIrcChan, leaveMsg);

	return 1;
}

hook OnPlayerText(playerid, text[])
{
	new
		name[MAX_PLAYER_NAME],
		ircMsg[256];

	GetPlayerName(playerid, name, sizeof(name));
	format(ircMsg, sizeof(ircMsg), "> [%d] %s: %s", playerid, name, text);
	IRC_GroupSay(gIrcGroup, gIrcChan, ircMsg);

	return 1;
}



public IRC_OnConnect(botid, ip[], port)
{
	printf("[IRC] IRC_OnConnect: Bot ID %d connected to %s:%d", botid, ip, port);

	IRC_SendRaw(botid, sprintf("ns identify %s", gIrcBotPass));
	IRC_JoinChannel(botid, gIrcChan);
	IRC_AddToGroup(gIrcGroup, botid);

	return 1;
}

public IRC_OnDisconnect(botid, ip[], port, reason[])
{
	printf("[IRC] IRC_OnDisconnect: Bot ID %d disconnected from %s:%d (%s)", botid, ip, port, reason);
	// Remove the bot from the group
	IRC_RemoveFromGroup(gIrcGroup, botid);
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

public IRC_OnReceiveRaw(botid, message[])
{
	new File:file;
	if (!fexist("irc_log.txt"))
	{
		file = fopen("irc_log.txt", io_write);
	}
	else
	{
		file = fopen("irc_log.txt", io_append);
	}
	if (file)
	{
		fwrite(file, message);
		fwrite(file, "\r\n");
		fclose(file);
	}
	return 1;
}

IRCCMD:say(botid, channel[], user[], host[], params[])
{
	if(IRC_IsVoice(botid, channel, user))
	{
		if(!isnull(params))
		{
			new msg[128];

			format(msg, sizeof(msg), ">Server: %s: %s", user, params);
			IRC_GroupSay(gIrcGroup, channel, msg);

			format(msg, sizeof(msg), " >  (IRC)%s: %s", user, params);
			SendClientMessageToAll(GREY, msg);
		}
	}
	return 1;
}
