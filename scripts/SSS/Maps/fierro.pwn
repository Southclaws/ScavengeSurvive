public OnLoad()
{
	print("Loading San Fierro");

	CreateLadder(-1164.6187, 370.0174, 1.9609, 14.1484, 221.1218);
	CreateLadder(-1182.6258, 60.4429, 1.9609, 14.1484, 134.2914);
	CreateLadder(-1736.4494, -445.9549, 1.9609, 14.1484, 270.7138);

	AddSprayTag(-1908.91, 299.56, 41.52, 0.00, 0.00, 180.00);
	AddSprayTag(-2636.70, 635.52, 15.63, 0.00, 0.00, 0.00);
	AddSprayTag(-2224.75, 881.27, 84.13, 0.00, 0.00, 90.00);
	AddSprayTag(-1788.32, 748.42, 25.36, 0.00, 0.00, 270.00);

	District_Housing1();
	District_Housing2();
	District_Bayfront();
	District_City1();
	District_City2();
	District_Naval();
	District_Police();
	District_Industrial();
	District_Airport();
	District_MontFoster();
	District_Ship1();
	District_Ship2();

	LinkTP(
		CreateButton(-904.7388, 335.7443, 1014.1530, "Press F to open", 0),
		CreateButton(-1857.1831, -169.5322, 9.1358, "Press F to open", 0));


	CreateItem(item_Barbecue, -2772.98, -94.21, 6.17,   0.00, 0.00, -76.08, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2663.80, -168.83, 3.31,   0.00, 0.00, -103.56, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2643.64, -98.28, 3.31,   0.00, 0.00, -123.48, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2668.34, 118.92, 3.47,   0.00, 0.00, -61.26, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2620.68, 259.43, 3.32,   0.00, 0.00, -113.76, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2702.96, 846.41, 69.70,   0.00, 0.00, -217.20, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2680.39, 931.05, 78.69,   0.00, 0.00, 58.74, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2646.92, 850.75, 63.01,   0.00, 0.00, -17.22, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2670.67, 790.34, 48.97,   0.00, 0.00, -194.16, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2532.54, 2230.10, 3.98,   0.00, 0.00, -226.44, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2558.33, 2256.55, 4.06,   0.00, 0.00, -231.24, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2430.86, 2368.72, 3.96,   0.00, 0.00, -168.30, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2479.55, 2483.86, 16.77,   0.00, 0.00, -203.28, .zoffset = FLOOR_OFFSET);
	CreateItem(item_Barbecue, -2446.11, 2512.45, 14.69,   0.00, 0.00, -132.60, .zoffset = FLOOR_OFFSET);

	return CallLocalFunction("fierro_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad fierro_OnLoad
forward fierro_OnLoad();


District_Housing1()
{
	CreateLootSpawn(-2720.340087, -318.529998, 6.930000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2744.159912, -291.399993, 6.079999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2776.780029, -304.290008, 6.120000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2649.449951, -307.170013, 6.329999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2752.159912, -252.050003, 6.260000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2773.340087, -172.770004, 6.260000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2746.800048, -166.660003, 5.269999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2773.520019, -146.130004, 6.250000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2755.270019, -197.070007, 6.110000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2758.090087, -127.290000, 6.019999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2773.070068, -87.500000, 6.260000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2749.030029, -88.669998, 5.350000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2661.360107, -95.970001, 3.409999,		3, 30, loot_Civilian);
	CreateLootSpawn(-2662.860107, -167.649993, 3.399999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2636.219970, -146.770004, 3.399999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2653.639892, -128.360000, 3.209999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2648.139892, -29.790000, 5.190000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2672.270019, -5.989999, 5.190000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2630.580078, -5.739999, 5.210000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2652.120117, 21.489999, 5.200000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2771.770019, -45.380001, 6.250000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2745.959960, -23.139999, 5.079999,		3, 30, loot_Civilian);
	CreateLootSpawn(-2764.100097, 2.799999, 6.050000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2776.649902, 103.900001, 6.240000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2775.800048, 193.050003, 6.250000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2780.580078, 220.289993, 6.240000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2724.340087, 365.910003, 3.459999,		3, 30, loot_Civilian);
	CreateLootSpawn(-2689.020019, 382.750000, 3.429999,		3, 30, loot_Civilian);
	CreateLootSpawn(-2656.070068, 376.049987, 3.389999,		3, 30, loot_Civilian);
	CreateLootSpawn(-2660.649902, 185.850006, 3.399999,		3, 30, loot_Civilian);
	CreateLootSpawn(-2687.669921, 181.679992, 3.399999,		3, 30, loot_Civilian);
	CreateLootSpawn(-2651.790039, 80.839996, 3.189999,		3, 30, loot_Civilian);
	CreateLootSpawn(-2652.209960, 126.290000, 3.240000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2666.489990, 127.500000, 3.539999,		3, 30, loot_Civilian);
	CreateLootSpawn(-2669.889892, 68.959999, 3.389999,		3, 30, loot_Civilian);
	CreateLootSpawn(-2580.439941, 310.140014, 4.260000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2571.040039, 327.329986, 9.640000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2499.659912, 312.420013, 34.180000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2472.090087, 397.809997, 26.840000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2525.189941, 305.769989, 34.189998,	3, 30, loot_Civilian);
	CreateLootSpawn(-2501.479980, 260.980010, 34.229999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2458.449951, 133.429992, 34.240001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2491.290039, 111.360000, 24.950000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2506.260009, 106.129997, 34.240001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2413.060058, 329.779998, 34.049999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2315.300048, 179.130004, 34.380001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2292.379882, 127.949996, 34.380001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2466.870117, -36.930000, 29.530000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2455.989990, -0.529999, 27.010000,		3, 30, loot_Civilian);
	CreateLootSpawn(-2456.320068, -20.340000, 31.880001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2458.379882, -94.510002, 25.059999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2446.989990, -100.720001, 30.260000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2456.939941, -162.410003, 25.100000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2478.679931, -196.940002, 24.690000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2319.239990, -21.920000, 34.400001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2310.229980, -33.119998, 34.400001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2309.379882, -119.309997, 34.389999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2288.090087, -12.229999, 34.400001,	3, 30, loot_Civilian);

	CreateLootSpawn(-2657.590087, -186.229995, 3.230000,	3, 35, loot_Industrial);
	CreateLootSpawn(-2657.790039, -92.809997, 3.240000,		3, 35, loot_Industrial);
	CreateLootSpawn(-2759.149902, -159.740005, 6.059999,	3, 35, loot_Industrial);
	CreateLootSpawn(-2759.060058, -101.260002, 6.000000,	3, 35, loot_Industrial);
	CreateLootSpawn(-2760.139892, -51.479999, 6.079999,		3, 35, loot_Industrial);
	CreateLootSpawn(-2765.030029, 14.520000, 6.050000,		3, 35, loot_Industrial);
	CreateLootSpawn(-2656.649902, 94.180000, 3.199999,		3, 35, loot_Industrial);
	CreateLootSpawn(-2719.840087, 76.309997, 3.419999,		3, 35, loot_Industrial);
	CreateLootSpawn(-2754.620117, 75.099998, 6.269999,		3, 35, loot_Industrial);
	CreateLootSpawn(-2755.760009, 96.050003, 6.120000,		3, 35, loot_Industrial);
	CreateLootSpawn(-2736.989990, 131.009994, 3.449999,		3, 35, loot_Industrial);
	CreateLootSpawn(-2751.270019, 202.940002, 6.100000,		3, 35, loot_Industrial);
	CreateLootSpawn(-2783.360107, 245.110000, 6.269999,		3, 35, loot_Industrial);
	CreateLootSpawn(-2660.179931, 235.440002, 3.409999,		3, 35, loot_Industrial);
	CreateLootSpawn(-2530.169921, 307.029998, 26.850000,	3, 35, loot_Industrial);
	CreateLootSpawn(-2557.209960, 306.109985, 15.029999,	3, 35, loot_Industrial);
	CreateLootSpawn(-2547.310058, 176.550003, 12.119999,	3, 35, loot_Industrial);
	CreateLootSpawn(-2532.050048, -13.970000, 15.500000,	3, 35, loot_Industrial);
	CreateLootSpawn(-2489.699951, 92.660003, 24.700000,		3, 35, loot_Industrial);
	CreateLootSpawn(-2320.159912, -94.449996, 34.369998,	3, 35, loot_Industrial);
	CreateLootSpawn(-2357.489990, -117.050003, 34.389999,	3, 35, loot_Industrial);

	CreateLootSpawn(-2734.060058, 67.639999, 10.279999,		2, 70, loot_Survivor);
	CreateLootSpawn(-2720.620117, 143.559997, 14.750000,	2, 70, loot_Survivor);
	CreateLootSpawn(-2718.199951, -320.089996, 56.580001,	2, 70, loot_Survivor);
	CreateLootSpawn(-2477.290039, -148.360000, 32.720001,	2, 70, loot_Survivor);
}
District_Housing2()
{
	LinkTP(
		CreateButton(-2578.1204, 1144.8810, 40.3989, "Press F to enter"),
		CreateButton(-2587.5229, 1162.4547, 55.5876, "Press F to enter"));

	CreateItem(item_Barbecue, -2701.1328, 845.7422, 70.3828, 171.0);

	CreateZipline(
		-2628.34, 778.85, 54.44,
		-2671.98, 726.87, 38.19);
	CreateZipline(
		-2674.76, 867.24, 82.52,
		-2674.28, 820.22, 73.14);

	CreateFuelOutlet(-2410.80, 970.85, 44.48, 2.0, 100.0, float(random(100)));
	CreateFuelOutlet(-2410.80, 976.19, 44.48, 2.0, 100.0, float(random(100)));
	CreateFuelOutlet(-2410.80, 981.52, 44.48, 2.0, 100.0, float(random(100)));

	CreateLootSpawn(-2865.719970, 684.940002, 22.549999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2873.159912, 701.070007, 22.540000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2881.320068, 724.690002, 28.280000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2883.409912, 747.650024, 28.399999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2901.040039, 742.690002, 28.120000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2883.870117, 682.900024, 22.389999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2895.959960, 789.849975, 33.959999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2879.439941, 793.219970, 34.639999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2856.800048, 837.669982, 39.330001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2890.399902, 829.559997, 38.430000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2875.729980, 850.280029, 38.430000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2863.449951, 872.119995, 42.990001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2839.820068, 888.119995, 43.130001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2844.350097, 925.559997, 43.130001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2863.040039, 903.010009, 42.990001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2858.020019, 960.520019, 43.130001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2892.739990, 970.210021, 39.650001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2895.969970, 1000.070007, 39.740001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2901.320068, 1037.219970, 35.889999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2899.020019, 1070.060058, 31.210000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2925.320068, 1117.750000, 26.000000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2924.719970, 1157.829956, 12.590000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2902.820068, 1175.500000, 12.630000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2801.550048, 1184.300048, 19.350000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2803.340087, 1133.069946, 25.090000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2815.330078, 1118.569946, 27.409999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2803.070068, 1008.760009, 47.200000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2773.949951, 831.179992, 51.349998,	3, 30, loot_Civilian);
	CreateLootSpawn(-2561.020019, 1146.250000, 54.799999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2535.290039, 1139.969970, 54.799999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2520.479980, 1145.729980, 54.799999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2408.989990, 1144.969970, 54.619998,	3, 30, loot_Civilian);
	CreateLootSpawn(-2450.179931, 1150.180053, 54.700000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2373.340087, 1133.869995, 54.790000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2507.840087, 1152.469970, 54.549999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2505.790039, 1200.290039, 36.500000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2548.040039, 1230.800048, 36.500000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2361.239990, 1023.799987, 49.770000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2406.739990, 753.789978, 34.240001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2458.629882, 754.419982, 34.229999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2429.389892, 515.849975, 29.000000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2674.120117, 866.500000, 75.349998,	3, 30, loot_Civilian);
	CreateLootSpawn(-2669.989990, 935.320007, 77.089996,	3, 30, loot_Civilian);
	CreateLootSpawn(-2664.080078, 988.150024, 64.040000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2702.750000, 790.469970, 49.060001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2678.739990, 789.679992, 49.060001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2660.459960, 790.530029, 49.049999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2646.560058, 790.400024, 49.049999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2672.409912, 836.119995, 49.060001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2647.379882, 850.260009, 63.090000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2675.270019, 733.840026, 27.020000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2644.629882, 739.030029, 27.020000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2622.030029, 778.729980, 43.939998,	3, 30, loot_Civilian);
	CreateLootSpawn(-2622.110107, 761.929992, 35.920001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2627.590087, 741.390014, 29.659999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2510.629882, 775.770019, 34.250000,	3, 30, loot_Civilian);

	CreateLootSpawn(-2453.479980, 503.850006, 29.159999,	3, 24, loot_Industrial);
	CreateLootSpawn(-2462.090087, 780.349975, 34.229999,	3, 24, loot_Industrial);
	CreateLootSpawn(-2461.729980, 791.090026, 34.229999,	3, 24, loot_Industrial);
	CreateLootSpawn(-2444.219970, 1000.929992, 49.470001,	3, 24, loot_Industrial);
	CreateLootSpawn(-2450.709960, 959.830017, 44.380001,	3, 24, loot_Industrial);
	CreateLootSpawn(-2327.090087, 1009.900024, 49.770000,	3, 24, loot_Industrial);
	CreateLootSpawn(-2465.459960, 1069.170043, 54.840000,	3, 24, loot_Industrial);
	CreateLootSpawn(-2719.790039, 916.320007, 66.669998,	3, 24, loot_Industrial);
	CreateLootSpawn(-2670.379882, 935.900024, 77.119995,	3, 24, loot_Industrial);
	CreateLootSpawn(-2654.280029, 881.450012, 78.709999,	3, 24, loot_Industrial);
	CreateLootSpawn(-2655.959960, 852.460021, 63.090000,	3, 24, loot_Industrial);
	CreateLootSpawn(-2711.550048, 850.159973, 69.769996,	3, 24, loot_Industrial);
	CreateLootSpawn(-2790.870117, 767.770019, 49.420001,	3, 24, loot_Industrial);

	CreateLootSpawn(-2708.760009, 637.979980, 13.529999,	3, 25, loot_Medical);
	CreateLootSpawn(-2695.540039, 638.109985, 13.529999,	3, 25, loot_Medical);
	CreateLootSpawn(-2681.389892, 638.200012, 13.529999,	3, 25, loot_Medical);
	CreateLootSpawn(-2668.889892, 638.219970, 13.529999,	3, 25, loot_Medical);
	CreateLootSpawn(-2656.800048, 636.960021, 13.529999,	3, 25, loot_Medical);
	CreateLootSpawn(-2639.649902, 635.359985, 13.529999,	3, 25, loot_Medical);
	CreateLootSpawn(-2640.750000, 608.409973, 13.529999,	3, 25, loot_Medical);
	CreateLootSpawn(-2677.270019, 607.510009, 13.529999,	3, 25, loot_Medical);
	CreateLootSpawn(-2559.149902, 660.719970, 13.529999,	3, 25, loot_Medical);
	CreateLootSpawn(-2592.840087, 642.150024, 13.529999,	3, 25, loot_Medical);

	CreateLootSpawn(-2667.598458, 726.274737, 36.614374,	3, 40, loot_Survivor);
	CreateLootSpawn(-2681.168458, 821.994737, 72.984374,	3, 40, loot_Survivor);
	CreateLootSpawn(-2632.018458, 600.744737, 65.154374,	3, 40, loot_Survivor);
	CreateLootSpawn(-2687.028458, 566.274737, 47.744374,	3, 40, loot_Survivor);
	CreateLootSpawn(-2886.236083, 733.934997, 35.324878,	3, 30, loot_Survivor);
	CreateLootSpawn(-2876.267089, 697.207458, 31.315910,	3, 30, loot_Survivor);
	CreateLootSpawn(-2890.229003, 998.771545, 49.240909,	3, 30, loot_Survivor);
	CreateLootSpawn(-2706.065917, 833.276000, 72.859443,	3, 30, loot_Survivor);
	CreateLootSpawn(-2645.362792, 943.932250, 82.868766,	3, 30, loot_Survivor);
	CreateLootSpawn(-2867.237060, 829.848144, 45.652069,	3, 30, loot_Survivor);
	CreateLootSpawn(-2411.010009, 966.022827, 50.659019,	3, 30, loot_Survivor);
	CreateLootSpawn(-2410.520507, 986.809570, 50.665370,	3, 30, loot_Survivor);
	CreateLootSpawn(-2350.280517, 1007.932739, 54.922580,	3, 30, loot_Survivor);
	CreateLootSpawn(-2421.767578, 1025.393920, 57.249450,	3, 30, loot_Survivor);
	CreateLootSpawn(-2435.979492, 1014.319030, 57.251171,	3, 30, loot_Survivor);
	CreateLootSpawn(-2424.120361, 973.048156, 49.286979,	3, 30, loot_Survivor);
	CreateLootSpawn(-2718.520263, -316.485931, 56.483760,	3, 30, loot_Survivor);
	CreateLootSpawn(-2719.678710, -321.517150, 56.480880,	3, 30, loot_Survivor);
	CreateLootSpawn(-2716.296142, -321.320007, 56.482120,	3, 30, loot_Survivor);
	CreateLootSpawn(-2718.261962, -323.316436, 56.482421,	3, 30, loot_Survivor);
	CreateLootSpawn(-2721.492431, -320.216705, 56.482051,	3, 30, loot_Survivor);
	CreateLootSpawn(-2714.705810, -320.121429, 56.485260,	3, 30, loot_Survivor);
	CreateLootSpawn(-2641.839355, 562.990478, 47.608409,	3, 30, loot_Survivor);
	CreateLootSpawn(-2697.316406, 822.339538, 72.864700,	3, 30, loot_Survivor);
	CreateLootSpawn(-2688.914062, 831.070434, 72.860137,	3, 30, loot_Survivor);
	CreateLootSpawn(-2719.969970, -318.457824, 56.481571,	3, 30, loot_Survivor);
	CreateLootSpawn(-2716.626708, -318.528839, 56.481620,	3, 30, loot_Survivor);
	CreateLootSpawn(-2686.596435, 575.859375, 47.615821,	3, 30, loot_Survivor);

}
District_Bayfront()
{
	CreateLootSpawn(-1643.489990, 1421.900024, 6.269999,	3, 40, loot_Civilian);
	CreateLootSpawn(-1626.489990, 1390.459960, 6.260000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1644.739990, 1386.229980, 8.860000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1694.489990, 1362.819946, 8.850000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1954.319946, 1342.770019, 6.210000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1555.800048, 1167.260009, 6.269999,	3, 40, loot_Civilian);
	CreateLootSpawn(-1553.579956, 1061.890014, 6.260000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1496.770019, 920.690002, 6.220000,		3, 40, loot_Civilian);
	CreateLootSpawn(-1617.270019, 1009.549987, 6.240000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1579.660034, 947.549987, 6.250000,		3, 40, loot_Civilian);
	CreateLootSpawn(-1673.790039, 1083.910034, 7.100000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1622.020019, 1170.670043, 6.320000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1639.219970, 1282.680053, 6.110000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1737.920043, 1238.699951, 6.630000,	3, 40, loot_Civilian);
	CreateLootSpawn(-2008.930053, 1384.410034, 6.260000,	3, 40, loot_Civilian);
	CreateLootSpawn(-2630.489990, 1431.060058, 6.170000,	3, 40, loot_Civilian);
	CreateLootSpawn(-2681.689941, 1452.540039, 6.170000,	3, 40, loot_Civilian);
	CreateLootSpawn(-2626.189941, 1393.150024, 6.170000,	3, 40, loot_Civilian);

	CreateLootSpawn(-1481.050048, 688.330017, 0.409999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1462.849975, 1019.309997, 0.860000,	3, 40, loot_Industrial);
	CreateLootSpawn(-1467.579956, 1085.880004, 0.669999,	3, 40, loot_Industrial);
	CreateLootSpawn(-1566.689941, 1266.930053, 0.509999,	3, 40, loot_Industrial);
	CreateLootSpawn(-1509.030029, 1296.130004, 0.469999,	3, 40, loot_Industrial);
	CreateLootSpawn(-1724.900024, 1433.119995, 0.450000,	3, 40, loot_Industrial);
	CreateLootSpawn(-1891.660034, 1396.040039, 0.409999,	3, 40, loot_Industrial);
	CreateLootSpawn(-2653.949951, 1358.109985, 6.210000,	3, 40, loot_Industrial);
	CreateLootSpawn(-1725.810058, 1235.810058, 16.989999,	3, 40, loot_Industrial);
	CreateLootSpawn(-1679.069946, 1210.069946, 20.239999,	3, 40, loot_Industrial);
	CreateLootSpawn(-1661.189941, 1217.130004, 6.340000,	3, 40, loot_Industrial);

	CreateLootSpawn(-1504.85859, 1374.5058458, 3.053452,	3, 20, loot_Survivor);
	CreateLootSpawn(-2671.62367, 1595.3435734, 2.273575,	3, 20, loot_Survivor);
	CreateLootSpawn(-2691.40367, 1595.0735734, 2.263575,	3, 20, loot_Survivor);
}
District_City1()
{
	new
		buttonid[2];

	buttonid[0] = CreateButton(-2208.2568, 579.8558, 35.7653, "Press F to activate", 0);
	buttonid[1] = CreateButton(-2208.2561, 584.4679, 35.7653, "Press F to activate", 0);
	CreateDoor(16501, buttonid,
		-2211.40, 581.99, 36.37,   0.00, 0.00, 90.00,
		-2211.40, 581.99, 39.61,   0.00, 0.00, 90.00);

	buttonid[0] = CreateButton(-2243.0400, 640.7287, 49.9911, "Press F to activate", 0);
	buttonid[1] = CreateButton(-2238.6035, 641.0287, 49.9911, "Press F to activate", 0);
	CreateDoor(16501, buttonid,
		-2241.90, 643.55, 50.69,   0.00, 0.00, 0.00,
		-2241.90, 643.55, 53.96,   0.00, 0.00, 0.00);


	CreateZipline(
		-2176.1233, 624.6251, 64.5186,
		-2199.2416, 599.1184, 58.2986);

	CreateZipline(
		-2172.7917, 598.8414, 71.2611,
		-2225.6408, 661.6533, 67.7622);

	CreateLadder(-2208.4399, 646.6311, 53.9300, 63.7599, 90.7508);

	CreateLootSpawn(-2194.120117, 453.790008, 34.250000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2178.100097, 606.299987, 34.240001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2155.020019, 634.299987, 51.450000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2126.510009, 575.909973, 34.250000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2168.689941, 364.970001, 34.389999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2287.709960, 729.130004, 48.509998,	3, 30, loot_Civilian);
	CreateLootSpawn(-2277.600097, 653.789978, 48.520000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2280.370117, 578.940002, 34.229999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2280.959960, 916.440002, 65.719993,	3, 30, loot_Civilian);
	CreateLootSpawn(-2183.590087, 1032.069946, 79.059997,	3, 30, loot_Civilian);
	CreateLootSpawn(-2198.409912, 971.640014, 79.079994,	3, 30, loot_Civilian);
	CreateLootSpawn(-2172.500000, 1106.239990, 79.069999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2223.389892, 1082.310058, 79.079994,	3, 30, loot_Civilian);
	CreateLootSpawn(-2300.669921, 1099.130004, 79.000000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2127.409912, 1218.359985, 46.340000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2036.819946, 1193.189941, 44.520000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2110.750000, 1138.239990, 53.990001,	3, 30, loot_Civilian);
	CreateLootSpawn(-2476.899902, 1267.069946, 27.319999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2476.800048, 1322.050048, 12.720000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2434.290039, 1341.449951, 7.510000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2435.560058, 1247.839965, 32.439998,	3, 30, loot_Civilian);
	CreateLootSpawn(-2382.270019, 1231.890014, 31.200000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2382.370117, 1304.800048, 17.690000,	3, 30, loot_Civilian);
	CreateLootSpawn(-2353.360107, 1322.050048, 14.329999,	3, 30, loot_Civilian);
	CreateLootSpawn(-2353.729980, 1258.050048, 26.409999,	3, 30, loot_Civilian);

	CreateLootSpawn(-2132.709960, 359.540008, 34.250000,	4, 15, loot_Industrial);
	CreateLootSpawn(-2219.159912, 368.260009, 34.400001,	4, 15, loot_Industrial);
	CreateLootSpawn(-2222.500000, 610.190002, 34.240001,	4, 15, loot_Industrial);
	CreateLootSpawn(-2184.649902, 715.219970, 52.979999,	4, 15, loot_Industrial);
	CreateLootSpawn(-2179.219970, 715.190002, 52.979999,	4, 15, loot_Industrial);
	CreateLootSpawn(-2186.860107, 697.429992, 52.979999,	4, 15, loot_Industrial);
	CreateLootSpawn(-2316.919921, 726.140014, 47.639999,	4, 15, loot_Industrial);
	CreateLootSpawn(-2199.709960, 994.940002, 79.079994,	4, 15, loot_Industrial);
	CreateLootSpawn(-2217.989990, 1055.160034, 79.069999,	4, 15, loot_Industrial);
	CreateLootSpawn(-2302.219970, 1051.060058, 70.239997,	4, 15, loot_Industrial);
	CreateLootSpawn(-2206.949951, 700.780029, 48.529998,	4, 15, loot_Industrial);
	CreateLootSpawn(-2159.280029, 654.409973, 51.450000,	4, 15, loot_Industrial);
	CreateLootSpawn(-2124.979980, 654.989990, 51.450000,	4, 15, loot_Industrial);
	CreateLootSpawn(-2105.300048, 856.919982, 68.639999,	4, 15, loot_Industrial);
	CreateLootSpawn(-2109.060058, 980.400024, 70.589996,	4, 15, loot_Industrial);
	CreateLootSpawn(-2107.939941, 1073.369995, 70.579994,	4, 15, loot_Industrial);
	CreateLootSpawn(-2102.629882, 654.320007, 51.439998,	4, 15, loot_Industrial);
	CreateLootSpawn(-2082.830078, 771.789978, 68.649993,	4, 15, loot_Industrial);
	CreateLootSpawn(-2080.949951, 843.489990, 68.649993,	4, 15, loot_Industrial);
	CreateLootSpawn(-2073.679931, 971.500000, 61.970001,	4, 15, loot_Industrial);
	CreateLootSpawn(-2075.439941, 1009.159973, 62.000000,	4, 15, loot_Industrial);
	CreateLootSpawn(-2156.169921, 1216.430053, 46.340000,	4, 15, loot_Industrial);
	CreateLootSpawn(-2178.919921, 1220.339965, 33.009998,	4, 15, loot_Industrial);

	CreateLootSpawn(-2220.929931, 703.669982, 62.670001,	4, 20, loot_Survivor);
	CreateLootSpawn(-2164.510009, 606.809997, 72.129997,	4, 20, loot_Survivor);
	CreateLootSpawn(-2174.330078, 706.440002, 52.979999,	4, 20, loot_Survivor);
	CreateLootSpawn(-2197.189941, 849.880004, 68.809997,	4, 20, loot_Survivor);
	CreateLootSpawn(-2072.389892, 982.210021, 76.189994,	4, 20, loot_Survivor);
	CreateLootSpawn(-2073.310058, 978.419982, 69.459999,	4, 20, loot_Survivor);
	CreateLootSpawn(-2042.040039, 878.530029, 61.700000,	4, 20, loot_Survivor);
	CreateLootSpawn(-2230.679931, 589.190002, 50.439998,	4, 20, loot_Survivor);

}
District_City2()
{
	LinkTP(
		CreateButton(-1753.70, 883.57, 295.56, "Press ~k~~VEHICLE_ENTER_EXIT~ to enter"),
		CreateButton(-1749.37, 871.82, 25.23, "Press ~k~~VEHICLE_ENTER_EXIT~ to enter"));

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

	CreateLootSpawn(-1942.709960, 487.500000, 31.049999,	4, 30, loot_Civilian);
	CreateLootSpawn(-1944.510009, 560.770019, 34.240001,	4, 30, loot_Civilian);
	CreateLootSpawn(-1934.140014, 576.479980, 34.240001,	4, 30, loot_Civilian);
	CreateLootSpawn(-1810.050048, 535.640014, 34.250000,	4, 30, loot_Civilian);
	CreateLootSpawn(-1825.880004, 567.929992, 34.250000,	4, 30, loot_Civilian);
	CreateLootSpawn(-1783.959960, 669.750000, 34.250000,	4, 30, loot_Civilian);
	CreateLootSpawn(-1987.630004, 898.640014, 44.279998,	4, 30, loot_Civilian);
	CreateLootSpawn(-1976.530029, 869.330017, 44.279998,	4, 30, loot_Civilian);
	CreateLootSpawn(-2020.099975, 906.359985, 45.479999,	4, 30, loot_Civilian);
	CreateLootSpawn(-1979.959960, 955.000000, 44.529998,	4, 30, loot_Civilian);
	CreateLootSpawn(-1866.989990, 1080.630004, 45.150001,	4, 30, loot_Civilian);
	CreateLootSpawn(-1982.640014, 1117.630004, 52.189998,	4, 30, loot_Civilian);
	CreateLootSpawn(-2043.829956, 1027.719970, 53.750000,	4, 30, loot_Civilian);
	CreateLootSpawn(-1914.800048, 1188.520019, 44.520000,	4, 30, loot_Civilian);
	CreateLootSpawn(-1713.489990, 1205.709960, 24.190000,	4, 30, loot_Civilian);
	CreateLootSpawn(-1749.810058, 1087.420043, 44.520000,	4, 30, loot_Civilian);
	CreateLootSpawn(-1813.010009, 1079.060058, 45.159999,	4, 30, loot_Civilian);
	CreateLootSpawn(-1764.719970, 961.359985, 23.960000,	4, 30, loot_Civilian);
	CreateLootSpawn(-1741.819946, 960.369995, 23.960000,	4, 30, loot_Civilian);
	CreateLootSpawn(-1697.969970, 950.619995, 23.969999,	4, 30, loot_Civilian);
	CreateLootSpawn(-1749.390014, 862.250000, 23.969999,	4, 30, loot_Civilian);
	CreateLootSpawn(-1750.040039, 906.330017, 23.969999,	4, 30, loot_Civilian);
	CreateLootSpawn(-1736.390014, 790.229980, 23.969999,	4, 30, loot_Civilian);
	CreateLootSpawn(-1705.689941, 785.820007, 23.950000,	4, 30, loot_Civilian);
	CreateLootSpawn(-1603.109985, 780.659973, 5.900000,		4, 30, loot_Civilian);
	CreateLootSpawn(-1600.219970, 871.590026, 8.289999,		4, 30, loot_Civilian);
	CreateLootSpawn(-1629.329956, 891.020019, 8.940000,		4, 30, loot_Civilian);

	CreateLootSpawn(-1978.959960, 429.779998, 24.190000,	3, 35, loot_Industrial);
	CreateLootSpawn(-2054.510009, 455.980010, 34.250000,	3, 35, loot_Industrial);
	CreateLootSpawn(-1959.560058, 618.289978, 34.090000,	3, 35, loot_Industrial);
	CreateLootSpawn(-1950.540039, 796.150024, 54.799999,	3, 35, loot_Industrial);
	CreateLootSpawn(-1779.180053, 763.190002, 23.969999,	3, 35, loot_Industrial);
	CreateLootSpawn(-1659.739990, 788.770019, 17.180000,	3, 35, loot_Industrial);
	CreateLootSpawn(-1680.979980, 1058.979980, 53.770000,	3, 35, loot_Industrial);
	CreateLootSpawn(-1669.189941, 1018.320007, 7.000000,	3, 35, loot_Industrial);
	CreateLootSpawn(-1770.939941, 1206.270019, 24.200000,	3, 35, loot_Industrial);
	CreateLootSpawn(-1790.770019, 1223.550048, 31.729999,	3, 35, loot_Industrial);
	CreateLootSpawn(-1837.060058, 992.390014, 44.689998,	3, 35, loot_Industrial);
	CreateLootSpawn(-2050.909912, 1112.790039, 52.360000,	3, 35, loot_Industrial);
	CreateLootSpawn(-2009.699951, 1226.750000, 30.710000,	3, 35, loot_Industrial);
	CreateLootSpawn(-1962.369995, 1227.400024, 30.729999,	3, 35, loot_Industrial);
	CreateLootSpawn(-1791.849975, 1304.280029, 58.810001,	3, 35, loot_Industrial);
	CreateLootSpawn(-1833.890014, 1297.560058, 58.810001,	3, 35, loot_Industrial);
	CreateLootSpawn(-1850.189941, 1287.250000, 49.520000,	3, 35, loot_Industrial);
	CreateLootSpawn(-1778.030029, 1313.900024, 40.229999,	3, 35, loot_Industrial);
	CreateLootSpawn(-1829.739990, 1306.729980, 30.940000,	3, 35, loot_Industrial);
	CreateLootSpawn(-1843.319946, 1284.109985, 21.639999,	3, 35, loot_Industrial);
	CreateLootSpawn(-1705.189941, 1017.330017, 16.659999,	3, 35, loot_Industrial);
	CreateLootSpawn(-1715.119995, 1043.729980, 17.000000,	3, 35, loot_Industrial);

	CreateLootSpawn(-1951.270019, 643.760009, 45.650001,	4, 10, loot_Military);
	CreateLootSpawn(-1981.880004, 657.570007, 45.650001,	4, 10, loot_Military);
	CreateLootSpawn(-1952.750000, 683.210021, 45.650001,	4, 10, loot_Military);
	CreateLootSpawn(-1923.599975, 666.200012, 45.650001,	4, 10, loot_Military);
	CreateLootSpawn(-1950.800048, 726.669982, 44.380001,	4, 10, loot_Military);
	CreateLootSpawn(-1982.650024, 702.380004, 45.650001,	4, 10, loot_Military);
	CreateLootSpawn(-1922.660034, 701.909973, 45.650001,	4, 10, loot_Military);
	CreateLootSpawn(-1920.949951, 714.369995, 45.650001,	4, 10, loot_Military);

	CreateLootSpawn(-1917.630004, 946.890014, 44.900001,	5, 10, loot_Survivor);
	CreateLootSpawn(-1855.859985, 986.119995, 44.509998,	5, 10, loot_Survivor);
	CreateLootSpawn(-1868.219970, 972.479980, 48.759998,	5, 10, loot_Survivor);
	CreateLootSpawn(-1953.010009, 1018.929992, 66.899993,	5, 10, loot_Survivor);
	CreateLootSpawn(-1989.020019, 1106.050048, 82.679992,	5, 10, loot_Survivor);
	CreateLootSpawn(-1808.140014, 1027.050048, 44.319999,	5, 10, loot_Survivor);
	CreateLootSpawn(-1868.489990, 811.460021, 111.619995,	5, 10, loot_Survivor);
	CreateLootSpawn(-1844.569946, 825.570007, 108.929992,	5, 10, loot_Survivor);
	CreateLootSpawn(-1883.750000, 793.530029, 108.929992,	5, 10, loot_Survivor);
	CreateLootSpawn(-2021.959960, 771.820007, 61.560001,	5, 10, loot_Survivor);
	CreateLootSpawn(-2018.770019, 871.260009, 61.720001,	5, 10, loot_Survivor);
	CreateLootSpawn(-2018.300048, 901.650024, 59.720001,	5, 10, loot_Survivor);
	CreateLootSpawn(-2017.920043, 901.979980, 54.360000,	5, 10, loot_Survivor);
	CreateLootSpawn(-1780.020019, 1312.430053, 58.819999,	5, 10, loot_Survivor);
	CreateLootSpawn(-1854.550048, 1075.630004, 144.209991,	5, 10, loot_Survivor);
	CreateLootSpawn(-1820.050048, 1079.699951, 144.209991,	5, 10, loot_Survivor);
	CreateLootSpawn(-1922.229980, 630.080017, 144.360000,	5, 10, loot_Survivor);
	CreateLootSpawn(-1985.239990, 631.119995, 144.349990,	5, 10, loot_Survivor);
	CreateLootSpawn(-1982.329956, 692.289978, 144.360000,	5, 10, loot_Survivor);
	CreateLootSpawn(-1922.010009, 689.419982, 144.369995,	5, 10, loot_Survivor);
	CreateLootSpawn(-1935.520019, 775.359985, 104.319999,	5, 10, loot_Survivor);
	CreateLootSpawn(-1963.880004, 816.200012, 91.349998,	5, 10, loot_Survivor);
	CreateLootSpawn(-1738.650024, 789.030029, 166.709991,	5, 10, loot_Survivor);
	CreateLootSpawn(-1764.640014, 769.390014, 166.709991,	5, 10, loot_Survivor);
	CreateLootSpawn(-1766.949951, 810.690002, 166.709991,	5, 10, loot_Survivor);
	CreateLootSpawn(-1667.650024, 894.349975, 135.169998,	5, 10, loot_Survivor);
	CreateLootSpawn(-1668.020019, 878.099975, 135.169998,	5, 10, loot_Survivor);
	CreateLootSpawn(-1649.579956, 874.489990, 135.160003,	5, 10, loot_Survivor);
	CreateLootSpawn(-1683.380004, 897.469970, 135.169998,	5, 10, loot_Survivor);
	CreateLootSpawn(-1705.384277, 1005.410888, 16.573249,	3, 30, loot_Survivor);
	CreateLootSpawn(-1704.886718, 1008.051330, 16.574590,	3, 30, loot_Survivor);
	CreateLootSpawn(-1685.362304, 1060.684814, 16.574239,	3, 30, loot_Survivor);
	CreateLootSpawn(-1688.958374, 1058.720458, 16.575769,	3, 30, loot_Survivor);
}
District_Naval()
{
	CreateLootSpawn(-1346.540039, 492.079986, 10.279999,	3, 25, loot_Civilian);

	CreateLootSpawn(-1465.579956, 339.299987, 6.280000,		3, 25, loot_Military);
	CreateLootSpawn(-1472.560058, 364.420013, 6.269999,		3, 25, loot_Military);
	CreateLootSpawn(-1344.849975, 368.000000, 6.269999,		3, 25, loot_Military);
	CreateLootSpawn(-1407.250000, 378.339996, 6.269999,		3, 25, loot_Military);
	CreateLootSpawn(-1449.880004, 402.549987, 6.269999,		3, 25, loot_Military);
	CreateLootSpawn(-1476.319946, 429.850006, 6.260000,		3, 25, loot_Military);
	CreateLootSpawn(-1401.060058, 414.570007, 6.260000,		3, 25, loot_Military);
	CreateLootSpawn(-1294.810058, 483.769989, 0.259999,		3, 25, loot_Military);
	CreateLootSpawn(-1471.180053, 483.750000, 0.259999,		3, 25, loot_Military);
	CreateLootSpawn(-1412.579956, 512.280029, 2.119999,		3, 25, loot_Military);
	CreateLootSpawn(-1380.530029, 506.390014, 2.129999,		3, 25, loot_Military);
	CreateLootSpawn(-1371.579956, 494.739990, 2.129999,		3, 25, loot_Military);
	CreateLootSpawn(-1354.310058, 492.500000, 10.289999,	3, 25, loot_Military);
	CreateLootSpawn(-1398.160034, 491.029998, 10.279999,	3, 25, loot_Military);
	CreateLootSpawn(-1404.579956, 496.260009, 10.279999,	3, 25, loot_Military);
	CreateLootSpawn(-1358.599975, 505.079986, 10.279999,	3, 25, loot_Military);
	CreateLootSpawn(-1294.000000, 506.910003, 10.279999,	3, 25, loot_Military);
	CreateLootSpawn(-1291.290039, 490.799987, 10.279999,	3, 25, loot_Military);
	CreateLootSpawn(-1250.599975, 501.480010, 17.360000,	3, 25, loot_Military);
	CreateLootSpawn(-1313.859985, 491.769989, 17.309999,	3, 25, loot_Military);
	CreateLootSpawn(-1390.660034, 496.200012, 17.309999,	3, 25, loot_Military);
	CreateLootSpawn(-1369.589965, 490.459991, 23.380001,	3, 25, loot_Military);

	CreateLootSpawn(-1341.034763, 493.847340, 32.344374,	2, 40, loot_Survivor);
	CreateLootSpawn(-1383.904763, 493.747340, 26.94374,		2, 40, loot_Survivor);
}
District_Police()
{
	CreateLootSpawn(-1615.52, 685.33, 6.48,		3, 30, loot_Police);
	CreateLootSpawn(-1590.78, 716.26, -6.15,	3, 30, loot_Police);
	CreateLootSpawn(-1623.20, 668.23, -5.86,	3, 30, loot_Police);
	CreateLootSpawn(-1576.75, 683.36, 6.33,		3, 30, loot_Police);
	CreateLootSpawn(-1670.43, 696.55, 29.70,	3, 30, loot_Police);
}
District_Industrial()
{
	CreateFuelOutlet(-1679.3594, 403.0547, 6.3828, 2.0, 100.0, float(random(130)));
	CreateFuelOutlet(-1675.2188, 407.1953, 6.3828, 2.0, 100.0, float(random(130)));
	CreateFuelOutlet(-1669.9063, 412.5313, 6.3828, 2.0, 100.0, float(random(130)));
	CreateFuelOutlet(-1665.5234, 416.9141, 6.3828, 2.0, 100.0, float(random(130)));
	CreateFuelOutlet(-1685.9688, 409.6406, 6.3828, 2.0, 100.0, float(random(130)));
	CreateFuelOutlet(-1681.8281, 413.7813, 6.3828, 2.0, 100.0, float(random(130)));
	CreateFuelOutlet(-1676.5156, 419.1172, 6.3828, 2.0, 100.0, float(random(130)));
	CreateFuelOutlet(-1672.1328, 423.5000, 6.3828, 2.0, 100.0, float(random(130)));

	CreateLootSpawn(-2221.239990, -143.350006, 34.400001,	3, 40, loot_Civilian);
	CreateLootSpawn(-2227.459960, -109.550003, 34.400001,	3, 40, loot_Civilian);
	CreateLootSpawn(-2224.100097, -306.670013, 34.639999,	3, 40, loot_Civilian);
	CreateLootSpawn(-2221.330078, -319.130004, 34.650001,	3, 40, loot_Civilian);
	CreateLootSpawn(-2206.540039, -21.809999, 34.400001,	3, 40, loot_Civilian);
	CreateLootSpawn(-2215.449951, 49.560001, 34.400001,		3, 40, loot_Civilian);
	CreateLootSpawn(-2211.850097, 115.790000, 34.400001,	3, 40, loot_Civilian);
	CreateLootSpawn(-2226.729980, 140.580001, 34.409999,	3, 40, loot_Civilian);
	CreateLootSpawn(-2194.409912, 165.169998, 34.389999,	3, 40, loot_Civilian);
	CreateLootSpawn(-2237.439941, 300.399993, 34.189998,	3, 40, loot_Civilian);
	CreateLootSpawn(-2161.239990, 300.470001, 34.189998,	3, 40, loot_Civilian);
	CreateLootSpawn(-2110.719970, -4.630000, 34.389999,		3, 40, loot_Civilian);
	CreateLootSpawn(-2043.920043, -37.680000, 34.500000,	3, 40, loot_Civilian);
	CreateLootSpawn(-2077.959960, 86.360000, 31.559999,		3, 40, loot_Civilian);
	CreateLootSpawn(-2109.699951, 128.850006, 34.310001,	3, 40, loot_Civilian);
	CreateLootSpawn(-2130.840087, 176.520004, 34.360000,	3, 40, loot_Civilian);
	CreateLootSpawn(-2124.449951, 275.209991, 34.560001,	3, 40, loot_Civilian);
	CreateLootSpawn(-2059.860107, 304.559997, 34.889999,	3, 40, loot_Civilian);
	CreateLootSpawn(-1911.819946, 305.149993, 40.110000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1974.810058, 158.600006, 26.770000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1962.930053, 154.039993, 26.770000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1963.280029, 132.259994, 26.770000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1977.560058, 115.379997, 26.760000,	3, 40, loot_Civilian);
	CreateLootSpawn(-1969.089965, 138.050003, 26.770000,	3, 40, loot_Civilian);

	CreateLootSpawn(-1573.170043, 51.720001, 16.360000,		3, 40, loot_Industrial);
	CreateLootSpawn(-1494.859985, 131.660003, 16.389999,	3, 40, loot_Industrial);
	CreateLootSpawn(-1628.829956, 156.809997, 1.009999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1689.650024, 13.199999, 2.639999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1721.520019, 14.710000, 2.659999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1716.209960, -40.060001, 2.609999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1688.260009, -47.580001, 2.619999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1627.709960, -42.659999, 2.619999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1723.880004, 225.429992, 1.019999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1651.400024, 258.320007, 0.250000,		3, 40, loot_Industrial);
	CreateLootSpawn(-1839.540039, -74.930000, 14.159999,	3, 40, loot_Industrial);
	CreateLootSpawn(-1819.689941, -150.070007, 8.480000,	3, 40, loot_Industrial);
	CreateLootSpawn(-1859.719970, -175.889999, 8.300000,	3, 40, loot_Industrial);
	CreateLootSpawn(-1884.829956, -208.600006, 17.440000,	3, 40, loot_Industrial);
	CreateLootSpawn(-1823.800048, -189.250000, 12.220000,	3, 40, loot_Industrial);
	CreateLootSpawn(-1825.849975, 42.819999, 14.150000,		3, 40, loot_Industrial);
	CreateLootSpawn(-1747.160034, 201.279998, 2.629999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1745.439941, 166.250000, 2.619999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1952.689941, 81.080001, 25.360000,		3, 40, loot_Industrial);
	CreateLootSpawn(-1938.839965, 95.250000, 25.360000,		3, 40, loot_Industrial);
	CreateLootSpawn(-1939.479980, 121.120002, 25.370000,	3, 40, loot_Industrial);
	CreateLootSpawn(-1924.079956, 181.179992, 25.350000,	3, 40, loot_Industrial);
	CreateLootSpawn(-2050.580078, 71.330001, 27.469999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1953.969970, 276.540008, 34.560001,	3, 40, loot_Industrial);
	CreateLootSpawn(-1954.530029, 294.299987, 40.130001,	3, 40, loot_Industrial);
	CreateLootSpawn(-1892.099975, 299.079986, 40.119998,	3, 40, loot_Industrial);
	CreateLootSpawn(-2048.820068, 305.880004, 45.330001,	3, 40, loot_Industrial);
	CreateLootSpawn(-2069.820068, 305.309997, 41.069999,	3, 40, loot_Industrial);
	CreateLootSpawn(-2087.360107, 299.600006, 34.439998,	3, 40, loot_Industrial);
	CreateLootSpawn(-2133.169921, 262.350006, 38.060001,	3, 40, loot_Industrial);
	CreateLootSpawn(-2119.340087, 222.300003, 34.170001,	3, 40, loot_Industrial);
	CreateLootSpawn(-2119.189941, 221.669998, 37.889999,	3, 40, loot_Industrial);
	CreateLootSpawn(-2131.580078, 190.750000, 45.590000,	3, 40, loot_Industrial);
	CreateLootSpawn(-2132.120117, 173.889999, 41.319999,	3, 40, loot_Industrial);
	CreateLootSpawn(-2131.590087, 150.759994, 40.500000,	3, 40, loot_Industrial);
	CreateLootSpawn(-2100.419921, 132.710006, 34.599998,	3, 40, loot_Industrial);
	CreateLootSpawn(-2090.340087, 84.769996, 34.389999,		3, 40, loot_Industrial);
	CreateLootSpawn(-2239.270019, 115.809997, 34.389999,	3, 40, loot_Industrial);
	CreateLootSpawn(-2015.130004, -112.360000, 34.209999,	3, 40, loot_Industrial);
	CreateLootSpawn(-2151.370117, -103.440002, 34.389999,	3, 40, loot_Industrial);
	CreateLootSpawn(-2150.169921, -133.029998, 35.590000,	3, 40, loot_Industrial);
	CreateLootSpawn(-2101.889892, -196.949996, 34.389999,	3, 40, loot_Industrial);
	CreateLootSpawn(-2184.969970, -214.850006, 35.610000,	3, 40, loot_Industrial);
	CreateLootSpawn(-2185.090087, -237.470001, 35.610000,	3, 40, loot_Industrial);
	CreateLootSpawn(-2159.010009, -228.199996, 35.599998,	3, 40, loot_Industrial);
	CreateLootSpawn(-2144.189941, -247.940002, 35.610000,	3, 40, loot_Industrial);
	CreateLootSpawn(-2185.250000, -247.000000, 35.610000,	3, 40, loot_Industrial);
	CreateLootSpawn(-2182.110107, -263.799987, 35.599998,	3, 40, loot_Industrial);
	CreateLootSpawn(-2145.270019, -263.600006, 35.599998,	3, 40, loot_Industrial);
	CreateLootSpawn(-2055.350097, -225.039993, 34.389999,	3, 40, loot_Industrial);
	CreateLootSpawn(-2020.420043, -272.070007, 34.369998,	3, 40, loot_Industrial);
	CreateLootSpawn(-1850.770019, -13.630000, 18.290000,	3, 40, loot_Industrial);
	CreateLootSpawn(-1709.839965, 404.130004, 6.510000,		3, 40, loot_Industrial);
	CreateLootSpawn(-1677.599975, 437.440002, 6.269999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1617.550048, -80.620002, 1.039999,		3, 40, loot_Industrial);
	CreateLootSpawn(-1760.050048, -188.470001, 1.039999,	3, 40, loot_Industrial);

	CreateLootSpawn(-1426.129272, -966.460998, 199.837814,	3, 30, loot_Survivor);
	CreateLootSpawn(-1435.656250, -959.542846, 199.946502,	3, 30, loot_Survivor);
	CreateLootSpawn(-1427.453491, -959.672424, 200.085449,	3, 30, loot_Survivor);
	CreateLootSpawn(-1432.990722, -965.091735, 199.961883,	3, 30, loot_Survivor);
	CreateLootSpawn(-1597.391479, 14.271209, 26.847660,		3, 30, loot_Survivor);
	CreateLootSpawn(-1585.873168, 21.918960, 33.054111,		3, 30, loot_Survivor);
	CreateLootSpawn(-1601.096679, 29.551740, 35.781711,		3, 30, loot_Survivor);
	CreateLootSpawn(-1592.966796, 30.497619, 35.781829,		3, 30, loot_Survivor);
	CreateLootSpawn(-1609.609252, 32.343601, 26.852989,		3, 30, loot_Survivor);
	CreateLootSpawn(-1604.519531, 41.764350, 33.060951,		3, 30, loot_Survivor);
	CreateLootSpawn(-1601.014282, 25.439979, 31.027650,		3, 30, loot_Survivor);
	CreateLootSpawn(-1738.221435, -22.317970, 14.751179,	3, 30, loot_Survivor);
	CreateLootSpawn(-1836.454223, 3.203059, 88.162078,		3, 30, loot_Survivor);
	CreateLootSpawn(-2196.316894, -274.095184, 34.311920,	3, 30, loot_Survivor);
	CreateLootSpawn(-2334.700439, -160.179428, 39.577770,	3, 30, loot_Survivor);
	CreateLootSpawn(-1845.781372, 3.016479, 88.161537,		3, 30, loot_Survivor);
	CreateLootSpawn(-1725.477539, -9.086099, 14.751170,		3, 30, loot_Survivor);
	CreateLootSpawn(-1851.608642, -149.832702, 20.639789,	3, 30, loot_Survivor);
	CreateLootSpawn(-1864.016479, -162.968460, 20.635780,	3, 30, loot_Survivor);
	CreateLootSpawn(-1961.556274, 258.980041, 46.680431,	3, 30, loot_Survivor);
	CreateLootSpawn(-1682.343017, 430.694000, 11.408100,	3, 30, loot_Survivor);
	CreateLootSpawn(-1679.729492, 406.736816, 11.413530,	3, 30, loot_Survivor);
	CreateLootSpawn(-1932.248046, 301.513366, 46.661540,	3, 30, loot_Survivor);
	CreateLootSpawn(-2105.155761, 136.726531, 42.346359,	3, 30, loot_Survivor);
	CreateLootSpawn(-2135.142578, 197.030914, 50.590980,	3, 30, loot_Survivor);
	CreateLootSpawn(-2041.598266, 307.133911, 50.286491,	3, 30, loot_Survivor);
	CreateLootSpawn(-1665.119384, 417.425231, 11.404919,	3, 30, loot_Survivor);
	CreateLootSpawn(-1615.957763, 15.085200, 23.151849,		3, 30, loot_Survivor);
	CreateLootSpawn(-1610.534423, 4.103499, 19.880670,		3, 30, loot_Survivor);
	CreateLootSpawn(-1621.125244, 15.134679, 19.884929,		3, 30, loot_Survivor);
	CreateLootSpawn(-1610.671997, 9.615260, 23.149129,		3, 30, loot_Survivor);
	CreateLootSpawn(-1693.037963, 417.812377, 11.415559,	3, 30, loot_Survivor);
	CreateLootSpawn(-1619.546264, -1.509310, 16.307559,		3, 30, loot_Survivor);
	CreateLootSpawn(-1626.177001, 8.094010, 16.311029,		3, 30, loot_Survivor);
}
District_Airport()
{
	CreateLootSpawn(-1460.160034, -267.670013, 13.230000,	4, 20, loot_Civilian);
	CreateLootSpawn(-1432.939941, -279.640014, 13.230000,	4, 20, loot_Civilian);
	CreateLootSpawn(-1398.959960, -311.500000, 13.220000,	4, 20, loot_Civilian);
	CreateLootSpawn(-1379.880004, -354.100006, 13.220000,	4, 20, loot_Civilian);
	CreateLootSpawn(-1435.739990, -226.470001, 5.079999,	4, 20, loot_Civilian);
	CreateLootSpawn(-1361.979980, -225.139999, 5.420000,	4, 20, loot_Civilian);
	CreateLootSpawn(-1362.079956, -85.750000, 5.420000,		4, 20, loot_Civilian);
	CreateLootSpawn(-1450.339965, 19.620000, 5.420000,		4, 20, loot_Civilian);
	CreateLootSpawn(-1450.089965, -86.440002, 5.420000,		4, 20, loot_Civilian);
	CreateLootSpawn(-1423.219970, -145.520004, 5.079999,	4, 20, loot_Civilian);
	CreateLootSpawn(-1423.310058, -245.809997, 5.079999,	4, 20, loot_Civilian);
	CreateLootSpawn(-1406.160034, -13.310000, 5.550000,		4, 20, loot_Civilian);

	CreateLootSpawn(-1253.670043, 62.709999, 13.230000,		3, 34, loot_Industrial);
	CreateLootSpawn(-1373.699951, -524.340026, 13.250000,	3, 34, loot_Industrial);
	CreateLootSpawn(-1350.760009, -462.359985, 13.239999,	3, 34, loot_Industrial);
	CreateLootSpawn(-1467.199951, -520.020019, 13.239999,	3, 34, loot_Industrial);
	CreateLootSpawn(-1425.829956, -527.739990, 13.250000,	3, 34, loot_Industrial);
	CreateLootSpawn(-1235.880004, -85.580001, 13.220000,	3, 34, loot_Industrial);
	CreateLootSpawn(-1195.130004, -134.399993, 13.220000,	3, 34, loot_Industrial);
	CreateLootSpawn(-1127.510009, -150.220001, 13.230000,	3, 34, loot_Industrial);

	CreateLootSpawn(-1542.140014, -443.559997, 5.190000,	3, 30, loot_Police);
	CreateLootSpawn(-1229.810058, 53.180000, 13.319999,		3, 30, loot_Police);
	CreateLootSpawn(-1270.199951, 47.240001, 13.230000,		3, 30, loot_Police);
	CreateLootSpawn(-1674.810058, -628.690002, 13.230000,	3, 30, loot_Police);
	CreateLootSpawn(-1369.390014, 1.743399, 5.079999,		3, 30, loot_Police);
	CreateLootSpawn(-1455.650024, -206.649993, 5.079999,	3, 30, loot_Police);
	CreateLootSpawn(-1444.380004, -101.510002, 5.079999,	3, 30, loot_Police);
	CreateLootSpawn(-1355.150024, -101.680000, 5.079999,	3, 30, loot_Police);
}
District_MontFoster()
{
	CreateLootSpawn(-2380.239990, -580.710021, 131.179992,	4, 30, loot_Civilian);
	CreateLootSpawn(-2526.750000, -623.270019, 131.830001,	4, 30, loot_Civilian);
	CreateLootSpawn(-1954.599975, -733.030029, 34.970001,	4, 30, loot_Civilian);
	CreateLootSpawn(-1962.479980, -779.250000, 34.979999,	4, 30, loot_Civilian);
	CreateLootSpawn(-1946.989990, -872.179992, 34.979999,	4, 30, loot_Civilian);
	CreateLootSpawn(-1962.900024, -946.830017, 34.979999,	4, 30, loot_Civilian);
	CreateLootSpawn(-1951.609985, -987.030029, 34.970001,	4, 30, loot_Civilian);
	CreateLootSpawn(-2117.639892, -807.369995, 31.059999,	4, 30, loot_Civilian);
	CreateLootSpawn(-2136.360107, -910.510009, 31.069999,	4, 30, loot_Civilian);
	CreateLootSpawn(-2107.810058, -963.299987, 31.229999,	4, 30, loot_Civilian);
	CreateLootSpawn(-2159.469970, -407.820007, 34.420001,	4, 30, loot_Civilian);
	CreateLootSpawn(-2149.800048, -430.660003, 34.420001,	4, 30, loot_Civilian);
	CreateLootSpawn(-2218.739990, -376.890014, 34.569999,	4, 30, loot_Civilian);
	CreateLootSpawn(-2080.120117, -482.040008, 37.819999,	4, 30, loot_Civilian);
	CreateLootSpawn(-2058.780029, -493.720001, 34.619998,	4, 30, loot_Civilian);
	CreateLootSpawn(-2021.290039, -491.209991, 34.619998,	4, 30, loot_Civilian);
	CreateLootSpawn(-1990.859985, -488.829986, 34.619998,	4, 30, loot_Civilian);
	CreateLootSpawn(-1981.609985, -432.630004, 34.619998,	4, 30, loot_Civilian);
	CreateLootSpawn(-2024.709960, -397.570007, 34.610000,	4, 30, loot_Civilian);

	CreateLootSpawn(-2535.129882, -689.179992, 138.399993,	4, 30, loot_Industrial);
	CreateLootSpawn(-2052.120117, -860.059997, 31.239999,	4, 30, loot_Industrial);
	CreateLootSpawn(-1945.180053, -1082.579956, 29.850000,	4, 30, loot_Industrial);
	CreateLootSpawn(-1961.790039, -895.799987, 34.979999,	4, 30, loot_Industrial);
	CreateLootSpawn(-1976.109985, -501.649993, 24.799999,	4, 30, loot_Industrial);
	CreateLootSpawn(-2112.149902, -397.839996, 34.610000,	4, 30, loot_Industrial);

	CreateLootSpawn(-2287.800048, -341.369995, 49.979999,	5, 45, loot_Survivor);
	CreateLootSpawn(-2529.790039, -657.880004, 146.989990,	5, 45, loot_Survivor);
	CreateLootSpawn(-2635.080078, -498.980010, 69.379997,	4, 30, loot_Survivor);
}
District_Ship1()
{
	CreateLootSpawn(-2303.82, 1545.11, 17.89, 4, 30, loot_Industrial);
	CreateLootSpawn(-2351.49, 1550.50, 22.24, 4, 25, loot_Survivor);
	CreateLootSpawn(-2404.19, 1548.50, 25.07, 4, 30, loot_Industrial);
	CreateLootSpawn(-2512.85, 1545.25, 16.40, 4, 30, loot_Industrial);
	CreateLootSpawn(-2499.11, 1552.21, 23.23, 4, 25, loot_Survivor);
	CreateLootSpawn(-2485.59, 1533.88, 27.10, 4, 30, loot_Industrial);
	CreateLootSpawn(-2472.23, 1550.56, 35.85, 4, 30, loot_Industrial);
	CreateLootSpawn(-2474.53, 1552.21, 32.26, 4, 25, loot_Survivor);
	CreateLootSpawn(-2477.65, 1549.85, 32.30, 4, 30, loot_Industrial);
	CreateLootSpawn(-2471.47, 1538.77, 32.28, 4, 30, loot_Industrial);
	CreateLootSpawn(-2436.10, 1555.23, 1.22, 4, 25, loot_Survivor);
	CreateLootSpawn(-2426.36, 1536.40, 1.23, 4, 30, loot_Industrial);
	CreateLootSpawn(-2389.63, 1548.60, 1.15, 4, 30, loot_Industrial);
	CreateLootSpawn(-2404.49, 1534.92, 1.18, 4, 25, loot_Survivor);
	CreateLootSpawn(-2366.65, 1540.04, 1.14, 4, 30, loot_Industrial);
	CreateLootSpawn(-2378.08, 1554.39, 1.17, 4, 30, loot_Industrial);
}
District_Ship2()
{
	CreateLootSpawn(-1478.84, 1489.43, 7.32, 4, 30, loot_Industrial);
	CreateLootSpawn(-1404.98, 1486.13, 6.24, 4, 25, loot_Survivor);
	CreateLootSpawn(-1371.58, 1486.57, 2.71, 4, 30, loot_Industrial);
	CreateLootSpawn(-1390.89, 1482.97, 0.95, 4, 25, loot_Survivor);
	CreateLootSpawn(-1433.17, 1483.05, 0.93, 4, 30, loot_Industrial);
	CreateLootSpawn(-1425.41, 1490.25, 0.97, 4, 25, loot_Survivor);
}
