/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


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
