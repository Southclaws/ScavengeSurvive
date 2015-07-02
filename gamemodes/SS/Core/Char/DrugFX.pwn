ptask DrugFX[1000](playerid)
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
}
