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

	tmp = DefineHatItem(item_HelmArmy);

	SetHatOffsetsForSkin(tmp, skin_Civ0M, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 60
	SetHatOffsetsForSkin(tmp, skin_Civ1M, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 170
	SetHatOffsetsForSkin(tmp, skin_Civ2M, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 250
	SetHatOffsetsForSkin(tmp, skin_Civ3M, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 188
	SetHatOffsetsForSkin(tmp, skin_Civ4M, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 207
	SetHatOffsetsForSkin(tmp, skin_Civ5M, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 44

	SetHatOffsetsForSkin(tmp, skin_MechM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 50
	SetHatOffsetsForSkin(tmp, skin_BikeM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 254
	SetHatOffsetsForSkin(tmp, skin_ArmyM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 287
	// SetHatOffsetsForSkin(tmp, skin_TriaM, 0.116999, 0.056999, -0.002999,  0.0, 0.0, 0.0,  1.0, 1.0, 1.0); // 294
	SetHatOffsetsForSkin(tmp, skin_ClawM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 101
	SetHatOffsetsForSkin(tmp, skin_FreeM, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 156

	SetHatOffsetsForSkin(tmp, skin_Civ0F, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 192
	SetHatOffsetsForSkin(tmp, skin_Civ1F, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 65
	SetHatOffsetsForSkin(tmp, skin_Civ2F, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 93
	SetHatOffsetsForSkin(tmp, skin_Civ3F, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 233
	SetHatOffsetsForSkin(tmp, skin_Civ4F, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 193
	SetHatOffsetsForSkin(tmp, skin_ArmyF, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 191
	SetHatOffsetsForSkin(tmp, skin_IndiF, 0.152291, 0.000030, -0.005790, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // 131
}

