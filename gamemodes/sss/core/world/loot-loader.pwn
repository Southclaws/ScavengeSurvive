/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


// The directory from which vehicle spawn positions are loaded
#define DIRECTORY_LOOT_TABLES	"loot/"


hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_LOOT_TABLES);
}

hook OnGameModeInit()
{
	new count = LoadLootTableDir(DIRECTORY_LOOT_TABLES);

	if(count == 0)
		err("No loot table entries loaded!");

	else
		log("Loaded %d Loot table entries", count);
}

LoadLootTableDir(directory[])
{
	new
		dir:dirhandle,
		directory_with_root[256],
		item[64],
		type,
		next_path[256],
		count;

	strcat(directory_with_root, DIRECTORY_SCRIPTFILES);
	strcat(directory_with_root, directory);

	dirhandle = dir_open(directory_with_root);

	if(!dirhandle)
	{
		err("[LoadLootTableDir] Reading directory '%s'.", directory);
		return 0;
	}

	while(dir_list(dirhandle, item, type))
	{
		if(type == FM_DIR && strcmp(item, "..") && strcmp(item, ".") && strcmp(item, "_"))
		{
			next_path[0] = EOS;
			format(next_path, sizeof(next_path), "%s%s/", directory, item);
			count += LoadLootTableDir(next_path);
		}

		if(type == FM_FILE)
		{
			if(!strcmp(item[strlen(item) - 4], ".ltb"))
			{
				next_path[0] = EOS;
				format(next_path, sizeof(next_path), "%s%s", directory, item);
				count += LoadLootTableFromFile(next_path);
			}
		}
	}

	dir_close(dirhandle);

	return count;
}

LoadLootTableFromFile(file[])
{
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
		uname[ITM_MAX_NAME],
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

	log("[LOAD] %d item spawn rates loaded from %s", count, file);

	return 1;
}

