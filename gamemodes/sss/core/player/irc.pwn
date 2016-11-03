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


static
	irc_Active,
	irc_Serv[32],
	irc_Port,
	irc_ChatChan[32],
	irc_ChatPass[32],
	irc_ChatPrefix,
	irc_StaffChan[32],
	irc_StaffPass[32],
	irc_StaffPrefix,
	irc_BotNick[32],
	irc_BotName[32],
	irc_BotUser[32],
	irc_BotMail[64],
	irc_BotPass[32];


static
	irc_Bot,
	irc_Group;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'IRC'...");

	GetSettingInt		("irc/use-irc",		0,					irc_Active);
	GetSettingString	("irc/serv",		"irc.tl",			irc_Serv);
	GetSettingInt		("irc/port",		6667,				irc_Port);
	GetSettingString	("irc/chat-chan",	"#MyChatChannel",	irc_ChatChan);
	GetSettingString	("irc/chat-pass",	"changeme",			irc_ChatPass);
	GetSettingInt		("irc/chat-prefix",	'.',				irc_ChatPrefix);
	GetSettingString	("irc/staff-chan",	"#MyStaffChannel",	irc_StaffChan);
	GetSettingString	("irc/staff-pass",	"changeme",			irc_StaffPass);
	GetSettingInt		("irc/staff-prefix",'.',				irc_StaffPrefix);
	GetSettingString	("irc/bot-name",	"SS-Bot",			irc_BotName);
	GetSettingString	("irc/bot-nick",	"SS-Bot",			irc_BotNick);
	GetSettingString	("irc/bot-pass",	"changeme",			irc_BotPass);
	GetSettingString	("irc/bot-mail",	"e@ma.il",			irc_BotMail);
	GetSettingString	("irc/bot-user",	"SS-Bot",			irc_BotUser);

	if(!irc_Active)
		return 1;

	if(!strcmp(irc_BotPass, "changeme"))
	{
		print("ERROR: Please set the IRC bot password in settings.json");
		for(;;){}
	}

	if(!strcmp(irc_BotMail, "e@ma.il"))
	{
		print("ERROR: Please set the IRC bot email in settings.json");
		for(;;){}
	}

	irc_Bot = IRC_Connect(irc_Serv, irc_Port, irc_BotNick, irc_BotName, irc_BotUser);
	IRC_SetIntData(irc_Bot, E_IRC_CONNECT_DELAY, 20);

	irc_Group = IRC_CreateGroup();

	return 1;
}

hook OnScriptExit()
{
	d:3:GLOBAL_DEBUG("[OnScriptExit] in /gamemodes/sss/core/player/irc.pwn");

	print("\n[OnScriptExit] Shutting down 'IRC'...");

	if(!irc_Active)
		return 1;

	IRC_Quit(irc_Bot, "Gamemode Closing/Restarting");

	IRC_DestroyGroup(irc_Group);

	return 1;
}


hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/player/irc.pwn");

	if(!irc_Active)
		return 1;

	// If the server is booting up after a restart, don't send connects.
	if(gServerInitialising)
		return 1;

	new
		joinMsg[128],
		name[MAX_PLAYER_NAME + 1];

	GetPlayerName(playerid, name, sizeof(name));
	strins(name, ".", 1);

	format(joinMsg, sizeof(joinMsg), " >>> [%02d][%s] has joined the server.", playerid, name);
	IRC_GroupSay(irc_Group, irc_ChatChan, joinMsg);

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDisconnect] in /gamemodes/sss/core/player/irc.pwn");

	if(!irc_Active)
		return 1;

	// If the server is restarting, don't send disconnects.
	if(gServerRestarting)
		return 1;

	new
		leaveMsg[128],
		name[MAX_PLAYER_NAME + 1],
		reasonMsg[8];

	switch(reason)
	{
		case 0: reasonMsg = "Timeout";
		case 1: reasonMsg = "Leaving";
		case 2: reasonMsg = "Kicked";
	}

	GetPlayerName(playerid, name, sizeof(name));
	strins(name, ".", 1);

	format(leaveMsg, sizeof(leaveMsg), " <<< [%02d][%s] has left the server. (%s)", playerid, name, reasonMsg);
	IRC_GroupSay(irc_Group, irc_ChatChan, leaveMsg);

	return 1;
}

