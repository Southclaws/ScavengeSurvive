public OnLoad()
{
	new
		buttonid[2];

	// Front Gate
	buttonid[0] = CreateButton(97.6948, 1918.5541, 18.1833, "Press to activate gate");
	buttonid[1] = CreateButton(95.7846, 1918.5755, 18.1172, "Press to activate gate");
	CreateDoor(969, buttonid,
		96.902634, 1918.947876, 17.330902, 0.0, 0.0, 90.0,
		96.886208, 1922.040039, 17.310095, 0.0, 0.0, 90.0, .movesound = 6000, .stopsound = 6002);

	// Front Blast Doors
	buttonid[0] = CreateButton(210.3842, 1876.6578, 13.1406, "Press to activate door");
	buttonid[1] = CreateButton(209.5598, 1874.3828, 13.1469, "Press to activate door");
	CreateDoor(2927, buttonid,
		215.9915, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		219.8936, 1875.2880, 13.9389, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002, .movespeed = 0.4);
	CreateDoor(2929, buttonid,
		211.8555, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		207.8556, 1875.2880, 13.9389, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002, .movespeed = 0.4);

	// First door - to storage room
	buttonid[0] = CreateButton(237.4928,1871.3110,11.4609, "Press to activate door");
	buttonid[1] = CreateButton(239.3345,1870.4381,11.4609, "Press to activate door");
	CreateDoor(5422, buttonid,
		238.4573, 1872.2921, 12.4737, 0.0, 0.0, 0.0,
		238.4573, 1872.2921, 14.6002, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002);

	// Storage room to generator room
	buttonid[0] = CreateButton(247.3196, 1842.8588, 8.7614, "Press to activate door");
	buttonid[1] = CreateButton(247.3196, 1840.5961, 8.7578, "Press to activate door");
	CreateDoor(5422, buttonid,
		248.275406, 1842.032104, 9.7770, 0.0, 0.0, 90.0,
		248.270325, 1842.033691, 11.9806, 0.0, 0.0, 90.0, .movesound = 6000, .stopsound = 6002);

	// Big doors in storage room leading to passage
	buttonid[0] = CreateButton(255.3204, 1842.7847, 8.7578, "Press to activate door");
	buttonid[1] = CreateButton(257.0612, 1843.4278, 8.7578, "Press to activate door");
	CreateDoor(9093, buttonid,
		256.3291, 1845.7827, 9.5281, 0.0, 0.0, 0.0,
		256.3291, 1845.7827, 12.1, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002);

	// Big doors in generator room leading to passage
	buttonid[0] = CreateButton(255.5610, 1832.4649, 4.7109, "Press to activate door");
	buttonid[1] = CreateButton(257.0517, 1833.1218, 4.7109, "Press to activate door");
	CreateDoor(9093, buttonid,
		256.3094, 1835.3549, 5.4820, 0.0, 0.0, 0.0,
		256.3094, 1835.3549, 8.0035, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002);

	// Generator room leading to walkway
	buttonid[0] = CreateButton(249.3303, 1805.2384, 7.4796, "Press to activate door");
	buttonid[1] = CreateButton(249.0138, 1806.8889, 7.5546, "Press to activate door");
	CreateDoor(5422, buttonid,
		248.3001, 1805.8772, 8.5633, 0.0, 0.0, 90.0,
		248.3001, 1805.8772, 10.8075, 0.0, 0.0, 90.0, .movesound = 6000, .stopsound = 6002);

	// Headquaters room
	buttonid[0] = CreateButton(234.1869,1821.3165,7.4141, "Press to activate door");
	buttonid[1] = CreateButton(228.3555,1820.2427,7.4141, "Press to activate door");
	CreateDoor(1508, buttonid,
		233.793884, 1825.885498, 7.097370, 0.0, 0.0, 0.0,
		233.793884, 1827.063477, 7.097370, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002);
	CreateDoor(1508, buttonid,
		233.793884, 1819.572388, 7.097370, 0.0, 0.0, 0.0,
		233.793884, 1818.413452, 7.097370, 0.0, 0.0, 0.0, .movesound = 6000, .stopsound = 6002);

	// Labs to Shaft
	buttonid[0] = CreateButton(269.4969,1873.1721,8.6094, "Press to activate door");
	buttonid[1] = CreateButton(270.6281,1875.8774,8.4375, "Press to activate door");
	CreateDoor(5422, buttonid,
		267.051788, 1875.100952, 9.267685, 0.0, 0.0, 90.0,
		264.048431, 1875.085449, 9.267685, 0.0, 0.0, 90.0, .movesound = 6000, .stopsound = 6002);


	return CallLocalFunction("a69_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad a69_OnLoad
forward a69_OnLoad();
