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


/*
	AC client connects to GS through socket
	Server stores IP and username in buffer
	OnPlayerConnect -> check name/IP is in buffer
	if so: query that IP for AC, get hardware info

	Player = an in-game player who is connected to the game server
	Client = anti-cheat client application connected to the server
*/


#include <YSI\y_hooks>


#define MAX_AC_BUFFER	(256)


enum E_AC_CONNECT_BUFFER_DATA
{
			E_AC_CONNECT_BUFFER_CLIENT_ID,
			E_AC_CONNECT_BUFFER_IPADDRESS,
			E_AC_CONNECT_BUFFER_HANDSHAKE
}

enum E_AC_PLAYER_BUFFER_DATA
{
			E_AC_PLAYER_BUFFER_NAME[MAX_PLAYER_NAME],	// Username sent from AC client
			E_AC_PLAYER_BUFFER_PLAYER_ID,				// Player ID when they connect
			E_AC_PLAYER_BUFFER_TIMESTAMP,				// Timestamp of AC connection
			E_AC_PLAYER_BUFFER_IP_ADDRESS,				// Socket client IP Address
			E_AC_PLAYER_BUFFER_CLIENT_ID				// Socket client ID
}


static
Socket:		ac_Socket,

			/*
				The connect buffer contains data related to anti-cheat clients
				connecting to the server. This information is only relevant
				before the player connects to the server and is verified.
			*/
			ac_ConnectBuffer[MAX_AC_BUFFER][E_AC_CONNECT_BUFFER_DATA],
Iterator:	ac_ConnectIterator<MAX_AC_BUFFER>,

			/*
				The player buffer takes over as soon as a player connects to the
				server and is verified.
			*/
			ac_PlayerBuffer[MAX_AC_BUFFER][E_AC_PLAYER_BUFFER_DATA],
Iterator:	ac_PlayerIterator<MAX_AC_BUFFER>,

			ac_PlayerBufferCell[MAX_PLAYERS] = {-1, ...};

static
bool:		ac_Active,
bool:		ac_Auto,
			ac_Port,
			ac_Timeout,
bool:		ac_Whitelist,
			ac_KickOnClose,
			ac_Countdown[MAX_PLAYERS],
