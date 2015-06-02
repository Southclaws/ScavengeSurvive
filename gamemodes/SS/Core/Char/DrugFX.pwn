ptask DrugFX[100](playerid)
{
//	if(IsPlayerUnderDrugEffect(playerid, drug_Lsd))
//	{
//		hour = 22;
//		minute = 3;
//		weather = 33;
//	}
//	else if(IsPlayerUnderDrugEffect(playerid, drug_Heroin))
//	{
//		hour = 22;
//		minute = 30;
//		weather = 33;
//	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Air))
	{
		SetPlayerDrunkLevel(playerid, 100000);

		if(random(100) < 50)
			GivePlayerHP(playerid, -0.1);
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
	{
		GivePlayerHP(playerid, 0.01);
	}
}
