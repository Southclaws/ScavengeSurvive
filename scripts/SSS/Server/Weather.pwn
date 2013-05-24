#define MAX_WEATHER_TYPES	(20)


enum E_WEATHER_DATA
{
		weather_name[23],
Float:	weather_chance
}


new
	gWeatherID,
	gLastWeatherChange;

new
	WeatherData[MAX_WEATHER_TYPES][E_WEATHER_DATA]=
	{
		{"EXTRASUNNY_LS",			1.0},		// 00
		{"SUNNY_LS",				1.0},		// 01
		{"EXTRASUNNY_SMOG_LS",		1.0},		// 02
		{"SUNNY_SMOG_LS",			1.0},		// 03
		{"CLOUDY_LS",				1.0},		// 04

		{"SUNNY_SF",				1.0},		// 05
		{"EXTRASUNNY_SF",			1.0},		// 06
		{"CLOUDY_SF",				1.0},		// 07
		{"RAINY_SF",				0.3},		// 08
		{"FOGGY_SF",				1.0},		// 09

		{"SUNNY_LV",				1.0},		// 10
		{"EXTRASUNNY_LV",			1.0},		// 11
		{"CLOUDY_LV",				0.6},		// 12

		{"EXTRASUNNY_COUNTRYSIDE",	0.8},		// 13
		{"SUNNY_COUNTRYSIDE",		0.9},		// 14
		{"CLOUDY_COUNTRYSIDE",		0.5},		// 15
		{"RAINY_COUNTRYSIDE",		0.4},		// 16

		{"EXTRASUNNY_DESERT",		1.0},		// 17
		{"SUNNY_DESERT",			1.0},		// 18
		{"SANDSTORM_DESERT",		0.3}		// 19
	};

hook OnGameModeInit()
{
	gWeatherID = random(sizeof(WeatherData));
	gLastWeatherChange = tickcount();
}

WeatherUpdate()
{
	if(tickcount() - gLastWeatherChange > 600000 && random(100) < 10)
	{
		new
			list[MAX_WEATHER_TYPES],
			idx;

		for(new i; i < MAX_WEATHER_TYPES; i++)
		{
			if(frandom(1.0) < WeatherData[i][weather_chance])
				list[idx++] = i;
		}

		gWeatherID = list[random(idx)];
		gLastWeatherChange = tickcount();
	}
}
