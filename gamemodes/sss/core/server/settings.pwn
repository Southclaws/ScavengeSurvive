/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 "Southclaws" Keene

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
		Logger_Log("settings file not found creating with defaults");

		fclose(fopen(SETTINGS_FILE, io_write));
	}

	GetSettingString("server/motd", "Please update the 'server/motd' string in "SETTINGS_FILE"", gMessageOfTheDay);
	GetSettingString("server/website", "www.southcla.ws", gWebsiteURL);
	GetSettingInt("server/crash-on-exit", false, gCrashOnExit);

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
	SetGameModeText("Scavenge Survive by Southclaws");
}


stock GetSettingInt(const path[], defaultvalue, &output, printsetting = true, openfile = true)
{
	if(openfile)
		ini_open(SETTINGS_FILE);

	if(!ini_isKey(path))
	{
		ini_setInt(path, defaultvalue);
		output = defaultvalue;
		ini_close();

		if(printsetting)
			Logger_Log("Setting default", Logger_S("path", path), Logger_I("output", output));
	}
	else
	{
		ini_getInt(path, output);

		if(printsetting)
			Logger_Log("Setting loaded", Logger_S("path", path), Logger_I("output", output));
	}

	if(openfile)
		ini_close();
}

stock GetSettingFloat(const path[], Float:defaultvalue, &Float:output, printsetting = true, openfile = true)
{
	if(openfile)
		ini_open(SETTINGS_FILE);

	if(!ini_isKey(path))
	{
		ini_setFloat(path, defaultvalue);
		output = defaultvalue;
		ini_close();

		if(printsetting)
			Logger_Log("Setting default", Logger_S("path", path), Logger_F("output", output));
	}
	else
	{
		ini_getFloat(path, output);

		if(printsetting)
			Logger_Log("Setting loaded", Logger_S("path", path), Logger_F("output", output));
	}

	if(openfile)
		ini_close();
}

stock GetSettingString(const path[], const defaultvalue[], output[], maxsize = sizeof(output), printsetting = true, openfile = true)
{
	if(openfile)
		ini_open(SETTINGS_FILE);

	if(!ini_isKey(path))
	{
		ini_setString(path, defaultvalue);
		output[0] = EOS;
		strcat(output, defaultvalue, maxsize);
		ini_close();

		if(printsetting)
			Logger_Log("Setting default", Logger_S("path", path), Logger_S("output", output));
	}
	else
	{
		ini_getString(path, output, maxsize);

		if(printsetting)
			Logger_Log("Setting loaded", Logger_S("path", path), Logger_S("output", output));
	}

	if(openfile)
		ini_close();
}


/*
	Arrays
*/

stock GetSettingIntArray(const path[], defaultvalue, max, output[], &outputtotal, printsetting = true)
{
	ini_open(SETTINGS_FILE);

	new tmpkey[MAX_KEY_LENGTH];

	while(outputtotal < max)
	{
		format(tmpkey, sizeof(tmpkey), "%s/%d", path, outputtotal);

		if(!ini_isKey(tmpkey))
		{
			if(outputtotal == 0)
			{
				ini_setInt(tmpkey, defaultvalue);
				ini_close();
				output[0] = defaultvalue;

				if(printsetting)
					Logger_Log("Setting default", Logger_S("key", tmpkey), Logger_S("value", output[0]));
			}

			break;
		}

		GetSettingInt(tmpkey, defaultvalue, output[outputtotal], printsetting, false);

		outputtotal++;
	}

	ini_close();
}

stock GetSettingFloatArray(const path[], Float:defaultvalue, max, Float:output[], &outputtotal, printsetting = true)
{
	ini_open(SETTINGS_FILE);

	new tmpkey[MAX_KEY_LENGTH];

	while(outputtotal < max)
	{
		format(tmpkey, sizeof(tmpkey), "%s/%d", path, outputtotal);

		if(!ini_isKey(tmpkey))
		{
			if(outputtotal == 0)
			{
				ini_setFloat(tmpkey, defaultvalue);
				ini_close();
				output[0] = defaultvalue;

				if(printsetting)
					Logger_Log("Setting default", Logger_S("key", tmpkey), Logger_S("value", output[0]));
			}

			break;
		}

		GetSettingFloat(tmpkey, defaultvalue, output[outputtotal], printsetting, false);

		outputtotal++;
	}

	ini_close();
}

stock GetSettingStringArray(const path[], const defaultvalue[], max, output[][], &outputtotal, outputmaxsize, printsetting = true)
{
	ini_open(SETTINGS_FILE);

	new tmpkey[MAX_KEY_LENGTH];

	while(outputtotal < max)
	{
		format(tmpkey, sizeof(tmpkey), "%s/%d", path, outputtotal);

		if(!ini_isKey(tmpkey))
		{
			if(outputtotal == 0)
			{
				ini_setString(tmpkey, defaultvalue);
				ini_close();
				output[0][0] = EOS;
				strcat(output[0], defaultvalue, outputmaxsize);

				if(printsetting)
					Logger_Log("Setting default", Logger_S("key", tmpkey), Logger_S("value", output[0]));
			}

			break;
		}

		GetSettingString(tmpkey, defaultvalue, output[outputtotal], outputmaxsize, printsetting, false);

		outputtotal++;
	}

	ini_close();
}

stock UpdateSettingInt(const path[], value)
{
	ini_open(SETTINGS_FILE);
	ini_setInt(path, value);
	ini_close();
	ini_close();
}

stock UpdateSettingFloat(const path[], Float:value)
{
	ini_open(SETTINGS_FILE);
	ini_setFloat(path, value);
	ini_close();
	ini_close();
}

stock UpdateSettingString(const path[], value[])
{
	ini_open(SETTINGS_FILE);
	ini_setString(path, value);
	ini_close();
	ini_close();
}
