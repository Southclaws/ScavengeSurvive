/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

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

static area;

hook OnGameModeInit()
{
	CreateObject(3350, -962.72461, 5136.90479, 52.29009,   180.00000, 0.00000, 14.88004);
	area = CreateDynamicRectangle(-982.4383, 5091.6768, -950.4024, 5195.4932, 1, 0);
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(areaid == area)
	{
		PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com/u/45512231/wtf2.3.mp3", -962.72461, 5136.90479, 52.29009, 30.0, 1);
	}
	#if defined sfn_OnPlayerEnterDynamicArea
		return sfn_OnPlayerEnterDynamicArea(playerid, areaid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
 
#define OnPlayerEnterDynamicArea sfn_OnPlayerEnterDynamicArea
#if defined sfn_OnPlayerEnterDynamicArea
	forward sfn_OnPlayerEnterDynamicArea(playerid, areaid);
#endif

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(areaid == area)
	{
		StopAudioStreamForPlayer(playerid);
	}

	#if defined sfw_OnPlayerLeaveDynamicArea
		return sfw_OnPlayerLeaveDynamicArea(playerid, areaid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif
 
#define OnPlayerLeaveDynamicArea sfw_OnPlayerLeaveDynamicArea
#if defined sfw_OnPlayerLeaveDynamicArea
	forward sfw_OnPlayerLeaveDynamicArea(playerid, areaid);
#endif
