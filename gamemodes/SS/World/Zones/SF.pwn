#include <YSI\y_hooks>


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'World/SF'...");

	CreateLadder(-1164.6187, 370.0174, 1.9609, 14.1484, 221.1218);
	CreateLadder(-1182.6258, 60.4429, 1.9609, 14.1484, 134.2914);
	CreateLadder(-1736.4494, -445.9549, 1.9609, 14.1484, 270.7138);

	SF_District_Housing1();
	SF_District_Housing2();
	SF_District_Bayfront();
	SF_District_City1();
	SF_District_City2();
	SF_District_Naval();
	SF_District_Police();
	SF_District_Industrial();
	SF_District_SfAirport();
	SF_District_MontFoster();
	SF_District_Ship1();
	SF_District_Ship2();

/*
	// SF Factory
	LinkTP(
		CreateButton(-904.7388, 335.7443, 1014.1530, "Press F to open", 0),
		CreateButton(-1857.1831, -169.5322, 9.1358, "Press F to open", 0));

	// SF utility room
	LinkTP(
		CreateButton(-2578.1204, 1144.8810, 40.3989, "Press F to enter"),
		CreateButton(-2587.5229, 1162.4547, 55.5876, "Press F to enter"));
*/
	CreateNewSprayTag(-1788.31995, 748.41998, 25.36000,   0.00000, 0.00000, 270.00000);
	CreateNewSprayTag(-1908.90003, 299.56000, 41.52000,   0.00000, 0.00000, 180.00000);
	CreateNewSprayTag(-2224.75000, 881.27002, 84.13000,   0.00000, 0.00000, 90.00000);
	CreateNewSprayTag(-2636.69995, 635.52002, 15.13000,   0.00000, 0.00000, 0.00000);

	DefineSupplyDropPos("San Fierro Airport", -1312.81885, -16.52664, 13.08027);
	DefineSupplyDropPos("San Fierro Driving School", -2055.64697, -200.37950, 34.24461);
	DefineSupplyDropPos("San Fierro Country Club", -2767.39209, -287.28488, 5.98262);
	DefineSupplyDropPos("San Fierro Hospital", -2569.96948, 653.26270, 26.74425);
	DefineSupplyDropPos("San Fierro Square", -1980.58887, 884.61041, 44.17714);
	DefineSupplyDropPos("San Fierro Promenade", -1587.81201, 1180.50891, 5.97472);
}


