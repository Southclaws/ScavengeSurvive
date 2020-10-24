/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>

enum
{
	loot_Civilian,
	loot_Industrial,
	loot_Police,
	loot_Military,
	loot_Medical,
	loot_CarCivilian,
	loot_CarIndustrial,
	loot_CarPolice,
	loot_CarMilitary,
	loot_Survivor
}

forward OnLoad();

#include "../gamemodes/ss/World/Zones/SF.pwn"
#include "../gamemodes/ss/World/Zones/LS.pwn"
#include "../gamemodes/ss/World/Zones/LV.pwn"
#include "../gamemodes/ss/World/Zones/BC.pwn"
#include "../gamemodes/ss/World/Zones/FC.pwn"
#include "../gamemodes/ss/World/Zones/TR.pwn"
#include "../gamemodes/ss/World/Zones/RC.pwn"

new
	File:output,
	count;

public OnFilterScriptInit()
{
	output = fopen("loot.txt", io_write);
	
	LoadSF();
	LoadTR();
	LoadFC();
	LoadBC();
	LoadRC();
	LoadLV();
	LoadLS();

	fclose(output);

	printf("Done, count: %d", count);
}

CreateLootSpawn(Float:x, Float:y, Float:z,	amount, chance, type)
{
	#pragma unused amount, chance, type, z

	new str[128];

	format(str, 128, "\t\t\t\t{%d, %d},\r\n", floatround(x), floatround(y));

	fwrite(output, str);

	count++;
}

