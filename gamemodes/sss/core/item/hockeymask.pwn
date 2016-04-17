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
	print("\n[OnScriptInit] Initialising 'HockeyMask'...");

	new tmp;

	tmp = DefineMaskItem(item_HockeyMask);

	SetMaskOffsetsForSkin(tmp, skin_MainM, 0.092999, 0.041000, -0.007000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_MainF, 0.092999, 0.041000, -0.004000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ1M, 0.092999, 0.041000, -0.006000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ2M, 0.095999, 0.035000, -0.001999,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ3M, 0.089999, 0.037000, -0.001999,  90.000000, 90.000000, 0.000000,  0.915000, 1.000000, 0.988000);
	SetMaskOffsetsForSkin(tmp, skin_Civ4M, 0.109999, 0.038000, -0.001999,  90.000000, 90.000000, 0.000000,  0.964999, 1.000000, 1.034000);
	SetMaskOffsetsForSkin(tmp, skin_MechM, 0.106999, 0.017000, -0.009000,  90.000000, 90.000000, 0.000000,  0.964999, 1.000000, 1.034000);
	SetMaskOffsetsForSkin(tmp, skin_BikeM, 0.108000, 0.045000, -0.003999,  90.000000, 90.000000, 0.000000,  0.964999, 1.181999, 1.292000);
	SetMaskOffsetsForSkin(tmp, skin_ArmyM, 0.054999, 0.025000, 0.005999,  89.000022, 81.200004, 0.000000,  0.932000, 0.987000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_ClawM, 0.092000, 0.037999, 0.000000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_FreeM, 0.092000, 0.031999, 0.000000,  90.000000, 90.000000, 0.000000,  1.000000, 1.180999, 1.266000);
	SetMaskOffsetsForSkin(tmp, skin_Civ1F, 0.075000, 0.032000, 0.000000,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ2F, 0.064999, 0.035999, -0.004999,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ3F, 0.064999, 0.035999, -0.004999,  90.000000, 90.000000, 0.000000,  1.000000, 1.000000, 1.000000);
	SetMaskOffsetsForSkin(tmp, skin_Civ4F, 0.098999, 0.024999, -0.002999,  90.000000, 90.000000, 0.000000,  1.131000, 1.096999, 1.190000);
	SetMaskOffsetsForSkin(tmp, skin_ArmyF, 0.095999, 0.028999, -0.002999,  90.000000, 90.000000, 0.000000,  1.131000, 1.096999, 1.092000);
	SetMaskOffsetsForSkin(tmp, skin_IndiF, 0.081999, 0.027999, 0.000000,  90.000000, 90.000000, 0.000000,  1.059001, 1.193000, 1.132000);
}
