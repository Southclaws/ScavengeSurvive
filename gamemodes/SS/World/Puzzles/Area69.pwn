new
	code_ControlTower,
	code_MainGate,
	code_AirstripGate,
	code_BlastDoor,
	code_Inner,
	code_Storage,
	code_StorageWatch,
	code_Generator,
	code_PassageTop,
	code_PassageBottom,
	code_Catwalk,
	code_Headquarters,
	code_Shaft,

	btn_ControlTower,
	btn_StorageWatch,

	lock_ControlTower,
	lock_StorageWatch,

	door_Main,
	door_Airstrip,
	door_BlastDoor1,
	door_BlastDoor2,
	door_Storage,
	door_Generator,
	door_PassageTop,
	door_PassageBottom,
	door_Catwalk,
	door_Headquarters1,
	door_Headquarters2,
	door_Shaft;

public OnLoad()
{
	new
		buttonid[2];

	code_ControlTower	= 1000 + random(8999);
	code_MainGate		= 1000 + random(8999);
	code_AirstripGate	= 1000 + random(8999);
	code_BlastDoor		= 1000 + random(8999);
	code_Inner			= 1000 + random(8999);
	code_Storage		= 1000 + random(8999);
	code_StorageWatch	= 1000 + random(8999);
	code_Generator		= 1000 + random(8999);
	code_PassageTop		= 1000 + random(8999);
	code_PassageBottom	= 1000 + random(8999);
	code_Catwalk		= 1000 + random(8999);
	code_Headquarters	= 1000 + random(8999);
	code_Shaft			= 1000 + random(8999);

	lock_ControlTower = 1;
	lock_StorageWatch = 1;

	btn_ControlTower = CreateButton(211.6015, 1812.2878, 21.8594, "Press "KEYTEXT_INTERACT" to interact");
	btn_StorageWatch = CreateButton(246.4888, 1861.1544, 14.0840, "Press "KEYTEXT_INTERACT" to interact");

	// Main Gate Block
	CreateObject(971, 96.88655, 1923.33936, 17.58039, 0.00000, 0.00000, 90.00000);
	CreateObject(971, 96.88655, 1923.33936, 13.61467, 0.00000, 0.00000, 90.00000);
	CreateObject(19273, 117.87466, 1932.37390, 19.57730, 0.00000, 0.00000, 270.00000);

	// Main Gate
	buttonid[0] = CreateButton(117.8747, 1932.3739, 19.5773, "Press to activate gate");
	door_Main = CreateDoor(19313, buttonid,
		134.91060, 1941.52124, 21.77760, 0.00000, 0.00000, 0.00000,
		120.9106, 1941.52124, 21.77760, 0.00000, 0.00000, 0.00000,
		.maxbuttons = 1, .movesound = 6000, .stopsound = 6002, .closedelay = -1);

	// Airstrip Gate
	buttonid[0] = CreateButton(280.7763, 1828.0514, 2.3915, "Press to activate gate");
	door_Airstrip = CreateDoor(19313, buttonid,
		285.98541, 1822.31140, 20.09470, 0.00000, 0.00000, 270.00000,
		285.98541, 1834.31140, 20.09470, 0.00000, 0.00000, 270.00000,
		.maxbuttons = 1, .movesound = 6000, .stopsound = 6002, .closedelay = -1);

	// Main Blast Doors
	buttonid[0] = CreateButton(210.3842, 1876.6578, 13.1406, "Press to activate door");
	buttonid[1] = CreateButton(209.5598, 1874.3828, 13.1469, "Press to activate door");
	door_BlastDoor1 = CreateDoor(2927, buttonid,
		215.9915, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		219.8936, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		.movesound = 6000, .stopsound = 6002, .movespeed = 0.4, .closedelay = -1);
	door_BlastDoor2 = CreateDoor(2929, buttonid,
		211.8555, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		207.8556, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		.movesound = 6000, .stopsound = 6002, .movespeed = 0.4, .closedelay = -1);

	// First door - to storage room
	buttonid[0] = CreateButton(237.4928, 1871.3110, 11.4609, "Press to activate door");
	buttonid[1] = CreateButton(239.3345, 1870.4381, 11.4609, "Press to activate door");
	door_Storage = CreateDoor(5422, buttonid,
		238.4573, 1872.2921, 12.4737, 0.0, 0.0, 0.0,
		238.4573, 1872.2921, 14.6002, 0.0, 0.0, 0.0,
		.movesound = 6000, .stopsound = 6002, .closedelay = -1);

	// Storage room to generator room
	buttonid[0] = CreateButton(247.3196, 1842.8588, 8.7614, "Press to activate door");
	buttonid[1] = CreateButton(247.3196, 1840.5961, 8.7578, "Press to activate door");
	door_Generator = CreateDoor(5422, buttonid,
		248.275406, 1842.032104, 9.7770, 0.0, 0.0, 90.0,
		248.270325, 1842.033691, 11.9806, 0.0, 0.0, 90.0,
		.movesound = 6000, .stopsound = 6002, .closedelay = -1);

	// Big doors in storage room leading to passage
	buttonid[0] = CreateButton(255.3204, 1842.7847, 8.7578, "Press to activate door");
	buttonid[1] = CreateButton(257.0612, 1843.4278, 8.7578, "Press to activate door");
	door_PassageTop = CreateDoor(9093, buttonid,
		256.3291, 1845.7827, 9.5281, 0.0, 0.0, 0.0,
		256.3291, 1845.7827, 12.1, 0.0, 0.0, 0.0,
		.movesound = 6000, .stopsound = 6002, .closedelay = -1);

	// Big doors in generator room leading to passage
	buttonid[0] = CreateButton(255.5610, 1832.4649, 4.7109, "Press to activate door");
	buttonid[1] = CreateButton(257.0517, 1833.1218, 4.7109, "Press to activate door");
	door_PassageBottom = CreateDoor(9093, buttonid,
		256.3094, 1835.3549, 5.4820, 0.0, 0.0, 0.0,
		256.3094, 1835.3549, 8.0035, 0.0, 0.0, 0.0,
		.movesound = 6000, .stopsound = 6002, .closedelay = -1);

	// Generator room leading to walkway
	buttonid[0] = CreateButton(249.3303, 1805.2384, 7.4796, "Press to activate door");
	buttonid[1] = CreateButton(249.0138, 1806.8889, 7.5546, "Press to activate door");
	door_Catwalk = CreateDoor(5422, buttonid,
		248.3001, 1805.8772, 8.5633, 0.0, 0.0, 90.0,
		248.3001, 1805.8772, 10.8075, 0.0, 0.0, 90.0,
		.movesound = 6000, .stopsound = 6002, .closedelay = -1);

	// Headquaters room
	buttonid[0] = CreateButton(234.1869, 1821.3165, 7.4141, "Press to activate door");
	buttonid[1] = CreateButton(228.3555, 1820.2427, 7.4141, "Press to activate door");
	door_Headquarters1 = CreateDoor(1508, buttonid,
		233.793884, 1825.885498, 7.097370, 0.0, 0.0, 0.0,
		233.793884, 1827.063477, 7.097370, 0.0, 0.0, 0.0,
		.movesound = 6000, .stopsound = 6002, .closedelay = -1);
	door_Headquarters2 = CreateDoor(1508, buttonid,
		233.793884, 1819.572388, 7.097370, 0.0, 0.0, 0.0,
		233.793884, 1818.413452, 7.097370, 0.0, 0.0, 0.0,
		.movesound = 6000, .stopsound = 6002, .closedelay = -1);

	// Labs to Shaft
	buttonid[0] = CreateButton(269.4969, 1873.1721, 8.6094, "Press to activate door");
	buttonid[1] = CreateButton(270.6281, 1875.8774, 8.4375, "Press to activate door");
	door_Shaft = CreateDoor(5422, buttonid,
		268.0739, 1875.3544, 9.6097, 0.0, 0.0, 90.0,
		268.0739, 1875.3544, 11.6097, 0.0, 0.0, 90.0,
		.movesound = 6000, .stopsound = 6002, .closedelay = -1);


	buttonid[0] = CreateButton(279.1897, 1833.1392, 18.0874, "Press to enter", .label = 1);
	buttonid[1] = CreateButton(279.2243, 1832.3821, 2.7813, "Press to enter", .label = 1);
	LinkTP(buttonid[0], buttonid[1]);


	return CallLocalFunction("a69_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad a69_OnLoad
forward a69_OnLoad();

public OnButtonPress(playerid, buttonid)
{
	if(buttonid == btn_ControlTower)
	{
		if(lock_ControlTower)
		{
			ShowKeypad(playerid, k_ControlTower, code_ControlTower);

			if(GetItemType(GetPlayerItem(playerid)) == item_HackDevice)
				HackKeypad(playerid, k_ControlTower, code_ControlTower);
		}
		else
		{
			ShowCodeList1(playerid);
		}
	}

	if(buttonid == btn_StorageWatch)
	{
		if(lock_StorageWatch)
		{
			ShowKeypad(playerid, k_StorageWatch, code_StorageWatch);

			if(GetItemType(GetPlayerItem(playerid)) == item_HackDevice)
				HackKeypad(playerid, k_ControlTower, code_ControlTower);
		}
		else
		{
			ShowCodeList2(playerid);
		}
	}

	return CallLocalFunction("a69_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress a69_OnButtonPress
forward a69_OnButtonPress(playerid, buttonid);

public OnPlayerActivateDoor(playerid, doorid, newstate)
{
	if(doorid == door_Main)
		return PlayerActivateDoorButton(playerid, k_MainGate, code_ControlTower);

	if(doorid == door_Airstrip)
		return PlayerActivateDoorButton(playerid, k_AirstripGate, code_AirstripGate);

	if(doorid == door_BlastDoor1)
		return PlayerActivateDoorButton(playerid, k_BlastDoor, code_BlastDoor);

	if(doorid == door_BlastDoor2)
		return PlayerActivateDoorButton(playerid, k_BlastDoor, code_BlastDoor);

	if(doorid == door_Storage)
		return PlayerActivateDoorButton(playerid, k_Storage, code_Storage);

	if(doorid == door_Generator)
		return PlayerActivateDoorButton(playerid, k_Generator, code_Generator);

	if(doorid == door_PassageTop)
		return PlayerActivateDoorButton(playerid, k_PassageTop, code_PassageTop);

	if(doorid == door_PassageBottom)
		return PlayerActivateDoorButton(playerid, k_PassageBottom, code_PassageBottom);

	if(doorid == door_Catwalk)
		return PlayerActivateDoorButton(playerid, k_Catwalk, code_Catwalk);

	if(doorid == door_Headquarters1)
		return PlayerActivateDoorButton(playerid, k_Headquarters1, code_Headquarters);

	if(doorid == door_Headquarters2)
		return PlayerActivateDoorButton(playerid, k_Headquarters2, code_Headquarters);

	if(doorid == door_Shaft)
		return PlayerActivateDoorButton(playerid, k_Shaft, code_Shaft);


	return CallLocalFunction("a69_OnPlayerActivateDoor", "ddd", playerid, doorid, newstate);
}
#if defined _ALS_OnPlayerActivateDoor
	#undef OnPlayerActivateDoor
#else
	#define _ALS_OnPlayerActivateDoor
#endif
#define OnPlayerActivateDoor a69_OnPlayerActivateDoor
forward a69_OnPlayerActivateDoor(playerid, doorid, newstate);

PlayerActivateDoorButton(playerid, keypad, code)
{
	ShowKeypad(playerid, keypad, code);

	if(GetItemType(GetPlayerItem(playerid)) == item_HackDevice)
		HackKeypad(playerid, keypad, code);

	return 1;
}

public OnPlayerKeypadEnter(playerid, keypadid, success)
{
	new itemid = GetPlayerItem(playerid);

	if(GetItemType(itemid) == item_HackDevice)
		DestroyItem(itemid);

	if(keypadid == k_ControlTower)
	{
		if(success)
		{
			lock_ControlTower = 0;
			ShowCodeList1(playerid);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_MainGate)
	{
		if(success)
		{
			OpenDoor(door_Main);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_AirstripGate)
	{
		if(success)
		{
			OpenDoor(door_Airstrip);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_BlastDoor)
	{
		if(success)
		{
			OpenDoor(door_BlastDoor1);
			OpenDoor(door_BlastDoor2);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Storage)
	{
		if(success)
		{
			OpenDoor(door_Storage);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Generator)
	{
		if(success)
		{
			OpenDoor(door_Generator);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_PassageTop)
	{
		if(success)
		{
			OpenDoor(door_PassageTop);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_PassageBottom)
	{
		if(success)
		{
			OpenDoor(door_PassageBottom);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Catwalk)
	{
		if(success)
		{
			OpenDoor(door_Catwalk);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Headquarters1)
	{
		if(success)
		{
			OpenDoor(door_Headquarters1);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Headquarters2)
	{
		if(success)
		{
			OpenDoor(door_Headquarters2);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Shaft)
	{
		if(success)
		{
			OpenDoor(door_Shaft);
			HideKeypad(playerid);
		}
	}

	return CallLocalFunction("a69_OnPlayerKeypadEnter", "ddd", playerid, keypadid, success);
}
#if defined _ALS_OnPlayerKeypadEnter
	#undef OnPlayerKeypadEnter
#else
	#define _ALS_OnPlayerKeypadEnter
#endif
#define OnPlayerKeypadEnter a69_OnPlayerKeypadEnter
forward a69_OnPlayerKeypadEnter(playerid, keypadid, success);

ShowCodeList1(playerid)
{
	new str[258];
	format(str, 258,
		""#C_ORANGE"Keycodes for security system. SECTOR 01:\n\n\
		\t"#C_WHITE"Control Tower:"#C_YELLOW"\t%d\n\
		\t"#C_WHITE"Main gate:"#C_YELLOW"\t\t%d\n\
		\t"#C_WHITE"Airstrip Gate:"#C_YELLOW"\t\t%d\n\
		\t"#C_WHITE"Blast Door:"#C_YELLOW"\t\t%d\n\
		\t"#C_WHITE"Inner Door 1:"#C_YELLOW"\t\t%d\n\
		\t"#C_WHITE"Inner Door 2:"#C_YELLOW"\t\t%d",
		code_ControlTower,
		code_MainGate,
		code_AirstripGate,
		code_BlastDoor,
		code_Inner,
		code_Storage);

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Main Control", str, "Close", "");
}

ShowCodeList2(playerid)
{
	new str[258];
	format(str, 258,
		""#C_ORANGE"Keycodes for security system. SECTOR 02:\n\n\
		\t"#C_WHITE"Generator:"#C_YELLOW"\t%d\n\
		\t"#C_WHITE"Passage 1:"#C_YELLOW"\t\t%d\n\
		\t"#C_WHITE"Passage 2:"#C_YELLOW"\t\t%d\n\
		\t"#C_WHITE"Catwalk:"#C_YELLOW"\t\t%d\n\
		\t"#C_WHITE"Headquarters:"#C_YELLOW"\t\t%d\n\
		\t"#C_WHITE"Shaft:"#C_YELLOW"\t\t%d",
		code_Generator,
		code_PassageTop,
		code_PassageBottom,
		code_Catwalk,
		code_Headquarters,
		code_Shaft);

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Main Control", str, "Close", "");
}
