#define PRINT_SETTINGS


LoadSettings()
{
	print("\nLoading Settings...");


/*
	Setting Loading
*/


	if(fexist(SETTINGS_FILE))
	{
		new tmp[64];

		// server

		strcat(gMessageOfTheDay, dj(SETTINGS_FILE, "server/motd"));
		strcat(gWebsiteURL, dj(SETTINGS_FILE, "server/website"));

		for(new i, j = djCount(SETTINGS_FILE, "server/infomsgs"); i < j; i++)
		{
			if(i >= MAX_INFO_MESSAGE)
			{
				print("ERROR: MAX_INFO_MESSAGE limit reached while loading infomsgs from '"SETTINGS_FILE"'.");
				break;
			}

			format(tmp, sizeof(tmp), "server/infomsgs/%d", i);
			strcat(gInfoMessage[i], dj(SETTINGS_FILE, tmp));
			gTotalInfoMessage++;
		}

		for(new i, j = djCount(SETTINGS_FILE, "server/rules"); i < j; i++)
		{
			if(i >= MAX_RULE)
			{
				print("ERROR: MAX_RULE limit reached while loading rules from '"SETTINGS_FILE"'.");
				break;
			}

			format(tmp, sizeof(tmp), "server/rules/%d", i);
			strcat(gRuleList[i], dj(SETTINGS_FILE, tmp));
			gTotalRules++;
		}

		for(new i, j = djCount(SETTINGS_FILE, "server/staff"); i < j; i++)
		{
			if(i >= MAX_STAFF)
			{
				print("ERROR: MAX_STAFF limit reached while loading staff from '"SETTINGS_FILE"'.");
				break;
			}

			format(tmp, sizeof(tmp), "server/staff/%d", i);
			strcat(gStaffList[i], dj(SETTINGS_FILE, tmp));
			gTotalStaff++;
		}

		gWhitelist = bool:djInt(SETTINGS_FILE, "server/whitelist");
		gInfoMessageInterval = djInt(SETTINGS_FILE, "server/infomsg-interval");
		gPerformFileCheck = djInt(SETTINGS_FILE, "server/file-check");

		// player

		gPauseMap = bool:djInt(SETTINGS_FILE, "player/allow-pause-map");
		gInteriorEntry = bool:djInt(SETTINGS_FILE, "player/interior-entry");
		gPlayerAnimations = bool:djInt(SETTINGS_FILE, "player/player-animations");
		gVehicleSurfing = bool:djInt(SETTINGS_FILE, "player/vehicle-surfing");
		gNameTagDistance = djFloat(SETTINGS_FILE, "player/nametag-distance");
		gCombatLogWindow = djInt(SETTINGS_FILE, "player/combat-log-window");
		gLoginFreezeTime = djInt(SETTINGS_FILE, "player/login-freeze-time");
		gMaxTaboutTime = djInt(SETTINGS_FILE, "player/max-tab-out-time");
		gPingLimit = djInt(SETTINGS_FILE, "player/ping-limit");
	}
	else
	{
		print("ERROR: Settings file '"SETTINGS_FILE"' not found. Creating with default values.");

		djCreateFile(SETTINGS_FILE);
		djStyled(true);
		// Speed isn't an issue here, and this file should be easy on the eye.

		gMessageOfTheDay		= "Please update the 'server/motd' string in "SETTINGS_FILE"";
		gWebsiteURL				= "southclawjk.wordpress.com";
		gInfoMessage[0]			= "(info 1) Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.";
		gInfoMessage[1]			= "(info 2) Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.";
		gInfoMessage[2]			= "(info 3) Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.";
		gTotalInfoMessage		= 3;
		gRuleList[0]			= "(Rule 1) Please update the 'server/rules' array in '"SETTINGS_FILE"'.";
		gRuleList[1]			= "(Rule 2) Please update the 'server/rules' array in '"SETTINGS_FILE"'.";
		gRuleList[2]			= "(Rule 3) Please update the 'server/rules' array in '"SETTINGS_FILE"'.";
		gTotalRules				= 3;
		gStaffList[0]			= "(Staff 1)";
		gStaffList[1]			= "(Staff 2)";
		gStaffList[2]			= "(Staff 3)";
		gTotalStaff				= 3;
		gWhitelist				= false;
		gInfoMessageInterval	= 5;
		gPerformFileCheck		= false;

		gPauseMap				= false;
		gInteriorEntry			= false;
		gPlayerAnimations		= true;
		gVehicleSurfing			= false;
		gNameTagDistance		= 3.0;
		gCombatLogWindow		= 10;
		gLoginFreezeTime		= 5;
		gMaxTaboutTime			= 60;
		gPingLimit				= 400;

		djAutocommit(false);

		djSet(SETTINGS_FILE, "server/motd", gMessageOfTheDay);
		djSet(SETTINGS_FILE, "server/website", gWebsiteURL);
		djAppend(SETTINGS_FILE, "server/infomsgs", gInfoMessage[0]);
		djAppend(SETTINGS_FILE, "server/infomsgs", gInfoMessage[1]);
		djAppend(SETTINGS_FILE, "server/infomsgs", gInfoMessage[2]);
		djAppend(SETTINGS_FILE, "server/rules", gRuleList[0]);
		djAppend(SETTINGS_FILE, "server/rules", gRuleList[1]);
		djAppend(SETTINGS_FILE, "server/rules", gRuleList[2]);
		djAppend(SETTINGS_FILE, "server/staff", gStaffList[0]);
		djAppend(SETTINGS_FILE, "server/staff", gStaffList[1]);
		djAppend(SETTINGS_FILE, "server/staff", gStaffList[2]);
		djSetInt(SETTINGS_FILE, "server/whitelist", gWhitelist);
		djSetInt(SETTINGS_FILE, "server/infomsg-interval", gInfoMessageInterval);
		djSetInt(SETTINGS_FILE, "server/file-check", gPerformFileCheck);

		djSetInt(SETTINGS_FILE, "player/allow-pause-map", gPauseMap);
		djSetInt(SETTINGS_FILE, "player/interior-entry", gInteriorEntry);
		djSetInt(SETTINGS_FILE, "player/player-animations", gPlayerAnimations);
		djSetInt(SETTINGS_FILE, "player/vehicle-surfing", gVehicleSurfing);
		djSetFloat(SETTINGS_FILE, "player/nametag-distance", gNameTagDistance);
		djSetInt(SETTINGS_FILE, "player/combat-log-window", gCombatLogWindow);
		djSetInt(SETTINGS_FILE, "player/login-freeze-time", gLoginFreezeTime);
		djSetInt(SETTINGS_FILE, "player/max-tab-out-time", gMaxTaboutTime);
		djSetInt(SETTINGS_FILE, "player/ping-limit", gPingLimit);

		djCommit(SETTINGS_FILE);
		djAutocommit(true);
	}


#if defined PRINT_SETTINGS

	printf(" MoTD: %s", gMessageOfTheDay);
	printf(" Web URL: %s", gWebsiteURL);

	for(new i; i < gTotalInfoMessage; i++)
		printf(" Info%d: %s", i, gInfoMessage[i]);

	for(new i; i < gTotalRules; i++)
		printf(" Rule%d: %s", i, gRuleList[i]);

	for(new i; i < gTotalStaff; i++)
		printf(" Staff%d: %s", i, gStaffList[i]);

	printf(" Whitelist: %d", gWhitelist);
	printf(" InfoMsg Interval: %d", gInfoMessageInterval);
	printf(" File Check: %d", gPerformFileCheck);

	printf(" Pause Map: %d", gPauseMap);
	printf(" Interior Entry: %d", gInteriorEntry);
	printf(" Player Animations: %d", gPlayerAnimations);
	printf(" Vehicle Surfing: %d", gVehicleSurfing);
	printf(" Name Distance: %f", gNameTagDistance);
	printf(" Combat Log Window: %d", gCombatLogWindow);
	printf(" Login Freeze Time: %d", gLoginFreezeTime);
	printf(" Max Tab-out Time: %d", gMaxTaboutTime);
	printf(" Max Ping: %d", gPingLimit);

#endif


/*
	Setting Assignment
*/


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
