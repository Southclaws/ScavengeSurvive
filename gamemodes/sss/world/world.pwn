/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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
#include "sss/world/objects.pwn"

#include "sss/world/xmas.pwn"

static
	MapName[32] = "San Androcalypse",
	ItemCounts[MAX_ITEM_TYPE];

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
	for(new ItemType:i; i < MAX_ITEM_TYPE; i++)
	{
		if(!IsValidItemType(i))
			break;

		if(GetItemTypeCount(i) == 0)
			continue;

		ItemCounts[i] = GetItemTypeCount(i);
	}

	defer _Load_Objects();
}

timer _Load_Objects[500]()
{
	Logger_Log("loading World Objects");
	Load_Objects();
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

	new itemtypename[MAX_ITEM_NAME];

	// compare with previous list and print differences
	for(new ItemType:i; i < MAX_ITEM_TYPE; i++)
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

