#include <YSI\y_hooks>


static Socket:socket;


forward OnRemoteCommand(command[], params[]);


hook OnGameModeInit()
{
	socket = socket_create(TCP);

	if(!is_socket_valid(socket))
	{
		print("ERROR");
		return 1;
	}

	socket_bind(socket, "localhost");
	socket_set_max_connections(socket, 1);

	socket_listen(socket, 7778);

	return 1;
}

hook OnGameModeExit()
{
	socket_stop_listen(socket);
	socket_destroy(socket);
}

public onSocketReceiveData(Socket:id, remote_clientid, data[], data_len)
{
	if(id == socket)
	{
		if(data[0] == EOS)
			return 1;

		new
			command[32],
			params[96];

		sscanf(data, "s[32]s[96]", command, params);

		CallLocalFunction("OnRemoteCommand", "ss", command, params);
	}

	return 1;
}

public OnRemoteCommand(command[], params[])
{
	if(!strcmp(command, "is_account_registered"))
	{
		strtrim(params, "\r\n");

		printf("[RCMD] is_account_registered '%s'", params);

		if(AccountExists(params))
			socket_sendto_remote_client(socket, 0, "true");

		else
			socket_sendto_remote_client(socket, 0, "false");
	}
}
