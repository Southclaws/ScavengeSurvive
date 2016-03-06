/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

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


#define MAX_SPAWNS (2)


static
	Float:spawn_List[MAX_SPAWNS][4] =
	{
		{-2431.0, 2254.0, 5.0,	0.0},
		{-2431.0, 2215.0, 5.0,	90.0}
	},
	spawn_Last[MAX_PLAYERS];



GenerateSpawnPoint(playerid, &Float:x, &Float:y, &Float:z, &Float:r)
{
	new index = random(sizeof(spawn_List));

	while(index == spawn_Last[playerid])
		index = random(sizeof(spawn_List));

	x = spawn_List[index][0];
	y = spawn_List[index][1];
	z = spawn_List[index][2];
	r = spawn_List[index][3];

	spawn_Last[playerid] = index;
}
