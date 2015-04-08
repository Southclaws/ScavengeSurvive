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

	if(!json_get_node(json, path))
		printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot auto-write default value %d.", defaultvalue);

	else
		output = json_get_int(json, path);

	if(printsetting)
		printf("%s: %d", path, output);

	json_close(json);
}

stock GetSettingFloat(path[], Float:defaultvalue, &Float:output, printsetting = true)
{
	new JSONNode:json = JSONNode:json_parse_file(SETTINGS_FILE);

	if(!json_get_node(json, path))
		printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot auto-write default value %f.", defaultvalue);

	else
		output = json_get_float(json, path);

	if(printsetting)
		printf("%s: %f", path, output);

	json_close(json);
}

stock GetSettingString(path[], defaultvalue[], output[], maxsize = sizeof(output), printsetting = true)
{
	new JSONNode:json = JSONNode:json_parse_file(SETTINGS_FILE);

	if(!json_get_node(json, path))
		printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot auto-write default value '%s'.", defaultvalue);

	else
		json_get_string(json, output, maxsize, path);

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

	if(!json_get_node(json, path))
	{
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

	if(!json_get_node(json, path))
	{
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

	if(!json_get_node(json, path))
	{
		printf("WARNING: JSON writing currently not supported by KingHual's plugin! Cannot auto-write default values %d %s.", defaultmax, defaultvalues);
	}
	else
	{
		new JSONArray:jsonarray = json_get_array(json, path);

		outputtotal = json_array_count(jsonarray);
		printf("string array size %d, '%s'", outputtotal, path);

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
