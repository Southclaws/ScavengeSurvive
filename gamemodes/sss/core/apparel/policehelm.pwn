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

	tmp = DefineHatItem(item_PoliceHelm);

	SetHatOffsetsForSkin(tmp, skin_Civ0M, 0.121999, 0.001999, -0.006999,  0.000000, 0.000000, 0.000000,  1.00000, 1.00000, 1.17); // 60
	SetHatOffsetsForSkin(tmp, skin_Civ1M, 0.121999, 0.001999, -0.006999,  0.000000, 0.000000, 0.000000,  1.00000, 1.00000, 1.17); // 170
	SetHatOffsetsForSkin(tmp, skin_Civ2M, 0.121999, 0.001999, -0.006999,  0.000000, 0.000000, 0.000000,  1.00000, 1.00000, 1.17); // 250
	SetHatOffsetsForSkin(tmp, skin_Civ3M, 0.121999, 0.001999, -0.006999,  0.000000, 0.000000, 0.000000,  1.00000, 1.00000, 1.17); // 188
	SetHatOffsetsForSkin(tmp, skin_Civ4M, 0.140999, 0.025030, -0.002789,  0.000000, 0.000000, 0.000000,  1.000000, 1.000000, 1.00); // 206
	SetHatOffsetsForSkin(tmp, skin_Civ5M, 0.116998, 0.019030, -0.002789,  0.000000, 0.000000, 0.000000,  1.000000, 1.000000, 1.00); // 44

	SetHatOffsetsForSkin(tmp, skin_MechM, 0.121999, 0.001999, -0.006999,  0.000000, 0.000000, 0.000000,  1.036000, 1.041000, 1.159); // 50
	SetHatOffsetsForSkin(tmp, skin_BikeM, 0.119998, 0.021030, -0.002789,  0.000000, 0.000000, 0.000000,  1.000000, 1.106000, 1.10); // 254
	SetHatOffsetsForSkin(tmp, skin_ArmyM, 0.093998, 0.040029, 0.005210,  0.000000, 0.000000, 0.000000,  1.000000, 1.169000, 1.10); // 287
	// SetHatOffsetsForSkin(tmp, skin_TriaM, 0.116999, 0.056999, -0.002999,  0.000000, 90.000000, 83.800086,  1.074001, 1.124001, 1.000000); // 294
	SetHatOffsetsForSkin(tmp, skin_ClawM, 0.123998, 0.023029, 0.005210,  0.000000, 0.000000, 0.000000,  1.000000, 1.068000, 1.100000); // 101
	SetHatOffsetsForSkin(tmp, skin_FreeM, 0.123998, 0.019029, 0.003210,  0.000000, 0.000000, 0.000000,  1.000000, 1.175000, 1.106000); // 156

	SetHatOffsetsForSkin(tmp, skin_Civ0F, 0.121999, 0.009030, -0.005789,  0.000000, 0.000000, 0.000000,  1.000000, 1.084000, 1.17); // 192
	SetHatOffsetsForSkin(tmp, skin_Civ1F, 0.109998, 0.011029, -0.006789,  0.000000, 5.199999, -4.199999,  1.000000, 1.113000, 1.053000); // 65
	SetHatOffsetsForSkin(tmp, skin_Civ2F, 0.089998, 0.018029, -0.000789,  0.000000, 0.000000, 0.000000,  1.000000, 1.042000, 1.014000); // 93
	SetHatOffsetsForSkin(tmp, skin_Civ3F, 0.089998, 0.018029, -0.000789,  0.000000, 0.000000, 0.000000,  1.000000, 1.042000, 1.014000); // 233
	SetHatOffsetsForSkin(tmp, skin_Civ4F, 0.123998, 0.018029, 0.001210,  0.000000, 0.000000, 0.000000,  1.000000, 1.042000, 1.014000); // 193
	SetHatOffsetsForSkin(tmp, skin_ArmyF, 0.122998, 0.022029, 0.000210,  0.000000, 0.000000, 0.000000,  1.000000, 1.072000, 1.074000); // 191
	SetHatOffsetsForSkin(tmp, skin_IndiF, 0.099998, 0.022029, 0.000210,  0.000000, 0.000000, 0.000000,  1.000000, 1.072000, 1.074000); // 131
}
