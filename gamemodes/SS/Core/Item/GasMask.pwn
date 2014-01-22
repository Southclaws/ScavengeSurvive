public OnLoad()
{
	new tmp;

	tmp = DefineMaskItem(item_GasMask);

	SetMaskOffsetsForSkin(tmp, skin_MainM, 0.009000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_MainF, 0.009000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000);

	SetMaskOffsetsForSkin(tmp, skin_Civ1M, 0.009000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ2M, 0.003000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ3M, 0.019000, 0.136999, 0.001000,  90.000000, 80.600074, 0.000000,  0.883000, 0.958000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ4M, 0.023000, 0.137999, 0.000000,  90.000000, 86.300010, 0.000000,  0.892999, 1.057000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_MechM, 0.019000, 0.104999, -0.003999,  90.000000, 86.300010, 0.000000,  1.018999, 1.200000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_BikeM, 0.019000, 0.135999, 0.000000,  90.000000, 86.300010, 0.000000,  1.107999, 1.200000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_ArmyM, -0.006999, 0.135999, 0.005000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_ClawM, 0.006000, 0.127999, 0.000000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_FreeM, 0.006000, 0.139999, 0.005000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);

	SetMaskOffsetsForSkin(tmp, skin_Civ1F, 0.006000, 0.122999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ2F, -0.011999, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ3F, -0.011999, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ4F, 0.016000, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_ArmyF, 0.016000, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_IndiF, -0.006999, 0.131999, -0.002999,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.065000);

	#if defined gmask_OnLoad
        gmask_OnLoad();
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad gmask_OnLoad
#if defined gmask_OnLoad
    forward gmask_OnLoad();
#endif

