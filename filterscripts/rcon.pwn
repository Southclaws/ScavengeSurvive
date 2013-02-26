#include <a_samp>
#include <sscanf2>

public OnRconCommand(cmd[])
{
	new
		command[32],
		params[32];

	sscanf(cmd, "s[32]s[32]", command, params);

	if(!strcmp(command, "restart"))
	{
		if(params[0] == EOS)
		{
			print("\n\tUsage: 'restart <seconds>' enter '0' to restart instantly.");
			print("\tIt is not advised to restart instantly.");
			print("\tEntering a time will display a countdown to all players");
			print("\tallowing them to prepare for the restart.\n");
		}
		else
		{
			CallRemoteFunction("SetRestart", "d", strval(params));
		}
	}
}
