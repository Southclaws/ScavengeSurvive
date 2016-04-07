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
	print("\n[OnScriptInit] Initialising 'zorromask'...");

	new tmp;

	tmp = DefineMaskItem(item_ZorroMask);

	SetMaskOffsetsForSkin(tmp, skin_MainM, 0.084736, 0.033890, -0.001497, 90.0, 90.0, 0.0, 1.100000, 1.200000, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_MainF, 0.083829, 0.034189, -0.000001, 90.0, 90.0, 0.0, 1.0, 1.0, 1.0);

	SetMaskOffsetsForSkin(tmp, skin_Civ1M, 0.084736, 0.033890, -0.001497, 90.0, 90.0, 0.0, 1.100000, 1.200000, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_Civ2M, 0.084736, 0.033890, -0.001497, 90.0, 90.0, 0.0, 1.100000, 1.200000, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_Civ3M, 0.084736, 0.033890, -0.001497, 90.0, 90.0, 0.0, 1.0, 1.0, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_Civ4M, 0.100977, 0.038188, -0.001497, 90.0, 90.0, 0.0, 1.0, 1.0, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_MechM, 0.101776, 0.007677, -0.004035, 90.0, 90.0, 0.0, 1.100000, 1.159999, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_BikeM, 0.099304, 0.027807, 0.001974, 90.0, 90.0, 0.0, 1.200000, 1.129999, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_ArmyM, 0.084736, 0.033890, -0.001497, 90.0, 90.0, 0.0, 1.100000, 1.200000, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_ClawM, 0.091096, 0.024014, -0.000001, 90.0, 90.0, 0.0, 1.200000, 1.129999, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_FreeM, 0.083829, 0.017114, -0.000001, 90.0, 90.0, 0.0, 1.299999, 1.299999, 1.0);

	SetMaskOffsetsForSkin(tmp, skin_Civ1F, 0.083829, 0.034189, -0.000001, 90.0, 90.0, 0.0, 1.0, 1.0, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_Civ2F, 0.062500, 0.030794, -0.000001, 90.0, 90.0, 0.0, 1.200000, 1.179999, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_Civ3F, 0.062500, 0.030794, -0.000001, 90.0, 90.0, 0.0, 1.200000, 1.179999, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_Civ4F, 0.089004, 0.030794, -0.000001, 90.0, 90.0, 0.0, 1.200000, 1.179999, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_ArmyF, 0.087324, 0.030794, -0.000001, 90.0, 90.0, 0.0, 1.200000, 1.179999, 1.0);
	SetMaskOffsetsForSkin(tmp, skin_IndiF, 0.069696, 0.031932, -0.000001, 90.0, 90.0, 0.0, 1.100000, 1.200000, 1.0);
}
