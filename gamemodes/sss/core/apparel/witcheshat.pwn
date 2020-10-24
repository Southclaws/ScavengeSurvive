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

	tmp = DefineHatItem(item_WitchesHat);

	SetHatOffsetsForSkin(tmp, skin_Civ0M, 0.137000, 0.003000, 0.003000,  1.900000, -6.299999, -12.099997,  1.000000, 1.000000, 1.000000); // 60
	SetHatOffsetsForSkin(tmp, skin_Civ1M, 0.136000, -0.001999, 0.007999,  1.900000, -6.299999, -12.099997,  0.993999, 1.085000, 0.954999); // 170
	SetHatOffsetsForSkin(tmp, skin_Civ2M, 0.136000, -0.001999, 0.007999,  1.900000, -6.299999, -12.099997,  0.993999, 1.085000, 0.954999); // 170
	SetHatOffsetsForSkin(tmp, skin_Civ3M, 0.126000, -0.001999, 0.009999,  1.900000, -6.299999, -12.099997,  0.993999, 1.085000, 0.954999); // 188
	SetHatOffsetsForSkin(tmp, skin_Civ4M, 0.143000, 0.011000, 0.003999,  0.900000, -4.800001, -14.999998,  0.848999, 1.085000, 0.846999); // 206
	SetHatOffsetsForSkin(tmp, skin_Civ5M, 0.122000, -0.001999, 0.004999,  1.900000, -6.800000, -19.499998,  0.829999, 1.085000, 0.846999); // 44

	SetHatOffsetsForSkin(tmp, skin_MechM, 0.156000, -0.017999, 0.000999,  -4.900000, -3.900000, -13.399996,  0.983999, 1.159999, 0.898999); // 50
	SetHatOffsetsForSkin(tmp, skin_BikeM, 0.156000, -0.002999, 0.000999,  -4.900000, -3.900000, -13.399996,  0.983999, 1.159999, 0.898999); // 254
	SetHatOffsetsForSkin(tmp, skin_ArmyM, 0.080000, 0.033000, 0.000999,  -4.900000, -3.900000, -13.399996,  1.187999, 1.344999, 1.119999); // 287
	// SetHatOffsetsForSkin(tmp, skin_TriaM, 0.116999, 0.056999, -0.002999,  0.000000, 90.000000, 83.800086,  1.074001, 1.124001, 1.000000); // 294
	SetHatOffsetsForSkin(tmp, skin_ClawM, 0.148000, -0.004999, -0.015999,  -4.900000, -3.900000, -13.399996,  1.218000, 1.246999, 1.033999); // 101
	SetHatOffsetsForSkin(tmp, skin_FreeM, 0.164000, -0.008999, 0.004000,  -4.900000, -3.900000, -13.399996,  1.187000, 1.246999, 1.033999); // 156

	SetHatOffsetsForSkin(tmp, skin_Civ0F, 0.171000, -0.001999, 0.008999,  1.900000, -6.299999, -12.099997,  0.993999, 1.085000, 0.954999); // 192
	SetHatOffsetsForSkin(tmp, skin_Civ1F, 0.145000, -0.005999, 0.008000,  -4.000000, 9.100001, -27.499994,  1.361000, 1.170999, 1.223999); // 65
	SetHatOffsetsForSkin(tmp, skin_Civ2F, 0.145000, 0.003000, 0.005999,  0.000000, 0.000000, 0.000000,  0.977000, 1.184999, 1.080999); // 93
	SetHatOffsetsForSkin(tmp, skin_Civ3F, 0.129000, 0.011000, 0.005999,  0.000000, 0.000000, 0.000000,  0.977000, 1.184999, 1.080999); // 233
	SetHatOffsetsForSkin(tmp, skin_Civ4F, 0.138000, 0.013000, 0.005999,  0.000000, 0.000000, 0.000000,  1.066000, 1.241999, 1.142999); // 193
	SetHatOffsetsForSkin(tmp, skin_ArmyF, 0.154000, 0.006000, -0.000999,  0.000000, 0.000000, 0.000000,  1.066000, 1.241999, 1.142999); // 191
	SetHatOffsetsForSkin(tmp, skin_IndiF, 0.129000, 0.006000, -0.000999,  0.000000, 0.000000, -9.799999,  1.066000, 1.241999, 1.142999); // 131
}