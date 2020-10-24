/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


// The directory from which vehicle spawn positions are loaded
#define DIRECTORY_LOOT_TABLES	"loot/"


hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_LOOT_TABLES);
}

hook OnGameModeInit()
{
	new count = LoadLootTableDir(DIRECTORY_SCRIPTFILES DIRECTORY_LOOT_TABLES);

	if(count == 0)
		err("No loot table entries loaded!");

	else
		Logger_Log("loaded loot table entries", Logger_I("count", count));
}

LoadLootTableDir(const directory_with_root[])
{
	Logger_Log("loading loot tables from directory", Logger_S("directory", directory_with_root));

	new
		Directory:direc,
		entry[64],
		ENTRY_TYPE:type,
		count,
		ext[5],
		trimlength = strlen("./scriptfiles/");

	direc = OpenDir(directory_with_root);

	if(direc == Directory:-1)
	{
		err("[LoadLootTableDir] Reading directory '%s'.", directory_with_root);
		return 0;
	}

	while(DirNext(direc, type, entry))
	{
		if(type == E_DIRECTORY && strcmp(entry, "..") && strcmp(entry, ".") && strcmp(entry, "_"))
		{
			count += LoadLootTableDir(entry);
		}

		if(type == E_REGULAR)
		{
			PathExt(entry, ext);
			if(!strcmp(ext, ".ltb"))
			{
				count += LoadLootTableFromFile(entry[trimlength]);
			}
		}
	}

	CloseDir(direc);

	return count;
}

LoadLootTableFromFile(file[])
{
	Logger_Log("loading loot table from file", Logger_S("file", file));

	if(!fexist(file))
	{
		err("[LoadLootTableFromFile] File '%s' not found.", file);
		return 0;
	}

	new
		File:f = fopen(file, io_read),
		line[128],

		// Loaded from first line
		indexname[32],
		indexid,
		Float:mult,

		// Loaded from each other line
		Float:weight,
		uname[MAX_ITEM_NAME],
		ItemType:itemtype,
		perlimit,
		svrlimit,

		linenum,
		count;

	fread(f, line);

	if(sscanf(line, "p<,>s[32]F(1.0)", indexname, mult))
	{
		err("[LoadLootTableFromFile] ltb (loot-table) file %s has bad header (must be <indexname>, <weight multiplier>", file);
		return 0;
	}

	indexid = DefineLootIndex(indexname);

	while(fread(f, line))
	{
		linenum++;

		strtrim(line, "\r\n");

		if(sscanf(line, "p<,>fs[32]D(3)D(0)", weight, uname, perlimit, svrlimit))
			continue;

		itemtype = GetItemTypeFromUniqueName(uname, true);

		if(!IsValidItemType(itemtype))
		{
			err("[LoadLootTableFromFile] Invalid item uname '%s' at %s:%d", uname, file, linenum);
			continue;
		}

		AddItemToLootIndex(indexid, itemtype, weight * mult, perlimit, svrlimit);

		count++;
	}

	fclose(f);

	Logger_Log("loaded item spawn rates", Logger_I("count", count), Logger_S("file", file));

	return 1;
}

