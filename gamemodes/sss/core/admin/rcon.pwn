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
			console("\n\tUsage: 'restart <seconds>' enter '0' to restart instantly.");
			console("\tIt is not advised to restart instantly.");
			console("\tEntering a time will display a countdown to all players");
			console("\tallowing them to prepare for the restart.\n");
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
			console("\n\tUsage: 'whitelist (<add/remove> <name>) / (on/off/?)'.");
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
						console("The name '%s' is already in the whitelist.", name);

					if(ret == 1)
						console("Added '%s' to whitelist.", name);

					if(ret == -1)
						console("A database query error occurred.");
				}

				if(!strcmp(action, "remove") && action[0] != EOS && name[0] != EOS)
				{
					new ret = RemoveNameFromWhitelist(name);

					if(ret == 0)
						console("The name '%s' is not in the whitelist.", name);

					if(ret == 1)
						console("Removed '%s' from whitelist.", name);

					if(ret == -1)
						console("A database query error occurred.");
				}

				if(!strcmp(action, "?") && action[0] != EOS && name[0] != EOS)
				{
					new ret = IsNameInWhitelist(name);

					if(ret == 1)
						console("That name is in the whitelist.");

					if(ret == 0)
						console("That name is not in the whitelist.");

					if(ret == -1)
						console("A database query error occurred.");
				}
			}

			if(!strcmp(action, "on") && action[0] != EOS)
			{
				ToggleWhitelist(true);
				console("Whitelist turned on.");
			}

			if(!strcmp(action, "off") && action[0] != EOS)
			{
				ToggleWhitelist(false);
				console("Whitelist turned off.");
			}

			if(!strcmp(action, "auto on") && action[0] != EOS)
			{
				ToggleAutoWhitelist(false);
				console("Automatic whitelist turned off.");
			}

			if(!strcmp(action, "auto off") && action[0] != EOS)
			{
				ToggleAutoWhitelist(false);
				console("Automatic whitelist turned off.");
			}
		}

		return 1;
	}

	return 0;
}
