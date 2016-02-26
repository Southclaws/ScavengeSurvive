LoadSettings()
{
	print("\nLoading Settings...");


/*
	Setting Loading
*/


	if(!fexist(SETTINGS_FILE))
	{
		print("ERROR: Settings file '"SETTINGS_FILE"' not found. Creating and using default values.");

		fclose(fopen(SETTINGS_FILE, io_write));
	}

	GetSettingString("server/motd", "Please update the 'server/motd' string in "SETTINGS_FILE"", gMessageOfTheDay);
	GetSettingString("server/website", "southclawjk.wordpress.com", gWebsiteURL);
	GetSettingInt("server/crash-on-exit", true, gCrashOnExit);

	GetSettingStringArray("server/rules", "Please update the 'server/rules' array in '"SETTINGS_FILE"'.", MAX_RULE, gRuleList, gTotalRules, MAX_RULE_LEN);
	GetSettingStringArray("server/staff", "StaffName", 3, gStaffList, gTotalStaff, MAX_STAFF_LEN);

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

	print("\n");
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
			printf("[DEFAULT] %s: %d", path, output);
	}
	else
	{
		output = file_GetVal(path);

		if(printsetting)
			printf("[LOAD] %s: %d", path, output);
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
			printf("[DEFAULT] %s: %f", path, output);
	}
	else
	{
		output = file_GetFloat(path);

		if(printsetting)
			printf("[LOAD] %s: %f", path, output);
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
			printf("[DEFAULT] %s: %s", path, output);
	}
	else
	{
		file_GetStr(path, output, maxsize);

		if(printsetting)
			printf("[LOAD] %s: %s", path, output);
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
				printf("ERROR: key '%s' not found.", tmpkey);

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
				printf("ERROR: key '%s' not found.", tmpkey);

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
				printf("ERROR: key '%s' not found.", tmpkey);
				output[0][0] = EOS;
				strcat(output[0], defaultvalue, outputmaxsize);
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

stock UpdateSettingArrayAppend(path[], value[])
{
	djAppend(SETTINGS_FILE, path, value);
}



#endinput
LoadSettings()
{
	print("\nLoading Settings...");


/*
	Setting Loading
*/


	if(!fexist(SETTINGS_FILE))
	{
		print("ERROR: Settings file '"SETTINGS_FILE"' not found. Creating and using default values.");

		fclose(fopen(SETTINGS_FILE, io_write));
	}

	GetSettingString("server/motd", "Please update the 'server/motd' string in "SETTINGS_FILE"", gMessageOfTheDay);
	GetSettingString("server/website", "southclawjk.wordpress.com", gWebsiteURL);

	gRuleList[0] = "(Rule 1) Please update the 'server/rules' array in '"SETTINGS_FILE"'.";
	gRuleList[1] = "(Rule 2) Please update the 'server/rules' array in '"SETTINGS_FILE"'.";
	gRuleList[2] = "(Rule 3) Please update the 'server/rules' array in '"SETTINGS_FILE"'.";
	GetSettingStringArray("server/rules", gRuleList, 3, gRuleList, gTotalRules, MAX_RULE_LEN);

	gStaffList[0] = "(Staff 1)";
	gStaffList[1] = "(Staff 2)";
	gStaffList[2] = "(Staff 3)";
	GetSettingStringArray("server/staff", gStaffList, 3, gStaffList, gTotalStaff, MAX_STAFF_LEN);

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
	SetGameModeText("Scavenge Survive by Southclaw");

	print("\n");
}

stock GetSettingInt(path[], defaultvalue, &output, printsetting = true)
{
	new JSONNode:json = JSONNode:json_parse_file(SETTINGS_FILE);

	printf("[JSON] type of '%s' is %d", path, json_get_type(json, path));

	if(json_get_type(json, path) != JSON_NUMBER)
	{
		output = defaultvalue;
		printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot auto-write default value %d.", defaultvalue);
	}
	else
	{
		output = json_get_int(json, path);
	}

	if(printsetting)
		printf("%s: %d", path, output);

	json_close(json);
}

stock GetSettingFloat(path[], Float:defaultvalue, &Float:output, printsetting = true)
{
	new JSONNode:json = JSONNode:json_parse_file(SETTINGS_FILE);

	printf("[JSON] type of '%s' is %d", path, json_get_type(json, path));

	if(json_get_type(json, path) != JSON_NUMBER)
	{
		output = defaultvalue;
		printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot auto-write default value %f.", defaultvalue);
	}
	else
	{
		output = json_get_float(json, path);
	}

	if(printsetting)
		printf("%s: %f", path, output);

	json_close(json);
}

stock GetSettingString(path[], defaultvalue[], output[], maxsize = sizeof(output), printsetting = true)
{
	new JSONNode:json = JSONNode:json_parse_file(SETTINGS_FILE);

	printf("[JSON] type of '%s' is %d", path, json_get_type(json, path));

	if(json_get_type(json, path) != JSON_STRING)
	{
		output[0] = EOS;
		strcat(output, defaultvalue, maxsize);
		printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot auto-write default value '%s'.", defaultvalue);
	}
	else
	{
		json_get_string(json, output, maxsize, path);
	}

	if(printsetting)
		printf("%s: %s", path, output);

	json_close(json);
}


/*
	Arrays
*/

stock GetSettingIntArray(path[], defaultvalues[], defaultmax, output[], &outputtotal, printsetting = true)
{
	new JSONNode:json = JSONNode:json_parse_file(SETTINGS_FILE);

	printf("[JSON] type of '%s' is %d", path, json_get_type(json, path));

	if(json_get_type(json, path) != JSON_ARRAY)
	{
		for(new i; i < defaultmax; i++)
			output[i] = defaultvalues[i];

		outputtotal = defaultmax;
		printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot auto-write default values %d %s.", defaultmax, defaultvalues);
	}
	else
	{
		new JSONArray:jsonarray = json_get_array(json, path);

		outputtotal = json_array_count(jsonarray);
		printf("int array size %d, '%s'", outputtotal, path);

		for(new i; i < outputtotal; i++)
		{
			json = json_array_at(jsonarray, i);
			output[i] = json_get_int(json);

			if(printsetting)
				printf("%s[%d]: %d", path, i, output[i]);
		}
	}

	json_close(json);
}

stock GetSettingFloatArray(path[], Float:defaultvalues[], defaultmax, Float:output[], &outputtotal, printsetting = true)
{
	new JSONNode:json = JSONNode:json_parse_file(SETTINGS_FILE);

	printf("[JSON] type of '%s' is %d", path, json_get_type(json, path));

	if(json_get_type(json, path) != JSON_ARRAY)
	{
		for(new i; i < defaultmax; i++)
			output[i] = defaultvalues[i];

		outputtotal = defaultmax;
		printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot auto-write default values %d %s.", defaultmax, defaultvalues);
	}
	else
	{
		new JSONArray:jsonarray = json_get_array(json, path);

		outputtotal = json_array_count(jsonarray);
		printf("float array size %d, '%s'", outputtotal, path);

		for(new i; i < outputtotal; i++)
		{
			json = json_array_at(jsonarray, i);
			output[i] = json_get_float(json);

			if(printsetting)
				printf("%s[%d]: %f", path, i, output[i]);
		}
	}

	json_close(json);
}

stock GetSettingStringArray(path[], defaultvalues[][], defaultmax, output[][], &outputtotal, outputsize, printsetting = true)
{
	new JSONNode:json = JSONNode:json_parse_file(SETTINGS_FILE);

	printf("[JSON] type of '%s' is %d", path, json_get_type(json, path));

	if(json_get_type(json, path) != JSON_ARRAY)
	{
		for(new i; i < defaultmax; i++)
			strcat(output[i], defaultvalues[i], outputsize);

		outputtotal = defaultmax;
		printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot auto-write default values %d %s.", defaultmax, defaultvalues);
	}
	else
	{
		new JSONArray:jsonarray = json_get_array(json, path);

		outputtotal = json_array_count(jsonarray);

		for(new i; i < outputtotal; i++)
		{
			json = json_array_at(jsonarray, i);
			json_get_string(json, output[i], outputsize);

			if(printsetting)
				printf("%s[%d]: %s", path, i, output[i]);
		}
	}

	json_close(json);
}

stock UpdateSettingInt(path[], value)
{
	printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot write %s: %d.", path, value);
}

stock UpdateSettingFloat(path[], Float:value)
{
	printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot write %s: %d.", path, value);
}

stock UpdateSettingString(path[], value[])
{
	printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot write %s: %d.", path, value);
}
