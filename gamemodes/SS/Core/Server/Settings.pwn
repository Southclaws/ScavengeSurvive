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

	djStyled(true);

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
	if(!djIsSet(SETTINGS_FILE, path))
		djSetInt(SETTINGS_FILE, path, defaultvalue), output = defaultvalue;

	else
		output = djInt(SETTINGS_FILE, path);

	if(printsetting)
		printf("  %s: %d", path, output);
}

stock GetSettingFloat(path[], Float:defaultvalue, &Float:output, printsetting = true)
{
	if(!djIsSet(SETTINGS_FILE, path))
		djSetFloat(SETTINGS_FILE, path, defaultvalue), output = defaultvalue;

	else
		output = djFloat(SETTINGS_FILE, path);

	if(printsetting)
		printf("  %s: %f", path, output);
}

stock GetSettingString(path[], defaultvalue[], output[], maxsize = sizeof(output), printsetting = true)
{
	if(!djIsSet(SETTINGS_FILE, path))
		djSet(SETTINGS_FILE, path, defaultvalue), strcat(output, defaultvalue, maxsize);

	else
		strcat(output, dj(SETTINGS_FILE, path), maxsize);

	if(printsetting)
		printf("  %s: %s", path, output);
}


/*
	Arrays
*/

stock GetSettingIntArray(path[], defaultvalues[], defaultmax, output[], &outputtotal, printsetting = true)
{
	if(!djIsSet(SETTINGS_FILE, path))
	{
		new tmpvalue[12];

		for(new i; i < defaultmax; i++)
		{
			format(tmpvalue, sizeof(tmpvalue), "%d", defaultvalues[i]);
			djAppend(SETTINGS_FILE, path, tmpvalue);
			output[i] = defaultvalues[i];

			if(printsetting)
				printf("  %s/%d: %d", path, i, output[i]);
		}
	}
	else
	{
		new tmppath[64];

		outputtotal = djCount(SETTINGS_FILE, path);
		printf("int array size %d, '%s'", outputtotal, path);

		for(new i; i < outputtotal; i++)
		{
			format(tmppath, sizeof(tmppath), "%s/%d", path, i);
			output[i] = djInt(SETTINGS_FILE, tmppath);

			if(printsetting)
				printf("  %s: %d", tmppath, output[i]);
		}
	}
}

stock GetSettingFloatArray(path[], Float:defaultvalues[], defaultmax, Float:output[], &outputtotal, printsetting = true)
{
	if(!djIsSet(SETTINGS_FILE, path))
	{
		new tmpvalue[12];

		for(new i; i < defaultmax; i++)
		{
			format(tmpvalue, sizeof(tmpvalue), "%f", defaultvalues[i]);
			djAppend(SETTINGS_FILE, path, tmpvalue);
			output[i] = defaultvalues[i];

			if(printsetting)
				printf("  %s/%d: %f", path, i, output[i]);
		}
	}
	else
	{
		new tmppath[64];

		outputtotal = djCount(SETTINGS_FILE, path);
		printf("float array size %d, '%s'", outputtotal, path);

		for(new i; i < outputtotal; i++)
		{
			format(tmppath, sizeof(tmppath), "%s/%d", path, i);
			output[i] = djFloat(SETTINGS_FILE, tmppath);

			if(printsetting)
				printf("  %s: %f", tmppath, output[i]);
		}
	}
}

stock GetSettingStringArray(path[], defaultvalues[][], defaultmax, output[][], &outputtotal, printsetting = true)
{
	if(!djIsSet(SETTINGS_FILE, path))
	{
		for(new i; i < defaultmax; i++)
		{
			djAppend(SETTINGS_FILE, path, defaultvalues[i]);
			format(output[i], DJSON_MAX_STRING, defaultvalues[i]);

			if(printsetting)
				printf("  %s/%d: %s", path, i, output[i]);
		}
	}
	else
	{
		new tmppath[64];

		outputtotal = djCount(SETTINGS_FILE, path);
		printf("string array size %d, '%s'", outputtotal, path);

		for(new i; i < outputtotal; i++)
		{
			format(tmppath, sizeof(tmppath), "%s/%d", path, i);
			format(output[i], DJSON_MAX_STRING, dj(SETTINGS_FILE, tmppath));

			if(printsetting)
				printf("  %s: %s", tmppath, output[i]);
		}
	}
}

stock UpdateSettingInt(path[], value)
{
	djSetInt(SETTINGS_FILE, path, value);
}

stock UpdateSettingFloat(path[], Float:value)
{
	djSetFloat(SETTINGS_FILE, path, value);
}

stock UpdateSettingString(path[], value[])
{
	djSet(SETTINGS_FILE, path, value);
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
