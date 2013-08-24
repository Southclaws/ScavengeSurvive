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

#include "/temp/SF.pwn"
#include "/temp/LS.pwn"
#include "/temp/LV.pwn"
#include "/temp/BC.pwn"
#include "/temp/FC.pwn"
#include "/temp/TR.pwn"
#include "/temp/RC.pwn"

new
	File:output,
	count;

main()
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

public OnPlayerSpawn(playerid)
{
	SetPlayerPos(playerid, 0.0, 0.0, 3.0);
}
