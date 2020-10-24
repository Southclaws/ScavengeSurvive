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

	tmp = DefineMaskItem(item_HockeyMask);

	SetMaskOffsetsForSkin(tmp, skin_Civ0M, 0.092999, 0.041000, -0.007000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000); // 60
	SetMaskOffsetsForSkin(tmp, skin_Civ1M, 0.092999, 0.041000, -0.006000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000); // 170
	SetMaskOffsetsForSkin(tmp, skin_Civ2M, 0.092999, 0.041000, -0.006000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000); // 250
	SetMaskOffsetsForSkin(tmp, skin_Civ3M, 0.095999, 0.035000, -0.001999,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000); // 188
	SetMaskOffsetsForSkin(tmp, skin_Civ4M, 0.109999, 0.038000, -0.001999,  90.000000, 90.000000, 0.000000,  0.964999, 1.000000, 1.034000); // 207
	SetMaskOffsetsForSkin(tmp, skin_Civ5M, 0.089999, 0.037000, -0.001999,  90.000000, 90.000000, 0.000000,  0.915000, 1.000000, 0.988000); // 44

	SetMaskOffsetsForSkin(tmp, skin_MechM, 0.106999, 0.017000, -0.009000,  90.000000, 90.000000, 0.000000,  0.964999, 1.000000, 1.034000); // 50
	SetMaskOffsetsForSkin(tmp, skin_BikeM, 0.108000, 0.045000, -0.003999,  90.000000, 90.000000, 0.000000,  0.964999, 1.181999, 1.292000); // 254
	SetMaskOffsetsForSkin(tmp, skin_ArmyM, 0.054999, 0.025000, 0.005999,  89.000022, 81.200004, 0.000000,  0.932000, 0.987000, 1.000000); // 287
	// SetHatOffsetsForSkin(tmp, skin_TriaM, 0.116999, 0.056999, -0.002999,  0.000000, 90.000000, 83.800086,  1.074001, 1.124001, 1.000000); // 294
	SetMaskOffsetsForSkin(tmp, skin_ClawM, 0.092000, 0.037999, 0.000000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000); // 101
	SetMaskOffsetsForSkin(tmp, skin_FreeM, 0.092000, 0.031999, 0.000000,  90.000000, 90.000000, 0.000000,  1.000000, 1.180999, 1.266000); // 156

	SetMaskOffsetsForSkin(tmp, skin_Civ0F, 0.092999, 0.041000, -0.004000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000); // 192
	SetMaskOffsetsForSkin(tmp, skin_Civ1F, 0.075000, 0.032000, 0.000000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000); // 65
	SetMaskOffsetsForSkin(tmp, skin_Civ2F, 0.064999, 0.035999, -0.004999,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000); // 93
	SetMaskOffsetsForSkin(tmp, skin_Civ3F, 0.064999, 0.035999, -0.004999,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000); // 233
	SetMaskOffsetsForSkin(tmp, skin_Civ4F, 0.098999, 0.024999, -0.002999,  90.000000, 90.000000, 0.000000,  1.131000, 1.096999, 1.190000); // 193
	SetMaskOffsetsForSkin(tmp, skin_ArmyF, 0.095999, 0.028999, -0.002999,  90.000000, 90.000000, 0.000000,  1.131000, 1.096999, 1.092000); // 191
	SetMaskOffsetsForSkin(tmp, skin_IndiF, 0.081999, 0.027999, 0.000000,  90.000000, 90.000000, 0.000000,  1.059001, 1.193000, 1.132000); // 131
}
