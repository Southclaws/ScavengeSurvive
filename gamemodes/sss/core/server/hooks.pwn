/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


Hook_HackDetect_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	HackDetect_SetPlayerPos(playerid, x, y, z);
	return SetPlayerPos(playerid, x, y, z);
}
#define SetPlayerPos Hook_HackDetect_SetPlayerPos

Hook_SetPlayerSkin(playerid, skinid, retry_on_fail = true)
{
	new specialaction = GetPlayerSpecialAction(playerid);

	if(specialaction == SPECIAL_ACTION_ENTER_VEHICLE || specialaction == SPECIAL_ACTION_EXIT_VEHICLE)
	{
		if(retry_on_fail)
			return _: defer Retry_SetPlayerSkin(playerid, skinid);
	}

	return SetPlayerSkin(playerid, skinid);
}
#define SetPlayerSkin Hook_SetPlayerSkin

timer Retry_SetPlayerSkin[100](playerid, skinid)
{
	Hook_SetPlayerSkin(playerid, skinid);
}
