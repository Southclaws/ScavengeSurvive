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


#include <YSI_4\y_hooks>


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'policecap'...");

	new tmp;

	tmp = DefineHatItem(item_PoliceCap);

	SetHatOffsetsForSkin(tmp, skin_MainM, 0.130999, 0.038999, -0.003999,  0.000000, 90.000000, 88.000030,  1.055000, 1.077000, 1.000000); // 60
	SetHatOffsetsForSkin(tmp, skin_MainF, 0.151999, 0.037999, -0.003999,  0.000000, 90.000000, 88.000030,  1.136001, 1.097000, 1.000000); // 192

	SetHatOffsetsForSkin(tmp, skin_Civ1M, 0.130999, 0.038999, -0.003999,  0.000000, 90.000000, 88.000030,  1.055000, 1.077000, 1.000000); // 170
	SetHatOffsetsForSkin(tmp, skin_Civ2M, 0.124999, 0.037999, -0.003999,  0.000000, 90.000000, 88.000030,  1.104001, 0.947000, 1.000000); // 188
	SetHatOffsetsForSkin(tmp, skin_Civ3M, 0.124999, 0.047999, -0.002999,  0.000000, 90.000000, 88.000030,  0.906001, 0.947000, 1.000000); // 44
	SetHatOffsetsForSkin(tmp, skin_Civ4M, 0.130999, 0.050999, 0.000000,  0.000000, 90.000000, 90.000000,  1.000000, 1.000000, 1.000000); // 206
	SetHatOffsetsForSkin(tmp, skin_MechM, 0.144999, 0.016999, -0.008000,  0.000000, 90.000000, 85.300064,  1.168001, 1.079000, 1.000000); // 50
	SetHatOffsetsForSkin(tmp, skin_BikeM, 0.141999, 0.037999, -0.002999,  0.000000, 90.000000, 85.300064,  1.149001, 1.110001, 1.000000); // 254
	SetHatOffsetsForSkin(tmp, skin_ArmyM, 0.116999, 0.056999, -0.002999,  0.000000, 90.000000, 83.800086,  1.074001, 1.124001, 1.000000); // 287
	SetHatOffsetsForSkin(tmp, skin_ClawM, 0.138999, 0.043999, -0.001999,  0.000000, 90.000000, 83.800086,  1.206002, 1.161002, 1.000000); // 101
	SetHatOffsetsForSkin(tmp, skin_FreeM, 0.155999, 0.036999, -0.001999,  0.000000, 90.000000, 83.800086,  1.272003, 1.271002, 1.246000); // 156

	SetHatOffsetsForSkin(tmp, skin_Civ1F, 0.152999, 0.031999, 0.010000,  1.099999, 74.299987, 83.800086,  1.272003, 1.271002, 1.246000); // 65
	SetHatOffsetsForSkin(tmp, skin_Civ2F, 0.118999, 0.031999, 0.001000,  0.000000, 90.000000, 90.000000,  1.173999, 1.124000, 1.200000); // 93
	SetHatOffsetsForSkin(tmp, skin_Civ3F, 0.118999, 0.031999, 0.001000,  0.000000, 90.000000, 90.000000,  1.173999, 1.124000, 1.200000); // 233
	SetHatOffsetsForSkin(tmp, skin_Civ4F, 0.138999, 0.044999, 0.001000,  0.000000, 90.000000, 90.000000,  1.173999, 1.124000, 1.200000); // 193
	SetHatOffsetsForSkin(tmp, skin_ArmyF, 0.138999, 0.048999, 0.001000,  0.000000, 90.000000, 90.000000,  1.275000, 1.187000, 1.366999); // 191
	SetHatOffsetsForSkin(tmp, skin_IndiF, 0.111999, 0.054999, 0.000000,  0.000000, 90.000000, 88.099945,  1.145000, 1.043002, 1.070000); // 131
}
