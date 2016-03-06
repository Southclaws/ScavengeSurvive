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


#define TILE_SIZE_X		(41.3482)
#define TILE_SIZE_Y		(40.0000)

#define ORIGIN_X		(-3000.0)
#define ORIGIN_Y		(-3000.0)
#define ENDPOINT_X		(3000.0)
#define ENDPOINT_Y		(3000.0)


GenerateTerrain(seed)
{
	printf("\n\n\nGenerating terrain from seed: %d", seed);

	new
		Float:x = ORIGIN_X,
		Float:y = ORIGIN_Y,
		tileid,
		tempseed1 = seed,
		tempseed2 = seed;

	while(x < ENDPOINT_X && y < ENDPOINT_Y)
	{
		GenerateTile(tempseed1, tempseed2, tileid);

		CreateTile(tileid, x, y);

		x += TILE_SIZE_X;

		if(x > ENDPOINT_X)
		{
			x = ORIGIN_X;
			y += TILE_SIZE_Y;
		}
	}

	print("Terrain generation complete");
	printf("%d Total Tiles", GetTotalTiles());

	new name[24];

	for(new i; i < GetTotalTileTypes(); i++)
	{
		GetTileName(i, name);
	 	printf("Tile '%s' uses: %d", name, GetTileUses(i));
	}

	print("\n\n\n");
}
