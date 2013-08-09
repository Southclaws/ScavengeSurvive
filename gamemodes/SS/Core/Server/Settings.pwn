#define PRINT_SETTINGS


LoadSettings()
{
	print("\nLoading Settings...");


/*
	Setting Loading
*/


	INI_Load(SETTINGS_FILE);


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

	return 1;
}