PlayerText:	ac_CountdownUI[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
Timer:		ac_CountdownTimer[MAX_PLAYERS];

static
			HANDLER = -1;


/*==============================================================================

	Setup

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'ac'...");

	GetSettingInt("ac/active", 0, ac_Active);
	GetSettingInt("ac/auto-toggle", 0, ac_Auto);
	GetSettingInt("ac/port", 7778, ac_Port);
	GetSettingInt("ac/timeout", 60, ac_Timeout);
	GetSettingInt("ac/whitelist", 0, ac_Whitelist);
	GetSettingInt("ac/kick-on-close", 1, ac_KickOnClose);

	HANDLER = debug_register_handler("SSAC", 4);
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'ac'...");

	ac_Socket = socket_create(TCP);

	if(!is_socket_valid(ac_Socket))
		printf("ERROR: Socket creation failed (%d)", _:ac_Socket);

	socket_bind(ac_Socket, "localhost");
	socket_set_max_connections(ac_Socket, MAX_AC_BUFFER);

	if(!socket_listen(ac_Socket, ac_Port))
	{
		new File:f = fopen("nonexistentfile", io_read), _s[1];
		fread(f, _s);
		fclose(f);
		return -2;
	}

	printf("[SSAC] SOCKET: Now listening on socket ID %d port %d", _:ac_Socket, ac_Port);

	for(new i; i < MAX_AC_BUFFER; i++)
		_ac_ResetBufferCell(i);

	return 0;
}


/*timer _ac_open_socket[1000](tries)
{
	tries += 1;

	printf("[_ac_open_socket] Tries: %d", tries);

	if(tries > 10)
	{
		SendRconCommand("exit");
		return;
	}

	socket_stop_listen(ac_Socket);

	if(!socket_listen(ac_Socket, ac_Port))
		defer _ac_open_socket(tries);

	return;
}
*/
hook OnScriptExit()
{
	print("\n[OnScriptExit] Shutting down 'ac'...");

	if(is_socket_valid(ac_Socket))
	{
		print("Closing AC socket...");
		socket_stop_listen(ac_Socket);
		socket_destroy(ac_Socket);
	}
}

hook OnPlayerConnect(playerid)
{
	ac_CountdownUI[playerid]		=CreatePlayerTextDraw(playerid, 430.0, 40.0, "No anti-cheat client~n~Time remaining: 00:00");
	PlayerTextDrawAlignment			(playerid, ac_CountdownUI[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ac_CountdownUI[playerid], 255);
	PlayerTextDrawFont				(playerid, ac_CountdownUI[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ac_CountdownUI[playerid], 0.20, 1.0);
	PlayerTextDrawColor				(playerid, ac_CountdownUI[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ac_CountdownUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, ac_CountdownUI[playerid], 1);

	return 1;
}


/*==============================================================================

	AC Buffer Interface

==============================================================================*/


_ac_ResetConnectBufferCell(cell)
{
	if(!(0 <= cell < MAX_AC_BUFFER))
		return 0;

	d:1:HANDLER("[_ac_ResetConnectBufferCell] cell:%d client:%d ip:'%s' hand:%d", cell, ac_ConnectBuffer[cell][E_AC_CONNECT_BUFFER_CLIENT_ID], IpIntToStr(ac_ConnectBuffer[cell][E_AC_CONNECT_BUFFER_IPADDRESS]), ac_ConnectBuffer[cell][E_AC_CONNECT_BUFFER_HANDSHAKE]);
	Iter_Remove(ac_ConnectIterator, cell);
	ac_ConnectBuffer[cell][E_AC_CONNECT_BUFFER_CLIENT_ID] = -1;
	ac_ConnectBuffer[cell][E_AC_CONNECT_BUFFER_IPADDRESS] = 0;
	ac_ConnectBuffer[cell][E_AC_CONNECT_BUFFER_HANDSHAKE] = 0;

	return 1;
}

_ac_ResetBufferCell(cell)
{
	if(!(0 <= cell < MAX_AC_BUFFER))
		return 0;

	d:1:HANDLER("[_ac_ResetBufferCell] cell:%d name:'%s' playerid:%d timestamp:%d ip:'%s' client:%d", cell, ac_PlayerBuffer[cell][E_AC_PLAYER_BUFFER_NAME], ac_PlayerBuffer[cell][E_AC_PLAYER_BUFFER_PLAYER_ID], ac_PlayerBuffer[cell][E_AC_PLAYER_BUFFER_TIMESTAMP], IpIntToStr(ac_PlayerBuffer[cell][E_AC_PLAYER_BUFFER_IP_ADDRESS]), ac_PlayerBuffer[cell][E_AC_PLAYER_BUFFER_CLIENT_ID]);
	Iter_Remove(ac_PlayerIterator, cell);
	d:1:HANDLER("[_ac_ResetBufferCell] After Iter_Remove");
	ac_PlayerBuffer[cell][E_AC_PLAYER_BUFFER_NAME][0] = 0;
	ac_PlayerBuffer[cell][E_AC_PLAYER_BUFFER_PLAYER_ID] = INVALID_PLAYER_ID;
	ac_PlayerBuffer[cell][E_AC_PLAYER_BUFFER_TIMESTAMP] = 0;
	ac_PlayerBuffer[cell][E_AC_PLAYER_BUFFER_IP_ADDRESS] = 0;
	ac_PlayerBuffer[cell][E_AC_PLAYER_BUFFER_CLIENT_ID] = -1;

	return 1;
}

/*
	Called to connect a specific IP and clientid to the server and store its
	data into the server memory ready for the handshake request to come in.
*/
_ac_ConnectClient(remote_client[], remote_clientid)
{
	d:1:HANDLER("[_ac_ConnectClient] Appending client %s (id:%d) to connection buffer.", remote_client, remote_clientid);

	new
		cell = Iter_Free(ac_ConnectIterator),
		ipbyte[4];

	if(cell == -1)
	{
		print("[_ac_ConnectClient] ERROR: AC IP buffer full.");
		return 1;
	}

	// Extract the IP into an integer (easier to work with than a string).
	sscanf(remote_client, "p<.>a<d>[4]", ipbyte);
	ac_ConnectBuffer[cell][E_AC_CONNECT_BUFFER_CLIENT_ID] = remote_clientid;
	ac_ConnectBuffer[cell][E_AC_CONNECT_BUFFER_IPADDRESS] = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);
	ac_ConnectBuffer[cell][E_AC_CONNECT_BUFFER_HANDSHAKE] = 0;

	return 1;
}

/*
	Called to process raw data received on the AC socket.
*/
_ac_ProcessRaw(remote_clientid, data[])
{
	d:1:HANDLER("[_ac_ProcessRaw] Received from client %d: '%s'", remote_clientid, data);

	if(!strcmp(data, "ACPORTCHECK"))
		return 1;

	new index;

	// Find out which index in the buffer contains this IP
	foreach(new i : ac_ConnectIterator)
	{
		if(ac_ConnectBuffer[i][E_AC_CONNECT_BUFFER_CLIENT_ID] == remote_clientid)
		{
			// Remember this index in the buffer for later.
			index = i;
			break;
		}
	}

	// Has this client not completed a handshake?
	if(ac_ConnectBuffer[index][E_AC_CONNECT_BUFFER_HANDSHAKE] == 0)
	{
		d:2:HANDLER("[_ac_ProcessRaw] Executing AC socket code phase 1: Client requires handshake.");
		// Are they requesting a handshake?
		if(!strcmp(data, "ACCLIENT"))
		{
			// If so, send handshake:
			_ac_SendHandshake(index);
			return 0;
		}
	}

	if(ac_ConnectBuffer[index][E_AC_CONNECT_BUFFER_HANDSHAKE] == 1)
	{
		strtrim(data, "\n\r");

		if(isnull(data))
		{
			d:2:HANDLER("[_ac_ProcessRaw] ERROR: Extracted name string is null");
			return 0;
		}

		if(!(3 <= strlen(data) <= 24))
		{
			d:2:HANDLER("[_ac_ProcessRaw] ERROR: Extracted name string is invalid length for a name");
			return 0;
		}

		_ac_AddPlayerToPlayerBuffer(data, remote_clientid, ac_ConnectBuffer[index][E_AC_CONNECT_BUFFER_IPADDRESS]);

		// Remove the connecting client from the connect buffer, not needed now.
		_ac_ResetConnectBufferCell(index);

		ac_ConnectBuffer[index][E_AC_CONNECT_BUFFER_HANDSHAKE] = 2;

		return 1;
	}

	printf("[_ac_ProcessRaw] WARNING: Received '%s' from client with handshake status of %d", data, ac_ConnectBuffer[index][E_AC_CONNECT_BUFFER_HANDSHAKE]);

	return 0;
}

/*
	Used to send a handshake back to the client.
*/
_ac_SendHandshake(index)
{
	d:3:HANDLER("[_ac_SendHandshake] Client is requesting handshake via 'ACCLIENT', sending response.");

	socket_sendto_remote_client(ac_Socket, ac_ConnectBuffer[index][E_AC_CONNECT_BUFFER_CLIENT_ID], "ACOK");
	ac_ConnectBuffer[index][E_AC_CONNECT_BUFFER_HANDSHAKE] = 1;

	return 1;
}

/*
	Appends a name to the buffer and performs the necessary checks to ensure
	the name is added or errors handled under any circumstance.
*/
_ac_AddPlayerToPlayerBuffer(name[], remote_clientid, ip)
{
	d:2:HANDLER("[_ac_AddPlayerToPlayerBuffer] Executing AC socket code phase 2: Buffer append name.");

	new index = _ac_BufferCheckName(name);

	if(index > -1)
	{
		d:2:HANDLER("[_ac_AddPlayerToPlayerBuffer] Name already in buffer with ID %d", ac_PlayerBuffer[index][E_AC_PLAYER_BUFFER_PLAYER_ID]);

		if(ac_PlayerBuffer[index][E_AC_PLAYER_BUFFER_PLAYER_ID] == INVALID_PLAYER_ID)
		{
			d:2:HANDLER("[_ac_AddPlayerToPlayerBuffer] Buffer entry player is not connected.");

			if(gettime() - ac_PlayerBuffer[index][E_AC_PLAYER_BUFFER_TIMESTAMP] < 10)
			{
				d:2:HANDLER("[_ac_AddPlayerToPlayerBuffer] Buffer entry was created less than 10 seconds ago, ending function.");
				return 0;
			}
		}
		else
		{
			d:2:HANDLER("[_ac_AddPlayerToPlayerBuffer] Buffer entry player is connected, ending function.");
			return 0;
		}
	}
	else
	{
		index = Iter_Free(ac_PlayerIterator);
	}

	// If the buffer is full
	if(index == -1)
	{
		d:2:HANDLER("[_ac_AddPlayerToPlayerBuffer] AC buffer is full, picking oldest entry to overwrite.");

		index = _ac_GetOldestBufferEntry();

		if(index == -1)
		{
			d:2:HANDLER("[_ac_AddPlayerToPlayerBuffer] ERROR: index = -1.");
			return 0;
		}
	}

	d:2:HANDLER("[_ac_AddPlayerToPlayerBuffer] Picked AC buffer index %d.", index);

	Iter_Add(ac_PlayerIterator, index);
	_ac_SetBufferCellData(index, name, remote_clientid, ip);

	return 1;
}

/*
	Checks if a name is already in the player buffer
*/
_ac_BufferCheckName(name[])
{
	foreach(new i : ac_PlayerIterator)
	{
		d:2:HANDLER("[_ac_BufferCheckName] %d: comparing '%s' with '%s'", i, name, ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_NAME]);

		if(!strcmp(ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_NAME], name, true))
			return i;
	}

	return -1;
}

_ac_GetOldestBufferEntry()
{
	new lastbuffertimestamp = gettime();

	// Look for an outdated buffer entry.
	foreach(new i : ac_PlayerIterator)
	{
		// If the current buffer index timestamp is higher than highest.
		if(ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_TIMESTAMP] < lastbuffertimestamp)
		{
			lastbuffertimestamp = ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_TIMESTAMP];
			return i;
		}
	}

	return -1;
}

