/*==============================================================================


	Southclaws's Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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
