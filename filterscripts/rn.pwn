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
