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

hook OnGameModeExit()
{
	socket_stop_listen(socket);
	socket_destroy(socket);
}

public onSocketRemoteConnect(Socket:id, remote_client[], remote_clientid)
{
	printf("[onSocketRemoteConnect] id:%d remote_client:%s, remote_clientid:%d", _:id, remote_client, remote_clientid);
	timeout[remote_clientid] = defer socket_timeout(remote_clientid);
	return 1;
}

public onSocketRemoteDisconnect(Socket:id, remote_clientid)
{
	printf("[onSocketRemoteDisconnect] id:%d remote_clientid:%d", _:id, remote_clientid);
	return 1;
}


public onSocketReceiveData(Socket:id, remote_clientid, data[], data_len)
{
	stop timeout[remote_clientid];
	timeout[remote_clientid] = defer socket_timeout(remote_clientid);

	if(id == socket)
	{
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

	return 1;
}

SCMD:is_account_registered(remote_clientid, params[])
{
	strtrim(params, "\r\n");

	printf("[RCMD] is_account_registered '%s'", params);

	if(AccountExists(params))
		socket_sendto_remote_client(socket, 0, "true");

	else
		socket_sendto_remote_client(socket, 0, "false");
}

timer socket_timeout[10000](remote_clientid)
{
	printf("[socket_timeout] id:%d remote_clientid:%d", _:socket, remote_clientid);
	socket_close_remote_client(socket, remote_clientid);
}
