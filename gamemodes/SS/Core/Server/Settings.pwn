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
		strcat(gGameModeName, dj(SETTINGS_FILE, "server/gamemodename"));

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

		gWhitelist = bool:djInt(SETTINGS_FILE, "server/whitelist");

		// player

		gPauseMap = bool:djInt(SETTINGS_FILE, "player/allow-pause-map");
		gInteriorEntry = bool:djInt(SETTINGS_FILE, "player/interior-entry");
		gPlayerAnimations = bool:djInt(SETTINGS_FILE, "player/player-animations");
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

		gMessageOfTheDay	= "Please update the 'server/motd' string in "SETTINGS_FILE"";
		gWebsiteURL			= "southclawjk.wordpress.com";
		gGameModeName		= "Southclaw's Scavenge + Survive";
		gInfoMessage[0]		= "(info 1) Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.";
		gInfoMessage[1]		= "(info 2) Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.";
		gInfoMessage[2]		= "(info 3) Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.";
		gWhitelist			= false;
		gPauseMap			= false;
		gInteriorEntry		= false;
		gPlayerAnimations	= true;
		gNameTagDistance	= 3.0;
		gCombatLogWindow	= 10;
		gLoginFreezeTime	= 5;
		gMaxTaboutTime		= 60;
		gPingLimit			= 400;

		djAutocommit(false);

		djSet(SETTINGS_FILE, "server/motd", gMessageOfTheDay);
		djSet(SETTINGS_FILE, "server/website", gWebsiteURL);
		djSet(SETTINGS_FILE, "server/gamemodename", gGameModeName);
		djAppend(SETTINGS_FILE, "server/infomsgs", gInfoMessage[0]);
		djAppend(SETTINGS_FILE, "server/infomsgs", gInfoMessage[1]);
		djAppend(SETTINGS_FILE, "server/infomsgs", gInfoMessage[2]);
		djSetInt(SETTINGS_FILE, "server/whitelist", gWhitelist);

		djSetInt(SETTINGS_FILE, "player/allow-pause-map", gPauseMap);
		djSetInt(SETTINGS_FILE, "player/interior-entry", gInteriorEntry);
		djSetInt(SETTINGS_FILE, "player/player-animations", gPlayerAnimations);
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
	printf(" Game Mode Name: %s", gGameModeName);

	for(new i; i < gTotalInfoMessage; i++)
		printf(" Info%d: %s", i, gInfoMessage[i]);

	printf(" Whitelist: %d", gWhitelist);

	printf(" Pause Map: %d", gPauseMap);
	printf(" Interior Entry: %d", gInteriorEntry);
	printf(" Player Animations: %d", gPlayerAnimations);
	printf(" Name Distance: %f", gNameTagDistance);
	printf(" Combat Log Window: %d", gCombatLogWindow);
	printf(" Login Freeze Time: %d", gLoginFreezeTime);
	printf(" Max Tab-out Time: %d", gMaxTaboutTime);
	printf(" Max Ping: %d", gPingLimit);

#endif


/*
	Setting Assignment
*/


	SetGameModeText(gGameModeName);

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
