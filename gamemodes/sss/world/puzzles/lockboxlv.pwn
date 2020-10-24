/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define LV_LOCKBOX_FILE "SSS/LockBox/LV.dat"


new
	LV_LockBox_Door1,
	LV_LockBox_Door2;


hook OnGameModeInit()
{
	new
		dr_state[2],
		File:file,
		buttonid[1];

	if(fexist(LV_LOCKBOX_FILE))
	{
		file = fopen(LV_LOCKBOX_FILE, io_read);
		fblockread(file, dr_state, 2);
		fclose(file);
	}
	else dr_state[0] = DR_STATE_OPEN;

	buttonid[0] = CreateButton(2873.9119, 924.2617, 11.3926, "Press ~k~~VEHICLE_ENTER_EXIT~ to use door");

	LV_LockBox_Door1 = CreateDoor(16637, buttonid,
		2866.5149, 918.1044, 11.2430, 0.0, 0.0, 0.0,
		2866.5149, 918.1044, 13.9973, 0.0, 0.0, 0.0,
		.movesound = 6000, .stopsound = 6002, .movespeed = 0.4, .closedelay = -1, .initstate = dr_state[0]);

	buttonid[0] = CreateButton(2877.5132, 924.3632, 11.3926, "Press ~k~~VEHICLE_ENTER_EXIT~ to use door");

	LV_LockBox_Door2 = CreateDoor(16637, buttonid,
		2871.0339, 917.9779, 11.2430, 0.0, 0.0, 180.0,
		2871.0339, 917.9779, 13.9973, 0.0, 0.0, 180.0,
		.movesound = 6000, .stopsound = 6002, .movespeed = 0.4, .closedelay = -1, .initstate = dr_state[1]);
}
hook OnGameModeExit()
{
	new
		dr_state[2],
		File:file;

	dr_state[0] = GetDoorState(LV_LockBox_Door1);
	dr_state[1] = GetDoorState(LV_LockBox_Door2);

	if(dr_state[0] == DR_STATE_OPENING)
		dr_state[0] = DR_STATE_OPEN;

	if(dr_state[0] == DR_STATE_CLOSING)
		dr_state[0] = DR_STATE_CLOSED;

	if(dr_state[1] == DR_STATE_OPENING)
		dr_state[1] = DR_STATE_OPEN;

	if(dr_state[1] == DR_STATE_CLOSING)
		dr_state[1] = DR_STATE_CLOSED;

	file = fopen(LV_LOCKBOX_FILE, io_write);
	fblockwrite(file, dr_state, 2);
	fclose(file);
}
