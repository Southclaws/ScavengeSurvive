/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_WEPCACHE_LOCATIONS			(256)
#define WEPCACHE_INTERVAL				(1500000 + random(600000)) // 25 minutes + random 10 minutes
#define WEPCACHE_SIGNAL_INTERVAL		(200000)


enum E_WEPCACHE_LOCATION_DATA
{
Float:	wepc_posX,
Float:	wepc_posY,
Float:	wepc_posZ
}

static
Float:		wepc_DropLocationData[MAX_WEPCACHE_LOCATIONS][E_WEPCACHE_LOCATION_DATA],
   Iterator:wepc_Index<MAX_WEPCACHE_LOCATIONS>,
Float:		wepc_CurrentPosX,
Float:		wepc_CurrentPosY,
Float:		wepc_CurrentPosZ,
			webc_ActiveDrop = -1,
Container:	webc_Containerid = INVALID_CONTAINER_ID,
Button:		webc_Button = INVALID_BUTTON_ID;


hook OnGameModeInit()
{
	defer WeaponsCacheTimer();
	return 1;
}

DefineWeaponsCachePos(Float:x, Float:y, Float:z)
{
	new id = Iter_Free(wepc_Index);

	if(id == ITER_NONE)
	{
		err("Weapons cache pos definition limit reached.");
		return -1;
	}

	wepc_DropLocationData[id][wepc_posX] = x;
	wepc_DropLocationData[id][wepc_posY] = y;
	wepc_DropLocationData[id][wepc_posZ] = z;

	Iter_Add(wepc_Index, id);

	return id;
}

timer WeaponsCacheTimer[WEPCACHE_INTERVAL]()
{
	if(Iter_Count(Player) < 4)
		return;

	// There are no more locations available, kill the timer.
	if(Iter_Count(wepc_Index) == 0)
	{
		err("Weapons caches run out, stopping weapons cache timer.");
		return;
	}

	// Pick a location without any players nearby
	new
		id = Iter_Random(wepc_Index),
		checked;

	while(GetPlayersNearDropLocation(id) > 0)
	{
		if(checked == Iter_Count(wepc_Index))
		{
			checked = -1;
			break;
		}

		id = Iter_Random(wepc_Index);
		checked++;
	}

	if(checked > -1)
	{
		WeaponsCacheDrop(wepc_DropLocationData[id][wepc_posX], wepc_DropLocationData[id][wepc_posY], wepc_DropLocationData[id][wepc_posZ]);

		Iter_Remove(wepc_Index, id);

		webc_ActiveDrop = id;
	}

	defer WeaponsCacheTimer();

	return;
}

GetPlayersNearDropLocation(id)
{
	new count;

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, 500.0, wepc_DropLocationData[id][wepc_posX], wepc_DropLocationData[id][wepc_posY], wepc_DropLocationData[id][wepc_posZ]))
			count++;
	}

	return count;
}

WeaponsCacheDrop(Float:x, Float:y, Float:z)
{
	if(webc_ActiveDrop != -1)
		return 0;

	CreateDynamicObject(964, x, y, z - 0.0440, 0.0, 0.0, 0.0, .streamdistance = 1000.0, .drawdistance = 1000.0);

	wepc_CurrentPosX = x;
	wepc_CurrentPosY = y;
	wepc_CurrentPosZ = z;

	if(webc_Containerid != INVALID_CONTAINER_ID)
		DestroyContainer(webc_Containerid);

	if(webc_Button != INVALID_BUTTON_ID)
		DestroyButton(webc_Button);

	webc_Containerid = CreateContainer("Weapon Cache", 32);
	webc_Button = CreateButton(x, y - 0.5, z + 1.0, "Weapon Cache", .label = 1, .labeltext = "Weapon Cache");

	FillContainerWithLoot(Container:webc_Containerid, 22 + random(11), GetLootIndexFromName("airdrop_military_weapons"));

	defer WeaponsCacheSignal(1, x, y, z);

	return 1;
}

hook OnButtonPress(playerid, Button:id)
{
	if(id == webc_Button)
		DisplayContainerInventory(playerid, Container:webc_Containerid);
}


timer WeaponsCacheSignal[WEPCACHE_SIGNAL_INTERVAL](count, Float:x, Float:y, Float:z)
{
	// Gets a random weapons-cache drop location and uses it as a reference point.
	// Announces the angle and distance from that location to the weapons cache.
	new
		locationlist[MAX_WEPCACHE_LOCATIONS],
		idx,
		location,
		Float:ref_x,
		Float:ref_y,
		Float:ref_z,
		Float:angleto,
		Float:distanceto;

	for(new i, j = random(Iter_Free(wepc_Index)); i < j; i++)
	{
		ref_x = wepc_DropLocationData[i][wepc_posX];
		ref_y = wepc_DropLocationData[i][wepc_posY];
		ref_z = wepc_DropLocationData[i][wepc_posZ];

		if(Distance(ref_x, ref_y, ref_z, wepc_CurrentPosX, wepc_CurrentPosY, wepc_CurrentPosZ) < 1000.0)
		{
			locationlist[idx++] = i;
		}
	}

	if(idx > 0)
	{
		location = locationlist[random(idx)];

		ref_x = wepc_DropLocationData[location][wepc_posX];
		ref_y = wepc_DropLocationData[location][wepc_posY];
		ref_z = wepc_DropLocationData[location][wepc_posZ];

		angleto = absoluteangle(360 - GetAngleToPoint(ref_x, ref_y, x, y));
		distanceto = Distance2D(ref_x, ref_y, x, y);

		ChatMsgAll(YELLOW, " >  [EBS]: WEAPONS CACHE SIGNAL: BEARING: %.1fDEG DISTANCE: %.1fM'", angleto, distanceto);
	}
	else
	{
		err("No reference point found.");
		return;
	}

	if(count < 3)
	{
		defer WeaponsCacheSignal(count + 1, x, y, z);
	}
	else
	{
		webc_ActiveDrop = -1;
	}

	return;
}
