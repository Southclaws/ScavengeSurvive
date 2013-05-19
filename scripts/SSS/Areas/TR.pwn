public OnLoad()
{
	print("Loading Tierra Robada");
	CreateFuelOutlet(-1465.4766, 1868.2734, 32.8203, 2.0, 100.0, frandom(100.0));
	CreateFuelOutlet(-1464.9375, 1860.5625, 32.8203, 2.0, 100.0, frandom(100.0));
	CreateFuelOutlet(-1477.8516, 1867.3125, 32.8203, 2.0, 100.0, frandom(100.0));
	CreateFuelOutlet(-1477.6563, 1859.7344, 32.8203, 2.0, 100.0, frandom(100.0));

	CreateFuelOutlet(-1327.0313, 2685.5938, 50.4531, 2.0, 100.0, frandom(100.0));
	CreateFuelOutlet(-1327.7969, 2680.1250, 50.4531, 2.0, 100.0, frandom(100.0));
	CreateFuelOutlet(-1328.5859, 2674.7109, 50.4531, 2.0, 100.0, frandom(100.0));
	CreateFuelOutlet(-1329.2031, 2669.2813, 50.4531, 2.0, 100.0, frandom(100.0));

	District_Bayside();
	District_Quebrados();
	District_Barancas();
	District_Sherman();
	District_RobadaGen();

	return CallLocalFunction("robada_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad robada_OnLoad
forward robada_OnLoad();


District_Bayside()
{
	CreateLootSpawn(-2560.33521, 2256.71069, 4.03032,	3, 30, loot_Civilian);
	CreateLootSpawn(-2526.42236, 2230.25171, 3.97745,	3, 30, loot_Civilian);
	CreateLootSpawn(-2524.90869, 2241.80249, 3.97117,	3, 30, loot_Civilian);
	CreateLootSpawn(-2582.55981, 2307.26733, 5.99649,	3, 30, loot_Civilian);
	CreateLootSpawn(-2619.74927, 2249.61157, 7.15421,	3, 30, loot_Civilian);
	CreateLootSpawn(-2637.86987, 2334.30200, 7.49702,	3, 30, loot_Civilian);
	CreateLootSpawn(-2598.33618, 2357.89038, 8.88010,	3, 30, loot_Civilian);
	CreateLootSpawn(-2490.16113, 2358.32104, 9.10369,	3, 30, loot_Civilian);
	CreateLootSpawn(-2479.32104, 2488.71387, 17.21367,	3, 30, loot_Civilian);
	CreateLootSpawn(-2446.46899, 2513.36792, 14.67988,	3, 30, loot_Civilian);
	CreateLootSpawn(-2462.86694, 2496.75024, 15.72379,	3, 30, loot_Civilian);
	CreateLootSpawn(-2474.64990, 2449.87598, 16.31130,	3, 30, loot_Civilian);
	CreateLootSpawn(-2469.29956, 2407.16528, 15.65823,	3, 30, loot_Civilian);
	CreateLootSpawn(-2385.05615, 2441.33569, 8.35205,	3, 30, loot_Civilian);
	CreateLootSpawn(-2333.02271, 2431.87329, 6.29611,	3, 30, loot_Civilian);
	CreateLootSpawn(-2398.78931, 2404.83374, 7.91520,	3, 30, loot_Civilian);
	CreateLootSpawn(-2423.01440, 2401.30200, 12.09972,	3, 30, loot_Civilian);
	CreateLootSpawn(-2435.82764, 2350.67480, 3.95540,	3, 30, loot_Civilian);
	CreateLootSpawn(-2187.87866, 2413.00732, 4.15637,	3, 30, loot_Civilian);

	CreateLootSpawn(-2560.33521, 2256.71069, 4.03032,	3, 15, loot_Industrial);
	CreateLootSpawn(-2526.42236, 2230.25171, 3.97745,	3, 15, loot_Industrial);
	CreateLootSpawn(-2524.90869, 2241.80249, 3.97117,	3, 15, loot_Industrial);
	CreateLootSpawn(-2582.55981, 2307.26733, 5.99649,	3, 15, loot_Industrial);
	CreateLootSpawn(-2619.74927, 2249.61157, 7.15421,	3, 15, loot_Industrial);
	CreateLootSpawn(-2637.86987, 2334.30200, 7.49702,	3, 15, loot_Industrial);
	CreateLootSpawn(-2598.33618, 2357.89038, 8.88010,	3, 15, loot_Industrial);
	CreateLootSpawn(-2490.16113, 2358.32104, 9.10369,	3, 15, loot_Industrial);
	CreateLootSpawn(-2479.32104, 2488.71387, 17.21367,	3, 15, loot_Industrial);
	CreateLootSpawn(-2446.46899, 2513.36792, 14.67988,	3, 15, loot_Industrial);
	CreateLootSpawn(-2462.86694, 2496.75024, 15.72379,	3, 15, loot_Industrial);
	CreateLootSpawn(-2474.64990, 2449.87598, 16.31130,	3, 15, loot_Industrial);
	CreateLootSpawn(-2469.29956, 2407.16528, 15.65823,	3, 15, loot_Industrial);
	CreateLootSpawn(-2385.05615, 2441.33569, 8.35205,	3, 15, loot_Industrial);
	CreateLootSpawn(-2333.02271, 2431.87329, 6.29611,	3, 15, loot_Industrial);
	CreateLootSpawn(-2398.78931, 2404.83374, 7.91520,	3, 15, loot_Industrial);
	CreateLootSpawn(-2423.01440, 2401.30200, 12.09972,	3, 15, loot_Industrial);
	CreateLootSpawn(-2435.82764, 2350.67480, 3.95540,	3, 15, loot_Industrial);
	CreateLootSpawn(-2187.87866, 2413.00732, 4.15637,	3, 15, loot_Industrial);
	CreateLootSpawn(-2374.43481, 2216.36084, 3.96434,	3, 15, loot_Industrial);
	CreateLootSpawn(-2335.72559, 2298.06445, 3.96524,	3, 15, loot_Industrial);
	CreateLootSpawn(-2329.73682, 2315.89258, 2.47632,	3, 15, loot_Industrial);
	CreateLootSpawn(-2293.67725, 2232.15454, 3.97610,	3, 15, loot_Industrial);
	CreateLootSpawn(-2183.48145, 2418.57642, 3.96865,	3, 15, loot_Industrial);
	CreateLootSpawn(-2231.77466, 2400.19141, 1.47613,	3, 15, loot_Industrial);
	CreateLootSpawn(-2225.93579, 2393.84985, 1.46124,	3, 15, loot_Industrial);
	CreateLootSpawn(-2252.31836, 2420.18164, 1.47137,	3, 15, loot_Industrial);
	CreateLootSpawn(-2259.45630, 2428.16235, 1.45578,	3, 15, loot_Industrial);
	CreateLootSpawn(-2238.82446, 2447.77100, 1.46378,	3, 15, loot_Industrial);
	CreateLootSpawn(-2233.08887, 2440.96143, 1.47163,	3, 15, loot_Industrial);
	CreateLootSpawn(-2211.37817, 2420.07837, 1.47727,	3, 15, loot_Industrial);
	CreateLootSpawn(-2205.59912, 2413.41846, 1.46828,	3, 15, loot_Industrial);
	CreateLootSpawn(-2240.18384, 2466.76416, 3.95956,	3, 15, loot_Industrial);
	CreateLootSpawn(-2274.50879, 2431.53979, 3.95307,	3, 15, loot_Industrial);
	CreateLootSpawn(-2245.76953, 2372.29297, 3.96713,	3, 15, loot_Industrial);
	CreateLootSpawn(-2341.27051, 2476.00000, 3.96448,	3, 15, loot_Industrial);
	CreateLootSpawn(-2398.41309, 2356.26733, 3.95593,	3, 15, loot_Industrial);
	CreateLootSpawn(-2450.41357, 2304.93896, 3.97062,	3, 15, loot_Industrial);
	CreateLootSpawn(-2482.99463, 2291.23755, 3.95833,	3, 15, loot_Industrial);
	CreateLootSpawn(-2521.22607, 2293.64429, 3.96985,	3, 15, loot_Industrial);
	CreateLootSpawn(-2505.22485, 2367.41650, 3.96825,	3, 15, loot_Industrial);
	CreateLootSpawn(-2529.43018, 2353.90942, 3.97955,	3, 15, loot_Industrial);
	CreateLootSpawn(-2463.07837, 2518.56689, 15.80178,	3, 15, loot_Industrial);

	CreateLootSpawn(-2481.05078, 2282.49438, 18.11488,	2, 5, loot_Survivor);
	CreateLootSpawn(-2499.54834, 2302.89990, 14.58998,	2, 5, loot_Survivor);
	CreateLootSpawn(-2481.34180, 2316.34912, 15.03521,	2, 5, loot_Survivor);
	CreateLootSpawn(-2522.76611, 2305.10547, 12.49624,	2, 5, loot_Survivor);
	CreateLootSpawn(-2538.14404, 2303.83374, 12.49173,	2, 5, loot_Survivor);
}


District_Quebrados()
{
	CreateLootSpawn(-1603.15735, 2690.23340, 54.28019,	3, 30, loot_Civilian);
	CreateLootSpawn(-1589.21973, 2705.65381, 55.16963,	3, 30, loot_Civilian);
	CreateLootSpawn(-1562.90332, 2707.99878, 54.82388,	3, 30, loot_Civilian);
	CreateLootSpawn(-1509.67725, 2697.67822, 54.82032,	3, 30, loot_Civilian);
	CreateLootSpawn(-1482.62170, 2701.84888, 55.23552,	3, 30, loot_Civilian);
	CreateLootSpawn(-1451.30042, 2690.63232, 55.16674,	3, 30, loot_Civilian);
	CreateLootSpawn(-1446.15125, 2587.79541, 54.82346,	3, 30, loot_Civilian);
	CreateLootSpawn(-1474.97388, 2562.43823, 55.16697,	3, 30, loot_Civilian);
	CreateLootSpawn(-1479.32251, 2546.72485, 55.24495,	3, 30, loot_Civilian);
	CreateLootSpawn(-1566.24890, 2647.57861, 54.82233,	3, 30, loot_Civilian);
	CreateLootSpawn(-1573.01965, 2629.06665, 54.83292,	3, 30, loot_Civilian);
	CreateLootSpawn(-1670.04419, 2589.70435, 80.35351,	3, 30, loot_Civilian);
	CreateLootSpawn(-1662.05762, 2551.03271, 84.27365,	3, 30, loot_Civilian);
	CreateLootSpawn(-1670.20569, 2553.19775, 84.30128,	3, 30, loot_Civilian);
	CreateLootSpawn(-1666.45190, 2481.40820, 86.18620,	3, 30, loot_Civilian);

	CreateLootSpawn(-1514.99573, 2568.54224, 54.82280,	3, 18, loot_Industrial);
	CreateLootSpawn(-1515.25476, 2578.12085, 54.82317,	3, 18, loot_Industrial);
	CreateLootSpawn(-1471.75647, 2621.21387, 57.75673,	3, 18, loot_Industrial);
	CreateLootSpawn(-1459.71008, 2629.84399, 57.75553,	3, 18, loot_Industrial);
	CreateLootSpawn(-1478.56006, 2640.58057, 57.77585,	3, 18, loot_Industrial);
	CreateLootSpawn(-1484.09644, 2615.09448, 57.77431,	3, 18, loot_Industrial);
	CreateLootSpawn(-1470.46643, 2626.93335, 54.82856,	3, 18, loot_Industrial);
	CreateLootSpawn(-1456.86731, 2644.52148, 54.83415,	3, 18, loot_Industrial);
	CreateLootSpawn(-1274.00061, 2723.84473, 49.25645,	3, 20, loot_Industrial);
	CreateLootSpawn(-1321.17041, 2706.52368, 49.06358,	3, 20, loot_Industrial);

	CreateLootSpawn(-1390.06812, 2641.60620, 54.98318,	2, 30, loot_Police);

	CreateLootSpawn(-1514.76123, 2521.80200, 54.83961,	3, 30, loot_Medical);
	CreateLootSpawn(-1510.41077, 2519.64673, 54.89139,	3, 30, loot_Medical);
	CreateLootSpawn(-1519.04895, 2519.97070, 54.88930,	3, 30, loot_Medical);
	CreateLootSpawn(-1500.28870, 2528.68286, 54.66892,	3, 30, loot_Medical);
	CreateLootSpawn(-1528.54492, 2523.11426, 54.79468,	3, 30, loot_Medical);

	CreateLootSpawn(-1504.42444, 2625.95996, 54.82740,	2, 15, loot_Survivor);
	CreateLootSpawn(-1509.39148, 2612.84082, 58.56698,	2, 15, loot_Survivor);
	CreateLootSpawn(-1444.17346, 2616.59082, 60.03917,	2, 15, loot_Survivor);
	CreateLootSpawn(-1510.69812, 2585.29736, 60.02413,	2, 15, loot_Survivor);

}

District_Barancas()
{
	CreateLootSpawn(-637.60626, 1442.92505, 12.60786,	3, 30, loot_Civilian);
	CreateLootSpawn(-654.76465, 1446.82837, 12.60757,	3, 30, loot_Civilian);
	CreateLootSpawn(-716.42871, 1438.43323, 17.88206,	3, 30, loot_Civilian);
	CreateLootSpawn(-770.97913, 1449.68933, 12.91093,	3, 30, loot_Civilian);
	CreateLootSpawn(-791.18585, 1423.66284, 12.91914,	3, 30, loot_Civilian);
	CreateLootSpawn(-827.53320, 1450.50830, 13.01999,	3, 30, loot_Civilian);
	CreateLootSpawn(-905.66498, 1515.38220, 25.31052,	3, 30, loot_Civilian);
	CreateLootSpawn(-938.47705, 1425.14172, 29.42587,	3, 30, loot_Civilian);
	CreateLootSpawn(-1051.02393, 1548.58740, 32.42755,	3, 30, loot_Civilian);
	CreateLootSpawn(-880.96838, 1546.20618, 24.89556,	3, 30, loot_Civilian);
	CreateLootSpawn(-857.03998, 1535.93469, 21.58257,	3, 30, loot_Civilian);
	CreateLootSpawn(-781.17700, 1635.92273, 26.04301,	3, 30, loot_Civilian);
	CreateLootSpawn(-828.19196, 1502.57104, 18.49405,	3, 30, loot_Civilian);
	CreateLootSpawn(-748.38422, 1588.45947, 25.95566,	3, 30, loot_Civilian);

	CreateLootSpawn(-733.56732, 1546.22961, 38.00749,	3, 20, loot_Survivor);
	CreateLootSpawn(-692.57898, 1549.16516, 81.65029,	3, 20, loot_Survivor);
}

District_Sherman()
{
	CreateLootSpawn(-897.95825, 1976.49341, 59.62031,	3, 25, loot_Civilian);
	CreateLootSpawn(-895.60889, 1967.39795, 59.62622,	3, 25, loot_Civilian);
	CreateLootSpawn(-939.20490, 2026.91345, 59.88820,	3, 25, loot_Civilian);
	CreateLootSpawn(-895.34863, 2006.79419, 59.90656,	3, 25, loot_Civilian);
	CreateLootSpawn(-924.01068, 2003.89404, 59.90224,	3, 25, loot_Civilian);
	CreateLootSpawn(-794.89850, 2026.19446, 59.37967,	3, 25, loot_Civilian);
	CreateLootSpawn(-714.41473, 2046.09729, 59.36851,	3, 25, loot_Civilian);
	CreateLootSpawn(-616.33447, 2026.93787, 59.38301,	3, 25, loot_Civilian);

	CreateLootSpawn(-821.93060, 1821.88074, 5.98079,	3, 30, loot_Industrial);
	CreateLootSpawn(-808.59399, 1862.17664, 5.97852,	3, 30, loot_Industrial);
	CreateLootSpawn(-831.33447, 1975.07141, 5.97241,	3, 30, loot_Industrial);
	CreateLootSpawn(-592.67542, 1982.13550, 5.99131,	3, 30, loot_Industrial);
	CreateLootSpawn(-605.13605, 1931.04871, 5.98274,	3, 30, loot_Industrial);
	CreateLootSpawn(-618.54901, 1881.80627, 5.98871,	3, 30, loot_Industrial);
	CreateLootSpawn(-609.70947, 1814.44824, 5.98118,	3, 30, loot_Industrial);
	CreateLootSpawn(-651.29407, 2126.87793, 59.37933,	3, 30, loot_Industrial);
	CreateLootSpawn(-775.04413, 2089.03101, 59.37369,	3, 30, loot_Industrial);

	CreateLootSpawn(-832.40436, 2002.49146, 75.97985,	4, 20, loot_Survivor);
	CreateLootSpawn(-820.91925, 1861.41223, 21.91115,	4, 20, loot_Survivor);
	CreateLootSpawn(-828.01477, 1910.36804, 21.89612,	4, 20, loot_Survivor);
	CreateLootSpawn(-840.93866, 1977.09570, 21.87680,	4, 20, loot_Survivor);
	CreateLootSpawn(-755.40234, 2039.20459, 76.88585,	4, 20, loot_Survivor);
	CreateLootSpawn(-675.10614, 2043.95508, 76.88017,	4, 20, loot_Survivor);
	CreateLootSpawn(-597.14282, 2014.70801, 75.97655,	4, 20, loot_Survivor);
	CreateLootSpawn(-582.33557, 1986.65576, 21.90201,	4, 20, loot_Survivor);
	CreateLootSpawn(-588.16498, 1940.66040, 21.90247,	4, 20, loot_Survivor);
	CreateLootSpawn(-601.43585, 1874.48242, 21.90022,	4, 20, loot_Survivor);
	CreateLootSpawn(-903.92273, 1919.63708, 122.02664,	4, 20, loot_Survivor);
	CreateLootSpawn(-897.47742, 1870.62500, 116.91568,	4, 20, loot_Survivor);
	CreateLootSpawn(-837.24481, 2009.47095, 59.17081,	4, 20, loot_Survivor);
	CreateLootSpawn(-839.95380, 2019.51074, 59.37107,	4, 20, loot_Survivor);
	CreateLootSpawn(-881.05548, 1998.04822, 59.19070,	4, 20, loot_Survivor);

}

District_RobadaGen()
{
	CreateLootSpawn(-2084.18799, 2308.36963, 22.98837,	3, 25, loot_Civilian);
	CreateLootSpawn(-1957.37402, 2391.17017, 48.48126,	3, 25, loot_Civilian);
	CreateLootSpawn(-1312.63354, 2532.77979, 86.72825,	3, 25, loot_Civilian);
	CreateLootSpawn(-1289.87146, 2510.56812, 86.01758,	3, 25, loot_Civilian);
	CreateLootSpawn(-1333.11206, 2527.40259, 86.05123,	3, 25, loot_Civilian);
	CreateLootSpawn(-1803.35120, 2038.16907, 8.58781,	3, 25, loot_Civilian);
	CreateLootSpawn(-1830.81348, 2043.56677, 7.56844,	3, 25, loot_Civilian);
	CreateLootSpawn(-1431.80713, 2173.01807, 49.02753,	3, 25, loot_Civilian);
	CreateLootSpawn(-1497.36926, 1964.75525, 47.40289,	3, 25, loot_Civilian);
	CreateLootSpawn(-1220.32092, 1842.07996, 40.61417,	3, 25, loot_Civilian);
	CreateLootSpawn(-1365.47742, 2057.56055, 51.53279,	3, 25, loot_Civilian);
	CreateLootSpawn(-692.68323, 928.51282, 12.62511,	3, 25, loot_Civilian);
	CreateLootSpawn(-685.78192, 939.49304, 12.63766,	3, 25, loot_Civilian);
	CreateLootSpawn(-683.28857, 942.53912, 15.82795,	3, 25, loot_Civilian);
	CreateLootSpawn(-665.74475, 877.97656, 0.99825,		3, 25, loot_Civilian);

	CreateLootSpawn(-1832.72266, 2059.21997, 8.70734,	3, 20, loot_Industrial);
	CreateLootSpawn(-1512.04004, 1972.73035, 47.41776,	3, 20, loot_Industrial);
	CreateLootSpawn(-1503.97571, 1978.29919, 47.41971,	3, 20, loot_Industrial);
	CreateLootSpawn(-1381.84265, 2114.90283, 41.18408,	3, 20, loot_Industrial);
	CreateLootSpawn(-1374.62378, 2108.19263, 41.18366,	3, 20, loot_Industrial);
	CreateLootSpawn(-1227.88245, 1834.90979, 40.60062,	3, 20, loot_Industrial);
	CreateLootSpawn(-672.89850, 961.59961, 11.12390,	3, 20, loot_Industrial);
	CreateLootSpawn(-689.60468, 970.07257, 11.17480,	3, 20, loot_Industrial);
	CreateLootSpawn(-657.66016, 879.13013, 0.99663,		3, 20, loot_Industrial);
	CreateLootSpawn(-666.04785, 939.41364, 11.11209,	3, 20, loot_Industrial);

	CreateLootSpawn(-2091.51270, 2313.77466, 24.88898,	3, 15, loot_Survivor);
	CreateLootSpawn(-1314.31531, 2546.07446, 86.72868,	3, 15, loot_Survivor);
	CreateLootSpawn(-1311.71777, 2512.58179, 86.03461,	3, 15, loot_Survivor);
	CreateLootSpawn(-1317.55945, 2524.69678, 86.47644,	3, 15, loot_Survivor);
	CreateLootSpawn(-1290.96448, 2513.11328, 86.03764,	3, 15, loot_Survivor);
	CreateLootSpawn(-696.70526, 934.70117, 15.82476,	3, 15, loot_Survivor);
}
