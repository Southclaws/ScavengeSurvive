/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


Load_FC()
{
	CreateFuelOutlet(-2246.7031, -2559.7109, 31.0625, 2.0, 100.0, frandom(50.0));
	CreateFuelOutlet(-2241.7188, -2562.2891, 31.0625, 2.0, 100.0, frandom(50.0));

	CreateFuelOutlet(-1600.6719, -2707.8047, 47.9297, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1603.9922, -2712.2031, 47.9297, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1607.3047, -2716.6016, 47.9297, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1610.6172, -2721.0000, 47.9297, 2.0, 100.0, frandom(40.0));

	CreateFuelOutlet(-85.2422, -1165.0313, 2.6328, 2.0, 130.0, frandom(40.0));
	CreateFuelOutlet(-90.1406, -1176.6250, 2.6328, 2.0, 130.0, frandom(40.0));
	CreateFuelOutlet(-92.1016, -1161.7891, 2.9609, 2.0, 130.0, frandom(40.0));
	CreateFuelOutlet(-97.0703, -1173.7500, 3.0313, 2.0, 130.0, frandom(40.0));


	CreateLadder(-1056.0153, -628.1323, 32.0012, 130.1213, 180.0);
	CreateLadder(-1059.8658, -617.5842, 34.0942, 130.1221, 270.0);
	CreateLadder(-1073.3224, -645.8720, 32.0078, 56.6255, 180.0);
	CreateLadder(-1111.0469, -645.8738, 32.0078, 56.6202, 180.0);
	CreateLadder(-1097.3682, -640.2991, 34.0896, 44.2146, 0.0);
	CreateLadder(-1063.1298, -640.0430, 34.0896, 44.2146, 0.0);
	CreateLadder(-1099.8262, -719.3637, 32.0078, 54.7115, 180.0);
	CreateLadder(-1055.5986, -719.3712, 32.0078, 54.7115, 180.0);
	CreateLadder(-1013.4467, -719.3651, 32.0078, 54.7115, 180.0);

	FC_District_Chilliad();
	FC_District_AngelPine();
	FC_District_Scrapyard();
	FC_District_Farms();
	FC_District_EasterChem();
	FC_District_FallenTree();
	FC_District_FlintGen();

	DefineSupplyDropPos("Back-o-Beyond", -638.19598, -2442.45068, 30.10299);
	DefineSupplyDropPos("Flint Range", -519.18439, -1633.60962, 8.71135);
	DefineSupplyDropPos("Flint County Fallen Tree", -587.47852, -484.26419, 24.47583);
	DefineSupplyDropPos("The Farm Flint County", -1114.30457, -974.00067, 128.16339);
	DefineSupplyDropPos("Angel Pine", -2165.39160, -2395.42017, 29.44930);
	DefineSupplyDropPos("Mount Chilliad", -2335.43652, -1652.50720, 482.67642);
}


