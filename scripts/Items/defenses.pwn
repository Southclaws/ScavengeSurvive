new
	ItemType:item_Door			= INVALID_ITEM_TYPE,
	ItemType:item_MetPanel		= INVALID_ITEM_TYPE,
	ItemType:item_SurfBoard		= INVALID_ITEM_TYPE,
	ItemType:item_CrateDoor		= INVALID_ITEM_TYPE,
	ItemType:item_CorPanel		= INVALID_ITEM_TYPE,
	ItemType:item_ShipDoor		= INVALID_ITEM_TYPE,
	ItemType:item_MetalPlate	= INVALID_ITEM_TYPE,
	ItemType:item_MetalStand	= INVALID_ITEM_TYPE,
	ItemType:item_WoodDoor		= INVALID_ITEM_TYPE,
	ItemType:item_WoodPanel		= INVALID_ITEM_TYPE;


public OnLoad()
{
	DefineDefenseItem(item_Door,		180.0000, 90.0000, 0.0000, -0.0331, 1);
	DefineDefenseItem(item_MetPanel,	90.0000, 90.0000, 0.0000, -0.0092, 2);
	DefineDefenseItem(item_SurfBoard,	90.0000, 0.0000, 0.0000, 0.2650, 1);
	DefineDefenseItem(item_CrateDoor,	0.0000, 90.0000, 0.0000, 0.7287, 3);
	DefineDefenseItem(item_CorPanel,	0.0000, 90.0000, 0.0000, 1.1859, 2);
	DefineDefenseItem(item_ShipDoor,	90.0000, 90.0000, 0.0000, 1.3966, 4);
	DefineDefenseItem(item_MetalPlate,	90.0000, 90.0000, 0.0000, 2.1143, 4);
	DefineDefenseItem(item_MetalStand,	90.0000, 0.0000, 0.0000, 0.5998, 3);
	DefineDefenseItem(item_WoodDoor,	90.0000, 90.0000, 0.0000, -0.0160, 1);
	DefineDefenseItem(item_WoodPanel,	90.0000, 0.0000, 20.0000, 1.0284, 3);

	return CallLocalFunction("def_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad def_OnLoad
forward def_OnLoad();

