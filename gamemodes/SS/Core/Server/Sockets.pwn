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


#endinput
#include <YSI\y_hooks>


#define MAX_SOCKET_CONNECTIONS (64)


static
Socket:	socket,
Timer:	timeout[MAX_SOCKET_CONNECTIONS];


forward OnRemoteCommand(command[], params[]);


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Sockets'...");

	socket = socket_create(TCP);

	if(!is_socket_valid(socket))
	{
		print("ERROR");
		return 1;
	}

	socket_bind(socket, "localhost");
	socket_set_max_connections(socket, MAX_SOCKET_CONNECTIONS);

	socket_listen(socket, 7776);

	return 1;
}

hook OnScriptExit()
{
	print("\n[OnScriptExit] Shutting down 'Sockets'...");

	socket_stop_listen(socket);
	socket_destroy(socket);
}

public onSocketRemoteConnect(Socket:id, remote_client[], remote_clientid)
{
	if(id == socket)
	{
		printf("[SAPI] [onSocketRemoteConnect] id:%d remote_client:%s, remote_clientid:%d", _:id, remote_client, remote_clientid);
		timeout[remote_clientid] = defer socket_timeout(remote_clientid);

		return 1;
	}

	#if defined sock_onSocketRemoteConnect
		return sock_onSocketRemoteConnect(id, remote_client, remote_clientid);
	#else
		return 1;
	#endif
}
#if defined _ALS_onSocketRemoteConnect
	#undef onSocketRemoteConnect
#else
	#define _ALS_onSocketRemoteConnect
#endif
#define onSocketRemoteConnect sock_onSocketRemoteConnect
#if defined sock_onSocketRemoteConnect
	forward sock_onSocketRemoteConnect(Socket:id, remote_client[], remote_clientid);
#endif

public onSocketRemoteDisconnect(Socket:id, remote_clientid)
{
	if(id == socket)
	{
		printf("[SAPI] [onSocketRemoteDisconnect] id:%d remote_clientid:%d", _:id, remote_clientid);

		return 1;
	}

	#if defined sock_onSocketRemoteDisconnect
		return sock_onSocketRemoteDisconnect(id, remote_clientid);
	#else
		return 1;
	#endif
}
#if defined _ALS_onSocketRemoteDisconnect
	#undef onSocketRemoteDisconnect
#else
	#define _ALS_onSocketRemoteDisconnect
#endif
#define onSocketRemoteDisconnect sock_onSocketRemoteDisconnect
#if defined sock_onSocketRemoteDisconnect
	forward sock_onSocketRemoteDisconnect(Socket:id, remote_clientid);
#endif

public onSocketReceiveData(Socket:id, remote_clientid, data[], data_len)
{
	if(id == socket)
	{
		printf("[SAPI] [onSocketReceiveData] Received %d bytes from client %d on socket %d: '%s'", data_len, remote_clientid, _:id, data);
		stop timeout[remote_clientid];
		timeout[remote_clientid] = defer socket_timeout(remote_clientid);

		if(data[0] == EOS)
			return 1;

		new
			command[32],
			params[96],
			cmdfunction[64];

		sscanf(data, "s[30]s[96]", command, params);

		for (new i, j = strlen(command); i < j; i++)
			command[i] = tolower(command[i]);

		format(cmdfunction, sizeof(command) + 5, "scmd_%s", command[0]);

		if(isnull(params))
			CallLocalFunction(cmdfunction, "is", remote_clientid, "\1");

		else
			CallLocalFunction(cmdfunction, "is", remote_clientid, params);
	}

	#if defined sock_onSocketReceiveData
		return sock_onSocketReceiveData(id, remote_clientid, data, data_len);
	#else
		return 1;
	#endif
}
#if defined _ALS_onSocketReceiveData
	#undef onSocketReceiveData
#else
	#define _ALS_onSocketReceiveData
#endif
#define onSocketReceiveData sock_onSocketReceiveData
#if defined sock_onSocketReceiveData
	forward sock_onSocketReceiveData(Socket:id, remote_clientid, data[], data_len);
#endif

timer socket_timeout[10000](remote_clientid)
{
	printf("[socket_timeout] id:%d remote_clientid:%d", _:socket, remote_clientid);
	socket_close_remote_client(socket, remote_clientid);
}

stock socket_api_send(remote_clientid, data[])
{
	socket_sendto_remote_client(socket, remote_clientid, data);
}



SCMD:is_account_registered(remote_clientid, params[])
{
	strtrim(params, "\r\n");

	printf("[RCMD] is_account_registered '%s'", params);

	if(AccountExists(params))
		socket_sendto_remote_client(socket, remote_clientid, "true");

	else
		socket_sendto_remote_client(socket, remote_clientid, "false");
}

