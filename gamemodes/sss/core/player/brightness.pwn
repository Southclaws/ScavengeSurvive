/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
			BrightnessLevel[MAX_PLAYERS],
//			BrightnessFade[MAX_PLAYERS],
PlayerText:	BrightnessUI[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};


hook OnPlayerConnect(playerid)
{
	BrightnessLevel[playerid] = 255;

	PlayerTextDrawBoxColor(playerid, BrightnessUI[playerid], BrightnessLevel[playerid]);
	PlayerTextDrawShow(playerid, BrightnessUI[playerid]);

	BrightnessUI[playerid]			=CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, BrightnessUI[playerid], 255);
	PlayerTextDrawFont				(playerid, BrightnessUI[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, BrightnessUI[playerid], 0.500000, 50.000000);
	PlayerTextDrawColor				(playerid, BrightnessUI[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, BrightnessUI[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, BrightnessUI[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, BrightnessUI[playerid], 1);
	PlayerTextDrawUseBox			(playerid, BrightnessUI[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, BrightnessUI[playerid], 255);
	PlayerTextDrawTextSize			(playerid, BrightnessUI[playerid], 640.000000, 0.000000);
}

ptask BrightnessUpdate[100](playerid)
{
	if(!IsPlayerSpawned(playerid))
		return;

	new Float:hp = GetPlayerHP(playerid);

	if(BrightnessLevel[playerid] > 0)
	{
		PlayerTextDrawBoxColor(playerid, BrightnessUI[playerid], BrightnessLevel[playerid]);
		PlayerTextDrawShow(playerid, BrightnessUI[playerid]);

		BrightnessLevel[playerid] -= 4;

		if(BrightnessLevel[playerid] < 0)
			BrightnessLevel[playerid] = 0;

		if(hp <= 40.0)
		{
			if(BrightnessLevel[playerid] <= floatround((40.0 - hp) * 4.4))
				BrightnessLevel[playerid] = 0;
		}

		return;
	}

	if(hp >= 40.0)
	{
		if(IsPlayerSpawned(playerid))
			PlayerTextDrawBoxColor(playerid, BrightnessUI[playerid], 0);

		return;
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Painkill))
	{
		PlayerTextDrawHide(playerid, BrightnessUI[playerid]);
	}
	else if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
	{
		PlayerTextDrawHide(playerid, BrightnessUI[playerid]);
	}
	else
	{
		PlayerTextDrawBoxColor(playerid, BrightnessUI[playerid], floatround((40.0 - hp) * 4.4));
		PlayerTextDrawShow(playerid, BrightnessUI[playerid]);

		if(!IsPlayerKnockedOut(playerid))
		{
			if(GetTickCountDifference(GetTickCount(), GetPlayerKnockOutTick(playerid)) > 5000 * hp)
			{
				new Float:bleedrate;
				GetPlayerBleedRate(playerid, bleedrate);
				if(bleedrate > 0.0)
				{
					if(frandom(40.0) < (50.0 - hp))
						KnockOutPlayer(playerid, floatround(2000 * (50.0 - hp) + frandom(200 * (50.0 - hp))));
				}
				else
				{
					if(frandom(40.0) < (40.0 - hp))
						KnockOutPlayer(playerid, floatround(2000 * (40.0 - hp) + frandom(200 * (40.0 - hp))));
				}
			}
		}
	}

	return;
}

stock SetPlayerBrightness(playerid, level)
{
//	if(!IsPlayerConnected(playerid))
//		return 0;

	if(level > 255)
		level = 255;

	if(level < 0)
		level = 0;

	BrightnessLevel[playerid] = level;

	PlayerTextDrawBoxColor(playerid, BrightnessUI[playerid], BrightnessLevel[playerid]);
	PlayerTextDrawShow(playerid, BrightnessUI[playerid]);

	return 1;
}
/*
stock SetPlayerBrightnessFade(playerid, amount)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	BrightnessFade[playerid] = amount;

	return 1;
}
*/

ACMD:brightness[4](playerid, params[])
{
	SetPlayerBrightness(playerid, strval(params));
	return 1;
}