_ac_SetBufferCellData(index, name[], remote_clientid, ip)
{
	d:1:HANDLER("[_ac_SetBufferCellData] Setting %d to '%s' %d '%d'", index, name, remote_clientid, IpIntToStr(ip));

	strcpy(ac_PlayerBuffer[index][E_AC_PLAYER_BUFFER_NAME], name, MAX_PLAYER_NAME);
	ac_PlayerBuffer[index][E_AC_PLAYER_BUFFER_PLAYER_ID] = bool:_ac_NameCheck(name);
	ac_PlayerBuffer[index][E_AC_PLAYER_BUFFER_TIMESTAMP] = gettime();
	ac_PlayerBuffer[index][E_AC_PLAYER_BUFFER_CLIENT_ID] = remote_clientid;
	ac_PlayerBuffer[index][E_AC_PLAYER_BUFFER_IP_ADDRESS] = ip;

	if(ac_PlayerBuffer[index][E_AC_PLAYER_BUFFER_PLAYER_ID] != INVALID_PLAYER_ID)
		ac_PlayerBufferCell[ac_PlayerBuffer[index][E_AC_PLAYER_BUFFER_PLAYER_ID]] = index;
}

_ac_ClientDisconnect(bufferid)
{
	d:1:HANDLER("[_ac_ClientDisconnect] Removing %d from buffer, client:%d player:%d name:'%s'", bufferid, ac_PlayerBuffer[bufferid][E_AC_PLAYER_BUFFER_CLIENT_ID], ac_PlayerBuffer[bufferid][E_AC_PLAYER_BUFFER_PLAYER_ID], ac_PlayerBuffer[bufferid][E_AC_PLAYER_BUFFER_NAME]);

	if(!ac_Active)
		return;

	if(!ac_KickOnClose)
		return;

	if(!IsPlayerConnected(ac_PlayerBuffer[bufferid][E_AC_PLAYER_BUFFER_PLAYER_ID]))
		return;

	d:1:HANDLER("[_ac_ClientDisconnect] Kicking %p (%d)", ac_PlayerBuffer[bufferid][E_AC_PLAYER_BUFFER_PLAYER_ID], ac_PlayerBuffer[bufferid][E_AC_PLAYER_BUFFER_PLAYER_ID]);

	KickPlayer(ac_PlayerBuffer[bufferid][E_AC_PLAYER_BUFFER_PLAYER_ID], "Lost connection with anti-cheat client.");
	_ac_ResetBufferCell(bufferid);

	return;
}

