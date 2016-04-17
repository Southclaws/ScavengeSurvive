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
