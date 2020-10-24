/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnGameModeInit()
{
	new tmp;

	tmp = DefineHatItem(item_BoaterHat);

	SetHatOffsetsForSkin(tmp, skin_Civ0M, 0.153999, 0.008999, -0.009000,  0.153999, 0.008999, -0.009000,  1.000000, 1.181999, 1.121000); // 60
	SetHatOffsetsForSkin(tmp, skin_Civ1M, 0.165000, 0.006000, -0.007000,  0.165000, 0.006000, -0.007000,  1.000000, 1.150001, 1.049000); // 170
	SetHatOffsetsForSkin(tmp, skin_Civ2M, 0.165000, 0.006000, -0.007000,  0.165000, 0.006000, -0.007000,  1.000000, 1.150001, 1.049000); // 250
	SetHatOffsetsForSkin(tmp, skin_Civ3M, 0.165000, 0.006000, -0.007000,  0.165000, 0.006000, -0.007000,  1.000000, 1.150001, 1.049000); // 188
	SetHatOffsetsForSkin(tmp, skin_Civ4M, 0.137000, 0.010000, -0.005000,  0.137000, 0.010000, -0.005000,  1.000000, 1.075001, 1.062000); // 207
	SetHatOffsetsForSkin(tmp, skin_Civ5M, 0.123000, 0.002999, -0.001000,  0.123000, 0.002999, -0.001000,  1.000000, 1.075001, 0.945000); // 44

	SetHatOffsetsForSkin(tmp, skin_MechM, 0.137000, 0.010000, -0.005000,  0.137000, 0.010000, -0.005000,  1.000000, 1.075001, 1.062000); // 50
	SetHatOffsetsForSkin(tmp, skin_BikeM, 0.153000, -0.005999, -0.006000,  0.153000, -0.005999, -0.006000,  1.016000, 1.210001, 1.113001); // 254
	SetHatOffsetsForSkin(tmp, skin_ArmyM, 0.122000, 0.015000, -0.001000,  0.122000, 0.015000, -0.001000,  1.016000, 1.210001, 1.113001); // 287
	// SetHatOffsetsForSkin(tmp, skin_TriaM, 0.116999, 0.056999, -0.002999,  0.000000, 90.000000, 83.800086,  1.074001, 1.124001, 1.000000); // 294
	SetHatOffsetsForSkin(tmp, skin_ClawM, 0.130000, 0.010000, -0.003000,  0.130000, 0.010000, -0.003000,  1.019000, 1.413001, 1.263001); // 101
	SetHatOffsetsForSkin(tmp, skin_FreeM, 0.160000, -0.012999, -0.007000,  0.160000, -0.012999, -0.007000,  1.019000, 1.413001, 1.263001); // 156

	SetHatOffsetsForSkin(tmp, skin_Civ0F, 0.165000, 0.006000, -0.007000,  0.165000, 0.006000, -0.007000,  1.000000, 1.150001, 1.049000); // 192
	SetHatOffsetsForSkin(tmp, skin_Civ1F, 0.121000, -0.006999, -0.027000,  0.121000, -0.006999, -0.027000,  1.096000, 1.385002, 1.554001); // 65
	SetHatOffsetsForSkin(tmp, skin_Civ2F, 0.154000, -0.025999, -0.007000,  0.154000, -0.025999, -0.007000,  1.096000, 1.413001, 1.209001); // 93
	SetHatOffsetsForSkin(tmp, skin_Civ3F, 0.154000, -0.025999, -0.007000,  0.154000, -0.025999, -0.007000,  1.096000, 1.413001, 1.209001); // 233
	SetHatOffsetsForSkin(tmp, skin_Civ4F, 0.154000, 0.003000, -0.005000,  0.154000, 0.003000, -0.005000,  1.096000, 1.236001, 1.120001); // 193
	SetHatOffsetsForSkin(tmp, skin_ArmyF, 0.154000, 0.009000, -0.003000,  0.154000, 0.009000, -0.003000,  1.096000, 1.427002, 1.206001); // 191
	SetHatOffsetsForSkin(tmp, skin_IndiF, 0.121000, 0.009000, -0.006000,  0.121000, 0.009000, -0.006000,  1.096000, 1.191002, 1.160001); // 131
}