_ac_PlayerJoin(playerid)
{
	d:1:HANDLER("[_ac_PlayerJoin] Player %d connected, running AC buffer checks.", playerid);
	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	foreach(new i : ac_PlayerIterator)
	{
		d:2:HANDLER("[_ac_PlayerJoin] comparing '%s' == '%s'", name, ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_NAME]);
		if(!strcmp(ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_NAME], name, true))
		{
			ac_PlayerBufferCell[playerid] = i;
			_ac_PlayerJoinWithAC(playerid);
			return 1;
		}
	}

	return _ac_PlayerJoinNoAC(playerid);
}

_ac_PlayerJoinWithAC(playerid)
{
	Msg(playerid, YELLOW, " >  Anti-cheat client connected.");

	new ip = GetPlayerIpAsInt(playerid);

	if(ac_PlayerBuffer[ac_PlayerBufferCell[playerid]][E_AC_PLAYER_BUFFER_IP_ADDRESS] != ip)
	{
		printf("[KICK] Kicking '%p' (%d) for IP mismatch. Player: %s AC: %s", playerid, playerid, IpIntToStr(ip), IpIntToStr(ac_PlayerBuffer[ac_PlayerBufferCell[playerid]][E_AC_PLAYER_BUFFER_IP_ADDRESS]));
		MsgF(playerid, YELLOW, " >  Your game IP: %s, Your anti-cheat connection: %s If both connections are dead, you will be able to rejoin in 10 seconds.", IpIntToStr(ip), IpIntToStr(ac_PlayerBuffer[ac_PlayerBufferCell[playerid]][E_AC_PLAYER_BUFFER_IP_ADDRESS]));
		KickPlayer(playerid, "AC Client IP mismatch");
		return 0;
	}

	d:1:HANDLER("[_ac_PlayerJoinWithAC] Player '%p' (%d) connected with AC client.", playerid, playerid);
	ac_PlayerBuffer[ac_PlayerBufferCell[playerid]][E_AC_PLAYER_BUFFER_PLAYER_ID] = playerid;

	return 1;
}

