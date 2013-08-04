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

	if(!strcmp(command, "whitelist"))
	{
		if(params[0] == EOS)
		{
			print("\n\tUsage: 'whitelist (<add/remove> <name>) / (on/off/?)'.");
		}
		else
		{
			new
				action[7],
				name[MAX_PLAYER_NAME];

			if(!sscanf(params, "s[7]s[24]", action, name))
			{
				if(!strcmp(action, "add") && action[0] != EOS && name[0] != EOS)
				{
					new ret = CallRemoteFunction("external_WhitelistAdd", "s", name);
					printf("Added '%s' to whitelist ret: %d", name, ret);
				}

				if(!strcmp(action, "remove") && action[0] != EOS && name[0] != EOS)
				{
					new ret = CallRemoteFunction("external_WhitelistRemove", "s", name);
					printf("Removed '%s' from whitelist.", name, ret);
				}

				if(!strcmp(action, "on") && action[0] != EOS && name[0] != EOS)
				{
					CallRemoteFunction("external_WhitelistOn", "");
					print("Whitelist turned on.");
				}

				if(!strcmp(action, "off") && action[0] != EOS && name[0] != EOS)
				{
					CallRemoteFunction("external_WhitelistOff", "");
					print("Whitelist turned off.");
				}

				if(!strcmp(action, "?") && action[0] != EOS && name[0] != EOS)
				{
					new ret = CallRemoteFunction("external_WhitelistCheck", "s", name);

					if(ret)
						print("That name is in the whitelist");

					else
						print("That name is not in the whitelist");
				}
			}
		}
	}
}
