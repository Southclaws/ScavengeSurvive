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
			SetRestart(strval(params));
		}

		return 1;
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
					new ret = AddNameToWhitelist(name);

					if(ret == 0)
						printf("The name '%s' is already in the whitelist.", name);

					if(ret == 1)
						printf("Added '%s' to whitelist.", name);

					if(ret == -1)
						print("A database query error occurred.");
				}

				if(!strcmp(action, "remove") && action[0] != EOS && name[0] != EOS)
				{
					new ret = RemoveNameFromWhitelist(name);

					if(ret == 0)
						printf("The name '%s' is not in the whitelist.", name);

					if(ret == 1)
						printf("Removed '%s' from whitelist.", name);

					if(ret == -1)
						print("A database query error occurred.");
				}

				if(!strcmp(action, "?") && action[0] != EOS && name[0] != EOS)
				{
					new ret = IsNameInWhitelist(name);

					if(ret == 1)
						print("That name is in the whitelist.");

					if(ret == 0)
						print("That name is not in the whitelist.");

					if(ret == -1)
						print("A database query error occurred.");
				}
			}

			if(!strcmp(action, "on") && action[0] != EOS)
			{
				gWhitelist = true;
				print("Whitelist turned on.");
			}

			if(!strcmp(action, "off") && action[0] != EOS)
			{
				gWhitelist = false;
				print("Whitelist turned off.");
			}

		}

		return 1;
	}

	return 0;
}
