#define PRINT_SETTINGS


LoadSettings()
{
	print("Loading Settings...");


/*
	Setting Loading
*/


	INI_Load(SETTINGS_FILE);


#if defined PRINT_SETTINGS

	printf("MoTD: %s", gMessageOfTheDay);
	printf("Game Mode Name: %s", gGameModeName);

	printf("Whitelist: %d", gWhitelist);
	printf("Pause Map: %d", gPauseMap);
	printf("Interior Entry: %d", gInteriorEntry);
	printf("Player Animations: %d", gPlayerAnimations);

	printf("Name Distance: %f", gNameTagDistance);

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
}

INI:settings[](name[], value[])
{
	INI_String("motd", gMessageOfTheDay, MAX_MOTD_LEN);
	INI_String("gamemodename", gGameModeName, 32);

	INI_Bool("whitelist", gWhitelist);
	INI_Bool("allow-pause-map", gPauseMap);
	INI_Bool("interior-entry", gInteriorEntry);
	INI_Bool("player-animations", gPlayerAnimations);

	INI_Float("nametag-distance", gNameTagDistance);

	return 1;
}
