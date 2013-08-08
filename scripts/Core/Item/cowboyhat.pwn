public OnLoad()
{
	new tmp;

	tmp = DefineHatItem(item_CowboyHat);

	SetHatOffsetsForSkin(tmp, skin_MainM, 0.153999, 0.008999, -0.009000,  0.153999, 0.008999, -0.009000,  1.000000, 1.181999, 1.121000);
	SetHatOffsetsForSkin(tmp, skin_MainF, 0.165000, 0.006000, -0.007000,  0.165000, 0.006000, -0.007000,  1.000000, 1.150001, 1.049000);

	SetHatOffsetsForSkin(tmp, skin_Civ1M, 0.165000, 0.006000, -0.007000,  0.165000, 0.006000, -0.007000,  1.000000, 1.150001, 1.049000);
	SetHatOffsetsForSkin(tmp, skin_Civ2M, 0.165000, 0.006000, -0.007000,  0.165000, 0.006000, -0.007000,  1.000000, 1.150001, 1.049000);
	SetHatOffsetsForSkin(tmp, skin_Civ3M, 0.127000, 0.019999, -0.004000,  0.000000, 0.000000, 0.000000,  1.000000, 0.945000, 0.977999);
	SetHatOffsetsForSkin(tmp, skin_Civ4M, 0.158000, 0.016999, -0.004000,  0.000000, 0.000000, 0.000000,  1.000000, 1.071999, 1.035000);
	SetHatOffsetsForSkin(tmp, skin_MechM, 0.137000, 0.010000, -0.005000,  0.137000, 0.010000, -0.005000,  1.000000, 1.075001, 1.062000);
	SetHatOffsetsForSkin(tmp, skin_BikeM, 0.153000, -0.005999, -0.006000,  0.153000, -0.005999, -0.006000,  1.016000, 1.210001, 1.113001);
	SetHatOffsetsForSkin(tmp, skin_ArmyM, 0.122000, 0.015000, -0.001000,  0.122000, 0.015000, -0.001000,  1.016000, 1.210001, 1.113001);
	SetHatOffsetsForSkin(tmp, skin_ClawM, 0.130000, 0.010000, -0.003000,  0.130000, 0.010000, -0.003000,  1.019000, 1.413001, 1.263001);
	SetHatOffsetsForSkin(tmp, skin_FreeM, 0.160000, -0.012999, -0.007000,  0.160000, -0.012999, -0.007000,  1.019000, 1.413001, 1.263001);

	SetHatOffsetsForSkin(tmp, skin_Civ1F, 0.121000, -0.006999, -0.027000,  0.121000, -0.006999, -0.027000,  1.096000, 1.385002, 1.554001);
	SetHatOffsetsForSkin(tmp, skin_Civ2F, 0.154000, -0.025999, -0.007000,  0.154000, -0.025999, -0.007000,  1.096000, 1.413001, 1.209001);
	SetHatOffsetsForSkin(tmp, skin_Civ3F, 0.154000, -0.025999, -0.007000,  0.154000, -0.025999, -0.007000,  1.096000, 1.413001, 1.209001);
	SetHatOffsetsForSkin(tmp, skin_Civ4F, 0.154000, 0.003000, -0.005000,  0.154000, 0.003000, -0.005000,  1.096000, 1.236001, 1.120001);
	SetHatOffsetsForSkin(tmp, skin_ArmyF, 0.154000, 0.009000, -0.003000,  0.154000, 0.009000, -0.003000,  1.096000, 1.427002, 1.206001);
	SetHatOffsetsForSkin(tmp, skin_IndiF, 0.121000, 0.009000, -0.006000,  0.121000, 0.009000, -0.006000,  1.096000, 1.191002, 1.160001);

	return CallLocalFunction("cbhat_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad cbhat_OnLoad
forward cbhat_OnLoad();

