/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'armyhelm'...");

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

