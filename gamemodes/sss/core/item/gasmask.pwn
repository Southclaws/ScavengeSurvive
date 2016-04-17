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
	new tmp;

	tmp = DefineMaskItem(item_GasMask);

	SetMaskOffsetsForSkin(tmp, skin_MainM, 0.009000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_MainF, 0.009000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000);

	SetMaskOffsetsForSkin(tmp, skin_Civ1M, 0.009000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ2M, 0.003000, 0.137999, -0.003999,  90.000000, 90.000000, 0.000000,  1.000000, 1.190000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ3M, 0.019000, 0.136999, 0.001000,  90.000000, 80.600074, 0.000000,  0.883000, 0.958000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ4M, 0.023000, 0.137999, 0.000000,  90.000000, 86.300010, 0.000000,  0.892999, 1.057000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_MechM, 0.019000, 0.104999, -0.003999,  90.000000, 86.300010, 0.000000,  1.018999, 1.200000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_BikeM, 0.019000, 0.135999, 0.000000,  90.000000, 86.300010, 0.000000,  1.107999, 1.200000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_ArmyM, -0.006999, 0.135999, 0.005000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_ClawM, 0.006000, 0.127999, 0.000000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_FreeM, 0.006000, 0.139999, 0.005000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);

	SetMaskOffsetsForSkin(tmp, skin_Civ1F, 0.006000, 0.122999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ2F, -0.011999, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ3F, -0.011999, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ4F, 0.016000, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_ArmyF, 0.016000, 0.129999, 0.003000,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_IndiF, -0.006999, 0.131999, -0.002999,  90.000000, 86.300010, 0.000000,  0.963999, 1.156999, 1.065000);
}
