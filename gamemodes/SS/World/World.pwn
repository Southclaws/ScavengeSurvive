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


#include "ss/World/Spawn.pwn"

#include "ss/World/Zones/LS.pwn"
#include "ss/World/Zones/SF.pwn"
#include "ss/World/Zones/LV.pwn"
#include "ss/World/Zones/RC.pwn"
#include "ss/World/Zones/FC.pwn"
#include "ss/World/Zones/BC.pwn"
#include "ss/World/Zones/TR.pwn"
// #include "ss/World/Misc/ls_apartments1.pwn"
#include "ss/World/Misc/ls_apartments2.pwn"
// #include "ss/World/Misc/ls_beachside.pwn"
// #include "ss/World/Misc/.pwn"
#include "ss/World/Puzzles/Area69.pwn"
#include "ss/World/Puzzles/Ranch.pwn"
#include "ss/World/Puzzles/MtChill.pwn"
#include "ss/World/Puzzles/CodeHunt.pwn"
#include "ss/World/HouseLoot.pwn"

#include "ss/World/Xmas.pwn"

static
	MapName[32] = "San Androcalypse",
	ItemCounts[ITM_MAX_TYPES];

#include <YSI\y_hooks>


hook OnGameModeInit()
{
	defer LoadWorld();
}

timer LoadWorld[10]()
{
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

timer _Load_LS[100]()
{
	Load_LS();
	defer _Load_SF();
}

timer _Load_SF[100]()
{
	Load_SF();
	defer _Load_LV();
}

timer _Load_LV[100]()
{
	Load_LV();
	defer _Load_RC();
}

timer _Load_RC[100]()
{
	Load_RC();
	defer _Load_FC();
}

timer _Load_FC[100]()
{
	Load_FC();
	defer _Load_BC();
}

timer _Load_BC[100]()
{
	Load_BC();
	defer _Load_TR();
}

timer _Load_TR[100]()
{
	Load_TR();
	defer _Finalise();
}

timer _Finalise[100]()
{
	new itemtypename[ITM_MAX_NAME];

	// compare with previous list and print differences
	for(new ItemType:i; i < ITM_MAX_TYPES; i++)
	{
		if(!IsValidItemType(i))
			break;

		if(GetItemTypeCount(i) == 0)
			continue;

		GetItemTypeUniqueName(i, itemtypename);

		printf("[%03d] Loaded:%04d, Spawned:%04d, Total:%04d, '%s'", _:i, ItemCounts[i], GetItemTypeCount(i) - ItemCounts[i], GetItemTypeCount(i), itemtypename);
	}

	gServerInitialising = false;
}

stock GetMapName()
{
	return MapName;
}