SF_District_Housing1()
{
	CreateSaveBlockArea(CreateDynamicCube(-2521.3608, 286.6024, 1035.3081, -2478.7195, 328.1099, 1039.7107), -2499.1262, 315.1892, 29.4147);

	DefineWeaponsCachePos(-2716.43823, 382.60507, 3.34639);
	DefineWeaponsCachePos(-2521.67456, 318.69183, 34.09675);
	DefineWeaponsCachePos(-2473.95605, 401.25406, 26.73841);
	DefineWeaponsCachePos(-2587.40479, 332.89505, 3.84088);
	DefineWeaponsCachePos(-2684.57642, 268.28076, 3.31175);
	DefineWeaponsCachePos(-2641.14673, 190.63800, 3.30231);
	DefineWeaponsCachePos(-2752.70020, 206.10161, 5.93917);
	DefineWeaponsCachePos(-2980.13965, 468.74667, 3.87113);
	DefineWeaponsCachePos(-2755.74316, 96.59800, 6.01551);
	DefineWeaponsCachePos(-2679.01245, -22.84922, 3.30198);
	DefineWeaponsCachePos(-2655.62231, 88.49954, 3.07376);
	DefineWeaponsCachePos(-2524.37085, -7.58145, 24.60770);
	DefineWeaponsCachePos(-2456.55249, -22.27232, 31.77888);
	DefineWeaponsCachePos(-2496.17969, 96.59895, 34.15479);
	DefineWeaponsCachePos(-2311.83350, 196.26547, 34.27616);
	DefineWeaponsCachePos(-2318.07178, 102.51508, 34.30185);
	DefineWeaponsCachePos(-2318.58887, -3.95909, 34.31125);
	DefineWeaponsCachePos(-2351.37231, -146.02968, 34.30040);
	DefineWeaponsCachePos(-2487.73804, -128.85942, 24.59999);
	DefineWeaponsCachePos(-2752.04517, -246.72028, 6.17439);
	DefineWeaponsCachePos(-2898.28613, -35.74038, 3.17566);
	DefineWeaponsCachePos(-2897.09619, 223.05794, 2.77412);

	CreateStaticLootSpawn(-2720.340087, -318.529998, 6.930000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2744.159912, -291.399993, 6.079999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2776.780029, -304.290008, 6.120000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2649.449951, -307.170013, 6.329999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2752.159912, -252.050003, 6.260000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2773.340087, -172.770004, 6.260000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2746.800048, -166.660003, 5.269999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2773.520019, -146.130004, 6.250000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2755.270019, -197.070007, 6.110000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2758.090087, -127.290000, 6.019999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2773.070068, -87.500000, 6.260000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2749.030029, -88.669998, 5.350000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2661.360107, -95.970001, 3.409999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2662.860107, -167.649993, 3.399999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2636.219970, -146.770004, 3.399999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2653.639892, -128.360000, 3.209999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2648.139892, -29.790000, 5.190000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2672.270019, -5.989999, 5.190000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2630.580078, -5.739999, 5.210000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2652.120117, 21.489999, 5.200000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2771.770019, -45.380001, 6.250000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2745.959960, -23.139999, 5.079999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2764.100097, 2.799999, 6.050000,			loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2776.649902, 103.900001, 6.240000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2775.800048, 193.050003, 6.250000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2780.580078, 220.289993, 6.240000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2724.340087, 365.910003, 3.459999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2689.020019, 382.750000, 3.429999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2656.070068, 376.049987, 3.389999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2660.649902, 185.850006, 3.399999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2687.669921, 181.679992, 3.399999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2651.790039, 80.839996, 3.189999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2652.209960, 126.290000, 3.240000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2666.489990, 127.500000, 3.539999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2669.889892, 68.959999, 3.389999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2580.439941, 310.140014, 4.260000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2571.040039, 327.329986, 9.640000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2499.659912, 312.420013, 34.180000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2472.090087, 397.809997, 26.840000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2525.189941, 305.769989, 34.189998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2501.479980, 260.980010, 34.229999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2458.449951, 133.429992, 34.240001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2491.290039, 111.360000, 24.950000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2506.260009, 106.129997, 34.240001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2413.060058, 329.779998, 34.049999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2315.300048, 179.130004, 34.380001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2292.379882, 127.949996, 34.380001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2466.870117, -36.930000, 29.530000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2455.989990, -0.529999, 27.010000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2456.320068, -20.340000, 31.880001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2458.379882, -94.510002, 25.059999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2446.989990, -100.720001, 30.260000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2456.939941, -162.410003, 25.100000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2478.679931, -196.940002, 24.690000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2319.239990, -21.920000, 34.400001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2310.229980, -33.119998, 34.400001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2309.379882, -119.309997, 34.389999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2288.090087, -12.229999, 34.400001,		loot_Civilian, 15.0);

	CreateStaticLootSpawn(-2657.590087, -186.229995, 3.230000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2657.790039, -92.809997, 3.240000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2759.149902, -159.740005, 6.059999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2759.060058, -101.260002, 6.000000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2760.139892, -51.479999, 6.079999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2765.030029, 14.520000, 6.050000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2656.649902, 94.180000, 3.199999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2719.840087, 76.309997, 3.419999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2754.620117, 75.099998, 6.269999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2755.760009, 96.050003, 6.120000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2736.989990, 131.009994, 3.449999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2751.270019, 202.940002, 6.100000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2783.360107, 245.110000, 6.269999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2660.179931, 235.440002, 3.409999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2530.169921, 307.029998, 26.850000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2557.209960, 306.109985, 15.029999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2547.310058, 176.550003, 12.119999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2532.050048, -13.970000, 15.500000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2489.699951, 92.660003, 24.700000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2320.159912, -94.449996, 34.369998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2357.489990, -117.050003, 34.389999,		loot_Industrial, 12.0);

	CreateStaticLootSpawn(-2734.060058, 67.639999, 10.279999,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2720.620117, 143.559997, 14.750000,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2718.199951, -320.089996, 56.580001,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2477.290039, -148.360000, 32.720001,		loot_Survivor, 8.0);
}
SF_District_Housing2()
{
	CreateItem(item_Barbecue, -2701.1328, 845.7422, 70.3828, 171.0);

	CreateZipline(
		-2628.34, 778.85, 54.44,
		-2671.98, 726.87, 38.19);
	CreateZipline(
		-2674.76, 867.24, 82.52,
		-2674.28, 820.22, 73.14);

	CreateFuelOutlet(-2410.80, 970.85, 44.48, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-2410.80, 976.19, 44.48, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-2410.80, 981.52, 44.48, 2.0, 100.0, frandom(40.0));

	DefineWeaponsCachePos(-1838.79651, 1543.79602, 6.11533);
	DefineWeaponsCachePos(-1791.30994, 1543.37488, 6.12531);
	DefineWeaponsCachePos(-1740.91626, 1543.25623, 6.14425);
	DefineWeaponsCachePos(-1635.86804, 1395.58569, 6.10300);
	DefineWeaponsCachePos(-1687.91589, 1333.41431, 16.21160);
	DefineWeaponsCachePos(-1507.31702, 1376.17590, 2.70524);
	DefineWeaponsCachePos(-1470.77661, 1490.27856, 7.22244);
	DefineWeaponsCachePos(-1367.22815, 1488.73926, 10.00001);
	DefineWeaponsCachePos(-2312.12354, 1543.81042, 17.66385);
	DefineWeaponsCachePos(-2511.63599, 1546.00610, 16.22589);
	DefineWeaponsCachePos(-2482.55811, 1545.02832, 31.02781);
	DefineWeaponsCachePos(-2666.99951, 1595.01184, 216.26262);
	DefineWeaponsCachePos(-2677.81641, 1421.06689, 22.88134);
	DefineWeaponsCachePos(-2694.79102, 1450.10278, 6.08558);
	DefineWeaponsCachePos(-2650.59155, 1173.00110, 34.16104);
	DefineWeaponsCachePos(-2813.31299, 1144.59729, 19.29218);
	DefineWeaponsCachePos(-2448.96436, 986.39960, 44.28560);
	DefineWeaponsCachePos(-2326.22144, 1024.58105, 49.66642);
	DefineWeaponsCachePos(-2444.17920, 749.96143, 34.14997);
	DefineWeaponsCachePos(-2764.66406, 786.03918, 51.77070);
	DefineWeaponsCachePos(-2568.56030, 835.23065, 49.40046);
	DefineWeaponsCachePos(-2647.30957, 850.75775, 63.00303);
	DefineWeaponsCachePos(-2721.87305, 976.66754, 53.45127);
	DefineWeaponsCachePos(-2569.40210, 982.52228, 77.25880);

	CreateStaticLootSpawn(-2865.719970, 684.940002, 22.549999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2873.159912, 701.070007, 22.540000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2881.320068, 724.690002, 28.280000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2883.409912, 747.650024, 28.399999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2901.040039, 742.690002, 28.120000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2883.870117, 682.900024, 22.389999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2895.959960, 789.849975, 33.959999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2879.439941, 793.219970, 34.639999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2856.800048, 837.669982, 39.330001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2890.399902, 829.559997, 38.430000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2875.729980, 850.280029, 38.430000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2863.449951, 872.119995, 42.990001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2839.820068, 888.119995, 43.130001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2844.350097, 925.559997, 43.130001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2863.040039, 903.010009, 42.990001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2858.020019, 960.520019, 43.130001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2892.739990, 970.210021, 39.650001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2895.969970, 1000.070007, 39.740001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2901.320068, 1037.219970, 35.889999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2899.020019, 1070.060058, 31.210000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2925.320068, 1117.750000, 26.000000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2924.719970, 1157.829956, 12.590000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2902.820068, 1175.500000, 12.630000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2801.550048, 1184.300048, 19.350000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2803.340087, 1133.069946, 25.090000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2815.330078, 1118.569946, 27.409999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2803.070068, 1008.760009, 47.200000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2773.949951, 831.179992, 51.349998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2561.020019, 1146.250000, 54.799999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2535.290039, 1139.969970, 54.799999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2520.479980, 1145.729980, 54.799999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2408.989990, 1144.969970, 54.619998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2450.179931, 1150.180053, 54.700000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2373.340087, 1133.869995, 54.790000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2507.840087, 1152.469970, 54.549999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2505.790039, 1200.290039, 36.500000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2548.040039, 1230.800048, 36.500000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2361.239990, 1023.799987, 49.770000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2406.739990, 753.789978, 34.240001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2458.629882, 754.419982, 34.229999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2429.389892, 515.849975, 29.000000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2674.120117, 866.500000, 75.349998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2669.989990, 935.320007, 77.089996,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2664.080078, 988.150024, 64.040000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2702.750000, 790.469970, 49.060001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2678.739990, 789.679992, 49.060001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2660.459960, 790.530029, 49.049999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2646.560058, 790.400024, 49.049999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2672.409912, 836.119995, 49.060001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2647.379882, 850.260009, 63.090000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2675.270019, 733.840026, 27.020000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2644.629882, 739.030029, 27.020000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2622.030029, 778.729980, 43.939998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2622.110107, 761.929992, 35.920001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2627.590087, 741.390014, 29.659999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2510.629882, 775.770019, 34.250000,		loot_Civilian, 15.0);

	CreateStaticLootSpawn(-2453.479980, 503.850006, 29.159999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2462.090087, 780.349975, 34.229999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2461.729980, 791.090026, 34.229999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2444.219970, 1000.929992, 49.470001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2450.709960, 959.830017, 44.380001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2327.090087, 1009.900024, 49.770000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2465.459960, 1069.170043, 54.840000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2719.790039, 916.320007, 66.669998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2670.379882, 935.900024, 77.119995,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2654.280029, 881.450012, 78.709999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2655.959960, 852.460021, 63.090000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2711.550048, 850.159973, 69.769996,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2790.870117, 767.770019, 49.420001,		loot_Industrial, 12.0);

	CreateStaticLootSpawn(-2708.760009, 637.979980, 13.529999,		loot_Medical, 15.0);
	CreateStaticLootSpawn(-2695.540039, 638.109985, 13.529999,		loot_Medical, 15.0);
	CreateStaticLootSpawn(-2681.389892, 638.200012, 13.529999,		loot_Medical, 15.0);
	CreateStaticLootSpawn(-2668.889892, 638.219970, 13.529999,		loot_Medical, 15.0);
	CreateStaticLootSpawn(-2656.800048, 636.960021, 13.529999,		loot_Medical, 15.0);
	CreateStaticLootSpawn(-2639.649902, 635.359985, 13.529999,		loot_Medical, 15.0);
	CreateStaticLootSpawn(-2640.750000, 608.409973, 13.529999,		loot_Medical, 15.0);
	CreateStaticLootSpawn(-2677.270019, 607.510009, 13.529999,		loot_Medical, 15.0);
	CreateStaticLootSpawn(-2559.149902, 660.719970, 13.529999,		loot_Medical, 15.0);
	CreateStaticLootSpawn(-2592.840087, 642.150024, 13.529999,		loot_Medical, 15.0);

	CreateStaticLootSpawn(-2667.598458, 726.274737, 36.614374,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2681.168458, 821.994737, 72.984374,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2632.018458, 600.744737, 65.154374,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2687.028458, 566.274737, 47.744374,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2886.236083, 733.934997, 35.324878,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2876.267089, 697.207458, 31.315910,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2890.229003, 998.771545, 49.240909,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2706.065917, 833.276000, 72.859443,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2645.362792, 943.932250, 82.868766,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2867.237060, 829.848144, 45.652069,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2411.010009, 966.022827, 50.659019,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2410.520507, 986.809570, 50.665370,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2350.280517, 1007.932739, 54.922580,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2421.767578, 1025.393920, 57.249450,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2435.979492, 1014.319030, 57.251171,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2424.120361, 973.048156, 49.286979,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2718.520263, -316.485931, 56.483760,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2719.678710, -321.517150, 56.480880,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2716.296142, -321.320007, 56.482120,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2718.261962, -323.316436, 56.482421,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2721.492431, -320.216705, 56.482051,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2714.705810, -320.121429, 56.485260,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2641.839355, 562.990478, 47.608409,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2697.316406, 822.339538, 72.864700,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2688.914062, 831.070434, 72.860137,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2719.969970, -318.457824, 56.481571,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2716.626708, -318.528839, 56.481620,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2686.596435, 575.859375, 47.615821,		loot_Survivor, 8.0);

}
SF_District_Bayfront()
{
	DefineWeaponsCachePos(-1838.79651, 1543.79602, 6.11533);
	DefineWeaponsCachePos(-1791.30994, 1543.37488, 6.12531);
	DefineWeaponsCachePos(-1740.91626, 1543.25623, 6.14425);
	DefineWeaponsCachePos(-1635.86804, 1395.58569, 6.10300);
	DefineWeaponsCachePos(-1687.91589, 1333.41431, 16.21160);
	DefineWeaponsCachePos(-1507.31702, 1376.17590, 2.70524);
	DefineWeaponsCachePos(-1470.77661, 1490.27856, 7.22244);
	DefineWeaponsCachePos(-1367.22815, 1488.73926, 10.00001);
	DefineWeaponsCachePos(-2312.12354, 1543.81042, 17.66385);
	DefineWeaponsCachePos(-2511.63599, 1546.00610, 16.22589);
	DefineWeaponsCachePos(-2482.55811, 1545.02832, 31.02781);
	DefineWeaponsCachePos(-2666.99951, 1595.01184, 216.26262);
	DefineWeaponsCachePos(-2677.81641, 1421.06689, 22.88134);
	DefineWeaponsCachePos(-2694.79102, 1450.10278, 6.08558);

	CreateStaticLootSpawn(-1643.489990, 1421.900024, 6.269999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1626.489990, 1390.459960, 6.260000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1644.739990, 1386.229980, 8.860000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1694.489990, 1362.819946, 8.850000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1954.319946, 1342.770019, 6.210000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1555.800048, 1167.260009, 6.269999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1553.579956, 1061.890014, 6.260000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1496.770019, 920.690002, 6.220000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1617.270019, 1009.549987, 6.240000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1579.660034, 947.549987, 6.250000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1673.790039, 1083.910034, 7.100000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1622.020019, 1170.670043, 6.320000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1639.219970, 1282.680053, 6.110000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1737.920043, 1238.699951, 6.630000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2008.930053, 1384.410034, 6.260000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2630.489990, 1431.060058, 6.170000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2681.689941, 1452.540039, 6.170000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2626.189941, 1393.150024, 6.170000,		loot_Civilian, 15.0);

	CreateStaticLootSpawn(-1481.050048, 688.330017, 0.409999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1462.849975, 1019.309997, 0.860000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1467.579956, 1085.880004, 0.669999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1566.689941, 1266.930053, 0.509999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1509.030029, 1296.130004, 0.469999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1724.900024, 1433.119995, 0.450000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1891.660034, 1396.040039, 0.409999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2653.949951, 1358.109985, 6.210000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1725.810058, 1235.810058, 16.989999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1679.069946, 1210.069946, 20.239999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1661.189941, 1217.130004, 6.340000,		loot_Industrial, 12.0);

	CreateStaticLootSpawn(-1504.85859, 1374.5058458, 3.053452,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2671.62367, 1595.3435734, 2.273575,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2691.40367, 1595.0735734, 2.263575,		loot_Survivor, 8.0);
}
SF_District_City1()
{
	new
		buttonid[2];

	buttonid[0] = CreateButton(-2208.2568, 579.8558, 35.7653, "Press F to activate", 0);
	buttonid[1] = CreateButton(-2208.2561, 584.4679, 35.7653, "Press F to activate", 0);
	CreateDoor(16501, buttonid,
		-2211.40, 581.99, 36.37,   0.00, 0.00, 90.00,
		-2211.40, 581.99, 39.61,   0.00, 0.00, 90.00, .movesound = 6000, .stopsound = 6002);

	buttonid[0] = CreateButton(-2243.0400, 640.7287, 49.9911, "Press F to activate", 0);
	buttonid[1] = CreateButton(-2238.6035, 641.0287, 49.9911, "Press F to activate", 0);
	CreateDoor(16501, buttonid,
		-2241.90, 643.55, 50.69,   0.00, 0.00, 0.00,
		-2241.90, 643.55, 53.96,   0.00, 0.00, 0.00, .movesound = 6000, .stopsound = 6002);


	CreateZipline(
		-2176.1233, 624.6251, 64.5186,
		-2199.2416, 599.1184, 58.2986);

	CreateZipline(
		-2172.7917, 598.8414, 71.2611,
		-2225.6408, 661.6533, 67.7622);

	CreateLadder(-2208.4399, 646.6311, 53.9300, 63.7599, 90.7508);

	DefineWeaponsCachePos(-2211.60791, 1052.62097, 78.99883);
	DefineWeaponsCachePos(-2197.20264, 969.18610, 78.98930);
	DefineWeaponsCachePos(-2140.15234, 1218.97644, 46.25816);
	DefineWeaponsCachePos(-2110.48584, 977.87390, 70.49709);
	DefineWeaponsCachePos(-2103.68506, 899.04816, 75.69330);
	DefineWeaponsCachePos(-2234.26538, 584.21545, 50.35577);
	DefineWeaponsCachePos(-2221.83374, 707.35040, 62.58080);
	DefineWeaponsCachePos(-2200.90356, 678.93530, 68.23893);
	DefineWeaponsCachePos(-2164.82495, 686.34259, 88.94374);
	DefineWeaponsCachePos(-2274.15161, 534.39038, 34.01009);

	CreateStaticLootSpawn(-2194.120117, 453.790008, 34.250000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2178.100097, 606.299987, 34.240001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2155.020019, 634.299987, 51.450000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2126.510009, 575.909973, 34.250000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2168.689941, 364.970001, 34.389999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2287.709960, 729.130004, 48.509998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2277.600097, 653.789978, 48.520000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2280.370117, 578.940002, 34.229999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2280.959960, 916.440002, 65.719993,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2183.590087, 1032.069946, 79.059997,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2198.409912, 971.640014, 79.079994,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2172.500000, 1106.239990, 79.069999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2223.389892, 1082.310058, 79.079994,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2300.669921, 1099.130004, 79.000000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2127.409912, 1218.359985, 46.340000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2036.819946, 1193.189941, 44.520000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2110.750000, 1138.239990, 53.990001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2476.899902, 1267.069946, 27.319999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2476.800048, 1322.050048, 12.720000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2434.290039, 1341.449951, 7.510000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2435.560058, 1247.839965, 32.439998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2382.270019, 1231.890014, 31.200000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2382.370117, 1304.800048, 17.690000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2353.360107, 1322.050048, 14.329999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2353.729980, 1258.050048, 26.409999,		loot_Civilian, 15.0);

	CreateStaticLootSpawn(-2132.709960, 359.540008, 34.250000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2219.159912, 368.260009, 34.400001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2222.500000, 610.190002, 34.240001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2184.649902, 715.219970, 52.979999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2179.219970, 715.190002, 52.979999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2186.860107, 697.429992, 52.979999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2316.919921, 726.140014, 47.639999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2199.709960, 994.940002, 79.079994,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2217.989990, 1055.160034, 79.069999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2302.219970, 1051.060058, 70.239997,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2206.949951, 700.780029, 48.529998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2159.280029, 654.409973, 51.450000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2124.979980, 654.989990, 51.450000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2105.300048, 856.919982, 68.639999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2109.060058, 980.400024, 70.589996,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2107.939941, 1073.369995, 70.579994,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2102.629882, 654.320007, 51.439998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2082.830078, 771.789978, 68.649993,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2080.949951, 843.489990, 68.649993,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2073.679931, 971.500000, 61.970001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2075.439941, 1009.159973, 62.000000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2156.169921, 1216.430053, 46.340000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2178.919921, 1220.339965, 33.009998,		loot_Industrial, 12.0);

	CreateStaticLootSpawn(-2220.929931, 703.669982, 62.670001,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2164.510009, 606.809997, 72.129997,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2174.330078, 706.440002, 52.979999,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2197.189941, 849.880004, 68.809997,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2072.389892, 982.210021, 76.189994,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2073.310058, 978.419982, 69.459999,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2042.040039, 878.530029, 61.700000,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2230.679931, 589.190002, 50.439998,		loot_Survivor, 8.0);

}
SF_District_City2()
{
/*
	LinkTP(
		CreateButton(-1753.70, 883.57, 295.56, "Press ~k~~VEHICLE_ENTER_EXIT~ to enter"),
		CreateButton(-1749.37, 871.82, 25.23, "Press ~k~~VEHICLE_ENTER_EXIT~ to enter"));
*/
	CreateZipline(
		-2114.91, 923.88, 86.04,
		-1948.34, 952.88, 61.47);
	CreateZipline(
		-2085.09, 982.10, 80.66,
		-2019.65, 899.83, 62.78);
	CreateZipline(
		-1754.93, 884.69, 296.37,
		-1989.02, 624.56, 147.52);
	CreateZipline(
		-1754.93, 884.69, 296.44,
		-1851.00, 1077.59, 150.31);
	CreateZipline(
		-1753.09, 883.41, 296.08,
		-1748.49, 768.64, 169.70);
	CreateZipline(
		-1753.09, 883.41, 296.18,
		-1254.30, 953.72, 142.16);

	DefineWeaponsCachePos(-2046.87012, 463.17310, 34.12703);
	DefineWeaponsCachePos(-1947.86841, 488.86847, 30.91935);
	DefineWeaponsCachePos(-1931.62964, 577.71667, 34.13211);
	DefineWeaponsCachePos(-1951.34485, 718.47125, 45.55853);
	DefineWeaponsCachePos(-2082.19287, 770.99146, 68.55400);
	DefineWeaponsCachePos(-2021.50085, 871.65021, 61.63058);
	DefineWeaponsCachePos(-1988.12134, 896.95831, 44.18531);
	DefineWeaponsCachePos(-1921.87622, 961.96558, 44.80597);
	DefineWeaponsCachePos(-2074.21924, 1005.65887, 61.88423);
	DefineWeaponsCachePos(-1982.39417, 1118.25916, 52.10574);
	DefineWeaponsCachePos(-2009.34900, 1226.89587, 30.61418);
	DefineWeaponsCachePos(-1852.08179, 1302.13721, 58.73064);
	DefineWeaponsCachePos(-1794.35498, 1227.62781, 31.63998);
	DefineWeaponsCachePos(-1648.44714, 1205.13428, 31.90201);
	DefineWeaponsCachePos(-1706.03638, 1018.84833, 16.57570);
	DefineWeaponsCachePos(-1742.83679, 756.27258, 23.87367);
	DefineWeaponsCachePos(-1630.50244, 669.49847, 6.18189);
	DefineWeaponsCachePos(-1657.23267, 799.38824, 16.70249);
	DefineWeaponsCachePos(-1595.26514, 800.79590, 5.80202);
	DefineWeaponsCachePos(-1754.06091, 959.15283, 23.86285);
	DefineWeaponsCachePos(-1681.42395, 1109.79700, 53.69134);
	DefineWeaponsCachePos(-1651.70630, 1210.25659, 12.67112);
	DefineWeaponsCachePos(-1825.49988, 555.73029, 34.16164);

	CreateStaticLootSpawn(-1942.709960, 487.500000, 31.049999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1944.510009, 560.770019, 34.240001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1934.140014, 576.479980, 34.240001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1810.050048, 535.640014, 34.250000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1825.880004, 567.929992, 34.250000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1783.959960, 669.750000, 34.250000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1987.630004, 898.640014, 44.279998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1976.530029, 869.330017, 44.279998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2020.099975, 906.359985, 45.479999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1979.959960, 955.000000, 44.529998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1866.989990, 1080.630004, 45.150001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1982.640014, 1117.630004, 52.189998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2043.829956, 1027.719970, 53.750000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1914.800048, 1188.520019, 44.520000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1713.489990, 1205.709960, 24.190000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1749.810058, 1087.420043, 44.520000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1813.010009, 1079.060058, 45.159999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1764.719970, 961.359985, 23.960000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1741.819946, 960.369995, 23.960000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1697.969970, 950.619995, 23.969999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1749.390014, 862.250000, 23.969999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1750.040039, 906.330017, 23.969999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1736.390014, 790.229980, 23.969999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1705.689941, 785.820007, 23.950000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1603.109985, 780.659973, 5.900000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1600.219970, 871.590026, 8.289999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1629.329956, 891.020019, 8.940000,		loot_Civilian, 15.0);

	CreateStaticLootSpawn(-1978.959960, 429.779998, 24.190000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2054.510009, 455.980010, 34.250000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1959.560058, 618.289978, 34.090000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1950.540039, 796.150024, 54.799999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1779.180053, 763.190002, 23.969999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1659.739990, 788.770019, 17.180000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1680.979980, 1058.979980, 53.770000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1669.189941, 1018.320007, 7.000000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1770.939941, 1206.270019, 24.200000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1790.770019, 1223.550048, 31.729999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1837.060058, 992.390014, 44.689998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2050.909912, 1112.790039, 52.360000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2009.699951, 1226.750000, 30.710000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1962.369995, 1227.400024, 30.729999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1791.849975, 1304.280029, 58.810001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1833.890014, 1297.560058, 58.810001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1850.189941, 1287.250000, 49.520000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1778.030029, 1313.900024, 40.229999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1829.739990, 1306.729980, 30.940000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1843.319946, 1284.109985, 21.639999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1705.189941, 1017.330017, 16.659999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1715.119995, 1043.729980, 17.000000,		loot_Industrial, 12.0);

	CreateStaticLootSpawn(-1951.270019, 643.760009, 45.650001,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1981.880004, 657.570007, 45.650001,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1952.750000, 683.210021, 45.650001,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1923.599975, 666.200012, 45.650001,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1950.800048, 726.669982, 44.380001,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1982.650024, 702.380004, 45.650001,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1922.660034, 701.909973, 45.650001,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1920.949951, 714.369995, 45.650001,		loot_Military, 10.0);

	CreateStaticLootSpawn(-1917.630004, 946.890014, 44.900001,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1855.859985, 986.119995, 44.509998,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1868.219970, 972.479980, 48.759998,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1953.010009, 1018.929992, 66.899993,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1989.020019, 1106.050048, 82.679992,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1808.140014, 1027.050048, 44.319999,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1868.489990, 811.460021, 111.619995,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1844.569946, 825.570007, 108.929992,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1883.750000, 793.530029, 108.929992,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2021.959960, 771.820007, 61.560001,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2018.770019, 871.260009, 61.720001,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2018.300048, 901.650024, 59.720001,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2017.920043, 901.979980, 54.360000,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1780.020019, 1312.430053, 58.819999,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1854.550048, 1075.630004, 144.209991,	loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1820.050048, 1079.699951, 144.209991,	loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1922.229980, 630.080017, 144.360000,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1985.239990, 631.119995, 144.349990,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1982.329956, 692.289978, 144.360000,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1922.010009, 689.419982, 144.369995,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1935.520019, 775.359985, 104.319999,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1963.880004, 816.200012, 91.349998,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1738.650024, 789.030029, 166.709991,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1764.640014, 769.390014, 166.709991,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1766.949951, 810.690002, 166.709991,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1667.650024, 894.349975, 135.169998,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1668.020019, 878.099975, 135.169998,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1649.579956, 874.489990, 135.160003,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1683.380004, 897.469970, 135.169998,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1705.384277, 1005.410888, 16.573249,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1704.886718, 1008.051330, 16.574590,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1685.362304, 1060.684814, 16.574239,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1688.958374, 1058.720458, 16.575769,		loot_Survivor, 8.0);
}
SF_District_Naval()
{
	new buttonid[1];

	// Requires "./scriptfiles/Maps/SF/Naval Base.map" to remove:
	// RemoveBuildingForPlayer(playerid, 968, -1526.4375, 481.3828, 6.9063, 0.01);

	buttonid[0] = CreateButton(-1520.4270, 482.1193, 7.6727, "Press "KEYTEXT_INTERACT" to activate gate");

	CreateDoor(968, buttonid,
		-1526.4375, 481.3828, 7.02, 356.8584, 270.00, 0.0,
		-1526.4375, 481.3828, 7.00, 356.8584, 0.0000, 0.0,
		.closedelay = -1, .maxbuttons = 1, .movespeed = 0.01, .movesound = 0, .stopsound = 0);

	CreateStaticLootSpawn(-1346.540039, 492.079986, 10.279999,		loot_Civilian, 15.0);

	DefineWeaponsCachePos(-1568.56714, 312.95941, 6.16430);
	DefineWeaponsCachePos(-1474.82520, 324.02725, 6.13750);
	DefineWeaponsCachePos(-1333.39526, 373.50836, 6.17051);
	DefineWeaponsCachePos(-1332.49829, 408.23975, 6.16129);
	DefineWeaponsCachePos(-1466.05042, 391.89731, 6.17912);
	DefineWeaponsCachePos(-1465.70007, 353.19241, 6.17956);
	DefineWeaponsCachePos(-1464.51794, 427.33926, 6.17625);
	DefineWeaponsCachePos(-1333.34875, 444.43680, 6.16187);
	DefineWeaponsCachePos(-1257.79797, 501.39343, 17.22221);
	DefineWeaponsCachePos(-1351.65906, 501.28937, 17.26845);
	DefineWeaponsCachePos(-1398.96924, 497.37836, 17.22742);
	DefineWeaponsCachePos(-1443.14771, 494.93771, 17.21759);
	DefineWeaponsCachePos(-1529.59558, 365.36691, 6.13829);
	DefineWeaponsCachePos(-1520.81750, 494.38846, 6.17715);

	CreateStaticLootSpawn(-1465.579956, 339.299987, 6.280000,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1472.560058, 364.420013, 6.269999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1344.849975, 368.000000, 6.269999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1407.250000, 378.339996, 6.269999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1449.880004, 402.549987, 6.269999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1476.319946, 429.850006, 6.260000,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1401.060058, 414.570007, 6.260000,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1294.810058, 483.769989, 0.259999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1471.180053, 483.750000, 0.259999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1412.579956, 512.280029, 2.119999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1380.530029, 506.390014, 2.129999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1371.579956, 494.739990, 2.129999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1354.310058, 492.500000, 10.289999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1398.160034, 491.029998, 10.279999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1404.579956, 496.260009, 10.279999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1358.599975, 505.079986, 10.279999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1294.000000, 506.910003, 10.279999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1291.290039, 490.799987, 10.279999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1250.599975, 501.480010, 17.360000,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1313.859985, 491.769989, 17.309999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1390.660034, 496.200012, 17.309999,		loot_Military, 10.0);
	CreateStaticLootSpawn(-1369.589965, 490.459991, 23.380001,		loot_Military, 10.0);

	CreateStaticLootSpawn(-1341.034763, 493.847340, 32.344374,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1383.904763, 493.747340, 26.94374,		loot_Survivor, 8.0);
}
SF_District_Police()
{
	CreateStaticLootSpawn(-1615.52000, 685.33000, 6.48000,			loot_Police, 10.0);
	CreateStaticLootSpawn(-1590.78000, 716.26000, -6.15000,			loot_Police, 10.0);
	CreateStaticLootSpawn(-1623.20000, 668.23000, -5.86000,			loot_Police, 10.0);
	CreateStaticLootSpawn(-1576.75000, 683.36000, 6.33000,			loot_Police, 10.0);
	CreateStaticLootSpawn(-1670.43000, 696.55000, 29.70000,			loot_Police, 10.0);
}
SF_District_Industrial()
{
	CreateDynamicObject(2002, -1978.52356, 131.39619, 26.68210, 0.00000, 0.00000, 90.00000);
	CreateDynamic3DTextLabel("XBOX ONE", YELLOW, -1978.52356, 131.39619, 28.2150, 10.0);
	CreateWorkBench(-2124.13916, 219.68687, 34.66147, -128.63998);

	CreateFuelOutlet(-1679.3594, 403.0547, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1675.2188, 407.1953, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1669.9063, 412.5313, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1665.5234, 416.9141, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1685.9688, 409.6406, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1681.8281, 413.7813, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1676.5156, 419.1172, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1672.1328, 423.5000, 6.3828, 2.0, 100.0, frandom(35.0));

	DefineWeaponsCachePos(-2716.43823, 382.60507, 3.34639);
	DefineWeaponsCachePos(-2521.67456, 318.69183, 34.09675);
	DefineWeaponsCachePos(-2473.95605, 401.25406, 26.73841);
	DefineWeaponsCachePos(-2587.40479, 332.89505, 3.84088);
	DefineWeaponsCachePos(-2684.57642, 268.28076, 3.31175);
	DefineWeaponsCachePos(-2641.14673, 190.63800, 3.30231);
	DefineWeaponsCachePos(-2752.70020, 206.10161, 5.93917);
	DefineWeaponsCachePos(-2980.13965, 468.74667, 3.87113);
	DefineWeaponsCachePos(-2755.74316, 96.59800, 6.01551);
	DefineWeaponsCachePos(-2679.01245, -22.84922, 3.30198);
	DefineWeaponsCachePos(-2655.62231, 88.49954, 3.07376);
	DefineWeaponsCachePos(-2524.37085, -7.58145, 24.60770);
	DefineWeaponsCachePos(-2456.55249, -22.27232, 31.77888);
	DefineWeaponsCachePos(-2496.17969, 96.59895, 34.15479);
	DefineWeaponsCachePos(-2311.83350, 196.26547, 34.27616);
	DefineWeaponsCachePos(-2318.07178, 102.51508, 34.30185);
	DefineWeaponsCachePos(-2318.58887, -3.95909, 34.31125);
	DefineWeaponsCachePos(-2351.37231, -146.02968, 34.30040);
	DefineWeaponsCachePos(-2487.73804, -128.85942, 24.59999);
	DefineWeaponsCachePos(-2752.04517, -246.72028, 6.17439);
	DefineWeaponsCachePos(-2898.28613, -35.74038, 3.17566);
	DefineWeaponsCachePos(-2897.09619, 223.05794, 2.77412);
	DefineWeaponsCachePos(-2111.67480, -233.74495, 34.29289);
	DefineWeaponsCachePos(-2124.46118, -126.45124, 34.29319);
	DefineWeaponsCachePos(-2073.39575, -172.08612, 34.28024);
	DefineWeaponsCachePos(-2099.70801, -30.01222, 34.27067);
	DefineWeaponsCachePos(-2047.98547, 13.73487, 34.29177);
	DefineWeaponsCachePos(-2094.02441, 90.69981, 34.30629);
	DefineWeaponsCachePos(-2023.68958, 84.27389, 27.12345);
	DefineWeaponsCachePos(-1939.00598, 145.68996, 25.27828);
	DefineWeaponsCachePos(-1969.54260, 265.57611, 34.12888);
	DefineWeaponsCachePos(-2060.09033, 293.43243, 34.33141);
	DefineWeaponsCachePos(-2130.50269, 222.63608, 35.12024);
	DefineWeaponsCachePos(-2111.82446, 143.30721, 33.82689);
	DefineWeaponsCachePos(-2161.18530, 253.25722, 34.31134);
	DefineWeaponsCachePos(-2234.36841, 306.64288, 34.08678);
	DefineWeaponsCachePos(-1664.24829, 451.28119, 6.15673);
	DefineWeaponsCachePos(-1626.63635, 112.75829, -12.12942);
	DefineWeaponsCachePos(-1561.06958, 96.18565, 2.53192);
	DefineWeaponsCachePos(-1482.45276, 146.22197, 17.73873);
	DefineWeaponsCachePos(-1612.43555, 12.42134, 23.14303);
	DefineWeaponsCachePos(-1582.15430, 64.89886, 16.31585);
	DefineWeaponsCachePos(-1707.88635, 57.00654, 2.52927);
	DefineWeaponsCachePos(-1753.44312, -183.35468, 2.47866);
	DefineWeaponsCachePos(-1745.51611, 158.55383, 2.48789);
	DefineWeaponsCachePos(-1840.71997, -13.49674, 14.09450);
	DefineWeaponsCachePos(-1824.40051, -82.25533, 14.09643);
	DefineWeaponsCachePos(-1862.99194, -142.73291, 10.86462);
	DefineWeaponsCachePos(-1869.49231, -217.88721, 17.34285);
	DefineWeaponsCachePos(-1811.91846, -188.73935, 12.41115);

	CreateStaticLootSpawn(-2221.239990, -143.350006, 34.400001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2227.459960, -109.550003, 34.400001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2224.100097, -306.670013, 34.639999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2221.330078, -319.130004, 34.650001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2206.540039, -21.809999, 34.400001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2215.449951, 49.560001, 34.400001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2211.850097, 115.790000, 34.400001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2226.729980, 140.580001, 34.409999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2194.409912, 165.169998, 34.389999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2237.439941, 300.399993, 34.189998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2161.239990, 300.470001, 34.189998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2110.719970, -4.630000, 34.389999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2043.920043, -37.680000, 34.500000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2077.959960, 86.360000, 31.559999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2109.699951, 128.850006, 34.310001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2130.840087, 176.520004, 34.360000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2124.449951, 275.209991, 34.560001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2059.860107, 304.559997, 34.889999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1911.819946, 305.149993, 40.110000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1974.810058, 158.600006, 26.770000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1962.930053, 154.039993, 26.770000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1963.280029, 132.259994, 26.770000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1977.560058, 115.379997, 26.760000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1969.089965, 138.050003, 26.770000,		loot_Civilian, 15.0);

	CreateStaticLootSpawn(-1573.170043, 51.720001, 16.360000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1494.859985, 131.660003, 16.389999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1628.829956, 156.809997, 1.009999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1689.650024, 13.199999, 2.639999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1721.520019, 14.710000, 2.659999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1716.209960, -40.060001, 2.609999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1688.260009, -47.580001, 2.619999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1627.709960, -42.659999, 2.619999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1723.880004, 225.429992, 1.019999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1651.400024, 258.320007, 0.250000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1839.540039, -74.930000, 14.159999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1819.689941, -150.070007, 8.480000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1859.719970, -175.889999, 8.300000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1884.829956, -208.600006, 17.440000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1823.800048, -189.250000, 12.220000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1825.849975, 42.819999, 14.150000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1747.160034, 201.279998, 2.629999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1745.439941, 166.250000, 2.619999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1952.689941, 81.080001, 25.360000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1938.839965, 95.250000, 25.360000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1939.479980, 121.120002, 25.370000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1924.079956, 181.179992, 25.350000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2050.580078, 71.330001, 27.469999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1953.969970, 276.540008, 34.560001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1954.530029, 294.299987, 40.130001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1892.099975, 299.079986, 40.119998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2048.820068, 305.880004, 45.330001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2069.820068, 305.309997, 41.069999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2087.360107, 299.600006, 34.439998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2133.169921, 262.350006, 38.060001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2119.340087, 222.300003, 34.170001,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2119.189941, 221.669998, 37.889999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2131.580078, 190.750000, 45.590000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2132.120117, 173.889999, 41.319999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2131.590087, 150.759994, 40.500000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2100.419921, 132.710006, 34.599998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2090.340087, 84.769996, 34.389999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2239.270019, 115.809997, 34.389999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2015.130004, -112.360000, 34.209999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2151.370117, -103.440002, 34.389999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2150.169921, -133.029998, 35.590000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2101.889892, -196.949996, 34.389999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2184.969970, -214.850006, 35.610000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2185.090087, -237.470001, 35.610000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2159.010009, -228.199996, 35.599998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2144.189941, -247.940002, 35.610000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2185.250000, -247.000000, 35.610000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2182.110107, -263.799987, 35.599998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2145.270019, -263.600006, 35.599998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2055.350097, -225.039993, 34.389999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2020.420043, -272.070007, 34.369998,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1850.770019, -13.630000, 18.290000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1709.839965, 404.130004, 6.510000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1677.599975, 437.440002, 6.269999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1617.550048, -80.620002, 1.039999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1760.050048, -188.470001, 1.039999,		loot_Industrial, 12.0);

	CreateStaticLootSpawn(-1426.129272, -966.460998, 199.837814,	loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1435.656250, -959.542846, 199.946502,	loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1427.453491, -959.672424, 200.085449,	loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1432.990722, -965.091735, 199.961883,	loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1597.391479, 14.271209, 26.847660,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1585.873168, 21.918960, 33.054111,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1601.096679, 29.551740, 35.781711,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1592.966796, 30.497619, 35.781829,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1609.609252, 32.343601, 26.852989,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1604.519531, 41.764350, 33.060951,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1601.014282, 25.439979, 31.027650,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1738.221435, -22.317970, 14.751179,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1836.454223, 3.203059, 88.162078,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2196.316894, -274.095184, 34.311920,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2334.700439, -160.179428, 39.577770,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1845.781372, 3.016479, 88.161537,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1725.477539, -9.086099, 14.751170,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1851.608642, -149.832702, 20.639789,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1864.016479, -162.968460, 20.635780,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1961.556274, 258.980041, 46.680431,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1682.343017, 430.694000, 11.408100,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1679.729492, 406.736816, 11.413530,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1932.248046, 301.513366, 46.661540,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2105.155761, 136.726531, 42.346359,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2135.142578, 197.030914, 50.590980,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2041.598266, 307.133911, 50.286491,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1665.119384, 417.425231, 11.404919,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1615.957763, 15.085200, 23.151849,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1610.534423, 4.103499, 19.880670,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1621.125244, 15.134679, 19.884929,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1610.671997, 9.615260, 23.149129,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1693.037963, 417.812377, 11.415559,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1619.546264, -1.509310, 16.307559,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-1626.177001, 8.094010, 16.311029,		loot_Survivor, 8.0);

	CreateHackerTrap(-1844.83752, -101.30441, 4.64848,				loot_Military);
	CreateHackerTrap(-1842.06116, -103.07392, 4.64540,				loot_Military);
	CreateHackerTrap(-1849.03284, -103.55869, 4.64305,				loot_Military);
	CreateHackerTrap(-1848.35547, -98.46133, 4.64475,				loot_Military);
	CreateHackerTrap(-1842.68433, -98.32790, 4.64715,				loot_Military);
}
SF_District_SfAirport()
{
	DefineWeaponsCachePos(-1237.20361, 52.09208, 13.13244);
	DefineWeaponsCachePos(-1279.19019, 45.46248, 13.13572);
	DefineWeaponsCachePos(-1199.94641, -132.13683, 13.11613);
	DefineWeaponsCachePos(-1341.54285, -497.72485, 13.16293);
	DefineWeaponsCachePos(-1447.83240, -556.44781, 13.16663);
	DefineWeaponsCachePos(-1671.28918, -628.41888, 13.09485);
	DefineWeaponsCachePos(-1416.39600, -297.07736, 13.13366);
	DefineWeaponsCachePos(-1545.16748, -440.26828, 4.98256);
	DefineWeaponsCachePos(-1735.94885, -567.59247, 15.47855);
	DefineWeaponsCachePos(-1528.37463, -260.38547, 13.09692);
	DefineWeaponsCachePos(-1371.29199, -384.41708, 13.13528);

	CreateStaticLootSpawn(-1460.160034, -267.670013, 13.230000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1432.939941, -279.640014, 13.230000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1398.959960, -311.500000, 13.220000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1379.880004, -354.100006, 13.220000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1435.739990, -226.470001, 5.079999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1361.979980, -225.139999, 5.420000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1362.079956, -85.750000, 5.420000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1450.339965, 19.620000, 5.420000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1450.089965, -86.440002, 5.420000,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1423.219970, -145.520004, 5.079999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1423.310058, -245.809997, 5.079999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1406.160034, -13.310000, 5.550000,		loot_Civilian, 15.0);

	CreateStaticLootSpawn(-1253.670043, 62.709999, 13.230000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1373.699951, -524.340026, 13.250000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1350.760009, -462.359985, 13.239999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1467.199951, -520.020019, 13.239999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1425.829956, -527.739990, 13.250000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1235.880004, -85.580001, 13.220000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1195.130004, -134.399993, 13.220000,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1127.510009, -150.220001, 13.230000,		loot_Industrial, 12.0);

	CreateStaticLootSpawn(-1270.199951, 47.240001, 13.230000,		loot_Police, 10.0);
	CreateStaticLootSpawn(-1674.810058, -628.690002, 13.230000,		loot_Police, 10.0);
	CreateStaticLootSpawn(-1369.390014, 1.743399, 5.079999,			loot_Police, 10.0);
	CreateStaticLootSpawn(-1455.650024, -206.649993, 5.079999,		loot_Police, 10.0);
	CreateStaticLootSpawn(-1444.380004, -101.510002, 5.079999,		loot_Police, 10.0);
	CreateStaticLootSpawn(-1355.150024, -101.680000, 5.079999,		loot_Police, 10.0);

	CreateHackerTrap(1229.78259, 53.58940, 13.23220,				loot_Police);
	CreateHackerTrap(-1542.14001, -443.55999, 5.19000,				loot_Police);
}
SF_District_MontFoster()
{
	DefineWeaponsCachePos(-2150.16040, -408.60284, 34.30775);
	DefineWeaponsCachePos(-1986.81006, -497.92313, 34.31303);
	DefineWeaponsCachePos(-2555.83960, -251.85573, 20.41562);
	DefineWeaponsCachePos(-2614.35718, -305.86423, 21.81332);
	DefineWeaponsCachePos(-2515.93628, -248.72455, 37.54561);
	DefineWeaponsCachePos(-2417.03809, -230.64073, 39.51999);
	DefineWeaponsCachePos(-2296.50806, -260.05917, 42.32588);
	DefineWeaponsCachePos(-2424.78906, -304.97256, 56.97111);
	DefineWeaponsCachePos(-2518.56592, -343.68137, 57.11472);
	DefineWeaponsCachePos(-2304.42700, -342.69180, 64.54024);
	DefineWeaponsCachePos(-2342.75513, -359.71954, 67.41110);
	DefineWeaponsCachePos(-2387.56665, -577.08984, 131.10046);
	DefineWeaponsCachePos(-2518.69678, -596.86841, 131.70680);
	DefineWeaponsCachePos(-2050.66992, -853.88745, 31.16034);
	DefineWeaponsCachePos(-1997.96411, -967.32709, 31.15343);
	DefineWeaponsCachePos(-1949.76208, -841.21948, 34.88272);
	DefineWeaponsCachePos(-2000.53369, -971.46515, 31.11395);
	DefineWeaponsCachePos(-1893.49109, -858.82703, 31.01959);

	CreateStaticLootSpawn(-2380.239990, -580.710021, 131.179992,	loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2526.750000, -623.270019, 131.830001,	loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1954.599975, -733.030029, 34.970001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1962.479980, -779.250000, 34.979999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1946.989990, -872.179992, 34.979999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1962.900024, -946.830017, 34.979999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1951.609985, -987.030029, 34.970001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2117.639892, -807.369995, 31.059999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2136.360107, -910.510009, 31.069999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2107.810058, -963.299987, 31.229999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2159.469970, -407.820007, 34.420001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2149.800048, -430.660003, 34.420001,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2218.739990, -376.890014, 34.569999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2080.120117, -482.040008, 37.819999,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2058.780029, -493.720001, 34.619998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2021.290039, -491.209991, 34.619998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1990.859985, -488.829986, 34.619998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-1981.609985, -432.630004, 34.619998,		loot_Civilian, 15.0);
	CreateStaticLootSpawn(-2024.709960, -397.570007, 34.610000,		loot_Civilian, 15.0);

	CreateStaticLootSpawn(-2535.129882, -689.179992, 138.399993,	loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2052.120117, -860.059997, 31.239999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1945.180053, -1082.579956, 29.850000,	loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1961.790039, -895.799987, 34.979999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-1976.109985, -501.649993, 24.799999,		loot_Industrial, 12.0);
	CreateStaticLootSpawn(-2112.149902, -397.839996, 34.610000,		loot_Industrial, 12.0);

	CreateStaticLootSpawn(-2287.800048, -341.369995, 49.979999,		loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2529.790039, -657.880004, 146.989990,	loot_Survivor, 8.0);
	CreateStaticLootSpawn(-2635.080078, -498.980010, 69.379997,		loot_Survivor, 8.0);
}
SF_District_Ship1()
{
	CreateStaticLootSpawn(-2303.82, 1545.11, 17.89,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-2404.19, 1548.50, 25.07,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-2512.85, 1545.25, 16.40,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-2485.59, 1533.88, 27.10,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-2472.23, 1550.56, 35.85,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-2477.65, 1549.85, 32.30,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-2471.47, 1538.77, 32.28,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-2426.36, 1536.40, 1.23,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-2389.63, 1548.60, 1.15,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-2366.65, 1540.04, 1.14,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-2378.08, 1554.39, 1.17,					loot_Industrial, 12.0, 6);

	CreateStaticLootSpawn(-2351.49, 1550.50, 22.24,					loot_Survivor, 8.0, 6);
	CreateStaticLootSpawn(-2499.11, 1552.21, 23.23,					loot_Survivor, 8.0, 6);
	CreateStaticLootSpawn(-2474.53, 1552.21, 32.26,					loot_Survivor, 8.0, 6);
	CreateStaticLootSpawn(-2436.10, 1555.23, 1.22,					loot_Survivor, 8.0, 6);
	CreateStaticLootSpawn(-2404.49, 1534.92, 1.18,					loot_Survivor, 8.0, 6);
}
SF_District_Ship2()
{
	CreateStaticLootSpawn(-1478.84, 1489.43, 7.32,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-1371.58, 1486.57, 2.71,					loot_Industrial, 12.0, 6);
	CreateStaticLootSpawn(-1433.17, 1483.05, 0.93,					loot_Industrial, 12.0, 6);

	CreateStaticLootSpawn(-1404.98, 1486.13, 6.24,					loot_Survivor, 8.0, 6);
	CreateStaticLootSpawn(-1390.89, 1482.97, 0.95,					loot_Survivor, 8.0, 6);
	CreateStaticLootSpawn(-1425.41, 1490.25, 0.97,					loot_Survivor, 8.0, 6);
}