_ac_PlayerJoinNoAC(playerid)
{
	if(!ac_Active)
		return 1;

	if(ac_Whitelist)
	{
		if(IsPlayerInWhitelist(playerid))
		{
			d:1:HANDLER("[_ac_PlayerJoinNoAC] AC Whitelist binding active, player without AC is in whitelist.");

			return 1;
		}
		else
		{
			d:1:HANDLER("[_ac_PlayerJoinNoAC] AC Whitelist binding active, player without AC isn't in whitelist.");

			_ac_SendWarningMessage(playerid, true);

			new
				name[MAX_PLAYER_NAME],
				alive;

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			GetAccountAliveState(name, alive);

			if(alive)
				return 0;

			return 1;
		}
	}

	d:1:HANDLER("[_ac_PlayerJoinNoAC] AC Whitelist binding inactive, warning player.");

	_ac_SendWarningMessage(playerid);

	new
		name[MAX_PLAYER_NAME],
		alive;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	GetAccountAliveState(name, alive);

	if(alive)
		return 0;

	return 1;
}

_ac_NameCheck(name[])
{
	new tmp_name[MAX_PLAYER_NAME];

	foreach(new i : Player)
	{
		GetPlayerName(i, tmp_name, MAX_PLAYER_NAME);

		if(!strcmp(tmp_name, name))
			return i;
	}

	return INVALID_PLAYER_ID;
}

_ac_SendWarningMessage(playerid, whitelistversion = false)
{
	Msg(playerid, BLUE, "=============================");

	if(whitelistversion)
	{
		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Cheat",
			""C_WHITE"You are not whitelisted, you must use the SS anti-cheat to play, go to:\n\n\t\t"C_YELLOW"j.mp/ss-ac\n\n\
			"C_WHITE"This is in force to provide the best gameplay experience for all players.\n\
			The application is extremely tiny and requires no installation.\n\
			Simply open it and connect join the server as usual.\n\n\
			You can still play the tutorial to get a feel for the game, enjoy!", "Close", "");

		Msg(playerid, YELLOW, "You are not whitelisted, you must use the SS anti-cheat to play, go to: "C_BLUE"j.mp/ss-ac");
		Msg(playerid, YELLOW, "This is in force to provide the best gameplay experience for all players.");
		Msg(playerid, YELLOW, "The application is extremely tiny and requires no installation.");
		Msg(playerid, YELLOW, "Simply open it and connect join the server as usual.");
		Msg(playerid, YELLOW, "You can still play the tutorial to get a feel for the game, enjoy!");
	}
	else
	{
		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Cheat",
			""C_WHITE"You must use the SS anti-cheat to play without admins, go to:\n\n\t\t"C_YELLOW"j.mp/ss-ac\n\n\
			"C_WHITE"This is in force to provide the best gameplay experience for all players.\n\
			The application is extremely tiny and requires no installation.\n\
			Simply open it and connect join the server as usual.\n\n\
			You can still play the tutorial to get a feel for the game, enjoy!", "Close", "");

		Msg(playerid, YELLOW, "You must use the SS anti-cheat to play without admins, go to: "C_BLUE"j.mp/ss-ac");
		Msg(playerid, YELLOW, "This is in force to provide the best gameplay experience for all players.");
		Msg(playerid, YELLOW, "The application is extremely tiny and requires no installation.");
		Msg(playerid, YELLOW, "Simply open it and connect join the server as usual.");
		Msg(playerid, YELLOW, "You can still play the tutorial to get a feel for the game, enjoy!");
	}
}


