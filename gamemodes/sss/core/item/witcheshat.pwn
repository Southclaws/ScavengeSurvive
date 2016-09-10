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
	print("\n[OnGameModeInit] Initialising 'WitchesHat'...");

	new tmp;

	tmp = DefineHatItem(item_WitchesHat);

	SetHatOffsetsForSkin(tmp, skin_MainM, 0.137000, 0.003000, 0.003000,  1.900000, -6.299999, -12.099997,  1.000000, 1.000000, 1.000000); //60
	SetHatOffsetsForSkin(tmp, skin_MainF, 0.171000, -0.001999, 0.008999,  1.900000, -6.299999, -12.099997,  0.993999, 1.085000, 0.954999);
	SetHatOffsetsForSkin(tmp, skin_Civ1M, 0.136000, -0.001999, 0.007999,  1.900000, -6.299999, -12.099997,  0.993999, 1.085000, 0.954999);
	SetHatOffsetsForSkin(tmp, skin_Civ2M, 0.126000, -0.001999, 0.009999,  1.900000, -6.299999, -12.099997,  0.993999, 1.085000, 0.954999);
	SetHatOffsetsForSkin(tmp, skin_Civ3M, 0.122000, -0.001999, 0.004999,  1.900000, -6.800000, -19.499998,  0.829999, 1.085000, 0.846999);
	SetHatOffsetsForSkin(tmp, skin_Civ4M, 0.143000, 0.011000, 0.003999,  0.900000, -4.800001, -14.999998,  0.848999, 1.085000, 0.846999);
	SetHatOffsetsForSkin(tmp, skin_MechM, 0.156000, -0.017999, 0.000999,  -4.900000, -3.900000, -13.399996,  0.983999, 1.159999, 0.898999);
	SetHatOffsetsForSkin(tmp, skin_BikeM, 0.156000, -0.002999, 0.000999,  -4.900000, -3.900000, -13.399996,  0.983999, 1.159999, 0.898999);
	SetHatOffsetsForSkin(tmp, skin_ArmyM, 0.080000, 0.033000, 0.000999,  -4.900000, -3.900000, -13.399996,  1.187999, 1.344999, 1.119999);
	SetHatOffsetsForSkin(tmp, skin_ClawM, 0.148000, -0.004999, -0.015999,  -4.900000, -3.900000, -13.399996,  1.218000, 1.246999, 1.033999);
	SetHatOffsetsForSkin(tmp, skin_FreeM, 0.164000, -0.008999, 0.004000,  -4.900000, -3.900000, -13.399996,  1.187000, 1.246999, 1.033999);
	SetHatOffsetsForSkin(tmp, skin_Civ1F, 0.145000, -0.005999, 0.008000,  -4.000000, 9.100001, -27.499994,  1.361000, 1.170999, 1.223999);
	SetHatOffsetsForSkin(tmp, skin_Civ2F, 0.145000, 0.003000, 0.005999,  0.000000, 0.000000, 0.000000,  0.977000, 1.184999, 1.080999);
	SetHatOffsetsForSkin(tmp, skin_Civ3F, 0.129000, 0.011000, 0.005999,  0.000000, 0.000000, 0.000000,  0.977000, 1.184999, 1.080999);
	SetHatOffsetsForSkin(tmp, skin_Civ4F, 0.138000, 0.013000, 0.005999,  0.000000, 0.000000, 0.000000,  1.066000, 1.241999, 1.142999);
	SetHatOffsetsForSkin(tmp, skin_ArmyF, 0.154000, 0.006000, -0.000999,  0.000000, 0.000000, 0.000000,  1.066000, 1.241999, 1.142999);
	SetHatOffsetsForSkin(tmp, skin_IndiF, 0.129000, 0.006000, -0.000999,  0.000000, 0.000000, -9.799999,  1.066000, 1.241999, 1.142999);
}