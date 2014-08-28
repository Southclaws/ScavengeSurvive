#define PRINT_SETTINGS


LoadSettings()
{
	print("\nLoading Settings...");


/*
	Setting Loading
*/


	if(!fexist(SETTINGS_FILE))
	{
		print("ERROR: Settings file '"SETTINGS_FILE"' not found. Creating with default values.");

		djCreateFile(SETTINGS_FILE);
	}

	djStyled(true);

	new tmp[64];


	// server/motd
	if(!djIsSet(SETTINGS_FILE, "server/motd"))
		djSet(SETTINGS_FILE, "server/motd", "Please update the 'server/motd' string in "SETTINGS_FILE"");

	strcat(gMessageOfTheDay, dj(SETTINGS_FILE, "server/motd"));
	printf("  server/motd: %s", gMessageOfTheDay);


	// server/website
	if(!djIsSet(SETTINGS_FILE, "server/website"))
		djSet(SETTINGS_FILE, "server/website", "southclawjk.wordpress.com");

	strcat(gWebsiteURL, dj(SETTINGS_FILE, "server/website"));
	printf("  server/website: %s", gWebsiteURL);


	// server/infomsgs
	if(!djIsSet(SETTINGS_FILE, "server/infomsgs"))
		djAppend(SETTINGS_FILE, "server/infomsgs", "(info 1) Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.");

	for(new i, j = djCount(SETTINGS_FILE, "server/infomsgs"); i < j; i++)
	{
		if(i >= MAX_INFO_MESSAGE)
		{
			print("ERROR: MAX_INFO_MESSAGE limit reached while loading infomsgs from '"SETTINGS_FILE"'.");
			break;
		}

		format(tmp, sizeof(tmp), "server/infomsgs/%d", i);
		strcat(gInfoMessage[i], dj(SETTINGS_FILE, tmp));
		printf("  %s: %s", tmp, gInfoMessage[i]);
		gTotalInfoMessage++;
	}


	// server/rules
	if(!djIsSet(SETTINGS_FILE, "server/rules"))
		djAppend(SETTINGS_FILE, "server/rules", "(Rule 1) Please update the 'server/rules' array in '"SETTINGS_FILE"'.");

	for(new i, j = djCount(SETTINGS_FILE, "server/rules"); i < j; i++)
	{
		if(i >= MAX_RULE)
		{
			print("ERROR: MAX_RULE limit reached while loading rules from '"SETTINGS_FILE"'.");
			break;
		}

		format(tmp, sizeof(tmp), "server/rules/%d", i);
		strcat(gRuleList[i], dj(SETTINGS_FILE, tmp));
		printf("  %s: %s", tmp, gRuleList[i]);
		gTotalRules++;
	}


	// server/staff
	if(!djIsSet(SETTINGS_FILE, "server/staff"))
		djAppend(SETTINGS_FILE, "server/staff", "(Staff 1)");

	for(new i, j = djCount(SETTINGS_FILE, "server/staff"); i < j; i++)
	{
		if(i >= MAX_STAFF)
		{
			print("ERROR: MAX_STAFF limit reached while loading staff from '"SETTINGS_FILE"'.");
			break;
		}

		format(tmp, sizeof(tmp), "server/staff/%d", i);
		strcat(gStaffList[i], dj(SETTINGS_FILE, tmp));
		printf("  %s: %s", tmp, gStaffList[i]);
		gTotalStaff++;
	}


	// server/infomsg-interval
	if(!djIsSet(SETTINGS_FILE, "server/infomsg-interval"))
		djSetInt(SETTINGS_FILE, "server/infomsg-interval", 5);

	gInfoMessageInterval = djInt(SETTINGS_FILE, "server/infomsg-interval");
	printf("  server/infomsg-interval: %d", gInfoMessageInterval);


	// server/max-uptime
	if(!djIsSet(SETTINGS_FILE, "server/max-uptime"))
		djSetInt(SETTINGS_FILE, "server/max-uptime", 5);

	gServerMaxUptime = 3600 * djInt(SETTINGS_FILE, "server/max-uptime");
	printf("  server/max-uptime: %d", gServerMaxUptime);



	// player/allow-pause-map
	if(!djIsSet(SETTINGS_FILE, "player/allow-pause-map"))
		djSetInt(SETTINGS_FILE, "player/allow-pause-map", false);

	gPauseMap = bool:djInt(SETTINGS_FILE, "player/allow-pause-map");
	printf("  player/allow-pause-map: %d", gPauseMap);


	// player/interior-entry
	if(!djIsSet(SETTINGS_FILE, "player/interior-entry"))
		djSetInt(SETTINGS_FILE, "player/interior-entry", false);

	gInteriorEntry = bool:djInt(SETTINGS_FILE, "player/interior-entry");
	printf("  player/interior-entry: %d", gInteriorEntry);


	// player/player-animations
	if(!djIsSet(SETTINGS_FILE, "player/player-animations"))
		djSetInt(SETTINGS_FILE, "player/player-animations", true);

	gPlayerAnimations = bool:djInt(SETTINGS_FILE, "player/player-animations");
	printf("  player/player-animations: %d", gPlayerAnimations);


	// player/vehicle-surfing
	if(!djIsSet(SETTINGS_FILE, "player/vehicle-surfing"))
		djSetInt(SETTINGS_FILE, "player/vehicle-surfing", false);

	gVehicleSurfing = bool:djInt(SETTINGS_FILE, "player/vehicle-surfing");
	printf("  player/vehicle-surfing: %d", gVehicleSurfing);


	// player/nametag-distance
	if(!djIsSet(SETTINGS_FILE, "player/nametag-distance"))
		djSetFloat(SETTINGS_FILE, "player/nametag-distance", 3.0);

	gNameTagDistance = djFloat(SETTINGS_FILE, "player/nametag-distance");
	printf("  player/nametag-distance: %f", gNameTagDistance);


	// player/combat-log-window
	if(!djIsSet(SETTINGS_FILE, "player/combat-log-window"))
		djSetInt(SETTINGS_FILE, "player/combat-log-window", 10);

	gCombatLogWindow = djInt(SETTINGS_FILE, "player/combat-log-window");
	printf("  player/combat-log-window: %d", gCombatLogWindow);


	// player/login-freeze-time
	if(!djIsSet(SETTINGS_FILE, "player/login-freeze-time"))
		djSetInt(SETTINGS_FILE, "player/login-freeze-time", 5);

	gLoginFreezeTime = djInt(SETTINGS_FILE, "player/login-freeze-time");
	printf("  player/login-freeze-time: %d", gLoginFreezeTime);


	// player/max-tab-out-time
	if(!djIsSet(SETTINGS_FILE, "player/max-tab-out-time"))
		djSetInt(SETTINGS_FILE, "player/max-tab-out-time", 60);

	gMaxTaboutTime = djInt(SETTINGS_FILE, "player/max-tab-out-time");
	printf("  player/max-tab-out-time: %d", gMaxTaboutTime);


	// player/ping-limit
	if(!djIsSet(SETTINGS_FILE, "player/ping-limit"))
		djSetInt(SETTINGS_FILE, "player/ping-limit", 400);

	gPingLimit = djInt(SETTINGS_FILE, "player/ping-limit");
	printf("  player/ping-limit: %d", gPingLimit);


	// I'd appreciate if you left my credit and the proper gamemode name intact!
	SetGameModeText("Scavenge Survive by Southclaw");

	if(!gPauseMap)
		MiniMapOverlay = GangZoneCreate(-6000, -6000, 6000, 6000);

	if(!gInteriorEntry)
		DisableInteriorEnterExits();

	if(gPlayerAnimations)
		UsePlayerPedAnims();

	SetNameTagDrawDistance(gNameTagDistance);


/*
	Defaults
*/


	EnableStuntBonusForAll(false);
	ManualVehicleEngineAndLights();
	AllowInteriorWeapons(true);

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
