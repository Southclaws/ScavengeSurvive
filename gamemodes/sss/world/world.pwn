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


#include "sss/world/spawn.pwn"

#include "sss/world/zones/ls.pwn"
#include "sss/world/zones/sf.pwn"
#include "sss/world/zones/lv.pwn"
#include "sss/world/zones/rc.pwn"
#include "sss/world/zones/fc.pwn"
#include "sss/world/zones/bc.pwn"
#include "sss/world/zones/tr.pwn"
// #include "sss/world/misc/ls_apartments1.pwn"
#include "sss/world/misc/ls_apartments2.pwn"
// #include "sss/world/misc/ls_beachside.pwn"
// #include "sss/world/misc/.pwn"
#include "sss/world/puzzles/area69.pwn"
#include "sss/world/puzzles/ranch.pwn"
#include "sss/world/puzzles/mtchill.pwn"
#include "sss/world/puzzles/codehunt.pwn"
#include "sss/world/houseloot.pwn"

#include "sss/world/xmas.pwn"

static
	MapName[32] = "San Androcalypse",
	ItemCounts[ITM_MAX_TYPES];

#include <YSI_Coding\y_hooks>


hook OnGameModeInit()
{
	defer LoadWorld();
}

timer LoadWorld[10]()
{
	Logger_Log("loading World");

	gServerInitialising = true;

	// store this to a list and compare after
	for(new ItemType:i; i < ITM_MAX_TYPES; i++)
	{
		if(!IsValidItemType(i))
			break;

		if(GetItemTypeCount(i) == 0)
			continue;

		ItemCounts[i] = GetItemTypeCount(i);
	}

	defer _Load_LS();
}

timer _Load_LS[500]()
{
	Logger_Log("loading LS");
	Load_LS();
	defer _Load_SF();
}

timer _Load_SF[500]()
{
	Logger_Log("loading SF");
	Load_SF();
	defer _Load_LV();
}

timer _Load_LV[500]()
{
	Logger_Log("loading LV");
	Load_LV();
	defer _Load_RC();
}

timer _Load_RC[500]()
{
	Logger_Log("loading RC");
	Load_RC();
	defer _Load_FC();
}

timer _Load_FC[500]()
{
	Logger_Log("loading FC");
	Load_FC();
	defer _Load_BC();
}

timer _Load_BC[500]()
{
	Logger_Log("loading BC");
	Load_BC();
	defer _Load_TR();
}

timer _Load_TR[500]()
{
	Logger_Log("loading TR");
	Load_TR();
	defer _Finalise();
}

timer _Finalise[500]()
{
	Logger_Log("loading HouseLoot");
	Load_HouseLoot();

	new itemtypename[ITM_MAX_NAME];

	// compare with previous list and print differences
	for(new ItemType:i; i < ITM_MAX_TYPES; i++)
	{
		if(!IsValidItemType(i))
			break;

		if(GetItemTypeCount(i) == 0)
			continue;

		GetItemTypeUniqueName(i, itemtypename);

		Logger_Log("spawned items",
			Logger_S("type", itemtypename),
			Logger_I("loaded", ItemCounts[i]),
			Logger_I("spawned", GetItemTypeCount(i) - ItemCounts[i]),
			Logger_I("total", GetItemTypeCount(i))
		);
	}

	gServerInitialising = false;
}

stock GetMapName()
{
	return MapName;
}

