new
	ItemType:item_HelmArmy = INVALID_ITEM_TYPE;


public OnLoad()
{
	new tmp;

	tmp = DefineHatItem(item_HelmArmy);

	SetHatOffsetsForSkin(tmp, skin_MainM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_MainF, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);

	SetHatOffsetsForSkin(tmp, skin_Civ1M, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_Civ2M, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_Civ3M, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_Civ4M, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_MechM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_BikeM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_ArmyM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_ClawM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_FreeM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);

	SetHatOffsetsForSkin(tmp, skin_Civ1F, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_Civ2F, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_Civ3F, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_Civ4F, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_ArmyF, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetHatOffsetsForSkin(tmp, skin_IndiF, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);

	return CallLocalFunction("army_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad army_OnLoad
forward army_OnLoad();

