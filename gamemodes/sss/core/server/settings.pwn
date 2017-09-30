/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


LoadSettings()
{
	if(!fexist(SETTINGS_FILE))
	{
		err("Settings file '"SETTINGS_FILE"' not found. Creating and using default values.");

		fclose(fopen(SETTINGS_FILE, io_write));
	}

	GetSettingString("server/motd", "Please update the 'server/motd' string in "SETTINGS_FILE"", gMessageOfTheDay);
	GetSettingString("server/website", "southclawjk.wordpress.com", gWebsiteURL);
	GetSettingInt("server/crash-on-exit", true, gCrashOnExit);

	GetSettingStringArray("server/rules", "Please update the 'server/rules' array in '"SETTINGS_FILE"'.", MAX_RULE, gRuleList, gTotalRules, MAX_RULE_LEN);
	GetSettingStringArray("server/staff", "StaffName", MAX_STAFF, gStaffList, gTotalStaff, MAX_STAFF_LEN);

	GetSettingInt("server/max-uptime", 18000, gServerMaxUptime);
	GetSettingInt("player/allow-pause-map", 0, gPauseMap);
	GetSettingInt("player/interior-entry", 0, gInteriorEntry);
	GetSettingInt("player/player-animations", 1, gPlayerAnimations);
	GetSettingInt("player/vehicle-surfing", 0, gVehicleSurfing);
	GetSettingFloat("player/nametag-distance", 3.0, gNameTagDistance);
	GetSettingInt("player/combat-log-window", 30, gCombatLogWindow);
	GetSettingInt("player/login-freeze-time", 8, gLoginFreezeTime);
	GetSettingInt("player/max-tab-out-time", 60, gMaxTaboutTime);
	GetSettingInt("player/ping-limit", 400, gPingLimit);

	// I'd appreciate if you left my credit and the proper gamemode name intact!
	// Failure to do this will result in being blacklisted from the server list.
	// And I'll be less inclined to help you with issues.
	// Unless you have a decent reason to change the gamemode name (heavy mod)
	// I'd still like to be credited for my work. Many servers have claimed
	// they are the sole creator of the mode and this makes me sad and very
	// hesitant to release my work completely free of charge.
	SetGameModeText("Scavenge Survive by Southclaw");
}


stock GetSettingInt(path[], defaultvalue, &output, printsetting = true, openfile = true)
{
	if(openfile)
		file_Open(SETTINGS_FILE);

	if(!file_IsKey(path))
	{
		file_SetVal(path, defaultvalue);
		output = defaultvalue;
		file_Save(SETTINGS_FILE);

		if(printsetting)
			log("[DEFAULT] %s: %d", path, output);
	}
	else
	{
		output = file_GetVal(path);

		if(printsetting)
			log("[SETTING] %s: %d", path, output);
	}

	if(openfile)
		file_Close();
}

stock GetSettingFloat(path[], Float:defaultvalue, &Float:output, printsetting = true, openfile = true)
{
	if(openfile)
		file_Open(SETTINGS_FILE);

	if(!file_IsKey(path))
	{
		file_SetFloat(path, defaultvalue);
		output = defaultvalue;
		file_Save(SETTINGS_FILE);

		if(printsetting)
			log("[DEFAULT] %s: %f", path, output);
	}
	else
	{
		output = file_GetFloat(path);

		if(printsetting)
			log("[SETTING] %s: %f", path, output);
	}

	if(openfile)
		file_Close();
}

stock GetSettingString(path[], defaultvalue[], output[], maxsize = sizeof(output), printsetting = true, openfile = true)
{
	if(openfile)
		file_Open(SETTINGS_FILE);

	if(!file_IsKey(path))
	{
		file_SetStr(path, defaultvalue);
		output[0] = EOS;
		strcat(output, defaultvalue, maxsize);
		file_Save(SETTINGS_FILE);

		if(printsetting)
			log("[DEFAULT] %s: %s", path, output);
	}
	else
	{
		file_GetStr(path, output, maxsize);

		if(printsetting)
			log("[SETTING] %s: %s", path, output);
	}

	if(openfile)
		file_Close();
}


/*
	Arrays
*/

stock GetSettingIntArray(path[], defaultvalue, max, output[], &outputtotal, printsetting = true)
{
	file_Open(SETTINGS_FILE);

	new tmpkey[MAX_KEY_LENGTH];

	while(outputtotal < max)
	{
		format(tmpkey, sizeof(tmpkey), "%s/%d", path, outputtotal);

		if(!file_IsKey(tmpkey))
		{
			if(outputtotal == 0)
			{
				file_SetInt(tmpkey, defaultvalue);
				file_Save(SETTINGS_FILE);
				output[0] = defaultvalue;

				if(printsetting)
					log("[DEFAULT] %s: %d", tmpkey, output[0]);
			}

			break;
		}

		GetSettingInt(tmpkey, defaultvalue, output[outputtotal], printsetting, false);

		outputtotal++;
	}

	file_Close();
}

stock GetSettingFloatArray(path[], Float:defaultvalue, max, Float:output[], &outputtotal, printsetting = true)
{
	file_Open(SETTINGS_FILE);

	new tmpkey[MAX_KEY_LENGTH];

	while(outputtotal < max)
	{
		format(tmpkey, sizeof(tmpkey), "%s/%d", path, outputtotal);

		if(!file_IsKey(tmpkey))
		{
			if(outputtotal == 0)
			{
				file_SetFloat(tmpkey, defaultvalue);
				file_Save(SETTINGS_FILE);
				output[0] = defaultvalue;

				if(printsetting)
					log("[DEFAULT] %s: %f", tmpkey, output[0]);
			}

			break;
		}

		GetSettingFloat(tmpkey, defaultvalue, output[outputtotal], printsetting, false);

		outputtotal++;
	}

	file_Close();
}

stock GetSettingStringArray(path[], defaultvalue[], max, output[][], &outputtotal, outputmaxsize, printsetting = true)
{
	file_Open(SETTINGS_FILE);

	new tmpkey[MAX_KEY_LENGTH];

	while(outputtotal < max)
	{
		format(tmpkey, sizeof(tmpkey), "%s/%d", path, outputtotal);

		if(!file_IsKey(tmpkey))
		{
			if(outputtotal == 0)
			{
				file_SetStr(tmpkey, defaultvalue);
				file_Save(SETTINGS_FILE);
				output[0][0] = EOS;
				strcat(output[0], defaultvalue, outputmaxsize);

				if(printsetting)
					log("[DEFAULT] %s: %s", tmpkey, output[0]);
			}

			break;
		}

		GetSettingString(tmpkey, defaultvalue, output[outputtotal], outputmaxsize, printsetting, false);

		outputtotal++;
	}

	file_Close();
}

stock UpdateSettingInt(path[], value)
{
	file_Open(SETTINGS_FILE);
	file_SetVal(path, value);
	file_Save(SETTINGS_FILE);
	file_Close();
}

stock UpdateSettingFloat(path[], Float:value)
{
	file_Open(SETTINGS_FILE);
	file_SetFloat(path, value);
	file_Save(SETTINGS_FILE);
	file_Close();
}

stock UpdateSettingString(path[], value[])
{
	file_Open(SETTINGS_FILE);
	file_SetStr(path, value);
	file_Save(SETTINGS_FILE);
	file_Close();
}
