/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaws" Keene

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

