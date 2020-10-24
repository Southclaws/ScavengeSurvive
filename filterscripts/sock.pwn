/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define FILTERSCRIPT


#include <a_samp>
#include <socket>
#include <sscanf2>


static
	Socket:gCommSocket;


public OnFilterScriptInit()
{
	gCommSocket = socket_create(TCP);

	if(!is_socket_valid(gCommSocket))
	{
		print("ERROR");
		return 1;
	}

	socket_bind(gCommSocket, "localhost");
	socket_set_max_connections(gCommSocket, 1);

	socket_listen(gCommSocket, 7778);

	return 1;
}

public OnFilterScriptExit()
{
	socket_stop_listen(gCommSocket);
	socket_destroy(gCommSocket);
}


public onSocketReceiveData(Socket:id, remote_clientid, data[], data_len)
{
	printf("onSocketReceiveData socketid %d, clientid %d, len %d", _:id, remote_clientid, data_len);

	if(id == gCommSocket)
	{
		if(data[0] == EOS)
			return 1;

		new
			command[32],
			params[96];

		sscanf(data, "s[32]s[96]", command, params);

		OnRemoteCommand(command, params);
	}

	return 1;
}

public onSocketAnswer(Socket:id, data[], data_len)
{
	printf("onSocketAnswer socketid %d len %d", _:id, data_len);


	return 1;
}


OnRemoteCommand(command[], params[])
{
	printf("OnRemoteCommand: '%s': '%s'", command, params);

	if(!strcmp(command, "is_account_registered"))
	{
		print("sending response");
		socket_sendto_remote_client(gCommSocket, 0, "response");
		print("response sent");
	}
}
