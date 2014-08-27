#include <YSI\y_hooks>


hook OnGameModeInit()
{
	print("[OnGameModeInit] Initialising 'Terrain'...");

	LoadTiles();
	GenerateTerrain(285645);
}