/*==============================================================================

	General Interface

==============================================================================*/


stock IsPlayerUsingAntiCheat(playerid)
{
	print("IsPlayerUsingAntiCheat 0");
	if(!IsPlayerConnected(playerid))
		return 0;

	printf("IsPlayerUsingAntiCheat 1 %d", ac_PlayerBufferCell[playerid]);
	if(ac_PlayerBufferCell[playerid] == -1)
		return 0;

	printf("IsPlayerUsingAntiCheat 2 %d", ac_PlayerBuffer[ac_PlayerBufferCell[playerid]][E_AC_PLAYER_BUFFER_PLAYER_ID]);
	if(ac_PlayerBuffer[ac_PlayerBufferCell[playerid]][E_AC_PLAYER_BUFFER_PLAYER_ID] != playerid)
		return 0;

	print("IsPlayerUsingAntiCheat 3");
	return 1;
}

stock SetAntiCheatActive(bool:toggle)
{
	ac_Active = toggle;

	if(toggle)
	{
		foreach(new i : Player)
		{
			if(!IsPlayerUsingAntiCheat(i))
			{
				ac_Countdown[i] = 60;
				PlayerTextDrawSetString(i, ac_CountdownUI[i], sprintf("No anti-cheat client~n~Time remaining: %02d:%02d", ac_Countdown[i] / 60, ac_Countdown[i] % 60));
				PlayerTextDrawShow(i, ac_CountdownUI[i]);
				stop ac_CountdownTimer[i];
				ac_CountdownTimer[i] = repeat _ac_UpdateCountdown(i);
			}
		}
	}
	else
	{
		foreach(new i : Player)
		{
			if(!IsPlayerUsingAntiCheat(i))
			{
				stop ac_CountdownTimer[i];
				PlayerTextDrawHide(i, ac_CountdownUI[i]);
			}
		}
	}
}

timer _ac_UpdateCountdown[1000](playerid)
{
	if(!IsPlayerLoggedIn(playerid))
	{
		stop ac_CountdownTimer[playerid];
		return;
	}

	if(ac_Countdown[playerid] == 0)
	{
		_ac_SendWarningMessage(playerid);
		KickPlayer(playerid, "Anti-cheat mode activated, please download the client from ac.scavengesurvive.com to continue playing!");
		stop ac_CountdownTimer[playerid];
		return;
	}

	PlayerTextDrawSetString(playerid, ac_CountdownUI[playerid], sprintf("No anti-cheat client~n~Time remaining: %02d:%02d", ac_Countdown[playerid] / 60, ac_Countdown[playerid] % 60));
	PlayerTextDrawShow(playerid, ac_CountdownUI[playerid]);

	ac_Countdown[playerid]--;

	return;
}

stock SetAntiCheatAuto(bool:toggle)
{
	ac_Auto = toggle;
	// Check for online admins and adjust AC state accordingly.
}

stock SetAntiCheatWhitelistBind(bool:toggle)
{
	ac_Whitelist = toggle;
	// Check for none whitelisted players if AC is active.
}


/*==============================================================================

	Hooks

==============================================================================*/


