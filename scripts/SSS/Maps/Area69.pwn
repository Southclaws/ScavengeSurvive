new
	door_Main,
	door_Airstrip,
	door_Side,
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

	// Main Gate
	door_Main = CreateDoor(19313, buttonid,
		134.91060, 1941.52124, 21.77760, 0.00000, 0.00000, 0.00000,
		120.9106, 1941.52124, 21.77760, 0.00000, 0.00000, 0.00000, .movesound = 6000, .stopsound = 6002);

	// Airstrip Gate
	buttonid[0] = CreateButton(280.7763, 1828.0514, 2.3915, "Press to activate gate");
	door_Airstrip = CreateDoor(19313, buttonid,
		285.98541, 1822.31140, 20.09470, 0.00000, 0.00000, 270.00000,
		285.98541, 1834.31140, 20.09470, 0.00000, 0.00000, 270.00000, .maxbuttons = 1, .movesound = 6000, .stopsound = 6002);

	// Side Gate
	buttonid[0] = CreateButton(97.6948, 1918.5541, 18.1833, "Press to activate gate");
	buttonid[1] = CreateButton(95.7846, 1918.5755, 18.1172, "Press to activate gate");
	door_Side = CreateDoor(969, buttonid,
		96.902634, 1918.947876, 17.330902, 0.0, 0.0, 90.0,
		96.886208, 1922.040039, 17.310095, 0.0, 0.0, 90.0, .movesound = 6000, .stopsound = 6002);

	// Main Blast Doors
	buttonid[0] = CreateButton(210.3842, 1876.6578, 13.1406, "Press to activate door");
	buttonid[1] = CreateButton(209.5598, 1874.3828, 13.1469, "Press to activate door");
	door_BlastDoor1 = CreateDoor(2927, buttonid,
		215.9915, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		219.8936, 1875.2880, 13.9389, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002, .movespeed = 0.4);
	door_BlastDoor2 = CreateDoor(2929, buttonid,
		211.8555, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		207.8556, 1875.2880, 13.9389, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002, .movespeed = 0.4);

	// First door - to storage room
	buttonid[0] = CreateButton(237.4928, 1871.3110, 11.4609, "Press to activate door");
	buttonid[1] = CreateButton(239.3345, 1870.4381, 11.4609, "Press to activate door");
	door_Storage = CreateDoor(5422, buttonid,
		238.4573, 1872.2921, 12.4737, 0.0, 0.0, 0.0,
		238.4573, 1872.2921, 14.6002, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002);

	// Storage room to generator room
	buttonid[0] = CreateButton(247.3196, 1842.8588, 8.7614, "Press to activate door");
	buttonid[1] = CreateButton(247.3196, 1840.5961, 8.7578, "Press to activate door");
	door_Generator = CreateDoor(5422, buttonid,
		248.275406, 1842.032104, 9.7770, 0.0, 0.0, 90.0,
		248.270325, 1842.033691, 11.9806, 0.0, 0.0, 90.0, .movesound = 6000, .stopsound = 6002);

	// Big doors in storage room leading to passage
	buttonid[0] = CreateButton(255.3204, 1842.7847, 8.7578, "Press to activate door");
	buttonid[1] = CreateButton(257.0612, 1843.4278, 8.7578, "Press to activate door");
	door_PassageTop = CreateDoor(9093, buttonid,
		256.3291, 1845.7827, 9.5281, 0.0, 0.0, 0.0,
		256.3291, 1845.7827, 12.1, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002);

	// Big doors in generator room leading to passage
	buttonid[0] = CreateButton(255.5610, 1832.4649, 4.7109, "Press to activate door");
	buttonid[1] = CreateButton(257.0517, 1833.1218, 4.7109, "Press to activate door");
	door_PassageBottom = CreateDoor(9093, buttonid,
		256.3094, 1835.3549, 5.4820, 0.0, 0.0, 0.0,
		256.3094, 1835.3549, 8.0035, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002);

	// Generator room leading to walkway
	buttonid[0] = CreateButton(249.3303, 1805.2384, 7.4796, "Press to activate door");
	buttonid[1] = CreateButton(249.0138, 1806.8889, 7.5546, "Press to activate door");
	door_Catwalk = CreateDoor(5422, buttonid,
		248.3001, 1805.8772, 8.5633, 0.0, 0.0, 90.0,
		248.3001, 1805.8772, 10.8075, 0.0, 0.0, 90.0, .movesound = 6000, .stopsound = 6002);

	// Headquaters room
	buttonid[0] = CreateButton(234.1869, 1821.3165, 7.4141, "Press to activate door");
	buttonid[1] = CreateButton(228.3555, 1820.2427, 7.4141, "Press to activate door");
	door_Headquarters1 = CreateDoor(1508, buttonid,
		233.793884, 1825.885498, 7.097370, 0.0, 0.0, 0.0,
		233.793884, 1827.063477, 7.097370, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002);
	door_Headquarters2 = CreateDoor(1508, buttonid,
		233.793884, 1819.572388, 7.097370, 0.0, 0.0, 0.0,
		233.793884, 1818.413452, 7.097370, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002);

	// Labs to Shaft
	buttonid[0] = CreateButton(269.4969, 1873.1721, 8.6094, "Press to activate door");
	buttonid[1] = CreateButton(270.6281, 1875.8774, 8.4375, "Press to activate door");
	door_Shaft = CreateDoor(5422, buttonid,
		268.0739, 1875.3544, 9.6097, 0.0, 0.0, 90.0,
		268.0739, 1875.3544, 11.6097, 0.0, 0.0, 90.0, .movesound = 6000, .stopsound = 6002);


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

public OnPlayerActivateDoor(playerid, doorid, newstate)
{
	// TODO: Puzzle to get into these doors.

	if(doorid == door_Main)
		return 0;

	if(doorid == door_Airstrip)
		return 0;

	if(doorid == door_Side)
		return 0;

	if(doorid == door_BlastDoor1)
		return 1;

	if(doorid == door_BlastDoor2)
		return 1;

	if(doorid == door_Storage)
		return 1;

	if(doorid == door_Generator)
		return 1;

	if(doorid == door_PassageTop)
		return 1;

	if(doorid == door_PassageBottom)
		return 1;

	if(doorid == door_Catwalk)
		return 1;

	if(doorid == door_Headquarters1)
		return 1;

	if(doorid == door_Headquarters2)
		return 1;

	if(doorid == door_Shaft)
		return 1;


	return CallLocalFunction("a69_OnPlayerActivateDoor", "ddd", playerid, doorid, newstate);
}
#if defined _ALS_OnPlayerActivateDoor
	#undef OnPlayerActivateDoor
#else
	#define _ALS_OnPlayerActivateDoor
#endif
#define OnPlayerActivateDoor a69_OnPlayerActivateDoor
forward a69_OnPlayerActivateDoor(playerid, doorid, newstate);
