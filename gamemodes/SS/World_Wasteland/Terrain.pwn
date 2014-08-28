#include <YSI\y_hooks>


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Terrain'...");

	LoadTiles();
	GenerateTerrain(285645);
}
