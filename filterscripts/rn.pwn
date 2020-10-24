/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


/*
	A small utility for converting log filenames to the new more logical format.

	Run this ONLY ONCE, if you run it on 'fixed' filenames, they will get mixed
	up again!
*/

#include <a_samp>
#include <sscanf2>
#include <FileManager>

public OnFilterScriptInit()
{
	new
		dir:direc = dir_open("./scriptfiles/Logs/"),
		item[64],
		type,
		original[64],
		newname[64],
		y, m, d, s[32];

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			// 01-09-2013 (Sun-01-Sep).txt
			sscanf(item, "p<->ddp< >ds[32]", y, m, d, s);

			format(original, 64, "./scriptfiles/Logs/%s", item);
			format(newname, 64, "./scriptfiles/Logs/New/%04d-%02d-%02d %s", y, m, d, s);

			printf("Moving '%s' TO '%s'", original, newname);

			file_move(original, newname);
		}
	}

	dir_close(direc);
}
