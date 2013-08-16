public OnLoad()
{
	print("Loading Los Santos");

	CreateFuelOutlet(1941.65625, -1778.45313, 14.14063, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1941.65625, -1774.31250, 14.14063, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1941.65625, -1771.34375, 14.14063, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1941.65625, -1767.28906, 14.14063, 2.0, 100.0, frandom(40.0));

	CreateZipline(
		2159.08, -986.47, 70.59,
		2063.30, -993.57, 59.38, .worldid = 3);

	CreateZipline(
		2152.75, -1027.94, 73.47,
		2191.36, -1051.42, 57.25, .worldid = 3);

	CreateZipline(
		2228.26, -1120.77, 48.88,
		2200.78, -1096.47, 42.13, .worldid = 3);

	LS_District_Housing1();
	LS_District_Housing2();
	LS_District_Housing3();
	LS_District_Housing4();
	LS_District_Seafront();
	LS_District_Industrial();
	LS_District_Docks();
	LS_District_Airport();
	LS_District_VerdantBluffs();
	LS_District_City1();
	LS_District_City2();
	LS_District_City3();

	return CallLocalFunction("santos_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad santos_OnLoad
forward santos_OnLoad();


LS_District_Housing1()
{

}

LS_District_Housing2()
{

}

LS_District_Housing3()
{

}

LS_District_Housing4()
{
	CreateLootSpawn(2529.212402, 746.210388, 13.727939,		3, 30, loot_Civilian);
	CreateLootSpawn(2536.050048, 716.275268, 9.810350,		3, 30, loot_Civilian);
	CreateLootSpawn(2536.044433, 717.308288, 13.727910,		3, 30, loot_Civilian);
	CreateLootSpawn(2530.483642, 746.163574, 9.809390,		3, 30, loot_Civilian);
	CreateLootSpawn(2447.997802, 712.438659, 10.430749,		3, 30, loot_Civilian);
	CreateLootSpawn(2447.347412, 691.438598, 10.429599,		3, 30, loot_Civilian);
	CreateLootSpawn(2448.320068, 661.740722, 10.436309,		3, 30, loot_Civilian);
	CreateLootSpawn(2575.773437, 716.156616, 9.810990,		3, 30, loot_Civilian);
	CreateLootSpawn(2655.451416, 717.334716, 13.728429,		3, 30, loot_Civilian);
	CreateLootSpawn(2663.015136, 746.588439, 9.811160,		3, 30, loot_Civilian);
	CreateLootSpawn(2662.460205, 746.575500, 13.728710,		3, 30, loot_Civilian);
	CreateLootSpawn(2655.032714, 716.946289, 9.810669,		3, 30, loot_Civilian);
	CreateLootSpawn(2575.261718, 717.110412, 13.728460,		3, 30, loot_Civilian);
	CreateLootSpawn(2617.114746, 715.517761, 9.810600,		3, 30, loot_Civilian);
	CreateLootSpawn(2617.070556, 716.836364, 13.728159,		3, 30, loot_Civilian);
	CreateLootSpawn(2347.247802, 655.013305, 10.424449,		3, 30, loot_Civilian);
	CreateLootSpawn(2367.012451, 653.568481, 10.431889,		3, 30, loot_Civilian);
	CreateLootSpawn(2397.887939, 654.839477, 10.432239,		3, 30, loot_Civilian);
	CreateLootSpawn(2317.868408, 654.195922, 10.424309,		3, 30, loot_Civilian);
	CreateLootSpawn(2209.342041, 654.194458, 10.431139,		3, 30, loot_Civilian);
	CreateLootSpawn(2228.561279, 653.509643, 10.431929,		3, 30, loot_Civilian);
	CreateLootSpawn(2258.473632, 654.241638, 10.424369,		3, 30, loot_Civilian);
	CreateLootSpawn(2397.191894, 691.481872, 10.422450,		3, 30, loot_Civilian);
	CreateLootSpawn(2367.036621, 733.299255, 10.430660,		3, 30, loot_Civilian);
	CreateLootSpawn(2398.945800, 734.115783, 10.431500,		3, 30, loot_Civilian);
	CreateLootSpawn(2448.066650, 742.206542, 10.430379,		3, 30, loot_Civilian);
	CreateLootSpawn(2346.703613, 735.044067, 10.431070,		3, 30, loot_Civilian);
	CreateLootSpawn(2367.769775, 691.429992, 10.421369,		3, 30, loot_Civilian);
	CreateLootSpawn(2347.972167, 692.932434, 10.429059,		3, 30, loot_Civilian);
	CreateLootSpawn(2316.832763, 692.246704, 10.428279,		3, 30, loot_Civilian);
	CreateLootSpawn(2845.474365, 1292.578735, 10.390649,	3, 30, loot_Civilian);
	CreateLootSpawn(2840.902343, 1323.954345, 10.382340,	3, 30, loot_Civilian);
	CreateLootSpawn(2840.524414, 1303.710571, 10.390130,	3, 30, loot_Civilian);
	CreateLootSpawn(2846.864746, 983.977050, 9.730420,		3, 30, loot_Civilian);
	CreateLootSpawn(2814.090576, 972.075012, 9.730509,		3, 30, loot_Civilian);
	CreateLootSpawn(2857.505126, 1313.865722, 10.383749,	3, 30, loot_Civilian);
	CreateLootSpawn(2855.473632, 1288.005859, 10.386739,	3, 30, loot_Civilian);
	CreateLootSpawn(2840.733886, 1278.551025, 10.384710,	3, 30, loot_Civilian);
	CreateLootSpawn(2813.613525, 892.617492, 9.728320,		3, 30, loot_Civilian);
	CreateLootSpawn(2850.873779, 891.994995, 9.729080,		3, 30, loot_Civilian);
	CreateLootSpawn(2838.092529, 857.174316, 9.728580,		3, 30, loot_Civilian);
	CreateLootSpawn(2812.443115, 857.125976, 9.729590,		3, 30, loot_Civilian);
	CreateLootSpawn(2853.561767, 1007.098937, 9.726630,		3, 30, loot_Civilian);
	CreateLootSpawn(2841.264160, 1252.038452, 10.374090,	3, 30, loot_Civilian);
	CreateLootSpawn(2781.696289, 1455.268188, 9.807920,		3, 30, loot_Civilian);
	CreateLootSpawn(2805.344482, 1336.131591, 9.714719,		3, 30, loot_Civilian);
	CreateLootSpawn(2764.591308, 1269.994384, 9.731579,		3, 30, loot_Civilian);
	CreateLootSpawn(2764.768310, 1290.838989, 9.734120,		3, 30, loot_Civilian);
	CreateLootSpawn(2804.960449, 1358.139648, 9.710240,		3, 30, loot_Civilian);
	CreateLootSpawn(2853.109619, 1355.202758, 9.763990,		3, 30, loot_Civilian);
	CreateLootSpawn(2845.113525, 1376.550903, 9.741649,		3, 30, loot_Civilian);
	CreateLootSpawn(2813.324707, 1375.385253, 9.706819,		3, 30, loot_Civilian);
	CreateLootSpawn(2790.842041, 1295.632324, 9.730360,		3, 30, loot_Civilian);
	CreateLootSpawn(2815.290039, 1252.746948, 10.312129,	3, 30, loot_Civilian);
	CreateLootSpawn(2846.227294, 1245.808105, 10.391010,	3, 30, loot_Civilian);
	CreateLootSpawn(2856.911865, 1267.264160, 10.382690,	3, 30, loot_Civilian);
	CreateLootSpawn(2787.594238, 1253.122924, 10.312359,	3, 30, loot_Civilian);
	CreateLootSpawn(2690.760009, 826.702209, 9.105250,		3, 30, loot_Civilian);
	CreateLootSpawn(2694.220703, 826.905456, 9.156709,		3, 30, loot_Civilian);
	CreateLootSpawn(2773.087646, 1245.720092, 10.312390,	3, 30, loot_Civilian);
	CreateLootSpawn(1951.799804, 665.274902, 9.799819,		3, 30, loot_Civilian);
	CreateLootSpawn(1925.541748, 663.871948, 13.253800,		3, 30, loot_Civilian);
	CreateLootSpawn(1918.325073, 664.505432, 9.806320,		3, 30, loot_Civilian);
	CreateLootSpawn(1956.461547, 678.527954, 13.251810,		3, 30, loot_Civilian);
	CreateLootSpawn(1979.425781, 672.988037, 9.793510,		3, 30, loot_Civilian);
	CreateLootSpawn(1979.443481, 715.915954, 9.804750,		3, 30, loot_Civilian);
	CreateLootSpawn(1979.446655, 733.980957, 9.810979,		3, 30, loot_Civilian);
	CreateLootSpawn(1897.759399, 665.543884, 13.252229,		3, 30, loot_Civilian);
	CreateLootSpawn(1935.143554, 739.833984, 14.984930,		3, 30, loot_Civilian);
	CreateLootSpawn(1955.215209, 742.057312, 9.809760,		3, 30, loot_Civilian);
	CreateLootSpawn(1956.058349, 718.559631, 13.259249,		3, 30, loot_Civilian);
	CreateLootSpawn(1909.347900, 742.410400, 9.809780,		3, 30, loot_Civilian);
	CreateLootSpawn(1898.134399, 675.337280, 9.814530,		3, 30, loot_Civilian);
	CreateLootSpawn(1897.471923, 721.835205, 13.256959,		3, 30, loot_Civilian);
	CreateLootSpawn(1909.026733, 742.023620, 13.259039,		3, 30, loot_Civilian);
	CreateLootSpawn(1887.994262, 641.647888, 9.800900,		3, 30, loot_Civilian);
	CreateLootSpawn(1908.071411, 641.926696, 9.799850,		3, 30, loot_Civilian);
	CreateLootSpawn(1927.545043, 641.869934, 9.795700,		3, 30, loot_Civilian);
	CreateLootSpawn(1847.739257, 659.965148, 10.450579,		3, 30, loot_Civilian);
	CreateLootSpawn(1847.000244, 740.260925, 10.450090,		3, 30, loot_Civilian);
	CreateLootSpawn(1846.061523, 719.222717, 10.449279,		3, 30, loot_Civilian);
	CreateLootSpawn(1846.130004, 690.921142, 10.441949,		3, 30, loot_Civilian);
	CreateLootSpawn(1954.227416, 641.173767, 9.793620,		3, 30, loot_Civilian);
	CreateLootSpawn(1946.672485, 764.314025, 9.797030,		3, 30, loot_Civilian);
	CreateLootSpawn(1926.333496, 764.244140, 9.801360,		3, 30, loot_Civilian);
	CreateLootSpawn(1894.868164, 764.406005, 9.801859,		3, 30, loot_Civilian);
	CreateLootSpawn(1875.604614, 752.290832, 9.799139,		3, 30, loot_Civilian);
	CreateLootSpawn(1875.266723, 646.387268, 9.784009,		3, 30, loot_Civilian);
	CreateLootSpawn(1875.866455, 673.159179, 9.789310,		3, 30, loot_Civilian);
	CreateLootSpawn(1875.969482, 724.658691, 9.797550,		3, 30, loot_Civilian);
	CreateLootSpawn(2124.900634, 652.876220, 10.439590,		3, 30, loot_Civilian);
	CreateLootSpawn(2167.575927, 774.213562, 10.444919,		3, 30, loot_Civilian);
	CreateLootSpawn(2178.019531, 734.434692, 10.432769,		3, 30, loot_Civilian);
	CreateLootSpawn(2093.813964, 652.809753, 10.441610,		3, 30, loot_Civilian);
	CreateLootSpawn(2044.205566, 652.762023, 10.439049,		3, 30, loot_Civilian);
	CreateLootSpawn(2013.356811, 652.578918, 10.437109,		3, 30, loot_Civilian);
	CreateLootSpawn(2064.983886, 651.948242, 10.441069,		3, 30, loot_Civilian);
	CreateLootSpawn(2206.404541, 734.414245, 10.435059,		3, 30, loot_Civilian);
	CreateLootSpawn(2207.468750, 693.141723, 10.433589,		3, 30, loot_Civilian);
	CreateLootSpawn(2177.299072, 691.747863, 10.434559,		3, 30, loot_Civilian);
	CreateLootSpawn(2178.341064, 654.173645, 10.431240,		3, 30, loot_Civilian);
	CreateLootSpawn(2228.584228, 691.382202, 10.426580,		3, 30, loot_Civilian);
	CreateLootSpawn(2226.975341, 733.346984, 10.433520,		3, 30, loot_Civilian);
	CreateLootSpawn(2258.053466, 734.149047, 10.435950,		3, 30, loot_Civilian);
	CreateLootSpawn(2256.820556, 692.370971, 10.437849,		3, 30, loot_Civilian);
	CreateLootSpawn(2123.395751, 774.333007, 10.428339,		3, 30, loot_Civilian);
	CreateLootSpawn(2123.978271, 732.836853, 10.440119,		3, 30, loot_Civilian);
	CreateLootSpawn(2093.014160, 732.045593, 10.432439,		3, 30, loot_Civilian);
	CreateLootSpawn(2092.385009, 773.298217, 10.435589,		3, 30, loot_Civilian);
	CreateLootSpawn(2012.646728, 773.360351, 10.451379,		3, 30, loot_Civilian);
	CreateLootSpawn(2043.672607, 774.018005, 10.435790,		3, 30, loot_Civilian);
	CreateLootSpawn(2072.898193, 774.429748, 10.438489,		3, 30, loot_Civilian);
	CreateLootSpawn(2064.170654, 731.925537, 10.440839,		3, 30, loot_Civilian);
	CreateLootSpawn(2070.137695, 694.792358, 10.437879,		3, 30, loot_Civilian);
	CreateLootSpawn(2041.160644, 694.778869, 10.432370,		3, 30, loot_Civilian);
	CreateLootSpawn(2120.778808, 694.580017, 10.429920,		3, 30, loot_Civilian);
	CreateLootSpawn(2090.038574, 693.333984, 10.438429,		3, 30, loot_Civilian);
	CreateLootSpawn(2012.709960, 731.861816, 10.432820,		3, 30, loot_Civilian);
	CreateLootSpawn(2042.775634, 733.417114, 10.440560,		3, 30, loot_Civilian);
	CreateLootSpawn(2010.167114, 693.344299, 10.441379,		3, 30, loot_Civilian);
	CreateLootSpawn(2873.211669, 857.381896, 9.726920,		3, 30, loot_Industrial);
	CreateLootSpawn(2782.555175, 1444.410400, 9.697299,		3, 30, loot_Industrial);
	CreateLootSpawn(2855.535644, 857.542846, 8.775620,		3, 30, loot_Industrial);
	CreateLootSpawn(2620.626953, 787.885253, 9.923480,		3, 30, loot_Industrial);
	CreateLootSpawn(2657.514648, 820.808227, 9.933919,		3, 30, loot_Industrial);
	CreateLootSpawn(2803.995361, 971.088500, 9.731200,		3, 30, loot_Industrial);
	CreateLootSpawn(2796.349365, 992.150939, 9.734519,		3, 30, loot_Industrial);
	CreateLootSpawn(2825.062744, 971.675537, 9.730299,		3, 30, loot_Industrial);
	CreateLootSpawn(2695.729736, 785.236694, 9.819310,		3, 30, loot_Industrial);
	CreateLootSpawn(2697.610107, 901.041381, 9.362779,		3, 30, loot_Industrial);
	CreateLootSpawn(2697.428955, 909.045532, 9.681559,		3, 30, loot_Industrial);
	CreateLootSpawn(2697.137451, 889.989685, 9.050160,		3, 30, loot_Industrial);
	CreateLootSpawn(2678.800537, 873.528442, 9.929679,		3, 30, loot_Industrial);
	CreateLootSpawn(2670.821533, 861.369506, 9.929809,		3, 30, loot_Industrial);
	CreateLootSpawn(2833.593994, 891.795776, 9.733340,		3, 30, loot_Industrial);
	CreateLootSpawn(2873.040771, 892.470642, 9.731579,		3, 30, loot_Industrial);
	CreateLootSpawn(2855.617675, 891.785766, 8.764880,		3, 30, loot_Industrial);
	CreateLootSpawn(2817.860351, 857.514648, 8.779250,		3, 30, loot_Industrial);
	CreateLootSpawn(2800.143798, 873.696472, 9.731120,		3, 30, loot_Industrial);
	CreateLootSpawn(2866.996582, 945.688964, 9.732979,		3, 30, loot_Industrial);
	CreateLootSpawn(2846.875244, 997.378234, 9.732080,		3, 30, loot_Industrial);
	CreateLootSpawn(2796.452392, 1006.670166, 9.734970,		3, 30, loot_Industrial);
	CreateLootSpawn(2847.850097, 972.811950, 9.729630,		3, 30, loot_Industrial);
	CreateLootSpawn(2867.243408, 1007.540222, 9.731670,		3, 30, loot_Industrial);
	CreateLootSpawn(2846.678466, 955.902770, 9.728469,		3, 30, loot_Industrial);
	CreateLootSpawn(2564.632812, 809.404785, 15.800060,		3, 30, loot_Survivor);
	CreateLootSpawn(2701.368896, 812.986511, 20.759939,		3, 30, loot_Survivor);
	CreateLootSpawn(2687.198730, 835.802551, 20.759250,		3, 30, loot_Survivor);
	CreateLootSpawn(1095.047973, -646.960205, 112.635978,	3, 30, loot_Civilian);
	CreateLootSpawn(1094.899536, -661.714050, 112.636383,	3, 30, loot_Civilian);
	CreateLootSpawn(1085.937744, -635.391662, 112.305236,	3, 30, loot_Civilian);
	CreateLootSpawn(1041.130615, -654.946411, 119.107971,	3, 30, loot_Civilian);
	CreateLootSpawn(1045.108032, -641.735412, 119.112426,	3, 30, loot_Civilian);
	CreateLootSpawn(1135.143920, -747.198852, 96.174667,	3, 30, loot_Civilian);
	CreateLootSpawn(1102.444091, -819.516235, 85.941749,	3, 30, loot_Civilian);
	CreateLootSpawn(977.631530, -770.354431, 111.197792,	3, 30, loot_Civilian);
	CreateLootSpawn(1104.227294, -827.333740, 85.942916,	3, 30, loot_Civilian);
	CreateLootSpawn(1112.020263, -742.039367, 99.104232,	3, 30, loot_Civilian);
	CreateLootSpawn(1093.437255, -804.421813, 106.417587,	3, 30, loot_Civilian);
	CreateLootSpawn(1052.391845, -652.872863, 119.108680,	3, 30, loot_Civilian);
	CreateLootSpawn(867.733703, -716.377136, 104.675628,	3, 30, loot_Civilian);
	CreateLootSpawn(887.528259, -655.566284, 115.883132,	3, 30, loot_Civilian);
	CreateLootSpawn(861.563537, -726.639221, 104.673446,	3, 30, loot_Civilian);
	CreateLootSpawn(918.452331, -786.645629, 113.329711,	3, 30, loot_Civilian);
	CreateLootSpawn(859.925170, -730.430053, 100.441810,	3, 30, loot_Civilian);
	CreateLootSpawn(898.947692, -677.859497, 115.883850,	3, 30, loot_Civilian);
	CreateLootSpawn(980.691101, -676.830200, 120.933258,	3, 30, loot_Civilian);
	CreateLootSpawn(993.135986, -697.539428, 120.616493,	3, 30, loot_Civilian);
	CreateLootSpawn(1012.546325, -662.435058, 120.126197,	3, 30, loot_Civilian);
	CreateLootSpawn(951.461303, -719.148620, 121.206451,	3, 30, loot_Civilian);
	CreateLootSpawn(945.859558, -709.860839, 121.612876,	3, 30, loot_Civilian);
	CreateLootSpawn(1016.570129, -762.367980, 111.560012,	3, 30, loot_Civilian);
	CreateLootSpawn(785.515625, -827.304504, 69.282409,		3, 30, loot_Civilian);
	CreateLootSpawn(824.815734, -900.607116, 67.762443,		3, 30, loot_Civilian);
	CreateLootSpawn(787.779296, -842.866149, 59.622428,		3, 30, loot_Civilian);
	CreateLootSpawn(824.270629, -849.142211, 68.914703,		3, 30, loot_Civilian);
	CreateLootSpawn(828.134582, -858.386779, 69.325332,		3, 30, loot_Civilian);
	CreateLootSpawn(829.375305, -903.752014, 67.762260,		3, 30, loot_Civilian);
	CreateLootSpawn(828.365783, -924.567749, 54.388580,		3, 30, loot_Civilian);
	CreateLootSpawn(274.957580, -1279.969970, 73.589202,	3, 30, loot_Civilian);
	CreateLootSpawn(835.244812, -928.713317, 54.241069,		3, 30, loot_Civilian);
	CreateLootSpawn(841.033081, -897.429138, 67.763473,		3, 30, loot_Civilian);
	CreateLootSpawn(836.541015, -894.436889, 67.763656,		3, 30, loot_Civilian);
	CreateLootSpawn(876.966857, -875.652404, 76.780403,		3, 30, loot_Civilian);
	CreateLootSpawn(1035.934326, -823.972473, 100.846763,	3, 30, loot_Civilian);
	CreateLootSpawn(1006.771240, -842.054382, 94.456718,	3, 30, loot_Civilian);
	CreateLootSpawn(1037.658325, -828.063537, 96.610939,	3, 30, loot_Civilian);
	CreateLootSpawn(1029.854980, -813.601867, 100.844291,	3, 30, loot_Civilian);
	CreateLootSpawn(1034.007690, -812.044738, 100.843292,	3, 30, loot_Civilian);
	CreateLootSpawn(980.819641, -832.789306, 94.459182,		3, 30, loot_Civilian);
	CreateLootSpawn(858.240600, -828.285095, 88.494377,		3, 30, loot_Civilian);
	CreateLootSpawn(851.485900, -831.040039, 88.493766,		3, 30, loot_Civilian);
	CreateLootSpawn(910.246154, -816.867126, 102.124382,	3, 30, loot_Civilian);
	CreateLootSpawn(989.765747, -828.553405, 94.458282,		3, 30, loot_Civilian);
	CreateLootSpawn(936.416320, -847.176025, 92.802719,		3, 30, loot_Civilian);
	CreateLootSpawn(1533.866943, -813.983825, 71.142730,	3, 30, loot_Civilian);
	CreateLootSpawn(1532.097167, -800.497497, 71.708709,	3, 30, loot_Civilian);
	CreateLootSpawn(1540.311889, -841.431945, 63.299381,	3, 30, loot_Civilian);
	CreateLootSpawn(1548.520874, -803.145690, 71.203872,	3, 30, loot_Civilian);
	CreateLootSpawn(1538.473510, -850.723754, 63.299388,	3, 30, loot_Civilian);
	CreateLootSpawn(1517.512573, -764.102966, 78.908027,	3, 30, loot_Civilian);
	CreateLootSpawn(1421.626464, -619.477050, 91.177757,	3, 30, loot_Civilian);
	CreateLootSpawn(1506.791748, -667.748413, 94.561546,	3, 30, loot_Civilian);
	CreateLootSpawn(1431.847900, -619.604003, 91.177726,	3, 30, loot_Civilian);
	CreateLootSpawn(1525.692749, -774.528869, 78.875289,	3, 30, loot_Civilian);
	CreateLootSpawn(1535.175537, -760.810424, 78.940841,	3, 30, loot_Civilian);
	CreateLootSpawn(1563.198608, -856.781738, 60.371208,	3, 30, loot_Civilian);
	CreateLootSpawn(1479.787963, -916.824340, 49.597179,	3, 30, loot_Civilian);
	CreateLootSpawn(1467.028808, -916.828674, 53.828571,	3, 30, loot_Civilian);
	CreateLootSpawn(1431.023559, -884.731323, 49.700778,	3, 30, loot_Civilian);
	CreateLootSpawn(1430.005493, -893.234802, 49.643360,	3, 30, loot_Civilian);
	CreateLootSpawn(1421.731689, -885.577514, 49.651191,	3, 30, loot_Civilian);
	CreateLootSpawn(1467.001953, -921.779235, 49.597869,	3, 30, loot_Civilian);
	CreateLootSpawn(1528.317626, -891.045349, 60.115451,	3, 30, loot_Civilian);
	CreateLootSpawn(1550.797241, -845.283386, 67.056587,	3, 30, loot_Civilian);
	CreateLootSpawn(1527.878540, -893.665954, 56.650878,	3, 30, loot_Civilian);
	CreateLootSpawn(1464.371459, -904.530761, 53.832729,	3, 30, loot_Civilian);
	CreateLootSpawn(1468.249511, -904.178161, 53.835018,	3, 30, loot_Civilian);
	CreateLootSpawn(1486.101318, -667.842651, 94.557136,	3, 30, loot_Civilian);
	CreateLootSpawn(1243.037597, -802.799743, 83.131011,	3, 30, loot_Civilian);
	CreateLootSpawn(895.284484, -793.131652, 100.428787,	3, 30, loot_Civilian);
	CreateLootSpawn(1298.567382, -800.488952, 83.131446,	3, 30, loot_Civilian);
	CreateLootSpawn(1287.559326, -833.233703, 76.258453,	3, 30, loot_Civilian);
	CreateLootSpawn(1273.002807, -833.846252, 76.257789,	3, 30, loot_Civilian);
	CreateLootSpawn(895.692871, -780.266601, 100.314918,	3, 30, loot_Civilian);
	CreateLootSpawn(835.355834, -752.983215, 84.303909,		3, 30, loot_Civilian);
	CreateLootSpawn(849.050231, -745.502502, 93.965690,		3, 30, loot_Civilian);
	CreateLootSpawn(809.231811, -759.120300, 75.504142,		3, 30, loot_Civilian);
	CreateLootSpawn(890.810791, -782.179016, 100.301429,	3, 30, loot_Civilian);
	CreateLootSpawn(785.534912, -761.189941, 72.570640,		3, 30, loot_Civilian);
	CreateLootSpawn(1282.292968, -785.447143, 91.024963,	3, 30, loot_Civilian);
	CreateLootSpawn(1442.696411, -629.307006, 94.708923,	3, 30, loot_Civilian);
	CreateLootSpawn(1454.658203, -608.350585, 94.712547,	3, 30, loot_Civilian);
	CreateLootSpawn(1496.768798, -690.868652, 93.726387,	3, 30, loot_Civilian);
	CreateLootSpawn(1496.881225, -666.190307, 94.560546,	3, 30, loot_Civilian);
	CreateLootSpawn(1518.969360, -688.484313, 93.743209,	3, 30, loot_Civilian);
	CreateLootSpawn(1339.177734, -648.521057, 107.071739,	3, 30, loot_Civilian);
	CreateLootSpawn(1332.310546, -631.921997, 108.126403,	3, 30, loot_Civilian);
	CreateLootSpawn(1258.478271, -785.251770, 91.014427,	3, 30, loot_Civilian);
	CreateLootSpawn(1335.444091, -645.322387, 108.126121,	3, 30, loot_Civilian);
	CreateLootSpawn(1330.713378, -654.992614, 107.071876,	3, 30, loot_Civilian);
	CreateLootSpawn(1341.586181, -654.420959, 107.479858,	3, 30, loot_Civilian);
	CreateLootSpawn(432.782409, -1137.394287, 72.730583,	3, 30, loot_Civilian);
	CreateLootSpawn(408.263061, -1149.463867, 75.660186,	3, 30, loot_Civilian);
	CreateLootSpawn(358.405792, -1207.870971, 75.510726,	3, 30, loot_Civilian);
	CreateLootSpawn(351.205749, -1197.000366, 75.512298,	3, 30, loot_Civilian);
	CreateLootSpawn(359.351654, -1210.981445, 71.279457,	3, 30, loot_Civilian);
	CreateLootSpawn(243.016586, -1375.386474, 52.096641,	3, 30, loot_Civilian);
	CreateLootSpawn(565.556823, -1098.565307, 68.964828,	3, 30, loot_Civilian);
	CreateLootSpawn(255.215209, -1366.582641, 52.096851,	3, 30, loot_Civilian);
	CreateLootSpawn(416.221801, -1154.770629, 75.660278,	3, 30, loot_Civilian);
	CreateLootSpawn(471.038146, -1164.438598, 66.181663,	3, 30, loot_Civilian);
	CreateLootSpawn(135.500289, -1475.143554, 24.205350,	3, 30, loot_Civilian);
	CreateLootSpawn(143.119857, -1470.090454, 24.203420,	3, 30, loot_Civilian);
	CreateLootSpawn(298.785430, -1155.863403, 79.906867,	3, 30, loot_Civilian);
	CreateLootSpawn(286.083068, -1155.092895, 79.906173,	3, 30, loot_Civilian);
	CreateLootSpawn(638.602539, -1124.482666, 43.197608,	3, 30, loot_Civilian);
	CreateLootSpawn(649.876281, -1130.461303, 43.196029,	3, 30, loot_Civilian);
	CreateLootSpawn(618.659179, -1100.380249, 45.755290,	3, 30, loot_Civilian);
	CreateLootSpawn(666.502563, -1126.102294, 43.194129,	3, 30, loot_Civilian);
	CreateLootSpawn(348.363128, -1199.882690, 75.512237,	3, 30, loot_Civilian);
	CreateLootSpawn(151.921432, -1448.550537, 31.840219,	3, 30, loot_Civilian);
	CreateLootSpawn(223.743942, -1414.072753, 50.833969,	3, 30, loot_Civilian);
	CreateLootSpawn(682.885498, -1020.373779, 54.749771,	3, 30, loot_Civilian);
	CreateLootSpawn(567.666320, -1129.898437, 49.666309,	3, 30, loot_Civilian);
	CreateLootSpawn(671.962951, -1019.337097, 54.757061,	3, 30, loot_Civilian);
	CreateLootSpawn(684.330688, -1023.160888, 50.479560,	3, 30, loot_Civilian);
	CreateLootSpawn(699.315979, -1060.332153, 48.415031,	3, 30, loot_Civilian);
	CreateLootSpawn(690.547607, -1075.557128, 48.418418,	3, 30, loot_Civilian);
	CreateLootSpawn(712.604492, -1080.413208, 48.415359,	3, 30, loot_Civilian);
	CreateLootSpawn(647.094238, -1058.234619, 51.577579,	3, 30, loot_Civilian);
	CreateLootSpawn(657.602539, -1062.115356, 51.574909,	3, 30, loot_Civilian);
	CreateLootSpawn(162.454147, -1456.620605, 31.839540,	3, 30, loot_Civilian);
	CreateLootSpawn(742.744445, -1018.045898, 41.638648,	3, 30, loot_Civilian);
	CreateLootSpawn(558.737854, -1075.004516, 71.893943,	3, 30, loot_Civilian);
	CreateLootSpawn(612.072692, -1085.438232, 57.818740,	3, 30, loot_Civilian);
	CreateLootSpawn(567.205261, -1071.232788, 71.896171,	3, 30, loot_Civilian);
	CreateLootSpawn(729.184570, -994.615600, 51.727760,		3, 30, loot_Civilian);
	CreateLootSpawn(724.845520, -998.779968, 51.726139,		3, 30, loot_Civilian);
	CreateLootSpawn(730.748596, -1013.307983, 51.731239,	3, 30, loot_Civilian);
	CreateLootSpawn(736.240112, -1024.747924, 41.637889,	3, 30, loot_Civilian);
	CreateLootSpawn(228.416305, -1404.779418, 50.609661,	3, 30, loot_Civilian);
	CreateLootSpawn(407.100311, -1267.465332, 49.014381,	3, 30, loot_Civilian);
	CreateLootSpawn(552.952331, -1200.403930, 43.825080,	3, 30, loot_Civilian);
	CreateLootSpawn(190.692794, -1308.165405, 69.271697,	3, 30, loot_Civilian);
	CreateLootSpawn(225.844131, -1244.717651, 77.292137,	3, 30, loot_Civilian);
	CreateLootSpawn(543.800903, -1203.825927, 43.752048,	3, 30, loot_Civilian);
	CreateLootSpawn(598.146240, -1193.720092, 40.778678,	3, 30, loot_Civilian);
	CreateLootSpawn(219.748565, -1251.123291, 77.322029,	3, 30, loot_Civilian);
	CreateLootSpawn(353.834381, -1280.481201, 52.697940,	3, 30, loot_Civilian);
	CreateLootSpawn(567.630920, -1215.542724, 43.821758,	3, 30, loot_Civilian);
	CreateLootSpawn(166.326919, -1338.236206, 68.841026,	3, 30, loot_Civilian);
	CreateLootSpawn(436.467559, -1265.196899, 50.572601,	3, 30, loot_Civilian);
	CreateLootSpawn(398.050537, -1271.308715, 49.014308,	3, 30, loot_Civilian);
	CreateLootSpawn(398.707122, -1293.374511, 49.011318,	3, 30, loot_Civilian);
	CreateLootSpawn(252.808181, -1269.475585, 73.065032,	3, 30, loot_Civilian);
	CreateLootSpawn(167.591308, -1308.043212, 69.304290,	3, 30, loot_Civilian);
	CreateLootSpawn(189.267440, -1319.379150, 69.198921,	3, 30, loot_Civilian);
	CreateLootSpawn(278.461303, -1257.001586, 72.922218,	3, 30, loot_Civilian);
	CreateLootSpawn(168.813095, -1320.230102, 69.302696,	3, 30, loot_Civilian);
	CreateLootSpawn(142.110092, -1480.547973, 24.204179,	3, 30, loot_Civilian);
	CreateLootSpawn(230.536514, -1211.562133, 75.095382,	3, 30, loot_Civilian);
	CreateLootSpawn(130.424209, -1488.619384, 17.678600,	3, 30, loot_Civilian);
	CreateLootSpawn(259.288299, -1290.854370, 73.586486,	3, 30, loot_Civilian);
	CreateLootSpawn(247.828994, -1198.851684, 75.097412,	3, 30, loot_Civilian);
	CreateLootSpawn(315.945434, -1138.715332, 80.545181,	3, 30, loot_Civilian);
	CreateLootSpawn(646.208374, -1117.320800, 43.197418,	3, 30, loot_Civilian);
	CreateLootSpawn(239.273391, -1202.713745, 75.098030,	3, 30, loot_Civilian);
	CreateLootSpawn(253.583541, -1222.576538, 74.255119,	3, 30, loot_Civilian);
	CreateLootSpawn(265.958068, -1287.645874, 73.588417,	3, 30, loot_Civilian);
	CreateLootSpawn(211.172592, -1238.497680, 77.342002,	3, 30, loot_Civilian);
	CreateLootSpawn(339.791992, -1303.296508, 53.214389,	3, 30, loot_Civilian);
	CreateLootSpawn(297.602294, -1336.484741, 52.428981,	3, 30, loot_Civilian);
	CreateLootSpawn(138.698776, -1498.159057, 17.756820,	3, 30, loot_Civilian);
	CreateLootSpawn(608.600585, -1187.076538, 40.775199,	3, 30, loot_Civilian);
	CreateLootSpawn(568.342590, -1164.535278, 53.422389,	3, 30, loot_Civilian);
	CreateLootSpawn(811.360534, -768.384216, 75.505256,		3, 30, loot_Industrial);
	CreateLootSpawn(367.327362, -1288.546997, 43.035560,	3, 30, loot_Industrial);
	CreateLootSpawn(1248.792724, -802.612365, 83.131118,	3, 30, loot_Industrial);
	CreateLootSpawn(1253.709960, -803.835266, 83.131668,	3, 30, loot_Industrial);
	CreateLootSpawn(249.613555, -1359.674316, 52.099788,	3, 30, loot_Industrial);
	CreateLootSpawn(1352.966064, -625.243835, 108.128547,	3, 30, loot_Industrial);
	CreateLootSpawn(344.771209, -1303.897827, 53.214721,	3, 30, loot_Industrial);
	CreateLootSpawn(886.221069, -783.689086, 100.279029,	3, 30, loot_Industrial);
	CreateLootSpawn(1460.072143, -630.371643, 94.712226,	3, 30, loot_Industrial);
	CreateLootSpawn(1519.931396, -694.568786, 93.743637,	3, 30, loot_Industrial);
	CreateLootSpawn(911.187927, -830.235107, 91.018157,		3, 30, loot_Industrial);
	CreateLootSpawn(229.213745, -1242.393188, 77.274276,	3, 30, loot_Industrial);
	CreateLootSpawn(946.102478, -844.068115, 92.684448,		3, 30, loot_Industrial);
	CreateLootSpawn(1025.141967, -774.999511, 102.035911,	3, 30, loot_Industrial);
	CreateLootSpawn(280.931549, -1158.941162, 79.906898,	3, 30, loot_Industrial);
	CreateLootSpawn(859.186462, -846.728149, 76.372848,		3, 30, loot_Industrial);
	CreateLootSpawn(831.975402, -891.647338, 67.763740,		3, 30, loot_Industrial);
	CreateLootSpawn(275.029083, -1252.000732, 72.919982,	3, 30, loot_Industrial);
	CreateLootSpawn(172.325164, -1338.528076, 68.908439,	3, 30, loot_Industrial);
	CreateLootSpawn(796.162292, -838.998596, 59.621261,		3, 30, loot_Industrial);
	CreateLootSpawn(833.732849, -906.914550, 67.750038,		3, 30, loot_Industrial);
	CreateLootSpawn(1112.598632, -732.301513, 99.102752,	3, 30, loot_Industrial);
	CreateLootSpawn(908.976989, -663.750549, 115.881980,	3, 30, loot_Industrial);
	CreateLootSpawn(1007.808776, -665.422302, 120.130867,	3, 30, loot_Industrial);
	CreateLootSpawn(1039.473022, -643.276428, 119.112098,	3, 30, loot_Industrial);
	CreateLootSpawn(1086.067871, -640.915405, 112.304298,	3, 30, loot_Industrial);
	CreateLootSpawn(844.840881, -759.080139, 84.233680,		3, 30, loot_Industrial);
	CreateLootSpawn(864.486145, -714.903686, 104.675903,	3, 30, loot_Industrial);
	CreateLootSpawn(1403.268066, -806.831420, 84.004043,	3, 30, loot_Survivor);
	CreateLootSpawn(1378.265136, -807.000976, 83.926689,	3, 30, loot_Survivor);
	CreateLootSpawn(1416.041015, -806.788269, 84.003089,	3, 30, loot_Survivor);
	CreateLootSpawn(1537.370727, -895.949829, 56.650020,	3, 30, loot_Survivor);
	CreateLootSpawn(1385.285278, -806.811767, 85.251502,	3, 30, loot_Survivor);
	CreateLootSpawn(1394.573364, -806.562744, 83.998092,	3, 30, loot_Survivor);
	CreateLootSpawn(1427.392822, -806.559692, 85.447402,	3, 30, loot_Survivor);
	CreateLootSpawn(1505.987548, -914.790222, 57.684600,	3, 30, loot_Survivor);
	CreateLootSpawn(119.482597, -1507.323730, 26.581119,	3, 30, loot_Survivor);
	CreateLootSpawn(1505.111083, -915.415954, 60.985130,	3, 30, loot_Survivor);
	CreateLootSpawn(1500.361694, -902.360351, 64.419326,	3, 30, loot_Survivor);
	CreateLootSpawn(159.792404, -1459.343627, 35.305068,	3, 30, loot_Survivor);
	CreateLootSpawn(1438.975463, -807.153198, 85.448982,	3, 30, loot_Survivor);
	CreateLootSpawn(1502.262084, -915.816955, 57.683940,	3, 30, loot_Survivor);
	CreateLootSpawn(343.241058, -1309.003540, 49.755649,	3, 30, loot_Survivor);
	CreateLootSpawn(1426.884765, -907.539733, 46.484710,	3, 30, loot_Survivor);
	CreateLootSpawn(1449.433105, -806.858581, 83.227867,	3, 30, loot_Survivor);
	CreateLootSpawn(973.122009, -864.624389, 91.197616,		3, 30, loot_Survivor);
	CreateLootSpawn(971.749145, -865.358520, 91.197868,		3, 30, loot_Survivor);
	CreateLootSpawn(950.667419, -866.327270, 89.321853,		3, 30, loot_Survivor);
	CreateLootSpawn(946.303405, -868.018127, 92.623413,		3, 30, loot_Survivor);
	CreateLootSpawn(974.400512, -782.261779, 111.194999,	3, 30, loot_Survivor);
	CreateLootSpawn(934.900024, -817.913146, 111.971069,	3, 30, loot_Survivor);
	CreateLootSpawn(972.427551, -864.971618, 94.524803,		3, 30, loot_Survivor);
	CreateLootSpawn(1016.655212, -768.188537, 115.933319,	3, 30, loot_Survivor);
	CreateLootSpawn(881.893005, -896.018920, 80.367576,		3, 30, loot_Survivor);
	CreateLootSpawn(884.111328, -896.531738, 73.631027,		3, 30, loot_Survivor);
	CreateLootSpawn(327.073486, -1229.867797, 83.721473,	3, 30, loot_Survivor);
	CreateLootSpawn(826.032104, -933.207702, 59.710460,		3, 30, loot_Survivor);
	CreateLootSpawn(865.565063, -839.091430, 92.074203,		3, 30, loot_Survivor);
	CreateLootSpawn(241.197967, -1225.837890, 78.679908,	3, 30, loot_Survivor);
	CreateLootSpawn(880.879211, -897.984252, 73.628662,		3, 30, loot_Survivor);
	CreateLootSpawn(886.840698, -895.101623, 73.629646,		3, 30, loot_Survivor);
	CreateLootSpawn(1296.277343, -786.507751, 87.311271,	3, 30, loot_Survivor);
	CreateLootSpawn(546.318298, -1175.285278, 61.269580,	3, 30, loot_Survivor);
	CreateLootSpawn(617.738403, -1091.837036, 62.658779,	3, 30, loot_Survivor);
	CreateLootSpawn(1291.899414, -769.524475, 94.949676,	3, 30, loot_Survivor);
	CreateLootSpawn(609.945190, -1194.831420, 44.242420,	3, 30, loot_Survivor);
	CreateLootSpawn(446.143829, -1260.485961, 54.043449,	3, 30, loot_Survivor);
	CreateLootSpawn(540.222900, -1185.064819, 57.803409,	3, 30, loot_Survivor);
	CreateLootSpawn(567.682250, -1209.451171, 48.220928,	3, 30, loot_Survivor);
	CreateLootSpawn(933.759582, -806.292968, 118.702766,	3, 30, loot_Survivor);
	CreateLootSpawn(1100.393798, -825.205078, 113.444587,	3, 30, loot_Survivor);
	CreateLootSpawn(940.445922, -814.994750, 111.971298,	3, 30, loot_Survivor);
	CreateLootSpawn(937.440795, -816.831237, 115.271911,	3, 30, loot_Survivor);
	CreateLootSpawn(872.725341, -728.742370, 109.439796,	3, 30, loot_Survivor);
	CreateLootSpawn(572.920227, -1122.068237, 65.380149,	3, 30, loot_Survivor);
	CreateLootSpawn(492.328948, -1151.658447, 75.360023,	3, 30, loot_Survivor);
	CreateLootSpawn(735.094665, -1000.182617, 56.957099,	3, 30, loot_Survivor);
}

LS_District_Seafront()
{

}

LS_District_Industrial()
{

}

LS_District_Docks()
{

}

LS_District_Airport()
{

}

LS_District_VerdantBluffs()
{

}

LS_District_City1()
{

}

LS_District_City2()
{

}

LS_District_City3()
{

}
