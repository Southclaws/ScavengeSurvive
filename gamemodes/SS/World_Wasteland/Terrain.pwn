public OnLoad()
{
	LoadTiles();
	GenerateTerrain(285645);

	#if defined ter_OnLoad
        ter_OnLoad();
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad ter_OnLoad
#if defined ter_OnLoad
    forward ter_OnLoad();
#endif
