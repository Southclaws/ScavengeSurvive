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


#define MAX_SPAWNS (14)


static
	Float:spawn_List[MAX_SPAWNS][4] =
	{
		{-2923.4396,	-70.4305,		0.7973,		269.0305},
		{-2914.9213,	-902.9458,		0.5190,		339.3433},
		{-2804.5021,	-2296.2153,		0.7071,		249.8544},
		{-228.7865,		-1719.8090,		1.1083,		34.9733},
		{13.9133,		-1112.0993,		1.2848,		110.2575},
		{-325.7897,		-467.2996,		1.9922,		48.1126},
		{-71.3649,		-577.1849,		1.3816,		351.6495},
		{161.5016,		157.5428,		1.1178,		187.3177},
		{2012.8952,		-38.5986,		1.2391,		4.8748},
		{2117.7065,		183.7778,		1.0822,		74.3911},
		{-1886.1279,	2160.1945,		1.4039,		335.7922},
		{-764.4365,		654.4160,		1.7907,		1.7156},
		{-434.6048,		867.6434,		1.4236,		318.3918},
		{-638.7510,		1286.1458,		1.4520,		110.0257}

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
