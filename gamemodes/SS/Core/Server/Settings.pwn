#define PRINT_SETTINGS


LoadSettings()
{
	print("\nLoading Settings...");


/*
	Setting Loading
*/

	if(fexist(SETTINGS_FILE))
	{
		INI_Load(SETTINGS_FILE);
	}
	else
	{
		print("ERROR: Settings file '"SETTINGS_FILE"' not found. Creating with default values.");

		new INI:ini = INI_Open(SETTINGS_FILE);

		gMessageOfTheDay	= "Message of the day. Please change this inside "SETTINGS_FILE"";
		gWebsiteURL			= "southclawjk.wordpress.com";
		gGameModeName		= "Southclaw's Scavenge + Survive";
		gWhitelist			= false;
		gPauseMap			= false;
		gInteriorEntry		= false;
		gPlayerAnimations	= true;
		gNameTagDistance	= 3.0;
		gCombatLogWindow	= 10;
		gLoginFreezeTime	= 5;
		gMaxTaboutTime		= 60;
		gPingLimit			= 400;

		INI_WriteString(ini, "motd", gMessageOfTheDay);
		INI_WriteString(ini, "website", gWebsiteURL);
		INI_WriteString(ini, "gamemodename", gGameModeName);

		INI_WriteBool(ini, "whitelist", gWhitelist);
		INI_WriteBool(ini, "allow-pause-map", gPauseMap);
		INI_WriteBool(ini, "interior-entry", gInteriorEntry);
		INI_WriteBool(ini, "player-animations", gPlayerAnimations);

		INI_WriteFloat(ini, "nametag-distance", gNameTagDistance);
		INI_WriteInt(ini, "combat-log-window", gCombatLogWindow);
		INI_WriteInt(ini, "login-freeze-time", gLoginFreezeTime);
		INI_WriteInt(ini, "max-tab-out-time", gMaxTaboutTime);
		INI_WriteInt(ini, "ping-limit", gPingLimit);

		INI_Close(ini);
	}


/*
	Printing setting values to console
*/


#if defined PRINT_SETTINGS

	printf(" MoTD: %s", gMessageOfTheDay);
	printf(" Web URL: %s", gWebsiteURL);
	printf(" Game Mode Name: %s", gGameModeName);

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

INI:settings[](name[], value[])
{
	INI_String("motd", gMessageOfTheDay, MAX_MOTD_LEN);
	INI_String("website", gWebsiteURL, MAX_WEBSITE_NAME);
	INI_String("gamemodename", gGameModeName, 32);

	INI_Bool("whitelist", gWhitelist);
	INI_Bool("allow-pause-map", gPauseMap);
	INI_Bool("interior-entry", gInteriorEntry);
	INI_Bool("player-animations", gPlayerAnimations);

	INI_Float("nametag-distance", gNameTagDistance);
	INI_Int("combat-log-window", gCombatLogWindow);
	INI_Int("login-freeze-time", gLoginFreezeTime);
	INI_Int("max-tab-out-time", gMaxTaboutTime);
	INI_Int("ping-limit", gPingLimit);

	return 1;
}
