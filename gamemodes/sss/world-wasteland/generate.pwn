/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define TILE_SIZE_X		(41.3482)
#define TILE_SIZE_Y		(40.0000)

#define ORIGIN_X		(-3000.0)
#define ORIGIN_Y		(-3000.0)
#define ENDPOINT_X		(3000.0)
#define ENDPOINT_Y		(3000.0)


GenerateTerrain(seed)
{
	log("\n\n\nGenerating terrain from seed: %d", seed);

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
	log("%d Total Tiles", GetTotalTiles());

	new name[24];

	for(new i; i < GetTotalTileTypes(); i++)
	{
		GetTileName(i, name);
	 	log("Tile '%s' uses: %d", name, GetTileUses(i));
	}

	print("\n\n\n");
}
