/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_WEATHER_TYPES	(20)


enum E_WEATHER_DATA
{
		weather_name[23],
Float:	weather_chance
}


static
	weather_Current,
	weather_CurrentHour,
	weather_CurrentMinute,
	weather_PlayerWeather[MAX_PLAYERS],
	weather_PlayerHour[MAX_PLAYERS],
	weather_PlayerMinute[MAX_PLAYERS],
	weather_LastChange;

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
	// Todo: custom weather array loaded from settings

	weather_Current = random(19);
	weather_LastChange = GetTickCount();
}

hook OnPlayerConnect(playerid)
{
	weather_PlayerWeather[playerid] = -1;
	weather_PlayerHour[playerid] = -1;
	weather_PlayerMinute[playerid] = -1;
	_WeatherUpdateForPlayer(playerid);
}

hook OnPlayerSpawnChar(playerid)
{
	SetWeatherForPlayer(playerid, weather_Current);
}

hook OnPlayerSpawnNewChar(playerid)
{
	SetWeatherForPlayer(playerid, weather_Current);
}

task WeatherUpdate[600000]()
{
	if(GetTickCountDifference(GetTickCount(), weather_LastChange) > 600000 && random(100) < 10)
	{
		new
			list[MAX_WEATHER_TYPES],
			idx;

		for(new i; i < MAX_WEATHER_TYPES; i++)
		{
			if(frandom(1.0) < WeatherData[i][weather_chance])
				list[idx++] = i;
		}

		weather_Current = list[random(idx)];
		weather_LastChange = GetTickCount();
		_WeatherUpdate();
	}

}

_WeatherUpdate()
{
	foreach(new i : Player)
	{
		_WeatherUpdateForPlayer(i);
	}
}

_WeatherUpdateForPlayer(playerid)
{
	if(weather_PlayerWeather[playerid] != -1)
		return 0;

	SetPlayerTime(playerid, weather_CurrentHour, weather_CurrentMinute);
	SetPlayerWeather(playerid, weather_Current);

	return 1;
}

stock SetGlobalWeather(weather)
{
	weather_Current = weather;

	_WeatherUpdate();
}

stock GetGlobalWeather()
{
	return weather_Current;
}

stock SetWeatherForPlayer(playerid, weather = -1)
{
	if(weather == -1)
	{
		weather_PlayerWeather[playerid] = -1;
		_WeatherUpdateForPlayer(playerid);
	}
	else
	{
		weather_PlayerWeather[playerid] = weather;
		SetPlayerWeather(playerid, weather);
	}
}

stock GetWeatherForPlayer(playerid)
{
	return weather_PlayerWeather[playerid];
}

stock SetTimeForPlayer(playerid, hour, minute, reset = false)
{
	if(reset)
	{
		weather_PlayerHour[playerid] = -1;
		weather_PlayerMinute[playerid] = -1;
		SetPlayerTime(playerid, weather_CurrentHour, weather_CurrentMinute);
	}
	else
	{
		weather_PlayerHour[playerid] = hour;
		weather_PlayerMinute[playerid] = minute;
		SetPlayerTime(playerid, hour, minute);
	}
}

stock GetTimeForPlayer(playerid, &hour, &minute)
{
	hour = weather_PlayerHour[playerid];
	minute = weather_PlayerMinute[playerid];
}
