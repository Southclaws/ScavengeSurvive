/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define DIRECTORY_TREES "trees/"


hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_TREES);
}

hook OnGameModeInit()
{
	LoadTreesFromFolder(DIRECTORY_SCRIPTFILES DIRECTORY_TREES);
}


/*==============================================================================

	Loading

==============================================================================*/


LoadTreesFromFolder(const foldername[])
{
	new
		Directory:direc,
		entry[64],
		ENTRY_TYPE:type,
		trimlength = strlen("./scriptfiles/");

	direc = OpenDir(foldername);

	while(DirNext(direc, type, entry))
	{
		if(type == E_REGULAR)
		{
			if(!strcmp(entry[strlen(entry) - 4], ".tpl"))
			{
				LoadTrees(entry[trimlength]);
			}
		}

		if(type == E_DIRECTORY && strcmp(entry, "..") && strcmp(entry, ".") && strcmp(entry, "_"))
		{
			LoadTreesFromFolder(entry);
		}
	}

	CloseDir(direc);
}

LoadTrees(filename[])
{
	new
		File:file,
		line[256],
		linenumber = 1,
		count,

		funcname[32],
		funcargs[128],

		category_name[MAX_TREE_CATEGORY_NAME],
		category_id,
		Float:x,
		Float:y,
		Float:z;

	if(!fexist(filename))
	{
		err("file: \"%s\" NOT FOUND", filename);
		return 0;
	}

	file = fopen(filename, io_read);

	if(!file)
	{
		err("file: \"%s\" NOT LOADED", filename);
		return 0;
	}

	while(fread(file, line))
	{
		if(line[0] < 65)
		{
			linenumber++;
			continue;
		}

		if(sscanf(line, "p<(>s[32]p<)>s[128]{s[96]}", funcname, funcargs))
		{
			linenumber++;
			continue;
		}

		if(!strcmp(funcname, "CreateTree"))
		{
			if(sscanf(funcargs, "p<,>s[32]fff", category_name, x, y, z))
			{
				err("[LoadTrees] Malformed parameters on line %d", linenumber);
				linenumber++;
				continue;
			}

			category_id = GetTreeCategoryFromName(category_name);
			CreateTree(GetRandomTreeSpecies(category_id), x, y, z);
			count++;
			linenumber++;
		}
	}

	Logger_Log("loaded trees",
		Logger_I("count", count),
		Logger_S("filename", filename));

	return 1;
}
