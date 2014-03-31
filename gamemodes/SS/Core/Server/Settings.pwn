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


	// server/whitelist
	if(!djIsSet(SETTINGS_FILE, "server/whitelist"))
		djSetInt(SETTINGS_FILE, "server/whitelist", false);

	gWhitelist = bool:djInt(SETTINGS_FILE, "server/whitelist");
	printf("  server/whitelist: %d", gWhitelist);


	// server/whitelist-auto-toggle
	if(!djIsSet(SETTINGS_FILE, "server/whitelist-auto-toggle"))
		djSetInt(SETTINGS_FILE, "server/whitelist-auto-toggle", false);

	gWhitelistAutoToggle = bool:djInt(SETTINGS_FILE, "server/whitelist-auto-toggle");
	printf("  server/whitelist-auto-toggle: %d", gWhitelistAutoToggle);


	// server/infomsg-interval
	if(!djIsSet(SETTINGS_FILE, "server/infomsg-interval"))
		djSetInt(SETTINGS_FILE, "server/infomsg-interval", 5);

	gInfoMessageInterval = djInt(SETTINGS_FILE, "server/infomsg-interval");
	printf("  server/infomsg-interval: %d", gInfoMessageInterval);


	// server/file-check
	if(!djIsSet(SETTINGS_FILE, "server/file-check"))
		djSetInt(SETTINGS_FILE, "server/file-check", false);

	gPerformFileCheck = djInt(SETTINGS_FILE, "server/file-check");
	printf("  server/file-check: %d", gPerformFileCheck);


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