hook OnPlayerSendChat(playerid, text[], Float:frequency)
{
	d:3:GLOBAL_DEBUG("[OnPlayerSendChat] in /gamemodes/sss/core/player/irc.pwn");

	if(irc_Active)
		_IRC_HandleServerChat(playerid, text, frequency);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_IRC_HandleServerChat(playerid, text[], Float:frequency)
{
	if(frequency == 1.0)
	{
		if(irc_ChatPrefix != 0)
		{
			if(text[0] != irc_ChatPrefix)
				return 0;

			strdel(text, 0, 1);
		}

		new
			name[MAX_PLAYER_NAME + 1],
			message[7 + MAX_PLAYER_NAME + 128];

		GetPlayerName(playerid, name, sizeof(name));
		strins(name, ".", strlen(name) / 2); // Prevents repeated nickalerts.

		format(message, sizeof(message), "[%02d][%s]: %s", playerid, name, text);
		IRC_GroupSay(irc_Group, irc_ChatChan, message);		
	}

	if(frequency == 3.0)
	{
		if(irc_StaffPrefix != 0)
		{
			if(text[0] != irc_StaffPrefix)
				return 0;

			strdel(text, 0, 1);
		}

		new
			name[MAX_PLAYER_NAME + 1],
			message[7 + MAX_PLAYER_NAME + 128];

		GetPlayerName(playerid, name, sizeof(name));
		strins(name, ".", strlen(name) / 2); // Prevents repeated nickalerts.

		format(message, sizeof(message), "[%02d][%s]: %s", playerid, name, text);
		IRC_GroupSay(irc_Group, irc_StaffChan, message);		
	}

	return 1;
}

hook IRC_OnUserSay(botid, recipient[], user[], host[], message[])
{
	if(irc_Active)
		_IRC_HandleChannelChat(recipient, user, message);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_IRC_HandleChannelChat(recipient[], user[], message[])
{
	if(!strcmp(recipient, irc_ChatChan, true))
	{
		if(irc_ChatPrefix != 0)
		{
			if(message[0] != irc_ChatPrefix)
				return 0;

			strdel(message, 0, 1);
		}

		logf("[CHAT] [IRC-C] [%s]: %s", user, message);

		new
			line1[256],
			line2[128];

		format(line1, 256, "[IRC] "C_AQUA"%s"C_WHITE": %s", user, TagScan(message));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(IsPlayerGlobalQuiet(i))
				continue;

			SendClientMessage(i, WHITE, line1);

			if(!isnull(line2))
				SendClientMessage(i, WHITE, line2);
		}
	}

	if(!strcmp(recipient, irc_StaffChan, true))
	{
		if(irc_StaffPrefix != 0)
		{
			if(message[0] != irc_StaffPrefix)
				return 0;

			strdel(message, 0, 1);
		}

		logf("[CHAT] [IRC-S] [%s]: %s", user, message);

		new
			line1[256],
			line2[128];

		format(line1, 256, "[STAFF IRC] "C_AQUA"%s"C_WHITE": %s", user, TagScan(message));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(GetPlayerAdminLevel(i) == 0)
				continue;

			SendClientMessage(i, WHITE, line1);

			if(!isnull(line2))
				SendClientMessage(i, WHITE, line2);
		}
	}

	return 1;
}


public IRC_OnConnect(botid, ip[], port)
{
	if(!irc_Active)
		return 1;

	printf("[IRC] IRC_OnConnect: Bot ID %d connected to %s:%d", botid, ip, port);

	IRC_SendRaw(botid, sprintf("ns identify %s", irc_BotPass));

	IRC_JoinChannel(botid, irc_ChatChan, irc_ChatPass);
	IRC_JoinChannel(botid, irc_StaffChan, irc_StaffPass);

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


stock SendIrcChatMessage(name[], text[])
{
	new
		message[7 + MAX_PLAYER_NAME + 128];

	strins(name, ".", strlen(name) / 2, MAX_PLAYER_NAME);

	format(message, sizeof(message), "[-][%s]: %s", name, text);

	IRC_GroupSay(irc_Group, irc_ChatChan, message);

	return 1;
}

stock SendIrcStaffMessage(name[], text[])
{
	new
		message[7 + MAX_PLAYER_NAME + 128];

	strins(name, ".", strlen(name) / 2, MAX_PLAYER_NAME);

	format(message, sizeof(message), "[-][%s]: %s", name, text);

	IRC_GroupSay(irc_Group, irc_StaffChan, message);

	return 1;
}
