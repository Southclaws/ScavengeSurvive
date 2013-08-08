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
	lck_keyButton,
	lck_extButton,
	lck_intButton,
	lck_locked
}


new
	lck_Data[MAX_LOCKUP][E_LOCKUP_DATA],
	lck_Total,
	lck_CurrentLockup[MAX_PLAYERS];


public OnLoad()
{
	LoadLockup_SF();

	return CallLocalFunction("lck_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad lck_OnLoad
forward lck_OnLoad();

CreateCodeParts(Float:coords[][], size, keycode)
{
	new
		output[16],
		code[4 char],
		itemid[4],
		nameextra[4][2];

	PickFromList(size, 4, output);
	GetDigits(keycode, code);

	valstr(nameextra[0], code{0});
	valstr(nameextra[1], code{1});
	valstr(nameextra[2], code{2});
	valstr(nameextra[3], code{3});

	itemid[0] = CreateItem(item_CodePart, coords[output[0]][0], coords[output[0]][1], coords[output[0]][2], .zoffset = FLOOR_OFFSET);
	itemid[1] = CreateItem(item_CodePart, coords[output[1]][0], coords[output[1]][1], coords[output[1]][2], .zoffset = FLOOR_OFFSET);
	itemid[2] = CreateItem(item_CodePart, coords[output[2]][0], coords[output[2]][1], coords[output[2]][2], .zoffset = FLOOR_OFFSET);
	itemid[3] = CreateItem(item_CodePart, coords[output[3]][0], coords[output[3]][1], coords[output[3]][2], .zoffset = FLOOR_OFFSET);

	SetItemExtraData(itemid[0], code{0});
	SetItemExtraData(itemid[1], code{1});
	SetItemExtraData(itemid[2], code{2});
	SetItemExtraData(itemid[3], code{3});

	SetItemNameExtra(itemid[0], nameextra[0]);
	SetItemNameExtra(itemid[1], nameextra[1]);
	SetItemNameExtra(itemid[2], nameextra[2]);
	SetItemNameExtra(itemid[3], nameextra[3]);
}

CreateLockup(keypadbutton, extButton, intButton)
{
	new keycode = 1000 + random(8999);
	lck_Data[lck_Total][lck_keyCode] = keycode;
	lck_Data[lck_Total][lck_keyButton] = keypadbutton;
	lck_Data[lck_Total][lck_extButton] = extButton;
	lck_Data[lck_Total][lck_intButton] = intButton;
	lck_Data[lck_Total][lck_locked] = 1;
	LinkTP(extButton, intButton);

	lck_Total++;

	return keycode;
}

public OnButtonPress(playerid, buttonid)
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
				ShowActionText(playerid, "This door is electronically locked controlled by a nearby keypad.");
				return 1;
			}
		}
	}

	return CallLocalFunction("lck_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress lck_OnButtonPress
forward lck_OnButtonPress(playerid, buttonid);

public OnPlayerKeypadEnter(playerid, keypadid, success)
{
	if(keypadid == k_Lockup)
	{
		if(success && lck_CurrentLockup[playerid] != -1)
		{
			lck_Data[lck_CurrentLockup[playerid]][lck_locked] = 0;
		}
	}

	return CallLocalFunction("lck_OnPlayerKeypadEnter", "ddd", playerid, keypadid, success);
}
#if defined _ALS_OnPlayerKeypadEnter
	#undef OnPlayerKeypadEnter
#else
	#define _ALS_OnPlayerKeypadEnter
#endif
#define OnPlayerKeypadEnter lck_OnPlayerKeypadEnter
forward lck_OnPlayerKeypadEnter(playerid, keypadid, success);


LoadLockup_SF()
{
	new keycode = CreateLockup(
		CreateButton(-2493.90112, 313.94443, 29.72062, "Press "#KEYTEXT_INTERACT" to interact"),
		CreateButton(-2499.1262, 315.1892, 29.4147, "Press "#KEYTEXT_INTERACT" to go inside"),
		CreateButton(-2499.1262, 318.6712, 1036.9948, "Press "#KEYTEXT_INTERACT" to leave"));

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

	CreateLootSpawn(-2493.80151, 311.45721, 1035.89465, 4, 25, loot_Survivor);
	CreateLootSpawn(-2493.62427, 314.89218, 1035.89514, 4, 25, loot_Survivor);
	CreateLootSpawn(-2501.56641, 310.20535, 1035.89514, 4, 25, loot_Survivor);
	CreateLootSpawn(-2497.18896, 310.38626, 1035.89502, 4, 25, loot_Survivor);
}
