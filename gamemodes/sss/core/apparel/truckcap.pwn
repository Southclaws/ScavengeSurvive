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

	tmp = DefineHatItem(item_TruckCap);

	SetHatOffsetsForSkin(tmp, skin_Civ0M, 0.120000, 0.024000, -0.003000,  0.000000, 90.000000, 90.000000,  1.028000, 1.029000, 1.000000); // 60
	SetHatOffsetsForSkin(tmp, skin_Civ1M, 0.120000, 0.024000, -0.003000,  0.000000, 90.000000, 90.000000,  1.028000, 1.029000, 1.000000); // 170
	SetHatOffsetsForSkin(tmp, skin_Civ2M, 0.120000, 0.024000, -0.003000,  0.000000, 90.000000, 90.000000,  1.028000, 1.029000, 1.000000); // 170
	SetHatOffsetsForSkin(tmp, skin_Civ3M, 0.106000, 0.023000, -0.003000,  0.000000, 90.000000, 90.000000,  1.052000, 1.054001, 1.000000); // 188
	SetHatOffsetsForSkin(tmp, skin_Civ4M, 0.117000, 0.035000, -0.003000,  0.000000, 90.000000, 90.000000,  0.962000, 0.934000, 1.000000); // 206
	SetHatOffsetsForSkin(tmp, skin_Civ5M, 0.100000, 0.035000, -0.003000,  0.000000, 90.000000, 90.000000,  0.879000, 0.907001, 1.000000); // 44

	SetHatOffsetsForSkin(tmp, skin_MechM, 0.128000, 0.003000, -0.006000,  0.000000, 90.000000, 90.000000,  1.123000, 0.990000, 1.000000); // 50
	SetHatOffsetsForSkin(tmp, skin_BikeM, 0.128000, 0.030000, 0.002000,  0.000000, 90.000000, 85.000030,  1.123000, 1.083000, 1.000000); // 254
	SetHatOffsetsForSkin(tmp, skin_ArmyM, 0.095000, 0.038000, 0.002000,  0.000000, 90.000000, 85.000030,  1.123000, 1.083000, 1.000000); // 287
	// SetHatOffsetsForSkin(tmp, skin_TriaM, 0.116999, 0.056999, -0.002999,  0.000000, 90.000000, 83.800086,  1.074001, 1.124001, 1.000000); // 294
	SetHatOffsetsForSkin(tmp, skin_ClawM, 0.114000, 0.033000, 0.002000,  0.000000, 90.000000, 88.599983,  1.161000, 1.136000, 1.000000); // 101
	SetHatOffsetsForSkin(tmp, skin_FreeM, 0.133000, 0.021000, -0.000999,  0.000000, 90.000000, 88.599983,  1.282000, 1.258000, 1.000000); // 156

	SetHatOffsetsForSkin(tmp, skin_Civ0F, 0.131000, 0.023000, -0.003000,  0.000000, 90.000000, 90.000000,  1.062000, 1.107001, 1.000000); // 192
	SetHatOffsetsForSkin(tmp, skin_Civ1F, 0.133000, 0.021000, -0.000999,  0.799999, 76.000000, 88.599983,  1.231000, 1.302000, 1.000000); // 65
	SetHatOffsetsForSkin(tmp, skin_Civ2F, 0.110000, 0.021000, -0.000999,  0.000000, 90.000000, 90.000000,  1.123999, 1.094000, 1.000000); // 93
	SetHatOffsetsForSkin(tmp, skin_Civ3F, 0.110000, 0.021000, -0.000999,  0.000000, 90.000000, 90.000000,  1.123999, 1.094000, 1.000000); // 233
	SetHatOffsetsForSkin(tmp, skin_Civ4F, 0.133000, 0.021000, -0.000999,  0.000000, 90.000000, 90.000000,  1.123999, 1.094000, 1.000000); // 193
	SetHatOffsetsForSkin(tmp, skin_ArmyF, 0.134000, 0.028000, -0.000999,  0.000000, 90.000000, 90.000000,  1.234999, 1.094000, 1.000000); // 191
	SetHatOffsetsForSkin(tmp, skin_IndiF, 0.092000, 0.041000, -0.003999,  0.000000, 90.000000, 88.200027,  1.162999, 1.106000, 1.000000); // 131
}
