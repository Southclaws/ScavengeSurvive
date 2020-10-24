/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


/*
x positions in each zone (7 zones)
4 items, randomly spawning at these positions
7 lockups, with 4 digit codes
high value loot spawn in each lockup

lockups in interior type places avoid hackers getting in etc
sewers, garages, underground rooms, caves etc
lockups block saving characters inside to stop loot farming

SF = hotel loading bay
LS = sewer room
LV = vault
BC = cave
TR = ?
FC = ?
RC = ?
*/

#define MAX_LOCKUP	(7)

enum E_LOCKUP_DATA
{
	lck_keyCode,
	Button:lck_keyButton,
	Button:lck_extButton,
	Button:lck_intButton,
	lck_locked
}


new
	lck_Data[MAX_LOCKUP][E_LOCKUP_DATA],
	lck_Total,
	lck_CurrentLockup[MAX_PLAYERS];


hook OnGameModeInit()
{
	SetItemTypeMaxArrayData(item_CodePart, 1);
	LoadLockup_SF();
}

CreateCodeParts(const Float:coords[][], size, keycode)
{
	new
		output[16],
		code[4 char],
		Item:itemid[4],
		nameextra[4][2];

	PickFromList(size, 4, output);
	GetDigits(keycode, code);

	valstr(nameextra[0], code{0});
	valstr(nameextra[1], code{1});
	valstr(nameextra[2], code{2});
	valstr(nameextra[3], code{3});

	itemid[0] = CreateItem(item_CodePart, coords[output[0]][0], coords[output[0]][1], coords[output[0]][2]);
	itemid[1] = CreateItem(item_CodePart, coords[output[1]][0], coords[output[1]][1], coords[output[1]][2]);
	itemid[2] = CreateItem(item_CodePart, coords[output[2]][0], coords[output[2]][1], coords[output[2]][2]);
	itemid[3] = CreateItem(item_CodePart, coords[output[3]][0], coords[output[3]][1], coords[output[3]][2]);

	SetItemExtraData(itemid[0], code{0});
	SetItemExtraData(itemid[1], code{1});
	SetItemExtraData(itemid[2], code{2});
	SetItemExtraData(itemid[3], code{3});

	SetItemNameExtra(itemid[0], nameextra[0]);
	SetItemNameExtra(itemid[1], nameextra[1]);
	SetItemNameExtra(itemid[2], nameextra[2]);
	SetItemNameExtra(itemid[3], nameextra[3]);
}

CreateLockup(Button:keypadbutton, Button:extButton, Button:intButton)
{
	new keycode = 1000 + random(8999);
	lck_Data[lck_Total][lck_keyCode] = keycode;
	lck_Data[lck_Total][lck_keyButton] = keypadbutton;
	lck_Data[lck_Total][lck_extButton] = extButton;
	lck_Data[lck_Total][lck_intButton] = intButton;
	lck_Data[lck_Total][lck_locked] = 1;
	// TODO: implement LinkTP
	// LinkTP(extButton, intButton);

	lck_Total++;

	return keycode;
}

hook OnButtonPress(playerid, Button:buttonid)
{
	for(new i; i < lck_Total; i++)
	{
		if(buttonid == lck_Data[i][lck_keyButton])
		{
			ShowKeypad(playerid, k_Lockup, lck_Data[i][lck_keyCode]);
			lck_CurrentLockup[playerid] = i;
			break;
		}

		if(buttonid == lck_Data[i][lck_extButton])
		{
			if(lck_Data[i][lck_locked])
			{
				ShowActionText(playerid, ls(playerid, "NEARBYKEYP", true));
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeypadEnter(playerid, keypadid, code, match)
{
	if(keypadid == k_Lockup)
	{
		if(code == match && lck_CurrentLockup[playerid] != -1)
		{
			lck_Data[lck_CurrentLockup[playerid]][lck_locked] = 0;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

LoadLockup_SF()
{
	new keycode = CreateLockup(
		CreateButton(-2493.90112, 313.94443, 29.72062, "Press "KEYTEXT_INTERACT" to interact"),
		CreateButton(-2499.1262, 315.1892, 29.4147, "Press "KEYTEXT_INTERACT" to go inside"),
		CreateButton(-2499.1262, 318.6712, 1036.9948, "Press "KEYTEXT_INTERACT" to leave"));

	new Float:coords[][]=
	{
		{-1988.97327, 1105.93872, 82.59016},
		{-2701.18188, 849.91577, 70.42641},
		{-1688.13623, 1331.96411, 16.24742},
		{-1896.49524, 985.39124, 44.41820},
		{-2579.95630, 330.52792, 9.55951},
		{-2134.74487, 185.65819, 45.51329},
		{-2531.18848, -709.22864, 138.31668},
		{-1478.10754, -330.93860, 13.59040}
	};

	CreateCodeParts(coords, 8, keycode);

	CreateStaticLootSpawn(-2493.80151, 311.45721, 1035.89465, GetLootIndexFromName("world_survivor"), 25, 4);
	CreateStaticLootSpawn(-2493.62427, 314.89218, 1035.89514, GetLootIndexFromName("world_survivor"), 25, 4);
	CreateStaticLootSpawn(-2501.56641, 310.20535, 1035.89514, GetLootIndexFromName("world_survivor"), 25, 4);
	CreateStaticLootSpawn(-2497.18896, 310.38626, 1035.89502, GetLootIndexFromName("world_survivor"), 25, 4);

	CreateDynamicObject(19273, -2493.90112, 313.94443, 29.72062,   0.00000, 0.00000, -110.21997);
	CreateDynamicObject(8948, -2499.05518, 319.42581, 1037.67224,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(6959, -2500.06128, 307.28314, 1035.92957,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(6959, -2500.09985, 307.30600, 1039.28417,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19456, -2502.83081, 314.66580, 1037.61548,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, -2493.77051, 319.36435, 1037.61548,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, -2492.07739, 317.67090, 1037.61548,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19456, -2492.07739, 311.24710, 1037.61548,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19456, -2496.98291, 306.34109, 1037.61548,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, -2503.40552, 306.34109, 1037.61548,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19456, -2502.83081, 305.03299, 1037.61548,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1498, -2491.95313, 316.93091, 1035.86389,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14782, -2492.53320, 312.28448, 1036.85669,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1299, -2494.32324, 307.47714, 1036.33472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1421, -2496.06860, 307.20682, 1036.66418,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1440, -2498.50732, 307.49863, 1036.36182,   0.00000, 0.00000, -181.98000);
	CreateDynamicObject(1441, -2497.06030, 308.77939, 1036.52283,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2971, -2501.42505, 307.89386, 1035.86816,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1224, -2495.07227, 309.75647, 1036.50610,   0.00000, 0.00000, 24.06000);
}
