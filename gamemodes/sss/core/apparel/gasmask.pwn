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

	tmp = DefineMaskItem(item_GasMask);

	SetMaskOffsetsForSkin(tmp, skin_Civ0M, 0.009000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000); // 60
	SetMaskOffsetsForSkin(tmp, skin_Civ1M, 0.009000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000); // 170
	SetMaskOffsetsForSkin(tmp, skin_Civ2M, 0.009000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000); // 250
	SetMaskOffsetsForSkin(tmp, skin_Civ3M, 0.003000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000); // 188
	SetMaskOffsetsForSkin(tmp, skin_Civ4M, 0.023000, 0.137999, 0.000000,  90.000000, 86.300010, 0.000000,  0.892999, 1.057000, 1.000000); // 207
	SetMaskOffsetsForSkin(tmp, skin_Civ5M, 0.019000, 0.136999, 0.001000,  90.000000, 80.600074, 0.000000,  0.883000, 0.958000, 1.000000); // 44

	SetMaskOffsetsForSkin(tmp, skin_MechM, 0.019000, 0.104999, -0.003999,  90.000000, 86.300010, 0.000000,  1.018999, 1.200000, 1.000000); // 50
	SetMaskOffsetsForSkin(tmp, skin_BikeM, 0.019000, 0.135999, 0.000000,  90.000000, 86.300010, 0.000000,  1.107999, 1.200000, 1.000000); // 254
	SetMaskOffsetsForSkin(tmp, skin_ArmyM, -0.006999, 0.135999, 0.005000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000); // 287
	// SetHatOffsetsForSkin(tmp, skin_TriaM, 0.116999, 0.056999, -0.002999,  0.000000, 90.000000, 83.800086,  1.074001, 1.124001, 1.000000); // 294
	SetMaskOffsetsForSkin(tmp, skin_ClawM, 0.006000, 0.127999, 0.000000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000); // 101
	SetMaskOffsetsForSkin(tmp, skin_FreeM, 0.006000, 0.139999, 0.005000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000); // 156

	SetMaskOffsetsForSkin(tmp, skin_Civ0F, 0.009000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000); // 192
	SetMaskOffsetsForSkin(tmp, skin_Civ1F, 0.006000, 0.122999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000); // 65
	SetMaskOffsetsForSkin(tmp, skin_Civ2F, -0.011999, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000); // 93
	SetMaskOffsetsForSkin(tmp, skin_Civ3F, -0.011999, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000); // 233
	SetMaskOffsetsForSkin(tmp, skin_Civ4F, 0.016000, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000); // 193
	SetMaskOffsetsForSkin(tmp, skin_ArmyF, 0.016000, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000); // 191
	SetMaskOffsetsForSkin(tmp, skin_IndiF, -0.006999, 0.131999, -0.002999,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.065000); // 131
}
