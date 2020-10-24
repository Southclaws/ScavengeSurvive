/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnPlayerScriptUpdate(playerid)
{
	if(IsPlayerUnderDrugEffect(playerid, drug_Lsd))
	{
		hour = 22;
		minute = 3;
		weather = 33;
		SetPlayerTime(playerid, hour, minute);
		SetPlayerWeather(playerid, weather);
	}
	else if(IsPlayerUnderDrugEffect(playerid, drug_Heroin))
	{
		hour = 22;
		minute = 30;
		weather = 33;
		SetPlayerTime(playerid, hour, minute);
		SetPlayerWeather(playerid, weather);
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Air))
	{
		SetPlayerDrunkLevel(playerid, 100000);

		if(random(100) < 50)
			GivePlayerHP(playerid, -1.0);
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
	{
		GivePlayerHP(playerid, 0.01);
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Air))
	{
		SetPlayerDrunkLevel(playerid, 100000);

		if(random(100) < 50)
			GivePlayerHP(playerid, -1.0);
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
	{
		GivePlayerHP(playerid, 0.01);
	}
}
