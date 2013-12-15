public OnLoad()
{
	LoadTiles();
	GenerateTerrain(285645);

	return CallLocalFunction("ter_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad ter_OnLoad
forward ter_OnLoad();