FC_District_Chilliad()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'FC_District_Chilliad' please wait...");

	CreateStaticLootSpawn(-2404.725585, -2176.453125, 32.303958,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2391.212158, -2216.532714, 32.308551,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2818.911865, -1528.634887, 139.843124,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2230.370849, -1743.514892, 479.874114,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2239.678222, -1748.054809, 479.876495,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2812.413818, -1516.458740, 139.840286,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2817.163818, -1512.304931, 138.279998,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2812.598632, -1521.808227, 139.842849,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2819.475585, -1524.675048, 139.842849,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2406.251953, -2186.815673, 32.306259,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2417.502685, -2176.006591, 32.330760,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2258.717529, -1273.389770, 225.117309,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2813.898925, -1506.738769, 138.281875,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2812.530273, -1534.418090, 138.280441,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2345.396972, -1657.122314, 482.683502,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2288.414550, -1624.262573, 482.769592,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2310.536376, -1653.226074, 482.692199,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2319.406005, -1683.331054, 481.194671,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2233.562255, -1736.573608, 479.844299,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2238.092773, -1711.406494, 479.887207,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2336.979736, -1598.952758, 482.670959,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2331.554687, -1584.218872, 482.597991,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2468.291748, -1346.212280, 310.011260,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2319.226806, -1223.251831, 234.331542,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2130.684570, -1948.657836, 240.301727,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2492.878173, -1316.614135, 296.819763,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2683.682617, -1539.384033, 302.911254,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2713.417236, -1490.661743, 292.985504,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2681.185791, -1421.499145, 260.902984,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2352.664306, -1727.111206, 482.110748,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2813.364746, -1528.597534, 139.842788,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2820.035644, -1516.731811, 139.840789,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2306.399169, -1693.183105, 480.557373,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2459.277587, -1916.006835, 302.515594,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2234.550048, -1743.220458, 479.868347,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2265.114013, -1688.054687, 479.846588,	GetLootIndexFromName("world_survivor"), 10.0);
}
FC_District_AngelPine()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'FC_District_AngelPine' please wait...");

	CreateItem(item_Workbench, -2176.33765, -2536.95630, 29.59808, 0.0, 0.0, -219.05981);

	CreateStaticLootSpawn(-2157.903564, -2475.454589, 30.111019,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2132.607666, -2513.873046, 30.814289,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2127.773681, -2501.750244, 29.612419,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2235.367919, -2484.460449, 30.208099,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2196.905029, -2508.886718, 29.952539,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2159.086425, -2535.734130, 30.811489,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2080.314208, -2448.080566, 29.614019,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2163.950439, -2418.213134, 29.613580,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2174.781494, -2419.958984, 33.285388,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2105.192871, -2481.190185, 29.616239,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2107.138427, -2457.327392, 29.614339,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2106.952880, -2432.015869, 29.613649,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2075.423339, -2532.287597, 29.602699,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2043.890869, -2559.551025, 29.591909,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2058.895996, -2544.626464, 29.596630,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2232.339111, -2557.671875, 30.914440,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2058.183837, -2465.038818, 30.169420,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2090.709228, -2512.223144, 29.619670,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2202.432373, -2385.866210, 29.713130,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2217.038330, -2397.214355, 31.051399,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2245.548828, -2432.792968, 30.793750,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2034.122558, -2530.115234, 29.593540,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2061.352783, -2511.542480, 29.653619,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2201.681396, -2388.375488, 29.609809,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2173.510253, -2328.774658, 29.609060,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2184.504882, -2262.635498, 29.620960,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2156.404541, -2332.900634, 29.610830,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2191.401611, -2350.564697, 29.605760,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2224.272216, -2295.315673, 29.612579,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2233.595703, -2289.223876, 29.612850,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2199.667968, -2243.089599, 29.775470,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2170.317382, -2311.622558, 29.610589,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2105.707031, -2342.188964, 29.609750,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2202.189697, -2248.728027, 29.717609,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2076.479492, -2312.090332, 30.115159,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2167.082519, -2346.146484, 29.610700,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-2082.261230, -2529.500488, 29.603080,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2092.906738, -2348.562255, 29.607959,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2049.408203, -2521.090087, 29.597389,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2220.041503, -2303.598632, 29.614700,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2239.407470, -2480.026367, 30.200260,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2177.290283, -2474.285888, 29.608589,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2129.279296, -2493.470703, 29.620899,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2118.410644, -2481.165283, 30.193799,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2133.864501, -2489.002441, 29.624839,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2040.508178, -2379.077880, 29.631479,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2067.586181, -2346.149902, 29.616279,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2003.412719, -2410.037841, 29.647930,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2014.837524, -2404.239501, 29.643680,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1992.017089, -2384.617187, 29.644790,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2028.388793, -2374.224121, 34.881450,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2234.125000, -2570.872314, 30.913349,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2007.607910, -2369.007324, 29.646980,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2011.688720, -2364.261962, 34.885330,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2216.145263, -2338.312988, 29.607130,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2251.603271, -2311.982421, 28.392770,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2099.707031, -2528.153076, 29.606790,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2196.010986, -2329.836669, 29.605300,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2190.792724, -2246.892578, 29.738239,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1970.755493, -2432.931152, 29.645900,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1998.189575, -2415.357177, 29.649030,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2182.287109, -2253.647460, 29.659240,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1954.332153, -2434.184326, 31.347339,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2200.087402, -2430.123291, 29.614099,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2162.854980, -2361.139648, 29.788639,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2144.534423, -2379.081542, 29.608030,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2140.546630, -2259.131835, 29.640359,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2187.230224, -2440.227294, 29.616130,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2194.645507, -2435.689208, 29.615159,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2186.646240, -2413.468261, 34.284839,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2093.609375, -2250.840820, 29.641279,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2087.881103, -2243.240722, 30.144739,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2189.731689, -2419.137695, 29.612579,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2178.595214, -2422.182617, 29.614080,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2179.026123, -2403.214599, 34.283828,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2107.771972, -2400.818847, 30.388460,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2092.268310, -2260.495361, 29.641519,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2100.753662, -2224.085937, 29.641010,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2083.979248, -2340.047607, 29.611219,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2076.409179, -2272.417968, 29.764499,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2067.100585, -2429.345458, 29.618160,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2085.517333, -2420.125976, 29.615859,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2113.257568, -2419.875732, 29.611059,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2066.702880, -2443.703369, 29.614280,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2073.672119, -2498.987548, 29.604980,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2065.387939, -2528.802001, 29.599290,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2076.008300, -2560.987548, 29.598310,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2155.065917, -2551.582275, 29.608970,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2174.005126, -2535.460449, 29.604949,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2225.195068, -2401.752685, 30.976589,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2028.890014, -2547.901367, 29.591070,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-2159.052246, -2368.569824, 29.697650,	GetLootIndexFromName("world_police"), 15.0);
	CreateStaticLootSpawn(-2163.110595, -2386.170898, 29.609680,	GetLootIndexFromName("world_police"), 15.0);
	CreateStaticLootSpawn(-2177.769531, -2520.553955, 30.804700,	GetLootIndexFromName("world_police"), 15.0);
	CreateStaticLootSpawn(-2150.911865, -2375.223144, 29.614200,	GetLootIndexFromName("world_medical"), 15.0);
	CreateStaticLootSpawn(-2053.867187, -2344.762939, 39.892368,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2100.300537, -2340.836914, 33.819259,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2181.256591, -2318.844970, 35.074069,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2187.869384, -2333.486816, 33.995449,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2129.392089, -2364.346191, 36.808349,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2142.756591, -2354.483886, 36.752231,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2037.523437, -2350.497314, 39.888690,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2044.713867, -2335.512207, 39.889518,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2147.136718, -2272.597900, 35.979560,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2031.805297, -2345.111083, 39.886379,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2076.451904, -2442.629882, 33.713180,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2118.579589, -2412.984619, 30.224279,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2105.928710, -2470.702148, 29.614280,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2107.486816, -2483.938476, 29.698709,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2094.562500, -2470.463378, 32.917369,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2179.936035, -2433.474609, 34.515739,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2198.115478, -2424.394042, 34.513240,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2084.549804, -2498.692871, 29.610559,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-2182.736572, -2416.976318, 34.285480,	GetLootIndexFromName("world_survivor"), 10.0);
}
FC_District_Scrapyard()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'FC_District_Scrapyard' please wait...");

	CreateItem(item_ScrapMachine, -1888.26416, -1636.40588, 21.21387, 0.0, 0.0, 0.0);
	CreateItem(item_RefineMachine, -1848.56006, -1685.39380, 22.97520, 0.0, 0.0, -54.0);

	CreateStaticLootSpawn(-1825.192138, -1629.722534, 22.001569,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1848.610473, -1629.970947, 20.828950,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1833.258300, -1706.893432, 22.201660,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1809.380249, -1630.356445, 21.999780,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1894.912597, -1680.887084, 22.006149,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1891.120849, -1658.930908, 22.013250,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1868.344604, -1629.660034, 20.792909,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1895.914184, -1637.824951, 20.745939,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1853.504882, -1697.221801, 39.872058,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1869.354980, -1717.392211, 20.751590,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1844.242431, -1702.215576, 39.817859,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1936.447631, -1704.864135, 20.732959,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1852.872436, -1725.018188, 20.724210,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1825.304077, -1618.146484, 22.013740,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1810.309082, -1619.215332, 22.012639,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1829.066284, -1607.148437, 22.009370,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1857.938476, -1617.679565, 20.850530,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1849.784057, -1622.744750, 20.909170,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1809.380737, -1608.792480, 22.009319,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1865.579223, -1611.779296, 20.750699,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1850.267456, -1608.355468, 20.751979,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1867.188598, -1624.464965, 20.872819,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1917.670532, -1683.468505, 22.007030,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1915.714233, -1661.329956, 22.008579,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1820.129516, -1613.401611, 22.012250,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1866.429199, -1565.355590, 20.740850,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1903.560302, -1665.573974, 22.012609,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1846.832275, -1691.553100, 22.203090,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1903.657958, -1677.914306, 22.012430,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1909.402954, -1671.123901, 22.010810,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1851.799804, -1707.148193, 39.825500,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1845.439086, -1708.595092, 45.223579,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1873.002441, -1703.499023, 29.017330,	GetLootIndexFromName("world_survivor"), 10.0);
}
FC_District_Farms()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'FC_District_Farms' please wait...");

	CreateItem(item_Workbench, -392.98178, -1433.41199, 24.67424, 0.0, 0.0, 0.00000);
	CreateItem(item_Workbench, -372.71423, -1040.36572, 58.21876, 0.0, 0.0, 95.58000);

	CreateStaticLootSpawn(-576.649841, -1483.673095, 9.674639,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-576.912963, -1035.397460, 22.790590,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-588.477416, -1053.169555, 22.345159,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-398.801727, -1418.695922, 24.717660,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-368.511413, -1438.944335, 24.717090,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-394.639068, -1446.344726, 24.718620,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-403.021148, -1435.469482, 24.715520,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1076.946655, -1202.374023, 128.234634,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1070.346313, -1211.820556, 128.235992,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1069.721923, -1207.763793, 128.235061,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1077.103515, -1189.719604, 128.234130,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-600.497070, -1071.309814, 22.471839,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1183.921386, -1137.082397, 128.218536,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1066.765380, -1156.452270, 128.218383,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-364.694274, -1429.045410, 24.740520,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1110.439453, -1674.457031, 75.365043,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1438.820678, -1541.625122, 100.778358,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1112.075317, -1616.152954, 75.381156,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-346.239685, -1049.110839, 58.299591,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-393.227722, -1147.004394, 68.358360,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1445.889160, -1540.839477, 100.779541,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1426.281250, -1525.608398, 100.742286,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1430.298339, -1460.600585, 100.670486,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1073.737060, -1154.708129, 128.216827,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-410.986755, -1426.632202, 24.543750,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1212.416870, -1217.744384, 128.187347,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1206.713623, -1156.307983, 128.185165,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-350.022216, -1034.164794, 58.350879,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-364.207946, -1417.766357, 24.736299,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-383.814331, -1040.321044, 57.888530,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1083.716552, -1195.757812, 128.234710,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-376.600799, -1035.094726, 58.128631,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-599.040283, -1067.744506, 22.417959,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-586.616943, -1050.798950, 22.421970,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-550.902099, -1016.870056, 23.077669,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-598.611511, -1081.535522, 22.663379,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-397.966796, -1435.548095, 24.716730,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-572.817749, -1498.621582, 8.591420,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1184.996948, -1142.595581, 128.216384,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-379.664733, -1426.452148, 24.714960,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-394.250152, -1152.255859, 68.508392,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1454.847290, -1574.425537, 104.117729,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1457.053955, -1571.332885, 100.751029,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1425.888305, -1559.425415, 100.782989,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1415.740112, -1536.853759, 100.747726,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1434.294311, -1572.672363, 100.758300,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1427.709228, -1479.954589, 104.028030,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1435.766479, -1582.702148, 100.758613,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1459.148071, -1582.136474, 100.751419,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1107.666015, -1638.835937, 75.384826,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1112.709838, -1676.598999, 75.364250,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1117.137329, -1626.197875, 75.379371,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1102.745727, -1626.042358, 75.384368,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1434.705688, -1538.027954, 100.785453,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1435.835571, -1556.129638, 100.779716,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1431.114135, -1447.623901, 100.739540,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1435.296752, -1531.461059, 100.785209,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1419.742675, -1503.229003, 104.035980,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1454.101806, -1511.594360, 100.755996,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1417.258789, -1502.953247, 100.665168,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1028.557983, -1183.612548, 128.215682,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1078.749511, -1296.847656, 128.214233,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1429.116699, -1504.494750, 100.665298,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1429.611938, -1477.931274, 100.667327,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1418.837646, -1478.224731, 100.665512,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1069.835937, -1203.207397, 128.233612,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1058.154052, -1195.552490, 128.163452,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1453.311035, -1578.309692, 100.755798,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1113.154907, -1619.511108, 75.379676,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1439.449096, -1575.944458, 100.755867,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1172.178344, -1138.864746, 128.208404,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1423.444946, -1500.048461, 100.668792,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-366.704284, -1420.110839, 28.636390,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1108.527832, -1621.807861, 75.379409,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1113.576782, -1635.856323, 75.382713,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1084.973999, -1621.516479, 75.376350,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1435.873168, -1574.493530, 104.122497,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-576.137084, -1484.566040, 13.333109,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-967.204162, -968.669494, 129.710342,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1420.233520, -1480.234741, 104.028648,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-957.291442, -972.272766, 129.660018,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1447.719116, -1578.769531, 104.120742,	GetLootIndexFromName("world_survivor"), 10.0);

	CreateHackerTrap(-362.127227, -1060.984008, 58.241569,			GetLootIndexFromName("world_survivor"));
}
FC_District_EasterChem()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'FC_District_EasterChem' please wait...");

	CreateStaticLootSpawn(-983.560485, -676.974487, 30.980920,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1007.987182, -672.090942, 30.984039,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1002.550842, -652.888671, 30.989000,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-983.686828, -622.938842, 30.994670,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-984.967651, -653.130187, 30.987300,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1183.921386, -1137.082397, 128.218536,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1030.675048, -664.080993, 30.982360,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1069.721923, -1207.763793, 128.235061,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1070.346313, -1211.820556, 128.235992,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1076.946655, -1202.374023, 128.234634,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1052.169433, -663.091918, 30.981660,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1066.765380, -1156.452270, 128.218383,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1077.103515, -1189.719604, 128.234130,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-600.497070, -1071.309814, 22.471839,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-364.694274, -1429.045410, 24.740520,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1031.630249, -639.699218, 30.991149,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-368.511413, -1438.944335, 24.717090,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1052.322387, -609.650634, 30.990629,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-346.239685, -1049.110839, 58.299591,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-393.227722, -1147.004394, 68.358360,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-394.639068, -1446.344726, 24.718620,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-576.649841, -1483.673095, 9.674639,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-576.912963, -1035.397460, 22.790590,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-588.477416, -1053.169555, 22.345159,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-403.021148, -1435.469482, 24.715520,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-398.801727, -1418.695922, 24.717660,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1005.339111, -625.503723, 30.996339,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1438.820678, -1541.625122, 100.778358,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1445.889160, -1540.839477, 100.779541,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1112.075317, -1616.152954, 75.381156,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1110.439453, -1674.457031, 75.365043,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1430.298339, -1460.600585, 100.670486,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1426.281250, -1525.608398, 100.742286,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-379.664733, -1426.452148, 24.714960,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-397.966796, -1435.548095, 24.716730,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-598.611511, -1081.535522, 22.663379,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1107.666015, -1638.835937, 75.384826,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1112.709838, -1676.598999, 75.364250,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-599.040283, -1067.744506, 22.417959,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-572.817749, -1498.621582, 8.591420,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-586.616943, -1050.798950, 22.421970,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-410.986755, -1426.632202, 24.543750,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-550.902099, -1016.870056, 23.077669,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-364.207946, -1417.766357, 24.736299,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1004.141296, -638.713867, 30.990079,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1006.093872, -592.466796, 30.983560,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1030.035400, -628.194885, 30.994409,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-982.708679, -641.684143, 30.985090,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1057.109375, -635.082763, 129.037490,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1026.221069, -690.198181, 30.990150,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1001.086303, -687.505676, 30.986129,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1052.113891, -602.333557, 91.913719,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-350.022216, -1034.164794, 58.350879,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1102.745727, -1626.042358, 75.384368,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-394.250152, -1152.255859, 68.508392,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-376.600799, -1035.094726, 58.128631,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1054.592895, -593.179809, 30.991790,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1117.137329, -1626.197875, 75.379371,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-383.814331, -1040.321044, 57.888530,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1069.835937, -1203.207397, 128.233612,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1055.329589, -695.071472, 31.348930,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1028.557983, -1183.612548, 128.215682,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1058.154052, -1195.552490, 128.163452,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1083.716552, -1195.757812, 128.234710,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1435.766479, -1582.702148, 100.758613,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1434.294311, -1572.672363, 100.758300,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1459.148071, -1582.136474, 100.751419,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1418.837646, -1478.224731, 100.665512,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1429.116699, -1504.494750, 100.665298,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1427.709228, -1479.954589, 104.028030,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1419.742675, -1503.229003, 104.035980,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1454.101806, -1511.594360, 100.755996,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1078.749511, -1296.847656, 128.214233,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1417.258789, -1502.953247, 100.665168,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1429.611938, -1477.931274, 100.667327,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1425.888305, -1559.425415, 100.782989,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1184.996948, -1142.595581, 128.216384,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1454.847290, -1574.425537, 104.117729,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1415.740112, -1536.853759, 100.747726,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1435.296752, -1531.461059, 100.785209,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1431.114135, -1447.623901, 100.739540,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1435.835571, -1556.129638, 100.779716,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1434.705688, -1538.027954, 100.785453,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1099.970947, -734.196289, 58.478408,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1073.737060, -1154.708129, 128.216827,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1457.053955, -1571.332885, 100.751029,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1206.713623, -1156.307983, 128.185165,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1123.032104, -755.728637, 30.998889,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1212.416870, -1217.744384, 128.187347,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1020.405639, -699.482360, 53.420539,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1020.392089, -706.969299, 53.445491,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1023.583496, -699.159484, 53.441589,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1024.058349, -705.256774, 128.655639,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1004.363098, -706.784973, 93.594818,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1100.421142, -608.209411, 43.195701,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1016.500366, -735.676452, 58.356479,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1066.117187, -607.453735, 43.203941,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1107.432617, -696.394653, 55.328479,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1062.294189, -696.081542, 55.329341,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1054.786010, -603.592224, 95.747810,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1054.732666, -606.378906, 91.912322,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1038.810546, -699.887695, 63.518711,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1038.837158, -706.721740, 63.517200,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1033.332153, -699.490478, 63.517509,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1017.298217, -703.672424, 129.464721,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1014.202697, -703.833557, 135.315689,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1026.910644, -704.834350, 134.507263,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1055.829345, -632.447204, 129.791809,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1055.671386, -617.564086, 129.210662,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1053.541503, -630.829101, 129.038574,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1056.549194, -601.297363, 91.912406,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1054.842041, -620.321838, 128.858871,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1058.432495, -696.342041, 66.116462,		GetLootIndexFromName("world_survivor"), 10.0);
}
FC_District_FallenTree()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'FC_District_FallenTree' please wait...");

	CreateStaticLootSpawn(-552.575927, -504.346130, 24.501939,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-569.084838, -502.943481, 24.501260,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-488.721588, -549.866149, 24.507780,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-540.804077, -541.241149, 24.514999,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-552.916076, -540.921081, 24.514659,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-502.164916, -515.611755, 24.507350,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-499.253021, -560.827880, 24.495370,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-578.162902, -474.599060, 24.505050,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-524.843261, -488.636230, 24.507530,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-489.395599, -487.445770, 24.509040,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-477.014099, -479.927429, 24.513059,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-527.151184, -479.682006, 24.512670,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-557.502136, -473.730072, 24.509740,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-520.322998, -501.751770, 23.884559,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-576.598205, -503.839447, 24.507850,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-557.136840, -504.842254, 23.618270,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-536.826232, -503.064971, 24.502950,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-593.921447, -489.312774, 24.494670,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-529.789550, -541.639831, 24.514530,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-472.201080, -551.021789, 32.111000,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-477.616943, -540.506958, 24.514270,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-519.696472, -549.144287, 24.514949,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-621.345886, -474.095764, 24.482940,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-576.950500, -540.365539, 24.512420,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-558.501342, -544.207580, 24.514469,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-518.380676, -523.488708, 35.270401,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-573.385620, -522.548095, 35.322448,		GetLootIndexFromName("world_survivor"), 10.0);
}
FC_District_FlintGen()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'FC_District_FlintGen' please wait...");

	CreateStaticLootSpawn(-283.446838, -2174.875244, 27.649789,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-396.378906, -426.530273, 15.193169,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-287.934722, -2163.882324, 27.612770,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-88.293579, -1202.006835, 1.888120,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-88.421173, -1212.357910, 1.888470,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-426.340148, -391.197784, 15.194359,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-431.180877, -399.702667, 15.193590,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(33.996829, -2645.136474, 39.724109,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-394.344604, -430.243469, 15.193519,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(22.604990, -2646.716308, 39.461601,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-65.233978, -1574.161865, 1.629930,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-99.471740, -1578.305908, 1.621670,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-66.679313, -1548.295043, 1.624670,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-54.423358, -1559.326782, 1.628819,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-87.796752, -1566.227661, 1.624650,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-77.352668, -1136.325927, 0.095440,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-79.215393, -1169.089843, 1.168910,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-89.113296, -1591.375610, 1.625460,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-73.897056, -1579.984741, 1.628769,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-73.815376, -1594.619384, 1.629690,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1624.385864, -2695.113525, 47.511489,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-23.557060, -2492.553222, 35.639831,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-35.018428, -2495.285400, 35.641208,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-14.842320, -2506.677978, 35.640491,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1561.483154, -2733.774169, 47.713401,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-938.342834, -513.508666, 24.943790,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-22.604980, -2525.286376, 35.619258,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-940.762756, -490.295104, 25.351129,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-915.067199, -531.646606, 24.942060,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-956.931274, -508.395172, 24.944450,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-927.418273, -497.646362, 24.946609,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1640.483032, -2234.282226, 30.470949,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1634.865844, -2235.677246, 30.471809,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1636.297119, -2245.072021, 30.470100,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-1426.129272, -966.460998, 199.837814,	GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-87.786003, -1132.687255, 0.095059,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-61.402309, -1111.925659, 0.086999,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-64.701316, -1121.552124, 0.088919,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-76.490539, -1103.682006, 0.086240,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-70.898323, -1139.092895, 0.094020,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-920.954101, -519.655883, 24.943010,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-913.349121, -518.605590, 24.943880,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-916.002441, -494.416961, 24.947000,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-937.587951, -534.039550, 24.941650,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-387.421630, -420.014709, 15.192569,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-418.137908, -395.415008, 15.195369,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-85.012351, -1217.130493, 1.690410,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-954.681396, -524.569641, 24.942930,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-913.563476, -523.794677, 24.943519,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-953.624267, -495.060333, 24.946840,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-84.233879, -1180.108032, 0.986909,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-72.056053, -1183.494750, 0.763509,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-6.244520, -2494.447998, 35.627090,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-48.097118, -2490.948486, 35.626319,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(8.232279, -2520.306152, 35.634639,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-19.128219, -2472.644775, 35.634658,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(23.226839, -2655.114013, 39.504699,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-266.807800, -2214.274414, 28.028459,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-20.419740, -2536.685546, 35.626319,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(33.963581, -2648.507080, 39.723438,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1546.228027, -2726.659912, 47.528739,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1558.373901, -2724.086425, 47.728321,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1633.617431, -2250.662597, 30.322069,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1630.555419, -2245.189697, 30.469289,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-16.941579, -2501.895263, 35.675449,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-16.872640, -2522.033203, 35.640880,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1620.040649, -2689.845703, 47.711978,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-39.810829, -2498.426269, 35.574661,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-62.385021, -1569.736450, 1.630220,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-56.516700, -1575.532348, 1.631850,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-88.621841, -1601.705200, 1.625679,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-61.131919, -1552.343505, 1.624109,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-91.023666, -1577.283691, 1.622630,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-72.108673, -1573.048217, 1.627779,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-256.693695, -2191.128173, 27.989290,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-286.333709, -2151.380615, 27.535039,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-79.776168, -1593.544921, 1.628239,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1435.656250, -959.542846, 199.946502,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-261.761383, -2183.147460, 27.950519,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-100.378753, -1569.194213, 1.620030,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-76.008827, -1549.642211, 1.620440,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-948.184509, -542.001403, 24.940900,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-947.564880, -527.743591, 24.942459,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-917.108642, -536.825683, 24.940309,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-29.274169, -1125.197631, 0.087449,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-34.358749, -1132.818481, 0.089180,		GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1432.990722, -965.091735, 199.961883,	GetLootIndexFromName("world_industrial"), 15.0);
	CreateStaticLootSpawn(-1630.915405, -2234.325683, 30.471929,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1640.683105, -2246.910644, 30.469890,	GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-91.105438, -1169.115600, 6.299079,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-325.500976, -467.629089, 0.996840,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-1427.453491, -959.672424, 200.085449,	GetLootIndexFromName("world_survivor"), 10.0);
}