public OnPlayerLoadAccount(playerid)
{
	if(!_ac_PlayerJoin(playerid))
		return 1;

	#if defined ac_OnPlayerLoadAccount
		return ac_OnPlayerLoadAccount(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerLoadAccount
	#undef OnPlayerLoadAccount
#else
	#define _ALS_OnPlayerLoadAccount
#endif
#define OnPlayerLoadAccount ac_OnPlayerLoadAccount
#if defined ac_OnPlayerLoadAccount
	forward ac_OnPlayerLoadAccount(playerid);
#endif

public OnPlayerLogin(playerid)
{
	d:1:HANDLER("[OnPlayerLogin] ac_Auto:%d ac_Active:%d", ac_Auto, ac_Active);

	if(ac_Auto && ac_Active)
	{
		d:1:HANDLER("[OnPlayerLogin] Admins online: %d", GetAdminsOnline(2));

		if(GetAdminsOnline(2) > 0) // turn off if ac is on and admins are online
		{
			d:1:HANDLER("[OnPlayerLogin] Disabling AC");
			SetAntiCheatActive(false);
		}
	}

	#if defined ac_OnPlayerLogin
		return ac_OnPlayerLogin(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLogin
	#undef OnPlayerLogin
#else
	#define _ALS_OnPlayerLogin
#endif

#define OnPlayerLogin ac_OnPlayerLogin
#if defined ac_OnPlayerLogin
	forward ac_OnPlayerLogin(playerid);
#endif

public OnPlayerCreateNewCharacter(playerid)
{
	if(ac_Active)
	{
		if(ac_PlayerBufferCell[playerid] == -1)
		{
			if(!(ac_Whitelist && IsPlayerInWhitelist(playerid)))
			{
				PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
				PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);

				_ac_SendWarningMessage(playerid);
			}
		}
	}

	#if defined ac_OnPlayerCreateNewCharacter
		return ac_OnPlayerCreateNewCharacter(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerCreateNewCharacter
	#undef OnPlayerCreateNewCharacter
#else
	#define _ALS_OnPlayerCreateNewCharacter
#endif
 
#define OnPlayerCreateNewCharacter ac_OnPlayerCreateNewCharacter
#if defined ac_OnPlayerCreateNewCharacter
	forward ac_OnPlayerCreateNewCharacter(playerid);
#endif


hook OnPlayerDisconnect(playerid, reason)
{
	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	defer _ac_DisconnectDelay();

	d:1:HANDLER("[OnPlayerDisconnect] ac_PlayerBufferCell:%d", ac_PlayerBufferCell[playerid]);
	if(ac_PlayerBufferCell[playerid] != -1)
	{
		_ac_ResetBufferCell(ac_PlayerBufferCell[playerid]);
		ac_PlayerBufferCell[playerid] = -1;
	}

	return 1;
}

timer _ac_DisconnectDelay[100]()
{
	d:1:HANDLER("[_ac_DisconnectDelay] ac_Auto:%d ac_Active:%d", ac_Auto, ac_Active);

	if(ac_Auto && !ac_Active)
	{
		d:1:HANDLER("[_ac_DisconnectDelay] Admins online: %d", GetAdminsOnline(2));

		if(GetAdminsOnline(2) == 0) // turn on if ac is off and no admins remain online
		{
			d:1:HANDLER("[_ac_DisconnectDelay] Enabling AC");
			SetAntiCheatActive(true);
		}
	}
}

public onSocketRemoteConnect(Socket:id, remote_client[], remote_clientid)
{
	if(id == ac_Socket)
	{
		_ac_ConnectClient(remote_client, remote_clientid);
		return 1;
	}

	#if defined ac_onSocketRemoteConnect
		return ac_onSocketRemoteConnect(id, remote_client, remote_clientid);
	#else
		return 1;
	#endif
}
#if defined _ALS_onSocketRemoteConnect
	#undef onSocketRemoteConnect
#else
	#define _ALS_onSocketRemoteConnect
#endif
#define onSocketRemoteConnect ac_onSocketRemoteConnect
#if defined ac_onSocketRemoteConnect
	forward ac_onSocketRemoteConnect(Socket:id, remote_client[], remote_clientid);
#endif

public onSocketRemoteDisconnect(Socket:id, remote_clientid)
{
	if(id == ac_Socket)
	{
		printf("[SSAC] [DISCONNECT] id:%d remote_clientid:%d", _:id, remote_clientid);

		foreach(new i : ac_PlayerIterator)
		{
			if(remote_clientid == ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_CLIENT_ID])
			{
				_ac_ClientDisconnect(i);
				break;
			}
		}

		foreach(new i : ac_ConnectIterator)
		{
			if(ac_ConnectBuffer[i][E_AC_CONNECT_BUFFER_CLIENT_ID] == remote_clientid)
			{
				_ac_ResetConnectBufferCell(i);
				break;
			}
		}

		return 1;
	}

	#if defined ac_onSocketRemoteDisconnect
		return ac_onSocketRemoteDisconnect(id, remote_clientid);
	#else
		return 1;
	#endif
}
#if defined _ALS_onSocketRemoteDisconnect
	#undef onSocketRemoteDisconnect
#else
	#define _ALS_onSocketRemoteDisconnect
#endif
#define onSocketRemoteDisconnect ac_onSocketRemoteDisconnect
#if defined ac_onSocketRemoteDisconnect
	forward ac_onSocketRemoteDisconnect(Socket:id, remote_clientid);
#endif

public onSocketReceiveData(Socket:id, remote_clientid, data[], data_len)
{
	if(id == ac_Socket)
	{
		_ac_ProcessRaw(remote_clientid, data);

		return 1;
	}

	#if defined ac_onSocketReceiveData
		return ac_onSocketReceiveData(id, remote_clientid, data, data_len);
	#else
		return 1;
	#endif
}
#if defined _ALS_onSocketReceiveData
	#undef onSocketReceiveData
#else
	#define _ALS_onSocketReceiveData
#endif
#define onSocketReceiveData ac_onSocketReceiveData
#if defined ac_onSocketReceiveData
	forward ac_onSocketReceiveData(Socket:id, remote_clientid, data[], data_len);
#endif


/*==============================================================================

	Commands

==============================================================================*/


ACMD:ac[3](playerid, params[])
{
	if(isnull(params))
	{
		MsgF(playerid, YELLOW, " >  Current anti-cheat state: %d", ac_Active);
	}
	else
	{
		SetAntiCheatActive(bool:strval(params));
		MsgF(playerid, YELLOW, "Set anti-cheat state %d", strval(params));
	}

	return 1;
}

ACMD:acauto[3](playerid, params[])
{
	if(isnull(params))
	{
		MsgF(playerid, YELLOW, " >  Current auto anti-cheat state: %d", ac_Auto);
	}
	else
	{
		SetAntiCheatAuto(bool:strval(params));
		MsgF(playerid, YELLOW, "Set auto anti-cheat state %d", strval(params));
	}

	return 1;
}

ACMD:acwl[3](playerid, params[])
{
	if(isnull(params))
	{
		MsgF(playerid, YELLOW, " >  Current anti-cheat whitelist state: %d", ac_Whitelist);
	}
	else
	{
		SetAntiCheatWhitelistBind(bool:strval(params));
		MsgF(playerid, YELLOW, "Set anti-cheat whitelist state %d", strval(params));
	}

	return 1;
}

ACMD:showbuffer[3](playerid, params[])
{
	gBigString[playerid][0] = EOS;

	foreach(new i : ac_PlayerIterator)
	{
		format(gBigString[playerid], sizeof(gBigString[]), "%s%s: %s(%d) ip:%s client:%d\n",
			gBigString[playerid],
			TimestampToDateTime(ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_TIMESTAMP], "%X"),
			ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_NAME],
			ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_PLAYER_ID],
			IpIntToStr(ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_IP_ADDRESS]),
			ac_PlayerBuffer[i][E_AC_PLAYER_BUFFER_CLIENT_ID]);
	}

	Dialog_Show(playerid, DIALOG_STYLE_LIST, "AC Player Buffer", gBigString[playerid], "Close", "");

	return 1;
}

hook OnRconCommand(cmd[])
{
	new
		command[32],
		params[32];

	sscanf(cmd, "s[32]s[32]", command, params);

	if(!strcmp(command, "ac"))
	{
		if(isnull(params))
		{
			printf("Current anti-cheat state: %d", ac_Active);
		}
		else
		{
			SetAntiCheatActive(bool:strval(params));
			printf("Set anti-cheat state %d", strval(params));
		}

		return 1;
	}

	if(!strcmp(command, "acauto"))
	{
		if(isnull(params))
		{
			printf("Current auto anti-cheat state: %d", ac_Active);
		}
		else
		{
			SetAntiCheatAuto(bool:strval(params));
			printf("Set auto anti-cheat state %d", strval(params));
		}

		return 1;
	}

	return 1;
}
