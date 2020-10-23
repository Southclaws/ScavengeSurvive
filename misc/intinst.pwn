/*==============================================================================


	Southclaws's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaws" Keene

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


static
	inst_EntButtonID[MAX_INTERIOR_INSTANCE],
	inst_IntButtonID[MAX_INTERIOR_INSTANCE],
	inst_EntButtonInst[BTN_MAX],
	inst_IntButtonInst[BTN_MAX],
	inst_Total;


stock CreateInteriorInstanceLink(Float:entx, Float:enty, Float:entz, Float:intx, Float:inty, Float:intz, text = "Press "KEYTEXT_INTERACT" to enter", world = 0, labeltext = "", labelcolour = 0xFFFF00FF, streamdist = BTN_DEFAULT_STREAMDIST)
{
	inst_EntButtonID[inst_Total] = CreateButton(entx, enty, entz, text, world, 0, _, 1, labeltext, labelcolour, streamdist);
	inst_IntButtonID[inst_Total] = CreateButton(intx, inty, intz, text, world, 0, _, 1, labeltext, labelcolour, streamdist);

	inst_EntButtonInst[inst_EntButtonID[inst_Total]] = inst_Total;
	inst_IntButtonInst[inst_IntButtonID[inst_Total]] = inst_Total;

	return inst_Total++;
}
