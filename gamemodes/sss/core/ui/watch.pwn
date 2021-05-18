/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


const MAX_SCALE_PROFILE = 3;

static
PlayerText:	WatchBackground[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	WatchTime[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	WatchBear[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	WatchFreq[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
bool:		watch_Show[MAX_PLAYERS];

static Float:ScaleProfiles[e_UI_SCALE_PROFILES][] = {
//   pos x       pos y      scale x   scale y   bg offset x
	{-1.000000,  0.000000,  0.939999, 1.000000, -52.899806}, // e_UI_SCALE_NORMAL: unmodified game
	{-19.000000, -7.000000, 0.749999, 1.079999, -52.899806}, // e_UI_SCALE_HUDSCALEFIX: with /hudscalefix
	{-27.000000, 0.000000,  0.660000, 1.000000, -54.599781}  // e_UI_SCALE_WIDESCREENFIX: with Widescreen Fix mod
};

ShowWatch(playerid)
{
	PlayerTextDrawShow(playerid, WatchBackground[playerid]);
	PlayerTextDrawShow(playerid, WatchTime[playerid]);
	PlayerTextDrawShow(playerid, WatchBear[playerid]);
	PlayerTextDrawShow(playerid, WatchFreq[playerid]);

	watch_Show[playerid] = true;
}

HideWatch(playerid)
{
	PlayerTextDrawHide(playerid, WatchBackground[playerid]);
	PlayerTextDrawHide(playerid, WatchTime[playerid]);
	PlayerTextDrawHide(playerid, WatchBear[playerid]);
	PlayerTextDrawHide(playerid, WatchFreq[playerid]);

	watch_Show[playerid] = false;
}

UpdateWatchWithScaleProfile(playerid)
{
	new e_UI_SCALE_PROFILES:profile = GetPlayerUIScaleProfile(playerid);
	_updateWatchUI(
		playerid,
		ScaleProfiles[profile][0],
		ScaleProfiles[profile][1],
		ScaleProfiles[profile][2],
		ScaleProfiles[profile][3],
		ScaleProfiles[profile][4]
	);
	ShowWatch(playerid);
}
ptask UpdateWatch[1000](playerid)
{
	if(!watch_Show[playerid])
		return;

	new
		str[12],
		hour,
		minute,
		Float:angle,
		lastattacker,
		lastweapon;

	gettime(hour, minute);

	if(IsPlayerInAnyVehicle(playerid))
		GetVehicleZAngle(GetPlayerLastVehicle(playerid), angle);

	else
		GetPlayerFacingAngle(playerid, angle);

	format(str, 6, "%02d:%02d", hour, minute);
	PlayerTextDrawSetString(playerid, WatchTime[playerid], str);

	format(str, 12, "%.0f DEG", 360 - angle);
	PlayerTextDrawSetString(playerid, WatchBear[playerid], str);

	format(str, 7, "%.2f", GetPlayerRadioFrequency(playerid));
	PlayerTextDrawSetString(playerid, WatchFreq[playerid], str);

	if(IsPlayerCombatLogging(playerid, lastattacker, Item:lastweapon))
	{
		if(IsPlayerConnected(lastattacker))
		{
			PlayerTextDrawColor(playerid, WatchTime[playerid], RED);
			PlayerTextDrawColor(playerid, WatchBear[playerid], RED);
			PlayerTextDrawColor(playerid, WatchFreq[playerid], RED);
		}
	}
	else
	{
		PlayerTextDrawColor(playerid, WatchTime[playerid], WHITE);
		PlayerTextDrawColor(playerid, WatchBear[playerid], WHITE);
		PlayerTextDrawColor(playerid, WatchFreq[playerid], WHITE);
	}

	PlayerTextDrawShow(playerid, WatchTime[playerid]);
	PlayerTextDrawShow(playerid, WatchBear[playerid]);
	PlayerTextDrawShow(playerid, WatchFreq[playerid]);

	return;
}

hook OnPlayerSpawnChar(playerid)
{
	UpdateWatchWithScaleProfile(playerid);
}

hook OnPlayerSpawnNewChar(playerid)
{
	UpdateWatchWithScaleProfile(playerid);
}

_updateWatchUI(playerid, Float:x, Float:y, Float:sx, Float:sy, Float:bgoffsetx)
{
	PlayerTextDrawDestroy(playerid, WatchBackground[playerid]);
	PlayerTextDrawDestroy(playerid, WatchTime[playerid]);
	PlayerTextDrawDestroy(playerid, WatchBear[playerid]);
	PlayerTextDrawDestroy(playerid, WatchFreq[playerid]);

	WatchBackground[playerid]		=CreatePlayerTextDraw(playerid, 87.000000 + x + (bgoffsetx * sx), 338.000000 + y, "LD_POOL:ball");
	PlayerTextDrawAlignment			(playerid, WatchBackground[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchBackground[playerid], 4);
	PlayerTextDrawLetterSize		(playerid, WatchBackground[playerid], 0.500000, 0.000000);
	PlayerTextDrawColor				(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, WatchBackground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawUseBox			(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawTextSize			(playerid, WatchBackground[playerid], sx * 108.000000, sy * 89.000000);

	WatchTime[playerid]				=CreatePlayerTextDraw(playerid, 87.000000 + x, 372.000000 + y, "69:69");
	PlayerTextDrawAlignment			(playerid, WatchTime[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchTime[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchTime[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, WatchTime[playerid], sx * 0.500000, sy * 2.000000);
	PlayerTextDrawColor				(playerid, WatchTime[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, WatchTime[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WatchTime[playerid], 1);

	WatchBear[playerid]				=CreatePlayerTextDraw(playerid, 87.000000 + x, 358.000000 + y, "45 Deg");
	PlayerTextDrawAlignment			(playerid, WatchBear[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchBear[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchBear[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, WatchBear[playerid], sx * 0.300000, sy * 1.500000);
	PlayerTextDrawColor				(playerid, WatchBear[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, WatchBear[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WatchBear[playerid], 1);

	WatchFreq[playerid]				=CreatePlayerTextDraw(playerid, 87.000000 + x, 391.000000 + y, "88.8");
	PlayerTextDrawAlignment			(playerid, WatchFreq[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchFreq[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchFreq[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, WatchFreq[playerid], sx * 0.300000, sy * 1.500000);
	PlayerTextDrawColor				(playerid, WatchFreq[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, WatchFreq[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WatchFreq[playerid], 1);
}
