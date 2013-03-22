#include <a_samp>
#include <md-sort>

#define CreateObject ConvertLoot

public OnFilterScriptInit()
{
CreateObject(1279, -1432.99072, -965.09174, 199.96188,   0.00000, 0.00000, 0.00000);
CreateObject(330, -1426.12927, -966.46100, 199.83781,   0.00000, 0.00000, 0.00000);
CreateObject(341, -1435.65625, -959.54285, 199.94650,   0.00000, 0.00000, 0.00000);
CreateObject(1247, -1427.45349, -959.67242, 200.08545,   0.00000, 0.00000, 0.00000);
SaveFile();
}


#define loot_Civilian		(330)
#define loot_Industrial		(341)
#define loot_Police			(346)
#define loot_Military		(356)
#define loot_Medical		(1240)
#define loot_Survivor		(1247)
#define loot_CarIndustrial	(1279)


enum e_loot_data
{
	loottype,
	string[256]
}

new
	LootData[5000][e_loot_data],
	TotalRecords;

ConvertLoot(model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	#pragma unused rx, ry, rz

	new
		type[32],
		id;

	switch(model)
	{
		case loot_Civilian:			type = "loot_Civilian",			id = 7;
		case loot_Industrial:		type = "loot_Industrial",		id = 6;
		case loot_Police:			type = "loot_Police",			id = 5;
		case loot_Military:			type = "loot_Military",			id = 4;
		case loot_Medical:			type = "loot_Medical",			id = 3;
		case loot_Survivor:			type = "loot_Survivor",			id = 2;
		case loot_CarIndustrial:	type = "loot_CarIndustrial",	id = 1;
	}

	format(LootData[TotalRecords][string], 256, "	CreateLootSpawn(%f, %f, %f,	%d, %d, %s);\r\n", x, y, z, 3, 30, type);
	LootData[TotalRecords][loottype] = id;

	TotalRecords++;
}

SaveFile()
{
	new
		File:file;

	SortDeepArray(LootData, loottype, .order = SORT_DESC);

	if(!fexist("output.txt"))
		file = fopen("output.txt", io_write);

	else
		file = fopen("output.txt", io_append);

	if(file)
	{
		for(new i; i < TotalRecords; i++)
		{
			fwrite(file, LootData[i][string]);
		}
	}

	fclose(file);
}
