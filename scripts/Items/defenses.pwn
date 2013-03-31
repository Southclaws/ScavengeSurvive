public OnLoad()
{
	DefineDefenseItem(item_Door,		180.0000, 90.0000, 0.0000, -0.0331,		1, 1, 0);
	DefineDefenseItem(item_MetPanel,	90.0000, 90.0000, 0.0000, -0.0092,		2, 1, 1);
	DefineDefenseItem(item_SurfBoard,	90.0000, 0.0000, 0.0000, 0.2650,		1, 1, 1);
	DefineDefenseItem(item_CrateDoor,	0.0000, 90.0000, 0.0000, 0.7287,		3, 1, 1);
	DefineDefenseItem(item_CorPanel,	0.0000, 90.0000, 0.0000, 1.1859,		2, 1, 1);
	DefineDefenseItem(item_ShipDoor,	90.0000, 90.0000, 0.0000, 1.3966,		4, 1, 1);
	DefineDefenseItem(item_MetalPlate,	90.0000, 90.0000, 0.0000, 2.1143,		4, 1, 1);
	DefineDefenseItem(item_MetalStand,	90.0000, 0.0000, 0.0000, 0.5998,		3, 1, 1);
	DefineDefenseItem(item_WoodDoor,	90.0000, 90.0000, 0.0000, -0.0160,		1, 1, 0);
	DefineDefenseItem(item_WoodPanel,	90.0000, 0.0000, 20.0000, 1.0284,		3, 1, 1);

	return CallLocalFunction("def_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad def_OnLoad
forward def_OnLoad();

