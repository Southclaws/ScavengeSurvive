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


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'XmasHat'...");

	new tmp;

	tmp = DefineHatItem(item_XmasHat);

	SetHatOffsetsForSkin(tmp, skin_MainM, 0.111999, 0.022999, -0.006000,  90.000000, 102.399971, 0.000000, 1.111000, 1.064999, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_MainF, 0.137000, 0.023999, 0.003999,  90.000000, 112.000053, 0.000000,  1.092000, 1.183000, 1.000000);

	SetHatOffsetsForSkin(tmp, skin_Civ1M, 0.111999, 0.022999, -0.006000,  90.000000, 102.399971, 0.000000, 1.111000, 1.064999, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_Civ2M, 0.111999, 0.017999, -0.004000,  90.000000, 102.399971, 0.000000, 1.111000, 1.064999, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_Civ3M, 0.111999, 0.017999, 0.000000,  90.000000, 102.399971, 0.000000,  0.905999, 0.953000, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_Civ4M, 0.120999, 0.032999, 0.000999,  90.000000, 112.000053, 0.000000,  0.986999, 0.927000, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_MechM, 0.134999, -0.010000, -0.006000,  90.000000, 102.399971, 0.000000, 1.111000, 1.000000, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_BikeM, 0.127000, 0.024999, 0.000000,  90.000000, 112.000053, 0.000000, 1.133999, 1.074000, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_ArmyM, 0.111000, 0.030999, 0.006000,  90.000000, 112.000053, 0.000000,  1.133999, 1.074000, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_ClawM, 0.121000, 0.030999, 0.001999,  90.000000, 112.000053, 0.000000,  1.182999, 1.173000, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_FreeM, 0.149000, 0.009999, 0.001999,  90.000000, 112.000053, 0.000000,  1.229999, 1.275000, 1.000000);

	SetHatOffsetsForSkin(tmp, skin_Civ1F, 0.140000, -0.017001, 0.015999,  38.499973, 78.500045, 50.700004,  1.103000, 1.183000, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_Civ2F, 0.115000, 0.008998, -0.001000,  90.000000, 98.200080, 0.000000,  1.103000, 1.183000, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_Civ3F, 0.115000, 0.008998, -0.001000,  90.000000, 98.200080, 0.000000,  1.103000, 1.183000, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_Civ4F, 0.129000, 0.015998, 0.000999,  90.000000, 98.200080, 0.000000,  1.149000, 1.178001, 1.000000);
	SetHatOffsetsForSkin(tmp, skin_ArmyF, 0.131000, 0.008998, 0.000999,  90.000000, 98.200080, 0.000000,  1.216000, 1.178001, 1.055999);
	SetHatOffsetsForSkin(tmp, skin_IndiF, 0.090000, 0.025998, 0.003999,  90.000000, 98.200080, 0.000000,  1.055000, 1.178001, 1.055999);
}
